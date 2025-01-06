local dialogs = require("dialogs")
local class = require("class")

local CutsceneController = class()

function CutsceneController:init()
	ad.stopMusic(0, true, "mainhall")
	ui.MainHall.stopAmbientSound()
	ui.playCutscene(ScpuiSystem.data.memory.cutscene, true, 0)
end

---@param document Document
function CutsceneController:initialize(document)
	self.document = document
	ui.MainHall.startAmbientSound()
	ui.MainHall.startMusic()
	ScpuiSystem.data.memory.cutscene = "none"
	ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	self.document:Close()
end

return CutsceneController
