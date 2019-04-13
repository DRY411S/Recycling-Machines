local recyclingrecipes = {}
local newrecipe = {}

function swopassemblerforrecycler(recipe,level)
if recipe.ingredients  ~= nil then
	for _,rec_ingredient in ipairs(recipe.ingredients) do
		if rec_ingredient[1] == "assembling-machine-"..level then
			rec_ingredient[1] = "recycling-machine-"..level
		end
	end -- each assembling machine's recipe ingredient
	recipe.result = "recycling-machine-" .. level+1
end
if recipe.normal ~= nil then
	for _,rec_ingredient in ipairs(recipe.normal.ingredients) do
		if rec_ingredient[1] == "assembling-machine-"..level then
			rec_ingredient[1] = "recycling-machine-"..level
		end
	end -- each assembling machine's normal recipe ingredient
	recipe.normal.result = "recycling-machine-"..level+1
end
if recipe.expensive ~= nil  then
	for _,rec_ingredient in ipairs(recipe.expensive.ingredients) do
		if rec_ingredient[1] == "assembling-machine-"..level then
			rec_ingredient[1] = "recycling-machine-"..level
		end
	end -- each assembling machine's expensive recipe ingredient
	recipe.expensive.result = "recycling-machine-"..level+1
end
--log(serpent.block(recipe))
return recipe
end

newrecipe = table.deepcopy(data.raw.recipe["assembling-machine-1"])
newrecipe.name = "recycling-machine-1"
newrecipe = swopassemblerforrecycler(newrecipe,0)
table.insert(recyclingrecipes,newrecipe)

newrecipe = table.deepcopy(data.raw.recipe["assembling-machine-2"])
newrecipe.name = "recycling-machine-2"
newrecipe = swopassemblerforrecycler(newrecipe,1)
table.insert(recyclingrecipes,newrecipe)

newrecipe = table.deepcopy(data.raw.recipe["assembling-machine-3"])
newrecipe.name = "recycling-machine-3"
newrecipe = swopassemblerforrecycler(newrecipe,2)
table.insert(recyclingrecipes,newrecipe)


data:extend(recyclingrecipes)
data:extend(
{
  {
	type = "recipe-category",
	name = "recycling-1"
  },
  {
	type = "recipe-category",
	name = "recycling-2"
  },
  {
	type = "recipe-category",
	name = "recycling-3"
  },
  {
	type = "recipe-category",
	name = "advanced-recycling"
  },
  {
	type = "recipe-category",
	name = "recycling-with-fluid"
  },
})