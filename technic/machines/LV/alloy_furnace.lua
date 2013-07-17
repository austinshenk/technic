-- LV Alloy furnace
--[[
minetest.register_craft({
	output = 'technic:coal_alloy_furnace',
	recipe = {
		{'default:brick', 'default:brick', 'default:brick'},
		{'default:brick', '',              'default:brick'},
		{'default:brick', 'default:brick', 'default:brick'},
	}
})
--]]

-- FIXME: kpoppel: I'd like to introduce an induction heating element here...
minetest.register_craft({
	output = 'technic:lv_alloy_furnace',
	recipe = {
		{'default:brick',       'default:brick',        'default:brick'},
		{'default:brick',       '',                     'default:brick'},
		{'default:steel_ingot', 'default:copper_ingot', 'default:steel_ingot'},
	}
})

technic.register_alloy_furnace({tier="LV", cook_time=6, demand={600}})


--------------------------------------------------
-- coal driven alloy furnace. This uses no EUs:
--------------------------------------------------
--[[
coal_alloy_furnace_formspec =
	"size[8,9]"..
	"label[0,0;Alloy Furnace]"..
	"image[2,2;1,1;default_furnace_fire_bg.png]"..
	"list[current_name;fuel;2,3;1,1;]"..
	"list[current_name;src;2,1;1,1;]"..
	"list[current_name;src2;3,1;1,1;]"..
	"list[current_name;dst;5,1;2,2;]"..
	"list[current_player;main;0,5;8,4;]"

minetest.register_node("technic:coal_alloy_furnace", {
	description = "Alloy Furnace",
	tiles = {"technic_coal_alloy_furnace_top.png", "technic_coal_alloy_furnace_bottom.png", "technic_coal_alloy_furnace_side.png",
		"technic_coal_alloy_furnace_side.png", "technic_coal_alloy_furnace_side.png", "technic_coal_alloy_furnace_front.png"},
	paramtype2 = "facedir",
	groups = {cracky=2},
	legacy_facedir_simple = true,
	sounds = default.node_sound_stone_defaults(),
	on_construct = function(pos)
		local meta = minetest.env:get_meta(pos)
		meta:set_string("formspec", coal_alloy_furnace_formspec)
		meta:set_string("infotext", "Alloy Furnace")
		local inv = meta:get_inventory()
		inv:set_size("fuel", 1)
		inv:set_size("src", 1)
		inv:set_size("src2", 1)
		inv:set_size("dst", 4)
	end,
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		if not (inv:is_empty("fuel") or inv:is_empty("dst") or inv:is_empty("src") or inv:is_empty("src2") )then
			return false
			end
		return true
	end,
})

minetest.register_node("technic:coal_alloy_furnace_active", {
	description = "Alloy Furnace",
	tiles = {"technic_coal_alloy_furnace_top.png", "technic_coal_alloy_furnace_bottom.png", "technic_coal_alloy_furnace_side.png",
		"technic_coal_alloy_furnace_side.png", "technic_coal_alloy_furnace_side.png", "technic_coal_alloy_furnace_front_active.png"},
	paramtype2 = "facedir",
	light_source = 8,
	drop = "technic:coal_alloy_furnace",
	groups = {cracky=2, not_in_creative_inventory=1},
	legacy_facedir_simple = true,
	sounds = default.node_sound_stone_defaults(),
	can_dig = function(pos,player)
		local meta = minetest.env:get_meta(pos);
		local inv = meta:get_inventory()
		if not (inv:is_empty("fuel") or inv:is_empty("dst") or inv:is_empty("src") or inv:is_empty("src2") )then
			return false
			end
		return true
	end,
})

minetest.register_abm({
	nodenames = {"technic:coal_alloy_furnace","technic:coal_alloy_furnace_active"},
	interval = 1,
	chance = 1,

	action = function(pos, node, active_object_count, active_object_count_wider)
		local meta = minetest.env:get_meta(pos)
		for i, name in pairs({
				"fuel_totaltime",
				"fuel_time",
				"src_totaltime",
				"src_time"
		}) do
			if meta:get_string(name) == "" then
				meta:set_float(name, 0.0)
			end
		end

		local inv    = meta:get_inventory()
		local recipe = nil

		-- Get what to cook if anything
		local srcstack = inv:get_stack("src", 1)
		if srcstack then src_item1=srcstack:to_table() end
		
		local src2stack = inv:get_stack("src2", 1)
		if src2stack then src_item2=src2stack:to_table() end
		
		if src_item1 and src_item2 then
		   recipe = technic.get_alloy_recipe(src_item1,src_item2)
		end

		local was_active = false

		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
		   was_active = true
		   meta:set_float("fuel_time", meta:get_float("fuel_time") + 1)
		   meta:set_float("src_time", meta:get_float("src_time") + 1)
		   if recipe and meta:get_float("src_time") == 6 then
		      -- check if there's room for output in "dst" list
		      local dst_stack = { name=recipe.dst_name, count=recipe.dst_count}
		      if inv:room_for_item("dst",dst_stack) then
			 -- Take stuff from "src" list
			 srcstack:take_item(recipe.src1_count)
			 inv:set_stack("src", 1, srcstack)
			 src2stack:take_item(recipe.src2_count)
			 inv:set_stack("src2", 1, src2stack)
			 -- Put result in "dst" list
			 inv:add_item("dst",dst_stack)
		      else
			 print("Furnace inventory full!") -- Silly code...
		      end
		      meta:set_string("src_time", 0)
		   end
		end
		
		if meta:get_float("fuel_time") < meta:get_float("fuel_totaltime") then
		   local percent = math.floor(meta:get_float("fuel_time") /
					   meta:get_float("fuel_totaltime") * 100)
		   meta:set_string("infotext","Furnace active: "..percent.."%")
		   hacky_swap_node(pos,"technic:coal_alloy_furnace_active")
		   meta:set_string("formspec",
				   "size[8,9]"..
				      "label[0,0;Electric Alloy Furnace]"..
				      "image[2,2;1,1;default_furnace_fire_bg.png^[lowpart:"..
				      (100-percent)..":default_furnace_fire_fg.png]"..
				   "list[current_name;fuel;2,3;1,1;]"..
				   "list[current_name;src;2,1;1,1;]"..
				   "list[current_name;src2;3,1;1,1;]"..
				   "list[current_name;dst;5,1;2,2;]"..
				   "list[current_player;main;0,5;8,4;]")
		   return
		end

		-- FIXME: Make this look more like the electrical version.
		-- This code refetches the recipe to see if it can be done again after the iteration
		srcstack = inv:get_stack("src", 1)
		if srcstack then src_item1=srcstack:to_table() end
		srcstack = inv:get_stack("src2", 1)
		if srcstack then src_item2=srcstack:to_table() end
		if src_item1 and src_item2 then
		   recipe = technic.get_alloy_recipe(src_item1,src_item2)
		end

		if recipe==nil then
		   if was_active then
		      meta:set_string("infotext","Furnace is empty")
		      hacky_swap_node(pos,"technic:coal_alloy_furnace")
		      meta:set_string("formspec", coal_alloy_furnace_formspec)
		   end
		   return
		end

		-- Next take a hard look at the fuel situation
		local fuel = nil
		local fuellist = inv:get_list("fuel")

		if fuellist then
		   fuel = minetest.get_craft_result({method = "fuel", width = 1, items = fuellist})
		end

		if fuel.time <= 0 then
		   meta:set_string("infotext","Furnace out of fuel")
		   hacky_swap_node(pos,"technic:coal_alloy_furnace")
		   meta:set_string("formspec", coal_alloy_furnace_formspec)
		   return
		end

		meta:set_string("fuel_totaltime", fuel.time)
		meta:set_string("fuel_time", 0)

		local stack = inv:get_stack("fuel", 1)
		stack:take_item()
		inv:set_stack("fuel", 1, stack)
	     end,
     })
--]]

