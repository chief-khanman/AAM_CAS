# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem, Dynamics, Aircraft


abstract type AbstractSpawnController end


# must return a vector of Tuple of cartesian 2 points
function getSourceAndDestinations(sc::AbstractSpawnController, timestep::Number, current_time::Number, aircraft::Vector{Aircraft}, ego_position::Cartesian2, rng::AbstractRNG)
    return Vector{Pair{Cartesian2, Cartesian2}}(undef, 0)
end

function setSpawnRate(sc::AbstractSpawnController, spawns_per_km_squared_hours::Number)

end


function render(sc::AbstractSpawnController, ax)


end