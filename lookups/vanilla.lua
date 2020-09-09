-- All the different types and subgroups in vanilla factorio (as of v0.18.3)
-- This is used as a debug to check for types and subgroups introduced by mods, that aren't in vanilla
-- The code to dump these group names is:
--[[
local typesfound = {}
local subgroup ={}
for name, this in pairs(data.raw) do
if typesfound[name] == nil then
table.insert(typesfound,name)
end
for _,validtype in pairs(data.raw[name]) do
	-- For all 'item' prototypes in this type
	if data.raw[name] == nil then
		error("Error Type: " .. validtype)
	end
	for name, item in pairs(data.raw[name]) do
		local found = false
		for _, v in pairs(subgroup) do
			if v == item.subgroup then
				found = true
			end
		end
		if not found and item.subgroup ~= nil then
			table.insert(subgroup,item.subgroup)
		end
	end
end
end
table.sort(typesfound)
log(serpent.block(typesfound))
table.sort(subgroup)
log(serpent.block(subgroup))
]]--


vanillatypes = {
  "accumulator",
  "achievement",
  "active-defense-equipment",
  "ambient-sound",
  "ammo",
  "ammo-category",
  "ammo-turret",
  "arithmetic-combinator",
  "armor",
  "arrow",
  "artillery-flare",
  "artillery-projectile",
  "artillery-turret",
  "artillery-wagon",
  "assembling-machine",
  "autoplace-control",
  "battery-equipment",
  "beacon",
  "beam",
  "belt-immunity-equipment",
  "blueprint",
  "blueprint-book",
  "boiler",
  "build-entity-achievement",
  "burner-generator",
  "capsule",
  "car",
  "cargo-wagon",
  "character",
  "character-corpse",
  "cliff",
  "combat-robot",
  "combat-robot-count",
  "constant-combinator",
  "construct-with-robots-achievement",
  "construction-robot",
  "container",
  "copy-paste-tool",
  "corpse",
  "curved-rail",
  "custom-input",
  "damage-type",
  "decider-combinator",
  "deconstruct-with-robots-achievement",
  "deconstructible-tile-proxy",
  "deconstruction-item",
  "decorative",
  "deliver-by-robots-achievement",
  "dont-build-entity-achievement",
  "dont-craft-manually-achievement",
  "dont-use-entity-in-energy-production-achievement",
  "editor-controller",
  "electric-energy-interface",
  "electric-pole",
  "electric-turret",
  "energy-shield-equipment",
  "entity-ghost",
  "equipment-category",
  "equipment-grid",
  "explosion",
  "finish-the-game-achievement",
  "fire",
  "fish",
  "flame-thrower-explosion",
  "fluid",
  "fluid-turret",
  "fluid-wagon",
  "flying-text",
  "font",
  "fuel-category",
  "furnace",
  "gate",
  "generator",
  "generator-equipment",
  "god-controller",
  "group-attack-achievement",
  "gui-style",
  "gun",
  "heat-interface",
  "heat-pipe",
  "highlight-box",
  "infinity-container",
  "infinity-pipe",
  "inserter",
  "item",
  "item-entity",
  "item-group",
  "item-request-proxy",
  "item-subgroup",
  "item-with-entity-data",
  "item-with-inventory",
  "item-with-label",
  "item-with-tags",
  "kill-achievement",
  "lab",
  "lamp",
  "land-mine",
  "leaf-particle",
  "loader",
  "loader-1x1",
  "locomotive",
  "logistic-container",
  "logistic-robot",
  "map-gen-presets",
  "map-settings",
  "market",
  "mining-drill",
  "mining-tool",
  "module",
  "module-category",
  "mouse-cursor",
  "movement-bonus-equipment",
  "night-vision-equipment",
  "noise-expression",
  "noise-layer",
  "offshore-pump",
  "optimized-decorative",
  "optimized-particle",
  "particle",
  "particle-source",
  "pipe",
  "pipe-to-ground",
  "player-damaged-achievement",
  "player-port",
  "power-switch",
  "produce-achievement",
  "produce-per-hour-achievement",
  "programmable-speaker",
  "projectile",
  "pump",
  "radar",
  "rail-chain-signal",
  "rail-planner",
  "rail-remnants",
  "rail-signal",
  "reactor",
  "recipe",
  "recipe-category",
  "repair-tool",
  "research-achievement",
  "resource",
  "resource-category",
  "roboport",
  "roboport-equipment",
  "rocket-silo",
  "rocket-silo-rocket",
  "rocket-silo-rocket-shadow",
  "selection-tool",
  "shortcut",
  "simple-entity",
  "simple-entity-with-force",
  "simple-entity-with-owner",
  "smoke",
  "smoke-with-trigger",
  "solar-panel",
  "solar-panel-equipment",
  "sound",
  "spectator-controller",
  "speech-bubble",
  -- New in v1.0
  "spidertron-remote",
  "spider-vehicle",
  "spider-leg",
  -- End v1.0 newness
  "splitter",
  "sprite",
  "sticker",
  "storage-tank",
  "straight-rail",
  "stream",
  "technology",
  "tile",
  "tile-effect",
  "tile-ghost",
  "tool",
  "train-path-achievement",
  "train-stop",
  "transport-belt",
  "tree",
  "trigger-target-type",
  "trivial-smoke",
  "turret",
  "tutorial",
  "underground-belt",
  "unit",
  "unit-spawner",
  "upgrade-item",
  "utility-constants",
  "utility-sounds",
  "utility-sprites",
  "virtual-signal",
  "wall",
  "wind-sound"
}


vanillasubgroups =  {
  "ammo",
  "armor",
  "belt",
  "capsule",
  "circuit-network",
  "cliffs",
  "corpses",
  "crash-site",
  "creatures",
  "defensive-structure",
  "empty-barrel",
  "enemies",
  "energy",
  "energy-pipe-distribution",
  "equipment",
  "explosions",
  "extraction-machine",
  "fill-barrel",
  "fluid",
  "fluid-recipes",
  "grass",
  "gun",
  "hit-effects",
  "inserter",
  "intermediate-product",
  "logistic-network",
  "module",
  "other",
  "particles",
  "production-machine",
  "raw-material",
  "raw-resource",
  "recycling-machine",
  "remnants",
  "science-pack",
  "smelting-machine",
  "storage",
  "terrain",
  "tool",
  "transport",
  "trees",
  "virtual-signal",
  "virtual-signal-color",
  "virtual-signal-letter",
  "virtual-signal-number",
  "virtual-signal-special",
  "wrecks"
}


-- Item-groups the vanilla game. Some visible in crafting menus, some not
-- from _, group in pairs(data.raw["item-group"]) group.name
vanillaitem_groups = {
"signals",
"other",
"environment",
"enemies",
"logistics",
"production",
"combat",
"intermediate-products",
"fluids",
"effects",
"Recycling" -- not vanilla. This mod!
}

-- Vanilla recipe crafting (including Recycling Machines)
--[[
local vanillacrafts = {}
for _,recipe in pairs(data.raw.recipe) do
	if recipe.category ~= nil then
		local catfound = false
		for _,craft in pairs(vanillacrafts) do
			if recipe.category == craft then
				catfound = true
				break
			end
		end
		if not catfound then
			table.insert(vanillacrafts,recipe.category)
		end
	end
end
table.sort(vanillacrafts)
log(serpent.block(vanillacrafts))
]]--
vanillacrafts = {
  "advanced-crafting",
  "centrifuging",
  "chemistry",
  "crafting",
  "crafting-with-fluid",
  "oil-processing",
  "recycling-1",
  "recycling-with-fluid",
  "rocket-building",
  "smelting"
}