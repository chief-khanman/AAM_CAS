# Dependencies: None

mutable struct AircraftStats
    ideal_distance
    distance_traveled
    time_elapsed
    num_nmac

    # things needed for nmac checking
    unique_id
    ac_encountered::Dict

end

# default constructor, airspace is initially empty
function AircraftStats(ideal_distance)
    return AircraftStats(ideal_distance, 0.0, 0.0, 0, uuid1(), Dict())
end

function getNormalizedRouteLength(as::AircraftStats)
    return as.distance_traveled / as.ideal_distance
end

function getAverageVelocity(as::AircraftStats)
    return as.distance_traveled / as.time_elapsed
end

function getNMACPerSecond(as::AircraftStats)
    return as.num_nmac / as.time_elapsed
end