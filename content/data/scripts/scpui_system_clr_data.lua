-----------------------------------
--This file adds hooks used to clear loadouts in specific cases
-----------------------------------

--Clears all the current loadout if F12 is detected during mission load
local function clearLoadoutWithKeypress()
    if hv.Key == "F12" then
		if ba.getCurrentGameState().Name == "GS_STATE_START_GAME" then
			local loadoutHandler = require("loadouthandler")
			
			local key = loadoutHandler:getMissionKey()
			ba.print("SCPUI got command to delete loadout file '" .. key .. "'!\n")
			
			local data = loadoutHandler:loadLoadoutsFromFile()
			
			data[key] = nil
			
			loadoutHandler:saveLoadoutsToFile(data)
		end
	end
end

--Clears all campaign related loadout save data on campaign start or restart
local function clearLoadoutOnCampaignStart()
	ba.print("SCPUI got command to delete all campaign loadouts!\n")
	
	local loadoutHandler = require("loadouthandler")
	local data = loadoutHandler:loadLoadoutsFromFile()
	
	if data == nil then return end
	
	for k, v in pairs(data) do
		if k:sub(-1) == "c" then
			data[k] = nil
		end
	end
	
	loadoutHandler:saveLoadoutsToFile(data)
end

engine.addHook("On Key Pressed", function()
	clearLoadoutWithKeypress()
end)

engine.addHook("On Campaign Begin", function()
	clearLoadoutOnCampaignStart()
end)