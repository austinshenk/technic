local path = technic.modpath.."/machines"

-- Machine registrations
dofile(path.."/common.lua")
dofile(path.."/alloy_furnace.lua")
dofile(path.."/electric_furnace.lua")
dofile(path.."/cables.lua")
dofile(path.."/solar_array.lua")
dofile(path.."/battery_box.lua")
dofile(path.."/grinder.lua")

-- Tiers
dofile(path.."/LV/init.lua")
dofile(path.."/MV/init.lua")
dofile(path.."/HV/init.lua")

dofile(path.."/switching_station.lua")
--dofile(path.."/supply_converter.lua")
dofile(path.."/other/init.lua")
if minetest.get_modpath("gloopores") then
	dofile(path.."/grinder_gloopores.lua")
end

