-----------------------------------
--Controller for the Multi Sync UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Dialogs = require("lib_dialogs")
local Utils = require("lib_utils")
local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local MultiSyncController = Class()

--- Called by the class constructor
--- @return nil
function MultiSyncController:init()
	self.Player_Ids = {} --- @type string[] list of player ids only
	self.Players_List = {} --- @type scpui_multi_setup_player[] list of actual players
	self.Team_Elements = {} --- @type Element[] list of team elements
	self.State_Elements = {} --- @type Element[] list of state elements
	self.SelfIsHost = nil --- @type boolean true if we are the host
	self.Countdown = nil --- @type number countdown time in seconds or -1 if countdown hasn't started
	self.CountdownStarted = nil --- @type boolean true if countdown has started
	self.PlayerListCleared = nil --- @type boolean true if the player list has been cleared
	self.Document = nil --- @type Document the RML document
	self.PlayersListEl = nil --- @type Element the players list element
	self.ChatEl = nil --- @type Element the chat window element
	self.ChatInputEl = nil --- @type Element the chat input element
	self.CommonTextEl = nil --- @type Element the common text element
	self.SelectedPlayer = nil --- @type Element the selected player element
	self.SubmittedChatValue = "" --- @type string the submitted chat value
	self.netgame = nil --- @type netgame the netgame object
end

--- Called by the RML document
--- @param document Document
function MultiSyncController:initialize(document)

	self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	--Hide these until we know if we're the host or not
	self.Document:GetElementById("bottom_panel_a"):SetClass("hidden", true)
	self.Document:GetElementById("bottom_panel_c"):SetClass("hidden", true)

	self.PlayersListEl = self.Document:GetElementById("players_list_ul")
	self.ChatEl = self.Document:GetElementById("chat_window")
	self.ChatInputEl = self.Document:GetElementById("chat_input")
	self.CommonTextEl = self.Document:GetElementById("common_text")
	--self.status_text_el = self.Document:GetElementById("status_text")

	ui.MultiSync.initMultiSync()

	self.netgame = ui.MultiGeneral.getNetGame()

	self:updateLists()
	ui.MultiGeneral.setPlayerState()

	Topics.multisync.initialize:send(self)

end

--- Exit the Multi Sync UI and quits the multi game
--- @return nil
function MultiSyncController:exit()
	ui.MultiSync.closeMultiSync(true)
end

--- Called by the RML when the chat submit button is pressed
--- @return nil
function MultiSyncController:submit_pressed()
	if self.SubmittedChatValue then
		self:sendChat()
	end
end

--- Kicks a player from the current game
--- @param player net_player the player to kick
--- @return nil
function MultiSyncController:kickPlayer(player)
	player:kickPlayer()
end

--- Called by the RML when the kick button is pressed
--- @return nil
function MultiSyncController:kick_pressed()
	if self.SelectedPlayer then
		self:kickPlayer(self:getPlayerByKey(self.SelectedPlayer.id).Entry)
	end
end

--- Called by the RML when the launch button is pressed
--- @return nil
function MultiSyncController:launch_pressed()
	ui.MultiSync:startCountdown()
end

--- Called by the RML when the exit button is pressed
--- @return nil
function MultiSyncController:exit_pressed()
	self:exit()
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function MultiSyncController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       --escape key is not allowed here
	end
end

--- Sends the chat to the server
--- @return nil
function MultiSyncController:sendChat()
	if string.len(self.SubmittedChatValue) > 0 then
		ui.MultiGeneral.sendChat(self.SubmittedChatValue)
		self.ChatInputEl:SetAttribute("value", "")
		self.SubmittedChatValue = ""
	end
end

--- Callled by the RML when the chat input focus is lost
--- @return nil
function MultiSyncController:input_focus_lost()
	--do nothing
end

