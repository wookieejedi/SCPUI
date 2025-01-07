-----------------------------------
--This file contains miscellaneous functions for multiplayer UIs
-----------------------------------

--- Helper function to check if we're in a valid multiplayer game
--- @return boolean
function ScpuiSystem:inMultiGame()
	local game = ui.MultiGeneral.getNetGame()
	
	if game:isValid() then
		return true
	end
	
	return false
end