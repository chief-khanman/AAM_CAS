include("../src/Includes.jl")

############## settings ##############
filename = "2.2Squares"

max_sim_time = 1000.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug


stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 10

video_algs = ["PPO"] # note you can leave this blank to not run any videos
spawn_rate_video = 40

# add any shapes to the shape  managers to change where ac can spawn, go, and where RAs are
sm_start = ShapeManager()
square =  Rectangle(Cartesian2(0.0, 7000.0), Cartesian2(4000.0, 3000.0))
addShape!(sm_start, square, 1)

sm_end = ShapeManager()
square2 =  Rectangle(Cartesian2(6000.0, 7000.0), Cartesian2(10000.0, 3000.0))
addShape!(sm_end, square2, 1)
sc = ConstantSpawnrateController(   sources=sm_start,
                                    destinations=sm_end,
                                    spawns_per_km_squared_hours=spawn_rate_video,
                                    relative_destination=false)
sm_restricted = ShapeManager()
######################################
println("\n", filename, " Experiment")

##### Main script #####
createStatsAndVideo(    current_dir=@__DIR__, 
                        stats_algs=stats_algs,
                        video_algs=video_algs,
                        refresh=refresh, 
                        spawn_rates_stats=spawn_rates_stats, 
                        spawn_rate_video=spawn_rate_video, 
                        number_trials=number_trials, 
                        spawn_controller=sc,
                        boundary_sm=sm_restricted,      
                        pathfinder=PathFinder(),                  
                        max_sim_time=max_sim_time, 
                        filename=filename, 
                        )

if length(stats_algs) > 0
    graphStatsAcrossAlgs(filename=filename)
end
