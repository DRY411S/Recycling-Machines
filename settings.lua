data:extend({
   {
      type = "string-setting",
      name = "ZRecycling-recoveryrate",
      setting_type = "startup",
      default_value = "1",
	  allowed_values = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" }, 
      order = "ba",
   },
   {
      type = "string-setting",
      name = "ZRecycling-recoveryspeed",
      setting_type = "startup",
      default_value = "=",
	  allowed_values = { "=", "1/2", "1/3", "1/4" }, 
      order = "ba",
   },
   {
      type = "string-setting",
      name = "ZRecycling-difficulty",
      setting_type = "startup",
      default_value = "expensive" ,
	  allowed_values = { "expensive" , "normal" }, 
      order = "ba",
   },
})