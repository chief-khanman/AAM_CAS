# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics

# a struct representing a single aircraft. Needs to have a position, velocity, acceleration, destination, and maximum acceleration
# plus statistics of its flight
mutable struct Aircraft
    dynamic::Dynamics
    destinations::Vector{Cartesian2}
    maximum_acceleration::Polar2
    maximum_velocity
    stats::AircraftStats
end

# typical constructor
function Aircraft(dynamic::Dynamics, destinations::Vector{Cartesian2}, maximum_acceleration::Polar2, maximum_velocity, arrival_radius)
    # arrival_radius is needed to calculate ideal ac distance. Note the ac is deleted when its within that distance, so the dest is really a circle, not a point
    stats = AircraftStats(Magnitude(dynamic.position - destinations[end]) - arrival_radius)
    return Aircraft(dynamic, destinations, maximum_acceleration, maximum_velocity, stats)
end

# convenience constructor. Casts the single destination to a vector.
function Aircraft(dynamic::Dynamics, destination::Cartesian2, maximum_acceleration::Polar2, maximum_velocity, arrival_radius)
    return Aircraft(dynamic, [destination], maximum_acceleration, maximum_velocity, arrival_radius)
end



function setAcceleration!(aircraft::Aircraft, acceleration::Polar2)
    # ensure change in speed is within maximum_acceleration
    if acceleration.r > aircraft.maximum_acceleration.r
        acceleration.r = aircraft.maximum_acceleration.r
    elseif acceleration.r < -aircraft.maximum_acceleration.r
        acceleration.r = -aircraft.maximum_acceleration.r
    end

    # ensure change in direction is within maximum_acceleration
    if acceleration.θ > aircraft.maximum_acceleration.θ
        acceleration.θ = aircraft.maximum_acceleration.θ
    elseif acceleration.θ < -aircraft.maximum_acceleration.θ
        acceleration.θ = -aircraft.maximum_acceleration.θ
    end

    setAcceleration!(aircraft.dynamic, acceleration)
end

function step!(aircraft::Aircraft, timestep, acceptable_arrival_distance)
    step!(aircraft.dynamic, timestep, aircraft.maximum_velocity)
    haveArrivedNext, haveArrivedFinal = hasArrived(aircraft, acceptable_arrival_distance)
    if haveArrivedNext
        goToNextDestination(aircraft)
    end
    updateStatistics(aircraft, timestep)
end

# returns if we have arrived to the next destination, and the final destination!
function hasArrived(aircraft::Aircraft, acceptable_arrival_distance)
    distance = aircraft.destinations[1] - aircraft.dynamic.position
    magnitude = Magnitude(distance)
    haveArrivedNext = magnitude <= 5.0 * acceptable_arrival_distance    # TODO 3.o times arrival distance?
    haveArrivedFinal = magnitude <= acceptable_arrival_distance && length(aircraft.destinations) == 1
    return haveArrivedNext, haveArrivedFinal
end


# clears an intermediate waypoint if one exists, and returns the next point
# if there is no intermediate waypoint, does nothing
function goToNextDestination(aircraft::Aircraft)
    if length(aircraft.destinations) > 1
        deleteat!(aircraft.destinations, 1)
    end
    return aircraft.destinations[1]
end


function updateStatistics(aircraft::Aircraft, timestep)
    aircraft.stats.time_elapsed += timestep
    aircraft.stats.distance_traveled += timestep * aircraft.dynamic.velocity.r
end

# overwriting print method
function Base.show(io::IO, x::Aircraft)
    print(io,x.dynamic,", Dest ", x.destination); 
end
