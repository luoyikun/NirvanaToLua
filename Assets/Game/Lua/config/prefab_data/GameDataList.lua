local function InitGameData(reqdir)
	return {
		1001001_config = require (reqdir.."/1001001_config")
	}
end
return InitGameData