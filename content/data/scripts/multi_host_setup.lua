local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")
local dialogs = require("dialogs")

local HostSetupController = class(AbstractBriefingController)

function HostSetupController:init()
	self.missionList = {} -- list of mission files + ids only
	self.missions = {} -- list of actual missions
	
	self.playerList = {} -- list of players + ids only
	self.players = {} -- list of actual players
	
	self.team_elements = {}
end

function HostSetupController:initialize(document)
	
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.missions_list_el = self.document:GetElementById("mission_list_ul")
	self.players_list_el = self.document:GetElementById("players_list_ul")
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
	self.common_text_el = self.document:GetElementById("common_text")
	--self.status_text_el = self.document:GetElementById("status_text")
	
	if not ScpuiSystem.MultiHostSetup then
		ui.MultiHostSetup.initMultiHostSetup()
		ScpuiSystem.MultiHostSetup = true
		ScpuiSystem.HostFilter = nil
		ScpuiSystem.HostList = "missions"
	end
	
	self.netgame = ui.MultiGeneral.getNetGame()
	
	self:buildFilters()
	
	if ScpuiSystem.HostList == "missions" then
		self.document:GetElementById("missions_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("campaigns_btn"):SetPseudoClass("checked", true)
	end
	
	self.selectedPlayer= nil
	self.selectedMission = nil
	
	self.submittedValue = ""
	
	self:updateLists()
	ui.MultiGeneral.setPlayerState()
	
	self.closed = self.netgame.Closed
	if self.netgame.Type == MULTI_TYPE_SQUADWAR then
		self.squadwar = true
	else
		self.squadwar = false
	end
	
	if self.closed then
		self.document:GetElementById("close_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("close_btn"):SetPseudoClass("checked", false)
	end
	
	if self.squadwar then
		self.document:GetElementById("squadwar_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("squadwar_btn"):SetPseudoClass("checked", false)
	end
	
	topics.multihostsetup.initialize:send(self)

end

function HostSetupController:buildFilters()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("dropdown_cont").first_child)
	
	ScpuiSystem:clearDropdown(select_el)
	
	select_el:Add("All", "All", 1)
	select_el:Add("Co-op", "Co-op", 2)
	select_el:Add("Team", "Team", 3)
	select_el:Add("Dogfight", "Dogfight", 4)
	
	select_el.selection = 1
end

function HostSetupController:exit(quit)
	ui.MultiHostSetup.closeMultiHostSetup(quit)
	ScpuiSystem.MultiHostSetup = nil
end

function HostSetupController:dialog_response(response)
	local path = self.promptControl
	self.promptControl = nil
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
	end
end

function HostSetupController:Show(text, title, input, buttons)
	--Create a simple dialog box with the text and title

	currentDialog = true
	
	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		dialog:input(input)
		for i = 1, #buttons do
			dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value, buttons[i].b_keypress)
		end
		dialog:escape("")
		dialog:show(self.document.context)
		:continueWith(function(response)
			self:dialog_response(response)
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.document.context)
end

function HostSetupController:squadwar_pressed()
	--Not actually sure what this button is for!
	if self.squadwar == false then
		self.netgame.Type = MULTI_TYPE_SQUADWAR
		self.document:GetElementById("squadwar_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("squadwar_btn"):SetPseudoClass("checked", false)
	end
end

function HostSetupController:help_pressed()
	--show help overlay
end

function HostSetupController:commit_pressed()
	ui.MultiHostSetup.closeMultiHostSetup(true)
	ScpuiSystem.MultiHostSetup = nil
end

function HostSetupController:host_options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_HOST_OPTIONS"])
end

function HostSetupController:missions_pressed()
	self.document:GetElementById("campaigns_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("missions_btn"):SetPseudoClass("checked", true)
	ScpuiSystem.HostList = "missions"
end

function HostSetupController:campaigns_pressed()
	self.document:GetElementById("missions_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("campaigns_btn"):SetPseudoClass("checked", true)
	ScpuiSystem.HostList = "campaigns"
end

function HostSetupController:team_1_pressed()
	if self.selectedPlayer then
		self.document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
		self.document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
		self:GetPlayerByKey(self.selectedPlayer.id).Entry.Team = 0
	end
end

function HostSetupController:team_2_pressed()
	if self.selectedPlayer then
		self.document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
		self.document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
		self:GetPlayerByKey(self.selectedPlayer.id).Entry.Team = 1
	end
end

function HostSetupController:add_heading_element(text)
	self.playerStats = self.playerStats .. "<span style=\"width: 49%; float: left; text-align: right;\">" .. text .. "</span><br></br>"
end

function HostSetupController:add_value_element(text, value)
	self.playerStats = self.playerStats .. "<br></br><span style=\"width: 50%; float: left; text-align: right;\">" .. text .. "</span>"
	self.playerStats = self.playerStats .. "<br></br><span style=\"width: 49%; float: right; padding-left: 1%;\">" .. value .. "</span>"
end

function HostSetupController:add_empty_line()
    self.playerStats = self.playerStats .. "<br></br>"
end

function HostSetupController:initialize_stats_text(stats)
    self.playerStats  = ""

    self:add_heading_element("All Time Stats")
    self:add_value_element("Primary weapon shots:", stats.PrimaryShotsFired)
    self:add_value_element("Primary weapon hits:", stats.PrimaryShotsHit)
    self:add_value_element("Primary friendly hits:", stats.PrimaryFriendlyHit)
    self:add_value_element("Primary hit %:",
                           utils.compute_percentage(stats.PrimaryShotsHit, stats.PrimaryShotsFired))
    self:add_value_element("Primary friendly hit %:",
                           utils.compute_percentage(stats.PrimaryFriendlyHit, stats.PrimaryShotsFired))
    self:add_empty_line()

    self:add_value_element("Secondary weapon shots:", stats.SecondaryShotsFired)
    self:add_value_element("Secondary weapon hits:", stats.SecondaryShotsHit)
    self:add_value_element("Secondary friendly hits:", stats.SecondaryFriendlyHit)
    self:add_value_element("Secondary hit %:",
                           utils.compute_percentage(stats.SecondaryShotsHit, stats.SecondaryShotsFired))
    self:add_value_element("Secondary friendly hit %:",
                           utils.compute_percentage(stats.SecondaryFriendlyHit, stats.SecondaryShotsFired))
    self:add_empty_line()

    self:add_value_element("Total kills:", stats.TotalKills)
    self:add_value_element("Assists:", stats.Assists)
    self:add_empty_line()

    self:add_value_element("Current Score:", stats.Score)
    self:add_empty_line()
    self:add_empty_line()

    self:add_heading_element("Kills by Ship Type")
    local score_from_kills = 0
    for i = 1, #tb.ShipClasses do
        local ship_cls = tb.ShipClasses[i]
        local kills    = stats:getShipclassKills(ship_cls)

        if kills > 0 then
            local name = topics.ships.name:send(ship_cls)
            score_from_kills = score_from_kills + kills * ship_cls.Score
            self:add_value_element(name .. ":", kills)
        end
    end
    self:add_value_element("Score from kills only:", score_from_kills)
	
	return self.playerStats
end

function HostSetupController:GetPlayerStats(player)

	local stats = player:getStats()
	
	self.promptControl = 3

	local text = self:initialize_stats_text(stats)
	local title = player.Name .. "'s stats"
	local buttons = {}
	buttons[1] = {
		b_type = dialogs.BUTTON_TYPE_POSITIVE,
		b_text = ba.XSTR("Okay", -1),
		b_value = "",
		b_keypress = string.sub(ba.XSTR("Okay", -1), 1, 1)
	}
	
	self:Show(text, title, false, buttons)
end

function HostSetupController:pilot_info_pressed()
	if self.selectedPlayer then
		self:GetPlayerStats(self:GetPlayerByKey(self.selectedPlayer.id).Entry)
	end
end

function HostSetupController:KickPlayer(player)
	player:kickPlayer()
end

function HostSetupController:kick_pressed()
	if self.selectedPlayer then
		self:KickPlayer(self:GetPlayerByKey(self.selectedPlayer.id).Entry)
	end
end

function HostSetupController:close_pressed()
	--TODO: If not host then hide this button
	if self.closed == true then
		self.netgame.Closed = false
	else
		self.netgame.Closed = true
	end
	self.closed = self.netgame.Closed
	self.document:GetElementById("close_btn"):SetPseudoClass("checked", self.netgame.Closed)
end

function HostSetupController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function HostSetupController:options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function HostSetupController:exit_pressed()
	self:exit(false)
end

function HostSetupController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit(false)
	end
end

function HostSetupController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function HostSetupController:InputFocusLost()
	--do nothing
end

function HostSetupController:InputChange(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

function HostSetupController:filter_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("dropdown_cont").first_child)
	local val = select_el.options[select_el.selection - 1].value
	
	if val == "Co-op" then
		ScpuiSystem.HostFilter = MULTI_TYPE_COOP
	elseif val == "Team" then
		ScpuiSystem.HostFilter = MULTI_TYPE_TEAM
	elseif val == "Dogfight" then
		ScpuiSystem.HostFilter = MULTI_TYPE_DOGFIGHT
	else
		ScpuiSystem.HostFilter = nil
	end
	
	self.missionList = {} -- list of mission files + ids only
	self.missions = {} -- list of actual missions
	ScpuiSystem:ClearEntries(self.missions_list_el)
	self.selectedMission = nil
end

function HostSetupController:CreateMissionEntry(entry)
	
	local li_el = self.document:CreateElement("li")
	
	local type_el = self.document:CreateElement("div")
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
	
	local builtin_el = self.document:CreateElement("div")
	builtin_el:SetClass("mission_builtin", true)
	builtin_el:SetClass("mission_item", true)
	if entry.Builtin then
		builtin_el.inner_rml = "*"
	else
		builtin_el.inner_rml = ""
	end
	li_el:AppendChild(builtin_el)
	
	local validity_el = self.document:CreateElement("div")
	validity_el:SetClass("mission_validity", true)
	validity_el:SetClass("mission_item", true)
	if entry.Builtin then
		validity_el.inner_rml = "X"
	else
		validity_el.inner_rml = ""
	end
	li_el:AppendChild(validity_el)
	
	local name_el = self.document:CreateElement("div")
	name_el:SetClass("mission_name", true)
	name_el:SetClass("mission_item", true)
	name_el.inner_rml = entry.Name
	li_el:AppendChild(name_el)
	
	local players_el = self.document:CreateElement("div")
	players_el:SetClass("mission_players", true)
	players_el:SetClass("mission_item", true)
	players_el.inner_rml = entry.Players
	li_el:AppendChild(players_el)
	
	local filename_el = self.document:CreateElement("div")
	filename_el:SetClass("mission_filename", true)
	filename_el:SetClass("mission_item", true)
	filename_el.inner_rml = entry.Filename
	li_el:AppendChild(filename_el)

	li_el.id = entry.InternalID
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectMission(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:SelectMission(entry)
	end)
	entry.key = li_el.id
	
	table.insert(self.missions, entry)

	return li_el
end

function HostSetupController:SelectMission(mission)
	if self.selectedMission then
		self.selectedMission:SetPseudoClass("checked", false)
	end
	self.selectedMission = self.document:GetElementById(mission.key)
	self.selectedMission:SetPseudoClass("checked", true)
	self.netgame:setMission(mission.Entry)
end

function HostSetupController:addMission(mission)
	self.missions_list_el:AppendChild(self:CreateMissionEntry(mission))
	table.insert(self.missionList, mission.InternalID)
	
	if mission.Filename == self.netgame.MissionFilename then
		self:SelectMission(mission)
	end
end

function HostSetupController:removeMission(idx)
	local mission_idx = self:getMissionIndexByID(self.missionList[idx])
	if mission_idx > 0 then
		if self.selectedMission and self.selectedMission.id == self.missions[mission_idx].key then
			self.selectedMission = nil
		end
		local el = self.document:GetElementById(self.missions[mission_idx].key)
		self.missions_list_el:RemoveChild(el)
		table.remove(self.missions, mission_idx)
	end
	table.remove(self.missionList, idx)
end

function HostSetupController:getMissionIndexByID(id)
	for i = 1, #self.missions do
		if self.missions[i].InternalID == id then
			return i
		end
	end
	return -1
end

function HostSetupController:CreatePlayerEntry(entry)
	
	local li_el = self.document:CreateElement("li")
	
	local name_el = self.document:CreateElement("div")
	name_el:SetClass("player_name", true)
	name_el:SetClass("player_item", true)
	name_el.inner_rml = entry.Name
	li_el:AppendChild(name_el)
	
	local team_el = self.document:CreateElement("div")
	team_el.id = entry.InternalID .. "_team"
	team_el:SetClass("player_team", true)
	team_el:SetClass("player_item", true)
	team_el.inner_rml = "Team" .. entry.Team + 1
	li_el:AppendChild(team_el)
	
	--These will eventually just change color or something I dunno
	local host = entry.Host
	local observer = entry.Observer
	local captain = entry.Captain

	li_el.id = entry.InternalID
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectPlayer(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:SelectPlayer(entry)
	end)
	entry.key = li_el.id
	
	table.insert(self.players, entry)
	table.insert(self.team_elements, team_el)

	return li_el
end

function HostSetupController:SelectPlayer(player)
	if self.selectedPlayer then
		self.selectedPlayer:SetPseudoClass("checked", false)
	end
	self.selectedPlayer = self.document:GetElementById(player.key)
	self.selectedPlayer:SetPseudoClass("checked", true)
	self:ActivateTeamButtons(player)
	--ui.MultiJoinGame.ActiveGames[player.Index]:setSelected()
end

function HostSetupController:GetPlayerByKey(key)
	for i = 1, #self.players do
		if self.players[i].key == key then
			return self.players[i]
		end
	end
end

function HostSetupController:ActivateTeamButtons(player)
	self.document:GetElementById("team_1_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("team_2_btn"):SetPseudoClass("checked", false)
	if player.Team == 0 then
		self.document:GetElementById("team_1_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("team_2_btn"):SetPseudoClass("checked", true)
	end
end

function HostSetupController:addPlayer(player)
	self.players_list_el:AppendChild(self:CreatePlayerEntry(player))
	table.insert(self.playerList, player.InternalID)
end

function HostSetupController:removePlayer(idx)
	local player_idx = self:getPlayerIndexByID(self.playerList[idx])
	if player_idx > 0 then
		local el = self.document:GetElementById(self.players[player_idx].key)
		--Also remove the team element to prevent an error later
		self:remove_team_element(self.playerList[idx] .. "_team")
		self.players_list_el:RemoveChild(el)
		table.remove(self.players, player_idx)
	end
	table.remove(self.playerList, idx)
end

function HostSetupController:updateTeam(player)
	player.Team = player.Entry.Team
	self.document:GetElementById(player.InternalID .. "_team").inner_rml = "Team" .. player.Team + 1
	self:ActivateTeamButtons(player)
end

function HostSetupController:remove_team_element(id)
	for i = 1, #self.team_elements do
		if self.team_elements[i].id == id then
			table.remove(self.team_elements, i)
			return
		end
	end
end

function HostSetupController:getPlayerIndexByID(id)
	for i = 1, #self.players do
		if self.players[i].InternalID == id then
			return i
		end
	end
	return -1
end

function HostSetupController:hideTeamButtons(toggle)
	self.document:GetElementById("team_1_cont"):SetClass("hidden", toggle)
	self.document:GetElementById("team_2_cont"):SetClass("hidden", toggle)
	
	for i = 1, #self.team_elements do
		self.team_elements[i]:SetClass("hidden", toggle)
	end
end

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
	self.chat_el.inner_rml = txt
	self.chat_el.scroll_top = self.chat_el.scroll_height
	
	local list = ui.MultiHostSetup.NetMissions
	
	if ScpuiSystem.HostList ~= "missions" then
		list = ui.MultiHostSetup.NetCampaigns
	end
	
	if #list == 0 then
		ScpuiSystem:ClearEntries(self.missions_list_el)
		self.missions_list_el.inner_rml = "Loading Mission List..."
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:ClearEntries(self.missions_list_el)
			self.missions_list_el.inner_rml = ""
			self.cleared = nil
		end
		-- check for new missions
		for i = 1, #list do
			local int_id = list[i].Filename .. "_" .. i
			local add_entry = true
			if ScpuiSystem.HostFilter then
				if list[i].Type == ScpuiSystem.HostFilter then
					add_entry = true
				else
					add_entry = false
				end
			end
			if add_entry and not utils.table.contains(self.missionList, int_id) then
				local entry = {
					Filename = list[i].Filename,
					Name = list[i].Name,
					Players = list[i].Players,
					Respawn = list[i].Respawn,
					Tracker = list[i].Tracker,
					Type = list[i].Type,
					Builtin = list[i].Builtin,
					InternalID = int_id,
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
		
		for i = 1, #self.missionList do
			--remove it if it no longer exists on the server
			if not utils.table.contains(missions, self.missionList[i]) then
				self:removeMission(i)
			end
		end
	end
	
	if #ui.MultiGeneral.NetPlayers == 0 then
		ScpuiSystem:ClearEntries(self.players_list_el)
		self.players_list_el.inner_rml = "Loading Players..."
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:ClearEntries(self.players_list_el)
			self.cleared = nil
		end
		-- check for new players
		for i = 1, #ui.MultiGeneral.NetPlayers do
			if ui.MultiGeneral.NetPlayers[i]:isValid() then
				local int_id = ui.MultiGeneral.NetPlayers[i].Name .. "_" .. i
				if not utils.table.contains(self.playerList, int_id) then
					local entry = {
						Name = ui.MultiGeneral.NetPlayers[i].Name,
						Team = ui.MultiGeneral.NetPlayers[i].Team,
						Host = ui.MultiGeneral.NetPlayers[i].Host,
						Observer = ui.MultiGeneral.NetPlayers[i].Observer,
						Captain = ui.MultiGeneral.NetPlayers[i].Captain,
						InternalID = int_id,
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
		
		for i = 1, #self.playerList do
			--remove it if it no longer exists on the server
			if not utils.table.contains(players, self.playerList[i]) then
				self:removePlayer(i)
			end
		end
	end
	
	if self.netgame and self.netgame.Type == MULTI_TYPE_TEAM then
		self:hideTeamButtons(false)
	else
		self:hideTeamButtons(true)
	end
	
	--Update the player teams
	for i = 1, #self.players do
		if self.players[i].Team ~= self.players[i].Entry.Team then
			self:updateTeam(self.players[i])
		end
	end
	
	--Select the first player
	if self.selectedPlayer == nil and #self.players > 0 then
		self:SelectPlayer(self.players[1])
	end
	
	--Select the first mission
	if self.netgame and self.selectedMission == nil and #self.missions > 0 then
		self:SelectMission(self.missions[1])
	end
	
	--self.document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText
	self.common_text_el.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return HostSetupController
