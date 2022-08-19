# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft

# note if there is an ego aircraft, it will be the first aircraft in the list all_aircraft
mutable struct Airspace
    all_aircraft::Vector{Aircraft}
    boundary::Cartesian2 # for rendering purposes, aircraft can leave this boundary
    create_ego_aircraft::Bool # whether or not this airspace should create an ego agent to begin with
    spawn_controller::AbstractSpawnController # an object to handle creating src and destination positions
    restricted_areas::ShapeManager  # areas within the airspace the ac have to avoid
    waypoints::PathFinder # A list of intermediate waypoints. This provides structure to where AC fly to intermediately

    # airspace constants
    maximum_aircraft_acceleration::Polar2
    maximum_aircraft_speed
    detection_radius
    arrival_radius
    
    # rng for reproducibility
    rng

    # stats to keep track of
    stats::AirspaceStats
end

# default constructor, airspace is initially empty
function Airspace(  ;
                    rng::AbstractRNG, 
                    boundary::Cartesian2=Cartesian2(10000.0, 10000.0),
                    create_ego_aircraft::Bool=true, 
                    spawn_controller::AbstractSpawnController=ConstantSpawnrateController(boundary, create_ego_aircraft),
                    restricted_areas::ShapeManager = ShapeManager(),  
                    waypoints::PathFinder = PathFinder(), 
                    maximum_aircraft_acceleration::Polar2=Polar2(3.0, 2pi/10), 
                    maximum_aircraft_speed::Number=50.0, 
                    detection_radius::Number=1000.0, 
                    arrival_radius::Number=100.0,
                    )

    # adust the spawn rate based on the size of the spawn areas. Converts it to spawns/second from spawns/second-m^2
    all_aircraft = Vector{Aircraft}(undef, 0)
    stats = AirspaceStats()
    as = Airspace(all_aircraft, boundary, create_ego_aircraft, spawn_controller,  restricted_areas, waypoints, maximum_aircraft_acceleration, maximum_aircraft_speed, detection_radius, arrival_radius, rng, stats)
    reset!(as)
    return as
end


# creates an aircraft and adds it to the airspace
function createEgoAircraft(airspace::Airspace)
    @assert length(airspace.all_aircraft) == 0
    # note ego is hard coded to spawn anywhere, and go 5000 meters
    start, destination =    ego_spawn_function(airspace.boundary, Cartesian2(0,0), airspace.detection_radius, airspace.arrival_radius, airspace.rng)
    initial_velocity = Polar2(airspace.maximum_aircraft_speed/2, rand(airspace.rng, Uniform(0.0, 2pi)))
    initial_acceleration = Polar2(0.0, 0.0)

    ac = Aircraft(Dynamics(start, initial_velocity, initial_acceleration), [destination], airspace.maximum_aircraft_acceleration, airspace.maximum_aircraft_speed, airspace.arrival_radius)
    push!(airspace.all_aircraft, ac)
end

# creates an aircraft and adds it to the airspace
function createAircraft(airspace::Airspace, source::Cartesian2, destination::Cartesian2)
    destinations = findPath(airspace.waypoints, source, destination, airspace.rng)
    
    initial_velocity = Polar2(airspace.maximum_aircraft_speed/2, rand(airspace.rng, Uniform(0.0, 2pi)))
    initial_acceleration = Polar2(0.0, 0.0)

    ac = Aircraft(Dynamics(source, initial_velocity, initial_acceleration), destinations, airspace.maximum_aircraft_acceleration, airspace.maximum_aircraft_speed, airspace.arrival_radius)
    push!(airspace.all_aircraft, ac)
end

