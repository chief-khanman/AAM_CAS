
# basic non - learning algorithm
# Still store it as a model so its consistent with the NNs and table
#  Must be a Continuous state, Continuous action (CC) environment.
function Basic( env, num_seconds)
    # create a model
    max_turn_rate = env.airspace.maximum_aircraft_acceleration.θ
    function basic_pilot(state)
        deviation = state[1]
        # deviation += rand(Normal(rng)) * .2 # adds random turning
        turn_direction = clamp(deviation, -max_turn_rate, max_turn_rate)
        action = [0.0, turn_direction]
        return action
    end

    # make directory to store algorithm - just for consistency
    directory = "Experiments/Basic"
    directory = getFileName(directory)
    mkpath(directory)

    # save the model. Note we must also create variables state_space and action_space, that list the spaces as either discrete or continuous using Symbols (:Discrete is a symbol)
    model = basic_pilot
    state_space = :Continuous
    action_space = :Continuous
    location = directory * "/model.bson"
    @save location model state_space action_space

end



# basic non - learning algorithm
# Still store it as a model so its consistent with the NNs and table
#  Must be a Continuous state, Continuous action (CC) environment.
function Sophisticated( env, num_seconds)
    # create a model
    max_turn_rate = env.airspace.maximum_aircraft_acceleration.θ
    nmac_distance = env.nmac_distance
    detection_radius = env.airspace.detection_radius
    function sophisticated_pilot(state)
        # direction to go if no intruder
        deviation = state[1]
        ideal_turn_direction = deviation
        
        # direction to go to only evade intruder
        angle_intruder = state[5]
        angle_avoid = state[5] > 0 ? angle_intruder - pi : angle_intruder + pi
        avoidance_turn_direction = angle_avoid
        
        # relative importance based on distance to intruder
        # if there is no intruder, importance is 0
        # if there is, we evade more the closer it gets. At NMAC distance or closer, we only evade. Outside, its exponential decay
        normed_nmac_distance = nmac_distance / detection_radius
        importance_evasion = state[3] == 0.0 ?  0.0 : min(1, exp( (normed_nmac_distance - state[4]) * 10.0))

        # doing a weighted average
        turn_direction =  (1 - importance_evasion) * ideal_turn_direction + importance_evasion * avoidance_turn_direction
        turn_direction = clamp(turn_direction, -max_turn_rate, max_turn_rate)
        action = [0.0, turn_direction]
        return action
    end

    # make directory to store algorithm - just for consistency
    directory = "Experiments/Sophisticated"
    directory = getFileName(directory)
    mkdir(directory)

    # save the model. Note we must also create variables state_space and action_space, that list the spaces as either discrete or continuous using Symbols (:Discrete is a symbol)
    model = sophisticated_pilot
    state_space = :Continuous
    action_space = :Continuous
    location = directory * "/model.bson"
    @save location model state_space action_space

end