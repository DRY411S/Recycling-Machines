-- variables used in data and control luas
-- to ensure consistency without hardcoding
require("constants")
local rec_prefix = constant_rec_prefix

--Set the recycle ratio. The user can enable a trigger mod to choose what they want
-- Default to 100% if they disabled all triggers
-- Set to the highest value if they enabled more than one
if dry411smods == nil then
	recycleratio = 100
elseif dry411smods.recycling == nil then
	recycleratio = 100
else
	recycleratio = 0
	if dry411smods.recycling.recycleratio10 then
		recycleratio = 10
	end
	if dry411smods.recycling.recycleratio20 then
		recycleratio = recycleratio + 20
	end
	if dry411smods.recycling.recycleratio40 then
		recycleratio = recycleratio +  40
	end
	if dry411smods.recycling.recycleratio50 then
		recycleratio = recycleratio +  50
	end
	-- 60 and 80 issued at 0.12.30 as absolutes, not adds
	-- Description says 'sets' not 'adds'
	if dry411smods.recycling.recycleratio60 then
		recycleratio = 60
	end
	if dry411smods.recycling.recycleratio80 then
		recycleratio = 80
	end
end
if recycleratio > 100 then recycleratio = 100 end	


-- Unused by code. These were the vanilla sub-groups found in development, left here for reference. Mods may produce others
local validsubgroups = {	
							-- "recycling-machine",
							-- "module",
							-- "logistic-network",
							-- "gun",
							-- "transport",
							-- "barrel",
							-- "equipment",
							-- "production-machine",
							-- "defensive-structure",
							-- "circuit-network",
							-- "energy-pipe-distribution",
							-- "inserter",
							-- "extraction-machine",
							-- "belt",
							-- "energy",
							-- "smelting-machine",
							-- "intermediate-product",
							-- "storage"
						}

-- These are the subgroups that cannot be recycled
local invalidsubgroups = {	
							"raw-material",
							"terrain",
							"fluid-recipes",
						}

-- These are the vanilla groups. Those in the table that are not commented have no recipes attached to them that we want to reverse
local invalid_item_groups = {
							--"combat",
							"enemies",
							"environment",
							"fluids",
							--"intermediate-products",
							--"logistics",
							"other",
							--"production",
							"signals",
							-- Unsupported bob's mod item-groups
							--"bob-fluid-products",
							}

-- These are the types found in development
-- Mods may invent more
-- TODO: Maybe let people decide what they want to recycle to unclutter the menus
local validtypes =	{	
						"ammo",
						"armor",
						"capsule",
						--"fluid",
						"gun",
						"item",
						"mining-tool",
						"module",
						"repair-tool",
						"tool"
					}
					
