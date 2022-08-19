# Test 1
b = Cartesian2(1000.0, 1000.0)
rng = MersenneTwister(1)

for _ in 1:100
    start, dest= ego_spawn_function(b, Cartesian2(0,0), 0.0, 100.0, rng)
    @assert 0 <= start.x <= b.x
    @assert 0 <= start.y <= b.y
    @assert Magnitude(start - dest) - 5000.0 < 0.1
end

println("Passed SpawnFunctionTest")