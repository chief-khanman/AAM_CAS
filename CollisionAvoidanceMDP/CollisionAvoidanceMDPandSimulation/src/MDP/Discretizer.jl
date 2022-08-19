# dependencies: none

# discretizes the space. Returns 2 functions. The first takes a continious state space and returns the single index state space.
# the second function Returns the total number of states as a 1:NumberStates Object
function getDiscreteFunctions(state_space, numberBins::Vector{Int})
    
    function getState(s)
        
        # Find the index for each dimension (as an int)
        dimensionIndicies = Vector{Int}(undef, 0)
        for i in 1:length(state_space) 
            width = (state_space[i].right - state_space[i].left) / numberBins[i]
            dim =  floor(Int, (s[i] - state_space[i].left) / width) + 1
            push!(dimensionIndicies, dim) 
        end

        # Convert to single index. Value = the sum (thisDimensionIndex * (product of all previous dimension widths))
        index = 1
        for i in 1:length(state_space) 
            offset = 1
            j = i-1
            while j > 0
                offset *= numberBins[j]
                j -= 1
            end
            index += (dimensionIndicies[i] - 1) * offset
        end
        return index
    end

    numberStates = 1
    for value in numberBins
        numberStates = numberStates *  value
    end
    
    return getState, Base.OneTo(numberStates)
end
