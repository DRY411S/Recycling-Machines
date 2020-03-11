-- variables used in data and control luas
-- to ensure consistency without hardcoding
require("constants")
local rec_prefix = constant_rec_prefix

--
-- LOCAL DATA
--
-- Will be using this mods structure to test for the presence of mods
log(serpent.block(mods))
--[[
  ZRecycling = "0.18.1",
  base = "0.18.0",
--]]

--[[
-- Some code suggested by darkfrei on factorio forums PM for travesring the different type of recipe constructs
-- Very elegant
for recipe_name, recipe_prot in pairs (data.raw.recipe) do
  local handlers = {recipe_prot, recipe_prot.normal, recipe_prot.expensive}
  for i, handler in pairs (handlers) do
    if handler.ingredients then
      for j, ingredient_prot in pairs (handler.ingredients) do
        local ingredient_name = ingredient_prot.name or ingredient_prot[1]
        local ingredient_type = ingredient_prot.type or "item"
        if not all_ingredients[ingredient_type] then all_ingredients[ingredient_type] = {} end
        if not (is_value_in_list (ingredient_name, all_ingredients[ingredient_type])) then
          table.insert(all_ingredients[ingredient_type], ingredient_name)
        end
      end
    end
    
    if handler.result then
      if not (is_value_in_list (handler.result, all_results.item)) then
        table.insert(all_results.item, handler.result)
      end
    end
    
    if handler.main_product and not (handler.main_product == "") then
      if not (is_value_in_list (handler.main_product, all_results.item)) then
        table.insert(all_results.item, handler.main_product)
      end
    end
    
    if handler.results then
      for j, result_prot in pairs (handler.results) do
        local result_name = result_prot.name -- or result_prot[1]
        local result_type = result_prot.type or "item"
        if not all_results[result_type] then all_results[result_type] = {} end
        if not (is_value_in_list (result_name, all_results[result_type])) then
          table.insert(all_results[result_type], result_name)
        end
      end
    end
  end
end
]]

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

-- Local tables that are populated by the local functions
local recycling_groups = {}		-- New item-groups for recycling
local recycling_subgroups = {}	-- New subgroups for recycling
local rev_recipes = {}			-- Where the reversed recipes will be stored
-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
local recipe_handled = {}       -- flags for when recipes have either been excluded from recycling, or matched to an item

--
-- LOCAL FUNCTIONS
--

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

-- Check whether the item matches the recipe result
-- and that the recipe is recyclable
local function matched(item,recipe,tech)

    local can_recycle = true
    
    -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/40
    -- We don't recycle if the allow_decomposition flag is set to false
    if recipe.allow_decomposition ~= nil and recipe.allow_decomposition == false then
        can_recycle = false
    elseif recipe.category == "smelting" then
        -- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
        -- We don't recycle what is smelted
        can_recycle = false
    elseif recipe.category == "chemistry" and recipe.name ~= "battery" then
        -- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
        -- We don't recycle what is made in chemical plants (apart from batteries)
        can_recycle = false    
	else
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
    
    local result
    if can_recycle == true then
        -- Now we need the recipe result
        -- There are 5 recipe result-scenarios
        -- 1 There is a single 'result'. This is our reversed recipe ingredient
        -- 2 There is a 'results' with only 1 result that isn't the default type i.e. not an 'item'
        -- 3 There is a 'results' with only 1 result that IS the default type but has just been coded that way by a modder)
        -- 4 There is a 'results' with more than one product produced by the recipe
        -- 5 there are no results
        -- The 2nd, 4th and 5th scenarios are things we cannot recycle.
        
        -- New for 0.15.x. Handle there being normal and expensive sets of ingredients
        
        local product_count = 0
        if recipe.result then
            -- Scenario 1
            result = recipe.result
            product_count = 1
        elseif recipe.normal ~= nil and recipe.normal.result then
            -- Scenario 1
            result = recipe.normal.result
            product_count = 1
        else

            -- There's no result so there must be results, even if there's only 1
            -- There are results or (normal.results and expensive.results)
            -- Assume the normal and expensive results are both valid
            -- In this part of the code, match against the normal recipe only
            local temprecipe = recipe
            if recipe.normal ~= nil then
                temprecipe = recipe.normal
            end
            -- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/40
            -- Scenario 5
            if temprecipe.results == nil then
                can_recycle = false
            else
            
                for i,v in pairs(temprecipe.results) do
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
            end -- no results
        end
    end -- can_recycle
    
	-- Fix for issues 11 and 12, caused by recipes that have NO ingredients!
	-- http://stackoverflow.com/questions/1252539/most-efficient-way-to-determine-if-a-lua-table-is-empty-contains-no-entries
	if recipe.ingredients ~= nil then
        if next(recipe.ingredients) == nil then
            can_recycle = false
        end
    end
    
	if recipe.normal ~= nil then
        if next(recipe.normal.ingredients) == nil then
            can_recycle = false
        end
    end
    
	if can_recycle == true then
		if item.name == result then
            -- v0.18.2 Moved the code to build the reverse recipe here
