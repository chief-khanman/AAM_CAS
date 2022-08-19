include("../src/Includes.jl")

############## settings ##############
filename = "5.Queues"

max_sim_time = 1000.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug


stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 10

video_algs = ["PPO"]  # note you can leave this blank to not run any videos
spawn_rate_video = 4000

# note to make queueing work, the internal distribution needs to be a TINY area. In this case, I limited it to 10 radius internally to mimic a heliport. 
# add any shapes to the shape  managers to change where ac can spawn, go, and where RAs are
sm_start = ShapeManager()
sm_end = ShapeManager()

addShape!(sm_start, Rectangle( Cartesian2(0.0, 7000.0), Cartesian2(2000.0, 5000.0), Uniform(990.0, 1010.0), Uniform(5990.0, 6010.0)), 1)
addShape!(sm_start, Rectangle( Cartesian2(0.0, 5000.0), Cartesian2(2000.0, 3000.0), Uniform(990.0, 1010.0), Uniform(3990.0, 4010.0)), 1)
addShape!(sm_start, Rectangle( Cartesian2(2000.0, 7000.0), Cartesian2(4000.0, 5000.0), Uniform(2990.0, 3010.0), Uniform(5990.0, 6010.0)), 1)
addShape!(sm_start, Rectangle( Cartesian2(2000.0, 5000.0), Cartesian2(4000.0, 3000.0), Uniform(2990.0, 3010.0), Uniform(3990.0, 4010.0)), 1)


addShape!(sm_end, Rectangle( Cartesian2(0.0+6000.0, 7000.0), Cartesian2(2000.0+6000.0, 5000.0), Uniform(990.0+6000.0, 1010.0+6000.0), Uniform(5990.0, 6010.0)), 1)
addShape!(sm_end, Rectangle( Cartesian2(0.0+6000.0, 5000.0), Cartesian2(2000.0+6000.0, 3000.0), Uniform(990.0+6000.0, 1010.0+6000.0), Uniform(3990.0, 4010.0)), 1)
addShape!(sm_end, Rectangle( Cartesian2(2000.0+6000.0, 7000.0), Cartesian2(4000.0+6000.0, 5000.0), Uniform(2990.0+6000.0, 3010.0+6000.0), Uniform(5990.0, 6010.0)), 1)
addShape!(sm_end, Rectangle( Cartesian2(2000.0+6000.0, 5000.0), Cartesian2(4000.0+6000.0, 3000.0), Uniform(2990.0+6000.0, 3010.0+6000.0), Uniform(3990.0, 4010.0)), 1)


sc = QueuedSpawnController(         sources=sm_start,
                                    destinations=sm_end,
                                    spawns_per_km_squared_hours=spawn_rate_video,
                                    relative_destination=false)


######################################

println("\n", filename, " Experiment")


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
if length(stats_algs) > 0
    graphStatsAcrossAlgs(filename=filename)
end