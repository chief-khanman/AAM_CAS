# Dependencies: Cartesian2, Polar2


# this file provides functions to convert from cartesian to polar and vice versa

# convert cartesian to polar
function toPolar(a::Cartesian2) 
    r = Magnitude(a)
    θ = Angle(a)
    return Polar2(r,θ)
end

# convert polar to cartesian
function toCartesian(a::Polar2) 
    x = getX(a)
    y = getY(a)
    return Cartesian2(x,y)
end