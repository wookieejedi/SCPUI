-----------------------------------
--Controller for the Multi Client Setup UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Dialogs = require("lib_dialogs")
local Topics = require("lib_ui_topics")
local Utils = require("lib_utils")

local Class = require("lib_class")

local ClientSetupController = Class()

ClientSetupController.PROMPT_MOTD = 1 --- @type number The message of the day enumeration
ClientSetupController.PROMPT_JOIN_PRIVATE = 2 --- @type number The join private channel enumeration
ClientSetupController.PROMPT_PLAYER_STATS = 3 --- @type number The player stats enumeration
ClientSetupController.PROMPT_FIND_PLAYER = 4 --- @type number The find player enumeration
ClientSetupController.PROMPT_FIND_PLAYER_RESPONSE = 5 --- @type number The find player response enumeration

--- Called by the class constructor
--- @return nil
function ClientSetupController:init()
	self.Player_Ids = {} --- @type string[] list of players element ids
	self.Player_List = {} --- @type scpui_multi_setup_player[] list of players
	self.Team_Elements = {} --- @type Element[] list of team elements
	self.PlayerListCleared = nil --- @type boolean Whether the player list has been cleared or not
	self.PromptControl = nil --- @type number The current prompt control. Should be one of the PROMPT_ enumerations
	self.FoundChannel = nil --- @type string The found channel during a channel search. UNUSED?
	self.PlayerStatsString = "" --- @type string The player stats string containing all divs and elements required
	self.SubmittedChatValue = "" --- @type string The submitted value from the chat input
	self.SelectedPlayerElement = nil --- @type Element The currently selected player element
	self.Netgame = nil --- @type netgame The current netgame
	self.PlayersListEl = nil --- @type Element The players list element
	self.ChatEl = nil --- @type Element The chat window element
	self.ChatInputEl = nil --- @type Element The chat input element
	self.CommonTextEl = nil --- @type Element The common text element
	self.Document = nil --- @type Document The RML document
end

--- Called by the RML document
--- @param document Document
function ClientSetupController:initialize(document)

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

	self.SelectedPlayerElement= nil

	self.SubmittedChatValue = ""

	self:updateLists()
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

--- Handle the response from a dialog box. Currently doesn't do anything but more is planned
--- @param response string The response from the dialog box
--- @return nil
function ClientSetupController:dialog_response(response)
	local path = self.PromptControl
	self.PromptControl = nil

	if path == self.PROMPT_PLAYER_STATS then --Show Player Stats
		--Do nothing!
	end

	--[[if path == self.PROMPT_MOTD then --MOTD
		--Do nothing!
	elseif path == self.PROMPT_JOIN_PRIVATE then --Join Private Channel
		if response and response ~= "" then
			ui.MultiPXO.joinPrivateChannel(response)
		end
	elseif path == self.PROMPT_PLAYER_STATS then --Show Player Stats
		--Do nothing!
	elseif path == self.PROMPT_FIND_PLAYER then --Find player
		if response and response ~= "" then
			self:GetPlayerChannel(response)
		end
	elseif path == self.PROMPT_FIND_PLAYER_RESPONSE then --Find player response
		if response == true then
			self:joinChannel(self.FoundChannel)
		end
		self.FoundChannel = nil
	end]]--
end

--- Show a dialog box
--- @param text string The text to display in the dialog box
--- @param title string The title of the dialog box
--- @param input boolean Whether the dialog box should have an input field
--- @param buttons dialog_button[] The buttons to display in the dialog box
--- @return nil
function ClientSetupController:showDialog(text, title, input, buttons)
	--Create a simple dialog box with the text and title

	local dialog = Dialogs.new()
		dialog:title(title)
		dialog:text(text)
		dialog:input(input)
		for i = 1, #buttons do
			dialog:button(buttons[i].Type, buttons[i].Text, buttons[i].Value, buttons[i].Keypress)
		end
		dialog:escape("")
		dialog:show(self.Document.context)
		:continueWith(function(response)
			self:dialog_response(response)
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.Document.context)
end

