Includes the following functionality:

Cliff Editing
=============
Can switch cliff entities to dummy entities and back via hotkeys. Dummy entities can be rotated properly and fit into blueprints.

Deactivate Biters
=================
Deactivates entities of type unit (biters), unit-spawner (biter spawner) and all turrets when the mod is added to the game and when they are built.

Entity Teleportation
====================
Shift+Arrow Key will teleport an entity one meter in the direction, not checking for collision.

Surface Stepping
================
Shift+Mouse4, Shift+Mouse5 will move the player one index up or down in the list of currently active surfaces. Shift+G will regenerate all resources on the map, except oil which is bugged currently. The command `/newsurface` will create a new surface using the map generation settings of the current surface. `deletesurface` will delete the current surface.

Zoom Hotkeys
============
Mouse4 and Mouse5 will zoom in and out quite far.

Calculate Technology costs
==========================
The command `/calc` calculates the cost of the given technologies and their prerequisites. For example `/calc {"rocket-silo", "concrete", "electric-energy-accumulators-1", "solar-energy", "fluid-handling", "electric-engine", "advanced-material-processing-2", "logistics", "fluid-handling" }` will output the minimal amount of science packs needed to complete the game.
