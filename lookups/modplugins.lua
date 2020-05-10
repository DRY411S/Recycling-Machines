--[[
	TODO: This file will contain extensions to data tables to allow support for mods
	Mods extend the vanilla Recycling Machines mod with additional:
		Crafting methods that need an equivalent recycling method or to be excluded from Recycling
		Prototype 'types' that extend the base
		Item groups (tabs in the player crafting menu) that need to appear in Recycling Machines
		subgroups that I may not want to handle in the mod
		locale (not handled here)
]]--

--[[
	TODO: Reintroduce this code lifted from its inline insertion in the mod
]]--

--[[
	Crafting methods

-- Special crafting for Yuoki Industries
-- TODO: Maybe constrain this to allow recycling of things that can only be assembled
-- TODO: Wait for feedback
craftingbeforeandafter["yuoki-alien-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-archaeology-wash"] = "recycling-with-fluid"
craftingbeforeandafter["yuoki-atomics-recipe"] = "recycling-"
craftingbeforeandafter["y-crushing-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-fame-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-formpress-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-raw-material-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-repair-recipe"] = "recycling-"
craftingbeforeandafter["yuoki-stargate-recipe"] = "recycling-"
craftingbeforeandafter["yuoki_trader_ultimate"] = "recycling-"
craftingbeforeandafter["yuoki-watergen-recipe"] = "recycling-with-fluid"
craftingbeforeandafter["yuoki-wonder-recipe"] = "recycling-"
]]--	

--[[
	New types
local validtypes =	{	

						-- Yuoki (is also used by vanilla but there are no recipes)
						"container",
                        -- "item-with-tags" used in Useful Combinators
                        "item-with-tags"
					}
--]]
					
