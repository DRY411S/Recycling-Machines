-- variables used in data and control luas
require("constants")

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
							-- bob's mods
							--"bob-alien-resource",
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
-- Maybe let people decide what they want to recycle to unclutter the menus
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
-- All other mods are shown in the default item-group
local groups_supported =	{
								["default"] = "__ZRecycling__/graphics/item-group/recycling.png",
								["Recycling"] = "__ZRecycling__/graphics/item-group/recycling.png",
								["logistics"] = "__ZRecycling__/graphics/item-group/logistics.png",
								["production"] = "__ZRecycling__/graphics/item-group/production.png",
								["combat"] = "__ZRecycling__/graphics/item-group/military.png",
								["intermediate-products"] = "__ZRecycling__/graphics/item-group/intermediate-products.png",
								["bob-logistics"] = "__ZRecycling__/graphics/item-group/boblogistics/logistics.png",
								["bob-fluid-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/fluids.png",
								["bob-resource-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/resources.png",
								["bob-intermediate-products"] = "__ZRecycling__/graphics/item-group/bobelectronics/intermediates.png",
								["void"] = "__ZRecycling__/graphics/item-group/bobplates/void.png",
								["bob-gems"] = "__ZRecycling__/graphics/item-group/bobplates/diamond-5.png",
								["bobmodules"] = "__ZRecycling__/graphics/item-group/bobmodules/module.png",
							}

local recycling_groups = {}
local recycling_subgroups = {}
local function build_groups()
	-- build groups and subgroups as candidates for recycling
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
								inventory_order = group.inventory_order,
								hidden = false,
								--name = rec_prefix .. group.name,
								name = group.name,
								order = "z" .. group.order .. "z"
							}
			table.insert(recycling_groups,newgroup)
		end
	end
	-- debug local callback = {}
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
								--name = rec_prefix .. subgroup.name,
								--group = rec_prefix .. subgroup.group,
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
			if v.type and ( v.type ~= 0 or v.type ~= "item" )then -- 0 is 'item' 1 is 'fluid'
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
		-- if result == "basic-mining-drill" then
			-- error(serpent.block(recipe.ingredients))
		-- end
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
			if recycleratio > 1 then
				recycleratio = 1
			end
			newrow.amount = math.ceil(newrow.amount*recycleratio)
			
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
					table.insert(rev_results,newrow)
				end
				
				-- -- Crop the amount if it exceeds the stack_size
				-- if stack_size then
					-- newrow.amount = math.min(stack_size,newrow.amount)
				-- -- else
					-- -- error("Result: " .. newrow.name .. " has no stack_size")
				-- end
				if swopamount ~= 0 then
					newrow.amount = swopamount
					table.insert(rev_results,newrow)
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
			main_product = "",
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
--error(serpent.block(recycling_groups) .. serpent.block(recycling_subgroups) .. serpent.block(rev_recipes))
--error(serpent.block(recycling_groups))