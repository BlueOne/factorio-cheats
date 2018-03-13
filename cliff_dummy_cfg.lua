local cliff_cfg = {
    ["straight-cliff"] = {
        "west_to_east",
        "north_to_south",
        "east_to_west",
        "south_to_north"
    },
    ["inner-corner-cliff"] = {
        "west_to_south",
        "north_to_west",
        "east_to_north",
        "south_to_east"
    },
    ["outer-corner-cliff"] = {
        "west_to_north",
        "north_to_east",
        "east_to_south",
        "south_to_west"
    },
    ["inner-entrance-cliff"] = {
        "west_to_none",
        "north_to_none",
        "east_to_none",
        "south_to_none"
    },
    ["outer-entrance-cliff"] = {
        "none_to_west",
        "none_to_north",
        "none_to_east",
        "none_to_south"
    }
}

return cliff_cfg