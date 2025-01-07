local async_util = require("lib_async")
local loadoutHandler = require("lib_loadout_handler")
local topics = require("lib_ui_topics")

local class = require("lib_class")

local RedAlertController = class()

function RedAlertController:init()
	ScpuiSystem:maybePlayCutscene(MOVIE_PRE_BRIEF)
	
	loadoutHandler:init()
end

local alert_el = nil
local alert_bool = true

---@param document Document
function RedAlertController:initialize(document)
	self.Document = document
	
	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

    local alert_info = ui.RedAlert.getRedAlert()
	
	if alert_info ~= nil then
		local text_el = self.Document:GetElementById("red_alert_text")
		local color_text = ScpuiSystem:set_briefing_text(text_el, alert_info.Text)
	
		if alert_info.AudioFilename then
			self.current_voice_handle = ad.openAudioStream(alert_info.AudioFilename, AUDIOSTREAM_VOICE)
			self.current_voice_handle:play(ad.MasterVoiceVolume)
		end
	end

	--Whenever we start a new mission, we reset the log ui to goals
	ScpuiSystem.data.memory.LogSection = 1
	
	ScpuiSystem.data.memory.AlertElement = self.Document:GetElementById("incoming_transmission")
	RedAlertController:blink()
	
	topics.redalert.initialize:send(self)

end

function RedAlertController:blink()
	
	async.run(function()
        async.await(async_util.wait_for(0.5))
		if alert_bool then
			ScpuiSystem.data.memory.AlertElement:SetClass("hidden", true)
			alert_bool = false
			RedAlertController:blink()
		else
			ScpuiSystem.data.memory.AlertElement:SetClass("hidden", false)
			alert_bool = true
			RedAlertController:blink()
		end
    end, async.OnFrameExecutor, async.context.captureGameState())

end

function RedAlertController:commit_pressed()
	if not topics.mission.commit:send(self) then
		return
	end
	loadoutHandler:unloadAll(true)
	topics.redalert.commit:send(self)
	ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
end

function RedAlertController:replay_pressed()
    if ui.RedAlert.replayPreviousMission() and mn.isInCampaign() then
		loadoutHandler:unloadAll(false)
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
	end
end

function RedAlertController:unload()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:close(false)
    end
	ScpuiSystem.data.memory.AlertElement = nil
	topics.redalert.unload:send(self)
end

function RedAlertController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
		event:StopPropagation()
		loadoutHandler:unloadAll(false)
		
		mn.unloadMission(true)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return RedAlertController
