local class = require("lib_class")
local utils = require("lib_utils")
local topics = require("lib_ui_topics")

local GamePausedController = class()

local pausedText = {"GAME IS PAUSED", 888347}

local screenRender = nil

function GamePausedController:init()
end

---@param document Document
function GamePausedController:initialize(document)

	ui.PauseScreen.initPause()
	
	if screenRender == nil then
		screenRender = gr.screenToBlob()
	end

    self.Document = document
	
	if mn.isInMission() then
		ui.PauseScreen.initPause()
	end

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	local main_bg = self.Document:GetElementById("screenrender")
	local imgEl = self.Document:CreateElement("img")
	main_bg:AppendChild(imgEl)
	imgEl:RemoveAttribute("src")
	imgEl:SetAttribute("src", screenRender)
	
	self.Document:GetElementById("text").inner_rml = utils.xstr(pausedText)
	
	topics.gamepaused.initialize:send(self)
	
end

function GamePausedController:global_keydown(element, event)
    if (event.parameters.key_identifier == rocket.key_identifier.ESCAPE) or (event.parameters.key_identifier == rocket.key_identifier.PAUSE) then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
	end
end

function GamePausedController:unload()
	if mn.isInMission() then
		ui.PauseScreen.closePause()
	end
	
	ui.PauseScreen.closePause()
	
	screenRender = nil
	
	topics.gamepaused.unload:send(self)
end

return GamePausedController
