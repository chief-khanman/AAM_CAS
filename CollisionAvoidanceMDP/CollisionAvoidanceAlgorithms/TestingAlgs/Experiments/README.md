# There are currently 5 experiments that attempt to isolate a single change in the airspace. The goal is to investigate how this 1 change affects the airspace.

1. The first experiment attempts to isolate how the destination impacts the airspace. In the first simulation "1.UniformSquare", there is a single 4000x4000
square as the source and destination. In the second "1.2Squares", there are 2 squares. The first is the spawn square which is again 4000x4000. The second is 
the destination square, also 4000x4000. As a result of this structure, the aircraft always have a destination to the right. This means all aircraft are moving
in the same direction. 


https://user-images.githubusercontent.com/59975096/166259228-d2cf587e-ba50-476d-8363-f4cdd172a694.mp4


https://user-images.githubusercontent.com/59975096/166259259-9d2e2bf0-de08-4ca2-a136-ff30d0502bec.mp4


2. The second experiment investigates how boundaries affect the airspace. In the first simulation "2.2Squares", there are 2 squares of size 4000x4000, one of 
which is the source of aircraft and the other is the destination. In between, there is a 2000m gap. Aircraft spawn in the left and move to the right. 
In the second simulation "2.2SquaresWithBoundary", the startand destination squares are the same, except a circular boundary has been added between the 2 squares. 
Finally, in the third simulation "2.2SquaresWithBoundaryAndWaypoints", 2 waypoints have been added, 1 on each side of the boundary, which aims to encourage aircraft 
to go "wide" around the restricted airspace instead of directly next to it. 


https://user-images.githubusercontent.com/59975096/166259296-ce885c7f-8b06-4f72-80d9-cae196b630e5.mp4



https://user-images.githubusercontent.com/59975096/166259310-ca91b845-86ad-4575-b84c-8d530116cd49.mp4



https://user-images.githubusercontent.com/59975096/166259319-f6997291-abb6-4ea9-be86-cf1e66e891e0.mp4



3. The third experiment attempts to investigate if a grid of waypoints can reduce NMACs. The first simulation "3.UniformFree" has a large square with aircraft flying freely.
The second simulation "3.UniformWaypoints" has the same square, except a grid of waypoints is overlayed on top. This allows the aircraft to follow a grid, which
mimics roads, instead of flying wherever they want. 


https://user-images.githubusercontent.com/59975096/166259334-ca2085dc-58b4-4849-96e1-06a5aefff06a.mp4



https://user-images.githubusercontent.com/59975096/166259349-75d9e1c9-988e-4ad6-8d5c-64214ed874d6.mp4


4. The fourth experiment aims to investigate if the size of the airspace matters or if policies are scalable. The first simulation "4.UniformSmall" is a single small
square as the start and end point. The second simulation "4.UniformBig" is exactly the same except the square is much bigger.


https://user-images.githubusercontent.com/59975096/166259358-586de255-b49a-43b2-bb24-cdc208d47b8e.mp4


https://user-images.githubusercontent.com/59975096/166263736-1a7fb6b1-5726-4b24-af12-26e0bcfdb3ef.mp4



5. The fifth experiment attempts to investigate how queueing may impact the environment. The first simulation "5.2Squares" has 2 squares, 1 start and 1 destination. The second
simulation "5.Queues" has those same squares broken into 4 parts. Each part has a single small point as the spawn point or destination. The aircraft are spawned via
a queueing system such that they cannot spawn if there is another aircraft within 150 meters of the spawn point. If they are unable to spawn, they must wait in queue in 
order to spawn. The single point of spawn and destination is designed to represent if there was a large structure, similiar to a parking garage but for aircraft, where all
aircraft have to start from and go to. The spawn rate of the single point depends on the size of the area it is "covering". In this case, the total spawnrate is the same
because the spawn area is the same. But, every aircraft can only spawn from the single point instead of anywhere. 


https://user-images.githubusercontent.com/59975096/166259382-ebc55587-bf34-4123-9830-e6b5db3cf677.mp4



https://user-images.githubusercontent.com/59975096/166259390-e2c65ab0-cb67-4fdf-90f1-69f4b386a494.mp4

6. In progess. This spawner can change the spawnrate for a given area based on the current time. This allows you to simulate rushhour cycles, etc. 



https://user-images.githubusercontent.com/59975096/166719739-9da73ed0-d815-4be9-b8b2-d79558556f90.mp4



https://user-images.githubusercontent.com/59975096/166719731-5fa830fd-df0c-486a-8e6e-fd435877afb8.mp4