--[[
	Item group tabs
-- Item-group icons for Recycling
groups_supported =	{
								--
								-- DyTech
								--
								["dytech-combat"] = "__ZRecycling__/graphics/item-group/DyTech-Core/combat.png",
								["dytech-energy"] = "__ZRecycling__/graphics/item-group/DyTech-Core/energy.png",
								["dytech-gem"] = "__ZRecycling__/graphics/item-group/DyTech-Core/gem.png",
								["dytech-inserter"] = "__ZRecycling__/graphics/item-group/DyTech-Core/inserter.png",
								["dytech-intermediates"] = "__ZRecycling__/graphics/item-group/DyTech-Core/intermediates.png",
								["dytech-machines"] = "__ZRecycling__/graphics/item-group/DyTech-Core/machines.png",
								["dytech-modules"] = "__ZRecycling__/graphics/item-group/DyTech-Core/modules.png",
								["dytech-metallurgy"] = "__ZRecycling__/graphics/item-group/DyTech-Core/metallurgy.png",
								["dytech-nuclear"] = "__ZRecycling__/graphics/item-group/DyTech-Core/nuclear.png",
								["dytech-invisible"] = "__ZRecycling__/graphics/item-group/DyTech-Core/danger.png",
								--
								-- Yuoki
								--
								["yuoki"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-ind-icon.png",
								["yuoki-energy"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-energy.png",
								["yuoki-atomics"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-atomics-icon.png",
								["yuoki_liquids"] = "__ZRecycling__/graphics/item-group/yuoki/yuoki-liquids.png",
                                --
                                -- Useful combinators
                                --
                                ["default"] = "__ZRecycling__/graphics/item-group/useful/clock.png",
					)
]]--

--[[
	Subgroups
local validsubgroups = {	
							-- Yuoki
							"y-raw-material",
						}
]]--

--[[
	Mod handling starts here
]]--
ignoredcrafts = {}
modsubgroups = {}
groups_supported = {}

--[[
	*** EXPERIMENTAL *** ADD all item groups,unconditionally ***
	*** If there are no recycling items in that group, then the tab does not display anyway ***
	*** MODS can overload other mods icons so need to test for this ***
	*** https://wiki.factorio.com/Types/IconSpecification ***
	*** DO VANILLA HERE BECAUSE OF THE ABOVE ***
]]--
for k,v in pairs(data.raw["item-group"]) do
	groups_supported[k] = {
							icon = v.icon,
							icon_size = v.icon_size,
							scale = v.scale,
							["shift"] = v.shift
						}
	if v.icons ~= nil then
		groups_supported[k].icons = {}
		for i,j in ipairs(v.icons) do
			groups_supported[k].icons[i] = j
		end
	end
end

-- Model
if mods["model"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Test locale	
end

-- Bob's Metals, Chemicals and Intermediates (bobplates)
if mods["bobplates"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["crafting-machine"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"distillery")
	table.insert(ignoredcrafts,"air-pump")
	table.insert(ignoredcrafts,"electrolysis")
	table.insert(ignoredcrafts,"chemical-furnace")
	table.insert(ignoredcrafts,"mixing-furnace")
	table.insert(ignoredcrafts,"void-fluid")
	table.insert(ignoredcrafts,"barrelling")
	-- Add types
	-- Add item-groups
	-- None for bobplates
	-- Test locale	
end

-- Bob's Modules (bobmodules)
if mods["bobmodules"] ~= nil or mods["bobelectronics"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["electronics"] = "recycling-"
	craftingbeforeandafter["electronics-machine"] = "recycling-with-fluid"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"crafting-machine")
	-- Add types
	-- None for bobmodules
	-- Add item-groups
	-- Test locale	
end

-- Bob's Greenhouse (bobgreenhouse)
if mods["bobgreenhouse"] ~= nil then
	-- Add crafting methods
	-- None for bobgreenhouse
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"bob-greenhouse")
	-- Add types
	-- None for bobgreenhouse
	-- Add item-groups
	-- None for bobgreenhouse
	-- Test locale	
end

-- All other Bob's mods should be supported now

--[[
	Angels
]]--

-- Angel's Refining
if mods["angelsrefining"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"barreling-pump")
	table.insert(ignoredcrafts,"liquifying")
	table.insert(ignoredcrafts,"filtering")
	table.insert(ignoredcrafts,"ore-sorting")
	table.insert(ignoredcrafts,"ore-sorting-t1")
	table.insert(ignoredcrafts,"ore-sorting-t1-5")
	table.insert(ignoredcrafts,"ore-sorting-t2")
	table.insert(ignoredcrafts,"ore-sorting-t3")
	table.insert(ignoredcrafts,"ore-sorting-t3-5")
	table.insert(ignoredcrafts,"ore-sorting-t4")
	table.insert(ignoredcrafts,"crystallizing")
	table.insert(ignoredcrafts,"water-treatment")
	table.insert(ignoredcrafts,"salination-plant")
	table.insert(ignoredcrafts,"washing-plant")
	table.insert(ignoredcrafts,"angels-water-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"fluids-refining")
	-- Test locale	
end

-- Angel's Petro Chemical Processing
if mods["angelspetrochem"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"petrochem-electrolyser")
	table.insert(ignoredcrafts,"advanced-chemistry")
	table.insert(ignoredcrafts,"petrochem-separation")
	table.insert(ignoredcrafts,"gas-refining")
	table.insert(ignoredcrafts,"steam-cracking")
	table.insert(ignoredcrafts,"petrochem-air-filtering")
	table.insert(ignoredcrafts,"angels-converter")
	table.insert(ignoredcrafts,"angels-chemical-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Fixes: https://github.com/DRY411S/Recycling-Machines/issues/77
	table.insert(invalidsubgroups,"angels-stone-casting")
	-- Test locale	
end

-- Angel's Smelting
if mods["angelssmelting"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["pellet-pressing"] = "recycling-"
	craftingbeforeandafter["powder-mixing"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"blast-smelting")
	table.insert(ignoredcrafts,"induction-smelting")
	table.insert(ignoredcrafts,"strand-casting")
	table.insert(ignoredcrafts,"casting")
	table.insert(ignoredcrafts,"ore-processing")
	table.insert(ignoredcrafts,"chemical-smelting")
	table.insert(ignoredcrafts,"cooling")
	table.insert(ignoredcrafts,"sintering")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"fluids-smelting")
	-- Test locale	
end

-- Angel's Bio Processing
if mods["angelsbioprocessing"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["bio-processor"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"bio-processing")
	table.insert(ignoredcrafts,"angels-tree")
	table.insert(ignoredcrafts,"angels-arboretum")
	table.insert(ignoredcrafts,"angels-tree-temperate")
	table.insert(ignoredcrafts,"angels-tree-swamp")
	table.insert(ignoredcrafts,"angels-tree-desert")
	table.insert(ignoredcrafts,"seed-extractor")
	table.insert(ignoredcrafts,"temperate-farming")
	table.insert(ignoredcrafts,"desert-farming")
	table.insert(ignoredcrafts,"swamp-farming")
	table.insert(ignoredcrafts,"nutrient-extractor")
	table.insert(ignoredcrafts,"bio-pressing")
	table.insert(ignoredcrafts,"bio-refugium-fish")
	table.insert(ignoredcrafts,"bio-butchery")
	table.insert(ignoredcrafts,"bio-refugium-puffer")
	table.insert(ignoredcrafts,"bio-hatchery")
	table.insert(ignoredcrafts,"bio-refugium-biter")
	table.insert(ignoredcrafts,"bio-refugium-hogger")
	table.insert(ignoredcrafts,"angels-bio-void")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
--	table.insert(invalidsubgroups,"fluids-smelting")
	-- Test locale	
end

-- Angel's Industries
if mods["angelsindustries"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

-- Bio Industries
if mods["Bio_Industries"] ~= nil then
	-- Add crafting methods
	-- None
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"biofarm-mod-greenhouse")
	table.insert(ignoredcrafts,"biofarm-mod-farm")
	table.insert(ignoredcrafts,"biofarm-mod-crushing")
	table.insert(ignoredcrafts,"biofarm-mod-smelting")
	table.insert(ignoredcrafts,"bi-arboretum")
	table.insert(ignoredcrafts,"clean-air")
	table.insert(ignoredcrafts,"biofarm-mod-bioreactor")
	-- Add types
	-- Add item-groups
	-- Test locale	
end

-- AAI Industry
if mods["aai-industry"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"fuel-processing")
	-- Add types
	-- Add item-groups
	-- Test locale	
end

--[[
	5dim
]]--

if mods["5dim_core"] ~= nil then
	-- Add crafting methods
--[[
   mashering
   industrial-furnace
   trade
]]--
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"decoration-floor")
	-- Test locale	
end

if mods["5dim_mining"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"water")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["5dim_module"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["welding"] = "recycling-"
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["5dim_ores"] ~= nil or mods["5dim_resources"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"mashering")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["5dim_resources"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"industrial-furnace")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end
 
if mods["5dim_trade"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["trade"] = "recycling-"
	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["WaterWell"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"water-well-production")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

--[[
	Pyanodon
	Many of Pyandon recipes involve more than 1 fluid either as input or output
	sometimes both. In fact there are very few Pyanodon recipes that can be recycled
	because Recycling Machines have only 1 fluid interface, either input or output
	And most also have more than 1 result, but Recycling Machines will accept only
	one ingredient
	Most of the Pyandon recipes are therefore flagged as not recyclable for this reason
	and their recipe crafting categories don't need to be explicitly excluded here
	Nevertheless, the code belows does exclude them so there is a clear record
--]]

if mods["pycoalprocessing"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["glassworks"] = "recycling-"
	craftingbeforeandafter["tar"] = "recycling-with-fluid"
	craftingbeforeandafter["solid-separator"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"fts-reactor")
	table.insert(ignoredcrafts,"ulric")
	table.insert(ignoredcrafts,"gasifier")
	table.insert(ignoredcrafts,"ralesia")
	table.insert(ignoredcrafts,"niobium")
	table.insert(ignoredcrafts,"fawogae")
	table.insert(ignoredcrafts,"advanced-foundry")
	table.insert(ignoredcrafts,"ground-borer")
	table.insert(ignoredcrafts,"wpu")
	table.insert(ignoredcrafts,"ball-mill")
	table.insert(ignoredcrafts,"carbonfilter")
	table.insert(ignoredcrafts,"classifier")
	table.insert(ignoredcrafts,"desulfurization")
	table.insert(ignoredcrafts,"distilator")
	table.insert(ignoredcrafts,"evaporator")
	table.insert(ignoredcrafts,"fluid-separator")
	table.insert(ignoredcrafts,"hpf")
	table.insert(ignoredcrafts,"methanol")
	table.insert(ignoredcrafts,"olefin")
	table.insert(ignoredcrafts,"crusher")
	table.insert(ignoredcrafts,"combustion")
	table.insert(ignoredcrafts,"quenching-tower")
	table.insert(ignoredcrafts,"rectisol")
	table.insert(ignoredcrafts,"co2")
	table.insert(ignoredcrafts,"cooling")
	table.insert(ignoredcrafts,"washer")
	table.insert(ignoredcrafts,"soil-extraction")
	table.insert(ignoredcrafts,"sand-extractor")
	table.insert(ignoredcrafts,"nursery")
	table.insert(ignoredcrafts,"mukmoux")
	table.insert(ignoredcrafts,"borax")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["pyindustry"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"py-runoff")
	table.insert(ignoredcrafts,"py-venting")
	table.insert(ignoredcrafts,"py-incineration")
	table.insert(ignoredcrafts,"hydroclassifier")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"py-tiles")
	-- Test locale	
end

if mods["pyrawores"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["handcrafting"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"bof")
	table.insert(ignoredcrafts,"casting")
	table.insert(ignoredcrafts,"eaf")
	table.insert(ignoredcrafts,"electrolyzer")
	table.insert(ignoredcrafts,"flotation")
	table.insert(ignoredcrafts,"impact-crusher")
	table.insert(ignoredcrafts,"leaching")
	table.insert(ignoredcrafts,"scrubber")
	table.insert(ignoredcrafts,"wet-scrubber")
	table.insert(ignoredcrafts,"flotation")
	table.insert(ignoredcrafts,"sinter")
	table.insert(ignoredcrafts,"drp")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- table.insert(invalidsubgroups,"py-tiles")
	-- Test locale	
end

if mods["pyfusionenergy"] ~= nil then
	-- Add crafting methods
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"heat-exchanger")
	table.insert(ignoredcrafts,"nmf")
	table.insert(ignoredcrafts,"hydrocyclone")
	table.insert(ignoredcrafts,"plankton")
	table.insert(ignoredcrafts,"xyhiphoe")
	table.insert(ignoredcrafts,"thickener")
	table.insert(ignoredcrafts,"screener")
	table.insert(ignoredcrafts,"secondary-crusher")
	table.insert(ignoredcrafts,"grease")
	table.insert(ignoredcrafts,"genlab")
	table.insert(ignoredcrafts,"kmauts")
	table.insert(ignoredcrafts,"compressor")
	table.insert(ignoredcrafts,"gas-separator")
	table.insert(ignoredcrafts,"mixer")
	table.insert(ignoredcrafts,"fusion-01")
	table.insert(ignoredcrafts,"fusion-02")
	table.insert(ignoredcrafts,"agitator")
	table.insert(ignoredcrafts,"vacuum")
	table.insert(ignoredcrafts,"pan")
	table.insert(ignoredcrafts,"jig")
	table.insert(ignoredcrafts,"bio-reactor")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["pyhightech"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["glassworks"] = "recycling-with-fluid"
	-- ++coal processing ^
	craftingbeforeandafter["chip"] = "recycling-"
	craftingbeforeandafter["nano"] = "recycling-with-fluid"
	craftingbeforeandafter["electronic"] = "recycling-with-fluid"
	craftingbeforeandafter["pcb"] = "recycling-with-fluid"
	craftingbeforeandafter["handcrafting"] = "recycling-"
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"fbreactor")
	table.insert(ignoredcrafts,"auog")
	table.insert(ignoredcrafts,"clay")
	table.insert(ignoredcrafts,"pulp")
	table.insert(ignoredcrafts,"kicalk")
	table.insert(ignoredcrafts,"pa")
	table.insert(ignoredcrafts,"zipir")
	table.insert(ignoredcrafts,"quantum")
	table.insert(ignoredcrafts,"moon")
	table.insert(ignoredcrafts,"arum")
	table.insert(ignoredcrafts,"blackhole-energy")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["pypetroleumhandling"] ~= nil then
	-- Add crafting methods
	-- None, treating all these as chemical reactions
	-- and therefore not recyclable
	-- NOTE: havent actually bothered to check
	-- Losing the will to live with Pyanodon!
	-- Ignore crafting methods
	table.insert(ignoredcrafts,"upgrader")
	table.insert(ignoredcrafts,"cracker")
	table.insert(ignoredcrafts,"reformer")
	table.insert(ignoredcrafts,"hor")
	table.insert(ignoredcrafts,"gas-refinery")
	table.insert(ignoredcrafts,"guar")
	table.insert(ignoredcrafts,"lor")
	table.insert(ignoredcrafts,"kerogen")
	table.insert(ignoredcrafts,"pumpjack")
	table.insert(ignoredcrafts,"tholin-plant")
	table.insert(ignoredcrafts,"coalbed")
	table.insert(ignoredcrafts,"fracking")
	table.insert(ignoredcrafts,"rhe")
	table.insert(ignoredcrafts,"tholin-atm")
	table.insert(ignoredcrafts,"converter-valve")
	table.insert(ignoredcrafts,"hot-air-advanced-foundry")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	-- Test locale	
end

if mods["pyalienlife"] ~= nil then
	-- Add crafting methods
	table.insert(ignoredcrafts,"research")
	table.insert(ignoredcrafts,"biofactory")
	table.insert(ignoredcrafts,"fwf")
	table.insert(ignoredcrafts,"creature-chamber")
	table.insert(ignoredcrafts,"incubator")
	table.insert(ignoredcrafts,"data-array")
	table.insert(ignoredcrafts,"sap")
	table.insert(ignoredcrafts,"slaughterhouse")
	table.insert(ignoredcrafts,"atomizer")
	table.insert(ignoredcrafts,"micro-mine")
	table.insert(ignoredcrafts,"moss")
	table.insert(ignoredcrafts,"seaweed")
	table.insert(ignoredcrafts,"bay")
	table.insert(ignoredcrafts,"sponge")
	table.insert(ignoredcrafts,"tuuphra")
	table.insert(ignoredcrafts,"arthurian")
	table.insert(ignoredcrafts,"spore")
	table.insert(ignoredcrafts,"navens")
	table.insert(ignoredcrafts,"yotoi")
	table.insert(ignoredcrafts,"dhilmos")
	table.insert(ignoredcrafts,"scrondrix")
	table.insert(ignoredcrafts,"rennea")
	table.insert(ignoredcrafts,"dingrits")
	table.insert(ignoredcrafts,"phadai")
	table.insert(ignoredcrafts,"slaughterhouse-fish")
	table.insert(ignoredcrafts,"fish-farm")
	table.insert(ignoredcrafts,"korlex")
	table.insert(ignoredcrafts,"yaedols")
	table.insert(ignoredcrafts,"slaughterhouse-ulric")
	table.insert(ignoredcrafts,"vonix")
	table.insert(ignoredcrafts,"slaughterhouse-vonix")
	table.insert(ignoredcrafts,"slaughterhouse-mukmoux")
	table.insert(ignoredcrafts,"bhoddos")
	table.insert(ignoredcrafts,"phagnot")
	table.insert(ignoredcrafts,"slaughterhouse-phagnot")
	table.insert(ignoredcrafts,"cridren")
	table.insert(ignoredcrafts,"grod")
	table.insert(ignoredcrafts,"slaughterhouse-arthurian")
	table.insert(ignoredcrafts,"slaughterhouse-auog")
	table.insert(ignoredcrafts,"slaughterhouse-dingrits")
	table.insert(ignoredcrafts,"slaughterhouse-korlex")
	table.insert(ignoredcrafts,"slaughterhouse-dhilmos")
	table.insert(ignoredcrafts,"slaughterhouse-scrondrix")
	table.insert(ignoredcrafts,"slaughterhouse-phadai")
	table.insert(ignoredcrafts,"xeno")
	table.insert(ignoredcrafts,"trits")
	table.insert(ignoredcrafts,"vat")
	table.insert(ignoredcrafts,"ralesia-farm")
	table.insert(ignoredcrafts,"rennea-farm")
	table.insert(ignoredcrafts,"tuuphra-farm")
	table.insert(ignoredcrafts,"grod-farm")
	table.insert(ignoredcrafts,"yotoi-farm")
	table.insert(ignoredcrafts,"bioreserve-farm")
	table.insert(ignoredcrafts,"slaughterhouse-zipir")
	table.insert(ignoredcrafts,"slaughterhouse-xyhiphoe")
	table.insert(ignoredcrafts,"slaughterhouse-trits")
	table.insert(ignoredcrafts,"slaughterhouse-xeno")
	table.insert(ignoredcrafts,"vrauks")
	table.insert(ignoredcrafts,"slaughterhouse-vrauks")
	table.insert(ignoredcrafts,"slaughterhouse-cottongut")
	table.insert(ignoredcrafts,"slaughterhouse-kmauts")
	table.insert(ignoredcrafts,"slaughterhouse-arqad")
	table.insert(ignoredcrafts,"slaughterhouse-cridren")
	table.insert(ignoredcrafts,"bio-printer")
	table.insert(ignoredcrafts,"cottongut")
	table.insert(ignoredcrafts,"arqad")
	table.insert(ignoredcrafts,"compost")
	table.insert(ignoredcrafts,"kicalk-farm")
	table.insert(ignoredcrafts,"arum-farm")
	table.insert(ignoredcrafts,"antelope")
	table.insert(ignoredcrafts,"slaughterhouse-antelope")
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"py-alienlife-food")
	table.insert(invalidsubgroups,"py-alienlife-plants")
	table.insert(invalidsubgroups,"py-alienlife-latex")
	table.insert(invalidsubgroups,"py-alienlife-yotoi")
	table.insert(invalidsubgroups,"py-alienlife-genetics")
	-- Test locale	
end

--[[
	Yuoki

-- Yuoki Railways
if mods["yi_railway"] ~= nil then
	-- Add crafting methods
	craftingbeforeandafter["yir_rc_future_monument"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_diesel_monument"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_wsl"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_wsw"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_material"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_stuff"] = "recycling-with-fluid"
	craftingbeforeandafter["yir_rc_tiles"] = "recycling-with-fluid"	-- Ignore crafting methods
	-- Add types
	-- Add item-groups
	-- Add invalid sub-groups
	table.insert(invalidsubgroups,"yir_floor")
	table.insert(invalidsubgroups,"yir_floor_line2")
	table.insert(invalidsubgroups,"yir_floor_line3")
	-- Test locale	
end
]]--

--[[
	Load the data structures that document all the types, item-groups, and item-subgrupds that exist in vanilla
	First add a table (for debug purposes of all the item-subgroups introduced by mods, then
	run some debug code to write into the log the identities of discovered protypes that the mod does not currently handle
]]--
require("lookups.vanilla")

-- Add modded item-subgroups for all supported item-groups
for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
	local matched = false
	groupname = subgroup.name
	for _,invalidsubgroup in pairs(invalidsubgroups) do
		if invalidsubgroup == subgroupname then
			matched = true
			break
		end
	end
	if not matched then
		for _,subname in pairs(vanillasubgroups) do
			if subname == subgroup.name then
				matched = true
				break
			end
		end
	end
	if not matched then
		for group,icon in pairs(groups_supported) do
			if subgroup.group == group then
				matched = true
				table.insert(modsubgroups,subgroup.name)
				break
			end
		end
	end
end -- each subgroup
-- log(serpent.block(modsubgroups))
--[[
	*** DEBUG SECTION FROM HERE ***
	Identify whether there are new prototypes that this mod does not handle.
	If so, publish warnings in the log. These are not mod breaking,
	but good to know for future inclusion
]]--

-- Item-groups
for _, group in pairs(data.raw["item-group"]) do
	local matched = false
	for _, vanilla in pairs(vanillaitem_groups) do
		if group.name == vanilla then
			matched = true
			break
		end
	end
	if not matched then
		for modded,_ in pairs(groups_supported) do
			if group.name == modded then
				matched = true
				break
			end
		end
	end
	if not matched then
		log("Warning: Recycling Machines unsupported item-group: " .. group.name)
	end
end

--Subgroups
for subgroupname, subgroup in pairs(data.raw["item-subgroup"]) do
	local matched = false
	groupname = subgroup.name
	for _,invalidsubgroup in pairs(invalidsubgroups) do
		if invalidsubgroup == subgroupname then
			matched = true
			break
		end
	end
	if not matched then
		for _, vanilla in pairs(vanillasubgroups) do
			if groupname == vanilla then
				matched = true
				break
			end
		end
	end
	if not matched then
		for _,subgroup in pairs(modsubgroups) do
			if groupname == subgroup then
				matched = true
				break
			end
		end
	end
	if not matched then
		log("Warning: Recycling Machines unsupported item-subgroup: " .. groupname)
	end
end -- each subgroup

-- Types
for name, this in pairs(data.raw) do
	local typefound = false
	for _,vanilla in pairs(vanillatypes) do
		if vanilla == name then
			typefound = true
			break
		end
	end
	if not typefound then
		log("Warning: Recycling Machines unsupported type: " .. name)
	end
end

--Crafting types
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
			for craft, recycle in pairs(craftingbeforeandafter) do
				if recipe.category == craft then
					catfound = true
					break
				end
			end
		end
		if not catfound then
			for _,craft in pairs(ignoredcrafts) do
				if recipe.category == craft then
					catfound = true
					break
				end
			end
		end
		if not catfound then
			log("Warning: Recycling Machines unsupported craft: " .. recipe.category)
			table.insert(ignoredcrafts,recipe.category)
		end
	end
end