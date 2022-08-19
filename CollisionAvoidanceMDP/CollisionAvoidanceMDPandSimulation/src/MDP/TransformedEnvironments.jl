# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft, SpawnFunction, PilotFunction, Airspace, MDP


# this function returns an environment that does not allow linear acceleration, only a change in direction
# it is a simpler problem to solve
function getDirectionOnlyEnvironment(env::CollisionAvoidanceEnv)
    @assert env.is_MDP
    max_acceleration = env.airspace.maximum_aircraft_acceleration
    max_change_direction = max_acceleration.θ
    
    directionEnv = ActionTransformedEnv(
        env;
        action_mapping = s -> [0.0, s[1]],
        action_space_mapping = _ ->    Space( ClosedInterval{Number}[(-max_change_direction)..(max_change_direction),]) 
    )
    return directionEnv
end

# this function returns an environment that has a discrete action space with 5 actions: hard left, middle left, straight, middle right, hard right
# and only allows turning, not linear acceleration
function getCDEnvironment(env::CollisionAvoidanceEnv)
    @assert env.is_MDP
    max_acceleration = env.airspace.maximum_aircraft_acceleration
    max_change_direction = max_acceleration.θ
    actions = [-max_change_direction, -max_change_direction/2, 0.0, max_change_direction/2, max_change_direction]

    cdEnv = ActionTransformedEnv(
        env;
        action_mapping = index -> [0.0, actions[index]],
        action_space_mapping = _ ->  Base.OneTo(5)
    )
    return cdEnv
end


# this function returns an environment that has a discrete action space with 5 actions: hard left, middle left, straight, middle right, hard right (no linear acceleration)
# it also has a discrete state space
function getDDEnvironment(env::CollisionAvoidanceEnv)
    @assert env.is_MDP

    env = getCDEnvironment(env)
    # this function generates the 2 functions we needs. The first arg is the state space of our env, the second is a list of number of bins for each dimension
    state_mapping, state_space_mapping = getDiscreteFunctions(ReinforcementLearningBase.state_space(env), [10, 2, 2, 10, 10, 10, 10])
    ddEnv = StateTransformedEnv(
            env;
            state_mapping=s -> state_mapping(s),
            state_space_mapping = _ -> state_space_mapping
        )
    
    return ddEnv
end