
# runs PPO on the environment provided for the given number of seconds.
#  Must be a Continuous state, Continuous action (CC) environment.
function PPO( env, num_seconds)
    println("Running PPO on C.C. Collision Avoidance for ", num_seconds, " seconds...")
    rng = StableRNG(123)


    function get_ex(env) 



        # fetch relevant from env
        as = ReinforcementLearningBase.action_space(env)
        ss = ReinforcementLearningBase.state_space(env)
        ns = length(ss)
        na = length(as)
        init = glorot_uniform(rng)
        println("NS = ", ns, ", NA = ", na)
        
        # generate bounds for action space
        left, middle, right = Vector{Float64}(undef, 0), Vector{Float64}(undef, 0), Vector{Float64}(undef, 0)
        for dim in as
            l = leftendpoint(dim)
            r = rightendpoint(dim)
            push!(left, l)
            push!(right, r)
            push!(middle, (l + r) / 2)
        end
        width = right .- middle

        N_ENV = 8
        UPDATE_FREQ = 2048
        envs = Vector{AbstractEnv}(undef, 0)
        for i in 1:N_ENV
            push!(envs, deepcopy(env))
        end

        env = MultiThreadEnv(envs)

        init = glorot_uniform(rng)

        agent = Agent(
            policy = PPOPolicy(
                approximator = ActorCritic(
                    actor = GaussianNetwork(
                        pre = Chain(
                            Dense(ns, 64, relu; init = glorot_uniform(rng)),
                            Dense(64, 64, relu; init = glorot_uniform(rng)),
                        ),
                        μ = Chain(Dense(64, na, tanh; init = glorot_uniform(rng)), vec),
                        logσ = Chain(Dense(64, na; init = glorot_uniform(rng)), vec),
                    ),
                    critic = Chain(
                        Dense(ns, 64, relu; init = glorot_uniform(rng)),
                        Dense(64, 64, relu; init = glorot_uniform(rng)),
                        Dense(64, 1; init = glorot_uniform(rng)),
                    ),
                    optimizer = ADAM(3e-4),
                ),
                γ = 0.99f0,
                λ = 0.95f0,
                clip_range = 0.2f0,
                max_grad_norm = 0.5f0,
                n_epochs = 10,
                n_microbatches = 32,
                actor_loss_weight = 1.0f0,
                critic_loss_weight = 0.5f0,
                entropy_loss_weight = 0.00f0,
                dist = Normal,
                rng = rng,
                update_freq = UPDATE_FREQ,
            ),
            trajectory = PPOTrajectory(;
                capacity = UPDATE_FREQ,
                state = Matrix{Float32} => (ns, N_ENV),
                action = Vector{Float32} => (N_ENV,),
                action_log_prob = Vector{Float32} => (N_ENV,),
                reward = Vector{Float32} => (N_ENV,),
                terminal = Vector{Bool} => (N_ENV,),
            ),
        )

        stop_condition = StopAfterNSeconds(Float64(num_seconds))
        hook = TotalBatchRewardPerEpisode(N_ENV)
        Experiment(agent, env, stop_condition, hook, "# Play Collision Avoidance with PPO")
    end

    # run the experiment
    ex = get_ex(env)
    run(ex, describe=false)

    # make directory to store results
    directory = "Experiments/PPO"
    directory = getFileName(directory)
    mkpath(directory)
    println("Saving results to ", directory, "...")

    # save the raw reward data
    rewards = ex.hook.rewards
    location = directory * "/rewards.bson"
    @save location rewards

    # save the model. Note we must also create variables state_space and action_space, that list the spaces as either discrete or continuous using Symbols (:Discrete is a symbol)
    actor = ex.policy.policy.approximator.actor 
    function model(x)
        μ, logσ = actor(x) 
        return rand(rng, Normal(μ[1], exp(logσ[1])))
    end
    state_space = :Continuous
    action_space = :Continuous
    location = directory * "/model.bson"
    @save location model state_space action_space

    # save the reward graph
    graphReward(rewards, directory * "/reward_graph.png", "PPO Reward Over Time")
end