-- **************			
                        if recipe.name ~= item.name then
							log("Matched item: " .. item.name .. " with recipe: " .. recipe.name)
						end
						local newcategory
                        -- Only handle recipes where the category is nil or is produced in an assembling machine
                        -- Not strictly true for Yuoki, but allowed
                        local invalid = true
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
                        
						-- Special case for terrain
						-- https://github.com/DRY411S/Recycling-Machines/issues/62
						-- Recycle cliff explosives
						if item.subgroup == "terrain" and recipe.name ~= "cliff-explosives" then
							invalid = true
						end
						
						-- Special case for batteries
                        if invalid == true and recipe.name == "battery" then
                            newcategory = "recycling-with-fluid"
                            invalid = false
                        end
                        
                        if invalid == false then
                            -- The 'item' contains useful things we need to construct the reverse recipe
                            -- It may be armor, gun, item, module etc.
                            -- Make the recipe
                            add_reverse_recipe(item,recipe,newcategory,tech)
                        end
-- **************			
			
			-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
            recipe_handled[recipe.name] = true
			return true
		else
			return nil
		end
	else
		-- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
        recipe_handled[recipe.name] = true
        return nil
	end
end --match function


-- Called to convert the ingredients into results
-- Called separately for 'flat', normal and expensive recipes
local function build_rev_results(ingredients)

	-- Build the ingredients into reverse results
	local newrow
    local results_count = 0
	local rev_results = {}
    for k, v in pairs(ingredients) do
		results_count = results_count + 1
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
	end -- recipe ingredients loop
    return results_count, rev_results
end -- build_rev_results

-- Called when a recipe's results match an 'item'
-- and it is known that the recipe can be recycled
function add_reverse_recipe(item,recipe,newcategory,tech)
--log("Item: ".. item.name)
-- .. ", Recipe: " .. recipe.name .. ", Category: " .. newcategory .. ", Tech: " .. tech[recipe.name])
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
	
  local result, temprecipe
	local result_count = recipe.result_count
	if not result_count then
        -- 
        -- Fixed for https://github.com/DRY411S/Recycling-Machines/issues/44
        -- Code was not handling that there could be different result_count for normal and expensive
        -- 
        -- 
        -- Fixed for https://github.com/DRY411S/Recycling-Machines/issues/46
        -- Code was not calculating the number of items required to recycle correctly
        -- 
        if recipe.normal ~= nil then
                result_count = recipe.normal.result_count
                -- may still be nil at this point https://github.com/DRY411S/Recycling-Machines/issues/46
        end
  end
   
    
  local energy_required = recipe.energy_required
	if not energy_required then
        -- 
        -- Fixed for https://github.com/DRY411S/Recycling-Machines/issues/44
        -- Code was not handling that there could be different result_count and energy_required for normal and expensive
        -- 
        -- 
        -- Enhancement https://github.com/DRY411S/Recycling-Machines/issues/45
        -- Allow user decide whether take longer to recycle by using the Expensive energy_required setting
        -- 
        if recipe.normal ~= nil then
            if difficulty == "expensive" then
                energy_required = recipe.expensive.energy_required
            else
                energy_required = recipe.normal.energy_required
            end
        end
        
        if not energy_required then
            energy_required = 0.5
        end
	end
    
	if recipe.result then
		result = recipe.result
	elseif recipe.normal ~= nil and recipe.normal.result then
		result = recipe.normal.result
  end
	if result == nil then
        -- There's no result so there must be results, even if there's only 1
        if recipe.results ~= nil then
            temprecipe = recipe
        elseif recipe.normal ~= nil then
            temprecipe = recipe.normal
        end
           
		for i,v in pairs(temprecipe.results) do
            result = v.name
            --
            -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/46
            --
            if not result_count then
                result_count = v.amount
                if not result_count then
                    result_count = v.amount_max
                end
            end --may still be nil even now
		end
	end

    --
    -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/46
    --
    if not result_count then
        result_count = 1
    end
