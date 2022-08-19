
# test constant spawnrate controller
# create variables
sources = ShapeManager()
dests = ShapeManager()
addShape!(sources, Rectangle(Cartesian2(0.0, 1000.0), Cartesian2(1000.0, 0.0)), 1)
addShape!(dests, Rectangle(Cartesian2(0.0, 1000.0), Cartesian2(1000.0, 0.0)), 1)



sc =  ConstantSpawnrateController(;     sources=sources,
                                        destinations=dests,
                                        spawns_per_km_squared_hours=3600, # 1 per second per km2
                                        relative_destination= false)

# must return 1 ac based on the spawnrate 3600 per km2 hr, 1 km2, and a timestep of 1.0 seconds
list =  getSourceAndDestinations(sc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

list =  getSourceAndDestinations(sc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

list =  getSourceAndDestinations(sc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

# double it, shuld be 2 now
setSpawnRate(sc, 7200)
list =  getSourceAndDestinations(sc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 2

list =  getSourceAndDestinations(sc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 2

# now test queued system
qsc =  QueuedSpawnController(;        sources=sources,
                                        destinations=dests,
                                        spawns_per_km_squared_hours=3600,
                                        relative_destination=false)
# no ac, should be able to spawn 1
list =  getSourceAndDestinations(qsc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

# can only spawn 1 at a time since then they are too close anyway, so even if spawnrate is high
# still only returns 1
setSpawnRate(qsc, 36000)
list =  getSourceAndDestinations(qsc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1


# now test congested airspace
sources = ShapeManager()
dests = ShapeManager()
addShape!(sources, Circle(Cartesian2(1000.0, 1000.0), 500.0; r_distribution=Uniform(0.0, 10.0), angle_distribution=Uniform(0.0, 2pi)), 1)
addShape!(dests,   Circle(Cartesian2(1000.0, 1000.0), 500.0; r_distribution=Uniform(0.0, 10.0), angle_distribution=Uniform(0.0, 2pi)), 1)
ac = Vector{Aircraft}(undef, 0)
push!(ac, Aircraft(Dynamics(Cartesian2(1000.0, 1000.0), Polar2(0.0, 0.0), Polar2(0.0, 0.0)), Cartesian2(10000, 10000), Polar2(0.0, 0.0), 1000, 1))
qsc =  QueuedSpawnController(;        sources=sources,
                                        destinations=dests,
                                        spawns_per_km_squared_hours=3600* pi/4,
                                        relative_destination=false)

# note we have 3600*pi/4 spawns/km2hr, pi/4 area, 1 second sim, should get 1 ac.
# but we have forced it to spawn at exactly 1000,1000
# and we added an ac at 1000, 1000
# so it should stay in queue and NOT spawn
list =  getSourceAndDestinations(qsc, 1.0, 0.0, ac, Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 0

# now if aircraft is empty, can spawn again
list =  getSourceAndDestinations(qsc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

# double spawnrate, can still only spawn 1 because of spacing issues
setSpawnRate(qsc, 3600* pi/4 * 2)
list =  getSourceAndDestinations(qsc, 1.0, 0.0, Vector{Aircraft}(undef, 0), Cartesian2(0.0, 0.0), MersenneTwister(1))
@assert length(list) == 1

println("Passed SpawnControllersTest")