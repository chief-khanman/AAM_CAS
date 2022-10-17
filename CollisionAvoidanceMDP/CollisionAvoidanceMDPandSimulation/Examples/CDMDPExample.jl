include("../CollisionAvoidanceMDPandSimulation.jl")



env =  CollisionAvoidanceEnv_constructor(   is_MDP=true,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), true, 50.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/30),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=3600.0, # 1 hour
                                timestep=1.0,
                                )
# returns an env with only direction as an action, speed remains constant
transformed_env = getCDEnvironment(env)
ss = ReinforcementLearningBase.state_space(transformed_env)
as = ReinforcementLearningBase.action_space(transformed_env)

println("Discrete action space = ", as)

for _ in 1:10
    ReinforcementLearningBase.reset!(transformed_env)

    done = false
    while !done
        s = ReinforcementLearningBase.state(transformed_env)
        r = ReinforcementLearningBase.reward(transformed_env)
        done = ReinforcementLearningBase.is_terminated(transformed_env)

        # do something with action here
        # since its transformed, this value is only steering
        action = rand(as)
        transformed_env(action)
        # render(env)
    end
    # train here, etc
end


# for some reason, render windows dont close automatically
closeAllWindows()