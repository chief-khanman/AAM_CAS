# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft, SpawnFunction, PilotFunction, Airspace

# This is the main MDP object. The following interface is used to control it:
#= Minimal interfaces to implement to use the ReinforcementLearning.jl:

action_space(env::YourEnv)
state(env::YourEnv)
state_space(env::YourEnv)
reward(env::YourEnv)
is_terminated(env::YourEnv)
reset!(env::YourEnv)
(env::YourEnv)(action)

=#

mutable struct CollisionAvoidanceEnv <: AbstractEnv
    airspace::Airspace
    is_MDP::Bool
    pilot_function::Function
    rng::AbstractRNG
    # extra variables
    # timekeeping
    current_time::Number
    max_time::Number
    timestep::Number

    # distances
    nmac_distance::Number

end

# constructor. IF given no args, it will be an MDP
function CollisionAvoidanceEnv(;is_MDP::Bool=true,
                                boundary::Cartesian2=Cartesian2(10000, 10000), 
                                spawn_controller::AbstractSpawnController=ConstantSpawnrateController(boundary, is_MDP),
                                restricted_areas::ShapeManager=ShapeManager(),
                                waypoints::PathFinder = PathFinder(),
                                maximum_aircraft_acceleration::Polar2=Polar2(3.0, 2pi/10), # first is linear acceleration, second is change in direction
                                maximum_aircraft_speed::Number=50.0, 
                                detection_radius::Number=1000.0, 
                                pilot_function::Union{Nothing, Function}=nothing,
                                max_time::Number=3600.0, # 1 hour
                                timestep::Number=1.0,
                                arrival_distance::Number=100.0,
                                nmac_distance::Number=150.0,
                                rng::AbstractRNG=MersenneTwister(123)
                                )

    airspace = Airspace(    boundary=boundary, 
                            rng=rng,
                            create_ego_aircraft=is_MDP, 
                            spawn_controller=spawn_controller,
                            restricted_areas = restricted_areas,  
                            waypoints = waypoints,
                            maximum_aircraft_acceleration=maximum_aircraft_acceleration, 
                            maximum_aircraft_speed=maximum_aircraft_speed, 
                            detection_radius=detection_radius, 
                            arrival_radius=arrival_distance,
                        )
    if pilot_function == nothing
        pilot_function = default_pilot_function(maximum_aircraft_acceleration)
    end

    return CollisionAvoidanceEnv(airspace, is_MDP, pilot_function, rng, 0.0, max_time, timestep, nmac_distance )
end

# define possible actions in the action space. Note this is valid for both ego and non-ego aircraft
# so this method is callable for simulation too
function ReinforcementLearningBase.action_space(env::CollisionAvoidanceEnv)
    max_acceleration = env.airspace.maximum_aircraft_acceleration
    max_change_speed = max_acceleration.r
    max_change_direction = max_acceleration.θ

    action_space = Space(
        ClosedInterval{Number}[
            (-max_change_speed)..(max_change_speed),
            (-max_change_direction)..(max_change_direction),
        ],
    )
    return action_space
end

# Retrieve the state for the ego aircraft.
# Since a simulation has no ego, this function is not callable in simulation
function ReinforcementLearningBase.state(env::CollisionAvoidanceEnv)
    @assert env.is_MDP == true
    return getEgoState(env.airspace)
end

# define possible states in the state space. Note this is valid for both ego and non-ego aircraft
# so this method is callable for simulation too
function ReinforcementLearningBase.state_space(env::CollisionAvoidanceEnv)
    max_speed = env.airspace.maximum_aircraft_speed
    detection_radius = env.airspace.detection_radius

    state_space = Space(
        ClosedInterval{Number}[
            (-pi)..(pi), # deviation
            (0.0)..(max_speed), # my velocity
            (0.0)..(1.0), # isIntruder?
            (0.0)..(detection_radius), # distance to intruder
            (-pi)..(pi), # angle of intruder
            (-pi)..(pi), # relative heading of intruder
            (0.0)..(2 * max_speed), # relative velocity of intruder
        ],
    )
    return state_space
end

