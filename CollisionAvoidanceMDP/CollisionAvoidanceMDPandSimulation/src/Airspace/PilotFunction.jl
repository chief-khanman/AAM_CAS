# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft, Airspace

# Here is the interface for a custom pilot function
# your function must take 1 argument: The state array
# Additionally, provides a RNG. You must use this to generate randomness (if you choose to), or your results will not be reproducible. 

# your function must return 1 action array
# To see what the state and action array consists of, see the MDP

# The below function is a default pilot behavior. It goes straight to the destination, ignoring intruders.
# Slight noise is added to make the aircraft swerve
function default_pilot_function(max_acceleration::Polar2)
    function some_pilot_function(state, rng)
        max_turn_rate = max_acceleration.θ
        deviation = state[1]
        # deviation += rand(Normal(rng)) * .2 # adds random turning
        turn_direction = clamp(deviation, -max_turn_rate, max_turn_rate)
        action = [0.0, turn_direction]
        return action
    end
    return some_pilot_function
end