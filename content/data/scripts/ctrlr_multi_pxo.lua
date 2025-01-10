-----------------------------------
--Controller for the Multi PXO UI
-----------------------------------

local AsyncUtil = require("lib_async")
local Dialogs = require("lib_dialogs")
local Topics = require("lib_ui_topics")
local Utils = require("lib_utils")

local Class = require("lib_class")

local PXOController = Class()

PXOController.PROMPT_MOTD = 1 --- @type number the enumeration for the message of the day dialog box
PXOController.PROMPT_JOIN_PRIVATE = 2 --- @type number the enumeration for the join private channel dialog box
PXOController.PROMPT_PLAYER_STATS = 3 --- @type number the enumeration for the player stats dialog box
PXOController.PROMPT_FIND_PLAYER = 4 --- @type number the enumeration for the find player dialog box
PXOController.PROMPT_FIND_PLAYER_CHANNEL = 5 --- @type number the enumeration for the find player response dialog box


--- Called by the class constructor
--- @return nil
function PXOController:init()
	self.Players_List = {} --- @type  scpui_pxo_chat_player[] actual player entry
	self.Player_Names = {} --- @type string[] list of player names only
	self.Channels_List = {} --- @type scpui_pxo_channel[] actual channel entry
	self.Channel_Names = {} --- @type string[] list of channel names only
	self.SubmittedChatValue = "" --- @type string the player's text input
	self.PromptControl = nil --- @type number the current dialog prompt. Should be one of the PROMPT_ enumerations
	self.BannerFilename = "" --- @type string the current banner filename
	self.BannerWebUrl = "" --- @type string the current banner URL
	self.BannerImgBlob = "" --- @type string the current banner image blob
	self.BannerWidth = 0 --- @type number the current banner width
	self.BannerHeight = 0 --- @type number the current banner height
	self.PlayerStats = "" --- @type string the current player stats
	self.SelectedPlayer = nil --- @type scpui_pxo_chat_player the currently selected player
	self.SelectedChannel = nil --- @type scpui_pxo_channel the currently selected channel
	self.CurrentChannel = nil --- @type scpui_pxo_channel the currently active channel
	self.FoundChannel = nil --- @type scpui_pxo_channel the channel name found by the player search
	self.Motd = "" --- @type string the current message of the day
	self.ChatInputEl = nil --- @type Element the chat input element
	self.PlayersEl = nil --- @type Element the players list element
	self.ChannelsEl = nil --- @type Element the channels list element
	self.ChatEl = nil --- @type Element the chat window element
	self.BannerEl = nil --- @type Element the banner element
	self.Document = nil --- @type Document the RML document
end

--- Called by the RML document
--- @param document Document
function PXOController:initialize(document)

	self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.PlayersEl = self.Document:GetElementById("players_list_ul")
	self.ChannelsEl = self.Document:GetElementById("channels_list_ul")
	self.ChatEl = self.Document:GetElementById("chat_window")
	self.BannerEl = self.Document:GetElementById("banner_div")

	self.ChatInputEl = self.Document:GetElementById("chat_input")

	if not ScpuiSystem.data.memory.MultiReady then
		ui.MultiPXO.initPXO()
	end

	ScpuiSystem.data.memory.MultiReady = true

	self:updateLists()
	ui.MultiGeneral.setPlayerState()

	Topics.multipxo.initialize:send(self)

end

--- Set the selected channel as checked on the UI and unselect the previous one
--- @param channel scpui_pxo_channel the channel to select
--- @return nil
function PXOController:selectChannel(channel)
	if self.SelectedChannel ~= nil then
		self.Document:GetElementById(self.SelectedChannel.Key):SetPseudoClass("checked", false)
	end
	self.SelectedChannel = channel
	self.Document:GetElementById(channel.Key):SetPseudoClass("checked", true)
end

--- Join a chat channel
--- @param entry scpui_pxo_channel the channel to join
--- @return nil
function PXOController:joinChannel(entry)
	for i = 1, #ui.MultiPXO.Channels do
		if ui.MultiPXO.Channels[i].Name == entry.Name then
			if not ui.MultiPXO.Channels[i]:isCurrent() then
				ui.MultiPXO.Channels[i]:joinChannel()
			end
			return
		end
	end
end

--- Called by the RML when the join button is pressed. Joins the selected channel, if any
--- @return nil
function PXOController:join_public_pressed()
	if self.SelectedChannel then
		self:joinChannel(self.SelectedChannel)
	end
