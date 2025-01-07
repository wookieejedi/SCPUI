local Topic = require("lib_topic")

return {
  journal = {
	   initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context
	   unload  = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the context
	}
}

