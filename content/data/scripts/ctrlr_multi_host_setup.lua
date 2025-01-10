-----------------------------------
--Controller for the Multi Host Setup UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Dialogs = require("lib_dialogs")
local Topics = require("lib_ui_topics")
local Utils = require("lib_utils")

local Class = require("lib_class")

local HostSetupController = Class()

--- Called by the class constructor
--- @return nil
function HostSetupController:init()
	self.Mission_Files = {} --- @type string[] list of mission files
	self.Missions_List = {} --- @type scpui_multi_setup_mission[] list of actual missions
	self.Player_Ids = {} --- @type string[] list of players
	self.Players_List = {} --- @type scpui_multi_setup_player[] list of actual players
	self.Team_Elements = {} --- @type Element[] list of team elements
	self.MissionsListEl = nil --- @type Element mission list element
	self.PlayersListEl = nil --- @type Element player list element
	self.ChatEl = nil --- @type Element chat element
	self.ChatInputEl = nil --- @type Element chat input element
	self.CommonTextEl = nil --- @type Element common text element
	self.Document = nil --- @type Document the RML document
	self.Netgame = nil --- @type netgame the netgame object
	self.SelectedPlayerEl = nil --- @type Element the selected player element
	self.SelectedMissionEl = nil --- @type Element the selected mission element
	self.SubmittedChatValue = "" --- @type string the submitted chat value
	self.GameClosed = false --- @type boolean whether the game is closed
	self.Squadwar = false --- @type boolean whether the game is a squadwar
end

