
-- Scenario Tools
------------------------------------------------------------------------------

local cliff_dummy_cfg = require("cliff_dummy_cfg")
local Table = require("Utils.Table")
local Event = require("stdlib.event.event")



-- TODO: Everything below Zoom is untested!
-- TODO: Merge game speed hotkeys into the mod



-- Cliff Editing
------------------------------------------------------------------------------
-- Change cliffs to more easily editable dummy entities and vice versa with hotkeys.

local dummy_to_cliff_orientation = {}
local cliff_orientation_to_dummy = {}

for name, orientations in pairs(cliff_dummy_cfg) do
    dummy_to_cliff_orientation[name] = {}
    for i, s in pairs(orientations) do
        s = s:gsub("_", "-")
        dummy_to_cliff_orientation[name][i*2 - 2] = s
        cliff_orientation_to_dummy[s] = {name, i*2 - 2}
    end
end

local function replace_dummies(surface)
    for name, _ in pairs(dummy_to_cliff_orientation) do
        for _, ent in pairs(surface.find_entities_filtered{name=name}) do
            surface.create_entity{
                name="cliff",
                position={ent.position.x, ent.position.y - 0.5},
                force="neutral",
                cliff_orientation = dummy_to_cliff_orientation[ent.name][ent.direction]
            }
            ent.destroy()
        end
    end
end

local function replace_cliffs(surface, area)
    for _, ent in pairs(surface.find_entities_filtered{name="cliff", area=area}) do
        local data = cliff_orientation_to_dummy[ent.cliff_orientation]
        surface.create_entity{
            name = data[1],
            direction = data[2],
            position = {ent.position.x, ent.position.y},
            force = "player",
        }
        ent.destroy()
    end
end


script.on_event("replace-dummies", function(event)
    local player = game.players[event.player_index]
    replace_dummies(player.surface)

    global.cliff_editing_players = global.cliff_editing_players or {}
    if global.cliff_editing_players[event.player_index] then
        global.cliff_editing_players[event.player_index] = nil
    end
end)

script.on_event("replace-cliffs", function(event)
    local player = game.players[event.player_index]
    global.cliff_editing_players = global.cliff_editing_players or {}
    if not global.cliff_editing_players[event.player_index] then
        global.cliff_editing_players[event.player_index] = true
    end
end)

script.on_nth_tick(30, function(event)
    for player_index, _ in pairs(global.cliff_editing_players or {}) do
        local player = game.players[player_index]
        local p = player.position
        local r = 30
        local box = {{p.x - r, p.y - r}, {p.x + r, p.y + r}}
        replace_cliffs(player.surface, box)
    end
end)





-- Deactivate Entities
------------------------------------------------------------------------------
-- Deactivate certain entities as soon as they enter the game or the mod is added.

local inactive_types_default = {"unit", "unit-spawner", "turret", "fluid-turret", "electric-turret", "ammo-turret"}
global.inactive_types = global.inactive_types or inactive_types_default

local function deactivate_entities(surface, area)
    for _, t in pairs(global.inactive_types) do
        for _, ent in pairs(surface.find_entities_filtered{type=t, area=area}) do
            ent.active = false
        end
    end
end

Event.register(defines.events.on_tick, function()
    if not global.entities_deactivated then
        for _, surface in pairs(game.surfaces) do
            deactivate_entities(surface)
        end
        global.entities_deactivated = true
    end
end)


Event.register(defines.events.on_built_entity, function(event)
    local entity = event.created_entity
    if Table.find(entity.type, global.inactive_types) then
        entity.active = false
    end
end)

Event.register(defines.events.on_chunk_generated, function(event)
    deactivate_entities(event.surface, event.area)
end)




-- Entity Teleportation
------------------------------------------------------------------------------
-- Move selected Entity with shift+arrow keys.
-- Inspired by picker extended, which checks for collision. Here, we explicitly dont check for collision.

global.last_moved = global.last_moved or {}
local function move_player_selected(player, vector)
    local ent = player.selected
    if ent then
        global.last_moved[player.index] = ent
        ent.teleport({ent.position.x + vector[1], ent.position.y + vector[2]})
    else
        ent = global.last_moved[player.index]
        if ent and ent.valid then
            ent.teleport({ent.position.x + vector[1], ent.position.y + vector[2]})
        end
    end
end


for k, v in pairs({left={-1, 0}, right={1, 0}, up={0, -1}, down={0, 1}}) do
    Event.register("move-entity-" .. k, function(event)
        local player = game.players[event.player_index]
        move_player_selected(player, v)
    end)
end



-- Surface Manipulation
------------------------------------------------------------------------------
-- Hotkeys for stepping between surfaces. Command for surface creation and deletion. Hotkey to regenerate resources of surface.

