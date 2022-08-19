
# runs a2c on the environment provided for the given number of seconds.
#  Must be a Continuous state, discrete action (CC) environment.
function A2C( env, num_seconds)
    println("Running A2C on C.D. Collision Avoidance for ", num_seconds, " seconds...")
    rng = StableRNG(123)


    function get_ex(env) 
        N_ENV = 16
        UPDATE_FREQ = 10

        # fetch relevant from env
        as = ReinforcementLearningBase.action_space(env)
        ss = ReinforcementLearningBase.state_space(env)
        ns = length(ss)
        na = length(as)
        println("NS = ", ns, ", NA = ", na)

        # generate multi threaded envs
        envs = Vector{AbstractEnv}(undef, 0)
        for i in 1:N_ENV
            push!(envs, deepcopy(env))
        end
        env = MultiThreadEnv(envs)
        RLBase.reset!(env, is_force = true)


        # create learning stuff
        agent = Agent(
            policy = QBasedPolicy(
                learner = A2CLearner(
                    approximator = ActorCritic(
                        actor = Chain(
                            Dense(ns, 256, relu; init = glorot_uniform(rng)),
                            Dense(256, na; init = glorot_uniform(rng)),
                        ),
                        critic = Chain(
                            Dense(ns, 256, relu; init = glorot_uniform(rng)),
                            Dense(256, 1; init = glorot_uniform(rng)),
                        ),
                        optimizer = ADAM(1e-3),
                    ),
                    γ = 0.99f0,
                    actor_loss_weight = 1.0f0,
                    critic_loss_weight = 0.5f0,
                    entropy_loss_weight = 0.001f0,
                    update_freq = UPDATE_FREQ,
                ),
                explorer = BatchExplorer(GumbelSoftmaxExplorer()),
            ),
            trajectory = CircularArraySARTTrajectory(;
                capacity = UPDATE_FREQ,
                state = Matrix{Float32} => (ns, N_ENV),
                action = Vector{Int} => (N_ENV,),
                reward = Vector{Float32} => (N_ENV,),
                terminal = Vector{Bool} => (N_ENV,),
            ),
        )

        stop_condition = StopAfterNSeconds(Float64(num_seconds))
        hook = TotalBatchRewardPerEpisode(N_ENV)
        Experiment(agent, env, stop_condition, hook, "# A2C with Collision Avoidance")
    end


    # run the experiment
    ex = get_ex(env)
    run(ex, describe=false)

    # make directory to store results
    directory = "Experiments/A2C"
    directory = getFileName(directory)
    mkdir(directory)
    println("Saving results to ", directory, "...")

    # save the raw reward data
    rewards = ex.hook.rewards
    location = directory * "/rewards.bson"
    @save location rewards

    # save the model. Note we must also create variables state_space and action_space, that list the spaces as either discrete or continuous using Symbols (:Discrete is a symbol)
    actor = ex.policy.policy.learner.approximator.actor 
    function model(x)
        return  actor(x)
    end
    state_space = :Continuous
    action_space = :Discrete
    location = directory * "/model.bson"
    @save location model state_space action_space

    # save the reward graph
    graphReward(rewards, directory * "/reward_graph.png", "PPO Reward Over Time")

end