--log("result_count: " .. result_count .. ", recipe.result: " .. result)    

    -- New for 0.15.6 https://github.com/DRY411S/Recycling-Machines/issues/39
    -- Don't get the percentage of original ingredients back from a single item
    -- Instead need X of the items to get the original ingredients back for 1 item
    -- Adjust result_count for recycleratio
    result_count = result_count * recycleratio

	-- Create new recipe name and assign to a recycling group
	local rec_name = rec_prefix .. recipe.name
	local newgroup = rec_prefix .. data.raw["item-subgroup"][item.subgroup].group
	local max_count,recycle_count = 0
	
	local flat,normal,expensive = {}
    if recipe.ingredients ~= nil then
        recycle_count, flat = build_rev_results(recipe.ingredients)
        if max_count <= recycle_count then
            max_count = recycle_count
        end
    else
 		recycle_count, normal = build_rev_results(recipe.normal.ingredients)
        if max_count <= recycle_count then
            max_count = recycle_count
        end
        recycle_count, expensive = build_rev_results(recipe.expensive.ingredients)
        if max_count <= recycle_count then
            max_count = recycle_count
        end
    end

    --Set recycle_count to maximum number of results
    recycle_count = max_count
	-- Build the results into ingredients
	local ingredients = {}
	ingredients[1] = result
	ingredients[2] = result_count
    
    -- Fix: https://github.com/DRY411S/Recycling-Machines/issues/63
	-- If an item has a stack_size of less than the ingredient count, then the ingredient count needs reducing
	if item.stack_size < result_count then
		ingredients[2] = item.stack_size
	end
	
	-- Assign the category to force a recycling machine based on the number of results
	if newcategory ~= "recycling-with-fluid" then
		local recyclesuffix = "1"
		newcategory = newcategory .. recyclesuffix
	end
