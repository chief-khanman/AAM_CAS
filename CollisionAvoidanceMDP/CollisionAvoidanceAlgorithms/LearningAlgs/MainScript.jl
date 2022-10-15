include("Includes.jl")

############## settings ##############
algs = [TD3, A2C, PPO, DDPG, DQN, Tabular, Basic, Sophisticated]   # functions to run. Takes env and number seconds as parameters
training_seconds = 30                             # number of seconds each alg runs
######################################



##### Main script #####
env =  CollisionAvoidanceEnv(   is_MDP=true,
                                max_time=1000.0, # 1 hour
                                )

for alg in algs
    if alg == Basic || alg == Sophisticated        # CS, CA, unmodified env. Currently only the hard-coded, non-learning algs
        t_env = deepcopy(env)
        alg(t_env, training_seconds)
    elseif alg == DDPG || alg == TD3 || alg == PPO   # CS, CA algorithms
        t_env = getDirectionOnlyEnvironment(env)
        alg(t_env, training_seconds)
    elseif alg == DQN || alg == A2C                 # CS, DA algorithms
        t_env = getCDEnvironment(env)
        alg(t_env, training_seconds)
    elseif alg == Tabular                           # DS, DA algorithms
        t_env = getDDEnvironment(env)
        alg(t_env, training_seconds)
    end
end
