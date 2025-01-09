-----------------------------------
--Controller for the Multi Join Game UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Dialogs = require("lib_dialogs")
local Topics = require("lib_ui_topics")
local Utils = require("lib_utils")

local Class = require("lib_class")

local JoinGameController = Class()

JoinGameController.NETWORK_TYPE_PXO = 1
JoinGameController.NETWORK_TYPE_LOCAL = 2

--- Called by the class constructor
--- @return nil
function JoinGameController:init()
	self.Games_Elements = {} --- @type string[] list of games element ids
	self.Games_List = {} --- @type scpui_multi_active_game[] list of games
	self.GamesListEl = nil --- @type Element the games list element
	self.CommonTextEl = nil --- @type Element the common text element
	self.StatusTextEl = nil --- @type Element the status text element
	self.Network = self.NETWORK_TYPE_PXO --- @type number the network type
	self.Document = nil --- @type Document the RML document
end

--- Called by the RML document
--- @param document Document
function JoinGameController:initialize(document)

	self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.GamesListEl = self.Document:GetElementById("games_list_ul")
	self.CommonTextEl = self.Document:GetElementById("common_text")
	self.StatusTextEl = self.Document:GetElementById("status_text")

	ScpuiSystem:clearEntries(self.GamesListEl)

	if not ScpuiSystem.data.memory.MultiJoinReady then
		ui.MultiJoinGame.initMultiJoin()
	end

	ScpuiSystem.data.memory.MultiJoinReady = true

	self:updateLists()
	ui.MultiGeneral.setPlayerState()

	--If we're in local only mode
	local options = opt.Options
	for _, v in ipairs(options) do
		if v.Key == "Multi.TogglePXO" then
			if v.Value.Display == "Off" then
				self.Network = self.NETWORK_TYPE_LOCAL
			end
			break
		end
	end


	Topics.multijoingame.initialize:send(self)

end

--- Create a game entry element
--- @param entry scpui_multi_active_game
--- @return Element el the created element
function JoinGameController:createGameEntry(entry)

	local li_el = self.Document:CreateElement("li")

	local status_el = self.Document:CreateElement("div")
	status_el:SetClass("game_status", true)
	status_el:SetClass("game_item", true)
	status_el.inner_rml = entry.Status
	li_el:AppendChild(status_el)

	local type_el = self.Document:CreateElement("div")
	type_el:SetClass("game_type", true)
	type_el:SetClass("game_item", true)
	type_el.inner_rml = entry.Type
	li_el:AppendChild(type_el)

	local server_el = self.Document:CreateElement("div")
	server_el:SetClass("game_server", true)
	server_el:SetClass("game_item", true)
	server_el.inner_rml = entry.Server
	li_el:AppendChild(server_el)

	local players_el = self.Document:CreateElement("div")
	players_el:SetClass("game_players", true)
	players_el:SetClass("game_item", true)
	players_el.inner_rml = tostring(entry.Players)
	li_el:AppendChild(players_el)

	local ping_el = self.Document:CreateElement("div")
	ping_el:SetClass("game_ping", true)
	ping_el:SetClass("game_item", true)
	ping_el.inner_rml = entry.Ping .. "ms"
	li_el:AppendChild(ping_el)

	li_el.id = entry.Server .. entry.InternalId
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectGame(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:selectGame(entry)
		ui.MultiJoinGame.sendJoinRequest()
	end)
	entry.Key = li_el.id

	table.insert(self.Games_List, entry)

	return li_el
end

--- Select a game element
--- @param game scpui_multi_active_game
--- @return nil
function JoinGameController:selectGame(game)
	if self.selected_game then
		self.selected_game:SetPseudoClass("checked", false)
	end
	self.selected_game = self.Document:GetElementById(game.Key)
	self.selected_game:SetPseudoClass("checked", true)
	ui.MultiJoinGame.ActiveGames[game.Index]:setSelected()
end