--log("newcategory: " .. newcategory)
	--New name, group assigned--
	-- Results and ingredients are swopped
	-- Build the recipe now we have all the parts
	local new_recipe =
	{
		type = "recipe",
		name = rec_name,
		-- localised_name = locale,
		hidden = false,
		category = newcategory,
        -- main_product = "",
		group = newgroup,
		subgroup = rec_prefix .. item.subgroup,
		order = item.order,
	}
    
    -- enabled is initially false and made true in the event handler
    -- for the inital game items, and true when the corresponding unlock technology
    -- is researched
	--[[
	Fix for https://github.com/DRY411S/Recycling-Machines/issues/69 is to set the recipe enablement to what it
	is at start of game. This handles when mods use reset_technology_effects() after our on_configuration_changed event
	Previously we hid the recipes because they were appearing as recylable before recycling machines were created
	However, now we have the hide_from_player_crafting parameter, they won't appear.
	]]--
    if next(flat) ~= nil then
        -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/69
		new_recipe.enabled = recipe.enabled
		-- Finally a fix for issue #1 https://github.com/DRY411S/Recycling-Machines/issues/1
		new_recipe.hide_from_player_crafting = true
        new_recipe.ingredients = {ingredients}
        new_recipe.energy_required = energy_required
        new_recipe.results = flat
    else
        new_recipe.normal = {}
        -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/69
        new_recipe.normal.enabled = recipe.normal.enabled
		-- Finally a fix for issue #1 https://github.com/DRY411S/Recycling-Machines/issues/1
		new_recipe.normal.hide_from_player_crafting = true
        new_recipe.normal.ingredients = {ingredients}
        new_recipe.normal.energy_required = energy_required
        new_recipe.normal.results = normal
        new_recipe.expensive = {}
        -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/69
        new_recipe.expensive.enabled = recipe.expensive.enabled
		-- Finally a fix for issue #1 https://github.com/DRY411S/Recycling-Machines/issues/1
		new_recipe.expensive.hide_from_player_crafting = true
        new_recipe.expensive.ingredients = {ingredients}
        new_recipe.expensive.energy_required = energy_required
        new_recipe.expensive.results = expensive
    end
	
	-- Fix for issue 23. Provided by judos https://github.com/judos,
	-- The else clause failed in testing, modified by me
	if item.icon then
		new_recipe.icon = item.icon
	elseif item.icons then	
		new_recipe.icons = item.icons
	else
		new_recipe.icon = "__base__/graphics/icons/" .. result .. ".png"
	end
    
    new_recipe.icon_size = item.icon_size
	
	-- Produce localised "Recycled <item> parts" if there is more than one result
	-- If there is only one result, the game takes care of the locale
	-- Fix for: https://github.com/DRY411S/Recycling-Machines/issues/36
	-- for the Portable fusion reactor there is only 1 result but there are 3 stacks
	-- which the game's locale does not handle
	if recycle_count > 1 or item.name == "fusion-reactor-equipment" then
			new_recipe.localised_name = localise_text(item)
	end

	table.insert(rev_recipes,new_recipe)
    
    --
    -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/43
    --
    
    -- We need to add this reverse recipe to the technology tree so that mods that call reset_technology_effects don't disable all the recipes
    -- tech[recipe.name] contains the name of the technology that unlocks the recipe we are reversing
    local neweffect = {}
    neweffect.recipe = new_recipe.name
    neweffect.type = "unlock-recipe"
    if data.raw["technology"][tech[recipe.name]] ~= nil then
        if tech[recipe.name] == "automation" and recycle_count > 2 then
            tech[recipe.name] = "automation-2"
        end
    else
        if recycle_count <= 2 then 
            tech[recipe.name] = "automation"
        elseif recycle_count <= 4 then
            tech[recipe.name] = "automation-2"
        else
            tech[recipe.name] = "automation-3"
        end
    end
    
    -- Everything can be recycled in every machine in 0.17
    table.insert(data.raw["technology"][tech[recipe.name]].effects,neweffect)


end -- add_reverse_recipe

--
-- MAIN CODE STARTS HERE
--

--Get the recycle ratio from mod-settings.
-- Enhancement https://github.com/DRY411S/Recycling-Machines/issues/39
--This is the number of items you must insert into the Recycling Machine
-- before it will work, and give you back the ingredients for a single item
--Default is 1
recycleratio = tonumber(settings.startup["ZRecycling-recoveryrate"].value)

--Get the time baseline from mod-settings.
-- Enhancement https://github.com/DRY411S/Recycling-Machines/issues/45
-- This is the base time to recycle. It can be either the original recipe's Expensive
-- or Normal setting. Default is Expensive
difficulty = settings.startup["ZRecycling-difficulty"].value

-- a flag for this recipe if it is invalid for recycling
local invalid

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

-- MAIN LOOP
-- for all validtypes
log("***************** Start matching")
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
			name = item.name
			recipe = data.raw.recipe[name]
			if recipe ~= nil and matched(item,recipe,tech) then
			elseif recipe ~= nil and recipe_handled[recipe.name] == nil then
				log("Slow matching: " .. item.name .. " of type: " .. item.type .." subgroup: " .. item.subgroup)
			for name, recipe in pairs(data.raw.recipe) do
            
                -- Enhancement for https://github.com/DRY411S/Recycling-Machines/issues/41
                -- Don't check this recipe for a match if it has already been handled in previous match attempts
                -- If handled means that it's either been matched or it cannot be recycled
                if recipe_handled[recipe.name] == nil then
			
                    -- Do the recipe results match the item?
                    -- And is the recipe recyclable?
                    if matched(item,recipe,tech) == true then
                    
                    end -- matched recipe
                end -- recipe_handled
            end -- each recipe
			end -- fast match
		end -- valid subgroup
	end -- each prototype in this type
end -- each validtype
log("***************** End matching")


-- Recipes all done, Create new subgroups and groups
create_reverse_groupsandsubgroups()
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
-- log(serpent.block(recycling_subgroups)) 
-- log(serpent.block(rev_recipes))