# finds the nearest intruder in the list of aircraft to the aircraft. Must be within detection radius, otherwise returns nothing
function findNearestIntruder(aircraft::Aircraft, all_aircraft::Vector{Aircraft}, detection_radius)
    # find intruder, if they exists
    intruder = nothing
    intruder_distance = detection_radius


    # look for nearest intruder
    for possible_intruder in all_aircraft
        # skip self!
        if possible_intruder == aircraft 
            continue
        end

        # compute distance away, update if they are closer
        distance_away = Magnitude(possible_intruder.dynamic.position - aircraft.dynamic.position)
        if distance_away < intruder_distance
            intruder = possible_intruder
            intruder_distance = distance_away
        end
    end
    return intruder, intruder_distance
end

# finds the nearest intruder in the list of aircraft to the aircraft. Must be within detection radius, otherwise returns nothing
function findNearestRestricted(aircraft::Aircraft, restricted_areas::ShapeManager, detection_radius) 
    nearest_restricted, restricted_distance = getNearestPointOnEdge(restricted_areas, aircraft.dynamic.position)

    # make sure nearest RA is within detection radius
    if restricted_distance > detection_radius
        nearest_restricted = nothing
        restricted_distance = detection_radius
    end

    # if the AC is within the RA, then we need to adjust it.
    # The function getNearestPointOnEdge will still return an edge point, and a negative distance. 
    # we want to encourage it to leave the RA. So, we will create a point that is in the opposite direction of the nearest edge point
    # this will hopefully push the AC outside of the RA 
    if restricted_distance < 0.0
        # get unit vector in the direction from edge to the AC
        vector_from_edge_to_ac = aircraft.dynamic.position - nearest_restricted
        unit_vector = vector_from_edge_to_ac * (1.0 / Magnitude(vector_from_edge_to_ac))

        # use unit vector to create a point on the opposite side of the ac, 50.0 meters away
        new_restricted_point = aircraft.dynamic.position + unit_vector * 50.0
        nearest_restricted = new_restricted_point
        restricted_distance = 50.0
    end

    return nearest_restricted, restricted_distance
end


# Returns the state of an aircraft
function getState(aircraft::Aircraft, all_aircraft::Vector{Aircraft}, detection_radius, restricted_areas::ShapeManager)
    # calculate deviation
    destination_vector = aircraft.destinations[1] - aircraft.dynamic.position
    deviation = Angle(destination_vector) - aircraft.dynamic.velocity.θ

    # find my velocity 
    velocity = aircraft.dynamic.velocity.r

    # find nearest intruder and restricted airspace.
    # Nearest point in airspace can be considered an aircraft with 0 velocity. 
    # Note for both cases, if there is not an intruder/RA within detection_radius, the thing is nothing and the distance is detection_radius
    nearest_intruder, intruder_distance = findNearestIntruder(aircraft, all_aircraft, detection_radius)
    nearest_restricted, restricted_distance = findNearestRestricted(aircraft, restricted_areas, detection_radius) 

    # first, is there an intruder or RA at all?
    # assuming there is, calculate the intruder distance away, position, and velocity
    # distance away = the ac if its closer, or the RA otherwise.
    # position = aircraft position, or the nearest point in the RA
    # velocity = ac velocity, or 0.0 for a RA
    is_intruder = intruder_distance < detection_radius || restricted_distance < detection_radius
    if intruder_distance < restricted_distance
        intruder_distance = intruder_distance
        intruder_position = nearest_intruder.dynamic.position
        intruder_velocity = nearest_intruder.dynamic.velocity
    elseif intruder_distance > restricted_distance
        intruder_distance = restricted_distance
        intruder_position = nearest_restricted
        intruder_velocity = Polar2(0.0, 0.0)
    end

    # There isnt intruder or RA
    if !is_intruder
        has_intruder = 0.0
        intruder_distance = 0.0
        angle_of_intruder = 0.0
        heading_of_intruder = 0.0
        velocity_of_intruder = 0.0

    # There is intruder
    # Use the values gathered from intruder info to calculate state. Doesnt matter if its an AC or RA, the process is the same
    # given that we have intruder distance, intruder position, and intruder velocity (0 for a RA since its constant position)
    else 
        has_intruder = 1.0
        angle_of_intruder = Angle(intruder_position - aircraft.dynamic.position) - aircraft.dynamic.velocity.θ
        relative_velocity_of_intruder = toPolar(toCartesian(intruder_velocity) - toCartesian(aircraft.dynamic.velocity))
        heading_of_intruder = relative_velocity_of_intruder.θ - aircraft.dynamic.velocity.θ 
        velocity_of_intruder = relative_velocity_of_intruder.r
    end

    # need to normalize state
    state = [deviation, velocity, has_intruder, intruder_distance, angle_of_intruder, heading_of_intruder, velocity_of_intruder]
    normalize!(state, aircraft.maximum_velocity, detection_radius)

    return state
