-- variables used in data and control luas
-- to ensure consistency without hardcoding
require("constants")
local rec_prefix = constant_rec_prefix

--
-- LOCAL DATA
--

-- These are the subgroups that cannot be recycled
local invalidsubgroups = {	
							"raw-material",
							"terrain",
							"fluid-recipes",
							-- Yuoki
							"y-raw-material",
							-- Bob's Mods
							"bob-gems-ore",
							"bob-gems-raw",
							"bob-gems-cut",
							"bob-gems-polished",
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
							}

-- These are the types found in development
-- Mods may invent more, but not likely
-- TODO: Maybe let people decide what they want to recycle to unclutter the menus
-- TODO: Would need a GUI or trigger mods
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
						-- New in v0.13
						"rail-planner",
						-- Yuoki
						"container"
					}
					
-- There's a long lookup list of Recycling group tabs in this included file
require("lookups.itemgrouptabs")

-- Localisations are a huge lookup table
-- Placed in a separate file to aid readability of this main code
require("lookups.localisations")
local localestring = ""
local localetype = ""

-- Accepted crafting categories
-- These are the categories which are accepted in assembling machines
-- This mod only recycles things that can be assembled in machines
local craftingbeforeandafter =	{}

-- Crafting for Vanilla
craftingbeforeandafter["crafting"] = "recycling-"
craftingbeforeandafter["advanced-crafting"] = "recycling-"
craftingbeforeandafter["crafting-with-fluid"] = "recycling-with-fluid"

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

-- Local tables that are populated by the local functions
local recycling_groups = {}		-- New item-groups for reecycling
local recycling_subgroups = {}	-- New subgroups for recycling
local rev_recipes = {}			-- Where the reversed recipes will be stored

--
-- LOCAL FUNCTIONS
--

-- Localise the reversed recipe name by wrapping the original recipe
-- with "Recycled <recipetext> parts"
-- Uses the lookup table from the localisations.lua
local function localise_text(item,recipe,result)
	if locale_section[item.subgroup] then
		localestring = {"recipe-name.recycledparts",{locale_section[item.subgroup] .. result}}
	else
		-- Show the user the name of the unsupported subgroup,
		-- when they hover over the Recycling Recipes
		-- for future bug reporting and enhancement
		localestring = {"recipe-name.recycledunknown", {item.subgroup}}
	end
end --localise_text

local function build_groups()
	-- build local item-groups and subgroups as candidates for recycling
	-- Initially just a copy of in-game (and mod) groups and subgroups
	-- and set recycling icons for the item-group tabs
	local invalid
	-- For each item-group
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
				if group.name == nextname then
					newicon = nextpath
					break
				end
			end
			
			local newgroup = {
								type = "item-group",
								icon = newicon,
								inventory_order = group.inventory_order,
								hidden = false,
								name = group.name,
								order = "z" .. group.order .. "z"
							}
			table.insert(recycling_groups,newgroup)
		end
	end -- each item-group
	
	-- For each subgroup
	invalid = false
	for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
		-- It's valid unless we find a reason that it's not
		invalid = false
		groupname = subgroup.group
		if invalid == false then
			for _, invalid_item_group in pairs(invalid_item_groups) do
				if groupname == invalid_item_group then
					invalid = true
					break
				end
			end
		end
		if invalid == false then
			for _,invalidsubgroup in pairs(invalidsubgroups) do
				if invalidsubgroup == subgroupname then
					invalid = true
					break
				else
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

-- To add the recycycling prefix
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

-- Check whether the item matches the recipe result
-- and that the recipe is recyclable
local function matched(item,recipe)

	-- First we need the recipe result
	-- There are 4 recipe result-scenarios
	-- 1 There is a single 'result'. This is our reversed recipe ingredient
	-- 2 There is a 'results' with only 1 result that isn't the default type i.e. not an 'item'
	-- 3 There is a 'results' with only 1 result that IS the default type but has just been coded that way by a modder)
	-- 4 There is a 'results' with more than one product produced by the recipe
	-- The 2nd and the 4th scenarios are things we cannot recycle.
	
	local result
	local can_recycle = true
	local product_count = 0
	if recipe.result then
		-- Scenario 1
		result = recipe.result
		product_count = 1
	else
		-- There's no result so there must be results, even if there's only 1
		for i,v in pairs(recipe.results) do
			product_count = product_count + 1
			if product_count ~= 1 then
				-- Scenario 4
				can_recycle = false
				break
			end	
			-- Need to handle 'type' not being present
			-- If not v.name, this implies that the elements have no 'friendly' key, are item types,
			-- and are just in table in name, amount order
			if not v.name then
				v.name = v[1]
				v.amount = v[2]
			end
			result = v.name
			result_count = v.amount and v.amount or 1
			if v.type and ( v.type == 1 or v.type == "fluid" )then -- 0 is 'item' 1 is 'fluid'
				-- Scenario 2
				can_recycle = false
				break
			end
		end
	end

	-- Fix for issues 11 and 12, caused by recipes that have NO ingredients!
	-- http://http://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
	if next(recipe.ingredients) == nil then
		can_recycle = false
	end
	
	if can_recycle == true then
		if item.name == result then
			return true
		else
			return nil
		end
	else
		return nil
	end
end

