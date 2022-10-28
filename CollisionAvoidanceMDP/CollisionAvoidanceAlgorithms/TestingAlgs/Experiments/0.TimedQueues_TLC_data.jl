include("../src/Includes.jl")

############## settings ##############
filename = "0.TimedQueues_TLC_data" # need to change name from 7. to 0. 

max_sim_time = 1000.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug


stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 10

video_algs = ["PPO"]  # note you can leave this blank to not run any videos
spawn_rate_video = 40

# note to make queueing work, the internal distribution needs to be a TINY area. In this case, I limited it to 10 radius internally to mimic a heliport. 
# add any shapes to the shape  managers to change where ac can spawn, go, and where RAs are
sm_start = ShapeManager()
sm_end = ShapeManager()

s1 =  Rectangle( Cartesian2(0.0, 7000.0), Cartesian2(2000.0, 5000.0), Uniform(990.0, 1010.0), Uniform(5990.0, 6010.0))
s2 =  Rectangle( Cartesian2(0.0, 5000.0), Cartesian2(2000.0, 3000.0), Uniform(990.0, 1010.0), Uniform(3990.0, 4010.0))
s3 =  Rectangle( Cartesian2(2000.0, 7000.0), Cartesian2(4000.0, 5000.0), Uniform(2990.0, 3010.0), Uniform(5990.0, 6010.0))
s4 =  Rectangle( Cartesian2(2000.0, 5000.0), Cartesian2(4000.0, 3000.0), Uniform(2990.0, 3010.0), Uniform(3990.0, 4010.0))

s5 =  Rectangle( Cartesian2(0.0+6000.0, 7000.0), Cartesian2(2000.0+6000.0, 5000.0), Uniform(990.0+6000.0, 1010.0+6000.0), Uniform(5990.0, 6010.0))
s6 =  Rectangle( Cartesian2(0.0+6000.0, 5000.0), Cartesian2(2000.0+6000.0, 3000.0), Uniform(990.0+6000.0, 1010.0+6000.0), Uniform(3990.0, 4010.0))
s7 =  Rectangle( Cartesian2(2000.0+6000.0, 7000.0), Cartesian2(4000.0+6000.0, 5000.0), Uniform(2990.0+6000.0, 3010.0+6000.0), Uniform(5990.0, 6010.0))
s8 =  Rectangle( Cartesian2(2000.0+6000.0, 5000.0), Cartesian2(4000.0+6000.0, 3000.0), Uniform(2990.0+6000.0, 3010.0+6000.0), Uniform(3990.0, 4010.0))

addShape!(sm_start, s1)
addShape!(sm_start, s2)
addShape!(sm_start, s3)
addShape!(sm_start, s4)
addShape!(sm_start, s5)
addShape!(sm_start, s6)
addShape!(sm_start, s7)
addShape!(sm_start, s8)

addShape!(sm_end, s1)
addShape!(sm_end, s2)
addShape!(sm_end, s3)
addShape!(sm_end, s4)
addShape!(sm_end, s5)
addShape!(sm_end, s6)
addShape!(sm_end, s7)
addShape!(sm_end, s8)

src_funcs = [   getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
    ]
dest_funcs = [  getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, max_sim_time),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
                getSinusoidal(2*max_sim_time, 1.0, 0.0, 0),
]



sc = QueuedAndTimedSpawnController( sources=sm_start,
                                    destinations=sm_end,
                                    source_priority_functions=src_funcs,
                                    destination_priority_functions=dest_funcs,
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