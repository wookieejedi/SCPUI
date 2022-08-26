local rocket_utils = require("rocket_util")
local async_util = require("async_util")

local class = require("class")

local RedAlertController = class()

function RedAlertController:init()
end

function RedAlertController:initialize(document)
	self.document = document

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end

    local alert_info = ui.RedAlert.getRedAlert()
	ba.warning(alert_info.Text)
	ba.warning(alert_info.AudioFilename)
	
	--local text_el = self.document:GetElementById("red_alert_text")
	
	--local color_text = rocket_utils.set_briefing_text(text_el, alert_info.Text)
	
	--if alert_info.AudioFilename then
	--	voice_handle = ad.openAudioStream(alert_info.AudioFilename, AUDIOSTREAM_VOICE)
	--	voice_handle:play(ad.MasterVoiceVolume)
	--end

end

function RedAlertController:commit_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
end

function RedAlertController:replay_pressed()
    if ui.RedAlert.replayPreviousMission() and mn.isInCampaign() then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
	end
end

function RedAlertController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        --self.music_handle:stop()
		event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return RedAlertController