--- Check if the netgame type is squadwar and set the button accordingly
function ClientSetupController:check_squadwar()
	--Not actually sure what this button is for!
	if self.Netgame.Type == MULTI_TYPE_SQUADWAR then
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", false)
	end
end

--- Called by the RML to set the selected player to team 1
--- @return nil
function ClientSetupController:team_1_pressed()
	if self.SelectedPlayerElement then
		local player = self:getPlayerByKey(self.SelectedPlayerElement.id).Entry
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
	if self.SelectedPlayerElement then
		local player = self:getPlayerByKey(self.SelectedPlayerElement.id).Entry
		if player:isSelf() then
			self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
			self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
			player.Team = 1
		end
	end
end

--- Add a heading to the player stats
--- @param text string The text to add as a heading
--- @return nil
function ClientSetupController:addHeadingElement(text)
	self.PlayerStatsString = self.PlayerStatsString .. "<span style=\"width: 49%; float: left; text-align: right;\">" .. text .. "</span><br></br>"
end

--- Add a value to the player stats
--- @param text string The name of the value
--- @param value string The value to add
--- @return nil
function ClientSetupController:addValueElement(text, value)
	self.PlayerStatsString = self.PlayerStatsString .. "<br></br><span style=\"width: 50%; float: left; text-align: right;\">" .. text .. "</span>"
	self.PlayerStatsString = self.PlayerStatsString .. "<br></br><span style=\"width: 49%; float: right; padding-left: 1%;\">" .. value .. "</span>"
end

--- Add an empty line to the player stats
--- @return nil
function ClientSetupController:addEmptyLine()
    self.PlayerStatsString = self.PlayerStatsString .. "<br></br>"
end

--- Initialize the player stats text for display
--- @param stats scoring_stats The stats to display
--- @return string The formatted player stats string
function ClientSetupController:initializeStatsText(stats)
    self.PlayerStatsString  = ""

    self:addHeadingElement("All Time Stats")
    self:addValueElement("Primary weapon shots:", tostring(stats.PrimaryShotsFired))
    self:addValueElement("Primary weapon hits:", tostring(stats.PrimaryShotsHit))
    self:addValueElement("Primary friendly hits:", tostring(stats.PrimaryFriendlyHit))
    self:addValueElement("Primary hit %:",
                           Utils.compute_percentage(stats.PrimaryShotsHit, stats.PrimaryShotsFired))
    self:addValueElement("Primary friendly hit %:",
                           Utils.compute_percentage(stats.PrimaryFriendlyHit, stats.PrimaryShotsFired))
    self:addEmptyLine()

    self:addValueElement("Secondary weapon shots:", tostring(stats.SecondaryShotsFired))
    self:addValueElement("Secondary weapon hits:", tostring(stats.SecondaryShotsHit))
    self:addValueElement("Secondary friendly hits:", tostring(stats.SecondaryFriendlyHit))
    self:addValueElement("Secondary hit %:",
                           Utils.compute_percentage(stats.SecondaryShotsHit, stats.SecondaryShotsFired))
    self:addValueElement("Secondary friendly hit %:",
                           Utils.compute_percentage(stats.SecondaryFriendlyHit, stats.SecondaryShotsFired))
    self:addEmptyLine()

    self:addValueElement("Total kills:", tostring(stats.TotalKills))
    self:addValueElement("Assists:", tostring(stats.Assists))
    self:addEmptyLine()

    self:addValueElement("Current Score:", tostring(stats.Score))
    self:addEmptyLine()
    self:addEmptyLine()

    self:addHeadingElement("Kills by Ship Type")
    local score_from_kills = 0
    for i = 1, #tb.ShipClasses do
        local ship_cls = tb.ShipClasses[i]
        local kills    = stats:getShipclassKills(ship_cls)

        if kills > 0 then
            local name = Topics.ships.name:send(ship_cls)
            score_from_kills = score_from_kills + kills * ship_cls.Score
            self:addValueElement(name .. ":", tostring(kills))
        end
    end
    self:addValueElement("Score from kills only:", tostring(score_from_kills))

	return self.PlayerStatsString
