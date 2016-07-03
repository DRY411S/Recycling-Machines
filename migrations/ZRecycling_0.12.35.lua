--
-- Requested Enhancement
-- https://github.com/DRY411S/Recycling-Machines/issues/5

game.reload_script()

-- This is a copy from control.lua. Make sure it is aligned.
-- GLOBAL functions
local rec_prefix = "dry411srev-"
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

local force = {}

for index, nextforce in pairs(game.forces) do
	nextforce.reset_recipes()
	nextforce.reset_technologies()

	-- Reenable reverse recipes where necessary
	force = nextforce
	if nextforce.technologies["automation"].researched and nextforce.technologies["automation"].researched == true then
		for _,v in pairs(force.recipes) do
			if v.enabled == true then
				ZRecycling.Unlock_Recipe(force,v.name)
			end
		end
	end
	
	-- Unlock recycling machines if the appropriate research has completed
	if nextforce.technologies["automation"].researched and nextforce.technologies["automation"].researched == true then
		force.recipes["recycling-machine-1"].enabled = true
		ZRecycling.Unlock_Recipe(force,"recycling-machine-1")
	end
	if nextforce.technologies["automation-2"].researched and nextforce.technologies["automation-2"].researched == true then
		force.recipes["recycling-machine-2"].enabled = true
		ZRecycling.Unlock_Recipe(force,"recycling-machine-2")
	end
	if nextforce.technologies["automation-3"].researched and nextforce.technologies["automation-3"].researched == true then
		force.recipes["recycling-machine-3"].enabled = true
		ZRecycling.Unlock_Recipe(force,"recycling-machine-3")
	end
end

