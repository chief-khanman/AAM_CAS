# the below function creates the ego agents initial position and destination for the MDP. The destination is guranteed to be exactly 5000 meters away. 
function ego_spawn_function(boundary::Cartesian2, ego_location::Cartesian2, detection_radius, arrival_radius,  rng)
    init_x = rand(rng, Uniform(0.0, boundary.x))
    init_y = rand(rng, Uniform(0.0, boundary.y))

    dest_theta = rand(rng, Uniform(0.0, 2pi))
    dest_offset = toCartesian(Polar2(5000.0, dest_theta))

    start = Cartesian2(init_x, init_y)
    destination = start + dest_offset

    return start, destination
end