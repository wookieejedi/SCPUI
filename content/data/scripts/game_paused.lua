local class = require("class")
local utils = require("utils")

local GamePausedController = class()

local pausedText = {"GAME IS PAUSED", -1}

local screenRender = nil

function GamePausedController:init()
end

function GamePausedController:initialize(document)

	ui.PauseScreen.initPause()
	
	if screenRender == nil then
		screenRender = gr.screenToBlob()
	end

    self.document = document
	
	if mn.isInMission() then
		ui.PauseScreen.initPause()
	end

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("h2-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("h2-5", true)
	end
	
	---Load background based on campaign for BtA - Mjn
	local campaignfilename = ba.getCurrentPlayer():getCampaignFilename()
	
	if campaignfilename == "bta1_m" then
		bgclass = "main_bg_bta1"
	elseif campaignfilename == "bta2_m" then
		bgclass = "main_bg_bta2"
	else
		bgclass = "general_bg"
	end
	
	self.document:GetElementById("main_background"):SetClass(bgclass, true)
	
	local main_bg = self.document:GetElementById("screenrender")
	local imgEl = self.document:CreateElement("img")
	main_bg:AppendChild(imgEl)
	imgEl:RemoveAttribute("src")
	imgEl:SetAttribute("src", screenRender)
	
	self.document:GetElementById("text").inner_rml = utils.xstr(pausedText)
	
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
end

return GamePausedController