end

--- Called by the RML when the join private channel button is pressed. Creates a dialog box to enter the channel name
--- @return nil
function PXOController:join_private_pressed()
	self.PromptControl = self.PROMPT_JOIN_PRIVATE

	local text = "Enter the name of the private channel to join"
	local title = "Join Private Channel"
	--- @type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	self:showDialog(text, title, true, buttons)
end

--- Create a channel entry in the UI list
--- @param entry scpui_pxo_channel the channel to create an entry for
--- @return Element li_el the created element
function PXOController:createChannelEntry(entry)

	local li_el = self.Document:CreateElement("li")

	local name_el = self.Document:CreateElement("div")
	name_el:SetClass("channel_name", true)
	name_el.inner_rml = entry.Name

	local players_el = self.Document:CreateElement("div")
	players_el:SetClass("channel_players", true)
	players_el.inner_rml = tostring(entry.NumPlayers)

	local games_el = self.Document:CreateElement("div")
	games_el:SetClass("channel_games", true)
	games_el.inner_rml = tostring(entry.NumGames)

	li_el:AppendChild(name_el)
	li_el:AppendChild(players_el)
	li_el:AppendChild(games_el)

	li_el.id = entry.Name
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectChannel(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:joinChannel(entry)
	end)

	if entry.IsCurrent == true then
		li_el:SetPseudoClass("active", true)
		self.CurrentChannel = entry
	end
	entry.Key = li_el.id

	table.insert(self.Channels_List, entry)

	return li_el
end

--- Adds a channel to the names table and the UI list
--- @param channel scpui_pxo_channel the channel to add
--- @return nil
function PXOController:addChannel(channel)
	self.ChannelsEl:AppendChild(self:createChannelEntry(channel))
	table.insert(self.Channel_Names, channel.Name)
end

--- Removes a channel from the names table and the UI list by index
--- @param idx number the index of the channel to remove
--- @return nil
function PXOController:removeChannel(idx)
	local chnl_idx = self:getChannelIndexByName(self.Channel_Names[idx])
	if chnl_idx > 0 then
		local el = self.Document:GetElementById(self.Channels_List[chnl_idx].Key)
		self.ChannelsEl:RemoveChild(el)
		table.remove(self.Channels_List, chnl_idx)
	end
	table.remove(self.Channel_Names, idx)
end

--- Updates a channel in the UI list with the latest data
--- @param channel pxo_channel the channel to update
--- @return nil
function PXOController:updateChannel(channel)
	local idx = self:getChannelIndexByName(channel.Name)
	if idx > 0 then
		local el = self.Document:GetElementById(self.Channels_List[idx].Key)
		local players_el = el.first_child.next_sibling
		local games_el = el.first_child.next_sibling.next_sibling

		if channel:isCurrent() == true then
			if self.CurrentChannel ~= nil then
				self.Document:GetElementById(self.CurrentChannel.Key):SetPseudoClass("active", false)
			end
			el:SetPseudoClass("active", true)
			self.CurrentChannel = self.Channels_List[idx]
		else
			el:SetPseudoClass("active", false)
		end

		if players_el.inner_rml ~= channel.NumPlayers then
			players_el.inner_rml = tostring(channel.NumPlayers)
		end

		if games_el.inner_rml ~= tostring(channel.NumGames) then
			games_el.inner_rml = tostring(channel.NumGames)
		end
	end
end

--- Get the index of a channel in the table by name
--- @param name string the name of the channel to find
--- @return number index the index of the channel in the table
function PXOController:getChannelIndexByName(name)
	for i = 1, #self.Channels_List do
		if self.Channels_List[i].Name == name then
			return i
		end
	end
	return -1
end

--- Called by the RML when the web rank button is pressed
--- @return nil
function PXOController:web_rank_pressed()
	ba.warning("Need to setup getting the PXO urls from FSO through the API! Tell Mjn!")
end

--- Called by the RML when the pilot info button is pressed
--- @return nil
function PXOController:pilot_info_pressed()
	if self.SelectedPlayer then
		self:getPlayerStats(self.SelectedPlayer.Name)
	end
end

--- Called by the RML when the find pilot button is pressed. Creates a dialog box to enter the player name
--- @return nil
function PXOController:find_pilot_pressed()
	self.PromptControl = self.PROMPT_FIND_PLAYER

	local text = "Enter the name of the player to search for."
	local title = "Search for player"
	--- @type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	self:showDialog(text, title, true, buttons)
