
# runs tabular method on the environment provided for the given number of seconds.
#  Must be a Discrete state, Discrete action (DD) environment.
function Tabular( env, num_seconds)
    println("Running Tabular on D.D. Collision Avoidance for ", num_seconds, " seconds...")
    

    function get_ex(env)

        ns, na = length(ReinforcementLearningBase.state(env)), length(ReinforcementLearningBase.action_space(env))

        policy = Agent(
            policy = QBasedPolicy(
                learner = TDLearner(
                    approximator = TabularQApproximator(
                        n_state = length(ReinforcementLearningBase.state_space(env)),
                        n_action = length(ReinforcementLearningBase.action_space(env)),
                    ),
                    γ=1.0,
                    method=:SARS,
                    n=1,
                ),
                explorer = EpsilonGreedyExplorer(
                    kind = :exp,
                    ϵ_stable = 0.01,
                    decay_steps = 500,
                    rng = StableRNG(123),
                ),
            ),
            trajectory = CircularArraySARTTrajectory(
                capacity = 1000,
                state = Vector{Int64} => (ns,),
            ),
        )
        stop_condition = StopAfterNSeconds(Float64(num_seconds))
        hook = TotalRewardPerEpisode()
        return Experiment(policy, env, stop_condition, hook, "# Play CollisionAvoidanceEnv_constructor with Tabular")
    end

    # run the experiment
    ex = get_ex(env)
    run(ex, describe=false)


    # make directory to store results
    directory = "Experiments/Tabular"
    directory = getFileName(directory)
    mkpath(directory)
    println("Saving results to ", directory, "...")

    # save the raw reward data
    rewards = ex.hook.rewards
    location = directory * "/rewards.bson"
    @save location rewards


    # save the model
    model = ex.policy.policy.learner.approximator.table
    state_space = :Discrete
    action_space = :Discrete
    location = directory * "/model.bson"
    @save location model state_space action_space

    # save the reward graph
    graphReward(rewards, directory * "/reward_graph.png", "Tabular Reward Over Time")

end