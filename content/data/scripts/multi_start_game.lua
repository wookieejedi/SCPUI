local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")
local dialogs = require("dialogs")

local JoinGameController = class(AbstractBriefingController)

function JoinGameController:init()

end

function JoinGameController:initialize(document)
	
	self.document = document
	
	self.missionTitle = ba.getCurrentPlayer():getName() .. "'s game"
	self.password = ""
	self.selected_rank = 1
	self.game_type = MULTI_GAME_TYPE_OPEN
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
	self.title_input_el = self.document:GetElementById("title_input")
	self.title_input_el:SetAttribute("value", self.missionTitle)
	
	self.password_input_el = self.document:GetElementById("password_input")
	
	ui.MultiStartGame.initMultiStart()
	
	self:buildRankList()
	
	self.document:GetElementById("open_btn"):SetPseudoClass("checked", true)
	
	self:updateLists()
	
	--topics.multijoingame.initialize:send(self)

end

function JoinGameController:buildRankList()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("dropdown_cont").first_child)
	
	ScpuiSystem:clearDropdown(select_el)
	
	for i = 1, #ui.Medals.Ranks_List do
		local rank = ui.Medals.Ranks_List[i].Name
		select_el:Add(rank, rank, i)
	end
	
	if #ui.Medals.Ranks_List > 0 then
		select_el.selection = 1
	end
end

function JoinGameController:uncheckButtons()
	self.document:GetElementById("open_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("password_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("rank_above_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("rank_below_btn"):SetPseudoClass("checked", false)
end

function JoinGameController:lockPassword(lock)
	self.document:GetElementById("password_lock"):SetClass("hidden", not lock)
end

function JoinGameController:lockRank(lock)
	self.document:GetElementById("rank_lock"):SetClass("hidden", not lock)
end

function JoinGameController:exit(continue)
	ui.MultiStartGame.closeMultiStart(false)
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_JOIN_GAME"])
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
	ui.MultiStartGame.setName(self.missionTitle)
	
	local arg = nil
	
	if self.game_type == MULTI_GAME_TYPE_PASSWORD then
		arg = self.password
	end
	
	if self.game_type == MULTI_GAME_TYPE_RANK_ABOVE or self.game_type == MULTI_GAME_TYPE_RANK_BELOW then
		arg = self.selected_rank
	end
	
	ui.MultiStartGame.setGameType(self.game_type, arg)
	ui.MultiStartGame.closeMultiStart()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_HOST_SETUP"])
end

function JoinGameController:help_pressed()
	--show help overlay
end

function JoinGameController:open_pressed()
	self:uncheckButtons()
	self.document:GetElementById("open_btn"):SetPseudoClass("checked", true)
	self:lockPassword(true)
	self:lockRank(true)
	
	self.game_type = MULTI_GAME_TYPE_OPEN
end

function JoinGameController:password_pressed()
	self:uncheckButtons()
	self.document:GetElementById("password_btn"):SetPseudoClass("checked", true)
	self:lockPassword(false)
	self:lockRank(true)
	
	self.game_type = MULTI_GAME_TYPE_PASSWORD
end

function JoinGameController:rank_above_pressed()
	self:uncheckButtons()
	self.document:GetElementById("rank_above_btn"):SetPseudoClass("checked", true)
	self:lockPassword(true)
	self:lockRank(false)
	
	self.game_type = MULTI_GAME_TYPE_RANK_ABOVE
end

function JoinGameController:rank_below_pressed()
	self:uncheckButtons()
	self.document:GetElementById("rank_below_btn"):SetPseudoClass("checked", true)
	self:lockPassword(true)
	self:lockRank(false)
	
	self.game_type = MULTI_GAME_TYPE_RANK_BELOW
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

function JoinGameController:get_rank_index(rank_name)
	for i = 1, #ui.Medals.Ranks_List do
		if ui.Medals.Ranks_List[i].Name == rank_name then
			return i
		end
	end
end

function JoinGameController:rank_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("dropdown_cont").first_child)
	
	local rank = select_el.options[select_el.selection - 1].value
	
	local player_rank = ba.getCurrentPlayer().Stats.Rank.Index
	
	local rank_idx = self:get_rank_index(rank)
	
	if self.game_type == MULTI_GAME_TYPE_RANK_ABOVE then
		if player_rank < rank_idx then
			select_el.selection = player_rank
			--Maybe show a popup warning that they can't choose a rank above their own!
			rank_idx = player_rank
		end
	end
	
	if self.game_type == MULTI_GAME_TYPE_RANK_BELOW then
		if player_rank > rank_idx then
			select_el.selection = player_rank
			--Maybe show a popup warning that they can't choose a rank below their own!
			rank_idx = player_rank
		end
	end
	
	if rank_idx then
		self.selected_rank = rank_idx
	end
end

function JoinGameController:title_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function JoinGameController:title_input_change(event)
    --local stringValue = event.parameters.value:gsub("^%s*(.-)%s*$", "%1")
	--self.title_input_el:SetAttribute("value", stringValue)
	self.missionTitle = event.parameters.value
end

function JoinGameController:password_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function JoinGameController:password_input_change(event)
    local stringValue = event.parameters.value:gsub("^%s*(.-)%s*$", "%1")
	self.password_input_el:SetAttribute("value", stringValue)
	self.password = stringValue
end

function JoinGameController:updateLists()
	ui.MultiStartGame.runNetwork()
	
	--self.document:GetElementById("status_text").inner_rml = ui.MultiJoinGame.StatusText
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return JoinGameController