end

--- Selects a player in the UI list and unselects the previous one
--- @param player scpui_pxo_chat_player the player to select
--- @return nil
function PXOController:selectPlayer(player)
	if self.SelectedPlayer ~= nil then
		self.Document:GetElementById(self.SelectedPlayer.Key):SetPseudoClass("checked", false)
	end
	self.SelectedPlayer = player
	self.Document:GetElementById(player.Key):SetPseudoClass("checked", true)
end

--- Get the channel of a player and if found create a dialog box for the player to choose what to do next
--- @param player_name string the name of the player to search for
--- @return nil
function PXOController:getPlayerChannel(player_name)
	local response, channel = ui.MultiPXO.getPlayerChannel(player_name)

	self.PromptControl = self.PROMPT_FIND_PLAYER_CHANNEL

	local text = response
	local title = "Search for player"
	--- @type dialog_button[]
	local buttons = {}

	--If we have a channel then offer the option to join
	if channel ~= "" then
		--Create a dummy channel object
		self.FoundChannel = {
			Name = channel,
			NumPlayers = 0,
			NumGames = 0,
			IsCurrent = true
		}
		text = text .. "<br></br>Join channel?"
		buttons[1] = {
			Type = Dialogs.BUTTON_TYPE_POSITIVE,
			Text = ba.XSTR("Yes", 888296),
			Value = true,
			Keypress = string.sub(ba.XSTR("Yes", 888296), 1, 1)
		}
		buttons[2] = {
			Type = Dialogs.BUTTON_TYPE_NEGATIVE,
			Text = ba.XSTR("No", 888298),
			Value = false,
			Keypress = string.sub(ba.XSTR("No", 888298), 1, 1)
		}
	else
		buttons[1] = {
			Type = Dialogs.BUTTON_TYPE_POSITIVE,
			Text = ba.XSTR("Okay", 888290),
			Value = false,
			Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
		}
	end

	self:showDialog(text, title, false, buttons)
end

--- Get the player stats and create a dialog box to display them
--- @param player_name string the name of the player to get stats for
--- @return nil
function PXOController:getPlayerStats(player_name)
	local stats = ui.MultiPXO.getPlayerStats(player_name)

	self.PromptControl = self.PROMPT_PLAYER_STATS

	local text = self:initializeStatsText(stats)
	local title = player_name .. "'s stats"
	--- @type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	self:showDialog(text, title, false, buttons)
end

--- Create a player entry in the UI list
--- @param entry scpui_pxo_chat_player the player to create an entry for
--- @return Element li_el the created element
function PXOController:createPlayerEntry(entry)

	local li_el = self.Document:CreateElement("li")

	li_el.inner_rml = "<span>" .. entry.Name .. "</span>"
	li_el.id = entry.Name
	li_el:SetClass("list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectPlayer(entry)
	end)
	li_el:AddEventListener("dblclick", function(_, _, _)
		self:getPlayerStats(entry.Name)
	end)
	entry.Key = li_el.id

	table.insert(self.Players_List, entry)

	return li_el
end

--- Adds a player to the names table and the UI list
--- @param player scpui_pxo_chat_player the player to add
--- @return nil
function PXOController:addPlayer(player)
	self.PlayersEl:AppendChild(self:createPlayerEntry(player))
	table.insert(self.Player_Names, player.Name)
end

--- Removes a player from the names table and the UI list by index
--- @param idx number the index of the player to remove
--- @return nil
function PXOController:removePlayer(idx)
	local plr_idx = self:getPlayerIndexByName(self.Player_Names[idx])
	if plr_idx > 0 then
		local el = self.Document:GetElementById(self.Players_List[plr_idx].Key)
		self.PlayersEl:RemoveChild(el)
		table.remove(self.Players_List, plr_idx)
	end
	table.remove(self.Player_Names, idx)
end

--- Get the index of a player in the table by name
--- @param name string the name of the player to find
--- @return number index the index of the player in the table
function PXOController:getPlayerIndexByName(name)
	for i = 1, #self.Players_List do
		if self.Players_List[i].Name == name then
			return i
		end
	end
	return -1
end

