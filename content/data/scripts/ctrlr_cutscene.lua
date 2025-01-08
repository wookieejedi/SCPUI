-----------------------------------
--Controller for the Cutscene Viewer UI -- Used for the tech room cutscenes only!
-----------------------------------

local Class = require("lib_class")

local CutsceneController = Class()

--- Called by the class constructor
--- @return nil
function CutsceneController:init()
	--- Here we play the cutscene during the initialization of the controller
	--- That means the initialize method will not be called until the cutscene
	--- has finished playing.
	ad.stopMusic(0, true, "mainhall")
	ui.MainHall.stopAmbientSound()
	ui.playCutscene(ScpuiSystem.data.memory.Cutscene, true, 0)
end

--- Called by the RML document
--- @param document Document
function CutsceneController:initialize(document)
	--- If we're here then the cutscene has finished playing so we can
	--- restart the music, reset the cutscene globals, and close the document.
	self.Document = document
	ui.MainHall.startAmbientSound()
	ui.MainHall.startMusic()
	ScpuiSystem.data.memory.Cutscene = "none"
	ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	self.Document:Close()
end

--- Called when the screen is being unloaded
--- @return nil
function CutsceneController:unload()
	-- Nothing to do
end

return CutsceneController
