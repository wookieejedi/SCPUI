local rocket_utils = require("rocket_util")
local async_util = require("async_util")

local class = require("class")

local AbstractBriefingController = require("briefingCommon")

local FictionViewerController = class()

function FictionViewerController:init()
end

function FictionViewerController:initialize(document)
    self.document = document
	self.textFile = ui.FictionViewer.getFiction().TextFile
	self.voiceFile = ui.FictionViewer.getFiction().VoiceFile
	
	ui.maybePlayCutscene(MOVIE_PRE_FICTION, true, 0)
	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
		self.document:GetElementById("fiction_text"):SetClass(("p2-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
		self.document:GetElementById("fiction_text"):SetClass("p2-5", true)
	end

	local file = cf.openFile(self.textFile, 'r', '')
	self.text = file:read('*a')
	file:close()
	
	local text_el = self.document:GetElementById("fiction_text")
	
	local color_text = rocket_utils.set_briefing_text(text_el, self.text)
	
	self.voice_handle = ad.openAudioStream(self.voiceFile, AUDIOSTREAM_VOICE)
	self.voice_handle:play(ad.MasterVoiceVolume)
	
	self:startMusic()

end

function FictionViewerController:startMusic()
    local filename = ui.FictionViewer.getFictionMusicName()

    if #filename <= 0 then
        return
    end

    self.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
	self.music_handle:play(ad.MasterEventMusicVolume, true)
	--Causes a CTD???
    --[[async.run(function()
        async.await(async_util.wait_for(2.5))
        self.music_handle:play(ad.MasterEventMusicVolume, true)
    end, async.OnFrameExecutor, self.uiActiveContext)]]--
end

function FictionViewerController:accept_pressed()
	self.music_handle:stop()
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

function FictionViewerController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        self.music_handle:stop()
		event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return FictionViewerController