--- Sends the chat message to the PXO server
--- @return nil
function PXOController:sendChat()
	if string.len(self.SubmittedChatValue) > 0 then
		ui.MultiPXO.sendChat(self.SubmittedChatValue)
		self.ChatInputEl:SetAttribute("value", "")
		self.SubmittedChatValue = ""
	end
end

--- Converts the banner image to a blob for display
function PXOController:convertBanner()
	local imag_h = gr.loadTexture(self.BannerFilename)
	self.BannerWidth = imag_h:getWidth()
	self.BannerHeight = imag_h:getHeight()
	local tex_h = gr.createTexture(self.BannerWidth, self.BannerHeight)
	gr.setTarget(tex_h)
	gr.clearScreen(0,0,0,0)
	gr.drawImage(imag_h, 0, 0, self.BannerWidth, self.BannerHeight, 0, 1, 1, 0, 1)
	self.BannerImgBlob = gr.screenToBlob()

	--clean up
	gr.setTarget()
	tex_h:destroyRenderTarget()
	imag_h:unload()
	tex_h:unload()
end

--- When the banner is clicked, open the URL in the player's browser
--- @return nil
function PXOController:bannerClicked()
	ui.launchURL(self.BannerWebUrl)
end

--- Exit the PXO screen and shutdown multiplayer pxo
--- @return nil
function PXOController:exit()
	ui.MultiPXO.closePXO()
	ScpuiSystem.data.memory.MultiReady = false
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

--- Handle the dialog response
--- @param response any the response from the dialog
--- @return nil
function PXOController:dialogResponse(response)
	local path = self.PromptControl
	self.PromptControl = nil
	if path == self.PROMPT_MOTD then --MOTD
		--Do nothing!
	elseif path == self.PROMPT_JOIN_PRIVATE then --Join Private Channel
		if response and response ~= "" then
			ui.MultiPXO.joinPrivateChannel(response)
		end
	elseif path == self.PROMPT_PLAYER_STATS then --Show Player Stats
		--Do nothing!
	elseif path == self.PROMPT_FIND_PLAYER then --Find player
		if response and response ~= "" then
			self:getPlayerChannel(response)
		end
	elseif path == self.PROMPT_FIND_PLAYER_CHANNEL then --Find player response
		if response == true then
			self:joinChannel(self.FoundChannel)
		end
		self.FoundChannel = nil
	end
end

--- Show a dialog box
--- @param text string the text to display
--- @param title string the title of the dialog
--- @param input boolean whether to show an input box
--- @param buttons dialog_button[] the buttons to display
--- @return nil
function PXOController:showDialog(text, title, input, buttons)
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

--- Called by the RML when the MOTD button is pressed. Displays the MOTD in a dialog box
--- @return nil
function PXOController:motd_pressed()

	self.PromptControl = self.PROMPT_MOTD

	local text = self.Motd
	local title = "Message of the Day"
	--- @type dialog_button[]
	local buttons = {}
	buttons[1] = {
		Type = Dialogs.BUTTON_TYPE_POSITIVE,
		Text = ba.XSTR("Okay", 888290),
		Value = "",
		Keypress = string.sub(ba.XSTR("Okay", 888290), 1, 1)
	}

	self:showDialog(text, title, false, buttons)

end

--- Add a heading element to the player stats
--- @param text string the text to add
--- @return nil
function PXOController:addHeadingElement(text)
	self.PlayerStats = self.PlayerStats .. "<span style=\"width: 49%; float: left; text-align: right;\">" .. text .. "</span><br></br>"
end

--- Add a value element to the player stats
--- @param text string the value name
--- @param value string the value to add
--- @return nil
function PXOController:addValueElement(text, value)
	self.PlayerStats = self.PlayerStats .. "<br></br><span style=\"width: 50%; float: left; text-align: right;\">" .. text .. "</span>"
	self.PlayerStats = self.PlayerStats .. "<br></br><span style=\"width: 49%; float: right; padding-left: 1%;\">" .. value .. "</span>"
end

--- Add an empty line to the player stats
--- @return nil
function PXOController:addEmptyLine()
    self.PlayerStats = self.PlayerStats .. "<br></br>"
end

--- Initialize the player stats text
--- @param stats scoring_stats the stats to display
function PXOController:initializeStatsText(stats)
    self.PlayerStats  = ""

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

	return self.PlayerStats
end

