-----------------------------------
--Controller for the Multi Client Setup UI
-----------------------------------

local Dialogs = require("lib_dialogs")
local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local AbstractMultiController = require("ctrlr_multi_common")

--- This multi controller is merged with the Multi Common Controller
local ClientSetupController = Class(AbstractMultiController)

--- Called by the class constructor
--- @return nil
function ClientSetupController:init()
	self.Player_List = {} --- @type scpui_multi_setup_player[] list of players
	self.SubmittedChatValue = "" --- @type string The submitted value from the chat input
	self.SelectedPlayerEl = nil --- @type Element The currently selected player element
	self.Netgame = nil --- @type netgame The current netgame
	self.PlayersListEl = nil --- @type Element The players list element
	self.ChatEl = nil --- @type Element The chat window element
	self.ChatInputEl = nil --- @type Element The chat input element
	self.CommonTextEl = nil --- @type Element The common text element
	self.Document = nil --- @type Document The RML document

	self.Subclass = AbstractMultiController.SUBCLASS_CLIENT_SETUP
end

--- Called by the RML document
--- @param document Document
function ClientSetupController:initialize(document)
	AbstractMultiController.initialize(self, document)
	ScpuiSystem.data.memory.multiplayer_general.Context = self

	self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.PlayersListEl = self.Document:GetElementById("players_list_ul")
	self.ChatEl = self.Document:GetElementById("chat_window")
	self.ChatEl = self.Document:GetElementById("chat_window")
	self.ChatInputEl = self.Document:GetElementById("chat_input")
	self.CommonTextEl = self.Document:GetElementById("common_text")
	--self.status_text_el = self.Document:GetElementById("status_text")

	ui.MultiClientSetup.initMultiClientSetup()

	self.Netgame = ui.MultiGeneral.getNetGame()

	self.SelectedPlayerEl= nil

	self.SubmittedChatValue = ""

	ScpuiSystem.data.memory.multiplayer_general.RunNetwork = true
	ui.MultiGeneral.setPlayerState()

	Topics.multiclientsetup.initialize:send(self)

end

--- Exit the Multi Client Setup UI
--- @param quit boolean Whether to quit the setup or proceed
function ClientSetupController:exit(quit)
	if quit == true then
		ui.MultiClientSetup.closeMultiClientSetup()
	end
end

--- Handle the response from a dialog box.
--- @return nil
function ClientSetupController:dialogResponse()
	local path = ScpuiSystem.data.memory.multiplayer_general.DialogType
	ScpuiSystem.data.memory.multiplayer_general.DialogType = nil

	local response = ScpuiSystem.data.memory.multiplayer_general.DialogResponse
	ScpuiSystem.data.memory.multiplayer_general.DialogResponse = nil

	if path == AbstractMultiController.DIALOG_PLAYER_STATS then --Show Player Stats
		--Do nothing!
	end
end

--- Called by the RML to set the selected player to team 1
--- @return nil
function ClientSetupController:team_1_pressed()
	if self.SelectedPlayerEl then
		local player = self:getPlayerByKey(self.SelectedPlayerEl.id).Entry
		if player:isSelf() then
			self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
			self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
			player.Team = 0
		end
	end
end

--- Called by the RML to set the selected player to team 2
--- @return nil
function ClientSetupController:team_2_pressed()
	if self.SelectedPlayerEl then
		local player = self:getPlayerByKey(self.SelectedPlayerEl.id).Entry
		if player:isSelf() then
			self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
			self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
			player.Team = 1
		end
	end
end

--- Get the player stats and display them in a dialog box
--- @param player net_player The player to get the stats for
--- @return nil
function ClientSetupController:getPlayerStats(player)

	local stats = player:getStats()

	ScpuiSystem.data.memory.multiplayer_general.DialogType = AbstractMultiController.DIALOG_PLAYER_STATS

	local text = AbstractMultiController.initializeStatsText(self, stats)
	local title = player.Name .. "'s stats"
	---@type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	AbstractMultiController.showDialog(self, text, title, false, buttons)
end

--- Called by the RML to show the player stats for the currently selected player
--- @return nil
function ClientSetupController:pilot_info_pressed()
	if self.SelectedPlayerEl then
		self:getPlayerStats(self:getPlayerByKey(self.SelectedPlayerEl.id).Entry)
	end
end

--- Called by the RML to submit text to the chat
--- @return nil
function ClientSetupController:submit_pressed()
	if self.SubmittedChatValue then
		self:sendChat()
	end
end

--- Called by the RML to exist the Client Setup UI
--- @return nil
function ClientSetupController:exit_pressed()
	self:exit(true)
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function ClientSetupController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit(true)
	end
end

--- Send the current input chat string to the server
--- @return nil
function ClientSetupController:sendChat()
	if string.len(self.SubmittedChatValue) > 0 then
		ui.MultiGeneral.sendChat(self.SubmittedChatValue)
		self.ChatInputEl:SetAttribute("value", "")
		self.SubmittedChatValue = ""
	end
end

--- Called by the RML when chat focus is lost
--- @return nil
function ClientSetupController:input_focus_lost()
	--do nothing
end

--- Called by the RML when the input box accepts keypresses
--- @param event Event The event that was triggered
--- @return nil
function ClientSetupController:input_change(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.ChatInputEl:GetAttribute("value")
		self.SubmittedChatValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

--- Get a player from the Player_List by key
--- @param key string The key to search for
--- @return scpui_multi_setup_player? player The player object
function ClientSetupController:getPlayerByKey(key)
	for i = 1, #self.Player_List do
		if self.Player_List[i].Key == key then
			return self.Player_List[i]
		end
	end
end

--- Called when the screen is being unloaded
--- @return nil
function ClientSetupController:unload()
	ScpuiSystem.data.memory.multiplayer_general.RunNetwork = false
	Topics.multiclientsetup.unload:send(self)
end

return ClientSetupController
