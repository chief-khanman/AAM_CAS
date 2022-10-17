# runs the interface test provided by RLBase
# test 1, normal env
env =  CollisionAvoidanceEnv_constructor(   is_MDP=true,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), true, 50.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=3600.0, # 1 hour
                                timestep=1.0,
                                )
ReinforcementLearningBase.test_interfaces!(env)

# test 2, discrete discrete env
t_env = getDDEnvironment(env)
ReinforcementLearningBase.test_interfaces!(t_env)

# test 3, cont. discrete env
t_env = getCDEnvironment(env)
ReinforcementLearningBase.test_interfaces!(t_env)

# test 4, cont. discrete env
t_env = getDirectionOnlyEnvironment(env)
ReinforcementLearningBase.test_interfaces!(t_env)

println("Passed InterfaceTest")