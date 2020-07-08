-- variables used in data and control luas
-- to ensure consistency without hardcoding
require("constants")
local rec_prefix = constant_rec_prefix

--
-- LOCAL DATA
--

-- These are the subgroups that cannot be recycled
invalidsubgroups = {	
							-- "raw-material", -- enabled only for batteries  fixes https://github.com/DRY411S/Recycling-Machines/issues/50
							-- "terrain", -- enabled only for cliff-explosives https://github.com/DRY411S/Recycling-Machines/issues/62
							"fluid-recipes",
                            -- New in 0.15
                            "raw-resource",
                            "fill-barrel",
                            "empty-barrel",
						}

-- These are the vanilla groups. Those in the table that are not commented out are the ones we support
-- Fix for: https://github.com/DRY411S/Recycling-Machines/issues/70
-- We now list valid item groups not invalid ones
valid_item_groups = {
							"combat",
							--"enemies",
							--"environment",
							--"fluids",
							"intermediate-products",
							"logistics",
							--"other",
							"production",
							--"signals",
							--"effects",
							}

--[[
	These are the valid types associated with crafting
	If they are commented out, they are not applicable for crafting in machines
	Mods may invent more, but not likely
]]--
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
						"tool",
						-- Introduced in factorio v0.13
						"rail-planner",
						-- Introduced in factorio v0.15
						"item-with-entity-data",
					}


-- Accepted crafting categories
-- These are the categories which are accepted in assembling machines
-- This mod only recycles things that can be assembled in machines
craftingbeforeandafter =	{}

-- Crafting for Vanilla
craftingbeforeandafter["crafting"] = "recycling-"
craftingbeforeandafter["advanced-crafting"] = "recycling-"
craftingbeforeandafter["crafting-with-fluid"] = "recycling-with-fluid"

--[[
	That's all the vanilla code setup
	Mods that require extra bespoke setup are held in the plugins file
--]]
require("lookups.modplugins")
-- Will be using this mods structure to test for the presence of mods
log(serpent.block(mods))
--[[ Example
  ZRecycling = "0.18.1",
  base = "0.18.0",
--]]

-- Local tables that are populated by the local functions
local recycling_groups = {}		-- New item-groups for recycling
local recycling_subgroups = {}	-- New subgroups for recycling
local rev_recipes = {}			-- Where the reversed recipes will be stored
-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
local recipe_handled = {}       -- flags for when recipes have either been excluded from recycling, or matched to an item

--[[
	LOCAL FUNCTIONS
--]]

--[[
	LOCAL GROUP FUNCTIONS
---]]

local function build_groups()
	-- build local item-groups and subgroups as candidates for recycling
	-- Initially just a copy of in-game (and mod) groups and subgroups
	-- and set recycling icons for the item-group tabs
	local invalid
	-- For each item-group
	for _, group in pairs(data.raw["item-group"]) do
		-- Fix for: https://github.com/DRY411S/Recycling-Machines/issues/70
		-- We now test for valid item groups not invalid ones, and assume we don't have one
		invalid = true
		local newicon = groups_supported["default"]
		for _, valid_item_group in pairs(valid_item_groups) do
			if group.name == valid_item_group then
				invalid = false
				break
			end
		end
		for nextname,nextpath in pairs(groups_supported) do
			if group.name == nextname then
--				newicon = nextpath
				invalid = false
				break
			end
		end
		if invalid == false then
	
			local newgroup = groups_supported[group.name]
--			local newgroup = {
								newgroup.type = "item-group"
--								icon = newicon,
--                                icon_size = 32,
								newgroup.inventory_order = group.inventory_order
								newgroup.hidden = false
								newgroup.name = group.name
								newgroup.order = group.order
--							}
			table.insert(recycling_groups,newgroup)
		end
	end -- each item-group
	
	-- For each subgroup
	for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
		-- Fix for: https://github.com/DRY411S/Recycling-Machines/issues/70
		-- We now test for valid item groups not invalid ones, and assume we don't have one
		invalid = true
		groupname = subgroup.group
		for valid_item_group,icon in pairs(groups_supported) do
			if groupname == valid_item_group then
				invalid = false
				break
			end
		end
		if invalid == false then
			for _,invalidsubgroup in pairs(invalidsubgroups) do
				if invalidsubgroup == subgroupname then
					invalid = true
					break
				end
			end
		end
		if invalid == false then
			local newsubgroup = {
								type = "item-subgroup",
								name = subgroup.name,
								group = subgroup.group,
								order = subgroup.order
							}
			table.insert(recycling_subgroups,newsubgroup)
		end
	end -- each subgroup
