# note this module just sandboxes the test. Any global variables created for testing are now confined to this module
# and cannot leak into other code if you run the test and then run other code in the same REPL.
module CollisionAvoidanceMDPandSimulationTest

println("Compiling...")

# include the source code
include("../CollisionAvoidanceMDPandSimulation.jl")

# include all tests
include("Cartesian2Test.jl")
include("Polar2Test.jl")
include("ConvertCoordinateSystemTest.jl")
include("ShapesTest.jl")
include("ShapeManagerTest.jl")
include("PathFinderTest.jl")
include("DynamicsTest.jl")
include("AircraftTest.jl")
include("SpawnFunctionTest.jl")
include("AirspaceTest.jl")
include("PilotFunctionTest.jl")
include("MDPTest.jl")
include("SpawnControllersTest.jl")
include("InterfaceTest.jl")


println("\nAll tests passed")

end