end

# normalize the state
# deviation is between -pi and pi
# velocity is between 0 and 1 (max_velocity = 1)
# has intruder is always either 0 or 1
# intruder distance is between 0 and 1 (1 = detection radius)
# angle of intrduer is between -pi and pi
# heading of intruder is between -pi and pi
# velocity of intruder is between 0 and 2( 2 = 2* max_velocity because they can be going the opposite direction as us)
function normalize!(state, max_speed, detection_radius, )
    state[1] = moveBetweenPiAndMinusPi(state[1])
    state[2] /= max_speed
    state[4] /= detection_radius
    state[5] = moveBetweenPiAndMinusPi(state[5])
    state[6] = moveBetweenPiAndMinusPi(state[6])
    state[7] /= (2*max_speed)
end

# moves a value in radians to be between -pi and pi. Note the angle represented is the same
function moveBetweenPiAndMinusPi(angle)
    # initially any value
    angle = angle % (2pi) 
    # now between -2pi and 2pi
    if angle < 0
        angle += 2*pi
    end
    # now between 0 and 2pi
    if angle >= pi
        angle -= 2*pi
    end
    # now between -pi and pi
    return angle
end

# fetch the ego aircrafts state
function getEgoState(airspace::Airspace)
    if airspace.create_ego_aircraft == false
        error("This simulation does not have an ego aircraft. Set create_ego_aircraft to true in order to create an MDP")
    end

    return getState(airspace.all_aircraft[1], airspace.all_aircraft, airspace.detection_radius, airspace.restricted_areas)

end


# fetch all aircraft states, except the ego aircraft if one exists
function getAllStates(airspace::Airspace)
    all_states = []
    for i in 1:length(airspace.all_aircraft)
        if airspace.create_ego_aircraft && i == 1
            continue
        end
        ac = airspace.all_aircraft[i]
        push!(all_states, getState(ac, airspace.all_aircraft, airspace.detection_radius, airspace.restricted_areas))

    end
    return all_states
end

# set the ego acceleration. Used by MDP
function setEgoAcceleration(airspace::Airspace, acceleration::Polar2)
    if airspace.create_ego_aircraft == false
        error("This simulation does not have an ego aircraft. Set create_ego_aircraft to true in order to create an MDP")
    end
    setAcceleration!(airspace.all_aircraft[1], acceleration)
end

# Set acceleration of every aicraft but the ego aircraft.
# if ego exists, sets aircracts 2:N
# if ego does not exists, sets aircrafts 1:N
function setAllAccelerations(airspace::Airspace, accelerations::Vector{Polar2})
    # make sure num accerlations matches num aircraft.
    # remember, if ego exists, it is at index = 1
    if !airspace.create_ego_aircraft && length(accelerations) != length(airspace.all_aircraft)
        error("The number of acceleration values and the number of aircraft do not match")
    end
    if airspace.create_ego_aircraft && length(accelerations) != (length(airspace.all_aircraft) - 1)
        error("The number of acceleration values and the number of aircraft do not match. Note the ego aircraft cannot be set with this method, set it using setEgoAcceleration.")
    end


    for i in 1:length(accelerations)
        if airspace.create_ego_aircraft 
            setAcceleration!(airspace.all_aircraft[i + 1], accelerations[i]) # if ego exists, skip first aircraft
        else
            setAcceleration!(airspace.all_aircraft[i], accelerations[i]) 
        end
    end