end

--- Get the player stats and display them in a dialog box
--- @param player net_player The player to get the stats for
--- @return nil
function ClientSetupController:getPlayerStats(player)

	local stats = player:getStats()

	self.PromptControl = self.PROMPT_PLAYER_STATS

	local text = self:initializeStatsText(stats)
	local title = player.Name .. "'s stats"
	---@type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	self:showDialog(text, title, false, buttons)
end

--- Called by the RML to show the player stats for the currently selected player
--- @return nil
function ClientSetupController:pilot_info_pressed()
	if self.SelectedPlayerElement then
		self:getPlayerStats(self:getPlayerByKey(self.SelectedPlayerElement.id).Entry)
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

--- Create a player entry element and insert the entry into the Player_List table
--- @param entry scpui_multi_setup_player
--- @return Element li_el The created element
function ClientSetupController:createPlayerEntry(entry)

	local li_el = self.Document:CreateElement("li")

	local name_el = self.Document:CreateElement("div")
	name_el:SetClass("player_name", true)
	name_el:SetClass("player_item", true)
	name_el.inner_rml = entry.Name
	li_el:AppendChild(name_el)

	local team_el = self.Document:CreateElement("div")
	team_el.id = entry.InternalId .. "_team"
	team_el:SetClass("player_team", true)
	team_el:SetClass("player_item", true)
	team_el.inner_rml = "Team" .. entry.Team + 1
	li_el:AppendChild(team_el)

	--These will eventually just change color or something I dunno
	local host = entry.Host
	local observer = entry.Observer
	local captain = entry.Captain

	li_el.id = entry.InternalId
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectPlayer(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:selectPlayer(entry)
	end)
	entry.Key = li_el.id

	table.insert(self.Player_List, entry)
	table.insert(self.Team_Elements, team_el)

	return li_el
end

--- Select a player from the player list and update the UI
--- @param player scpui_multi_setup_player
--- @return nil
function ClientSetupController:selectPlayer(player)
	if self.SelectedPlayerElement then
		self.SelectedPlayerElement:SetPseudoClass("checked", false)
	end
	self.SelectedPlayerElement = self.Document:GetElementById(player.Key)
	self.SelectedPlayerElement:SetPseudoClass("checked", true)
	self:activateTeamButtons(player)
	--ui.MultiJoinGame.ActiveGames[player.Index]:setSelected()
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

--- Enable or disable the team buttons based on the player's team
--- @param player scpui_multi_setup_player
--- @return nil
function ClientSetupController:activateTeamButtons(player)
	self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
	self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
	if player.Team == 0 then
		self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
	end
	if player.Entry:isSelf() then
		self.Document:GetElementById("player_team_lock"):SetClass("hidden", true)
	else
		self.Document:GetElementById("player_team_lock"):SetClass("hidden", false)
	end
end

--- Add a player to the Player_Ids list and the PlayersListEl
--- @param player scpui_multi_setup_player
--- @return nil
function ClientSetupController:addPlayer(player)
	self.PlayersListEl:AppendChild(self:createPlayerEntry(player))
	table.insert(self.Player_Ids, player.InternalId)
end

--- Remove a player from the Player_Ids list and the PlayersListEl
--- @param idx number The index of the player to remove
--- @return nil
function ClientSetupController:removePlayer(idx)
	local player_idx = self:getPlayerIndexByID(self.Player_Ids[idx])
	if player_idx > 0 then
		local el = self.Document:GetElementById(self.Player_List[player_idx].Key)
		--Also remove the team element to prevent an error later
		self:removeTeamElement(self.Player_Ids[idx] .. "_team")
		self.PlayersListEl:RemoveChild(el)
		table.remove(self.Player_List, player_idx)
	end
	table.remove(self.Player_Ids, idx)
end

