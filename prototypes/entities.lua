-- Recycling Machine Entities based on factorio assembling macines
-- This is essentially a copy of the assembling machine entities
-- Ingredients is always 1, so crafting categories are added to ensure that...
-- If you can make it only in a level X assembling machine, you can recycle it only at that level of recycling-machine
-- The exception is recipes with fluids. You can recycle them only in level 3 recycling machines.
-- TODO: Consider making them behave like furnaces and accept anything that goes past them
--       instead of recycling only one type of a item at a time
--       reverse-factory mod has this pretty much covered though

-- Enhancement https://github.com/DRY411S/Recycling-Machines/issues/37
-- Convert the mod setting craft factor into a craft speed adjustment 
local craftspeed = settings.startup["ZRecycling-recoveryspeed"].value
if craftspeed == "=" then 
    craftspeed = 1
else
    craftspeed = tonumber(string.sub(craftspeed,3))
end

require ("prototypes.recyclingpipes")

local recyclingmachines = {}

-- Get the assembling machine 1
local newrecycler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-1"])

-- Recycle it :)
newrecycler.name = "recycling-machine-1"
newrecycler.icon_size = 32
newrecycler.icon = "__ZRecycling__/graphics/icons/recycling-machine-1.png"
newrecycler.minable["result"] = "recycling-machine-1"
newrecycler.fast_replaceable_group = "recycling-machine"
newrecycler.next_upgrade = "recycling-machine-2"
newrecycler.animation.layers[1].filename = "__ZRecycling__/graphics/entity/recycling-machine-1/recycling-machine-1.png"
newrecycler.animation.layers[1].hr_version.filename = "__ZRecycling__/graphics/entity/recycling-machine-1/hr-recycling-machine-1.png"
newrecycler.crafting_categories = {"recycling-1"}
newrecycler.crafting_speed = newrecycler.crafting_speed / craftspeed
newrecycler.icon_mipmaps = nil
table.insert(recyclingmachines,newrecycler)


-- Get the assembling machine 2
local newrecycler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-2"])

-- Recycle it :)
newrecycler.name = "recycling-machine-2"
newrecycler.icon_size = 32
newrecycler.icon = "__ZRecycling__/graphics/icons/recycling-machine-2.png"
newrecycler.minable["result"] = "recycling-machine-2"
newrecycler.fast_replaceable_group = "recycling-machine"
newrecycler.next_upgrade = "recycling-machine-3"
newrecycler.animation.layers[1].filename = "__ZRecycling__/graphics/entity/recycling-machine-2/recycling-machine-2.png"
newrecycler.animation.layers[1].hr_version.filename = "__ZRecycling__/graphics/entity/recycling-machine-2/hr-recycling-machine-2.png"
newrecycler.crafting_categories = {"recycling-1", "recycling-2"}
newrecycler.crafting_speed = newrecycler.crafting_speed / craftspeed
newrecycler.icon_mipmaps = nil
table.insert(recyclingmachines,newrecycler)

-- Get the assembling machine 3
local newrecycler = table.deepcopy(data.raw["assembling-machine"]["assembling-machine-3"])

-- Recycle it :)
newrecycler.name = "recycling-machine-3"
newrecycler.icon_size = 32
newrecycler.icon = "__ZRecycling__/graphics/icons/recycling-machine-3.png"
newrecycler.minable["result"] = "recycling-machine-3"
newrecycler.fast_replaceable_group = "recycling-machine"
newrecycler.next_upgrade = nil
newrecycler.animation.layers[1].filename = "__ZRecycling__/graphics/entity/recycling-machine-3/recycling-machine-3.png"
newrecycler.animation.layers[1].hr_version.filename = "__ZRecycling__/graphics/entity/recycling-machine-3/hr-recycling-machine-3.png"
newrecycler.crafting_categories = {"recycling-1", "recycling-2", "recycling-3", "recycling-with-fluid"}
newrecycler.crafting_speed = newrecycler.crafting_speed / craftspeed
newrecycler.icon_mipmaps = nil
-- Fix for https://github.com/DRY411S/Recycling-Machines/issues/53
-- Was referencing non-existent pipe pictures. Was not rendering correct pipe pictures
newrecycler.fluid_boxes[1]["pipe_picture"] = recycling3pipepictures()
newrecycler.fluid_boxes[2]["pipe_picture"] = recycling3pipepictures()
table.insert(recyclingmachines,newrecycler)

--Add the recycling machine prototypes into the raw data
data:extend(recyclingmachines)

