Building Generator Demo
=======================

By Alex Parrill initrd.gz@gmail.com

This is a 2D layered building generator demo for a game I am making. It's written in LuaJIT-flavored Lua,
and uses my luajit-glfw library. The demo isn't interactable; just start it and watch the building generate.

I developed this technique because I was unsatisfied with the (in my experience) most common solution of
stitching together pre-created sections together, which has multiple problems (primairly, the sections can
quickly get repeditive, and trying to fit sections together without overlap is hard). Instead, this technique
operates in reverse; instead of picking a type of room and trying to fit them all together, this demo generates
a bunch of generic rooms, then determines what type they are.

Procedure
---------

1. Randomly generate rectangular room placeholders in a grid.
2. Move the rooms down, so that they are standing on another room or the ground.
3. Create a node at every grid cell that is occupied by a room, keeping track of which room a node belongs to.
4. Form a graph of possible room links with those nodes. The demo builds a [relative neighbor graph](http://en.wikipedia.org/wiki/Relative_neighborhood_graph).
5. Traverse the graph to form the actual connections between rooms. The demo builds a minimal spanning tree.
6. Randomly re-add connections from the possible links graph to the actual connections graph, to build some loops.
7. Clean up the graph by removind edges that connect to the same room, then removing nodes that do not have edges.

That is the end of the demo, but the real game will go further:

8. Determine the purpose of each room, ex. dining room, entryway, treasure room.
9. Carve out overlapping terrain, and generate meshes for the building.
10. Generate furniture and other contents of each room based on its purpose.

Possible improvements
---------------------

### Overhangs

In step 2, the rooms are moved down until they hit the ground or another building. This can create an egregious
overhang if the room lands on another room on the far left or right. This can be solved one of two ways:

1. Slide the falling room off the opposite side of the support. This mimics what would happen in reality, and
   creates more realistic structures. Care must be taken, however, to avoid an infinite loop where a room tries
   to fall down a hole that doesn't fit it, and indefinitely slides between two supporting rooms.
2. Create a pillar on the opposite side of the room and generate it downwards. This creates a more fascinating
   structure.

### Better loop creation

In step 6, the connections to add to the room links were chosen randomly. This might create very short loops, which
are unrealistic. The demo will not connect two rooms to each other more than once, but this can be improved. For
example, before adding a connection, the generator could determine the minimum loop length with the connection
added, and if it's too small, discard it.

### Room Purposes

Determining each room's purpose still presents a challenge. The available purposes depend on the building type; a
house needs a bedroom, bathroom, kitchen, etc., while a dungeon should have more ominous room types, such as a
trapped hallway or an armory.

A naive approach would be to purely randomly assign rooms a purpose, perhaps discarding the configuration if it does
not match a criteria. This can frequently generate purpose configurations that don't make much sense; for example,
a treasure room right at the dungeon enterance.

Ideally, the implemented system should accept various constraints, yet still be random. Example constraints could be:

* the kitchen must be at most 2 cells away from a bathroom,
* gardens should be at ground level, and
* treasure rooms should be frequently (but not always) placed after a trapped hallway.

More research and design is needed before I can build such a system though.
