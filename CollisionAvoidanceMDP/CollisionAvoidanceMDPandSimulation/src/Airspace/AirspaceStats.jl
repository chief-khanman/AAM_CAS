# Dependencies: None

# Relevant stats for the airspace. Each timestep, the stat is added to the list so we can compare over time
mutable struct AirspaceStats
    # general airspace stats
    time::Vector
    number_aircraft::Vector
    number_NMAC::Vector
    
    # keep track of arrived ac so we can pull stats from them
    arrived_ac::Vector


end



# default constructor, airspace is initially empty
function AirspaceStats()
    return AirspaceStats([], [], [], [])
end

function add_stats(as::AirspaceStats, current_time, current_num_ac, nmac_this_timestep, list_ac)
    push!(as.time, current_time)
    push!(as.number_aircraft, current_num_ac)
    push!(as.number_NMAC, nmac_this_timestep)
    push!(as.arrived_ac, list_ac)
end


function average_normalized_route_length(as::AirspaceStats)
    num_ac = 0
    len = 0.0
    for list in as.arrived_ac
        for ac in list
            len += getNormalizedRouteLength(ac.stats)
            num_ac += 1
        end
    end

    return len / num_ac
end

# for arrived ac
function average_num_nmac_per_second_for_arrived_ac(as::AirspaceStats)
    num_ac = 0
    num_nmac_per_second = 0.0
    for list in as.arrived_ac
        for ac in list
            num_nmac_per_second += getNMACPerSecond(ac.stats)
            num_ac += 1
        end
    end

    return num_nmac_per_second / num_ac
end


function average_num_nmac_per_second_for_airspace(as::AirspaceStats, timestep)
    total_flight_time = sum(as.number_aircraft) * timestep
    total_nmac = sum(as.number_NMAC)
    return total_nmac/total_flight_time
end