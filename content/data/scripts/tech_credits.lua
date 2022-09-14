local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")

local TechCreditsController = class()

function TechCreditsController:init()
end

function TechCreditsController:initialize(document)
    self.document = document
    self.elements = {}
    self.section = 1
	self.scroll = 0
	self.rate = ui.TechRoom.Credits.ScrollRate

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	local listComplete = ui.TechRoom.buildCredits()
	
	ad.stopMusic(0, true, "mainhall")
	ui.MainHall.stopAmbientSound()
	self:startMusic()
	
	local text_el = self.document:GetElementById("credits_text")
	
	local CompleteCredits = string.gsub(ui.TechRoom.Credits.Complete,"\n","<br></br>")
	
	--Eventually this we should calculate the number of line breaks needed based on div height
	local creditsBookend = "<br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br><br></br>"
	
	--Append new lines to the top and bottom of Credits so we can loop it later seamlessly
	CompleteCredits = creditsBookend .. CompleteCredits .. creditsBookend
	text_el.inner_rml = CompleteCredits
	
	self.creditsElement = text_el
	
	self:ScrollCredits()
	
	imageFile = "2_Crim0" .. ui.TechRoom.Credits.StartIndex .. ".png"
	
	local aniWrapper = self.document:GetElementById("credits_image")
	local aniEl = self.document:CreateElement("img")
	aniEl:SetAttribute("src", imageFile)

	aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
	
	self.document:GetElementById("data_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("mission_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("cutscene_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("credits_btn"):SetPseudoClass("checked", true)
	
end

function TechCreditsController:ChangeSection(section)

	if section == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
	end
	if section == 2 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
	end
	if section == 3 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	end
	if section == 4 then
		--ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
	end
	
end

function TechCreditsController:startMusic()
    
	local filename = ui.TechRoom.Credits.Music

    self.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
    async.run(function()
        async.await(async_util.wait_for(1.5))
        self.music_handle:play(ad.MasterEventMusicVolume, true)
    end, async.OnFrameExecutor)
end

function TechCreditsController:ScrollCredits()
	if self.scroll >= self.creditsElement.scroll_height then
		self.scroll = 0
	else
		self.scroll = self.scroll + self.rate / 50
	end
	self.creditsElement.scroll_top = self.scroll
	--self.creditsElement.scroll_top = 17100
	
	--ba.warning(self.creditsElement.scroll_height)
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:ScrollCredits()
    end, async.OnFrameExecutor)
end

function TechCreditsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

function TechCreditsController:exit_pressed(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

function TechCreditsController:unload()
	if self.music_handle ~= nil and self.music_handle:isValid() then
        self.music_handle:close(true)
    end
	ui.MainHall.startAmbientSound()
	ui.MainHall.startMusic()
end

return TechCreditsController
