# Dependencies: None

# Define a cartesian coordinate system for 2 dimensions
mutable struct Cartesian2
    x
    y
end

# overload + operator so we can add coordinates
function Base.:+(a::Cartesian2, b::Cartesian2) 
    x = a.x + b.x
    y = a.y + b.y
    return Cartesian2(x,y)
end

# overload - operator so we can subtract coordinates
function Base.:-(a::Cartesian2, b::Cartesian2) 
    x = a.x - b.x
    y = a.y - b.y
    return Cartesian2(x,y)
end

# overload * operator so we can scale coordinates
function Base.:*(a::Cartesian2, b) 
    x = a.x * b
    y = a.y * b
    return Cartesian2(x,y)
end

# overload == operator so we can scale coordinates
function Base.:(==)(a::Cartesian2, b::Cartesian2) 
    return a.x == b.x && a.y == b.y
end

# Convenience function to get magnitude of a coordinate
function Magnitude(a::Cartesian2) 
    return sqrt(a.x^2 + a.y^2)
end

# Convenience function to get angle of a coordinate from the x axis, in radians
# Output is between -pi and pi
function Angle(a::Cartesian2) 
    return atan(a.y, a.x)
end

# overwriting print method
function Base.show(io::IO,x::Cartesian2)
    print(io,"x=",x.x,", y=",x.y); 
end