--- Add a game to the list and UI
--- @param game scpui_multi_active_game
--- @return nil
function JoinGameController:addGame(game)
	self.GamesListEl:AppendChild(self:createGameEntry(game))
	table.insert(self.Games_Elements, game.InternalId)
end

--- Remove a game from the list and UI
--- @param idx number the index of the game to remove
--- @return nil
function JoinGameController:removeGame(idx)
	local game_idx = self:getGameIndexByID(self.Games_Elements[idx])
	if game_idx > 0 then
		local el = self.Document:GetElementById(self.Games_List[game_idx].Key)
		self.GamesListEl:RemoveChild(el)
		table.remove(self.Games_List, game_idx)
	end
	table.remove(self.Games_Elements, idx)
end

--- Get a game index by its internal ID
--- @param id string the internal ID of the game
--- @return number the index of the game
function JoinGameController:getGameIndexByID(id)
	for i = 1, #self.Games_List do
		if self.Games_List[i].InternalId == id then
			return i
		end
	end
	return -1
end

--- Exit the join game ui
--- @return nil
function JoinGameController:exit()
	ui.MultiJoinGame.closeMultiJoin()
	ScpuiSystem.data.memory.MultiJoinReady = false

	--Go back to mainhall if not in pxo!
	if self.Network == self.NETWORK_TYPE_LOCAL then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	else
		ba.postGameEvent(ba.GameEvents["GS_EVENT_PXO"])
	end
end

--- Called by the RML to join a game
--- @return nil
function JoinGameController:join_pressed()
	ui.MultiJoinGame.sendJoinRequest()
end

--- Called by the RML to show help boxes
--- @return nil
function JoinGameController:help_pressed()
	--show help overlay
end

--- Called by the RML to create a game
--- @return nil
function JoinGameController:create_pressed()
	ui.MultiJoinGame:createGame()
end

--- Called by the RML to join a game as observer
--- @return nil
function JoinGameController:observer_pressed()
	ui.MultiJoinGame.sendJoinRequest(true)
end

--- Called by the RML to cancel the join game ui. Will exit the game state
--- @return nil
function JoinGameController:cancel_pressed()
	self:exit()
end

--- Called by the RML to refresh the game list
--- @return nil
function JoinGameController:refresh_pressed()
	ui.MultiJoinGame:refresh()
end

--- Called by the RML to show the options menu
--- @return nil
function JoinGameController:options_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

--- Called by the RML to exit the join game ui
--- @return nil
function JoinGameController:exit_pressed()
	self:exit()
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function JoinGameController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit()
	end
end

--- Runs the network functions to update the games list and other elements. Runs every 0.01 seconds
--- @return nil
function JoinGameController:updateLists()
	ui.MultiJoinGame.runNetwork()

	if #ui.MultiJoinGame.ActiveGames == 0 then
		ScpuiSystem:clearEntries(self.GamesListEl)
		self.GamesListEl.inner_rml = "[No game servers found]"
		self.cleared = true
	else
		if self.cleared then
			ScpuiSystem:clearEntries(self.GamesListEl)
			self.cleared = nil
		end
		-- check for new games
		for i = 1, #ui.MultiJoinGame.ActiveGames do
			local int_id = ui.MultiJoinGame.ActiveGames[i].Server .. "_" .. i
			if not Utils.table.contains(self.Games_Elements, int_id) then
				--- @type scpui_multi_active_game
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
					InternalId = int_id,
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

		for i = 1, #self.Games_Elements do
			if not Utils.table.contains(games, self.Games_Elements[i]) then
				self:removeGame(i)
			end
		end
	end

	--maybe need to only update this when it's changed.. but for now this is fine
	self.CommonTextEl.inner_rml = string.gsub(ui.MultiGeneral.InfoText,"\n","<br></br>")
	self.StatusTextEl.inner_rml = ui.MultiGeneral.StatusText

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

--- Called when the screen is being unloaded
--- @return nil
function JoinGameController:unload()
	Topics.multijoingame.unload:send(self)
end

return JoinGameController
