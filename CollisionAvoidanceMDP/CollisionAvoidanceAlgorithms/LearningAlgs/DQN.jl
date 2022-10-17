
# runs DQN on the environment provided for the given number of seconds.
#  Must be a Continuous state, Discrete action (CD) environment.
function DQN( env, num_seconds)
    println("Running DQN on C.D. Collision Avoidance for ", num_seconds, " seconds...")
    

    function get_ex(env)
        rng = StableRNG(123)
        ns, na = length(ReinforcementLearningBase.state(env)), length(ReinforcementLearningBase.action_space(env))
        agent = Agent(
            policy = QBasedPolicy(
                learner = BasicDQNLearner(
                    approximator = NeuralNetworkApproximator(
                        model = Chain(
                            Dense(ns, 64, relu; init = glorot_uniform(rng)),
                            Dense(64, 64, relu; init = glorot_uniform(rng)),
                            Dense(64, na; init = glorot_uniform(rng)),
                        ),
                        optimizer = ADAM(),
                    ),
                    batch_size = 32,
                    min_replay_history = 100,
                    loss_func = huber_loss,
                    rng = rng,
                ),
                explorer = EpsilonGreedyExplorer(
                    kind = :exp,
                    ϵ_stable = 0.01,
                    decay_steps = 500,
                    rng = rng,
                ),
            ),
            trajectory = CircularArraySARTTrajectory(
                capacity = 50_000,
                state = Vector{Float32} => (ns,),
            ),
        )

        stop_condition = StopAfterNSeconds(Float64(num_seconds))
        hook = TotalRewardPerEpisode()

        return Experiment(agent, env, stop_condition, hook, "# Play CollisionAvoidanceEnv_constructor with DQN")
    end
    # run the experiment
    ex = get_ex(env)
    run(ex, describe=false)

    # make directory to store results
    directory = "Experiments/DQN"
    directory = getFileName(directory)
    mkpath(directory)
    println("Saving results to ", directory, "...")

    # save the raw reward data
    rewards = ex.hook.rewards
    location = directory * "/rewards.bson"
    @save location rewards

    # save the model
    model = ex.policy.policy.learner.approximator.model 
    state_space = :Continuous
    action_space = :Discrete
    location = directory * "/model.bson"
    @save location model state_space action_space

    # save the reward graph
    graphReward(rewards, directory * "/reward_graph.png", "DQN Reward Over Time")
end