--- Update the player team
--- @param player scpui_multi_setup_player
--- @return nil
function ClientSetupController:updateTeam(player)
	player.Team = player.Entry.Team
	self.Document:GetElementById(player.InternalId .. "_team").inner_rml = "Team" .. player.Team + 1
	self:activateTeamButtons(player)
end

--- Remove a team element from the Team_Elements list
--- @param id string The id of the element to remove
--- @return nil
function ClientSetupController:removeTeamElement(id)
	for i = 1, #self.Team_Elements do
		if self.Team_Elements[i].id == id then
			table.remove(self.Team_Elements, i)
			return
		end
	end
end

--- Get the player index by ID
--- @param id string The ID to search for
--- @return number The index of the player
function ClientSetupController:getPlayerIndexByID(id)
	for i = 1, #self.Player_List do
		if self.Player_List[i].InternalId == id then
			return i
		end
	end
	return -1
end

--- Hide or show the team buttons
--- @param toggle boolean Whether to hide or show the team buttons
--- @return nil
function ClientSetupController:hideTeamButtons(toggle)
	self.Document:GetElementById("team_1_cont"):SetClass("hidden", toggle)
	self.Document:GetElementById("team_2_cont"):SetClass("hidden", toggle)

	for i = 1, #self.Team_Elements do
		self.Team_Elements[i]:SetClass("hidden", toggle)
	end
end

--- Runs the network commands to update all player, chat, team lists, and other UI elements
--- Runs continuously every 0.01 seconds
--- @return nil
function ClientSetupController:updateLists()
	ui.MultiClientSetup.runNetwork()
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

	if #ui.MultiGeneral.NetPlayers == 0 then
		ScpuiSystem:clearEntries(self.PlayersListEl)
		self.PlayersListEl.inner_rml = "Loading Players..."
		self.PlayerListCleared = true
	else
		if self.PlayerListCleared then
			ScpuiSystem:clearEntries(self.PlayersListEl)
			self.PlayerListCleared = nil
		end
		-- check for new players
		for i = 1, #ui.MultiGeneral.NetPlayers do
			if ui.MultiGeneral.NetPlayers[i]:isValid() then
				local int_id = ui.MultiGeneral.NetPlayers[i].Name .. "_" .. i
				if not Utils.table.contains(self.Player_Ids, int_id) then
					---@type scpui_multi_setup_player
					local entry = {
						Name = ui.MultiGeneral.NetPlayers[i].Name,
						Team = ui.MultiGeneral.NetPlayers[i].Team,
						Host = ui.MultiGeneral.NetPlayers[i].Host,
						Observer = ui.MultiGeneral.NetPlayers[i].Observer,
						Captain = ui.MultiGeneral.NetPlayers[i].Captain,
						InternalId = int_id,
						Index = i,
						Entry = ui.MultiGeneral.NetPlayers[i]
					}
					self:addPlayer(entry)
				end
			end
		end

		-- now check for players that expired
		local players = {}

		-- create a simple table to use for comparing
		for i = 1, #ui.MultiGeneral.NetPlayers do
			table.insert(players, ui.MultiGeneral.NetPlayers[i].Name .. "_" .. i)
		end

		for i = 1, #self.Player_Ids do
			--remove it if it no longer exists on the server
			if not Utils.table.contains(players, self.Player_Ids[i]) then
				self:removePlayer(i)
			end
		end
	end

	if self.Netgame and self.Netgame.Type == MULTI_TYPE_TEAM then
		self:hideTeamButtons(false)
	else
		self:hideTeamButtons(true)
	end

	--Update the player teams
	for i = 1, #self.Player_List do
		if self.Player_List[i].Team ~= self.Player_List[i].Entry.Team then
			self:updateTeam(self.Player_List[i])
		end
	end

	--Select the first player
	if self.SelectedPlayerElement == nil and #self.Player_List > 0 then
		self:selectPlayer(self.Player_List[1])
	end

	self:check_squadwar()

	self.CommonTextEl.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")

	--self.Document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

--- Called when the screen is being unloaded
--- @return nil
function ClientSetupController:unload()
	Topics.multiclientsetup.unload:send(self)
end

return ClientSetupController
