
minetest.register_craft({
	output = 'technic:solar_array_mv 1',
	recipe = {
		{'technic:solar_array_lv', 'technic:solar_array_lv',  'technic:solar_array_lv'},
		{'technic:solar_array_lv', 'technic:mv_transformer',  'technic:solar_array_lv'},
		{'default:steel_ingot',    'technic:mv_cable_000000', 'default:steel_ingot'},
	}
})

technic.register_solar_array({tier="MV", power=50})