end -- build_groups

-- To add the recycling prefix
-- when we're done with the groups and subgroups 'as is'
local function create_reverse_groupsandsubgroups()
	for _,group in pairs(recycling_groups) do
		group.name = rec_prefix .. group.name
	end
	for _,subgroup in pairs(recycling_subgroups) do
		subgroup.name = rec_prefix .. subgroup.name
		subgroup.group = rec_prefix .. subgroup.group
	end
end

--[[
	LOCAL RECIPE FUNCTIONS
--]]

--[[
	Remove all recipes that cannot be recycled	
--]]
function removeIneligibleRecipes()
    
	for k , recipe in pairs(data.raw.recipe) do
		local can_recycle = true

		-- Fix for issues 11 and 12, caused by recipes that have NO ingredients!
		-- http://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
		local recipeLayers = {recipe, recipe.normal, recipe.expensive}
		for i, recipeLayer in pairs(recipeLayers) do
			if recipeLayer ~= nil and recipeLayer ~= false and recipeLayer.ingredients ~= nil and ( next(recipeLayer.ingredients) == nil or recipeLayer.ingredients == 0 ) then
				can_recycle = false
			end
		end
		
		if can_recycle == true then
			-- Only handle recipes where the category is nil (assumed crafting)
			-- or is in the craftingbeforeandafter table
			-- or is a bettery.
			-- Battery is special case, produced chemically but allowed to be recycled in assembler
			can_recycle = false
			local recipeCategory = recipe.category
			if not recipeCategory or recipe.name == "battery" then
				recipeCategory = "crafting"
			end
			for before,after in pairs(craftingbeforeandafter) do
				if recipeCategory == before then
					can_recycle = true
					break
				end
			end
		end
		
		if can_recycle == true then
			-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
			-- We don't recycle if the recipe is within invalid sub-groups
			for _,invalidsubgroup in pairs(invalidsubgroups) do
				if invalidsubgroup == recipe.subgroup then
					can_recycle = false
					break
				else
				end
			end
		end
		
		if can_recycle == true then
			-- Now we need to test the recipe result
			-- There are 6 recipe result-scenarios
			-- 1 There is a single 'result'. This is our reversed recipe ingredient
			-- 2 There is a 'results' with only 1 result that isn't the default type i.e. not an 'item'
			-- 3 There is a 'results' with only 1 result that IS the default type but has just been coded that way by a modder)
			-- 4 There is a 'results' with more than one product produced by the recipe
			-- 5 there are no results
			-- 6 Only one of normal or expensive are present (the other is nil or false)
			-- The 2nd, 4th and 5th scenarios are things we cannot recycle.
			
			-- New for 0.15.x. Handle there being normal and expensive sets of ingredients
			-- recipes can have either result(s) or both normal and expensive result(s)
			
			--  Assume that we cannot recycle until we have proved otherwise
			local recipeLayers = {recipe, recipe.normal, recipe.expensive}
			can_recycle  = false
			for i, recipeLayer in pairs (recipeLayers) do
				if recipeLayer ~= nil and recipeLayer ~= false then
					-- Scenario 1, almost always true
					if recipeLayer.result ~= nil then
						can_recycle = true
						break
					end
				end
			end
			
			-- if still false, test for results
			if can_recycle == false then
				
				for i, recipeLayer in pairs (recipeLayers) do
				
					if recipeLayer ~= nil and recipeLayer ~= false then
					
						if recipeLayer.results ~= nil then
							-- there are some results
							resultRows = 0
							for k, v in ipairs(recipeLayer.results) do
								resultRows = resultRows + 1
							end
							if resultRows == 1 then
								-- there is only 1 result
								-- Either scenario 2 or 3 to be tested here
								-- Using specification at https://lua-api.factorio.com/latest/Concepts.html#Product is open to interpretation
								-- Another reference https://wiki.factorio.com/Types/ProductPrototype
								-- https://wiki.factorio.com/Types/ItemProductPrototype
								-- Inspection shows type can in fact be absent, or numeric
								-- type absent is assumed to be item
								-- type = 1 is assumed to be fluid
								-- type = 0 is assumed to be item
								if recipeLayer.results.type == nil or recipeLayer.results.type == "item" or recipeLayer.results.type == 0 then
									can_recycle = true
									break
								end
							end
							-- Scenario 4. More than 1 result
						end
						-- Scenario 5. No results

					end -- recipeLayer (handles Scenario 6)
				end -- for multiple results
			end -- single result
		end -- can_recycle
		
		if can_recycle == false then
			 -- Code uses nil to check for handled
			 -- I set to false if cannot be recycled and true when recycled
			 recipe_handled[recipe.name] = false
			-- log("Cannot recycle: " .. recipe.name)
		else
		end
	end
