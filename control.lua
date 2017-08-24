-- GLOBAL defines--

-- Constants.lua contains the reverse recipe prefix in a variable constant_rec_prefix
-- It's also used in data-final-fixes.lua where the reverse recipes are built
require("constants")

-- GLOBAL variables

-- Make the recipe prefix a global to be used in migrations, which don't allow requires.
rec_prefix = constant_rec_prefix

-- This has to be copied into the migration scripts. Make sure it is aligned.
-- GLOBAL functions
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
            -- After 0.15.6 Only enable it if the mod global runtime map setting wants it            
            -- TODO: Handle mods
            -- if force.recipes[rec_prefix .. recipename].subgroup ~= nil then        
                -- local start,finish = string.find(force.recipes[rec_prefix .. recipename].subgroup.name , rec_prefix)
                -- if start ~= nil then
                    -- local setting = "ZRecycling" .. string.sub(force.recipes[rec_prefix .. recipename].subgroup.name , finish + 2 , -1)
                    -- -- game.player.print("Setting before: " .. force.recipes[rec_prefix .. recipename].subgroup.name .." and after: ".. setting)
                    -- if settings.global[setting] ~= nil then
                        -- --game.player.print("Reverse recipe found: " .. rec_prefix .. recipename)
                        -- force.recipes[rec_prefix .. recipename].enabled = settings.global[setting].value
                    -- else
                        -- force.recipes[rec_prefix .. recipename].enabled = true
                    -- end
                -- end
            -- end
		else
			--game.player.print("Reverse recipe missing: " .. recipename)
		end
	else
		--game.player.print("Recipe passed by event is missing " .. recipename)
	end
end

-- LOCAL Variables
local force = nil

-- LOCAL functions

-- When research is finished
local function enable_reverse_recipes(event)

	for _, nextforce in pairs(game.forces) do
		force = nextforce
		-- Don't reverse anything until automation has been researched (which allows a recycling machine)
		if force.technologies["automation"].researched == true or event.research.name == "automation" then
			-- Special case for automation
			if event.research.name == "automation" then
				-- Now we can recycle. Pick up reverse recipes for all the things
				-- that can be crafted without automation
				for _,v in pairs(force.recipes) do
					if v.enabled == true then
						ZRecycling.Unlock_Recipe(force,v.name)
					end
				end
			end
			local rec = event.research.effects
			for i,v in pairs(rec) do
				if v.type == "unlock-recipe" then
					ZRecycling.Unlock_Recipe(force,v.recipe)
				end
			end
		end
	end
end

-- When the mod settings change
-- Future version
-- local function adjust_reverse_recipes(event)

	-- for _, nextforce in pairs(game.forces) do
		-- force = nextforce
		-- -- Don't reverse anything until automation has been researched (which allows a recycling machine)
		-- if force.technologies["automation"].researched and force.technologies["automation"].researched == true then
            -- -- Now we can recycle. Unlock (or lock) Recycling Recipes according
            -- -- to whether there counterpart is enabled and the mod-setting wants them to be recyclable
            -- for _,v in pairs(force.recipes) do
                -- if v.enabled == true then
                    -- ZRecycling.Unlock_Recipe(force,v.name)
                -- end
            -- end
		-- end
	-- end
-- end

-- -- New game
-- local function reset_mod_settings()
-- -- Traverse the mod settings for ZRecycling strings, and reset to defaults
-- end


-- GAME Event Handlers

script.on_event(defines.events.on_research_finished,function(event)
	if event.name == defines.events.on_research_finished then
		enable_reverse_recipes(event)
	end
end
)

-- Future version
-- script.on_event(defines.events.on_runtime_mod_setting_changed,function(event)
	-- if event.name == defines.events.on_runtime_mod_setting_changed then
		-- adjust_reverse_recipes(event)
	-- end
-- end
-- )

-- script.on_init(reset_mod_settings)
