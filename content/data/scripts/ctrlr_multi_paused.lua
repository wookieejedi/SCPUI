local class = require("lib_class")
local async_util = require("lib_async")
local utils = require("lib_utils")
local dialogs = require("lib_dialogs")
local topics = require("lib_ui_topics")

local MultiPausedController = class()

local pausedText = {"GAME IS PAUSED", 888347}

local screenRender = nil

function MultiPausedController:init()
end

---@param document Document
function MultiPausedController:initialize(document)

	ui.MultiPauseScreen.initPause()
	
	if screenRender == nil then
		screenRender = gr.screenToBlob()
	end

    self.Document = document
	
	if mn.isInMission() then
		ui.MultiPauseScreen.initPause()
	end
	
	self.pauser = ui.MultiPauseScreen.Pauser
	self.Document:GetElementById("pauser_name").inner_rml = self.pauser

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.chat_el = self.Document:GetElementById("chat_window")
	self.input_id = self.Document:GetElementById("chat_input")
	
	local main_bg = self.Document:GetElementById("screenrender")
	local imgEl = self.Document:CreateElement("img")
	main_bg:AppendChild(imgEl)
	imgEl:RemoveAttribute("src")
	imgEl:SetAttribute("src", screenRender)
	
	self.submittedValue = ""
	
	self:updateLists()
	ui.MultiGeneral.setPlayerState()
	
	topics.multipaused.initialize:send(self)
	
end

function MultiPausedController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function MultiPausedController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function MultiPausedController:InputFocusLost()
	--do nothing
end

function MultiPausedController:InputChange(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

function MultiPausedController:exit_pressed()
	ui.MultiPauseScreen.closePause(true)
end

function MultiPausedController:global_keydown(element, event)
    if (event.parameters.key_identifier == rocket.key_identifier.ESCAPE) or (event.parameters.key_identifier == rocket.key_identifier.PAUSE) then
        ui.MultiPauseScreen.requestUnpause()
	end
end

function MultiPausedController:unload()
	ui.MultiPauseScreen.closePause()
	self.screenRender = nil
	
	topics.multipaused.unload:send(self)
end

function MultiPausedController:updateLists()
	ui.MultiPauseScreen.runNetwork()
	local chat = ui.MultiGeneral.getChat()
	
	local txt = ""
	for i = 1, #chat do
		local line = ""
		if chat[i].Callsign ~= "" then
			line = chat[i].Callsign .. ": " .. chat[i].Message
		else
			line = chat[i].Message
		end
		txt = txt .. ScpuiSystem:replaceAngleBrackets(line) .. "<br></br>"
	end
	self.chat_el.inner_rml = txt
	self.chat_el.scroll_top = self.chat_el.scroll_height
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return MultiPausedController
