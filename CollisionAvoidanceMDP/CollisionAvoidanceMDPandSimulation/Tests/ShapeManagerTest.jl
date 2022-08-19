# test
sm = ShapeManager()

c = Circle(Cartesian2(0.0, 0.0), 1.0) # unit circle
r = Rectangle(Cartesian2(5.0, 1.0), Cartesian2(6.0, 0.0)) # square of size 1 with bottom left at 5.0, 0.0

addShape!(sm, c, 10)
addShape!(sm, r, 1)

point, distance = getNearestPointOnEdge(sm, Cartesian2(-5.0, 0.0))
@assert point == Cartesian2(-1.0, 0.0)
@assert distance == 4.0

point, distance = getNearestPointOnEdge(sm, Cartesian2(10.0, 0.0))
@assert point == Cartesian2(6.0, 0.0)
@assert distance == 4.0

samplePoint(sm, MersenneTwister(123))
samplePoint(sm, MersenneTwister(123))
samplePoint(sm, MersenneTwister(123))
samplePoint(sm, MersenneTwister(123))




println("Passed ShapeManagerTest")