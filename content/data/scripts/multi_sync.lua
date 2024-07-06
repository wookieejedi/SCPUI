local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")
local dialogs = require("dialogs")

local MultiSyncController = class(AbstractBriefingController)

function MultiSyncController:init()
	self.playerList = {} -- list of players + ids only
	self.players = {} -- list of actual players
	
	self.team_elements = {}
	self.state_elements = {}
	
	self.host = nil
	self.countdown = nil
end

function MultiSyncController:initialize(document)
	
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	--Hide these until we know if we're the host or not
	self.document:GetElementById("bottom_panel_a"):SetClass("hidden", true)
	self.document:GetElementById("bottom_panel_c"):SetClass("hidden", true)
	
	self.players_list_el = self.document:GetElementById("players_list_ul")
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
	self.common_text_el = self.document:GetElementById("common_text")
	--self.status_text_el = self.document:GetElementById("status_text")
	
	ui.MultiSync.initMultiSync()
	
	self.netgame = ui.MultiGeneral.getNetGame()
	
	self.selectedPlayer= nil
	
	self.submittedValue = ""
	
	self:updateLists()
	ui.MultiGeneral.setPlayerState()
	
	topics.multisync.initialize:send(self)

end

function MultiSyncController:exit(quit)
	if quit == true then
		ui.MultiSync.closeMultiSync(quit)
	end
end

function MultiSyncController:dialog_response(response)
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

function MultiSyncController:Show(text, title, input, buttons)
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

function MultiSyncController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function MultiSyncController:KickPlayer(player)
	player:kickPlayer()
end

function MultiSyncController:kick_pressed()
	if self.selectedPlayer then
		self:KickPlayer(self:GetPlayerByKey(self.selectedPlayer.id).Entry)
	end
end

function MultiSyncController:launch_pressed()
	ui.MultiSync:startCountdown()
end

function MultiSyncController:exit_pressed()
	self:exit(true)
end

function MultiSyncController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       --self:exit(true)
	end
end

function MultiSyncController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function MultiSyncController:InputFocusLost()
	--do nothing
end

function MultiSyncController:InputChange(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

function MultiSyncController:CreatePlayerEntry(entry)
	
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
	
	local state_el = self.document:CreateElement("div")
	state_el.id = entry.InternalID .. "_state"
	state_el:SetClass("player_state", true)
	state_el:SetClass("player_item", true)
	state_el.inner_rml = entry.State
	li_el:AppendChild(state_el)
	
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
	table.insert(self.state_elements, state_el)

	return li_el
end

function MultiSyncController:SelectPlayer(player)
	if self.selectedPlayer then
		self.selectedPlayer:SetPseudoClass("checked", false)
	end
	self.selectedPlayer = self.document:GetElementById(player.key)
	self.selectedPlayer:SetPseudoClass("checked", true)
end

function MultiSyncController:GetPlayerByKey(key)
	for i = 1, #self.players do
		if self.players[i].key == key then
			return self.players[i]
		end
	end
end

function MultiSyncController:addPlayer(player)
	self.players_list_el:AppendChild(self:CreatePlayerEntry(player))
	table.insert(self.playerList, player.InternalID)
end

function MultiSyncController:removePlayer(idx)
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

function MultiSyncController:updateTeam(player)
	player.Team = player.Entry.Team
	self.document:GetElementById(player.InternalID .. "_team").inner_rml = "Team" .. player.Team + 1
end

function MultiSyncController:updateState(player)
	player.State = player.Entry.State
	self.document:GetElementById(player.InternalID .. "_state").inner_rml = player.State
end

function MultiSyncController:remove_team_element(id)
	for i = 1, #self.team_elements do
		if self.team_elements[i].id == id then
			table.remove(self.team_elements, i)
			return
		end
	end
end

function MultiSyncController:remove_state_element(id)
	for i = 1, #self.state_elements do
		if self.state_elements[i].id == id then
			table.remove(self.state_elements, i)
			return
		end
	end
end

function MultiSyncController:getPlayerIndexByID(id)
	for i = 1, #self.players do
		if self.players[i].InternalID == id then
			return i
		end
	end
	return -1
end

function MultiSyncController:countdownBegins()
	if self.countdownStarted then
		return
	end
	
	local aniEl = self.document:CreateElement("ani")
    aniEl:SetAttribute("src", "countdown.png")
	self.document:GetElementById("countdown"):AppendChild(aniEl)
	ui.disableInput() --Probably need to still allow chat.. but :shrug:
	self.countdownStarted = true
end

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
	self.chat_el.inner_rml = txt
	self.chat_el.scroll_top = self.chat_el.scroll_height
	
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
				--if self.host is nil, then we need to check if we're the host
				if self.host == nil then
					if ui.MultiGeneral.NetPlayers[i]:isSelf() and ui.MultiGeneral.NetPlayers[i].Host then
						self.host = true
						self.document:GetElementById("bottom_panel_a"):SetClass("hidden", false)
						self.document:GetElementById("bottom_panel_c"):SetClass("hidden", false)
					end
				end
				
				--Now do the rest of the player stuff
				local int_id = ui.MultiGeneral.NetPlayers[i].Name .. "_" .. i
				if not utils.table.contains(self.playerList, int_id) then
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
		if self.host == nil then
			self.host = false
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
	
	--Update the player teams
	for i = 1, #self.players do
		if self.players[i].Team ~= self.players[i].Entry.Team then
			self:updateTeam(self.players[i])
		end
	end
	
	--Update the player states
	for i = 1, #self.players do
		if self.players[i].State ~= self.players[i].Entry.State then
			self:updateState(self.players[i])
		end
	end
	
	--Select the first player
	if self.selectedPlayer == nil and #self.players > 0 then
		self:SelectPlayer(self.players[1])
	end
	
	--get the current countdown, if any
	self.countdown = ui.MultiSync:getCountdownTime()
	
	--self.document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText
	self.common_text_el.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")
	
	if self.countdown and self.countdown > 0 then
		self:countdownBegins()
	end
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return MultiSyncController