# Returns the reward for the current step for the ego agent.
# Since a simulation has no ego, this function is not callable in simulation
function ReinforcementLearningBase.reward(env::CollisionAvoidanceEnv)
    @assert env.is_MDP == true
    ego_state = state(env)

    # a small punishment for existing so it is incentivised to go home
    punishment_existing = -0.1

    # punishment for being close to others. Is small if farther than NMAC away, is large if within NMAC
    # note this tends to punish agent always
    # Set to 0 if there are no intruders
    if ego_state[3] == 0.0
        punishment_closeness = 0.0
    else
        normed_nmac_distance = env.nmac_distance / env.airspace.detection_radius
        punishment_closeness = -exp( (normed_nmac_distance - ego_state[4]) * 10.0) # = -e if colloision, e^-9 if very far away, exponential curve in between
    end

    # reward for approaching destination. Can be negative if we are going away
    # this is equal to the distance we have traveled towards the destination this timestep
    # will be most max speed (5.0 by default) to  -5.0
    # note the sum of reward_to_destination over an episode is the same regardless of route taken (assuming the ac gets to destination)
    reward_to_destination = ego_state[2] * cos(ego_state[1]) 

    # punishment for not facing direction. Punish more the farther away its pointed
    # Between 0 and -2 
    punishment_deviation = -2 * (ego_state[1] / pi) ^ 2

    # Sum all rewards. 
    reward_sum = punishment_existing + punishment_closeness + reward_to_destination + punishment_deviation
    
    # normalize over timestep. We dont want a more precise simulation to change reward incentives
    reward_sum *= env.timestep


    return reward_sum
end

# Returns if the current run has terminated.
# If this is an MDP, returns if the ego agent has arrived.
# if this is a simulation, returns based on time limit
function ReinforcementLearningBase.is_terminated(env::CollisionAvoidanceEnv)
    if env.is_MDP
        return hasArrived(env.airspace.all_aircraft[1], env.airspace.arrival_radius)[2] || env.current_time >= env.max_time
    else
        return env.current_time >= env.max_time
    end
end

# Resets the airspace to empty. Callable for both MDP and simulation
function ReinforcementLearningBase.reset!(env::CollisionAvoidanceEnv)
    reset!(env.airspace)
    env.current_time = 0.0
end

# Applies the action to the ego, and steps through time
# Only callable for MDP
function (env::CollisionAvoidanceEnv)(action)
    @assert env.is_MDP == true
    
    #println(action_space(env))
    #println(action)
    # @assert action in action_space(env)

    # note we would want the action to always be in the action space
    # but due to PPO we cannot gurantee it.
    # So we are going to clip it ourselves
    # note this is done automatically internally

    action = Polar2(action[1], action[2])
    setEgoAcceleration(env.airspace, action)

    step!(env)
end

# Steps the environment through time. Uses the pilot function on all non-ego aircraft. 
function step!(env::CollisionAvoidanceEnv)
    # fetch state of all ac
    all_states = getAllStates(env.airspace)
    
    # For each state, create an action based on the pilot function
    all_actions = Vector{Polar2}(undef, 0)
    for state in all_states
        action = env.pilot_function(state, env.rng)
        action = Polar2(action[1], action[2])
        push!(all_actions, action)
    end

    # apply action to all ac
    setAllAccelerations(env.airspace, all_actions)

    # step airspace
    step!(env.airspace, env.timestep, env.current_time, env.nmac_distance)
    env.current_time += env.timestep
end


function Random.seed!(env::CollisionAvoidanceEnv, s)
    env.rng = MersenneTwister(s)
end


function simulate!(env::CollisionAvoidanceEnv)
    ReinforcementLearningBase.reset!(env)
    done = false
    while !done
        done = is_terminated(env)
        step!(env)
    end
end


# casting them to normal name space.
# this way, you can use reset!(env) or ReinforcementLearningBase.reset!(env)
# However, for wrapped environments, note you MUST use ReinforcementLearningBase.
action_space(env::CollisionAvoidanceEnv) =      ReinforcementLearningBase.action_space(env::CollisionAvoidanceEnv)
state(env::CollisionAvoidanceEnv) =             ReinforcementLearningBase.state(env::CollisionAvoidanceEnv)
state_space(env::CollisionAvoidanceEnv) =       ReinforcementLearningBase.state_space(env::CollisionAvoidanceEnv)
reward(env::CollisionAvoidanceEnv) =            ReinforcementLearningBase.reward(env::CollisionAvoidanceEnv)
is_terminated(env::CollisionAvoidanceEnv) =     ReinforcementLearningBase.is_terminated(env::CollisionAvoidanceEnv)
reset!(env::CollisionAvoidanceEnv) =            ReinforcementLearningBase.reset!(env::CollisionAvoidanceEnv) 

