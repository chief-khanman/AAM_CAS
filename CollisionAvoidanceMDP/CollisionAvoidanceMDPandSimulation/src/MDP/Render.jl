# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft, SpawnFunction, PilotFunction, Airspace, MDP
# This is just an addon for the MDP, it is technically not needed to run the MDP


function createLocalAirspacePlot(env::CollisionAvoidanceEnv)
    All_AC =  env.airspace.all_aircraft
    ego = env.airspace.all_aircraft[1]

	# plot the aircraft
	for ac in All_AC
		# plot its current position as blue dot
		scatter(ac.dynamic.position.x, ac.dynamic.position.y, marker="o", color="blue", s=12)

		# plot a line showing its current velocity
		arrow_len = ac.dynamic.velocity.r * 30
		arrow(
			ac.dynamic.position.x, ac.dynamic.position.y,
			cos(ac.dynamic.velocity.θ) * arrow_len * 0.8,
			sin(ac.dynamic.velocity.θ) * arrow_len * 0.8,
			head_width=100,
			width=2,
			head_length=100,
			overhang=0.0,
			head_starts_at_zero="true",
			facecolor="black",
			length_includes_head="true")

		# plot its destination as magenta dot
		scatter(ac.destinations[1].x, ac.destinations[1].y, marker=",", color="magenta", s=12)
		
		# plot a line from src to destination
		plot([ac.dynamic.position.x; ac.destinations[1].x], [ac.dynamic.position.y; ac.destinations[1].y], 
			linestyle="--", color="black", linewidth=0.5)

		# text(ac.dyn.x, ac.dyn.y, string(ac.section))
	end

	# alert circle
	th = LinRange(-pi, pi, 30)
	plot(   ego.dynamic.position.x .+ env.airspace.detection_radius .* cos.(th), 
            ego.dynamic.position.y .+ env.airspace.detection_radius .* sin.(th), 
			linestyle="--", color="red", linewidth=0.4)

	# NMAC circle
	plot(   ego.dynamic.position.x .+ env.nmac_distance .* cos.(th), 
            ego.dynamic.position.y .+ env.nmac_distance .* sin.(th), 
			linestyle="--", color="red", linewidth=0.4)

	# label axis and title
	xlabel("X (m)")
	ylabel("Y (m)")
	title("t = " * string(env.current_time)*", num ac = " * string(length(env.airspace.all_aircraft)))
	axis("equal")
	ax = gca()
    ax[:set_xlim]([ego.dynamic.position.x + -env.airspace.detection_radius * 1.5, ego.dynamic.position.x + env.airspace.detection_radius * 1.5])
	ax[:set_ylim]([ego.dynamic.position.y + -env.airspace.detection_radius * 1.5, ego.dynamic.position.y + env.airspace.detection_radius * 1.5])
	pause(0.01)
	clf()
end


function createGlobalAirspacePlot(env::CollisionAvoidanceEnv)
    All_AC =  env.airspace.all_aircraft
	
	# plot the aircraft
	for ac in All_AC
		# plot its current position as blue dot
		scatter(ac.dynamic.position.x, ac.dynamic.position.y, marker="o", color="blue", s=12)

		# plot a line showing its current velocity
		arrow_len = ac.dynamic.velocity.r * 30
		arrow(
			ac.dynamic.position.x, ac.dynamic.position.y,
			cos(ac.dynamic.velocity.θ) * arrow_len * 0.8,
			sin(ac.dynamic.velocity.θ) * arrow_len * 0.8,
			head_width=100,
			width=2,
			head_length=100,
			overhang=0.0,
			head_starts_at_zero="true",
			facecolor="black",
			length_includes_head="true")
		# plot its destination as magenta dot
		scatter(ac.destinations[1].x, ac.destinations[1].y, marker=",", color="magenta", s=12)

		plot([ac.dynamic.position.x; ac.destinations[1].x], [ac.dynamic.position.y; ac.destinations[1].y], 
			linestyle="--", color="black", linewidth=0.5)

		# text(ac.dyn.x, ac.dyn.y, string(ac.section))
	end

	# labels
	xlabel("X (m)")
	ylabel("Y (m)")
	title("t = " * string(env.current_time)*", num ac = " * string(length(env.airspace.all_aircraft)))
	axis("equal")
	ax = gca()
	ax[:set_xlim]([0.0, env.airspace.boundary.x])
	ax[:set_ylim]([0.0, env.airspace.boundary.y])
	pause(0.01)
	clf()
