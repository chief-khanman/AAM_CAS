include("../src/Includes.jl")

############## settings ##############
filename = "Waypoints2"

max_sim_time = 1000.0
refresh = false  # whether to recreate stats and videos or not. Usually not needed, but if you change settings it is good for debug

stats_algs = ["TD3", "PPO", "A2C", "DDPG", "DQN", "Tabular", "Basic", "Sophisticated"]
spawn_rates_stats = [5, 10, 20, 40, 60] # in 1ac per km^2-hours
number_trials = 1

video_algs = ["PPO"] # note you can leave this blank to not run any videos
spawn_rate_video = 30

# now we need waypoints to guide ac around the problem
points =  Vector{Cartesian2}(undef, 0)
edges = Vector{Edge{Int64}}(undef, 0)
num_points_in_circle = 20

# these functions generate points in a certain shape
# note start_index is needed because the second circle will be the second set of points in this case, so its index starts at some value > 1 (20 in this case)
inside_points, inside_edges =  getCircleOfPoints(Cartesian2(5000.0, 5000.0), 2000.0, num_points_in_circle; connected_clockwise=true, connected_counter_clockwise=false)
outside_points, outside_edges =  getCircleOfPoints(Cartesian2(5000.0, 5000.0), 4000.0, num_points_in_circle; connected_clockwise=false, connected_counter_clockwise=true, start_index=20)

# add all of our points,edges to the lists
points = cat(points, inside_points, dims=1)
points = cat(points, outside_points, dims=1)

edges = cat(edges, inside_edges, dims=1)
edges = cat(edges, outside_edges, dims=1)

# also want to interconnect the circles
for i in 1:num_points_in_circle
    push!(edges, Edge(i, i + num_points_in_circle))
    push!(edges, Edge(i + num_points_in_circle, i))
end


pf = PathFinder(  points, edges)
sc =  ConstantSpawnrateController(Cartesian2(10000.0, 10000.0), false, spawns_per_kilometer_squared_hours=spawn_rate_video)

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
                        pathfinder=pf,                        
                        max_sim_time=max_sim_time, 
                        filename=filename, 
                        )

if length(stats_algs) > 0
    graphStatsAcrossAlgs(filename=filename)
end
