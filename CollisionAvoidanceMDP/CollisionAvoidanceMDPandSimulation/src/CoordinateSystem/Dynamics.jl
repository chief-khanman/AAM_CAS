# Dependencies: Cartesian2, Polar2, ConvertCoordinateSystem


# A struct repreesnting a point with a position, velocity, and acceleration
mutable struct Dynamics
    position::Cartesian2
    velocity::Polar2
    acceleration::Polar2
end

# Allows the acceleration of the point to be set.
function setAcceleration!(d::Dynamics, a::Polar2)
    d.acceleration = a
end

# steps the point through 1 timestep, moving the position, changing the velocity. Acceleration remains unchanged. 
# Presumably acceleration will be modified every step by other code.
function step!(d::Dynamics, timestep, max_speed=Inf)
    # calculate the new velocity
    d.velocity += d.acceleration * timestep
    
    # ensure does not exceed max speed if one is specified
    if d.velocity.r > max_speed
        d.velocity.r = max_speed
    end

    # convert negative speed to be positive in opposite direction
    if d.velocity.r < 0.0
        d.velocity.r = -d.velocity.r
        d.velocity.θ = d.velocity.θ - pi
    end
    
    # calculate new position
    d.position += toCartesian(d.velocity) * timestep
end

# overwriting print method
function Base.show(io::IO, x::Dynamics)
    print(io,"Pos ",x.position,", Vel ", x.velocity, ", Acc ", x.acceleration); 
end