error = 0.001

# Test 1
t1 = Polar2(0.0,0.0) + Polar2(1.0,1.0)
@assert t1.r == 1.0
@assert t1.θ == 1.0

# Test 2
t1 = Polar2(0.0,0.0) - Polar2(1.0,1.0)
@assert t1.r == -1.0
@assert t1.θ == -1.0

# Test 3
t1 = Polar2(1.0,1.0) * 10
@assert t1.r == 10.0
@assert t1.θ == 10.0

# Test 4
t1 = Polar2(0.0,0.0)
@assert getX(t1) - 0.0 < error
@assert getY(t1) - 0.0 < error

# Test 5
t1 = Polar2(5.0,0.0)
@assert getX(t1) - 5.0 < error
@assert getY(t1) - 0.0 < error

# Test 6
t1 = Polar2(5.0,pi/2)
@assert getX(t1) - 0.0 < error
@assert getY(t1) - 5.0 < error

# Test 7
t1 = Polar2(5.0,pi)
@assert getX(t1) - -5.0 < error
@assert getY(t1) - 0.0 < error

# Test 8
t1 = Polar2(5.0,3pi/2)
@assert getX(t1) - 0.0 < error
@assert getY(t1) - -5.0 < error

# Test 9
t1 = Polar2(5.0,2pi)
@assert getX(t1) - 5.0 < error
@assert getY(t1) - 0.0 < error

# Test 10
t1 = Polar2(5.0,20pi)
@assert getX(t1) - 5.0 < error
@assert getY(t1) - 0.0 < error

# Test 10
t1 = Polar2(5.0,pi/4)
@assert getX(t1) - 3.53553 < error
@assert getY(t1) - 3.53553 < error
println("Passed Polar2Test")