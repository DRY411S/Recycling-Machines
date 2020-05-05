--[[
	v0.18.8 05-May-2020
	This migration supports normal and expensive correctly
	adds new recipe properties for menus and tooltips
	and is a complete code rewrite of matching and recipe creation
	The mod setting for Recycling is removed, it never sat easily with the machine crafing factor
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