end
function render(env::CollisionAvoidanceEnv)
    if env.is_MDP
        createLocalAirspacePlot(env)
    else
        createGlobalAirspacePlot(env)
    end
end

function animate_init(env::CollisionAvoidanceEnv)
    rc("font", family="Times New Roman")
    rc("font", size=16)
    rc("text", usetex=false)
    fig = figure("SimAnim", figsize=(15, 8))
end

function animate_createAirspacePlot(env::CollisionAvoidanceEnv)
    All_AC = env.airspace.all_aircraft
    t = env.current_time

    # Plot:
    clf()
	graph1 = subplot2grid((2, 2), (0, 0), rowspan=3)
    ax = gca()
    
	# plot ac
	for ac in All_AC
        graph1 = scatter((ac.dynamic.position.x), (ac.dynamic.position.y), marker="o", color="blue", s=6)
        graph1 = scatter((ac.destinations[1].x), (ac.destinations[1].y), marker=",", color="magenta", s=3)
        graph1 = plot([(ac.dynamic.position.x), (ac.destinations[1].x)], [(ac.dynamic.position.y), (ac.destinations[1].y)], linestyle="--", color="black", linewidth=0.15)
    end

	# plot spaces
	render(env.airspace.spawn_controller, ax) 
	render(env.airspace.restricted_areas, ax, "r", "-") # solid red line
	render(env.airspace.waypoints)


	# final touches
    graph1 = xlabel("x (m)")
    graph1 = ylabel("y (m)")
	graph1 = title("t = " * string(env.current_time)*", num ac = " * string(length(env.airspace.all_aircraft)))
    ax[:set_xlim]([0, env.airspace.boundary.x])
    ax[:set_ylim]([0, env.airspace.boundary.y])
    ax[:set_aspect]("equal")
    return graph1
end

function animate_createNumACPlot(env::CollisionAvoidanceEnv)
    graph2 = subplot2grid((2, 2), (0, 1))
    graph2 = plot(env.airspace.stats.time, env.airspace.stats.number_aircraft, color="red")
    graph2 = xlabel("Time (sec)")
    graph2 = ylabel("Number of Aircraft")
    ax = gca()
    ax[:set_xlim]([0, env.max_time])
    ax[:set_ylim]([0, 1000])
    return graph2
end
function animate_createNMACPlot(env::CollisionAvoidanceEnv)
    graph3 = subplot2grid((2, 2), (1, 1))
    graph3 = plot(env.airspace.stats.time, env.airspace.stats.number_NMAC, color="red")
    graph3 = xlabel("Time (sec)")
    graph3 = ylabel("NMAC/sec")
    ax = gca()
    ax[:set_xlim]([0, env.max_time])
    ax[:set_ylim]([0, 25])
    return graph3
end

# this is a standin for a callback function
function DoNothing(env::CollisionAvoidanceEnv)
    
end

# this is a callback function to print current time to ensure progress is being made
function PrintTime(env::CollisionAvoidanceEnv)
    if env.current_time % 100.0 == 0.0
		println("t = ", env.current_time)
	end
end

# This function creates an mp4 file
# it is equilvalent to calling step! in a while loop until max time is reached
# Note this is for simulation only. For MDP, use renderLocal or renderGlobal
function Animate!(env::CollisionAvoidanceEnv; callback_function::Function=DoNothing, filename::String="")
    
	# ensure filename is valid
	if filename == ""
		name = string(typeof(env.airspace.spawn_controller))
		filename = name * ".mp4"
	end
	if filename[end-3:end] != ".mp4"
		filename = filename * ".mp4"
	end

	# animate function
	fig = animate_init(env)
    function animate(i, env::CollisionAvoidanceEnv)
        step!(env)        
        callback_function(env)

        ax1 = animate_createAirspacePlot(env)
        ax2 = animate_createNumACPlot(env)
        ax3 = animate_createNMACPlot(env)
        frame = (ax1, ax2, ax3)
        return frame
    end

	# call animate function
    numSteps = Int(trunc((env.max_time-env.current_time)/env.timestep))
    sim_anim = animation.FuncAnimation(fig, animate, fargs=(env,), frames=numSteps, interval=200)
    sim_anim[:save](filename, fps=60, extra_args=["-vcodec", "libx264"])
    closeAllWindows()
end

# closes plot windows. They do not close on their own for some reason
function closeAllWindows()
    close("all")
end