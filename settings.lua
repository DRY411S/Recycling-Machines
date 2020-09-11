data:extend({
   {
      type = "string-setting",
      name = "ZRecycling-recoveryrate",
      setting_type = "startup",
      default_value = "2",
	  allowed_values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, 
      order = "ba",
   },
   {
      type = "string-setting",
      name = "ZRecycling-recoveryspeed",
      setting_type = "startup",
      default_value = "1/2",
	  -- Fix for https://github.com/DRY411S/Recycling-Machines/issues/91
	  -- When setting craftspeed to 1 the mod fails to load
	  -- The '=' setting had been changed to '1'. The comments say it should be '='
	  allowed_values = { "=", "1/2", "1/3", "1/4" }, 
      order = "ba",
   },
})