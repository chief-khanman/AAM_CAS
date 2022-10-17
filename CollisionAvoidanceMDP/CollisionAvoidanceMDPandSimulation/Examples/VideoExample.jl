include("../CollisionAvoidanceMDPandSimulation.jl")

env =  CollisionAvoidanceEnv_constructor(   is_MDP=false,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), false, 50.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=200.0, # in seconds 
                                timestep=1.0,)

# Note this function is equilvalent of calling step! until max time is reached
# it optionally takes an argument callback_function which is called every step
# The callback takes 1 argument, the env. Perhaps use it to print the current time for long sims
Animate!(env, callback_function=PrintTime)

# note you could pull stats here, but you should not render if it is not needed because it is really slow!