local rocket_utils = require("rocket_util")
local async_util = require("async_util")

local class = require("class")

--local AbstractBriefingController = require("briefingCommon")

--local FictionViewerController = class(AbstractBriefingController)

local DebriefingController = class()

function DebriefingController:init()
	self.stages = {}
end

function DebriefingController:initialize(document)
	--AbstractBriefingController.initialize(self, document)
	self.document = document
	
	ui.maybePlayCutscene(MOVIE_PRE_DEBRIEF, true, 0)
	
	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	ui.Debriefing.initDebriefing()
	ba.warning(ui.Debriefing.getDebriefingMusicName())
	
	local debriefing = ui.Debriefing.getDebriefing()
	local numStages = 0
	for i = 1, #debriefing do
        --- @type briefing_stage
        local stage = debriefing[i]
		if stage.isValid then
			self.stages[i] = stage
			numStages = numStages + 1
			ba.warning(stage.Text)
			--This is where we should replace variables and containers probably!
		end
    end
	
	local medalName, medalFile = ui.Debriefing.getEarnedMedal()
	
	local promoStage, promoName, promoFile = ui.Debriefing.getEarnedPromotion()
	
	local traitorStage = ui.Debriefing.getTraitor()
	
	ba.warning(traitorStage.Text)
	
	--[[local text_el = self.document:GetElementById("fiction_text")
	
	local color_text = rocket_utils.set_briefing_text(text_el, self.text)
	
	self.voice_handle = ad.openAudioStream(self.voiceFile, AUDIOSTREAM_VOICE)
	self.voice_handle:play(ad.MasterVoiceVolume)]]--

end

function DebriefingController:accept_pressed()
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

function DebriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
		event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return DebriefingController
