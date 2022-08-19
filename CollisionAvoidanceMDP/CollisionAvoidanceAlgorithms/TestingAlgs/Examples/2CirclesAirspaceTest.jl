include("../src/Includes.jl")

############## settings ##############
filename = "2Circles"

max_sim_time = 100.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug

stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 1

video_algs = ["PPO"] # note you can leave this blank to not run any videos
spawn_rate_video = 30

# add any shapes to the shape  managers to change where ac can spawn.
sp_start = ShapeManager()
circle_start =  Circle(Cartesian2(2500.0, 5000.0), 2500.0)
addShape!(sp_start, circle_start, 1)

sp_end = ShapeManager()
circle_end =    Circle(Cartesian2(7500.0, 5000.0), 2500.0)
addShape!(sp_end, circle_end, 1)

sc = ConstantSpawnrateController(   sources=sp_start,
                                    destinations=sp_end,
                                    spawns_per_km_squared_hours=spawn_rate_video,
                                    relative_destination=false)


######################################


##### Main script #####
createStatsAndVideo(    current_dir=@__DIR__,                     
                        stats_algs=stats_algs, 
                        video_algs=video_algs,
                        refresh=refresh, 
                        spawn_rates_stats=spawn_rates_stats, 
                        spawn_rate_video=spawn_rate_video, 
                        number_trials=number_trials, 
                        spawn_controller=sc,
                        boundary_sm=ShapeManager(),   
                        pathfinder=PathFinder(),                                          
                        max_sim_time=max_sim_time, 
                        filename=filename, 
                        )


graphStatsAcrossAlgs(filename=filename)