end

# step all aircraft in the airspace through time. Spawn new ones
function step!(airspace::Airspace, timestep, current_time, nmac_range)
    # move through time
    for ac in airspace.all_aircraft
        step!(ac, timestep, airspace.arrival_radius)
    end

    number_NMAC_this_timestep = calculateNumNMAC(airspace, nmac_range, current_time)

    # create new ac
    # coords are the ego position if exists
    coords = airspace.create_ego_aircraft ? airspace.all_aircraft[1].dynamic.position : Cartesian2(0.0, 0.0)

    # detirmine how many to make. Is random between floor(spawnrate) and ceiling(spawnrate)
    ac = getSourceAndDestinations(airspace.spawn_controller, timestep, current_time, airspace.all_aircraft, coords, airspace.rng)

    # create all aircraft based on the above number
    for (start, destination) in ac
        createAircraft(airspace, start, destination)
    end

    # kill arrived aircraft
    # kill aircraft far from ego - MDP only 
    num_ac = length(airspace.all_aircraft)
    list_ac = []
    for i in 1:num_ac
        # dont kill ego, sim needs to end
        if airspace.create_ego_aircraft && i == 1
            continue
        end

        # Since we might change size of list, have to check list size every time
        if i > num_ac
            break
        end

        # all others can be killed
        # Kill if the ac has arrived, or if we are MDP and it is far away from ego (then we dont need to simulate it)
        # If its arrived locally, but not to its final destination, change its waypoint to the next waypoint
        ac = airspace.all_aircraft[i]
        hasArrivedNext, hasArrivedFinal = hasArrived(ac, airspace.arrival_radius)
        if  hasArrivedFinal     # kill if arrived   
            # update stats
            push!(list_ac, ac)

            # delete it from list
            deleteat!(airspace.all_aircraft, i)
            num_ac -= 1
            i -= 1
        # kill if too far from ego and its MDP
        elseif airspace.create_ego_aircraft && Magnitude(ac.dynamic.position - airspace.all_aircraft[1].dynamic.position) > airspace.detection_radius
            deleteat!(airspace.all_aircraft, i)
            num_ac -= 1
            i -= 1
        end

    end

    add_stats(airspace.stats, current_time, length(airspace.all_aircraft), number_NMAC_this_timestep, list_ac)
end


function reset!(airspace::Airspace)
    airspace.all_aircraft = []
    if airspace.create_ego_aircraft # if mdp, create an ego agent before starting. AC at index 1 (first) is the ego
        createEgoAircraft(airspace)
    end
end

# overwriting print method
function Base.show(io::IO, x::Airspace)
    print(io, "num ac=", length(x.all_aircraft))
end

function calculateNumNMAC(airspace::Airspace, nmac_range, current_time)
    num_ac = length(airspace.all_aircraft)
    num_nmac = 0
    for i in 1:num_ac
        for j in i+1:num_ac
            ac1 = airspace.all_aircraft[i]
            ac2 = airspace.all_aircraft[j]
            if Magnitude(ac1.dynamic.position - ac2.dynamic.position) < nmac_range
                # if time since we saw this ac last is less than 10 seconds, does not count as new collision!
                # If we have not seen this ac before, default value is -1000 so that this is always false and we proceed to the below
                if current_time - get(ac1.stats.ac_encountered, ac2.stats.unique_id, -1000.0) < 10.0
                    continue
                else
                    num_nmac += 1
                    airspace.all_aircraft[i].stats.num_nmac += 1
                    airspace.all_aircraft[j].stats.num_nmac += 1
                    # remember to add this encounter to the first ac. Since the order of this list doesnt change,
                    # we do not also need to add it to j
                    ac1.stats.ac_encountered[ac2.stats.unique_id] = current_time 
                end
            end
        end
    end
    return num_nmac
end

