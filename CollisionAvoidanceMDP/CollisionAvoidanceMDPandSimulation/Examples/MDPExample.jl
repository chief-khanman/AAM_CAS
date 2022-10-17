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
ss = ReinforcementLearningBase.state_space(env)
as = ReinforcementLearningBase.action_space(env)

for _ in 1:10
    ReinforcementLearningBase.reset!(env)

    done = false
    while !done
        s = ReinforcementLearningBase.state(env)
        r = ReinforcementLearningBase.reward(env)
        done = ReinforcementLearningBase.is_terminated(env)

        # do something with action here
        # first is change in speed, second is change in direction
        action = [0.0, clamp(s[1], -env.airspace.maximum_aircraft_acceleration.θ, env.airspace.maximum_aircraft_acceleration.θ)]
        
        env(action)
        render(env)
    end
    # train here, etc
end


# for some reason, render windows dont close automatically
closeAllWindows()