--- Called by the RML when the chat input accepts a keypress
--- @param event Event The event that was triggered
--- @return nil
function MultiSyncController:input_change(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.ChatInputEl:GetAttribute("value")
		self.SubmittedChatValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

--- Creates a player entry in the UI
--- @param entry scpui_multi_setup_player the player to create an entry for
--- @return Element li_el the created element
function MultiSyncController:createPlayerEntry(entry)

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

	local state_el = self.Document:CreateElement("div")
	state_el.id = entry.InternalId .. "_state"
	state_el:SetClass("player_state", true)
	state_el:SetClass("player_item", true)
	state_el.inner_rml = entry.State
	li_el:AppendChild(state_el)

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
	table.insert(self.State_Elements, state_el)

	return li_el
end

--- Selects a player in the player list and unselects the previous player
--- @param player scpui_multi_setup_player the player to select
--- @return nil
function MultiSyncController:selectPlayer(player)
	if self.SelectedPlayer then
		self.SelectedPlayer:SetPseudoClass("checked", false)
	end
	self.SelectedPlayer = self.Document:GetElementById(player.Key)
	self.SelectedPlayer:SetPseudoClass("checked", true)
end

--- Gets a player by their key identifier
--- @param key string the key identifier of the player
--- @return scpui_multi_setup_player? player the player
function MultiSyncController:getPlayerByKey(key)
	for i = 1, #self.Players_List do
		if self.Players_List[i].Key == key then
			return self.Players_List[i]
		end
	end
end

--- Adds a player to the player list and UI
--- @param player scpui_multi_setup_player the player to add
--- @return nil
function MultiSyncController:addPlayer(player)
	self.PlayersListEl:AppendChild(self:createPlayerEntry(player))
	table.insert(self.Player_Ids, player.InternalId)
end

function MultiSyncController:removePlayer(idx)
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

--- Updates a player's team in the UI
--- @param player scpui_multi_setup_player the player to update
--- @return nil
function MultiSyncController:updateTeam(player)
	player.Team = player.Entry.Team
	self.Document:GetElementById(player.InternalId .. "_team").inner_rml = "Team" .. player.Team + 1
end

--- Updates a player's state in the UI
--- @param player scpui_multi_setup_player the player to update
--- @return nil
function MultiSyncController:updateState(player)
	player.State = player.Entry.State
	self.Document:GetElementById(player.InternalId .. "_state").inner_rml = player.State
end

--- Remove a team element from the list
--- @param id string the id of the team element
--- @return nil
function MultiSyncController:removeTeamElement(id)
	for i = 1, #self.Team_Elements do
		if self.Team_Elements[i].id == id then
			table.remove(self.Team_Elements, i)
			return
		end
	end
end

--- Remove a state element from the list
--- @param id string the id of the state element
--- @return nil
function MultiSyncController:removeStateElement(id)
	for i = 1, #self.State_Elements do
		if self.State_Elements[i].id == id then
			table.remove(self.State_Elements, i)
			return
		end
	end
end

--- Get the index of a player by their internal id
--- @param id string the internal id of the player
--- @return number index the index of the player
function MultiSyncController:getPlayerIndexByID(id)
	for i = 1, #self.Players_List do
		if self.Players_List[i].InternalId == id then
			return i
		end
	end
	return -1
end

--- Called when the countdown begins and updates the UI
--- @return nil
function MultiSyncController:countdownBegins()
	if self.CountdownStarted then
		return
	end

	local ani_el = self.Document:CreateElement("ani")
    ani_el:SetAttribute("src", "countdown.png")
	self.Document:GetElementById("countdown"):AppendChild(ani_el)
	ui.disableInput() --Probably need to still allow chat.. but :shrug:
	self.CountdownStarted = true
end

--- Runs the multiplayer functions to update the player elements, chat, teams, and countdown. Runs every 0.01 seconds
--- @return nil
function MultiSyncController:updateLists()
	ui.MultiSync.runNetwork()

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
				--if self.host is nil, then we need to check if we're the host
				if self.SelfIsHost == nil then
					if ui.MultiGeneral.NetPlayers[i]:isSelf() and ui.MultiGeneral.NetPlayers[i].Host then
						self.SelfIsHost = true
						self.Document:GetElementById("bottom_panel_a"):SetClass("hidden", false)
						self.Document:GetElementById("bottom_panel_c"):SetClass("hidden", false)
					end
				end

				--Now do the rest of the player stuff
				local int_id = ui.MultiGeneral.NetPlayers[i].Name .. "_" .. i
				if not Utils.table.contains(self.Player_Ids, int_id) then
					local entry = {
						Name = ui.MultiGeneral.NetPlayers[i].Name,
						Team = ui.MultiGeneral.NetPlayers[i].Team,
						Host = ui.MultiGeneral.NetPlayers[i].Host,
						Observer = ui.MultiGeneral.NetPlayers[i].Observer,
						Captain = ui.MultiGeneral.NetPlayers[i].Captain,
						State = ui.MultiGeneral.NetPlayers[i].State,
						InternalID = int_id,
						Index = i,
						Entry = ui.MultiGeneral.NetPlayers[i]
					}
					self:addPlayer(entry)
				end
			end
		end

		-- if self.host is still nil then we are not the host
		if self.SelfIsHost == nil then
			self.SelfIsHost = false
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

	--Update the player teams
	for i = 1, #self.Players_List do
		if self.Players_List[i].Team ~= self.Players_List[i].Entry.Team then
			self:updateTeam(self.Players_List[i])
		end
	end

	--Update the player states
	for i = 1, #self.Players_List do
		if self.Players_List[i].State ~= self.Players_List[i].Entry.State then
			self:updateState(self.Players_List[i])
		end
	end

	--Select the first player
	if self.SelectedPlayer == nil and #self.Players_List > 0 then
		self:selectPlayer(self.Players_List[1])
	end

	--get the current countdown, if any
	self.Countdown = ui.MultiSync:getCountdownTime()

	--self.Document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText
	self.CommonTextEl.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")

	if self.Countdown and self.Countdown > 0 then
		self:countdownBegins()
	end

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

--- Called when the screen is being unloaded
--- @return nil
function MultiSyncController:unload()
	Topics.multisync.unload:send(self)
end

return MultiSyncController
