# Note this code just needs to not crash

# test 1, MDP
env =  CollisionAvoidanceEnv(   is_MDP=true,
                                boundary=Cartesian2(10000, 10000), 
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=3600.0, # 1 hour
                                timestep=1.0,
                                )
ss = state_space(env)
as = action_space(env)

for _ in 1:10
    ReinforcementLearningBase.reset!(env)
    done = false
    while !done
        s = state(env)
        local r = reward(env)
        done = is_terminated(env)
        action = rand(as)
        env(action)
    end
end

# test 2, simulation
env =  CollisionAvoidanceEnv(   is_MDP=false,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), false, 1.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=1000.0, # 1 hour
                                timestep=1.0,
                                )
for _ in 1:10
    ReinforcementLearningBase.reset!(env)
    done = false
    while !done
        done = is_terminated(env)
        step!(env)
    end
end

# test 3, spawn function works
env =  CollisionAvoidanceEnv(   is_MDP=true,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), true, 5000.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=50.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=3600.0, # 1 hour
                                timestep=3.0,
                                )
####
ReinforcementLearningBase.reset!(env)
step!(env)
ego = env.airspace.all_aircraft[1]
for i  in 2:length(env.airspace.all_aircraft)
    @assert Magnitude(ego.dynamic.position - env.airspace.all_aircraft[i].dynamic.position) <=  env.airspace.detection_radius
end

# test 4, verify random number generator consistency
env =  CollisionAvoidanceEnv(   is_MDP=false,
                                boundary=Cartesian2(10000, 10000), 
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), true, 5000.0),
                                maximum_aircraft_acceleration=Polar2(3.0, 2pi/10),
                                maximum_aircraft_speed=20.0, 
                                detection_radius=1000.0, 
                                pilot_function=nothing,
                                max_time=3600.0, # 1 hour
                                timestep=3.0,
                                rng=MersenneTwister(2)
                                )
ReinforcementLearningBase.reset!(env)
step!(env)
step!(env)
step!(env)
step!(env)
# this number is written by checking the first aircrafts position after 4 steps for the above seed. It should always be the same
# println(env.airspace.all_aircraft[1].dynamic.position.x)
@assert abs(env.airspace.all_aircraft[1].dynamic.position.x - 57.59140376696982) < .1





println("Passed MDPTest")