--
-- Requested Enhancement
-- https://github.com/DRY411S/Recycling-Machines/issues/5

game.reload_script()

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

