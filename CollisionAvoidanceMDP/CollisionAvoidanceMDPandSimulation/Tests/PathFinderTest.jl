# test 1
points = [  Cartesian2(0.0, 0.0),
            Cartesian2(1.0, 0.0),
            Cartesian2(0.0, 1.0),
            Cartesian2(1.0, 1.0),
            Cartesian2(2.0, 2.0),
            Cartesian2(3.0, 3.0),
]
edges = [   Edge(1, 2), 
            Edge(1, 3), 
            Edge(2, 4), 
            Edge(3, 4), 
            Edge(4, 5), 
            Edge(5, 6), 
]


pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-1.0, -1.0), Cartesian2(10.0, 10.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 0.0)
@assert path[2] == Cartesian2(1.0, 0.0) || path[2] == Cartesian2(0.0, 1.0)
@assert path[3] == Cartesian2(1.0, 1.0)
@assert path[4] == Cartesian2(2.0, 2.0)
@assert path[5] == Cartesian2(3.0, 3.0)
@assert path[6] == Cartesian2(10.0, 10.0)

# test 2
path = findPath(pf, Cartesian2(-1.0, -1.0), Cartesian2(-1.0, 1.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 0.0)
@assert path[2] == Cartesian2(0.0, 1.0)
@assert path[3] == Cartesian2(-1.0, 1.0)

# test 3
pf = PathFinder( )
path = findPath(pf, Cartesian2(-1.0, -1.0), Cartesian2(10.0, 10.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(10.0, 10.0)

#test 4
points = [  
            Cartesian2(1.0, 0.0),
            Cartesian2(0.0, 1.0),
        ]
edges = Vector{Edge{Int64}}(undef, 0)
edges = [Edge(1, 2)]
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(1.0, 2.0), Cartesian2(-1.0, 1.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 1.0)

#test 5
points = [  
            Cartesian2(1.0, 0.0),
            Cartesian2(0.0, 1.0),
        ]
edges = Vector{Edge{Int64}}(undef, 0)
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-1.0, -1.0), Cartesian2(2.0, 2.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 1.0) || path[1] ==  Cartesian2(1.0, 0.0)

#test 6
points = [  Cartesian2(0.0, 0.0),
            Cartesian2(0.0, 1.0),
            Cartesian2(1.0, 1.0),
            Cartesian2(1.0, 0.0),
        ]
edges = [   Edge(1, 2), 
            Edge(2, 3), 
            Edge(3, 4), 
            Edge(4, 1), 

        ]

pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-1.0, 0.0), Cartesian2(2.0, 0.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 0.0)
@assert path[2] == Cartesian2(0.0, 1.0)
@assert path[3] == Cartesian2(1.0, 1.0)
@assert path[4] == Cartesian2(1.0, 0.0)

# test for the point and edge generator as well
# test 7
points, edges = getLineOfPoints(Cartesian2(0.0, 0.0), Cartesian2(10.0, 0.0), 0 )
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-1.0, 0.0), Cartesian2(11.0, 0.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 0.0)
@assert path[2] == Cartesian2(10.0, 0.0)
@assert path[3] == Cartesian2(11.0, 0.0)

# test 8
points, edges = getLineOfPoints(Cartesian2(0.0, 0.0), Cartesian2(10.0, 0.0), 4 )
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-1.0, 0.0), Cartesian2(11.0, 0.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(0.0, 0.0)
@assert path[2] == Cartesian2(2.0, 0.0)
@assert path[3] == Cartesian2(4.0, 0.0)


# test 9
points, edges = getLineOfPoints(Cartesian2(0.0, 0.0), Cartesian2(10.0, 0.0), 4 )
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(11.0, 0.0), Cartesian2(-1.0, 0.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(10.0, 0.0)
@assert path[2] == Cartesian2(-1.0, 0.0)

# test 10
points, edges = getLineOfPoints(Cartesian2(0.0, 0.0), Cartesian2(10.0, 0.0), 4, bidirectional=true)
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(11.0, 0.0), Cartesian2(-1.0, 0.0), MersenneTwister(1234))
@assert path[1] == Cartesian2(10.0, 0.0)
@assert path[2] == Cartesian2(8.0, 0.0)
@assert path[3] == Cartesian2(6.0, 0.0)

# test 11
points, edges =  getCircleOfPoints(Cartesian2(0.0, 0.0), 1.0, 4; connected_clockwise=true, connected_counter_clockwise=false)
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-2.0, 0.0), Cartesian2(2.0, 0.0), MersenneTwister(1234))
@assert path[1].x == -1.0
@assert path[2].y == 1.0
@assert path[3].x == 1.0
@assert path[4].x == 2.0


# test 12
points, edges =  getCircleOfPoints(Cartesian2(0.0, 0.0), 1.0, 4; connected_clockwise=false, connected_counter_clockwise=true)
pf = PathFinder(  points, edges)
path = findPath(pf, Cartesian2(-2.0, 0.0), Cartesian2(2.0, 0.0), MersenneTwister(1234))
@assert path[1].x == -1.0
@assert path[2].y == -1.0
@assert path[3].x == 1.0
@assert path[4].x == 2.0



println("Passed PathFinderTest")