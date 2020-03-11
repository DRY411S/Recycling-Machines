--[[
	TODO: This file will contain extensions to data tables to allow support for mods
	Mods extend the vanilla Recycling Machines mod with additional:
		Crafting methods that need an equivalent recycling method or to be excluded from Recycling
		Prototype 'types' that extend the base
		Item groups (tabs in the player crafting menu) that need to appear in Recycling Machines
		subgroups that I may not want to handle in the mod
		locale (not handled here)
]]--

--[[
	TODO: Reintroduce this code lifted from its inline insertion in the mod
]]--

--[[
	Crafting methods

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
	Item group tabs
-- Item-group icons for Recycling
groups_supported =	{
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
                                -- Useful combinators
                                --
                                ["default"] = "__ZRecycling__/graphics/item-group/useful/clock.png",
					)
]]--

--[[
	Subgroups
local validsubgroups = {	
							-- Yuoki
							"y-raw-material",
						}
]]--

--[[
	Mod handling starts here
]]--
ignoredcrafts = {}
modsubgroups = {}
groups_supported = {}

--[[
	*** EXPERIMENTAL *** ADD all item groups,unconditionally ***
	*** If there are no recycling items in that group, then the tab does not display anyway ***
	*** MODS can overload other mods icons so need to test for this ***
	*** https://wiki.factorio.com/Types/IconSpecification ***
	*** DO VANILLA HERE BECAUSE OF THE ABOVE ***
]]--
for k,v in pairs(data.raw["item-group"]) do
	groups_supported[k] = {
							icon = v.icon,
							icon_size = v.icon_size,
							scale = v.scale,
							["shift"] = v.shift
						}
	if v.icons ~= nil then
		groups_supported[k].icons = {}
		for i,j in ipairs(v.icons) do
			groups_supported[k].icons[i] = j
		end
	end
end