end

-- Localise the reversed recipe name by wrapping the original localised text
-- with "Recycled <localised_text> parts"
-- New localise_text() function replaces hardcoded lookups, as suggested by eradicator https://forums.factorio.com/memberlist.php?mode=viewprofile&u=24632
-- on factorio forums https://forums.factorio.com/57840
-- New method implemented in 0.16.6, and 0.15.9
function localise_text(item)

	local result
	if item.localised_name then
		if type(item.localised_name) == "table" then
		   -- This is a table. I need the first v
		  result = item.localised_name[1]
		else
		  -- Oh my days, it's a string. Valid but highly unusual. Means that the mod does not support locale
		  -- and is hardcoded to a single language. Tsk.
		  -- Fixes https://github.com/DRY411S/Recycling-Machines/issues/52
		  result = item.localised_name
		  return {"recipe-name.recycledparts",result} 
		end
	elseif item.place_result then
		result = 'entity-name.'..item.place_result
	elseif item.placed_as_equipment_result then
		result = 'equipment-name.'..item.placed_as_equipment_result
	else
		result = 'item-name.'..item.name
	end
		
	return {"recipe-name.recycledparts",{result}}            
	
end --localise_text

-- Check whether the item matches the recipe result
-- Only recyclable recipes are passed in, except in special cases
local function matched(item,recipe,tech)

		--[[
			*** SPECIAL CASES ***
			Within an item type only certain items can be recycled.
			Cannot be handled by removeIneligibleRecipes because the item type is not nown at that point
		--]]
		
		-- Special case for terrain
		-- https://github.com/DRY411S/Recycling-Machines/issues/62
		-- Recycle cliff explosives but no other terrain types (landfill, concretes)
		if item.subgroup == "terrain" and item.name ~= "cliff-explosives" then
			can_recycle = false
			recipe_handled[item.name] = false			
			return false
		end

		--[[
			Get the recipe result here for matching
			The item name and the recipe name being the same are not enough
		--]]
		return item.name == getRecipeResult(recipe)
		
end --match function

function getRecipeResult(recipe)
	--[[
		Only called for valid recipes, so it is known that there is a result
		Can be in result or results (with the base, normal, or expensive layers)
		Return the first one you find
	--]]

	local recipeLayers = {recipe, recipe.normal, recipe.expensive}
	for i, recipeLayer in ipairs(recipeLayers) do
		if recipeLayer ~= nil and recipeLayer ~= false then
			if recipeLayer.result ~= nil then
				return recipeLayer.result
			elseif recipeLayer.results ~= nil then
				if recipeLayer.results[1].type ~= nil then
					return recipeLayer.results[1]["name"]
				else
					return recipeLayer.results[1][1]
				end
			end
		end
	end
	-- if here, haven't found any results. Should never happen
end

