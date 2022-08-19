rng = MersenneTwister(1)

# test 1
pilot = default_pilot_function(Polar2(5.0, pi))

# test 2
state1 = [2, 5.0,0,0,0,0,0]
@assert pilot(state1, rng)[2] > 0.0
@assert pilot(state1, rng)[1] == 0.0

# test 3
state1 = [-2,5.0,0,0,0,0,0]
@assert pilot(state1, rng)[2] < 0.0
@assert pilot(state1, rng)[1] == 0.0

println("Passed PilotFunctionTest")