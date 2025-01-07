local dialogs = require("lib_dialogs")
local class = require("lib_class")

local CutsceneController = class()

function CutsceneController:init()
	ad.stopMusic(0, true, "mainhall")
	ui.MainHall.stopAmbientSound()
	ui.playCutscene(ScpuiSystem.data.memory.Cutscene, true, 0)
end

---@param document Document
function CutsceneController:initialize(document)
	self.Document = document
	ui.MainHall.startAmbientSound()
	ui.MainHall.startMusic()
	ScpuiSystem.data.memory.Cutscene = "none"
	ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	self.Document:Close()
end

return CutsceneController
