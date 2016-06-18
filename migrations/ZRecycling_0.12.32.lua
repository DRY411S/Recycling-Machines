--
-- Requested Enhancement
-- https://github.com/DRY411S/Recycling-Machines/issues/5

game.reload_script()

-- This variable and function are copies from constants.lua. Need to find a better way.
-- Globals?

local force = {}
local rec_prefix = "dry411srev-"

local function Unlock_Recipe(recipename)
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

for index, nextforce in pairs(game.forces) do
	nextforce.reset_recipes()
	nextforce.reset_technologies()

	-- Reenable reverse recipes where necessary
	force = nextforce
	if nextforce.technologies["automation"].researched and nextforce.technologies["automation"].researched == true then
		for _,v in pairs(force.recipes) do
			if v.enabled == true then
				Unlock_Recipe(v.name)
			end
		end
	end
	
	-- Unlock recycling machines if the appropriate research has completed
	if nextforce.technologies["automation"].researched and nextforce.technologies["automation"].researched == true then
		force.recipes["recycling-machine-1"].enabled = true
		Unlock_Recipe("recycling-machine-1")
	end
	if nextforce.technologies["automation-2"].researched and nextforce.technologies["automation-2"].researched == true then
		force.recipes["recycling-machine-2"].enabled = true
		Unlock_Recipe("recycling-machine-2")
	end
	if nextforce.technologies["automation-3"].researched and nextforce.technologies["automation-3"].researched == true then
		force.recipes["recycling-machine-3"].enabled = true
		Unlock_Recipe("recycling-machine-3")
	end
end

