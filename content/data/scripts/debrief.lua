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
	
	if not RocketUiSystem.debriefInit then
		ui.maybePlayCutscene(MOVIE_PRE_DEBRIEF, true, 0)
		ui.Debriefing.initDebriefing()
		self:startMusic()
		RocketUiSystem.debriefInit = true
	end
	
	local player = ba.getCurrentPlayer()
	
	ba.warning(player.Stats.MissionSecondaryShotsFired)
		
	
	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	self.document:GetElementById("mission_name").inner_rml = mn.getMissionTitle()
	
	local li_el = self.document:CreateElement("li")
	
	local promoStage, promoName, promoFile = ui.Debriefing.getEarnedPromotion()
	local badgeStage, badgeName, badgeFile = ui.Debriefing.getEarnedBadge()
	local medalName, medalFile = ui.Debriefing.getEarnedMedal()
	
	local numStages = 0
	self.numRecs = 0
	self.audioPlaying = 0
	
	local traitorStage = ui.Debriefing.getTraitor()
	
	if not traitorStage then
		if promoName then
			numStages = numStages + 1
			self.stages[numStages] = promoStage
		end
		
		if badgeName then
			numStages = numStages + 1
			self.stages[numStages] = badgeStage
		end
		
		local debriefing = ui.Debriefing.getDebriefing()

		for i = 1, #debriefing do
			--- @type debriefing_stage
			local stage = debriefing[i]
			if stage.checkVisible then
				numStages = numStages + 1
				self.stages[numStages] = stage
				if self.stages[numStages].Recommendation ~= "" then
					self.numRecs = self.numRecs + 1
				end
				--This is where we should replace variables and containers probably!
			end
		end
	else
		numStages = 1
		self.stages[1] = traitorStage
	end
	
	self:BuildText()

	self:PlayVoice()
	
	self.document:GetElementById("debrief_btn"):SetPseudoClass("checked", true)
	
	--local defaultColorTag = ui.DefaultTextColorTag(2)
	--[[local text_el = self.document:GetElementById("fiction_text")
	
	local color_text = rocket_utils.set_briefing_text(text_el, self.text)
	
	self.voice_handle = ad.openAudioStream(self.voiceFile, AUDIOSTREAM_VOICE)
	self.voice_handle:play(ad.MasterVoiceVolume)]]--

end

function DebriefingController:PlayVoice()
	async.run(function()
        -- First, wait until the text has been shown fully
        async.await(async_util.wait_for(1.0))

        -- And now we can start playing the voice file
		if self.stages[self.audioPlaying + 1] then
			if self.stages[self.audioPlaying + 1].AudioFilename then
				self.audioPlaying = self.audioPlaying + 1
				local file = self.stages[self.audioPlaying].AudioFilename
				if #file > 0 and string.lower(file) ~= "none" then
					self.current_voice_handle = ad.openAudioStream(file, AUDIOSTREAM_VOICE)
					self.current_voice_handle:play(ad.MasterVoiceVolume)
				end
			end
		end

        self:waitForStageFinishAsync()
		
        self:PlayVoice()
    end, async.OnFrameExecutor)
end

function DebriefingController:waitForStageFinishAsync()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        while self.current_voice_handle:isPlaying() do
            async.await(async.yield())
        end
    else
        --Do nothing
    end

    -- Voice part is done so wait for a bit before saying we are actually finished
    async.await(async_util.wait_for(0.5))
end

function DebriefingController:BuildText()

	local completeText = ""
	
	local text_el = self.document:GetElementById("debrief_text")
	
	self.RecIDs = {}

	for i = 1, #self.stages do
		local paragraph = self.document:CreateElement("p")
		text_el:AppendChild(paragraph)
		paragraph:SetClass("debrief_text_actual", true)
		local color_text = rocket_utils.set_briefing_text(paragraph, self.stages[i].Text)
		local recommendation = self.document:CreateElement("p")
		self.RecIDs[i] = recommendation
		text_el:AppendChild(recommendation)
		recommendation.inner_rml = self.stages[i].Recommendation
		recommendation:SetClass("hidden", true)
		recommendation:SetClass("red", true)
		recommendation:SetClass("recommendation", true)
	end

	---Remember to create a special No Recommendations Div at the bottom!

end

function DebriefingController:startMusic()
	local filename = ui.Debriefing.getDebriefingMusicName()
	
	self.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
	async.run(function()
		async.await(async_util.wait_for(2.5))
		self.music_handle:play(ad.MasterEventMusicVolume, true, 0)
	end, async.OnFrameExecutor)
end

function DebriefingController:replay_pressed(element)
    ui.playElementSound(element, "click", "success")
	if self.music_handle ~= nil and self.music_handle:isValid() then
        self.music_handle:close(true)
    end
	RocketUiSystem.debriefInit = false
	ui.Debriefing.clearMissionStats()
    ui.Debriefing.replayMission()
end

function DebriefingController:accept_pressed()
	if self.music_handle ~= nil and self.music_handle:isValid() then
        self.music_handle:close(true)
    end
	RocketUiSystem.debriefInit = false
	ui.Debriefing.acceptMission()
end

function DebriefingController:options_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function DebriefingController:help_clicked(element)
    ui.playElementSound(element, "click", "success")
    --TODO
end

function DebriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
		event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

function DebriefingController:unload()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:close(false)
    end
end

return DebriefingController
