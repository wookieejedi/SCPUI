local rocket_utils = require("rocket_util")
local async_util = require("async_util")

local class = require("class")

local AbstractBriefingController = require("briefingCommon")

local LoopBriefController = class()

function LoopBriefController:init()
end

function LoopBriefController:initialize(document)
	self.document = document
    --AbstractLoopBriefController.initialize(self, document)

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end

    local loop = ui.LoopBrief.getLoopBrief()
	
	local text_el = self.document:GetElementById("loop_text")
	
	local color_text = rocket_utils.set_briefing_text(text_el, loop.Text)
	
	if loop.AudioFilename then
		voice_handle = ad.openAudioStream(loop.AudioFilename, AUDIOSTREAM_VOICE)
		voice_handle:play(ad.MasterVoiceVolume)
	end
	
	local aniWrapper = self.document:GetElementById("loop_anim")
    if loop.AniFilename then
        local aniEl = self.document:CreateElement("ani")
        aniEl:SetAttribute("src", loop.AniFilename)

        aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
    end

end

function LoopBriefController:accept_pressed()
    ui.LoopBrief.setLoopChoice(true)
	ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
end

function LoopBriefController:deny_pressed()
    ui.LoopBrief.setLoopChoice(false)
	ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
end

function LoopBriefController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        --self.music_handle:stop()
		event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

return LoopBriefController
