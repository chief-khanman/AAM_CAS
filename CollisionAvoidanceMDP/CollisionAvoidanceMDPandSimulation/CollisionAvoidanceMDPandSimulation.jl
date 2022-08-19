
#### externals ####
# for math
using Base, Distributions, IntervalSets, Random, UUIDs
using ReinforcementLearning, ReinforcementLearningBase
using StatsBase
using Graphs

# for rendering
ENV["MPLBACKEND"]="tkagg" # this is now needed to choose a gui backend for some reason. IDK why
using PyPlot
using PyCall
@pyimport matplotlib.animation as animation

#### internals. Note order matters, do not change it ####
# each local file lists its local dependencies at the top of the file. This may be useful if the order gets messed up
include("src/Helpers.jl")

include("src/CoordinateSystem/Cartesian2.jl")
include("src/CoordinateSystem/Polar2.jl")
include("src/CoordinateSystem/ConvertCoordinateSystem.jl")
include("src/CoordinateSystem/Dynamics.jl")

include("src/Shapes/AbstractShape.jl")
include("src/Shapes/Circle.jl")
include("src/Shapes/Rectangle.jl")
include("src/Shapes/ShapeManager.jl")

include("src/PathFinder/PathFinder.jl")
include("src/PathFinder/PointAndEdgeGenerators.jl")

include("src/Airspace/AircraftStats.jl")
include("src/Airspace/Aircraft.jl")

include("src/SpawnController/AbstractSpawnController.jl")
include("src/SpawnController/ConstantSpawnrateController.jl")
include("src/SpawnController/QueuedSpawnController.jl")
include("src/SpawnController/QueuedAndTimedSpawnController.jl")


include("src/Airspace/SpawnFunction.jl")
include("src/Airspace/AirspaceStats.jl")
include("src/Airspace/Airspace.jl")
include("src/Airspace/PilotFunction.jl")

include("src/MDP/MDP.jl")
include("src/MDP/Render.jl")
include("src/MDP/Discretizer.jl")
include("src/MDP/TransformedEnvironments.jl")