--- Called by the RML when the accept button is pressed. Closes the PXO screen and joins the game
--- @return nil
function PXOController:accept_pressed()
	ui.MultiPXO.closePXO()
	ScpuiSystem.data.memory.MultiReady = false
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_JOIN_GAME"])
end

--- Called by the RML when the help button is pressed. Goes to the PXO Help game state
--- @return nil
function PXOController:help_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PXO_HELP"])
end

--- Called by the RML when the exit button is pressed
--- @return nil
function PXOController:exit_pressed()
	self:exit()
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function PXOController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit()
	end
end

--- Called by the RML to submit the chat to the server
--- @return nil
function PXOController:submit_pressed()
	if self.SubmittedChatValue then
		self:sendChat()
	end
end

--- Called by the RML when the chat input has lost focus
--- @return nil
function PXOController:input_focus_lost()
	--do nothing
end

--- Called by the RML when the chat input has accepted a keypress
--- @param event Event the event that was triggered
--- @return nil
function PXOController:input_change(event)

	if event.parameters.linebreak ~= 1 then
		local val = self.ChatInputEl:GetAttribute("value")
		self.SubmittedChatValue = val
	else
		local submit_id = self.Document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end

end

--- Run the network functions to update the players and channels lists. Runs every 0.01 seconds
--- @return nil
function PXOController:updateLists()
	ui.MultiPXO.runNetwork()
	local chat = ui.MultiPXO.getChat()

	local players = ui.MultiPXO.getPlayers()

	-- check for new players
	for i = 1, #players do
		if not Utils.table.contains(self.Player_Names, players[i]) then
			--- @type scpui_pxo_chat_player
			local entry = {
				Name = players[i]
			}
			self:addPlayer(entry)
		end
	end

	-- now check for players that left
	for i = 1, #self.Player_Names do
		if not Utils.table.contains(players, self.Player_Names[i]) then
			self:removePlayer(i)
		end
	end

	-- check for new channels
	for i = 1, #ui.MultiPXO.Channels do
		if not Utils.table.contains(self.Channel_Names, ui.MultiPXO.Channels[i].Name) then
			--- @type scpui_pxo_channel
			local entry = {
				Name = ui.MultiPXO.Channels[i].Name,
				NumPlayers = ui.MultiPXO.Channels[i].NumPlayers,
				NumGames = ui.MultiPXO.Channels[i].NumGames,
				IsCurrent = ui.MultiPXO.Channels[i]:isCurrent()
			}
			self:addChannel(entry)
		else
			self:updateChannel(ui.MultiPXO.Channels[i])
		end
	end

	-- now check for channels that were removed
	local channels = {}

	-- create a simple table to use for comparing
	for i = 1, #ui.MultiPXO.Channels do
		table.insert(channels, ui.MultiPXO.Channels[i].Name)
	end

	for i = 1, #self.Channel_Names do
		if not Utils.table.contains(channels, self.Channel_Names[i]) then
			self:removeChannel(i)
		end
	end

	local txt = ""
	for i = 1, #chat do
		local line = chat[i].Callsign .. ": " .. chat[i].Message
		txt = txt .. line .. "<br></br>"
	end
	self.ChatEl.inner_rml = txt
	self.ChatEl.scroll_top = self.ChatEl.scroll_height

	self.Document:GetElementById("status_text").inner_rml = ui.MultiPXO.StatusText
	local motd = ui.MultiPXO.MotdText
	--Replace new lines with break tags
	self.Motd = motd:gsub("\n","<br></br>")

	if self.BannerFilename ~= ui.MultiPXO.bannerFilename then
		self.BannerFilename = ui.MultiPXO.bannerFilename
		self.BannerWebUrl = ui.MultiPXO.bannerURL

		if string.len(self.BannerFilename) > 0 then
			self:convertBanner()

			self.BannerEl.style.width = self.BannerWidth .. "px"
			self.BannerEl.style.height = self.BannerHeight .. "px"

			ScpuiSystem:clearEntries(self.BannerEl)

			local img_el = self.Document:CreateElement("img")
			img_el:SetAttribute("src", self.BannerImgBlob)
			img_el:AddEventListener("click", function(_, _, _)
				self:bannerClicked()
			end)
			self.BannerEl:AppendChild(img_el)
		end
	end

	async.run(function()
        async.await(AsyncUtil.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)

end

--- Called when the screen is being unloaded
--- @return nil
function PXOController:unload()
	Topics.multipxo.unload:send(self)
end

return PXOController
