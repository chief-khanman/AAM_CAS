# Collision Avoidance MDP
This repository consists of two sections: 
- Collision Avoidance MDP and Simulation - Used as a training and testing environment for a collision avoidance system.
- Collision Avoidance Algorithms - Using the MDP and simulation, tests various collision avoidance policies (strategies) in simulations. Is able to gather statistics on each policy and to generate a video of the policy in action.
  
# MDP and Simulation
This section of the project contains 3 parts:
1. Examples - This folder contains examples of using the MDP and/or the simulation in your own code.
2. src - This folder contains all relevant source code. See below for implementation details.
3. Tests - This folder contains unit tests of each part of the source code. In a Julia REPL, run > include("AllTests.jl") to test the entire project. If it runs without crashing, then the project is functioning properly. This is useful for when you have made changes and want to verify nothing was broken as a result. 

# MDP Example
Below is an example of the training MDP (with a dummy pilot). Note rendering is not usually done in training. 

https://user-images.githubusercontent.com/59975096/160887030-bd0e8598-9b34-46d8-9ed6-f6820710b0e8.mp4

Note:
- Each blue dot represents an aircraft
- The arrow represents current heading and velocity
- The magenta dots represent destinations.
- The inner circle is the radius for a Near Mid Air Collision (NMAC), a metric used to detirmine how often collisions occur. 
- The outer circle is the detection radius, for which any aircraft outside this circle is not know to the pilot. 

# Simulation Example
Likewise, we can test a trained or hardcoded policy in simulation. 
Each aircraft in this simulation is using the same policy, which was trained using DDPG in this case. 

https://user-images.githubusercontent.com/59975096/160887939-482ddfbc-6a68-4d0c-b47e-3c0e32852779.mp4

# Extra features
The following features are available in both the MDP and in simulation.
- Specify a spawn area. Aircraft are only able to spawn in this area.
  - Simulation default - Uniform within the boundary.
  - MDP default - Uniform in a circle of radius 1500 around the ego agent (note the ego agent is the agent we are training on). This spawn area is reduced to decrease training time, as each additional aircraft slows down the training process. Therefore, aircraft are forced to spawn near the ego agent.

- Specify a destination area. Aircraft destinations are guranteed to be within this area.
  - Simulation default - Uniform within the boundary.
  - MDP default - Uniform within the boundary. Note that aircraft who stray too far from the ego agent will also be deleted to reduce training time.

- Specify restricted airspaces. In essence, the boundary of a restricted airspace is converted into a row of aircraft, and each aircraft tries to avoid it. Therefore, it tries to avoid crossing into the restricted airspace.
  - Simulation default - None/Empty
  - MDP default - None/Empty

- Specify intermediate waypoints as a PathFinder object. Aircraft first travel to the nearest waypoint, then path find through the points and edges, which form a graph. The aircraft heads to the point nearest to its destination, and then finally to its destination. 
  - Simulation default - No waypoints. All aircraft head straight to their destination.
  - MDP default - No waypoints. All aircraft head straight to their destination.
 
Example simulation with spawn areas (green dotted circles), destination areas (blue dotted circles), and restricted areas (red solid circle).  

https://user-images.githubusercontent.com/59975096/160890064-1cedb140-a216-4890-8c16-a25b276cda10.mp4

Example simulation using waypoints. The waypoints consist of two circles of points. The outer circle moves counter clockwise, the inner circle moves clockwise. Moving from inner to outer circle is also allowed. 

https://user-images.githubusercontent.com/59975096/160890285-ab331624-75c2-4372-a6a8-626dfb4677bc.mp4


# Algorithms
This section of the repository contains various algorithms for solving the MDP. They are applied to the simulation for testing and viewing purposes. The following algorithms have been implemented:
- Basic - A hardcoded function that heads straight to its destination, and ignores other aircraft. 
- Sophisticated - A hardcoded function that balances heading straight to its destination and avoiding other aircraft using a weighted average. 
- DDPG - Trained on the MDP
- DQN - Trained on the MDP
- Tabular - Trained on the MDP
- PPO - Trained on the MDP
- TD3 - Trained on the MDP (note there is currently a bug in CircularArrayBuffers.jl, so TD3 only works on version 0.1.7. PPO only works on 0.1.10, so you must choose which one you prefer.)
- A2C - Trained on the MDP