-- A table of mods (and vanilla) where I've tested and provide a 'recycling' item-group icon
-- All other mods are shown in the default 'Recycling' item-group
local groups_supported =	{
								["default"] = "__ZRecycling__/graphics/item-group/recycling.png",
								["Recycling"] = "__ZRecycling__/graphics/item-group/recycling.png",
								-- Vanilla
								["logistics"] = "__ZRecycling__/graphics/item-group/logistics.png",
								["production"] = "__ZRecycling__/graphics/item-group/production.png",
								["combat"] = "__ZRecycling__/graphics/item-group/military.png",
								["intermediate-products"] = "__ZRecycling__/graphics/item-group/intermediate-products.png",
								-- Bob's Mods
								["bob-logistics"] = "__ZRecycling__/graphics/item-group/boblogistics/logistics.png",
								["bob-fluid-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/fluids.png",
								["bob-resource-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/resources.png",
								["bob-intermediate-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/intermediates.png",
								["void"] = "__ZRecycling__/graphics/item-group/bobplates/void.png",
								["bob-gems"] = "__ZRecycling__/graphics/item-group/bobplates/diamond-5.png",
								["bobmodules"] = "__ZRecycling__/graphics/item-group/bobmodules/module.png",
								-- DyTech
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
								-- 5dim
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
								-- Yuoki
								["yuoki"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-ind-icon.png",
								["yuoki-energy"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-energy.png",
								["yuoki-atomics"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-atomics-icon.png",
								["yuoki_liquids"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-liquids.png",
							}

local recycling_groups = {}
local recycling_subgroups = {}
local function build_groups()
	-- build local item-groups and subgroups as candidates for recycling
	local invalid
	for _, group in pairs(data.raw["item-group"]) do
		invalid = false
		for _, invalid_item_group in pairs(invalid_item_groups) do
			if group.name == invalid_item_group then
				invalid = true
				break
			end
		end
		if invalid == false then
			local newicon = groups_supported["default"]
			for nextname,nextpath in pairs(groups_supported) do
				-- error(nextname .. nextpath)
				if group.name == nextname then
					newicon = nextpath
					--error("newicon = " .. newicon)
					break
				end
			end
			
			local newgroup = {
								type = "item-group",
								icon = newicon,
								--icon = group.icon,
								inventory_order = group.inventory_order,
								hidden = false,
								--name = rec_prefix .. group.name,
								name = group.name,
								order = "z" .. group.order .. "z"
							}
			table.insert(recycling_groups,newgroup)
		end
	end
	-- debug local callback = {} -- to build a table for dumping during debugging
	invalid = false
	--error(serpent.block(recycling_groups) .. serpent.block(recycling_subgroups) .. serpent.block(rev_recipes))
	--error(serpent.block(data.raw["item-subgroup"]))
	for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
		-- It's valid unless we find a reason that it's not
		invalid = false
		groupname = subgroup.group
		-- debug table.insert(callback,{subgroupname,groupname})
		if invalid == false then
			--error(serpent.block(subgroup))
			for _, invalid_item_group in pairs(invalid_item_groups) do
				if groupname == invalid_item_group then
					invalid = true
					--error("Subgroup: " .. serpent.block(subgroup) .. " invalid_item_group: " .. invalid_item_group .. " groupname:" .. groupname)
					break
				else
					--error("Subgroup: " .. serpent.block(subgroup) .. " invalid_item_group: " .. invalid_item_group .. " groupname:" .. groupname)
				end
			end
			--error("Subgroup: " .. serpent.block(subgroup) .. " invalid: " .. invalid .. " groupname:" .. groupname)
		end
		-- debug table.insert(callback,{groupname,invalid})
		if invalid == false then
			--error(serpent.block(subgroup))
			for _,invalidsubgroup in pairs(invalidsubgroups) do
				if invalidsubgroup == subgroupname then
					invalid = true
					--error("Subgroup: " .. serpent.block(subgroup) .. " invalid_item_group: " .. invalid_item_group .. " groupname:" .. groupname)
					break
				else
					--error("Subgroup: " .. serpent.block(subgroup) .. " invalid_item_group: " .. invalid_item_group .. " groupname:" .. groupname)
				end
			end
		end
		-- debug table.insert(callback,{subgroupname,invalid})
		if invalid == false then
			local newsubgroup = {
								type = "item-subgroup",
								name = subgroup.name,
								group = subgroup.group,
								order = subgroup.order
							}
			--error(serpent.block(newsubgroup))
			table.insert(recycling_subgroups,newsubgroup)
		end
	end
--error(serpent.block(callback))
--error(serpent.block(recycling_subgroups))
end

-- To add the recycycling prefix when we're done with them 'as is'
local function create_reverse_groupsandsubgroups()
	for _,group in pairs(recycling_groups) do
		group.name = rec_prefix .. group.name
	end
	for _,subgroup in pairs(recycling_subgroups) do
		subgroup.name = rec_prefix .. subgroup.name
		subgroup.group = rec_prefix .. subgroup.group
	end
end

-- Accepted crafting categories
-- These are the categories which are accepted in assembling machines
-- This mod only recycles things that can be assembled in machines
-- TODO: Why are engine-units the only thing that I can find that use advanced-crafting?
local craftingbeforeandafter =	{
									["crafting"] = "recycling-",
									["advanced-crafting"] = "recycling-",
									["crafting-with-fluid"] = "recycling-with-fluid"
								}

-- Where the reversed recipes will be stored
local rev_recipes = {}
local function add_reverse_recipe(item,recipe,newcategory)

	-- Pick up icon, subgroup, and order from item
	-- Check hidden

	-- There are 5 result-scenarios
	-- 1 The result_count is missing, in which case it is 1
	-- 2 There is a single 'result'. This is our reversed recipe ingredient
	-- 3 There is a 'results' with only 1 result that isn't the default type i.e. not an 'tem'
	-- 4 There is a 'results' with only 1 result that IS the default type but has just been coded that way by a modder)
	-- 5 There is a 'results' with more than one product produced by the recipe
	-- The 3rd and the 5th scenarios are things we cannot recycle. The recipe results are our ingredients
	-- We support only 1 ingredient (non-fluid)
	
	local result
	local can_recycle = true
	local product_count = 0
	local result_count = recipe.result_count
	if not result_count then
		result_count = 1
	end
	if recipe.result then
		result = recipe.result
		product_count = 1
	else
		-- There's no result so there must be results, even if there's only 1
		for i,v in pairs(recipe.results) do
			product_count = product_count + 1
			result = v.name
			result_count = v.amount and v.amount or 1
			if v.type and ( v.type == 1 or v.type == "fluid" )then -- 0 is 'item' 1 is 'fluid'
				can_recycle = false
				break
			end
		end
	end
	if can_recycle == true and product_count == 1 then
		local rec_name = rec_prefix .. result
		local newgroup = rec_prefix .. data.raw["item-subgroup"][item.subgroup].group
		local recycle_count = 0
		-- Build the ingredients into results
		local rev_results = {}
		local newrow
		for k, v in pairs(recipe.ingredients) do
			recycle_count = recycle_count + 1
			newrow = {}
			-- Examples of different ingredient formats
			-- {"engine-unit", 1},
			-- {type="fluid", name= "lubricant", amount = 2},
			-- bobs-mod replacements are like
			-- {amount = 3, name = "basic-circuit-board", type = "item" } 
			-- Nightmare
			
			-- TODO: Need code to deal with stack-sizes
			-- If not v.name, this implies that the elements have no 'friendly' key, are item types,
			-- and are just in table in name, amount order
			if not v.name then
				newrow.name = v[1]
				newrow.amount = v[2]
			else
				newrow.type = v.type
				newrow.name = v.name
				newrow.amount = v.amount
			end
			-- Apply recycle ratio
			newrow.amount = math.ceil((newrow.amount*recycleratio)/100)
			
			-- Just add it, if it's a fluid
			if newrow.type and newrow.type == "fluid" then
				table.insert(rev_results,newrow)
			else
				-- If the result amounts are greater than the stack_size we need to limit out to stack_size
				-- data.raw.item doesn't work we need its type.
				local stack_size = nil
				for _,group  in pairs(data.raw) do
					for _,nextitem in pairs(group) do
						if nextitem.name == newrow.name then
							stack_size = nextitem.stack_size
							if stack_size then
								break
							end
						end
					end
					if stack_size then
						break
					end
				end
				
				if stack_size then
					local swopamount = newrow.amount
					while swopamount > stack_size do
						newrow.amount = stack_size
						swopamount = swopamount - stack_size
						if newrow.type then
							table.insert(rev_results,newrow)
						else
							table.insert(rev_results,{newrow.name,newrow.amount})
						end
					end
					
					if swopamount ~= 0 then
						newrow.amount = swopamount
						if newrow.type then
							table.insert(rev_results,newrow)
						else
							table.insert(rev_results,{newrow.name,newrow.amount})
						end
					end
				end
			end
		end
		-- Build the results into ingredients
		local ingredients = {}
		ingredients[1] = result
		ingredients[2] = result_count
		local theicon = item.icon
		if not theicon then
			theicon = "__base__/graphics/icons/" .. result .. ".png"
		end
		-- Assign the category to force a recycling machine based on the number of results
		if newcategory ~= "recycling-with-fluid" then
			local recyclesuffix = "1"
			if recycle_count >= 5 then
				recyclesuffix = "3"
			elseif recycle_count >= 3 then
				recyclesuffix = "2"
			end
			newcategory = newcategory .. recyclesuffix
		end
		local new_recipe =
		{
			type = "recipe",
			name = rec_name,
			-- enabled is initially false and made true in the event handler
			enabled = false,
			hidden = false,
			category = newcategory,
			ingredients = {ingredients},
			results = rev_results,
			energy_required = recipe.energy_required,
			-- main_product = "",
			group = newgroup,
			subgroup = rec_prefix .. item.subgroup,
			order = item.order,
			icon = theicon
		}
		
		table.insert(rev_recipes,new_recipe)
		
	end -- can_recycle

end -- function


--
-- MAIN CODE STARTS HERE
--
-- a flag for this recipe if it is invalid for recycling
local invalid

-- Build Groups and Subgroups that look like they will be recyclable
build_groups()
-- error(serpent.block(recycling_groups) .. serpent.block(recycling_subgroups))
-- error(serpent.block(recycling_subgroups))

-- for all validtypes
for _,validtype in pairs(validtypes) do
	-- For all 'item' prototypes
	for name, item in pairs(data.raw[validtype]) do

		--error(serpent.block(item))
		local recipe = data.raw.recipe[name]
		
		-- Assume we have an invalid recipe
		invalid = true
		
		local newcategory
		-- May not be a recipe, for example the machine gun on a vehicle
		if recipe then
			-- Only handle recipes where the category is nil or is produced in an assembling machine
			invalid = true
			newcategory = recipe.category
			if not newcategory then
				newcategory = "crafting"
			end
			for before,after in pairs(craftingbeforeandafter) do
				if newcategory == before then
					newcategory = after
					invalid = false
					break
				end
			end
			-- Special case for batteries
			if invalid == true and recipe.name == "battery" then
				newcategory = "recycling-with-fluid"
				invalid = false
			end
			
			-- Special case for Created Alien Artifacts mod. We don't want to recycle artefacts into circuits!
			if recipe.name == "superconducting-alien-artifact" then
				invalid = true
			end

			-- Special case for barrels that are empty but in an assembling machine being filled
			-- Or outside an assembling machine, full of crude-oil
			-- We only recycle empty barrels
			if recipe.name == "fill-crude-oil-barrel" or recipe.name == "empty-crude-oil-barrel" then
				invalid = true
			end

			if invalid == false then
				-- We have a valid item and recipe
				-- Just need to make sure that the item is in one of our sub-groups
				-- Assume it isn't
				invalid = true
				--error(serpent.block(item) .. serpent.block(recipe))
				for _,validsubgroup in pairs(recycling_subgroups) do
					--error(serpent.block(item) .. serpent.block(validsubgroup))
					if validsubgroup.name == item.subgroup then
						invalid = false
						-- error(serpent.block(item) .. serpent.block(validsubgroup))
						break -- valid item found
					end
				end
			end
		end
		if invalid == false then
			-- The 'item' contains useful things we need to construct the reverse recipe
			-- It may be armor, gun, item, module etc.
			-- Make the recipe
			--error(serpent.block(item) .. serpent.block(recipe))
			add_reverse_recipe(item,recipe,newcategory)
		end 
	end
end

-- Recipes all done, Create new subgroups and groups
create_reverse_groupsandsubgroups()
-- Add the new groups, new subgroups and reverse recipes to raw data
data:extend(recycling_groups)
data:extend(recycling_subgroups)
data:extend(rev_recipes)

-- Call for debugging only. Dump local tables in factorio-current.log
-- Stops game. Remove comment if you want the dump
--error(serpent.block(data.raw.item))
--error(serpent.block(recycling_groups) .. serpent.block(recycling_subgroups) .. serpent.block(data.raw.recipe) .. serpent.block(rev_recipes))
--error(serpent.block(recycling_groups))
--error(serpent.block(recycling_subgroups))
--error(serpent.block(data.raw.recipe))
--error(serpent.block(rev_recipes))