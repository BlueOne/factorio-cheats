local Table = require("Utils.Table")
local ProtUtils = require("Utils.Prototype")

local cliff_dummy_cfg = require("cliff_dummy_cfg")


if data then
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
    
    



-- Cliffs
--------------------------------------------------------------------------
Table.merge_inplace{data.raw.cliff.cliff, {
        flags = {"placeable-neutral", "placeable-player", "player-creation"},
        selectable_in_game = true
    }}

    data:extend{
        {
            type = "item",
            name = "cliff",
            icon = "__base__/graphics/icons/cliff-icon.png",
            icon_size = 32,
            flags = {"goes-to-quickbar"},
            subgroup = "terrain",
            order = "c[cliff]-a[cliff]",
            place_result = "cliff",
            stack_size = 100
        }
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
        ent.selection_box = {{-2, -2}, {2, 2}}
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
end