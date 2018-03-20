local speed_cfg = require("default_speeds")



-- Speed Control
data:extend{
	{
		name = "speedctrl-used-speeds",
		type = "int-setting",
		setting_type = "runtime-per-user",
		default_value = #speed_cfg.defaults,
		order = "ab",
		minimum_value = 1,
		maximum_value = speed_cfg.num_speed_settings
	},
	{
		name = "speedctrl-default-speed-level",
		type = "int-setting",
		setting_type = "runtime-per-user",
		default_value = speed_cfg.default_speed_level,
		order = "ab",
		minimum_value = 1,
		maximum_value = speed_cfg.num_speed_settings
	},
	{
		name = "speedctrl-halt-speed-level",
		type = "int-setting",
		setting_type = "runtime-per-user",
		default_value = speed_cfg.halt_speed_level,
		order = "ab",
		minimum_value = 1,
		maximum_value = speed_cfg.num_speed_settings
	},
	{
		name = "speedctrl-show-realtime",
		type = "bool-setting",
		setting_type = "runtime-per-user",
		default_value = false,
		order = "ab",
	},
}


local setting_prototypes = {}
for i = 1, speed_cfg.num_speed_settings do
	local index = math.min(i, #speed_cfg.defaults)
	local setting = {
		type = "double-setting",
		name = "speedctrl-speed-" .. i,
		setting_type = "runtime-per-user",
		default_value = speed_cfg.defaults[index],
		order = "bb" .. index,
		minimum_value = 0.6,
		maximum_value = 60*20,
	}

	table.insert(setting_prototypes, setting)
end

data:extend(setting_prototypes)



data:extend{
	-- Deactivate Spawners etc.
	{
		type = "bool-setting",
		name = "cheats-inactive-spawners",
		default_value = false,
		order = "a_spawners",
		setting_type = "runtime-global",
	},

	-- UI
	{
		type = "bool-setting",
		name = "speedctrl-show-ui-on-init",
		default_value = false,
		order = "a_speed_ui",
		setting_type = "runtime-per-user",
	},
}