--- Called by the RML document
--- @param document Document
function HostSetupController:initialize(document)

	self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.MissionsListEl = self.Document:GetElementById("mission_list_ul")
	self.PlayersListEl = self.Document:GetElementById("players_list_ul")
	self.ChatEl = self.Document:GetElementById("chat_window")
	self.ChatInputEl = self.Document:GetElementById("chat_input")
	self.CommonTextEl = self.Document:GetElementById("common_text")
	--self.status_text_el = self.Document:GetElementById("status_text")

	if not ScpuiSystem.data.memory.multiplayer_host.MultiHostSetup then
		ui.MultiHostSetup.initMultiHostSetup()
		ScpuiSystem.data.memory.multiplayer_host.MultiHostSetup = true
		ScpuiSystem.data.memory.multiplayer_host.HostFilter = nil
		ScpuiSystem.data.memory.multiplayer_host.HostList = "missions"
	end

	self.Netgame = ui.MultiGeneral.getNetGame()

	self:buildFilters()

	if ScpuiSystem.data.memory.multiplayer_host.HostList == "missions" then
		self.Document:GetElementById("missions_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("campaigns_btn"):SetPseudoClass("checked", true)
	end

	self.SelectedPlayerEl= nil
	self.SelectedMissionEl = nil

	self.SubmittedChatValue = ""

	self:updateLists()
	ui.MultiGeneral.setPlayerState()

	self.GameClosed = self.Netgame.Closed
	if self.Netgame.Type == MULTI_TYPE_SQUADWAR then
		self.Squadwar = true
	else
		self.Squadwar = false
	end

	if self.GameClosed then
		self.Document:GetElementById("close_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("close_btn"):SetPseudoClass("checked", false)
	end

	if self.Squadwar then
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", false)
	end

	Topics.multihostsetup.initialize:send(self)

end

--- Add the mission filters to the dropdown
--- @return nil
function HostSetupController:buildFilters()
	local select_el = Element.As.ElementFormControlDataSelect(self.Document:GetElementById("dropdown_cont").first_child)

	ScpuiSystem:clearDropdown(select_el)

	select_el:Add(ba.XSTR("All", 1256), "All", 1)
	select_el:Add(ba.XSTR("Co-op", 1257), "Co-op", 2)
	select_el:Add(ba.XSTR("Team", 1258), "Team", 3)
	select_el:Add(ba.XSTR("Dogfight", 1259), "Dogfight", 4)

	select_el.selection = 1
end

--- Exits the host setup screen
--- @param quit boolean True to accept the changes, false to cancel
--- @return nil
function HostSetupController:exit(quit)
	ui.MultiHostSetup.closeMultiHostSetup(quit)
	ScpuiSystem.data.memory.multiplayer_host.MultiHostSetup = nil
end

--- Respond to dialog closure
--- @param response number The response from the dialog
--- @return nil
function HostSetupController:dialogResponse(response)
	--- Only dialog here is showing player stats which requires no response
	return

	--[[local path = self.PromptControl
	self.PromptControl = nil
	if path == 1 then --MOTD
		--Do nothing!
	elseif path == 2 then --Join Private Channel
		if response and response ~= "" then
			ui.MultiPXO.joinPrivateChannel(response)
		end
	elseif path == 3 then --Show Player Stats
		--Do nothing!
	elseif path == 4 then --Find player
		if response and response ~= "" then
			self:GetPlayerChannel(response)
		end
	elseif path == 5 then --Find player response
		if response == true then
			self:joinChannel(self.foundChannel)
		end
		self.foundChannel = nil
	end]]--
end

--- Show a dialog box
--- @param text string The text to display
--- @param title string The title of the dialog
--- @param input boolean Whether to show an input box
--- @param buttons dialog_button[] The buttons to display
--- @return nil
function HostSetupController:showDialog(text, title, input, buttons)
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
			self:dialogResponse(response)
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.Document.context)
end

--- Called by the RML when the squadwar button is pressed
--- @return nil
function HostSetupController:squadwar_pressed()
	--Not actually sure what this button is for!
	if self.Squadwar == false then
		self.Netgame.Type = MULTI_TYPE_SQUADWAR
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("squadwar_btn"):SetPseudoClass("checked", false)
	end
end

--- Called by the RML when the help button is pressed
--- @return nil
function HostSetupController:help_pressed()
	--show help overlay
end

--- Called by the RML when the commit button is pressed
--- @return nil
function HostSetupController:commit_pressed()
	ui.MultiHostSetup.closeMultiHostSetup(true)
	ScpuiSystem.data.memory.multiplayer_host.MultiHostSetup = nil
end

--- Called by the RML when the host options button is pressed
--- @return nil
function HostSetupController:host_options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_HOST_OPTIONS"])
end

--- Called by the RML when the missions button is pressed
--- @return nil
function HostSetupController:missions_pressed()
	self.Document:GetElementById("campaigns_btn"):SetPseudoClass("checked", false)
	self.Document:GetElementById("missions_btn"):SetPseudoClass("checked", true)
	ScpuiSystem.data.memory.multiplayer_host.HostList = "missions"
end

--- Called by the RML when the campaigns button is pressed
--- @return nil
function HostSetupController:campaigns_pressed()
	self.Document:GetElementById("missions_btn"):SetPseudoClass("checked", false)
	self.Document:GetElementById("campaigns_btn"):SetPseudoClass("checked", true)
	ScpuiSystem.data.memory.multiplayer_host.HostList = "campaigns"
end

--- Called by the RML when the team 1 button is pressed
--- @return nil
function HostSetupController:team_1_pressed()
	if self.SelectedPlayerEl then
		self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
		self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
		self:getPlayerByKey(self.SelectedPlayerEl.id).Entry.Team = 0
	end
end

--- Called by the RML when the team 2 button is pressed
--- @return nil
function HostSetupController:team_2_pressed()
	if self.SelectedPlayerEl then
		self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
		self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
		self:getPlayerByKey(self.SelectedPlayerEl.id).Entry.Team = 1
	end
end

--- Add a heading element to the player stats
--- @param text string The text to add
--- @return nil
function HostSetupController:addHeadingElement(text)
	self.playerStats = self.playerStats .. "<span style=\"width: 49%; float: left; text-align: right;\">" .. text .. "</span><br></br>"
end

--- Add a value element to the player stats
--- @param text string The name of the value
--- @param value string The value to add
--- @return nil
function HostSetupController:addValueElement(text, value)
	self.playerStats = self.playerStats .. "<br></br><span style=\"width: 50%; float: left; text-align: right;\">" .. text .. "</span>"
	self.playerStats = self.playerStats .. "<br></br><span style=\"width: 49%; float: right; padding-left: 1%;\">" .. value .. "</span>"
end

--- Add an empty line to the player stats
--- @return nil
function HostSetupController:addEmptyLine()
    self.playerStats = self.playerStats .. "<br></br>"
end

--- Initialize the player stats text
--- @param stats scoring_stats The player stats to display
--- @return string stats The formatted player stats
function HostSetupController:initializeStatsText(stats)
    self.playerStats  = ""

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

	return self.playerStats
end

--- Get the player stats
--- @param player net_player The player to get the stats for
function HostSetupController:getPlayerStats(player)

	local stats = player:getStats()

	--self.PromptControl = 3

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

--- Called by the RML when the player info button is pressed
--- @return nil
function HostSetupController:pilot_info_pressed()
	if self.SelectedPlayerEl then
		self:getPlayerStats(self:getPlayerByKey(self.SelectedPlayerEl.id).Entry)
	end
end

--- Kick a player from the game
--- @param player net_player The player to kick
--- @return nil
function HostSetupController:KickPlayer(player)
	player:kickPlayer()
end

--- Called by the RML when the kick button is pressed to kick the selected player
--- @return nil
function HostSetupController:kick_pressed()
	if self.SelectedPlayerEl then
		self:KickPlayer(self:getPlayerByKey(self.SelectedPlayerEl.id).Entry)
	end
end

--- Called by the RML when the ban button is pressed
--- @return nil
function HostSetupController:close_pressed()
	--TODO: If not host then hide this button
	if self.GameClosed == true then
		self.Netgame.Closed = false
	else
		self.Netgame.Closed = true
	end
	self.GameClosed = self.Netgame.Closed
	self.Document:GetElementById("close_btn"):SetPseudoClass("checked", self.Netgame.Closed)
end

--- Called by the RML when the chat button is pressed
--- @return nil
function HostSetupController:submit_pressed()
	if self.SubmittedChatValue then
		self:sendChat()
	end
end

--- Called by the RML when the options button is pressed
--- @return nil
function HostSetupController:options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

--- Called by the RML when the exit button is pressed
--- @return nil
function HostSetupController:exit_pressed()
	self:exit(false)
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function HostSetupController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit(false)
	end
end

--- Send the chat string to the server
--- @return nil
function HostSetupController:sendChat()
	if string.len(self.SubmittedChatValue) > 0 then
		ui.MultiGeneral.sendChat(self.SubmittedChatValue)
		self.ChatInputEl:SetAttribute("value", "")
		self.SubmittedChatValue = ""
	end
end

--- Called by the RML when the chat input is no longer focused
function HostSetupController:input_focus_lost()
	--do nothing
end

--- Called by the RML when the chat input accepts a keypress
--- @param event Event The event that was triggered
--- @return nil
function HostSetupController:input_change(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.ChatInputEl:GetAttribute("value")
		self.SubmittedChatValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

--- Called by the RML when the filter dropdown changes
--- @return nil
function HostSetupController:filter_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.Document:GetElementById("dropdown_cont").first_child)
	local val = select_el.options[select_el.selection - 1].value

	if val == "Co-op" then
		ScpuiSystem.data.memory.multiplayer_host.HostFilter = MULTI_TYPE_COOP
	elseif val == "Team" then
		ScpuiSystem.data.memory.multiplayer_host.HostFilter = MULTI_TYPE_TEAM
	elseif val == "Dogfight" then
		ScpuiSystem.data.memory.multiplayer_host.HostFilter = MULTI_TYPE_DOGFIGHT
	else
		ScpuiSystem.data.memory.multiplayer_host.HostFilter = nil
	end

	self.Mission_Files = {} -- list of mission files + ids only
	self.Missions_List = {} -- list of actual missions
	ScpuiSystem:clearEntries(self.MissionsListEl)
	self.SelectedMissionEl = nil
end

--- Creates a mission entry element
--- @param entry scpui_multi_setup_mission The mission to create an element for
--- @return Element mission The created element
function HostSetupController:createMissionEntry(entry)

	local li_el = self.Document:CreateElement("li")

	local type_el = self.Document:CreateElement("div")
	type_el:SetClass("type", true)
	type_el:SetClass("mission_item", true)
	if entry.Type == MULTI_TYPE_COOP then
		type_el.inner_rml = "co-op"
	elseif entry.Type == MULTI_TYPE_TEAM then
		type_el.inner_rml = "team"
	elseif entry.Type == MULTI_TYPE_DOGFIGHT then
		type_el.inner_rml = "dogfight"
	end
	li_el:AppendChild(type_el)

	local builtin_el = self.Document:CreateElement("div")
	builtin_el:SetClass("mission_builtin", true)
	builtin_el:SetClass("mission_item", true)
	if entry.Builtin then
		builtin_el.inner_rml = "*"
	else
		builtin_el.inner_rml = ""
	end
	li_el:AppendChild(builtin_el)

	local validity_el = self.Document:CreateElement("div")
	validity_el:SetClass("mission_validity", true)
	validity_el:SetClass("mission_item", true)
	if entry.Builtin then
		validity_el.inner_rml = "X"
	else
		validity_el.inner_rml = ""
	end
	li_el:AppendChild(validity_el)

	local name_el = self.Document:CreateElement("div")
	name_el:SetClass("mission_name", true)
	name_el:SetClass("mission_item", true)
	name_el.inner_rml = entry.Name
	li_el:AppendChild(name_el)

	local players_el = self.Document:CreateElement("div")
	players_el:SetClass("mission_players", true)
	players_el:SetClass("mission_item", true)
	players_el.inner_rml = tostring(entry.Players)
	li_el:AppendChild(players_el)

	local filename_el = self.Document:CreateElement("div")
	filename_el:SetClass("mission_filename", true)
	filename_el:SetClass("mission_item", true)
	filename_el.inner_rml = entry.Filename
	li_el:AppendChild(filename_el)

	li_el.id = entry.InternalId
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectMission(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:selectMission(entry)
	end)
	entry.Key = li_el.id

	table.insert(self.Missions_List, entry)

	return li_el
end

--- Select a mission element
--- @param mission scpui_multi_setup_mission The mission to select
--- @return nil
function HostSetupController:selectMission(mission)
	if self.SelectedMissionEl then
		self.SelectedMissionEl:SetPseudoClass("checked", false)
	end
	self.SelectedMissionEl = self.Document:GetElementById(mission.Key)
	self.SelectedMissionEl:SetPseudoClass("checked", true)
	self.Netgame:setMission(mission.Entry)
end

--- Add a mission entry to the list and the UI
--- @param mission scpui_multi_setup_mission The mission to add
--- @return nil
function HostSetupController:addMission(mission)
	self.MissionsListEl:AppendChild(self:createMissionEntry(mission))
	table.insert(self.Mission_Files, mission.InternalId)

	if mission.Filename == self.Netgame.MissionFilename then
		self:selectMission(mission)
	end
end

--- Remove a mission entry from the list and the UI
--- @param idx number The index of the mission to remove
--- @return nil
function HostSetupController:removeMission(idx)
	local mission_idx = self:getMissionIndexByID(self.Mission_Files[idx])
	if mission_idx > 0 then
		if self.SelectedMissionEl and self.SelectedMissionEl.id == self.Missions_List[mission_idx].Key then
			self.SelectedMissionEl = nil
		end
		local el = self.Document:GetElementById(self.Missions_List[mission_idx].Key)
		self.MissionsListEl:RemoveChild(el)
		table.remove(self.Missions_List, mission_idx)
	end
	table.remove(self.Mission_Files, idx)
end

--- Get the index of a mission by its ID
--- @param id string The ID of the mission
--- @return number index The index of the mission
function HostSetupController:getMissionIndexByID(id)
	for i = 1, #self.Missions_List do
		if self.Missions_List[i].InternalId == id then
			return i
		end
	end
	return -1
end

--- Create a player entry element
--- @param entry scpui_multi_setup_player The player to create an element for
--- @return Element li_el The created element
function HostSetupController:createPlayerEntry(entry)

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

	table.insert(self.Players_List, entry)
	table.insert(self.Team_Elements, team_el)

	return li_el
end

--- Select a player element
--- @param player scpui_multi_setup_player The player to select
--- @return nil
function HostSetupController:selectPlayer(player)
	if self.SelectedPlayerEl then
		self.SelectedPlayerEl:SetPseudoClass("checked", false)
	end
	self.SelectedPlayerEl = self.Document:GetElementById(player.Key)
	self.SelectedPlayerEl:SetPseudoClass("checked", true)
	self:activateTeamButtons(player)
	--ui.MultiJoinGame.ActiveGames[player.Index]:setSelected()
end

--- Get a player by their key
--- @param key string The key of the player
--- @return scpui_multi_setup_player? player The player
function HostSetupController:getPlayerByKey(key)
	for i = 1, #self.Players_List do
		if self.Players_List[i].Key == key then
			return self.Players_List[i]
		end
	end
end

--- Activate or deactivate the team buttons for a player
function HostSetupController:activateTeamButtons(player)
	self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
	self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
	if player.Team == 0 then
		self.Document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
	else
		self.Document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
	end
end

--- Add a player entry to the list and the UI
--- @param player scpui_multi_setup_player The player to add
--- @return nil
function HostSetupController:addPlayer(player)
	self.PlayersListEl:AppendChild(self:createPlayerEntry(player))
	table.insert(self.Player_Ids, player.InternalId)
end

--- Remove a player entry from the list and the UI
--- @param idx number The index of the player to remove
--- @return nil
function HostSetupController:removePlayer(idx)
	local player_idx = self:getPlayerIndexByID(self.Player_Ids[idx])
	if player_idx > 0 then
		local el = self.Document:GetElementById(self.Players_List[player_idx].Key)
		--Also remove the team element to prevent an error later
		self:removeTeamElement(self.Player_Ids[idx] .. "_team")
		self.PlayersListEl:RemoveChild(el)
		table.remove(self.Players_List, player_idx)
	end
	table.remove(self.Player_Ids, idx)
end

--- Update a player's team
--- @param player scpui_multi_setup_player The player to update
--- @return nil
function HostSetupController:updateTeam(player)
	player.Team = player.Entry.Team
	self.Document:GetElementById(player.InternalId .. "_team").inner_rml = "Team" .. player.Team + 1
	self:activateTeamButtons(player)
end

--- Remove a team element from the list
--- @param id string The ID of the team element
--- @return nil
function HostSetupController:removeTeamElement(id)
	for i = 1, #self.Team_Elements do
		if self.Team_Elements[i].id == id then
			table.remove(self.Team_Elements, i)
			return
		end
	end
end

--- Get the index of a player by their ID
--- @param id string The ID of the player
--- @return number index The index of the player
function HostSetupController:getPlayerIndexByID(id)
	for i = 1, #self.Players_List do
		if self.Players_List[i].InternalId == id then
			return i
		end
	end
	return -1
end

--- Toggle the visibility of the team buttons
--- @param toggle boolean True to hide the buttons, false to show them
--- @return nil
function HostSetupController:hideTeamButtons(toggle)
	self.Document:GetElementById("team_1_cont"):SetClass("hidden", toggle)
	self.Document:GetElementById("team_2_cont"):SetClass("hidden", toggle)

	for i = 1, #self.Team_Elements do
		self.Team_Elements[i]:SetClass("hidden", toggle)
	end
end

--- Runs the network functions to update the chat and other network lists. Runs every 0.01 seconds
--- @return nil
function HostSetupController:updateLists()
	ui.MultiHostSetup.runNetwork()
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

	local list = ui.MultiHostSetup.NetMissions

	if ScpuiSystem.data.memory.multiplayer_host.HostList ~= "missions" then
		list = ui.MultiHostSetup.NetCampaigns
	end

	if #list == 0 then
		ScpuiSystem:clearEntries(self.MissionsListEl)
		self.MissionsListEl.inner_rml = "Loading Mission List..."
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:clearEntries(self.MissionsListEl)
			self.MissionsListEl.inner_rml = ""
			self.cleared = nil
		end
		-- check for new missions
		for i = 1, #list do
			local int_id = list[i].Filename .. "_" .. i
			local add_entry = true
			if ScpuiSystem.data.memory.multiplayer_host.HostFilter then
				if list[i].Type == ScpuiSystem.data.memory.multiplayer_host.HostFilter then
					add_entry = true
				else
					add_entry = false
				end
			end
			if add_entry and not Utils.table.contains(self.Mission_Files, int_id) then
				---@type scpui_multi_setup_mission
				local entry = {
					Filename = list[i].Filename,
					Name = list[i].Name,
					Players = list[i].Players,
					Respawn = list[i].Respawn,
					Tracker = list[i].Tracker,
					Type = list[i].Type,
					Builtin = list[i].Builtin,
					InternalId = int_id,
					Index = i,
					Entry = list[i]
				}
				self:addMission(entry)
			end
		end

		-- now check for missions that expired
		local missions = {}

		-- create a simple table to use for comparing
		for i = 1, #list do
			table.insert(missions, list[i].Filename .. "_" .. i)
		end

		for i = 1, #self.Mission_Files do
			--remove it if it no longer exists on the server
			if not Utils.table.contains(missions, self.Mission_Files[i]) then
				self:removeMission(i)
			end
		end
	end

	if #ui.MultiGeneral.NetPlayers == 0 then
		ScpuiSystem:clearEntries(self.PlayersListEl)
		self.PlayersListEl.inner_rml = "Loading Players..."
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:clearEntries(self.PlayersListEl)
			self.cleared = nil
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
	for i = 1, #self.Players_List do
		if self.Players_List[i].Team ~= self.Players_List[i].Entry.Team then
			self:updateTeam(self.Players_List[i])
		end
	end

	--Select the first player
	if self.SelectedPlayerEl == nil and #self.Players_List > 0 then
		self:selectPlayer(self.Players_List[1])
	end

	--Select the first mission
	if self.Netgame and self.SelectedMissionEl == nil and #self.Missions_List > 0 then
		self:selectMission(self.Missions_List[1])
	end

	--self.Document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText
	self.CommonTextEl.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

--- Called when the screen is being unloaded
--- @return nil
function HostSetupController:unload()
	Topics.multihostsetup.unload:send(self)
end

return HostSetupController
