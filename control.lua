-- v0.12 branch

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
	--game.player.print("Recipe: " .. recipename)
	-- Need to enable the reverse recipe for this one, in the Recycling group
	local recipe = force.recipes[recipename]
	if recipe then
		--error(serpent.block(recipe))
		--game.player.print("Recipe found: " .. recipename)
		-- Enable the reversed version
		local reverse_recipe = force.recipes[rec_prefix .. recipename]
		if reverse_recipe then
			--game.player.print("Reverse recipe found: " .. rec_prefix .. recipename)
			force.recipes[rec_prefix .. recipename].enabled = true
		else
			--game.player.print("Reverse recipe missing: " .. recipename)
		end
	else
		--game.player.print("Recipe passed by event is missing " .. recipename)
	end
end

-- LOCAL Variables
local force = nil

-- LOCAL functions

local function enable_reverse_recipes(event)

	for _, nextforce in pairs(game.forces) do
		force = nextforce
		-- Don't reverse anything until automation has been researched (which allows a recycling machine)
		if force.technologies["automation"].researched == true or event.research.name == "automation"then
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

-- GAME Event Handlers

script.on_event(defines.events.on_research_finished,function(event)
	if event.name == defines.events.on_research_finished then
		enable_reverse_recipes(event)
	end
end
)
