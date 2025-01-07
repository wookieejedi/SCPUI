local topics = require("ui_topics")
local async_util = require("async_util")

local class = require("class")

local AbstractBriefingController = require("briefingCommon")

local FictionViewerController = class(AbstractBriefingController)

function FictionViewerController:init()
	ScpuiSystem:maybePlayCutscene(MOVIE_PRE_FICTION)
end

---@param document Document
function FictionViewerController:initialize(document)

	---@type Document
	self.document = nil

	AbstractBriefingController.initialize(self, document)
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.textFile = ui.FictionViewer.getFiction().TextFile
	self.voiceFile = ui.FictionViewer.getFiction().VoiceFile

	local file = cf.openFile(self.textFile, 'r', '')
	self.text = file:read('*a')
	file:close()
	
	local text_el = self.document:GetElementById("fiction_text")
	
	local color_text = ScpuiSystem:set_briefing_text(text_el, self.text)
	
	topics.fictionviewer.initialize:send(self)
	
	self.voice_handle = ad.openAudioStream(self.voiceFile, AUDIOSTREAM_VOICE)
	self.voice_handle:play(ad.MasterVoiceVolume)

end

function FictionViewerController:scroll_up()
	local text_el = self.document:GetElementById("fiction_text")
	text_el.scroll_top = text_el.scroll_top + 10
end

function FictionViewerController:scroll_down()
	local text_el = self.document:GetElementById("fiction_text")
	text_el.scroll_top = text_el.scroll_top - 10
end

function FictionViewerController:go_to_next()
	if mn.hasCommandBriefing() then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_CMD_BRIEF"])
	else
		if mn.isRedAlertMission() then
			ba.postGameEvent(ba.GameEvents["GS_EVENT_RED_ALERT"])
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
		end
	end
end

function FictionViewerController:accept_pressed()
	if topics.fictionviewer.accept:send(self) then
		self:go_to_next()
	end
end

function FictionViewerController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
		if ScpuiSystem.data.memory.music_handle ~= nil and ScpuiSystem.data.memory.music_handle:isValid() then
			ScpuiSystem.data.memory.music_handle:close(true)
		end
		ScpuiSystem.data.memory.music_handle = nil
		ScpuiSystem.data.memory.current_music_file = nil
		event:StopPropagation()

		mn.unloadMission(true)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	elseif event.parameters.key_identifier == rocket.key_identifier.UP then
		self:scroll_down()
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN then
		self:scroll_up()
	elseif event.parameters.key_identifier == rocket.key_identifier.RETURN then
		self:accept_pressed()
    end
end

return FictionViewerController
