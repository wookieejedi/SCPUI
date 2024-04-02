local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")
local dialogs = require("dialogs")

local HostOptionsController = class(AbstractBriefingController)

function HostOptionsController:init()
	self.missionList = {} -- list of mission files + ids only
	self.missions = {} -- list of actual missions
	
	self.playerList = {} -- list of players + ids only
	self.players = {} -- list of actual players
	
	self.team_elements = {}
end

function HostOptionsController:initialize(document)
	
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
	self.chat_el = self.document:GetElementById("chat_window")
	--self.status_text_el = self.document:GetElementById("status_text")
	
	self.time_limit_input_el = self.document:GetElementById("time_limit_input")
	self.respawn_limit_input_el = self.document:GetElementById("respawn_limit_input")
	self.kill_limit_input_el = self.document:GetElementById("kill_limit_input")
	self.observers_limit_input_el = self.document:GetElementById("observers_limit_input")
	
	self.netgame = ui.MultiGeneral.getNetGame()
	
	self:buildDropdowns()
	
	self:updateLists()
	
	if self.netgame.HostModifiesShips then
		self.hostModifies = true
	else
		self.hostModifies = false
	end
	self.document:GetElementById("host_modifies_btn"):SetPseudoClass("checked", self.hostModifies)
	
	if self.netgame.TimeLimit < 0 then
		self.time_limit_input_el:SetAttribute("value", 0)
	else
		self.time_limit_input_el:SetAttribute("value", self.netgame.TimeLimit)
	end
	self.kill_limit_input_el:SetAttribute("value", self.netgame.RespawnLimit)
	self.respawn_limit_input_el:SetAttribute("value", self.netgame.KillLimit)
	self.observers_limit_input_el:SetAttribute("value", self.netgame.ObserverLimit)
	
	--topics.multijoingame.initialize:send(self)

end

function HostOptionsController:buildDropdowns()
	local ai_orders_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("ai_orders_cont").first_child)
	
	ScpuiSystem:clearDropdown(ai_orders_el)
	
	ai_orders_el:Add("Highest Rank", "Highest Rank", 1)
	ai_orders_el:Add("Team/Wing-Leader", "Team/Wing-Leader", 2)
	ai_orders_el:Add("Any", "Any", 3)
	ai_orders_el:Add("Host", "Host", 4)
	
	if self.netgame.Orders == MULTI_OPTION_RANK then
		ai_orders_el.selection = 1
	elseif self.netgame.Orders == MULTI_OPTION_HOST then
		ai_orders_el.selection = 4
	elseif self.netgame.Orders == MULTI_OPTION_LEAD then
		ai_orders_el.selection = 2
	else
		ai_orders_el.selection = 1
	end
	
	local end_mission_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("end_mission_cont").first_child)
	
	ScpuiSystem:clearDropdown(end_mission_el)
	
	end_mission_el:Add("Highest Rank", "Highest Rank", 1)
	end_mission_el:Add("Team/Wing-Leader", "Team/Wing-Leader", 2)
	end_mission_el:Add("Any", "Any", 3)
	end_mission_el:Add("Host", "Host", 4)
	
	if self.netgame.EndMission == MULTI_OPTION_RANK then
		end_mission_el.selection = 1
	elseif self.netgame.EndMission == MULTI_OPTION_HOST then
		end_mission_el.selection = 4
	elseif self.netgame.EndMission == MULTI_OPTION_LEAD then
		end_mission_el.selection = 2
	else
		end_mission_el.selection = 1
	end
	
	local difficulty_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("difficulty_cont").first_child)
	
	ScpuiSystem:clearDropdown(difficulty_el)
	
	difficulty_el:Add("Very Easy", "Very Easy", 1)
	difficulty_el:Add("Easy", "Easy", 2)
	difficulty_el:Add("Normal", "Normal", 3)
	difficulty_el:Add("Hard", "Hard", 4)
	difficulty_el:Add("Very Hard", "Very Hard", 5)
	
	difficulty_el.selection = self.netgame.SkillLevel + 1
end

function HostOptionsController:exit()
	self.netgame:acceptOptions()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_MULTI_HOST_SETUP"])
