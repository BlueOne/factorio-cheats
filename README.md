Loose Collection of cheats I've needed at some point. Most of the tools here were used for scenario creation or planning of speedruns or TAS. Use in conjunction with creative mode and picker extended.


Includes the following functionality:

Cliff Editing
=============
Can switch cliff entities to dummy entities and back via hotkeys. Dummy entities can be rotated properly and fit into blueprints. Will be obsolete when the pipette function is added to the editor.


Deactivate Biters
=================
Deactivates (freeze) entities of type unit (biters), unit-spawner (biter spawner) and all turrets when the mod is added to the game and when they are built. Has mod setting, default is off.

Entity Teleportation
====================
Shift+Arrow Key will teleport an entity one meter in the direction, not checking for collision.

Surface Stepping
================
Shift+Mouse4, Shift+Mouse5 will move the player one index up or down in the list of currently available surfaces. The command `/newsurface` will create a new surface using the map generation settings of the current surface. `deletesurface` will delete the current surface.

Resource Reset
==============
Shift+G will regenerate all resources on the map, except oil which is bugged (bug has been reported and assigned). 

Zoom Hotkeys
============
Mouse4 and Mouse5 will zoom in and out quite far. Since player.zoom in the API is write-only, this may behave a bit unintuitively.

Calculate Technology costs
==========================
The command `/calc` calculates the cost of the given technologies and their prerequisites. For example `/calc return {"rocket-silo", "concrete", "electric-energy-accumulators-1", "solar-energy", "fluid-handling", "electric-engine", "advanced-material-processing-2", "logistics", "fluid-handling" }` will output the minimal amount of science packs needed to complete the game.

Speed Hotkeys
=============
Change game speed via hotkey (Comma and period). Configurable with mod settings. Default settings will change speed by multiplying roughly by 3 every step. Will show current game speed and position of selected entity in UI.




Warning, this mod includes a command which uses loadstring on a command parameter, so every player in principle can use any console command if this mod is in the game, even if you only allowed admins to use console commands.
