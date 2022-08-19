
# test 1 = circle
c = Circle(Cartesian2(0.0, 0.0), 1.0)

some_point = Cartesian2(-5.0, 0.0)
nearest, distance =  getNearestPointOnEdge(c, some_point) 
@assert nearest == Cartesian2(-1.0, 0.0)
@assert distance ==  4.0

some_point = Cartesian2(5.0, 0.0)
nearest, distance =  getNearestPointOnEdge(c, some_point) 
@assert nearest == Cartesian2(1.0, 0.0)
@assert distance ==  4.0

some_point = Cartesian2(0.0, -5.0)
nearest, distance =  getNearestPointOnEdge(c, some_point) 
@assert nearest == Cartesian2(0.0, -1.0)
@assert distance ==  4.0

some_point = Cartesian2(0.0, 5.0)
nearest, distance =  getNearestPointOnEdge(c, some_point) 
@assert nearest == Cartesian2(0.0, 1.0)
@assert distance ==  4.0


some_point = Cartesian2(5.0, 5.0)
nearest, distance =  getNearestPointOnEdge(c, some_point) 
@assert nearest.x - sqrt(2.0)/2.0 < 0.000001
@assert nearest.y - sqrt(2.0)/2.0 < 0.000001
@assert distance ==  sqrt(5^2 + 5^2) - 1



some_point = samplePoint(c, MersenneTwister(123))





# test 2 = rectangle
r = Rectangle(Cartesian2(0.0, 1.0), Cartesian2(1.0, 0.0))

some_point = Cartesian2(-5.0, 0.0)
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(0.0, 0.0)
@assert distance ==  5.0

some_point = Cartesian2(5.0, 0.0)
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(1.0, 0.0)
@assert distance ==  4.0

some_point = Cartesian2(5.0, 5.0)
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(1.0, 1.0)
@assert distance ==  sqrt(4.0^2 + 4.0^2)

some_point = Cartesian2(0.5, 5.0)
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(0.5, 1.0)
@assert distance ==  4.0

some_point = Cartesian2(0.25, 0.5) # in left triangle of the rectangle
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(0.0, 0.5)
@assert distance ==  -0.25

some_point = Cartesian2(0.75, 0.5) # in left triangle of the rectangle
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(1.0, 0.5)
@assert distance ==  -0.25

some_point = Cartesian2(0.5, 0.75) # in left triangle of the rectangle
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(0.5, 1.0)
@assert distance ==  -0.25

some_point = Cartesian2(0.25, 0.5) # in left triangle of the rectangle
nearest, distance =  getNearestPointOnEdge(r, some_point) 
@assert nearest == Cartesian2(0.0, 0.5)
@assert distance ==  -0.25


some_point = samplePoint(r, MersenneTwister(123))


println("Passed ShapesTest")