# loads a given model from a bson. Must be able to do model(state) to get the action
function loadModel(model_directory::String, model_name::String)
    dict = BSON.load(model_directory * "/" * model_name) 
    return dict[:model], dict[:state_space], dict[:action_space]
end

# convert a state into discrete based on the default state space conversion. See discretizer.jl in the MDP code.
function GetStateToDiscreteFunction(env)
    state_function, state_space =  getDiscreteFunctions(ReinforcementLearningBase.state_space(env), [10, 2, 2, 10, 10, 10, 10]) # these numbers come from TransformedEnvinronments.jl
    
    function StateToDiscrete(state)
        return state_function(state)
    end
    return StateToDiscrete
end

# convert an action to continuous based on default values
function GetActionToContinuousFunction(env)
    max_acceleration = env.airspace.maximum_aircraft_acceleration.θ
    actions = [-max_acceleration, -max_acceleration/2, 0.0, max_acceleration/2, max_acceleration]    
    function ActionToContinuous(discrete_action)
        return actions[argmax(discrete_action)]
    end
    return ActionToContinuous
end


function getPilotFunctionFromModel(model, state_space_type, action_space_type, env)
    stateToDiscrete = GetStateToDiscreteFunction(env)
    actionToContinuous = GetActionToContinuousFunction(env)
    function pilot(state, rng)
        # if model was trained on discrete state, convert state to discrete and fetch value at index
        if state_space_type == :Discrete
            state = stateToDiscrete(state)
            action = model[ :, state]
        else
            # pass state through model
            action = Base.invokelatest(model, state)
        end

        # if model was trained on discrete action, convert action from discrete to cont
        if action_space_type == :Discrete
            action = actionToContinuous(action)
        end

        # make sure action is the right size. It may be turn only, in which case linear accelleration = 0
        if length(action) == 1
            return [0.0, action[1]] # action must be a acceleration and direction, even if you trained using a modified env
        elseif length(action) == 2
            return action
        else
            error("Action must have either 1 or 2 values. 1 for direction only case, or 2 for the default case. Action has "* string(action) * " values")
        end
    end
   
    return pilot
end



# fetches all experiment directories as strings
function getAllExperiments()
    current_dir = @__DIR__
    path = current_dir * "/../../Experiments"
    fulldirpaths=filter(isdir,readdir(path,join=true))
    dirnames=basename.(fulldirpaths)
    return dirnames
end




# creates the directory for experiment results if it doesnt exists
# note this isnt a method, this just runs when this code is included, which should be always before an experiment is run
current_dir = @__DIR__
dir_to_make = current_dir * "/../../Experiments"
if !isdir(dir_to_make)
    mkdir(dir_to_make)
end