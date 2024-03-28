local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")
local dialogs = require("dialogs")

local JoinGameController = class(AbstractBriefingController)

function JoinGameController:init()
	self.gamesList = {} -- list of games names + ids only
	self.games = {} -- list of actual games
end

function JoinGameController:initialize(document)
	
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
	self.games_list_el = self.document:GetElementById("games_list_ul")
	self.common_text_el = self.document:GetElementById("common_text")
	self.status_text_el = self.document:GetElementById("status_text")
	
	ScpuiSystem:ClearEntries(self.games_list_el)
	
	if not ScpuiSystem.MultiJoinReady then
		ui.MultiJoinGame.initMultiJoin()
	end
	
	ScpuiSystem.MultiJoinReady = true
	
	self:updateLists()
	
	--topics.multijoingame.initialize:send(self)

end

function JoinGameController:CreateGameEntry(entry)
	
	local li_el = self.document:CreateElement("li")
	
	local status_el = self.document:CreateElement("div")
	status_el:SetClass("game_status", true)
	status_el:SetClass("game_item", true)
	status_el.inner_rml = entry.Status
	li_el:AppendChild(status_el)
	
	local type_el = self.document:CreateElement("div")
	type_el:SetClass("game_type", true)
	type_el:SetClass("game_item", true)
	type_el.inner_rml = entry.Type
	li_el:AppendChild(type_el)
	
	local server_el = self.document:CreateElement("div")
	server_el:SetClass("game_server", true)
	server_el:SetClass("game_item", true)
	server_el.inner_rml = entry.Server
	li_el:AppendChild(server_el)
	
	local players_el = self.document:CreateElement("div")
	players_el:SetClass("game_players", true)
	players_el:SetClass("game_item", true)
	players_el.inner_rml = entry.Players
	li_el:AppendChild(players_el)
	
	local ping_el = self.document:CreateElement("div")
	ping_el:SetClass("game_ping", true)
	ping_el:SetClass("game_item", true)
	ping_el.inner_rml = entry.Ping .. "ms"
	li_el:AppendChild(ping_el)

	li_el.id = entry.Server .. entry.InternalID
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectGame(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:SelectGame(entry)
		ui.MultiJoinGame:sendJoinRequest()
	end)
	entry.key = li_el.id
	
	table.insert(self.games, entry)

	return li_el
end

function JoinGameController:SelectGame(game)
	if self.selected_game then
		self.selected_game:SetPseudoClass("checked", false)
	end
	self.selected_game = self.document:GetElementById(game.key)
	self.selected_game:SetPseudoClass("checked", true)
	ui.MultiJoinGame.ActiveGames[game.Index]:setSelected()
end

function JoinGameController:addGame(game)
	self.games_list_el:AppendChild(self:CreateGameEntry(game))
	table.insert(self.gamesList, game.InternalID)
end

function JoinGameController:removeGame(idx)
	local game_idx = self:getGameIndexByID(self.gamesList[idx])
	if game_idx > 0 then
		local el = self.document:GetElementById(self.games[game_idx].key)
		self.games_list_el:RemoveChild(el)
		table.remove(self.games, game_idx)
	end
	table.remove(self.gamesList, idx)
end

function JoinGameController:getGameIndexByID(id)
	for i = 1, #self.games do
		if self.games[i].InternalID == id then
			return i
		end
	end
	return -1
end

function JoinGameController:exit()
	ui.MultiJoinGame.closeMultiJoin()
	ScpuiSystem.MultiJoinReady = false
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PXO"])
	--Go back to mainhall if not in pxo options!
end

function JoinGameController:dialog_response(response)
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

function JoinGameController:Show(text, title, input, buttons)
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

function JoinGameController:join_pressed()
	ui.MultiJoinGame:sendJoinRequest()
end

function JoinGameController:help_pressed()
	--show help overlay
end

function JoinGameController:create_pressed()
	ui.MultiJoinGame:createGame()
end

function JoinGameController:observer_pressed()
	ui.MultiJoinGame:sendJoinRequest(true)
end

function JoinGameController:cancel_pressed()
	self:exit()
end

function JoinGameController:refresh_pressed()
	ui.MultiJoinGame:refresh()
end

function JoinGameController:options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function JoinGameController:exit_pressed()
	self:exit()
end

function JoinGameController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit()
	end
end

function JoinGameController:InputFocusLost()
	--do nothing
end

function JoinGameController:updateLists()
	ui.MultiJoinGame.runNetwork()

	if #ui.MultiJoinGame.ActiveGames == 0 then
		ScpuiSystem:ClearEntries(self.games_list_el)
		self.games_list_el.inner_rml = "[No game servers found]"
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:ClearEntries(self.games_list_el)
			self.cleared = nil
		end
		-- check for new games
		for i = 1, #ui.MultiJoinGame.ActiveGames do
			local int_id = ui.MultiJoinGame.ActiveGames[i].Server .. "_" .. i
			if not utils.table.contains(self.gamesList, int_id) then
				local entry = {
					Status = ui.MultiJoinGame.ActiveGames[i].Status,
					Type = ui.MultiJoinGame.ActiveGames[i].Type,
					Speed = ui.MultiJoinGame.ActiveGames[i].Speed,
					Standalone = ui.MultiJoinGame.ActiveGames[i].Standalone,
					Campaign = ui.MultiJoinGame.ActiveGames[i].Campaign,
					Server = ui.MultiJoinGame.ActiveGames[i].Server,
					Mission = ui.MultiJoinGame.ActiveGames[i].Mission,
					Ping = ui.MultiJoinGame.ActiveGames[i].Ping,
					Players = ui.MultiJoinGame.ActiveGames[i].Players,
					InternalID = int_id,
					Index = i
				}
				self:addGame(entry)
			end
		end
		
		-- now check for games that expired
		local games = {}
		
		-- create a simple table to use for comparing
		for i = 1, #ui.MultiJoinGame.ActiveGames do
			table.insert(games, ui.MultiJoinGame.ActiveGames[i].Server .. "_" .. i)
		end
		
		for i = 1, #self.gamesList do
			if not utils.table.contains(games, self.gamesList[i]) then
				self:removeGame(i)
			end
		end
	end
	
	--maybe need to only update this when it's changed.. but for now this is fine
	self.common_text_el.inner_rml = ui.MultiJoinGame.InfoText
	self.status_text_el.inner_rml = ui.MultiJoinGame.StatusText
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return JoinGameController
