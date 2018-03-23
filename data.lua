local Table = require("Utils.Table")
local ProtUtils = require("Utils.Prototype")

local cliff_dummy_cfg = require("cliff_dummy_cfg")


if not data then error("data.lua imported outside data stage.") end

-- Inputs
--------------------------------------------------------------------------

data:extend{
    {
        type = "custom-input",
        name = "replace-cliffs",
        key_sequence = "SHIFT + H"
    },
    {
        type = "custom-input",
        name = "replace-dummies",
        key_sequence = "H"
    },
}

for k, v in pairs({left="LEFT", right="RIGHT", up="UP", down="DOWN"}) do
    data:extend{
        {
            type = "custom-input",
            name = "move-entity-" .. k,
            key_sequence = "SHIFT + " .. v
        },
    }
end

data:extend{
    {
        type = "custom-input",
        name = "more-zoom",
        key_sequence = "Mouse button 4",
    },
    {
        type = "custom-input",
        name = "less-zoom",
        key_sequence = "Mouse button 5",
    },
    {
        type = "custom-input",
        name = "surface-up",
        key_sequence = "CONTROL + Mouse button 4",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "surface-down",
        key_sequence = "CONTROL + Mouse button 5",
        consuming = "all"
    },
    {
        type = "custom-input",
        name = "reset-resources",
        key_sequence = "CONTROL + G"
    },
} 



-- Game Speed
data:extend{
	{
		type = "custom-input",
		name = "speedctrl-halt",
		key_sequence = "Shift + Comma"
	},
	{
		type = "custom-input",
		name = "speedctrl-speed-up",
		key_sequence = "PERIOD"
	},
	{
		type = "custom-input",
		name = "speedctrl-speed-down",
		key_sequence = "COMMA"
	},
} 






-- Cliffs
--------------------------------------------------------------------------
Table.merge_into_first{data.raw.cliff.cliff, {
    flags = {"placeable-neutral", "placeable-player", "player-creation"},
    selectable_in_game = true
}}

data:extend{
    ProtUtils.generic_item("cliff", {flags={"goes-to-quickbar"}, order="c[cliff]-a[cliff]", icon="__base__/graphics/icons/cliff-icon.png"})
}


local function cliff_pictures(key)
    local pictures = data.raw.cliff.cliff.orientations[key].pictures[1]
    for _, layer in pairs(pictures.layers) do
        layer.frame_count = 1
    end
    return pictures
end
local function add_cliff_dummy(name, a, b, c, d)
    local ent, item, _ = ProtUtils.new_entity(name, "chemical-plant", "assembling-machine")
    ent.collision_box = {{-1.9, -1.9 }, {1.9, 1.9}}
    ent.selection_box = {{-1.9, -1.9}, {1.9, 1.9}}
    ent.icon = "__base__/graphics/icons/cliff-icon.png"
    item.icon = "__base__/graphics/icons/cliff-icon.png"

    local recipe = ProtUtils.generic_recipe(name)

    ent.animation = {
        north = cliff_pictures(a),
        east = cliff_pictures(b),
        south = cliff_pictures(c),
        west = cliff_pictures(d),
    }

    data:extend{
        ent,
        item,
        recipe
    }

end


for name, orientations in pairs(cliff_dummy_cfg) do
    add_cliff_dummy(name, orientations[1], orientations[2], orientations[3], orientations[4])
end


-- Make enemy entities placeable and mineable
--------------------------------------------------------------------------

local enemy_entities = {unit = {"small-biter", "medium-biter", "big-biter", "behemoth-biter", "small-spitter", "medium-spitter", "big-spitter", "behemoth-spitter", },
["turret"] = {"small-worm", "medium-worm", "big-worm"}, ["unit-spawner"] = {"biter-spawner", "spitter-spawner"}}

-- Creative mode doesnt load if all turrets have placement items.
-- TODO: Report that bug when I have internet again.
local turret = Table.deepcopy(data.raw.turret["small-worm-turret"])
turret.name = "foobar-turret"
local unit = Table.deepcopy(data.raw.unit["small-biter"])
unit.name = "foobar-biter"
local spawner = Table.deepcopy(data.raw["unit-spawner"]["biter-spawner"])
spawner.name = "foobar-spawner"
data:extend{turret, unit, spawner}

for type_name, entities in pairs(enemy_entities) do
    for _, name in pairs(entities) do
        local entity_name = name
        if type_name == "turret" then entity_name = name .. "-turret" end
        local icon = "__base__/graphics/icons/" .. name .. ".png"
        if name == "spitter-spawner" then icon = "__base__/graphics/icons/biter-spawner.png" end
        data:extend{
            ProtUtils.generic_item(entity_name, {flags={"goes-to-quickbar"}, order="c[" .. entity_name .. "]", icon=icon}),
            ProtUtils.generic_recipe(entity_name)
        }
        local ent = ProtUtils[type_name](entity_name)
        ent.flags = {"placeable-neutral", "placeable-player", "player-creation"}
        ent.minable = {hardness = 0.2, mining_time = 0.5, result = entity_name}
    end
end
