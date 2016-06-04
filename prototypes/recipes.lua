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
  {
    type = "recipe",
    name = "recycling-machine-1",
    enabled = false,
    ingredients =
    {
      {"electronic-circuit", 3},
      {"iron-gear-wheel", 5},
      {"iron-plate", 9}
    },
    result = "recycling-machine-1"
  },
  {
    type = "recipe",
    name = "recycling-machine-2",
    enabled = false,
    ingredients =
    {
      {"iron-plate", 9},
      {"electronic-circuit", 3},
      {"iron-gear-wheel", 5},
      {"recycling-machine-1", 1}
    },
    result = "recycling-machine-2"
  },
  {
    type = "recipe",
    name = "recycling-machine-3",
    enabled = false,
    ingredients =
    {
      {"speed-module", 4},
      {"recycling-machine-2", 2}
    },
    result = "recycling-machine-3"
  } 

})