-- variables used in data and control luas
require("constants")

local function add_reverse_recipe(item,recipe,newcategory,rev_recipes)

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
		-- game.player.print("Recipe: " .. rec_name)
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
			-- Nightmare
			
			-- If not v.name, this implies that the elements have no 'friendly' key, are item types,
			-- and are just in table in name, amount order
			if not v.name then
				newrow.name = v[1]
				newrow.amount = v[2]
			else
				newrow.type = "fluid"
				newrow.name = v.name
				newrow.amount = v.amount
			end
			-- Apply recycle ratio
			-- TODO: Need a test for if some joker has made it >= 1
			newrow.amount = math.ceil(newrow.amount*recycleratio)
			
			table.insert(rev_results,newrow) 
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
			energy_required = recipe.energy,
			main_product = "",
			group = "Recycling",
			subgroup = "rec-" .. item.subgroup,
			-- TODO: order = "b[fluid-chemistry]-c[solid-fuel-from-light-oil]", -- :: string [R]	Order string. Need to inject 'recycled-'
			icon = theicon
		}
		-- game.player.print("Reversed Recipe: " .. new_recipe.name)
		
		table.insert(rev_recipes,new_recipe)
		
	end -- can_recycle

end -- function

-- Unused by code. These were the sub-groups found in development, left here for reference. Mods may produce others
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

-- These are the invalid subgroups discovered in development
-- They are wood, coal, and plate
-- And anything that produces a fluid out of refineries or chemical plants
local invalidsubgroups = {	
							"raw-material",
							"terrain",
							"fluid-recipes"
						}

-- These are the types found in development
-- Mods may invent more
-- If they are commented out, they aren't recycled
-- Currently that's Ammunition and Capsules on the basis that they could explode during recycling
-- And you can never have too much ammo and combat robots right?
-- And honestly, turning fluids back into crude-oil isn't realistic.
local validtypes =	{	
						--"ammo",
						"armor",
						--"capsule",
						--"fluid",
						"gun",
						"item",
						"mining-tool",
						"module",
						"repair-tool",
						"tool"
					}

-- Acepted crafting categories
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

-- a flag for this recipe if it is invalid for recycling
local invalid
--
-- MAIN CODE STARTS HERE
--
-- For valid 'item' prototypes only
for _,validtype in pairs(validtypes) do
	-- For every 'item' in that valid prototype
	for name, item in pairs(data.raw[validtype]) do
		-- We need to do this because mods may have added new recipes with the same name
		-- for the same item, in different categories
		-- TODO: Assuming not
		-- for _,recipe in pairs(data.raw.recipe[name]) do
		local recipe = data.raw.recipe[name]
		
		-- Assume we have a valid recipe
		invalid = false
		
		local newcategory
		-- May not be a recipe, for example the machine gun on a vehicle
		if not recipe then
			invalid = true
		else
			-- TODO: Create and assign item menu-sub-groups on the fly
			
			-- Only handle recipes where the category is nil or is produced in an assembling machine
			newcategory = recipe.category
			if not newcategory then
				newcategory = "crafting"
			end
			-- Assume recipe is invalid unless it is in one of the accepted craftings
			-- This isn't the end of it. Further categorisation required
			invalid = true
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

			-- We have an item and a recipe
			-- Just need to make sure that the item isn't in on of the unsupported sub-groups
			for _,invalidsubgroup in pairs(invalidsubgroups) do
				if invalidsubgroup == item.subgroup then
					invalid = true
					break -- invalid item found
				end
			end
		end	
			if invalid == false then
				-- The 'item' contains useful things we need to construct the reverse recipe
				-- It may be armor, gun, item, module etc.
				-- Do the work here
				add_reverse_recipe(item,recipe,newcategory,rev_recipes)
			end 
		-- end: See TODO
	end
end

-- All done
-- Add the reverse recipes to raw data
data:extend(rev_recipes)

-- TODO: Add the new sub-groups too
-- data:extend(new_subgroups)

-- Call for debugging only. Dump table in factorio-current.log
-- Stops game. Remove comment if you want the dump
-- error(serpent.block(data.raw))