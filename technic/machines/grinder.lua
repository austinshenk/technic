
technic.grinder_recipes = {}

function technic.register_grinder_recipe(data)
	data.time = data.time or 3
	technic.grinder_recipes[data.input] = data
	if unified_inventory then
		unified_inventory.register_craft({
			type = "grinding",
			output = data.output,
			items = {data.input},
			width = 0,
		})
	end
end

-- Receive an ItemStack of result by an ItemStack input
function technic.get_grinder_recipe(itemstack)
	local src_item  = itemstack:to_table()
	if src_item == nil then
		return nil
	end
	local item_name = src_item.name
	if technic.grinder_recipes[item_name] then
		return technic.grinder_recipes[item_name]
	else
		return nil
	end
end


technic.register_grinder_recipe({input="default:stone",          output="default:sand"})
technic.register_grinder_recipe({input="default:cobble",         output="default:gravel"})
technic.register_grinder_recipe({input="default:gravel",         output="default:dirt"})
technic.register_grinder_recipe({input="default:desert_stone",   output="default:desert_sand"})
technic.register_grinder_recipe({input="default:iron_lump",      output="technic:iron_dust 2"})
technic.register_grinder_recipe({input="default:steel_ingot",    output="technic:iron_dust 1"})
technic.register_grinder_recipe({input="default:coal_lump",      output="technic:coal_dust 2"})
technic.register_grinder_recipe({input="default:copper_lump",    output="technic:copper_dust 2"})
technic.register_grinder_recipe({input="default:copper_ingot",   output="technic:copper_dust 1"})
technic.register_grinder_recipe({input="default:gold_lump",      output="technic:gold_dust 2"})
technic.register_grinder_recipe({input="default:gold_ingot",     output="technic:gold_dust 1"})
--technic.register_grinder_recipe({input="default:bronze_ingot",   output="technic:bronze_dust 1"})  -- Dust does not exist yet
--technic.register_grinder_recipe({input="home_decor:brass_ingot", output="technic:brass_dust 1"}) -- needs check for the mod
technic.register_grinder_recipe({input="moreores:tin_lump",      output="technic:tin_dust 2"})
technic.register_grinder_recipe({input="moreores:tin_ingot",     output="technic:tin_dust 1"})
technic.register_grinder_recipe({input="moreores:silver_lump",   output="technic:silver_dust 2"})
technic.register_grinder_recipe({input="moreores:silver_ingot",  output="technic:silver_dust 1"})
technic.register_grinder_recipe({input="moreores:mithril_lump",  output="technic:mithril_dust 2"})
technic.register_grinder_recipe({input="moreores:mithril_ingot", output="technic:mithril_dust 1"})
technic.register_grinder_recipe({input="technic:chromium_lump",  output="technic:chromium_dust 2"})
technic.register_grinder_recipe({input="technic:chromium_ingot", output="technic:chromium_dust 1"})