-- Called when a recipe's results match an 'item'
-- and it is known that the recipe can be recycled
function add_reverse_recipe(item,recipe,tech)

	--[[
		Need to swop the ingredients with the results for all recipe layers
		The results can have a nil amount, with 1 implied
		but ingredients must have a number
		Might need to split the new results into more than 1 stack. An assembler constraint
		Need to assign icons, subgroups and order. We will use the item for that
		Reference for recipe structure: https://wiki.factorio.com/Prototype/Recipe
		Is more up to date than the api doc at: https://lua-api.factorio.com/latest/LuaRecipePrototype.html
		-- Working assumption from the wiki is that these fields can appear under normal and expensive
		-- https://wiki.factorio.com/Prototype/Recipe#Recipe_data
		ingredients
		result
		result_count
		results
		energy_required
		emissions_multiplier
		requester_paste_multiplier
		overload_multiplier
		enabled
		hidden
		hide_from_stats
		hide_from_player_crafting
		allow_decomposition
		allow_as_intermediate
		allow_intermediates
		always_show_made_in
		show_amount_in_title
		always_show_products
		main_product
	--]]
	
	-- Use the actual recipe as the basis for the reversed recipe
	local reversedRecipe = table.deepcopy(recipe)
	
	-- Change some fields to confirm that this is a recycling recipe
	reversedRecipe.name = rec_prefix .. recipe.name
	reversedRecipe.group = rec_prefix .. data.raw["item-subgroup"][item.subgroup].group
	reversedRecipe.subgroup = rec_prefix .. item.subgroup
	-- Add the item icons and sort order to match the item
	-- because there is no rec_prefix .. item prototype defined
	reversedRecipe.icon = item.icon
	reversedRecipe.icons = item.icons
	reversedRecipe.icon_size = item.icon_size
	reversedRecipe.order = item.order
	-- Add the "Recycled <item.name> parts" description
	-- because there is no  rec_prefix .. item prototype defined
	reversedRecipe.localised_name = localise_text(item)

	-- Assign the category to force a recycling machine
	local newcategory =  nil
	if recipe.name == "battery" then
		newcategory = "recycling-with-fluid"
	elseif recipe.category  == nil then
		newcategory = "recycling-"
	else
		for old, new in pairs(craftingbeforeandafter) do
			if old == recipe.category then
				newcategory = new
				break
			end
		end
	end

	if newcategory ~= "recycling-with-fluid" then
		local recyclesuffix = "1"
		newcategory = newcategory .. recyclesuffix
	end
	reversedRecipe.category = newcategory
	
	-- The rest of reversedRecipe fields are in the flat, normal and expensive layers
	local oldrecipeLayer = { recipe, recipe.normal, recipe.expensive }
	local newrecipeLayer = { reversedRecipe, reversedRecipe.normal, reversedRecipe.expensive }
	for i = 1 , 3 do
		if oldrecipeLayer[i] ~= nil and oldrecipeLayer[i] ~= false then
			-- Set fields only if there are results in this layer
			if oldrecipeLayer[i].result ~= nil or oldrecipeLayer[i].results ~= nil then
				-- Overwrite (or populate) some optional fields)
				newrecipeLayer[i].hide_from_player_crafting = true
				newrecipeLayer[i].allow_decomposition = false
				newrecipeLayer[i].allow_as_intermediate = false
				newrecipeLayer[i].allow_intermediates = false
				newrecipeLayer[i].always_show_made_in = true
				newrecipeLayer[i].show_amount_in_title = false
				newrecipeLayer[i].always_show_products = true
				-- swop the results with the ingredients (for each layer)
				swopResultsAndIngredients(oldrecipeLayer[i],newrecipeLayer[i],item)
				newrecipeLayer[i].main_product = nil
			end
		end
	end
	
	-- All done Add the reversed recipe
	table.insert(rev_recipes,reversedRecipe)
    
    -- Link the recyclable recipe with the same technology as the original recipe
	local neweffect = {}
    neweffect.recipe = reversedRecipe.name
    neweffect.type = "unlock-recipe"
    if tech[recipe.name] ~= nil then
		table.insert(data.raw["technology"][tech[recipe.name]].effects,neweffect)
	end

end -- add_reverse_recipe

-- A reverse recipe swops the original results and ingredients
function swopResultsAndIngredients(old,new)
	-- Build results as ingredients
	if old.result ~= nil then
		if old.result_count == nil then
			old.result_count = 1
		end
	elseif old.results ~= nil then
		-- must be results then
		if old.results[1].type == nil then
			i1 = 1
			i2 = 2
		else
			i1 = "name"
			i2 = "amount"
		end
		old.result = old.results[1][i1]
		-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/87 (result_count can be nil)
		old.result_count = old.results[1][i2] or 1
	end
	new.ingredients = { {old.result, old.result_count * recycleratio} }
	
	-- Build ingredients as results
	-- No need to handle stack size any longer
	new.results = old.ingredients
end

--[[
	***************************************
	*
	* MAIN CODE STARTS HERE
	*
	***************************************
--]]

--Get the recycle ratio from mod-settings.
-- Enhancement https://github.com/DRY411S/Recycling-Machines/issues/39
--This is the number of items you must insert into the Recycling Machine
-- before it will work, and give you back the ingredients for a single item
--Default is 1
recycleratio = tonumber(settings.startup["ZRecycling-recoveryrate"].value)

-- Build Groups and Subgroups that look like they will be recyclable
-- Give icons to the item-group tabs
build_groups()

-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/43
-- Build a local variable of the format tech[recipe] = <the research to unlock the recipe>
local tech = {}
for name,item in pairs(data.raw["technology"]) do
    if item.effects ~= nil then
        for _,effect in pairs(item.effects) do
           if effect.type == "unlock-recipe" then
                tech[effect.recipe] = name
            end
        end
    end
