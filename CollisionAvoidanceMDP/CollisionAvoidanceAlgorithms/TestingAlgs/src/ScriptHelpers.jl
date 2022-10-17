# creates stats given the env and model information
function create_stats(env, model_directory::String, model_name::String, verbose=false)
    # fetch the model and some details about it
    model, state_space_type, action_space_type = loadModel(model_directory, model_name)

    # create the pilot function
    pilot = getPilotFunctionFromModel(model, state_space_type, action_space_type, env)

    # start sim
    env.pilot_function = pilot
    if verbose
        println("Gathering stats on policy at " * model_directory * "/" * model_name)
    end
    simulate!(env)

    # pull stats
    route_length = average_normalized_route_length(env.airspace.stats)
    nmac_hour = average_num_nmac_per_second_for_airspace(env.airspace.stats, env.timestep) * 3600
    return nmac_hour, route_length
end

# creates a video given the env and model information
function create_video(env, model_directory::String, model_name::String, video_name::String, verbose=false)
    # fetch the model and some details about it
    model, state_space_type, action_space_type = loadModel(model_directory, model_name)

    # create the pilot function
    pilot = getPilotFunctionFromModel(model, state_space_type, action_space_type, env)

    # start sim
    env.pilot_function = pilot
    Animate!(env, callback_function=PrintTime, filename=model_directory * "/" *  video_name * ".mp4")
end

# used by any stats scripts
function createStatsForAlg(; refresh, dir, spawn_rate_stats, number_trials, boundary_sm, spawn_controller,  waypoints, max_sim_time, current_dir, file_name)
    if isfile(current_dir * "/../../Experiments/" * dir * "/" * file_name * ".bson") && !refresh
        println("Stats already exist for ", dir, ", continuing...")
    else
        println("\tTesting ", dir)
        stats_table = []
        push!(stats_table, ("Algorithm", "Spawn rate", "Trial", "NMAC per hour", "Normed. route length"))

        # For all spawnrates, we want to run tests
        for spawn_rate in spawn_rate_stats
            for i in 1:number_trials
                println("Testing ", dir, " at spawnrate ", spawn_rate,", trial ", i)
                setSpawnRate(spawn_controller, spawn_rate)

                # create env for testing
                env =  CollisionAvoidanceEnv_constructor(   is_MDP=false,
                    spawn_controller=spawn_controller,
                    max_time=max_sim_time,
                    rng=MersenneTwister(i),
                    restricted_areas=boundary_sm,
                    waypoints=waypoints,
                    )
                # run stats
                nmac_hour, route_length = create_stats(env, current_dir * "/../../Experiments/" * dir, "model.bson")

                # save stats to table
                push!(stats_table, (dir, spawn_rate, i, nmac_hour, route_length))

            end
        end
        # save the table with all data
        @save current_dir * "/../../Experiments/" * dir * "/" * file_name * ".bson" stats_table
    end
end


function createVideoForAlg(;current_dir, dir, refresh, spawn_controller, boundary_sm,  waypoints, spawn_rate_video, max_sim_time, file_name )
    # verify stats have not been run. Its seeded, so results will be the same. No point in wasting time. 
    if isfile(current_dir * "/../../Experiments/" * dir * "/" * file_name * ".mp4") && !refresh
        println("Video already exists for ", dir, ", continuing...")
    else
        println("Recording ", dir)
        setSpawnRate(spawn_controller, spawn_rate_video)
        # create env for testing
        local env =  CollisionAvoidanceEnv_constructor(   is_MDP=false,
                    spawn_controller=spawn_controller,
                    max_time=max_sim_time,
                    restricted_areas=boundary_sm,
                    waypoints=waypoints,               
                    )
        # run video
        create_video(env, current_dir * "/../../Experiments/" * dir, "model.bson", file_name)
    end
end

function createStatsAndVideo(; current_dir, stats_algs, video_algs, refresh, spawn_rates_stats, spawn_rate_video, number_trials, spawn_controller, boundary_sm, pathfinder, max_sim_time, filename, )
    # get all experiment directories. Check if the given experiment used an algorithm we want to test
    dirs = getAllExperiments() 

    # if running stats
    if length(stats_algs) > 0
        for dir in dirs
            for alg in stats_algs
                # if the alg name is in the dir name, then it used that alg
                if occursin(alg, dir)
                    createStatsForAlg(              refresh=refresh,
                                                    dir=dir, 
                                                    spawn_rate_stats=spawn_rates_stats, 
                                                    number_trials=number_trials, 
                                                    spawn_controller=spawn_controller,
                                                    boundary_sm=boundary_sm, 
                                                    waypoints=pathfinder,
                                                    max_sim_time=max_sim_time, 
                                                    current_dir=current_dir, 
                                                    file_name=filename* "_stats"
                                                    )
                end
            end
        end
    end


    # if running video
    if length(video_algs) > 0
        for dir in dirs
            for alg in video_algs
                # if the alg name is in the dir name, then it used that alg
                if occursin(alg, dir)
                    createVideoForAlg(;     current_dir=current_dir, 
                                            dir=dir, 
                                            refresh=refresh, 
                                            spawn_controller=spawn_controller,
                                            boundary_sm=boundary_sm,            
                                            waypoints=pathfinder,                                 
                                            spawn_rate_video=spawn_rate_video, 
                                            max_sim_time=max_sim_time,
                                            file_name=filename* "_video" 
                                            )
                end
            end
        end
    end
end
