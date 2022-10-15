
# need a method to find a file name that has not been used. try adding a number, see if file exists. optionally takes an extension, if blank is not used
function getFileName(name::String, extension::String="")
    index = 0
    # look for unused name
    current_name = name
    current_dir = @__DIR__
    while true
        # append an index
        current_name = current_dir *"/../" * name * "_" * string(index) * extension 
        # if name is used, try next index. If not used, break
        if !ispath(current_name) 
            break
        end
        index += 1
    end

    return current_name
end


# need to be able to graph reward over time and save as a .png or .jpg
function graphReward(rewards::Vector{Float64}, save_location::String, title::String)
    plt.clf() # clear graph from previous uses
    plt.plot(rewards) # create graph
    plt.xlabel("Episode")
    plt.ylabel("Reward")
    plt.title(title)
    plt.savefig(save_location) # save
end

# need to be able to graph reward over time and save as a .png or .jpg
function graphReward(rewards::Vector{Vector{Float64}}, save_location::String, title::String)
    plt.clf() # clear graph from previous uses
    for r in rewards
        plt.plot(r) # create graph
    end
    plt.xlabel("Episode")
    plt.ylabel("Reward")
    plt.title(title)
    plt.savefig(save_location) # save
end


# creates the directory for experiment results if it doesnt exists
# note this isnt a method, this just runs when this code is included, which should be always before an experiment is run
current_dir = @__DIR__
dir_to_make = current_dir * "/../Experiments"
if !isdir(dir_to_make)
    mkdir(dir_to_make)
end