end

log("***************** Start matching")


--[[
	Remove all the recipes that cannot by recycled be setting the 'handled' flag
]]--
removeIneligibleRecipes()

--[[
	***************************************
	*
	* MAIN LOOP STARTS HERE
	*
	* FOR EVERY VALID TYPE
	*	FOR EVERY ITEM
	*		IF THE SUBGROUP IS VALID
	*			IF THE ITEM IS NOT HIDDEN
	*				FOR EACH RECIPE
	*					IF ITEM AND RECIPE MATCH (TRY A FAST MATCH FIRST)
	*						CREATE REVERSE RECIPE
	*		
	***************************************
--]]
-- MAIN LOOP
-- for all validtypes
local invalid
for _,validtype in pairs(validtypes) do
	-- For all 'item' prototypes in this type
	if data.raw[validtype] == nil then
	error("Error Type: " .. validtype)
	end
	for name, item in pairs(data.raw[validtype]) do

		-- Assume we have an invalid item
		invalid = true

		-- Does this item have a valid subgroup that we recycle
		for _,validsubgroup in pairs(recycling_subgroups) do
			if validsubgroup.name == item.subgroup then
				invalid = false
				break -- valid item found
			end
		end

		-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/61
		-- Recycling Recipes for hidden items are produced
		-- Is this a hidden item?
		if item.flags then
			for _,v in pairs(item.flags) do
				if v == "hidden" then
					invalid = true
					break
				end
			end
		end
		
		if invalid == false then
		
			-- New in v0.12.39 and v0.13.18. Look for all recipe(s) that have the result which is this item
			-- Written to assume that there may be more than one recipe per item (Bob's Modules)
			-- And that the recipe name may not be the same as the item name (Yuoki)
			
			-- New in version 0.18.2 attempt to fast match
			local ismatched = false
			local recipe = data.raw.recipe[item.name]
			if recipe ~= nil and recipe_handled[recipe.name] == nil then
				-- Fast match, assume recipe and item name are the same
				-- matched returns true if recipe is reversed
				ismatched = matched(item,recipe,tech)
				if  ismatched == false then
					-- Slow match. Traverse for recipes where the result is the item name
					log("Slow matching: " .. item.name .. " of type: " .. item.type .." subgroup: " .. item.subgroup)
					for name, recipe in pairs(data.raw.recipe) do
					
						-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
						-- Don't check this recipe for a match if it has already been handled in previous match attempts
						-- If handled means that it's either been matched or it cannot be recycled
						if recipe_handled[recipe.name] == nil then
					
							-- Do the recipe results match the item?
							-- And is the recipe recyclable?
							ismatched = matched(item,recipe,tech)

							if ismatched == true then
								break
							end -- matched recipe
						end -- recipe_handled already
					end -- slow match each recipe
				end -- fast match
				
				-- Reverse the recipe here if is matched (fast or slow)
				if ismatched == true then
					-- v0.18.8 Moved the code to build the reverse recipe here
					-- The 'item' contains useful things we need to construct the reverse recipe
					-- It may be armor, gun, item, module etc.
					-- Make the recipe
					add_reverse_recipe(item,recipe,tech)
					recipe_handled[recipe.name] = true
				else
					-- No match found
				end
			end -- already handled or no recipe for this item
		end -- valid subgroup
	end -- each prototype in this type
end -- each validtype
log("***************** End matching")

--[[
	***************************************
	*
	* MAIN LOOP ENDS HERE
	*
	***************************************
--]]

-- Recipes all done, Create new subgroups and groups
create_reverse_groupsandsubgroups()

--[[
	Adjust any vanilla recycling recipes that have been enabled by mods
	that would normally be disabled
--]]
require("lookups.modadjustments")

-- Add the new groups, new subgroups and reverse recipes to raw data
data:extend(recycling_groups)
data:extend(recycling_subgroups)
data:extend(rev_recipes)

-- Calls for debugging only. Dump local tables in factorio-current.log
-- Remove comment if you want the table dumped
-- log(serpent.block(data.raw))
-- log(serpent.block(data.raw.item))
-- log(serpent.block(data.raw.recipe))
-- log(serpent.block(data.raw.technology))
-- log(serpent.block(recycling_groups))
-- log(serpent.block(data.raw["item-group"]))
-- log(serpent.block(data.raw["item-subgroup"]))
-- log(serpent.block(recycling_subgroups)) 
-- log(serpent.block(rev_recipes))