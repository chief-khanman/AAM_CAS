include("../CollisionAvoidanceMDPandSimulation.jl")

env =  CollisionAvoidanceEnv(   is_MDP=false,
                                spawn_controller=ConstantSpawnrateController(Cartesian2(10000, 10000), false, 50.0),
                                max_time=1000.0, # in seconds
                                maximum_aircraft_speed=20.0, 
                                timestep=1.0,)


reset!(env)
done = false
while !done
    global done = is_terminated(env)
    step!(env)
    render(env) # note rendering is very slow
end

# check statistics, etc
println("Normed route len             = ",  average_normalized_route_length(env.airspace.stats))
println("NMAC per hour for arrived ac = ",  average_num_nmac_per_second_for_arrived_ac(env.airspace.stats) * 3600) # for arrived ac only!
println("NMAC per hour for airspace   = ",  average_num_nmac_per_second_for_airspace(env.airspace.stats, env.timestep) * 3600) # for arrived ac only!
plot(env.airspace.stats.number_NMAC) # only visible if you run this on a virtual desktop 

# for some reason, render windows dont close automatically
# closeAllWindows()