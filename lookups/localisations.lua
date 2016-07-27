-- Localisations involve a large lookup and are in this separate file to make it
-- easier to read the main code in data-final-fixes.lua, where this file is included
--
-- Used as a basis for locale determination. These were the v0.12 vanilla sub-groups found in development, left here for reference.
-- Mods produce others, v0.13 appears to have more. Mod subgroups will need to be handled for locale translation
validsubgroups =	{	
							-- "recycling-machine",
							-- "module",
							-- "logistic-network",
							-- "gun",
							-- "transport",
							-- "barrel",
							-- "equipment",
							-- "production-machine",
							-- "defensive-structure",
							-- "circuit-network",
							-- "energy-pipe-distribution",
							-- "inserter",
							-- "extraction-machine",
							-- "belt",
							-- "energy",
							-- "smelting-machine",
							-- "intermediate-product",
							-- "storage"
					}

-- Thanks to Mooncat https://forums.factorio.com/memberlist.php?mode=viewprofile&u=20664
-- and this advice https://forums.factorio.com/viewtopic.php?f=97&t=26039&p=183183#p183183
-- This has more sub-groups than in the 0.12 game and commented above.
-- Based on the subgroup name, this lookup table builds a locale string from the base.cfg locale
-- In English, "Recycled <item_being_recycled> parts" is displayed
locale_section = 	{
						--
						-- Vanilla
						--
						["recycling-machine"] = "entity-name.",
						["module"] = "item-name.",
						["logistic-network"] = "entity-name.",
						["gun"] = "item-name.",
						["transport"] = "entity-name.",
						["barrel"] = "item-name.",
						["equipment"] = "equipment-name.",
						["production-machine"] = "entity-name.",
						["defensive-structure"] = "entity-name.",
						["circuit-network"] = "item-name.",
						["energy-pipe-distribution"] = "entity-name.",
						["inserter"] = "entity-name.",
						["extraction-machine"] = "entity-name.",
						["belt"] = "entity-name.",
						["energy"] = "entity-name.",
						["smelting-machine"] = "entity-name.",
						["intermediate-product"] = "item-name.",
						["storage"] = "entity-name.",
						["tool"] = "item-name.",
						["science-pack"] = "item-name.",
						["ammo"] = "item-name.",
						["capsule"] = "item-name.",
						["armor"] = "item-name.",
						--
						-- Bob's Mods
						--
						-- Bob's Logistics
						["bob-storage"] = "entity-name.",
						["bob-belt"] = "item-name.",
						["bob-smart-inserter"] = "entity-name.",
						["bob-purple-inserter"] = "entity-name.",
						["pipe"] = "entity-name.",
						["pipe-to-ground"] = "entity-name.",
						["bob-transport"] = "entity-name.",
						["bob-logistic-robots"] = "entity-name.",
						["bob-logistic-roboport"] = "entity-name.",
						["bob-roboport-parts"] = "item-name.",
						-- Bob's Modules
						["module-intermediates"] = "item-name.",
						["speed-module"] = "item-name.",
						["effectivity-module"] = "item-name.",
						["productivity-module"] = "item-name.",
						["pollution-create-module"] = "item-name.",
						["pollution-clean-module"] = "item-name.",
						["raw-speed-module"] = "item-name.",
						["raw-speed-module-combine"] = "item-name.",
						["green-module"] = "item-name.",
						["green-module-combine"] = "item-name.",
						["raw-productivity-module"] = "item-name.",
						["raw-productivity-module-combine"] = "item-name.",
						["god-module"] = "item-name.",
						["module-beacon"] = "entity-name.",
						-- Bob's Power
						["bob-energy-boiler"] = "entity-name.",
						["bob-energy-steam-engine"] = "entity-name.",
						["bob-energy-solar-panel"] = "entity-name.",
						["bob-energy-accumulator"] = "entity-name.",
						-- Bob's Electronics
						["bob-fluid"] = "fluid-name.",
						["bob-resource-products"] = "item-name.",
						["bob-resource"] = "item-name.",
						["bob-resource-chemical"] = "item-name.",
						["bob-material-smelting"] = "item-name.",
						["bob-material-chemical"] = "item-name.",
						["bob-alloy"] = "item-name.",
						["bob-electronic-components"] = "item-name.",
						["bob-boards"] = "item-name.",
						["bob-electronic-boards"] = "item-name.",
						-- Bob's Warfare
						["bob-resource"] = "item-name.",
						["bob-ammo-parts"] = "item-name.",
						["bob-intermediates"] = "item-name.",
						["bob-robot-parts"] = "item-name.",
						["bob-gun"] = "item-name.",
						["bob-ammo"] = "item-name.",
						["bob-capsule"] = "item-name.",
						["bob-combat-robots"] = "item-name.",
						["bob-armor"] = "item-name.",
						["bob-equipment"] = "item-name.",
						-- Bob's Plates
						["bob-pump"] = "entity-name.",
						["bob-smelting-machine"] = "entity-name.",
						["bob-production-machine"] = "entity-name.",
						["bob-assembly-machine"] = "entity-name.",
						["bob-chemical-machine"] = "entity-name.",
						["bob-electrolyser-machine"] = "entity-name.",
						["bob-fluid"] = "fluid-name.",
						["bob-fluid-electrolysis"] = "entity-name.",
						["bob-gas-bottle"] = "item-name.",
						["bob-empty-gas-bottle"] = "item-name.",
						["bob-barrel"] = "item-name.",
						["bob-empty-barrel"] = "item-name.",
						["bob-canister"] = "item-name.",
						["bob-empty-canister"] = "item-name.",
						["bob-bearings"] = "item-name.",
						-- Bob's Greenhouse
						["bob-greenhouse"] = "entity-name.",
						["bob-greenhouse-items"] = "item-name.",
						-- Bob's Assembling Machines
						["bob-assembly-machine"] = "entity-name.",
						["bob-chemical-machine"] = "entity-name.",
						["bob-electrolyser-machine"] = "entity-name.",
						["bob-refinery-machine"] = "entity-name.",
						--
						-- Orbital Ion Cannon
						--
						-- Has a fix in my locale.cfg file
						--
						-- 5dim Mods
						--
						-- 5dim transport
						["liquid-store"] = "entity-name.",
						["store-solid"] = "entity-name.",
						["transport-belt"] = "entity-name.",
						["transport-ground"] = "entity-name.",
						["transport-ground-30"] = "entity-name.",
						["transport-ground-50"] = "entity-name.",
						["transport-splitters"] = "entity-name.",
						["transport-pipe-ground"] = "entity-name.",
						["transport-pipe-ground-30"] = "entity-name.",
						["transport-pipe-ground-50"] = "entity-name.",
						-- 5dim resources
						["masher"] = "entity-name.",
						-- 5dim mining
						["liquid-pump"] = "entity-name.",
						["mining-speed"] = "entity-name.",
						["mining-range"] = "entity-name.",
						-- 5dim automization
						["liquid-refinery"] = "entity-name.",
						["liquid-plant"] = "entity-name.",
						-- 5dim core
						-- Rocket silo locale also added
						["intermediate-lab"] = "item-name.",
						["intermediate-misc"] = "item-name.",
						["intermediate-chip"] = "item-name.",
						["intermediate-silo"] = "item-name.",
						["furnace-coal"] = "entity-name.",
						["furnace-electric"] = "entity-name.",
						["assembling-machine"] = "entity-name.",
						["lab"] = "item-name.",
						["pick"] = "item-name.",
						-- 5dim energy
						["energy-engine-1"] = "entity-name.",
						["energy-boiler"] = "entity-name.",
						["energy-offshore-pump"] = "entity-name.",
						["energy-small-pump"] = "entity-name.",
						["energy-accumulator"] = "entity-name.",
						["energy-solar-panel"] = "entity-name.",
						["energy-pole"] = "entity-name.",
						["energy-lamp"] = "entity-name.",
						-- 5dim inserters
						-- Filter inserter locale also added
						["inserters-burner"] = "entity-name.",
						["inserters-speed1"] = "entity-name.",
						["inserters-speed2"] = "entity-name.",
						["inserters-speed3"] = "entity-name.",
						["inserters-smart"] = "item-name.",
						["inserters-right"] = "item-name.",
						["inserters-left"] = "item-name.",
						-- 5dim logistic
						["logistic-robot"] = "entity-name.",
						["logistic-robot-c"] = "entity-name.",
						["logistic-roboport"] = "entity-name.",
						["logistic-pasive"] = "entity-name.",
						["logistic-requester"] = "entity-name.",
						["logistic-storage"] = "entity-name.",
						["logistic-active"] = "entity-name.",
						["logistic-wire"] = "item-name.",
						["logistic-beacon"] = "entity-name.",
						["logistic-comb"] = "entity-name.",
						["repair"] = "item-name.",
						-- 5dim module
						["speed"] = "item-name.",
						["effectivity"] = "item-name.",
						["productivity"] = "item-name.",
						["pollution"] = "item-name.",
						["welder"] = "item-name.",
						-- 5dim trains
						["trains-rails"] = "entity-name.",
						["trains-locomotive"] = "entity-name.",
						["trains-misc"] = "entity-name.",
						-- 5dim battlefield
						["defense-gun"] = "entity-name.",
						["defense-laser"] = "entity-name.",
						["defense-flame"] = "entity-name.",
						["defense-wall"] = "entity-name.",
						["defense-gate"] = "entity-name.",
						["defense-radar"] = "entity-name.",
						-- 5dim armor
						["armor-bullet"] = "item-name.",
						["armor-shotgun"] = "item-name.",
						["armor-rocket"] = "item-name.",
						["armor-flame"] = "item-name.",
						["armor-capsule"] = "item-name.",
						["armor-armor"] = "item-name.",
						["armor-dmg"] = "equipment-name.",
						["armor-util"] = "equipment-name.",
						-- 5dim vehicle
						-- tank locale also added
						["vehicles-car"] = "entity-name.",
						["vehicles-truck"] = "entity-name.",
						["vehicles-air"] = "entity-name.",
						["vehicles-tank"] = "item-name.",
						["vehicles-boat"] = "entity-name.",
						["vehicles-arty"] = "item-name.",
						-- 5dim decoration
						["decoration-banner"] = "entity-name.",
						["decoration-arrow"] = "entity-name.",
						["decoration-letter"] = "entity-name.",
						--
						-- Yuoki
						--
						-- Yuoki Industries
						-- y_drillhead locale also added
						-- y_toolhead locale also added
						["y_line1"] = "entity-name.",
						["y_line2"] = "entity-name.",
						["y-c_mud"] = "item-name.",
						["yuoki-formpress"] = "entity-name.",
						["y-storage"] = "entity-name.",
						["yuoki-archaeology"] = "item-name.",
						["y-defense"] = "entity-name.",
						["y-parts"] = "item-name.",
						["y_defense_walls"] = "entity-name.",
						["y-ammo"] = "item-name.",
						["y_line9"] = "entity-name.",
						["y-tools"] = "item-name.",
						-- Yuoki Energy
						["y-lamps"] = "entity-name.",
						["y-fame"] = "item-name.",
						["y-energy"] = "entity-name.",
						["y-energy-2"] = "entity-name.",
						["y-electric"] = "item-name.",
						["y-battery-single-use1"] = "item-name.",
						["y-tech"] = "entity-name.",
						["y-coal-brikett"] = "item-name.",
						["y-fuel"] = "item-name.",
						["y-coal-dust"] = "item-name.",
						["y-boiler"] = "entity-name.",
						["y-module"] = "item-name.",
						["ye_science_blue"] = "entity-name.",
						["ypfw_trader_sign"] = "entity-name.",
						["y_mastercrafted"] = "entity-name.",
						--Yuoki Atomics
						["y-stargate-r"] = "item-name.",
						["y_greensign"] = "item-name.",
						["y_rwtechsign"] = "item-name.",
						-- Yuoki Liquids
						["y-fluid-storage"] = "entity-name.",
						["y-unicomp-a2"] = "entity-name.",
						["y-unicomp-raw"] = "entity-name.",
						["y-pipe"] = "entity-name.",
						["y_refine_machinery"] = "entity-name.",
						["y_refine_parts"] = "entity-name.",
						["y_structure_vessel"] = "item-name.",
						["y_refine_material"] = "item-name.",
						--["name"] = "thing-name.",
					}
