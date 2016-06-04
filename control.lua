-- GLOBAL defines--

require "defines"
require "util"
-- Constants.lua contains the reverse recipe prefix in a variable rec_prefix
-- It's also used in data-final-fixes.lua where the reverse recipes are built
require("constants")

-- GLOBAL variables

-- LOCAL Variables

-- LOCAL functions

local function Toggle_Recipes(toggle)

	-- Need to toggle relevant recipes when the machine is either opened (toggle == true) or closed (toggle == false)
	for _,recipe in pairs(game.player.force.recipes) do
		if recipe.enabled == true and ( game.player.force.recipes[rec_prefix .. recipe.name] ~= nil ) then
			game.player.force.recipes[rec_prefix .. recipe.name].enabled = toggle
		end
	end
end

local function Unlock_Recipe(recipename)
	game.player.print("Recipe: " .. recipename)
	-- Need to enable the reverse recipe for this one, in the Recycling group
	local recipe = game.player.force.recipes[recipename]
	if recipe then
		--error(serpent.block(recipe))
		game.player.print("Recipe found: " .. recipename)
		-- Enable the reversed version
		local reverse_recipe = game.player.force.recipes[rec_prefix .. recipename]
		if reverse_recipe then
			game.player.print("Reverse recipe found: " .. rec_prefix .. recipename)
			game.player.force.recipes[rec_prefix .. recipename].enabled = true
		else
			game.player.print("Reverse recipe missing: " .. recipename)
		end
	else
		game.player.print("Recipe passed by event is missing " .. recipename)
	end
end

local function enable_reverse_recipes(event)
	game.player.print("Something was researched : " .. event.research.name)
	if event.research.force.name == "player" then
		-- Don't reverse anything until automation has been researched (which allows a recycling machine)
		if game.player.force.technologies["automation"].researched == true or event.research.name == "automation"then
			-- Special case for automation
			if event.research.name == "automation" then
				-- Now we can recycle. Pick up reverse recipes for all the things
				-- that can be crafted without automation
				for _,v in pairs(game.player.force.recipes) do
					if v.enabled == true then
						Unlock_Recipe(v.name)
					end
				end
			end
			local rec = event.research.effects
			for i,v in pairs(rec) do
				if v.type == "unlock-recipe" then
					Unlock_Recipe(v.recipe)
				end
			end
		end
	else
		game.player.print("Something was researched NOT for a player: " .. event.research.force.name)
	end
end

-- GAME Event Handlers

script.on_event(defines.events.on_research_finished,function(event)
	if event.name == defines.events.on_research_finished then
		-- enable_reverse_recipes(event)
	end
end
)

-- KUDOS to original CODE to check for a machine being opened by Kriogenic, and adapted by me to add a 'closed' handler
-- https://forums.factorio.com/viewtopic.php?f=25&t=26017#p164949

    events = defines.events
    events.machine_opened = script.generate_event_name()
    events.machine_closed = script.generate_event_name()

    script.on_init(function()
        if global.open == nil then
            global.open = false;
        end
    end)


function is_machine(entity)
	if entity.type == 'assembling-machine' then
		if entity.name == 'recycling-machine-1' or entity.name == 'recycling-machine-2' or entity.name == 'recycling-machine-3' then
			return true
		else
			return false
		end
	else
		return false
	end
end
   


   
   
    script.on_event({
        events.on_tick
    }, function(event)
   
      openinv = game.player.opened
   
   if openinv == nil and global.open == true then
      global.open = false
      game.raise_event(events.machine_closed, {
                entity = openinv,
            })
   elseif openinv ~= nil and is_machine(openinv) and global.open == false then
      global.open = true;
      game.raise_event(events.machine_opened, {
                entity = openinv,
            })
   end
   
    end)

    script.on_event({
       events.machine_opened
    }, function(event)

     Toggle_Recipes(true)
	 -- game.player.print("Code you wish to run when ever an assembler is opened")
    end)

    script.on_event({
       events.machine_closed
    }, function(event)

     Toggle_Recipes(false)
	 -- game.player.print("Code you wish to run when ever an assembler is closed")
    end)

    -- create an interface for other mods to access raised event.
    remote.add_interface("machine_opened", {
        event = function()
            return events.machine_opened
        end
    })
	remote.add_interface("machine_closed", {
        event = function()
            return events.machine_closed
        end
    })