-- Called when a recipe's results match an 'item'
-- and it is known that the recipe can be recycled
local function add_reverse_recipe(item,recipe,newcategory)

	-- Pick up icon, subgroup, and order from item

	-- There are 3 recipe result-scenarios
	-- 1 The result_count is missing, in which case it is 1
	-- 2 There is a single 'result'. This is our reversed recipe ingredient
	-- 3 There is a 'results' with only 1 result that IS the default type but has just been coded that way by a modder)
	-- Other invalid scenarios have been eliminated in the 'matched' routine
	-- That routine has confirmed that there are not too many results or that the result is a fluid
	-- The recipe result is our ingredient
	-- We support only 1 (non-fluid) ingredient for recycling 
	-- The recipe ingredients are our results!
	
	local result
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
			result = v.name
			result_count = v.amount and v.amount or 1
		end
	end

	-- Create new recipe name and assign to a recycling group
	local rec_name = rec_prefix .. recipe.name
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
	end -- recipe ingredients

	-- Build the results into ingredients
	local ingredients = {}
	ingredients[1] = result
	ingredients[2] = result_count
	
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

	--New name, group assigned--
	-- Results and ingredients are swopped
	-- Build the recipe now we have all the parts
	local new_recipe =
	{
		type = "recipe",
		name = rec_name,
		-- localised_name = locale,
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
	}
	
	-- Fix for issue 23. Provided by judos https://github.com/judos,
	-- The else clause failed in testing, modified by me
	if item.icon then
		new_recipe.icon = item.icon
	elseif item.icons then	
		new_recipe.icons = item.icons
	else
		new_recipe.icon = "__base__/graphics/icons/" .. result .. ".png"
	end
	
	-- Produce localised "Recycled <item> parts" if there is more than one result
	-- If there is only one result, the game takes care of the locale
	if recycle_count > 1 then
		localise_text(item,recipe,result)
		if localestring ~= "" then
			new_recipe.localised_name = localestring
		end
	end
	
	table.insert(rev_recipes,new_recipe)
	
end -- add_reverse_recipe

--
-- MAIN CODE STARTS HERE
--

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

-- a flag for this recipe if it is invalid for recycling
local invalid

-- Build Groups and Subgroups that look like they will be recyclable
-- Give icons to the item-group tabs
build_groups()

-- New for v0.13.14 Adjust recycling machine recipes if Marathon mod is installed
if marathon then
	-- For each assembling machine
	for i=1,3 do
		local assembler = data.raw.recipe["assembling-machine-" .. i]
		for _,ass_ingredient in ipairs(assembler.ingredients) do
			for _,rec_ingredient in ipairs(data.raw.recipe["recycling-machine-" .. i].ingredients) do
				if ass_ingredient[1] == rec_ingredient[1] then
					rec_ingredient[2] = ass_ingredient[2]
					break
				end
			end
		end -- each assembling machine's recipe ingredient
	end -- each recycling machine
end -- marathon

-- MAIN LOOP
-- for all validtypes
for _,validtype in pairs(validtypes) do
	-- For all 'item' prototypes in this type
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

		if invalid == false then
		
			-- New in v0.13.18. Look for all recipe(s) that have the result which is this item
			-- Written to assume that there may be more than one recipe per item (Bob's Modules)
			-- And that the recipe name may not be the same as the item name (Yuoki)
			for name, recipe in pairs(data.raw.recipe) do
			
				-- Do the recipe results match the item?
				-- And is the recipe recyclable?
				if matched(item,recipe) == true then
				
					local newcategory
					-- Only handle recipes where the category is nil or is produced in an assembling machine
					-- Not strictly true for Yuoki, but allowed
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
					
					--
					-- SPECIAL CASES
					--
					
					-- Special case for batteries
					if invalid == true and recipe.name == "battery" then
						newcategory = "recycling-with-fluid"
						invalid = false
					end
					
					-- Special case for Created Alien Artifacts mod. We don't want to recycle artefacts into circuits!
					if recipe.name == "superconducting-alien-artifact" then
						invalid = true
					end

					-- Special case for vanilla and Omnibarrels
					-- We only recycle empty barrels
					-- This code is dangerous!
					-- It assumes that all mods with barreled fluids follow
					-- the same empty/fill-<fluid>-barrel naming convention
					if (string.find(recipe.name,"fill-") == 1 or string.find(recipe.name,"empty-") == 1) and string.find(recipe.name,"-barrel") ~= nil then
						if recipe.name ~= "empty-barrel" then
							invalid = true
						end
					end

					if invalid == false then
						-- The 'item' contains useful things we need to construct the reverse recipe
						-- It may be armor, gun, item, module etc.
						-- Make the recipe
						add_reverse_recipe(item,recipe,newcategory)
					end
				end -- matched recipe
			end -- each recipe
		end -- valid subgroup
	end -- each prototype in this type
end -- each validtype


-- Recipes all done, Create new subgroups and groups
create_reverse_groupsandsubgroups()
-- Add the new groups, new subgroups and reverse recipes to raw data
data:extend(recycling_groups)
data:extend(recycling_subgroups)
data:extend(rev_recipes)

-- Calls for debugging only. Dump local tables in factorio-current.log
-- Stops game. Remove comment if you want the table dumped
--error(
--serpent.block(data.raw) ..
--serpent.block(data.raw.item) ..
--serpent.block(data.raw.recipe) ..
--serpent.block(recycling_groups) ..
--serpent.block(recycling_subgroups) .. 
--serpent.block(rev_recipes) ..
-- "")