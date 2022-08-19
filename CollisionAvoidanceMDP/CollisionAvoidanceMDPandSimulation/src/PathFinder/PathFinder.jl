# dependencies: Cartesian2

struct PathFinder
    points::Vector{Cartesian2}
    edge_graph::SimpleDiGraph
    weights::Matrix
end

function PathFinder()
    return PathFinder(Vector{Cartesian2}(undef, 0), SimpleDiGraph(), Matrix{Float64}(undef, 0, 0))
end

function PathFinder(  points::Vector{Cartesian2}, edges::Vector{Edge{Int64}} )
    weights = Matrix(undef, length(points), length(points))
    for i in 1:length(points)
        for j in 1:length(points)
            weights[i, j] = Magnitude(points[i] - points[j])
        end
    end
    g = SimpleDiGraph(edges)

    return PathFinder(points, g, weights)
end

function findNearestPointIndex(pf::PathFinder, point::Cartesian2)
    nearest_distance = Magnitude(point - pf.points[1])
    nearest_point_index = 1
    for i in 2:length(pf.points)
        magnitude = Magnitude(point - pf.points[i]) 
        if magnitude < nearest_distance
            nearest_distance = magnitude
            nearest_point_index = i
        end
    end
    return nearest_point_index
end


function findPath(pf::PathFinder, start::Cartesian2, dest::Cartesian2, rng::AbstractRNG)
    # error check. If its empty, return nothing
    if length(pf.points) == 0
        return [dest]
    end
    
    
    start_index = findNearestPointIndex(pf, start)
    end_index = findNearestPointIndex(pf, dest)
    # use randomness to break ties. A small change in value (between 0 and 1 ) wont hurt
    hueristic_f(index) = Magnitude(pf.points[index] - pf.points[end_index]) + rand(rng, Uniform(0.0, 0.1))

    # check that there are edges. If there arent, then just return the nearest point as a waypoint
    if pf.edge_graph.ne == 0
        return [pf.points[start_index], dest]
    end


    path = a_star(  pf.edge_graph,        # the graph
                    start_index, # the start vertex index
                    end_index,   # the end vertex index
                    pf.weights,  # the distance between all points
                    hueristic_f, # the hueristic function we just generated
                    )  

    # check that the path length isnt 0
    # if it is, then there are no edges, only a single point
    if length(path) == 0
        return [pf.points[start_index], dest]
    end


    # convert the path to a list of points. Dont forget the last point in path and the destination point
    ret = Vector{Cartesian2}(undef, 0)
    for edge in path
        index = src(edge)
        push!(ret, pf.points[index])
    end

    # add last point in path and destination points
    push!(ret, pf.points[dst(path[end])])
    push!(ret, dest)

    return ret
end


function render(pf::PathFinder)
    for point in pf.points
        graph1 = scatter((point.x), (point.y), marker="o", color="black", s=6)
    end
end
