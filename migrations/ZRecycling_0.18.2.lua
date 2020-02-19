--[[
	v0.18.2 16-Feb-2020
	This migration adds the hide_from_player_crafting = true to all recycling recipes
	This means that the recycling tabs no longer appear in the player's menu
	A complaint from users since 2016!
--]]

require("constants")
local rec_prefix = constant_rec_prefix

for index, force in pairs(game.forces) do
  for name, recipe in pairs(force.recipes) do
	-- If this a reverse recipe
	if string.find(rec_prefix, name) ~= nil then
		--Add the property
		if recipe.normal.ingredients ~= nil then
			recipe.normal.hide_from_player_crafting = true
			recipe.expensive.hide_from_player_crafting = true
		else
			recipe.hide_from_player_crafting = true
		end
	end
  end
end