-- Model
if mods["model"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Test locale	
end

-- Bob's Metals, Chemicals and Intermediates (bobplates)
if mods["bobplates"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["crafting-machine"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"distillery")
	table.insert(ignoredcrafts,"air-pump")
	table.insert(ignoredcrafts,"electrolysis")
	table.insert(ignoredcrafts,"chemical-furnace")
	table.insert(ignoredcrafts,"mixing-furnace")
	table.insert(ignoredcrafts,"void-fluid")
	table.insert(ignoredcrafts,"barrelling")
	-- Add types
	-- Add item-groups
	-- None for bobplates
	-- Test locale	
end

-- Bob's Modules (bobmodules)
if mods["bobmodules"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["electronics"] = "recycling-"
	craftingbeforeandafter["electronics-machine"] = "recycling-with-fluid"
	-- Ignore crafting methods
	-- None for bobmodules
	-- Add types
	-- None for bobmodules
	-- Add item-groups
	-- Test locale	
end

-- Bob's Greenhouse (bobgreenhouse)
if mods["bobgreenhouse"] ~= nil then
	-- Add crafting methods
	-- None for bobgreenhouse
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"bob-greenhouse")
	-- Add types
	-- None for bobgreenhouse
	-- Add item-groups
	-- None for bobgreenhouse
	-- Test locale	
end

-- All other Bob's mods should be supported now

--[[
	Angels
]]--

-- Angel's Refining
if mods["angelsrefining"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"barreling-pump")
	table.insert(ignoredcrafts,"liquifying")
	table.insert(ignoredcrafts,"filtering")
	table.insert(ignoredcrafts,"ore-sorting")
	table.insert(ignoredcrafts,"ore-sorting-t1")
	table.insert(ignoredcrafts,"ore-sorting-t1-5")
	table.insert(ignoredcrafts,"ore-sorting-t2")
	table.insert(ignoredcrafts,"ore-sorting-t3")
	table.insert(ignoredcrafts,"ore-sorting-t3-5")
	table.insert(ignoredcrafts,"ore-sorting-t4")
	table.insert(ignoredcrafts,"crystallizing")
	table.insert(ignoredcrafts,"water-treatment")
	table.insert(ignoredcrafts,"salination-plant")
	table.insert(ignoredcrafts,"washing-plant")
	table.insert(ignoredcrafts,"angels-water-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"fluids-refining")
	-- Test locale	
end

-- Angel's Petro Chemical Processing
if mods["angelspetrochem"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"petrochem-electrolyser")
	table.insert(ignoredcrafts,"advanced-chemistry")
	table.insert(ignoredcrafts,"petrochem-separation")
	table.insert(ignoredcrafts,"gas-refining")
	table.insert(ignoredcrafts,"steam-cracking")
	table.insert(ignoredcrafts,"petrochem-air-filtering")
	table.insert(ignoredcrafts,"angels-converter")
	table.insert(ignoredcrafts,"angels-chemical-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

-- Angel's Smelting
if mods["angelssmelting"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["pellet-pressing"] = "recycling-"
	craftingbeforeandafter["powder-mixing"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"blast-smelting")
	table.insert(ignoredcrafts,"induction-smelting")
	table.insert(ignoredcrafts,"strand-casting")
	table.insert(ignoredcrafts,"casting")
	table.insert(ignoredcrafts,"ore-processing")
	table.insert(ignoredcrafts,"chemical-smelting")
	table.insert(ignoredcrafts,"cooling")
	table.insert(ignoredcrafts,"sintering")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"fluids-smelting")
	-- Test locale	
end

-- Angel's Bio Processing
if mods["angelsbioprocessing"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["bio-processor"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"bio-processing")
	table.insert(ignoredcrafts,"angels-tree")
	table.insert(ignoredcrafts,"angels-arboretum")
	table.insert(ignoredcrafts,"angels-tree-temperate")
	table.insert(ignoredcrafts,"angels-tree-swamp")
	table.insert(ignoredcrafts,"angels-tree-desert")
	table.insert(ignoredcrafts,"seed-extractor")
	table.insert(ignoredcrafts,"temperate-farming")
	table.insert(ignoredcrafts,"desert-farming")
	table.insert(ignoredcrafts,"swamp-farming")
	table.insert(ignoredcrafts,"nutrient-extractor")
	table.insert(ignoredcrafts,"bio-pressing")
	table.insert(ignoredcrafts,"bio-refugium-fish")
	table.insert(ignoredcrafts,"bio-butchery")
	table.insert(ignoredcrafts,"bio-refugium-puffer")
	table.insert(ignoredcrafts,"bio-hatchery")
	table.insert(ignoredcrafts,"bio-refugium-biter")
	table.insert(ignoredcrafts,"bio-refugium-hogger")
	table.insert(ignoredcrafts,"angels-bio-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
--	table.insert(invalidsubgroups,"fluids-smelting")
	-- Test locale	
end

-- Angel's Industries
if mods["angelsindustries"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
	-- Test locale	
end

--[[
	Load the data structures that document all the types, item-groups, and item-subgrupds that exist in vanilla
	First add a table (for debug purposes of all the item-subgroups introduced by mods, then
	run some debug code to write into the log the identities of discovered protypes that the mod does not currently handle
]]--
require("lookups.vanilla")

-- Add modded item-subgroups for all supported item-groups
for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
	local matched = false
	groupname = subgroup.group
	for _,invalidsubgroup in pairs(invalidsubgroups) do
		if invalidsubgroup == subgroupname then
			matched = true
			break
		end
	end
	if not matched then
		for _,subname in pairs(vanillasubgroups) do
			if subname == subgroup.name then
				matched = true
				break
			end
		end
	end
	if not matched then
		for group,icon in pairs(groups_supported) do
			if groupname == group then
				matched = true
				table.insert(modsubgroups,subgroup.name)
				break
			end
		end
	end
end -- each subgroup

--[[
	*** DEBUG SECTION FROM HERE ***
	Identify whether there are new prototypes that this mod does not handle.
	If so, publish warnings in the log. These are not mod breaking,
	but good to know for future inclusion
]]--

-- Item-groups
for _, group in pairs(data.raw["item-group"]) do
	local matched = false
	for _, vanilla in pairs(vanillaitem_groups) do
		if group.name == vanilla then
			matched = true
			break
		end
	end
	if not matched then
		for modded,_ in pairs(groups_supported) do
			if group.name == modded then
				matched = true
				break
			end
		end
	end
	if not matched then
		log("Warning: Recycling Machines unsupported item-group: " .. group.name)
	end
end

--Subgroups
for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
	local matched = false
	groupname = subgroup.name
	for _,invalidsubgroup in pairs(invalidsubgroups) do
		if invalidsubgroup == subgroupname then
			matched = true
			break
		end
	end
	if not matched then
		for _, vanilla in pairs(vanillasubgroups) do
			if groupname == vanilla then
				matched = true
				break
			end
		end
	end
	if not matched then
		for _,subgroup in pairs(modsubgroups) do
			if groupname == subgroup then
				matched = true
				break
			end
		end
	end
	if not matched then
		log("Warning: Recycling Machines unsupported item-subgroup: " .. groupname)
	end
end -- each subgroup

-- Types
for name, this in pairs(data.raw) do
	local typefound = false
	for _,vanilla in pairs(vanillatypes) do
		if vanilla == name then
			typefound = true
			break
		end
	end
	if not typefound then
		log("Warning: Recycling Machines unsupported type: " .. name)
	end
end

--Crafting types
for _,recipe in pairs(data.raw.recipe) do
	if recipe.category ~= nil then
		local catfound = false
		for _,craft in pairs(vanillacrafts) do
			if recipe.category == craft then
				catfound = true
				break
			end
		end
		if not catfound then
			for craft, recycle in pairs(craftingbeforeandafter) do
				if recipe.category == craft then
					catfound = true
					break
				end
			end
		end
		if not catfound then
			for _,craft in pairs(ignoredcrafts) do
				if recipe.category == craft then
					catfound = true
					break
				end
			end
		end
		if not catfound then
			log("Warning: Recycling Machines unsupported craft: " .. recipe.category)
		end
	end
end