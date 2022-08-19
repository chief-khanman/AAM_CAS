include("../src/Includes.jl")

############## settings ##############
filename = "4Circles"

max_sim_time = 1000.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug

stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 1

video_algs = ["PPO"] # note you can leave this blank to not run any videos
spawn_rate_video = 30

# add any shapes to the shape  managers to change where ac can spawn, go, and where RAs are
sm_start = ShapeManager()
circle_top_left =  Circle(Cartesian2(2000.0, 8000.0), 2000.0)
circle_top_right =  Circle(Cartesian2(8000.0, 8000.0), 2000.0)
addShape!(sm_start, circle_top_left, 1)
addShape!(sm_start, circle_top_right, 1)

sm_end = ShapeManager()
circle_bottom_right =    Circle(Cartesian2(8000.0, 2000.0), 2000.0)
circle_bottom_left =    Circle(Cartesian2(2000.0, 2000.0), 2000.0)
addShape!(sm_end, circle_bottom_right, 1)
addShape!(sm_end, circle_bottom_left, 1)

sm_restricted = ShapeManager()
circle_middle =    Circle(Cartesian2(5000.0, 5000.0), 1000.0)
addShape!(sm_restricted, circle_middle, 1)

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
                        boundary_sm=sm_restricted,      
                        pathfinder=PathFinder(),                  
                        max_sim_time=max_sim_time, 
                        filename=filename, 
                        )

if length(stats_algs) > 0
    graphStatsAcrossAlgs(filename=filename)
end
