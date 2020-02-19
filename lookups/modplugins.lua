--[[
	TODO: This file will contain extensions to data tables to allow support for mods
	Mods extend the vanilla Recycling Machines mod with additional:
		Crafting methods that need an equivalent recycling method
		Prototype 'types' that extend the base
		subgroups that I may not want to handle in the mod
		Item groups (tabs in the player crafting menu) that need to appear in Recycling Machines
		locale (not handled here)
]]--

--[[
	TODO: Reintroduce this code lifted from its inline inserttion in the mod
]]--

--[[
	Crafting methods
-- Special crafting for Bob's Mods
craftingbeforeandafter["electronics"] = "recycling-"
craftingbeforeandafter["electronics-machine"] = "recycling-with-fluid"
craftingbeforeandafter["crafting-machine"] = "recycling-"

-- Special crafting for Yuoki Industries
-- TODO: Maybe constrain this to allow recycling of things that can only be assembled
-- TODO: Wait for feedback
craftingbeforeandafter["yuoki-alien-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-archaeology-wash"] = "recycling-with-fluid"
craftingbeforeandafter["yuoki-atomics-recipe"] = "recycling-"
craftingbeforeandafter["y-crushing-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-fame-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-formpress-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-raw-material-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-repair-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-stargate-recipe"] = "recycling-"
craftingbeforeandafter["yuoki_trader_ultimate"] = "recycling-"
craftingbeforeandafter["yuoki-watergen-recipe"] = "recycling-with-fluid"
craftingbeforeandafter["yuoki-wonder-recipe"] = "recycling-"
]]--	

--[[
	New types
local validtypes =	{	

						-- Yuoki (is also used by vanilla but there are no recipes)
						"container",
                        -- "item-with-tags" used in Useful Combinators
                        "item-with-tags"
					}
--]]
					
--[[
	Subgroups
local invalidsubgroups = {	
							-- Yuoki
							"y-raw-material",
							-- Bob's Mods
							"bob-gems-ore",
							"bob-gems-raw",
							"bob-gems-cut",
							"bob-gems-polished",
						}
]]--

--[[
	Item group tabs
-- Item-group icons for Recycling
groups_supported =	{
								-- Bob's Mods
								--
								["bob-logistics"] = "__ZRecycling__/graphics/item-group/boblogistics/logistics.png",
								["bob-fluid-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/fluids.png",
								["bob-resource-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/resources.png",
								["bob-intermediate-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/intermediates.png",
								["void"] = "__ZRecycling__/graphics/item-group/bobplates/void.png",
								["bob-gems"] = "__ZRecycling__/graphics/item-group/bobplates/diamond-5.png",
								["bobmodules"] = "__ZRecycling__/graphics/item-group/bobmodules/module.png",
								--
								-- DyTech
								--
								["dytech-combat"] = "__ZRecycling__/graphics/item-group/DyTech-Core/combat.png",
								["dytech-energy"] = "__ZRecycling__/graphics/item-group/DyTech-Core/energy.png",
								["dytech-gem"] = "__ZRecycling__/graphics/item-group/DyTech-Core/gem.png",
								["dytech-inserter"] = "__ZRecycling__/graphics/item-group/DyTech-Core/inserter.png",
								["dytech-intermediates"] = "__ZRecycling__/graphics/item-group/DyTech-Core/intermediates.png",
								["dytech-machines"] = "__ZRecycling__/graphics/item-group/DyTech-Core/machines.png",
								["dytech-modules"] = "__ZRecycling__/graphics/item-group/DyTech-Core/modules.png",
								["dytech-metallurgy"] = "__ZRecycling__/graphics/item-group/DyTech-Core/metallurgy.png",
								["dytech-nuclear"] = "__ZRecycling__/graphics/item-group/DyTech-Core/nuclear.png",
								["dytech-invisible"] = "__ZRecycling__/graphics/item-group/DyTech-Core/danger.png",
								--
								-- 5dim
								--
								["inserters"] = "__ZRecycling__/graphics/item-group/5dim_core/automatization.png",
								["energy"] = "__ZRecycling__/graphics/item-group/5dim_core/energy.png",
								["logistic"] = "__ZRecycling__/graphics/item-group/5dim_core/logistic.png",
								["mining"] = "__ZRecycling__/graphics/item-group/5dim_core/mining.png",
								["module"] = "__ZRecycling__/graphics/item-group/5dim_core/module.png",
								["nuclear"] = "__ZRecycling__/graphics/item-group/5dim_core/enuclear.png",
								["transport"] = "__ZRecycling__/graphics/item-group/5dim_core/transport.png",
								["trains"] = "__ZRecycling__/graphics/item-group/5dim_core/trains.png",
								["decoration"] = "__ZRecycling__/graphics/item-group/5dim_core/decorative.png",
								["vehicles"] = "__ZRecycling__/graphics/item-group/5dim_core/vehicles.png",
								["armor"] = "__ZRecycling__/graphics/item-group/5dim_core/armor.png",
								["plates"] = "__ZRecycling__/graphics/item-group/5dim_core/plates.png",
								["intermediate"] = "__ZRecycling__/graphics/item-group/5dim_core/intermediate.png",
								["defense"] = "__ZRecycling__/graphics/item-group/5dim_core/defense.png",
								["liquid"] = "__ZRecycling__/graphics/item-group/5dim_core/liquids.png",
								--
								-- Yuoki
								--
								["yuoki"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-ind-icon.png",
								["yuoki-energy"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-energy.png",
								["yuoki-atomics"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-atomics-icon.png",
								["yuoki_liquids"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-liquids.png",
                                -- 
                                -- Angels
                                --
                                ["resource-refining"] = "__ZRecycling__/graphics/item-group/angels/ore-refining.png",
                                ["water-treatment"] = "__ZRecycling__/graphics/item-group/angels/water-treatment-group.png",
                                ["angels-fluid-control"] = "__ZRecycling__/graphics/item-group/angels/heavy-pump-group.png",
                                ["petrochem-refining"] = "__ZRecycling__/graphics/item-group/angels/petrochem.png",
                                ["bio-processing"] = "__ZRecycling__/graphics/item-group/angels/algae-farm-group.png",
                                ["bio-processing-alien"] = "__ZRecycling__/graphics/item-group/angels/algae-farm-group.png",
                                ["angels-smelting"] = "__ZRecycling__/graphics/item-group/angels/blast-furnace-group.png",
                                ["angels-casting"] = "__ZRecycling__/graphics/item-group/angels/induction-furnace-group.png",
                                --
                                -- Useful combinators
                                --
                                ["default"] = "__ZRecycling__/graphics/item-group/useful/clock.png",
					)
]]--

