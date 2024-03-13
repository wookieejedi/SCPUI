local rocket_utils = require("rocket_util")
local async_util = require("async_util")
local loadoutHandler = require("loadouthandler")
local topics = require("ui_topics")

local class = require("class")

local RedAlertController = class()

function RedAlertController:init()
	ScpuiSystem:maybePlayCutscene(MOVIE_PRE_BRIEF)
	
	loadoutHandler:init()
end

local alert_el = nil
local alert_bool = true

function RedAlertController:initialize(document)
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)

    local alert_info = ui.RedAlert.getRedAlert()
	
	if alert_info ~= nil then
		local text_el = self.document:GetElementById("red_alert_text")
		local color_text = rocket_utils.set_briefing_text(text_el, alert_info.Text)
	
		if alert_info.AudioFilename then
			self.current_voice_handle = ad.openAudioStream(alert_info.AudioFilename, AUDIOSTREAM_VOICE)
			self.current_voice_handle:play(ad.MasterVoiceVolume)
		end
	end

	--Whenever we start a new mission, we reset the log ui to goals
	ScpuiSystem.logSection = 1
	
	alert_el = self.document:GetElementById("incoming_transmission")
	RedAlertController:blink()
	
	topics.redalert.initialize:send(self)

end

function RedAlertController:blink()
	
	async.run(function()
        async.await(async_util.wait_for(0.5))
		if alert_bool then
			alert_el:SetClass("hidden", true)
			alert_bool = false
			RedAlertController:blink()
		else
			alert_el:SetClass("hidden", false)
			alert_bool = true
			RedAlertController:blink()
		end
    end, async.OnFrameExecutor, async.context.captureGameState())

end

function RedAlertController:commit_pressed()
	if not topics.mission.commit:send(self) then
		return
	end
	loadoutHandler:unloadAll()
	topics.redalert.commit:send(self)
	ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
end

function RedAlertController:replay_pressed()
    if ui.RedAlert.replayPreviousMission() and mn.isInCampaign() then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
	end
end

function RedAlertController:unload()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:close(false)
    end
end

function RedAlertController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        --self.music_handle:stop()
		event:StopPropagation()
		loadoutHandler:unloadAll()
		
		mn.unloadMission(true)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return RedAlertController