Additional RL algorithms can be adopted from [ReinforcementLearningZoo](https://juliareinforcementlearning.org/docs/experiments/). For example, DDPG was taken from this example and adapted to our MDP via CollisionAvoidanceAlgorithms/LearningAlgs/DDPG.jl. It requires about 5 minutes of work assuming you are comfortable with both the algorithm and Julia itself. 

Note many scripts in this part of the project are customizable with "settings" variables at the top of the file.

To create the policies above, do the following:
1. Run CollisionAvoidanceAlgorithms/LearningAlgs/MainScript.jl. This will create the Experiments directory which stores the result, and run each training algoritm on the MDP. Each training algorithm is given 5 minutes of compute time, and then the resultant policy (Neural network or table), training data, and training graph are saved to their respective folder in Experiments. Note the hardcoded policies are also saved to their respective folder for consistency, although they are not trained policies. 
2. Run a script from CollisionAvoidanceAlgorithms/TestingAlgs/Examples/<something>. These scripts describe various situations and are customizeable:
   - Specify the max simulation time
   - Specify the file name that all relevant files will share for organizational purposes. Note these should be unique between scripts.
   - Specify if you want to record stats, video, or both
   - Specify the different spawn rates you want to test for stats
   - Specify the number of runs at each spawn rate for stats
   - Specify the spawnrate you want to use for the video
   - Specify the spawn area, destination area, restricted airspaces, and waypoints you want to use (if any)
   UniformAirspaceTest.jl is a good starting point. It uses the default spawn area, destination area, etc.
   4CirclesTest.jl shows you how to create spawn areas, destination areas, and restricted airspaces.
   WaypointsTest2.jl shows you how to specify more complicated waypoints, such as in the video above.
  
   Mix and match any of the customizations above as you please. There is a README in the TestingAlgs/Experiments directory for further reading.

# Implementation Details
The MDP and Simulation share all of their source code to gurantee consistency between them, and to aid in bug finding. Therefore the following details are shared between them, unless otherwise specified
1. Coordinate System - This supports the following: Cartesian coordinates, Polar coordinates, converting between them, and a Dynamics System. Dynamics represents a point with a position, velocity, and acceleration. At each timestep, acceleration is added to velocity, velocity is added to position, and in this way the point moves as you move through time.
2. Shapes - Shapes are used for spawn areas, destination areas, and restricted airspaces. Already implemented, you can use a rectangle or a circle with any internal distribution. There is also an interface specified (AbstractShape) if you would like to implement other types. A shape must implement the functions listed in AbstractShape in order to function with the ShapeManager. The ShapeManager is basically a list of Shapes. It allows you to find the nearest point on the edge of a shape to a given point. It also allows you to sample a point from the list of shapes which are proportionally sampled according to their weights. 
3. SpawnController - This object handles spawning aircraft. There is an abstract interface to implement new types of controllers. The default is the ConstantSpawnRateController, which consists of ShapeManagers for the source and destination as well as a spawnrate and if the destination is relative to the starting point or absolute. There is also queued controllers where aircraft first ensure the airspace directly above them is empty before taking off. If it is not, then the aircraft is added to a queue and tries again next timestep. The final version of the queue allows the priority weights to vary with the current time. 
4. PathFinder - An object used for waypoints. Is created using a list of Cartesian2 points, and edges connecting them. Note the edge values are a tuple of the indicies of their respective points in the list of points. PathFinder will return a list a Cartesian2Points given the points and edges you provide. This list is used as directions for aircraft, where they first head to the first point, then the second, and so on.
5. Airspace - Contains various objects used in creating an airspace. First, contains an aircraft which is made of a Dynamic (position, velocity, acceleration), a list of destinations (from a PathFinder), a maximum acceleration, maximum velocity, and relevant stats. An Airspace is effectively a list of aircraft plus the information needed for spawn areas, destination areas, pathfinders, restricted airspaces, etc. This also defines whether the airspace is being used as an MDP or simulation, which matters for only a few functions. 
6. MDP - This specifies the formal implementation of the MDP. Follows the interface given by ReinforcementLearning.jl. Notably, the state consists of:
    - Deviation - the relative direction, between -pi and pi, of my destination. 
    - My velocity - the velocity of the ego agent's aircraft. Normalized between 0 (not moving) and 1 (moving at max velocity)
    - Intruder exists? - 0.0 if there is no intruder nearby, 1.0 if there is an intruder nearby. The following values are all 0.0 if there is no intruder nearby. 
    - Distance to intruder - normalized between 0 (on top of us) and 1.0 (Detection radius max distance)
    - Angle of intruder - Relative angle to intruder from the ego aircraft's current heading, between -pi and pi
    - Heading of the intruder - Relative angle of the intruder's heading, between -pi and pi. 0 is the same direction as us, pi/2 is moving to our left, etc.
    - Velocity of intruder - Relative velocity of intruder, normalized between 0 and 1. 0 = Not moving from our perspective, 1 = moving at twice our maximum velocity (IE opposite directions). 
7. The action consists of: 
    - Change in velocity - controls linear acceleration (speed up, slow down)
    - Change in direction - controls angular acceleration (turn left, right)
  
Given that the above suffers from the curse of dimensionality for discrete functions, there are also modifed versions of the MDP:
  - Continuous state, continuous action - But linear acceleration is not allowed (reduces action space)
  - Continuous state, discrete action - Linear acceleration is not allowed. 5 discrete actions = Hard left, left, straight, right, hard right
  - Discrete state, discrete action - Linear acceleration is not allowed. Discretized state space and 5 discrete actions = Hard left, left, straight, right, hard right
  
# Final notes
- This MDP uses a single RNG for reproducibility, specified in constructors.
- Some rendering functions are adapted from [Sheng Li, Maxim Egorov, Mykel J. Kochenderfer](https://arxiv.org/pdf/1912.10146.pdf).

# Licensing
  ?
# Package Versions
The following versions are used (other versions _probably_ work too):
- Julia 1.6
- Distributions v0.25.19
- IntervalSets v0.5.3
- ReinforcementLearning v0.10.0
- ReinforcementLearningBase v0.9.7
- ReinforcementLearningZoo#findmyway-patch-7 <---- Note this branch fixed a bug with TD3. Without it, you wont be able to use TD3. This patch should be incorporated into v0.11 which has not been released yet.
- CircularArrayBuffers v0.1.10
- StatsBase v0.33.12
- Graphs v1.6.0
- PyPlot v2.10.0
- PyCall v1.92.3
- BSON v0.3.4
- ProgressMeter v1.7.1
                                                   
# Possible Next Steps
- Generate new stats such as time taken to reach destination, un-normalized distance, etc
- Add boundaries to count as NMAC or some other stat. Currently, boundaries are converted into a line of aircraft to avoid. However, there is not a stat to keep track of boundary violations. One should probably be added. 
- Create a to-scale simulation of some major city
                                                   
                                                   