local function reset_resources(surface)
	local r = 20
	for _, ent in pairs(surface.find_entities_filtered{area={{-r*32, -r*32}, {r*32, r*32}}, type="resource"}) do
		ent.destroy()
	end
	local entities = {"coal", "copper-ore", "iron-ore", "stone", "crude-oil", "uranium-ore"}
	local chunks = {}
	for x=-r, r do
		for y=-r, r do
			chunks[#chunks + 1] = {x, y}
		end
	end
	surface.regenerate_entity(entities, chunks)
	for _, ent in pairs(surface.find_entities_filtered{name="electric-mining-drill"}) do
		surface.create_entity{name=ent.name, position=ent.position, direction=ent.direction,force=ent.force}
		ent.destroy()
	end
end

local function reset_surfaces()
	local surfaces = {}
	for _, player in pairs(game.players) do
		if not surfaces[player.surface.index] then
			game.print(player.surface.name)
			reset_resources(player.surface)
			surfaces[player.surface.index] = true
		end
	end
end

local function shift_surface(player, step)
	if #game.surfaces <= 1 or step == 0 then return end

	local sign = (step > 0) and 1 or -1
	local index = player.surface.index
	for _=1, step / sign do
		repeat
			index = (index + step - 1) % #game.surfaces + 1
		until game.surfaces[index] and game.surfaces[index].valid and not (global.shift_excluded and global.shift_excluded[index])
	end
	player.teleport(player.position, game.surfaces[index])
end

commands.add_command("newsurface", "Create new surface. Uses map gen settings of current surface.", function (event)
    local player = game.players[event.player_index]
    local surface = game.create_surface("surface " .. math.random(2^32), player.surface.map_gen_settings)
    if not event.parameter or event.parameter == "" then
        surface.always_day = true
    end
end)


global.surface_to_delete = nil
global.surface_delete_tick = nil
commands.add_command("deletesurface", "Delete the surface. ", function(event)
    local surface = game.players[event.player_index].surface
    if surface.name ~= global.surface_to_delete then
        if surface.name ~= "nauvis" then
            game.print("Deleting surface " .. surface.name .. " in 60 seconds. Repeat the command on the same surface to abort.") 
            global.surface_to_delete = surface.name
            global.surface_delete_tick = game.tick + 60*60
        else
            game.print("Cannot delete surface Nauvis!")
        end
    else
        game.print("Aborting deletion of " .. surface.name)
        global.surface_delete_tick = nil
        global.surface_to_delete = nil
    end
end)

Event.register(defines.events.on_tick, function()
    if global.surface_delete_tick and game.tick > global.surface_delete_tick then
        game.delete_surface(global.surface_to_delete)
        global.surface_to_delete = nil
        global.surface_delete_tick = nil
    end
end)

commands.add_command("resetsurfaces", "Regenerate resources on active surfaces.", reset_surfaces)

script.on_event("surface-up", function (event)
	shift_surface(game.players[event.player_index], 1)
end)
script.on_event("surface-down", function (event)
	shift_surface(game.players[event.player_index], -1)
end)



-- Zoom Hotkeys
------------------------------------------------------------------------------

script.on_event("more-zoom", function (event)
	if not global.zoom then global.zoom = {} end
	if not global.zoom[event.player_index] then global.zoom[event.player_index] = 0 end
	if global.zoom[event.player_index] < 20 then
		global.zoom[event.player_index] = global.zoom[event.player_index] + 1
	end
	game.players[event.player_index].zoom = (1/2)^(global.zoom[event.player_index] / 3)
end)
script.on_event("less-zoom", function (event)
	if not global.zoom then global.zoom = {} end
	if not global.zoom[event.player_index] then global.zoom[event.player_index] = 0 end
	if global.zoom[event.player_index] > -20 then
		global.zoom[event.player_index] = global.zoom[event.player_index] - 1
	end
	game.players[event.player_index].zoom = (1/2)^(global.zoom[event.player_index] / 3)
end)




-- Calculate Technology Cost
------------------------------------------------------------------------------

local function tech_calc(techs)
    if type(techs) == "string" then
		techs = {techs}
    end

    local original_requirements = Table.deepcopy(techs)
	local all_techs = {}
	local costs = {}

    while #techs > 0 do
		local tech = game.technology_prototypes[techs[1]]
		table.remove(techs, 1)
		if not all_techs[tech.name] then
			all_techs[tech.name] = true
			if tech.research_unit_ingredients  then
				local count = tech.research_unit_count
				for _, ingredient in pairs(tech.research_unit_ingredients) do
					if not costs[ingredient.name] then costs[ingredient.name] = {count=0, time=0} end
					costs[ingredient.name].count = costs[ingredient.name].count + count * ingredient.amount
					costs[ingredient.name].time = costs[ingredient.name].time + tech.research_unit_energy * count / 60
				end
			end

            if tech.prerequisites then
                Table.concat_lists{techs, tech.prerequisites}
			end
		end
	end

	local s = "All necessary Technologies: "
	for name, v in pairs(all_techs) do
		if v then
			s = s .. name .. ", "
		end
	end
	game.print(s)

	s = "Original Requirements: "
	for name, v in pairs(original_requirements) do
		if v then
			s = s .. name .. ", "
		end
	end
	game.print(s)
	for name, amount in pairs(costs) do
		game.print(name .. ": " .. amount.count .. " in " .. amount.time .. " sec." )
	end
end

commands.add_command("calc", "Calculate Technology costs. Example: /calc {\"automobilism, concrete\"}", function(event)
    local t = loadstring(event.parameter)
    tech_calc(t)
end)
--[[
	 /calc {
		 "rocket-silo",
		 "concrete",
		 "electric-energy-accumulators-1",
		 "solar-energy",
		 "effect-transmission",
		 "fluid-handling",
		 "logistics-2",
		 "automobilism",
		 "electric-engine",
    }
--]]