end

function HostOptionsController:dialog_response(response)
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

function HostOptionsController:Show(text, title, input, buttons)
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

function HostOptionsController:commit_pressed()
	self:exit()
end

function HostOptionsController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function HostOptionsController:host_modifies_pressed()
	if self.netgame.HostModifiesShips then
		self.hostModifies = false
	else
		self.hostModifies = true
	end
	self.netgame.HostModifiesShips = self.hostModifies
	self.document:GetElementById("host_modifies_btn"):SetPseudoClass("checked", self.netgame.HostModifiesShips)
end

function HostOptionsController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit()
	end
end

function HostOptionsController:sendChat()
	if string.len(self.submittedValue) > 0 then
		--ui.MultiPXO.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function HostOptionsController:InputFocusLost()
	--do nothing
end

function HostOptionsController:TrimInput(val)
	local stringValue = val:gsub("^%s*(.-)%s*$", "%1")
	stringValue = stringValue:gsub("[^%d]", "")
	return stringValue
end

function HostOptionsController:time_limit_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function HostOptionsController:time_limit_input_change(event)
	local stringValue = self:TrimInput(event.parameters.value)
	self.time_limit_input_el:SetAttribute("value", stringValue)
	self.time_limit = stringValue
end

function HostOptionsController:respawn_limit_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function HostOptionsController:respawn_limit_input_change(event)
	local stringValue = self:TrimInput(event.parameters.value)
	self.respawn_limit_input_el:SetAttribute("value", stringValue)
	self.respawn_limit = stringValue
end

function HostOptionsController:kill_limit_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function HostOptionsController:kill_limit_input_change(event)
	local stringValue = self:TrimInput(event.parameters.value)
	self.kill_limit_input_el:SetAttribute("value", stringValue)
	self.kill_limit = stringValue
end

function HostOptionsController:observers_limit_keyup(element, event)
    if event.parameters.key_identifier ~= rocket.key_identifier.ESCAPE then
        return
    end
end

function HostOptionsController:observers_limit_input_change(event)
	local stringValue = self:TrimInput(event.parameters.value)
	self.observers_limit_input_el:SetAttribute("value", stringValue)
	self.observers_limit = stringValue
end

function HostOptionsController:ai_orders_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("ai_orders_cont").first_child)
	local val = select_el.options[select_el.selection - 1].value
	
	if val == "Highest Rank" then
		self.netgame.Orders = MULTI_OPTION_RANK
	elseif val == "Team/Wing-Leader" then
		self.netgame.Orders = MULTI_OPTION_LEAD
	elseif val == "Host" then
		self.netgame.Orders = MULTI_OPTION_HOST
	else
		self.netgame.Orders = MULTI_OPTION_ANY
	end
end

function HostOptionsController:end_mission_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("end_mission_cont").first_child)
	local val = select_el.options[select_el.selection - 1].value
	
	if val == "Highest Rank" then
		self.netgame.EndMission  = MULTI_OPTION_RANK
	elseif val == "Team/Wing-Leader" then
		self.netgame.EndMission  = MULTI_OPTION_LEAD
	elseif val == "Host" then
		self.netgame.EndMission  = MULTI_OPTION_HOST
	else
		self.netgame.EndMission  = MULTI_OPTION_ANY
	end
end

function HostOptionsController:difficulty_changed()
	local select_el = Element.As.ElementFormControlDataSelect(self.document:GetElementById("difficulty_cont").first_child)
	local val = select_el.options[select_el.selection - 1].value
	
	if val == "Very Easy" then
		self.netgame.SkillLevel  = 0
	elseif val == "Easy" then
		self.netgame.SkillLevel  = 1
	elseif val == "Hard" then
		self.netgame.SkillLevel  = 3
	elseif val == "Very Hard" then
		self.netgame.SkillLevel  = 4
	else
		self.netgame.SkillLevel = 2
	end
end

function HostOptionsController:updateLists()
	ui.MultiHostSetup.runNetwork()
	
	--self.document:GetElementById("status_text").inner_rml = ui.MultiGeneral.StatusText
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

return HostOptionsController
