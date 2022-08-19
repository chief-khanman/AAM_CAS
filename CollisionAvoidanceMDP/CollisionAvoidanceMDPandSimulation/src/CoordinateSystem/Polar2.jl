# Dependencies: None

# Define a polar coordinate system for 2 dimensions
mutable struct Polar2
    r
    θ
end

# overload + operator so we can add coordinates
function Base.:+(a::Polar2, b::Polar2) 
    r = a.r + b.r
    θ = a.θ + b.θ
    return Polar2(r,θ)
end

# overload - operator so we can subtract coordinates
function Base.:-(a::Polar2, b::Polar2) 
    r = a.r - b.r
    θ = a.θ - b.θ
    return Polar2(r,θ)
end

# overload * operator so we can scale coordinates - radius and angle are scaled
function Base.:*(a::Polar2, b) 
    r = a.r * b
    θ = a.θ * b
    return Polar2(r,θ)
end


# provide a way to get X and Y values out of it, though this may not be used much
function getX(a::Polar2)
    return a.r * cos(a.θ)
end
function getY(a::Polar2)
    return a.r * sin(a.θ)
end


# overwriting print method
function Base.show(io::IO, x::Polar2)
    print(io,"r=",x.r,", θ=",x.θ); 
end