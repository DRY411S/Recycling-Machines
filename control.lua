-- GLOBAL defines--

-- Constants.lua contains the reverse recipe prefix in a variable constant_rec_prefix
-- It's also used in data-final-fixes.lua where the reverse recipes are built
require("constants")

-- GLOBAL variables

-- Make the recipe prefix a global to be used in migrations, which don't allow requires.
rec_prefix = constant_rec_prefix

-- This has to be copied into the migration scripts. Make sure it is aligned.
-- GLOBAL functions
if not ZRecycling then ZRecycling = {} end

function ZRecycling.Unlock_Recipe(force,recipename)
	-- Need to enable the reverse recipe for this one, in the Recycling group
	local recipe = force.recipes[recipename]
	if recipe then
log(recipename)
		-- Enable the reversed version
		local reverse_recipe = force.recipes[rec_prefix .. recipename]
		if reverse_recipe then
			force.recipes[rec_prefix .. recipename].enabled = true
		end
	end
end

-- LOCAL Variables
local force = nil

-- LOCAL functions    

-- No longer called because the mod does not handle research_finished events
--[[-- When research is finished
local function enable_reverse_recipes(event)

	for _, nextforce in pairs(game.forces) do
		force = nextforce
		-- Don't reverse anything until automation has been researched (which allows a recycling machine)
		if force.technologies["automation"].researched == true or event.research.name == "automation" then
			-- Special case for automation
			if event.research.name == "automation" then
				-- Now we can recycle. Pick up reverse recipes for all the things
				-- that can be crafted without automation
				for _,v in pairs(force.recipes) do
					if v.enabled == true then
						ZRecycling.Unlock_Recipe(force,v.name)
					end
				end
			end
			local rec = event.research.effects
			for i,v in pairs(rec) do
				if v.type == "unlock-recipe" then
					ZRecycling.Unlock_Recipe(force,v.recipe)
				end
			end
		end
	end
end
]]--

-- GAME Event Handlers

--
-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/43
-- Recycling recipes are now embedded into the game's technology tree
-- Therefore there is no longer a need for a handler for on_research_finished event
-- 

--[[
script.on_event(defines.events.on_research_finished,function(event)
	if event.name == defines.events.on_research_finished then
	if event.research.name == "automation" then
      enable_reverse_recipes(event)
    end
	end
end
)
]]--

--
-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/43
-- Recycling Recipes are now added to the same technology that enables the original item
-- Therefore the recycling recipes can be enabled with a call to reset_technology_effects()
-- This must be done on_init because the previous method no longer works if other mods have called
-- It's also required for on_configuration_changed in case other mods have blatted technology_effects
-- reset_technology_effects()
--

script.on_init(function(event)
log("init")
	-- Used mainly for the case where a save game has been loaded but this mod had previously not been loaded
	-- But also on_init to unlock the Recycling versions of the game's initial recipes
	-- Recoded for https://github.com/DRY411S/Recycling-Machines/issues/49
	for _, nextforce in pairs(game.forces) do
		force = nextforce
		-- Enable the recycling machine if the equivalent assembling machine is enabled
		for i=1,3 do
			force.recipes["recycling-machine-" .. i].enabled = force.recipes["assembling-machine-" .. i].enabled
		end
		-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/64
		-- Flag everything that is available to the player at the start of the game, as recyclable,
		-- even though there are no recycling machines yet
		for _,v in pairs(force.recipes) do
			if v.enabled == true then
				ZRecycling.Unlock_Recipe(force,v.name)
			end
		end
	end
end
)

script.on_configuration_changed(function(event)
log("configchange")
	-- When other mods are loaded that weren't used before or have been changed, recycling recipes would have been produced
	-- I need to unlock the recycling recipes if the non-recycling recipe is itself unlocked
	-- Recoded for https://github.com/DRY411S/Recycling-Machines/issues/49
	for _, nextforce in pairs(game.forces) do
		force = nextforce
		-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/64
		-- Flag everything that is available to the player at the start of the game, as recyclable,
		-- even though there are no recycling machines yet
		for _,v in pairs(force.recipes) do
			if v.enabled == true then
				ZRecycling.Unlock_Recipe(force,v.name)
			end
		end
	end
end
)