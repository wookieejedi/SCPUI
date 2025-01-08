local topics = require("lib_ui_topics")
local async_util = require("lib_async")
local dialogs = require("lib_dialogs")

local class = require("lib_class")

local AbstractBriefingController = require("ctrlr_briefing_common")

local LoopBriefController = class()

function LoopBriefController:init()
end

---@param document Document
function LoopBriefController:initialize(document)
	self.Document = document
    --AbstractLoopBriefController.initialize(self, document)
	
	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

    local loop = ui.LoopBrief.getLoopBrief()
	
	local text_el = self.Document:GetElementById("loop_text")
	
	local color_text = ScpuiSystem:setBriefingText(text_el, loop.Text)
	
	if loop.AudioFilename then
		ba.print("SCPUI got loop briefing audio filename as " .. loop.AudioFilename)
		self.voice_handle = ad.openAudioStream(loop.AudioFilename, AUDIOSTREAM_VOICE)
		self.voice_handle:play(ad.MasterVoiceVolume)
	end
	
	local aniWrapper = self.Document:GetElementById("loop_anim")
    if loop.AniFilename then
        local aniEl = self.Document:CreateElement("ani")
        aniEl:SetAttribute("src", loop.AniFilename)

        aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
    end
	
	topics.loopbrief.initialize:send(self)

end

function LoopBriefController:accept_pressed()
    ui.LoopBrief.setLoopChoice(true)
	if self.voice_handle then
		self.voice_handle:close()
	end
	ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
end

function LoopBriefController:deny_pressed()
    ui.LoopBrief.setLoopChoice(false)
	if self.voice_handle then
		self.voice_handle:close()
	end
	ba.postGameEvent(ba.GameEvents["GS_EVENT_START_GAME"])
end

function LoopBriefController:Show(text, title)
	--Create a simple dialog box with the text and title

	dialogs.new()
		:title(title)
		:text(text)
		:button(dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Accept", 888014), true, string.sub(ba.XSTR("Accept", 888014), 1, 1))
		:button(dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("Decline", 888354), false, string.sub(ba.XSTR("Decline", 888354), 1, 1))
		:show(self.Document.context)
		:continueWith(function(accepted)
        if not accepted then
            self:deny_pressed()
            return
        end
        self:accept_pressed()
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.Document.context)
end

function LoopBriefController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then

		local text = ba.XSTR("You must either Accept or Decline before returning to the Main Hall", 888356)
		local title = ""
		self:Show(text, title)
    end
end

function LoopBriefController:unload()
	topics.loopbrief.unload:send(self)
end

return LoopBriefController