function technic.register_grinder(data)
	local tier = data.tier
	local ltier = string.lower(tier)
	local tube = {
		insert_object = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:add_item("src", stack)
		end,
		can_insert = function(pos, node, stack, direction)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			return inv:room_for_item("src", stack)
		end,
		connect_sides = {left=1, right=1, back=1, top=1, bottom=1},
	}

	local formspec =
		"invsize[8,10;]"..
		"list[current_name;src;3,1;1,1;]"..
		"list[current_name;dst;5,1;2,2;]"..
		"list[current_player;main;0,6;8,4;]"..
		"label[0,0;"..tier.." Grinder]"
	if data.upgrade then
		formspec = formspec..
			"list[current_name;upgrade1;1,4;1,1;]"..
			"list[current_name;upgrade2;2,4;1,1;]"..
			"label[1,5;Upgrade Slots]"
	end
	data.formspec = formspec

	minetest.register_node("technic:"..ltier.."_grinder", {
		description = tier.." Grinder",
		tiles = {"technic_"..ltier.."_grinder_top.png",  "technic_"..ltier.."_grinder_bottom.png",
			 "technic_"..ltier.."_grinder_side.png", "technic_"..ltier.."_grinder_side.png",
			 "technic_"..ltier.."_grinder_side.png", "technic_"..ltier.."_grinder_front.png"},
		paramtype2 = "facedir",
		groups = {cracky=2, tubedevice=1, tubedevice_receiver=1},
		technic = data,
		tube = tube,
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		on_construct = function(pos)
			local node = minetest.get_node(pos)
			local meta = minetest.get_meta(pos)
			local data = minetest.registered_nodes[node.name].technic
			meta:set_string("infotext", data.tier.." Grinder")
			meta:set_int("tube_time",  0)
			meta:set_string("formspec", data.formspec)
			local inv = meta:get_inventory()
			inv:set_size("src", 1)
			inv:set_size("dst", 4)
			inv:set_size("upgrade1", 1)
			inv:set_size("upgrade2", 1)
		end,
		can_dig = function(pos,player)
			local meta = minetest.get_meta(pos);
			local inv = meta:get_inventory()
			if not inv:is_empty("src") or not inv:is_empty("dst") or 
			   not inv:is_empty("upgrade1") or not inv:is_empty("upgrade2") then
				minetest.chat_send_player(player:get_player_name(),
						"Machine cannot be removed because it is not empty");
				return false
			else
				return true
			end
		end,
	})

	minetest.register_node("technic:"..ltier.."_grinder_active",{
		description = tier.." Grinder",
		tiles = {"technic_"..ltier.."_grinder_top.png",  "technic_"..ltier.."_grinder_bottom.png",
			 "technic_"..ltier.."_grinder_side.png", "technic_"..ltier.."_grinder_side.png",
			 "technic_"..ltier.."_grinder_side.png", "technic_"..ltier.."_grinder_front_active.png"},
		paramtype2 = "facedir",
		groups = {cracky=2, tubedevice=1, tubedevice_receiver=1, not_in_creative_inventory=1},
		legacy_facedir_simple = true,
		sounds = default.node_sound_wood_defaults(),
		technic = data,
		tube = tube,
		can_dig = function(pos,player)
			local meta = minetest.get_meta(pos)
			local inv = meta:get_inventory()
			if not inv:is_empty("src") or not inv:is_empty("dst") or
			   not inv:is_empty("upgrade1") or not inv:is_empty("upgrade2") then
				minetest.chat_send_player(player:get_player_name(),
						"Machine cannot be removed because it is not empty");
				return false
			else
				return true
			end
		end,
		-- These three makes sure upgrades are not moved in or out while the grinder is active.
		allow_metadata_inventory_put = function(pos, listname, index, stack, player)
			if listname == "src" or listname == "dst" then
				return stack:get_stack_max()
			else
				return 0 -- Disallow the move
			end
		end,
		allow_metadata_inventory_take = function(pos, listname, index, stack, player)
			if listname == "src" or listname == "dst" then
				return stack:get_stack_max()
			else
				return 0 -- Disallow the move
			end
		end,
		allow_metadata_inventory_move = function(pos, from_list, to_list, to_list, to_index, count, player)
			return 0
		end,
	})

	minetest.register_abm({
		nodenames = {"technic:"..ltier.."_grinder","technic:"..ltier.."_grinder_active"},
		interval = 1,
		chance   = 1,
		action = function(pos, node, active_object_count, active_object_count_wider)
			local data         = minetest.registered_nodes[node.name].technic
			local meta         = minetest.get_meta(pos)
			local eu_input     = meta:get_int(data.tier.."_EU_input")

			local machine_name   = data.tier.." Grinder"
			local machine_node   = "technic:"..string.lower(data.tier).."_grinder"
			local machine_demand = data.demand

			-- Setup meta data if it does not exist.
			if not eu_input then
				meta:set_int(data.tier.."_EU_demand", machine_demand[1])
				meta:set_int(data.tier.."_EU_input", 0)
				return
			end
		
			-- Power off automatically if no longer connected to a switching station
			technic.switching_station_timeout_count(pos, data.tier)

			local EU_upgrade, tube_upgrade = technic.handle_machine_upgrades(meta)
		
			-- State machine
			if eu_input < machine_demand[EU_upgrade+1] then
				-- Unpowered - go idle
				hacky_swap_node(pos, machine_node)
				meta:set_string("infotext", machine_name.." Unpowered")
			elseif eu_input >= machine_demand[EU_upgrade+1] then
				-- Powered	
				local inv    = meta:get_inventory()
				local empty  = inv:is_empty("src")
				
				technic.handle_machine_pipeworks(pos, tube_upgrade)

				local result = technic.get_grinder_recipe(inv:get_stack("src", 1))

				if empty or not result then
					hacky_swap_node(pos, machine_node)
					meta:set_string("infotext", machine_name.." Idle")
				else
					hacky_swap_node(pos, machine_node.."_active")
					meta:set_string("infotext", machine_name.." Active")

					meta:set_int("src_time", meta:get_int("src_time") + 1)
					if meta:get_int("src_time") >= result.time / data.speed then
						meta:set_int("src_time", 0)
						local result_stack = ItemStack(result.output)
						if inv:room_for_item("dst", result_stack) then
							srcstack = inv:get_stack("src", 1)
							srcstack:take_item()
							inv:set_stack("src", 1, srcstack)
							inv:add_item("dst", result_stack)
						end
					end
				end
			end
			meta:set_int(data.tier.."_EU_demand", machine_demand[EU_upgrade+1])
		end
	})

	technic.register_machine(tier, "technic:"..ltier.."_grinder",        technic.receiver)
	technic.register_machine(tier, "technic:"..ltier.."_grinder_active", technic.receiver)

end -- End registration

