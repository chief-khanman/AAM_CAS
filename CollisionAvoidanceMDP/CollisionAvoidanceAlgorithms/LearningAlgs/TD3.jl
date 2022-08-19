# runs td3 on the environment provided for the given number of seconds.
#  Must be a Continuous state, Continuous action (CC) environment.
function TD3( env, num_seconds)
    
    # error("Bug found in RL Zoo code. This code works with CircularArrayBuffers v0.1.7, but not more recent versions.")
    println("Running TD3 on C.C. Collision Avoidance for ", num_seconds, " seconds...")

    function get_ex(env)
        rng = StableRNG(123)

        # fetch relevant from env
        as = ReinforcementLearningBase.action_space(env)
        ss = ReinforcementLearningBase.state_space(env)
        ns = length(ss)
        na = length(as)
        println("NS = ", ns, ", NA = ", na)
        init = glorot_uniform(rng)

        
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

        create_actor() = Chain(
            Dense(ns, 30, relu; init = init),
            Dense(30, 30, relu; init = init),
            Dense(30, na, tanh; init = init),
        ) 

        create_critic_model() = Chain(
            Dense(ns + na, 30, relu; init = init),
            Dense(30, 30, relu; init = init),
            Dense(30, 1; init = init),
        ) 

        create_critic() = TD3Critic(create_critic_model(), create_critic_model())

        agent = Agent(
            policy = TD3Policy(
                behavior_actor = NeuralNetworkApproximator(
                    model = create_actor(),
                    optimizer = ADAM(),
                ),
                behavior_critic = NeuralNetworkApproximator(
                    model = create_critic(),
                    optimizer = ADAM(),
                ),
                target_actor = NeuralNetworkApproximator(
                    model = create_actor(),
                    optimizer = ADAM(),
                ),
                target_critic = NeuralNetworkApproximator(
                    model = create_critic(),
                    optimizer = ADAM(),
                ),
                γ = 0.99f0,
                ρ = 0.99f0,
                batch_size = 64,
                start_steps = 1000,
                start_policy = RandomPolicy(as[1]; rng = rng),
                update_after = 1000,
                update_freq = 1,
                policy_freq = 2,
                target_act_limit = maximum(width),
                target_act_noise = maximum(width) / 10,
                act_limit = maximum(width),
                act_noise = maximum(width) / 10,
                rng = rng,
            ),
            trajectory = CircularArraySARTTrajectory(
                capacity = 10_000,
                state = Vector{Float64} => (ns,),
                action = Vector{Float64} => (na, ),
            ),
        )

        stop_condition = StopAfterNSeconds(Float64(num_seconds))
        hook = TotalRewardPerEpisode()
        Experiment(agent, env, stop_condition, hook, "# Play CollisionAvoidanceEnv with TD3")
    end


    # run the experiment
    ex = get_ex(env)
    run(ex, describe=false)

    # make directory to store results
    directory = "Experiments/TD3"
    directory = getFileName(directory)
    mkdir(directory)
    println("Saving results to ", directory, "...")

    # save the raw reward data
    rewards = ex.hook.rewards
    location = directory * "/rewards.bson"
    @save location rewards
    
    # save the model. Note we must also create variables state_space and action_space, that list the spaces as either discrete or continuous using Symbols (:Discrete is a symbol)
    model = ex.policy.policy.behavior_actor.model 
    state_space = :Continuous
    action_space = :Continuous
    location = directory * "/model.bson"
    @save location model state_space action_space

    # save the reward graph
    graphReward(rewards, directory * "/reward_graph.png", "TD3 Reward Over Time")
end