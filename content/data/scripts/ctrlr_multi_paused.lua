-----------------------------------
--Controller for the Multi Pause UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local MultiPausedController = Class()

--- Called by the class constructor
--- @return nil
function MultiPausedController:init()
	self.Document = nil --- @type Document the RML document
	self.Pauser = nil --- @type string the name of the player who paused the game
	self.ChatEl = nil --- @type Element the chat window element
	self.ChatInputEl = nil --- @type Element the chat input element
	self.SubmittedChatValue = nil --- @type string the value of the chat input
	self.ScreenRender = nil --- @type string the screen render image blob
end

--- Called by the RML document
--- @param document Document
function MultiPausedController:initialize(document)

	ui.MultiPauseScreen.initPause()

	if self.ScreenRender == nil then
		self.ScreenRender = gr.screenToBlob()
	end

    self.Document = document

	if mn.isInMission() then
		ui.MultiPauseScreen.initPause()
	end

	self.Pauser = ui.MultiPauseScreen.Pauser
	self.Document:GetElementById("pauser_name").inner_rml = self.Pauser

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.ChatEl = self.Document:GetElementById("chat_window")
	self.ChatInputEl = self.Document:GetElementById("chat_input")

	local main_bg = self.Document:GetElementById("screenrender")
	local img_el = self.Document:CreateElement("img")
	main_bg:AppendChild(img_el)
	img_el:RemoveAttribute("src")
	img_el:SetAttribute("src", self.ScreenRender)

	self.SubmittedChatValue = ""

	self:updateLists()
	ui.MultiGeneral.setPlayerState()

	Topics.multipaused.initialize:send(self)

end

--- Called by the RML to submit the chat to the server
--- @return nil
function MultiPausedController:submit_pressed()
	if self.SubmittedChatValue then
		self:sendChat()
	end
end

--- Submits the current chat value to the server
--- @return nil
function MultiPausedController:sendChat()
	if string.len(self.SubmittedChatValue) > 0 then
		ui.MultiGeneral.sendChat(self.SubmittedChatValue)
		self.ChatInputEl:SetAttribute("value", "")
		self.SubmittedChatValue = ""
	end
end

--- Called by the RML when the chat input loses focus
--- @return nil
function MultiPausedController:input_focus_lost()
	--do nothing
end

--- Called by the RML when the chat input accepts a keypress
--- @param event Event the keypress event
--- @return nil
function MultiPausedController:input_change(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.ChatInputEl:GetAttribute("value")
		self.SubmittedChatValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

--- Called by the RML when the exit button is pressed
function MultiPausedController:exit_pressed()
	ui.MultiPauseScreen.closePause(true)
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function MultiPausedController:global_keydown(element, event)
    if (event.parameters.key_identifier == rocket.key_identifier.ESCAPE) or (event.parameters.key_identifier == rocket.key_identifier.PAUSE) then
        ui.MultiPauseScreen.requestUnpause()
	end
end

--- Called when the screen is being unloaded
--- @return nil
function MultiPausedController:unload()
	ui.MultiPauseScreen.closePause()
	self.screenRender = nil

	Topics.multipaused.unload:send(self)
end

--- Runs all the network functions to update the chat. Runs every 0.01 seconds
--- @return nil
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
	self.ChatEl.inner_rml = txt
	self.ChatEl.scroll_top = self.ChatEl.scroll_height

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

return MultiPausedController
