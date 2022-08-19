function graph(xs, ys, algs, xlabel, ylabel, title, filename)
    plt.clf() # clear graph from previous uses
    for i in 1:length(xs)
        plt.plot(xs[i],ys[i], label=algs[i])
    end
    plt.xlabel(xlabel)
    plt.ylabel(ylabel)
    plt.title(title) 
    plt.legend()
    plt.savefig(filename) # save
end

function averageValues(spawn_rate, nmac_rate, distance)
    @assert length(spawn_rate) == length(nmac_rate) == length(distance)

    # for each value in our data
    dict = Dict()
    for i in 1:length(spawn_rate)
        # fetch values from dict. If they dont exist, start at 0.
        # if they do, add to previous values
        # this is performing a sum accross nmac and distance, where the value is sum of all values at a given spawn_rate
        current_values = get(dict, spawn_rate[i], [0.0, 0.0])
        current_values[1] += nmac_rate[i]
        current_values[2] += distance[i]
        dict[spawn_rate[i]] = current_values
    end

    # calculate how many times we added a number so we can find average
    num_dupliciates = length(spawn_rate) / length(dict)
    
    # sort the dict by the spawn_rate
    list = collect(dict)
    list = sort(list, by=x->x[1])

    # convert back to list of numbers 
    spawn_rate = [k for (k,v) in list]
    nmac_rate = [v[1] for (k,v) in list]
    distance = [v[2] for (k,v) in list]
    
    # conver nmac and distance to averages by dividing (it was a sum)
    nmac_rate ./= num_dupliciates
    distance ./= num_dupliciates

    return spawn_rate, nmac_rate, distance
end

# graphs multiple algortihms performance for one experiment
function graphStatsAcrossAlgs(; filename,)
    rc("text", usetex=false) # disable latex maybe needed. Sometimes its buggy
    
    # main
    stats_file_name = filename * "_stats"
    current_dir = @__DIR__
    dirs = getAllExperiments()
    spawn_rate_data = []
    nmac_data = []
    distance_data = []
    used_algs = []

    # collect data
    for dir in dirs
        # collect data on each alg

        # read stats if they exists, otherwise conitnue
        stats_table = nothing
        try
            stats_table = BSON.load(current_dir * "/../../Experiments/" * dir * "/" * stats_file_name * ".bson")[:stats_table]
        catch e
            println(current_dir * "/../../Experiments/" * dir * "/" * stats_file_name * ".bson not found. Skipping...")
        end
        if stats_table == nothing
            continue
        end

        # parse file into a table
        spawn_rate = []
        nmac_rate = []
        distance = []
        for value in stats_table
            if typeof(value[2]) == String || typeof(value[4]) == String || typeof(value[5]) == String
                continue
            end
            push!(spawn_rate, value[2])
            push!(nmac_rate, value[4])        
            push!(distance, value[5])
        end

        # average values over trial runs
        spawn_rate, nmac_rate, distance = averageValues(spawn_rate, nmac_rate, distance)

        # add data to list for later graphing
        push!(spawn_rate_data, spawn_rate)
        push!(nmac_data, nmac_rate)
        push!(distance_data, distance)
        push!(used_algs, dir)
    end

    graph(spawn_rate_data, nmac_data,       used_algs, "Spawn rate (Spawns/KM2-hr)", "NMACs in Airspace",    "NMACs Per Algorithm",                 current_dir *  "/../../Experiments/" * stats_file_name * "_nmacs.png")
    graph(spawn_rate_data, distance_data,   used_algs, "Spawn rate (Spawns/KM2-hr)", "Normed. Route length", "Normed. Route Length Per Algorithm",  current_dir *  "/../../Experiments/" * stats_file_name * "_routeLength.png")
end

function isInList(name::String, list::Vector{String})

    for item in list
        if occursin(name, item) || occursin(item, name)
            return true
        end
    end
    return false
end


# graphs multiple experiments performance for one policy(alg)
# leave the arg blank to graph the performance on all experiements for 1 policy
# or specify a list of experiments you want to graph, such as "Uniform", etc
function graphStatsAcrossExperiments(experimentsToGraph::Vector{String} = Vector{String}(undef, 0), filename="AllExperiments")
    rc("text", usetex=false) # disable latex maybe needed. Sometimes its buggy
    
    # main
    stats_file_name = filename * "_stats"
    current_dir = @__DIR__
    dirs = getAllExperiments()


    # collect data
    for dir in dirs

        # create empty lists to start reading data in to
        spawn_rate_data = []
        nmac_data = []
        distance_data = []
        experiments = Vector{String}(undef, 0)

        # find all stats files
        path =  current_dir * "/../../Experiments/" * dir
        fulldirpaths = filter(isfile,readdir(path,join=true))
        filenames = basename.(fulldirpaths)

        for file in filenames

            if occursin("_stats", file)
                shorthand_experiment_type = file[1: findfirst("_stats", file)[1]-1 ]

                if length(experimentsToGraph) != 0 && !isInList(shorthand_experiment_type, experimentsToGraph)
                    continue
                end


                # read stats if they exists, otherwise conitnue
                stats_table = nothing
                full_file_name = current_dir * "/../../Experiments/" * dir * "/" * file
                try
                    stats_table = BSON.load(full_file_name)[:stats_table]
                catch e
                    println(full_file_name * " not found. Skipping...")
                end
                if stats_table == nothing
                    continue
                end


                spawn_rate = []
                nmac_rate = []
                distance = []
                for value in stats_table
                    if typeof(value[2]) == String || typeof(value[4]) == String || typeof(value[5]) == String
                        continue
                    end
                    push!(spawn_rate, value[2])
                    push!(nmac_rate, value[4])        
                    push!(distance, value[5])
                end

                # average values over trial runs
                spawn_rate, nmac_rate, distance = averageValues(spawn_rate, nmac_rate, distance)

                # add data to list for later graphing
                push!(spawn_rate_data, spawn_rate)
                push!(nmac_data, nmac_rate)
                push!(distance_data, distance)
                push!(experiments, shorthand_experiment_type)
            
            end
        end
        graph(spawn_rate_data, nmac_data,       experiments, "Spawn rate (Spawns/KM2-hr)", "NMACs in Airspace",    "NMACs Per Experiment",                 current_dir *  "/../../Experiments/" * dir * "/" * filename * "_nmacs.png")
        graph(spawn_rate_data, distance_data,   experiments, "Spawn rate (Spawns/KM2-hr)", "Normed. Route length", "Normed. Route Length Per Experiment",  current_dir *  "/../../Experiments/" * dir * "/" * filename * "_routeLength.png")
            
        
    end
end