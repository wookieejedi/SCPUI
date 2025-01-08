local dialogs = require("lib_dialogs")
local class = require("lib_class")
local async_util = require("lib_async")
local utils = require("lib_utils")
local async_util = require("lib_async")
local topics = require("lib_ui_topics")

local TechMissionsController = class()

function TechMissionsController:init()
	self.help_shown = false
	self.show_all = false
	self.Counter = 0
	self.help_shown = false
end

---@param document Document
function TechMissionsController:initialize(document)
    self.Document = document
    self.elements = {}
    self.section = 1
	
	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	self.Document:GetElementById("tech_btn_1"):SetPseudoClass("checked", false)
	self.Document:GetElementById("tech_btn_2"):SetPseudoClass("checked", true)
	self.Document:GetElementById("tech_btn_3"):SetPseudoClass("checked", false)
	self.Document:GetElementById("tech_btn_4"):SetPseudoClass("checked", false)
	
	topics.techroom.initialize:send(self)
	
	topics.simulator.initialize:send(self)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self:Show("Building missions list...", "Mission Simulator")
	
	async.run(function()
		async.await(async_util.wait_for(0.001))
	
		ui.TechRoom.buildMissionList()
		
		self:GetCampaign()
		
		self.Document:GetElementById("campaign_title").inner_rml = self.campaignName
		self.Document:GetElementById("campaign_file").inner_rml = self.campaignFilename
		
		self.SelectedEntry = nil
		
		--Check for last loaded section
		local newSection = nil
		if ScpuiSystem.data.ScpuiOptionValues.Sim_Room_Choice ~= nil then
			newSection = ScpuiSystem.data.ScpuiOptionValues.Sim_Room_Choice
		else
			newSection = 2
		end
		
		self.SelectedSection = nil
		self:ChangeSection(newSection)
		
		ScpuiSystem:closeDialog()
	
	end, async.OnFrameExecutor)
	
end

function TechMissionsController:Show(text, title)
	--Create a simple dialog box with the text and title

	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		dialog:show(self.Document.context)
		:continueWith(function()end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.Document.context)
end

function TechMissionsController:ChangeTechState(state)

	if state == 1 then
		topics.techroom.btn1Action:send()
	end
	if state == 2 then
		--This is where we are already, so don't do anything
		--topics.techroom.btn2Action:send()
	end
	if state == 3 then
		topics.techroom.btn3Action:send()
	end
	if state == 4 then
		topics.techroom.btn4Action:send()
	end
	
end

function TechMissionsController:ReloadList()

	local list_items_el = self.Document:GetElementById("list_item_names_ul")
	ScpuiSystem:clearEntries(list_items_el)
	self:ClearData()
	self.SelectedEntry = nil
	self.visibleList = {}
	self.Counter = 0
	self:CreateEntries(self.currentList)
	if #self.visibleList > 0 then
		self:SelectEntry(self.visibleList[1])
	end

end

function TechMissionsController:ChangeSection(section)

	self.sectionIndex = section

	if section == 1 then 
		section = "single"
	elseif section == 2 then
		section = "campaign"
	else
		section = topics.simulator.sectionname:send(section)
		
		if section == nil then
			section = "campaign"
			self.sectionIndex = 2
		end
	end
	
	--save the choice to the player file
	ScpuiSystem.data.ScpuiOptionValues.Sim_Room_Choice = self.sectionIndex
	ScpuiSystem:saveOptionsToFile(ScpuiSystem.data.ScpuiOptionValues)
	
	self.show_all = false
	self.Counter = 0

	if section ~= self.SelectedSection then
	
		local missionList = nil
		self.currentList = {}
	
		if section == "single" then
			self.Document:GetElementById("campaign_name_wrapper"):SetClass("hidden", true)
			missionList = ui.TechRoom.SingleMissions
			local i = 0
			local j = 1
			while (i ~= #missionList) do
				local file = missionList[i].Filename
				if topics.simulator.listSingle:send(file) == true then
					self.currentList[j] = {
						Name = missionList[i].Name,
						Filename = missionList[i].Filename,
						Description = missionList[i].Description:gsub("\n", ""),
						Author = missionList[i].Author,
						isVisible = true
					}
					j = j + 1
				end
				i = i + 1
			end
		elseif section == "campaign" then
			self.Document:GetElementById("campaign_name_wrapper"):SetClass("hidden", false)
			missionList = ui.TechRoom.CampaignMissions
			local i = 0
			local j = 1
			while (i ~= #missionList) do
				self.currentList[j] = {
					Name = missionList[i].Name,
					Filename = missionList[i].Filename,
					Description = missionList[i].Description:gsub("\n", ""),
					Author = missionList[i].Author,
					isVisible = missionList[i].isVisible
				}
				j = j + 1
				i = i + 1
			end
		else
			topics.simulator.newsection:send({self, section})
		end
		
		if self.SelectedEntry then
			self:ClearEntry()
		end
		
		--If we had an old section on, remove the active class
		if self.SelectedSection then
			local oldbullet = self.Document:GetElementById(self.SelectedSection.."_btn")
			oldbullet:SetPseudoClass("checked", false)
		end
		
		self.SelectedSection = section
		
		--Only create entries if there are any to create
		if self.currentList[1] then
			self.visibleList = {}
			self:CreateEntries(self.currentList)
			--Only select an entry if there is one available to select
			if #self.visibleList > 0 then
				self:SelectEntry(self.visibleList[1])
			end
		else
			local list_names_el = self.Document:GetElementById("list_item_names_ul")
			ScpuiSystem:clearEntries(list_names_el)
			self:ClearData()
		end

		local newbullet = self.Document:GetElementById(self.SelectedSection.."_btn")
		newbullet:SetPseudoClass("checked", true)
		
	end
	
end

function TechMissionsController:ScrollEntry(element)
	if self.scrollingEl == element then
		if self.scrollingEl.scroll_left < math.floor(self.scrollingEl.scroll_width -  self.scrollingEl.client_width) then
			if self.scrollTimer == nil then
				self.scrollTimer = 15
			elseif self.scrollTimer > 0 then
				self.scrollTimer = self.scrollTimer - 1
			else
				self.scrollingEl.scroll_left = self.scrollingEl.scroll_left + 0.5
				self.scrollTimer = -1
			end
		else
			if self.scrollTimer ~= nil then
				if self.scrollTimer == -1 then
					self.scrollTimer = 50
				elseif self.scrollTimer > 0 then
					self.scrollTimer = self.scrollTimer - 1
				else
					self.scrollingEl.scroll_left = 0
					self.scrollTimer = nil
				end
			end
		end
		
		async.run(function()
			async.await(async_util.wait_for(0.05))
			self:ScrollEntry(element)
		end, async.OnFrameExecutor)
	end
end

function TechMissionsController:StartScrollEntry(element)
	if element ~= nil and element.inner_rml ~= self.scrollingEl then
		if self.scrollingEl ~= nil then
			self.scrollingEl.scroll_left = 0
		end
		self.scrollTimer = nil
		self.scrollingEl = element
		self:ScrollEntry(element)
	end
end

function TechMissionsController:ResetEntry(element)
	if element ~= nil then
		self.scrollTimer = nil
		self.scrollingEl = nil
		element.scroll_left = 0
	end
end

function TechMissionsController:CreateEntryItem(entry, index)

	self.Counter = self.Counter + 1

	local li_el = self.Document:CreateElement("li")
	
	local name_el = self.Document:CreateElement("div")
	name_el:SetClass("missionlist_name", true)
	name_el.inner_rml = entry.Name
	
	local author_el = self.Document:CreateElement("div")
	author_el:SetClass("missionlist_author", true)
	author_el.inner_rml = entry.Author
	
	local file_el = self.Document:CreateElement("div")
	file_el:SetClass("missionlist_filename", true)
	file_el.inner_rml = entry.Filename
	
	local desc_el = self.Document:CreateElement("div")
	desc_el:SetClass("missionlist_description", true)
	desc_el.inner_rml = entry.Description
	
	li_el:AppendChild(name_el)
	li_el:AppendChild(author_el)
	li_el:AppendChild(file_el)
	li_el:AppendChild(desc_el)
	
	li_el.id = entry.Filename

	li_el:SetClass("missionlist_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	li_el:AddEventListener("mouseover", function(_, _, _)
		self:StartScrollEntry(li_el.first_child.next_sibling.next_sibling.next_sibling)
	end)
	li_el:AddEventListener("mouseout", function(_, _, _)
		self:ResetEntry(li_el.first_child.next_sibling.next_sibling.next_sibling)
	end)
	self.visibleList[self.Counter] = entry
	entry.key = li_el.id
	
	self.visibleList[self.Counter].Index = self.Counter
	
	topics.simulator.createitem:send(li_el)

	return li_el
end

function TechMissionsController:CreateEntries(list)

	local list_names_el = self.Document:GetElementById("list_item_names_ul")

	ScpuiSystem:clearEntries(list_names_el)

	for i, v in pairs(list) do
		if self.show_all and topics.simulator.allowall:send(self) then
			list_names_el:AppendChild(self:CreateEntryItem(v, i))
		elseif v.isVisible == true then
			list_names_el:AppendChild(self:CreateEntryItem(v, i))
		end
	end
end

function TechMissionsController:ClearEntry()

	self.Document:GetElementById(self.SelectedEntry):SetPseudoClass("checked", false)
	self.SelectedEntry = nil

end

function TechMissionsController:ClearData()

	--We have nothing to clear here!
	
end

function TechMissionsController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
	
		self.SelectedIndex = entry.Index
		
		if self.SelectedEntry then
			local oldEntry = self.Document:GetElementById(self.SelectedEntry)
			if oldEntry then oldEntry:SetPseudoClass("checked", false) end
		end
		
		local thisEntry = self.Document:GetElementById(entry.key)
		self.SelectedEntry = entry.key
		thisEntry:SetPseudoClass("checked", true)
		
	end

end

function TechMissionsController:GetCampaign()

	ui.CampaignMenu.loadCampaignList()

    local names, fileNames, descriptions = ui.CampaignMenu.getCampaignList()

    local currentCampaignFile = ba.getCurrentPlayer():getCampaignFilename()
    local selectedCampaign = ""

    self.names = names
    self.descriptions = {}
    self.fileNames = {}
    for i, v in ipairs(names) do
        self.descriptions[v] = descriptions[i]
        self.fileNames[v] = fileNames[i]

        if string.lower(fileNames[i]) == string.lower(currentCampaignFile) then
            selectedCampaign = v
        end
    end
	
	--It's possible that the current campaign is invalid for the mod, so let's check
	if selectedCampaign == "" and not cf.fileExists(currentCampaignFile .. ".fc2") then
		self.campaignFilename = ""
	else
		self.campaignFilename = currentCampaignFile .. ".fc2"
	end
	
	self.campaignName = selectedCampaign
	
end

function TechMissionsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    elseif event.parameters.key_identifier == rocket.key_identifier.S and event.parameters.ctrl_key == 1 and event.parameters.shift_key == 1 then
		self.show_all = not self.show_all
		self:ReloadList()
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
		self:ChangeTechState(1)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
		self:ChangeTechState(3)
	elseif event.parameters.key_identifier == rocket.key_identifier.TAB then
		local newSection = topics.simulator.tabkey:send(self.sectionIndex)
		self:ChangeSection(newSection)
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.shift_key == 1 then
		self:ScrollList(self.Document:GetElementById("mission_list"), 0)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.shift_key == 1 then
		self:ScrollList(self.Document:GetElementById("mission_list"), 1)
	elseif event.parameters.key_identifier == rocket.key_identifier.UP then
		self:select_prev()
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN then
		self:select_next()
	elseif event.parameters.key_identifier == rocket.key_identifier.LEFT then
		--self:select_prev()
	elseif event.parameters.key_identifier == rocket.key_identifier.RIGHT then
		--self:select_next()
	elseif event.parameters.key_identifier == rocket.key_identifier.RETURN then
		self:commit_pressed(element)
	elseif event.parameters.key_identifier == rocket.key_identifier.F1 then
		self:help_clicked(element)
	elseif event.parameters.key_identifier == rocket.key_identifier.F2 then
		self:options_button_clicked(element)
	end
end

function TechMissionsController:ScrollList(element, direction)
	if direction == 0 then
		element.scroll_top = element.scroll_top - 15
	else
		element.scroll_top = element.scroll_top + 15
	end
end

function TechMissionsController:select_next()
    local num = #self.visibleList
	
	if self.SelectedIndex == num then
		ui.playElementSound(nil, "click", "error")
	else
		self:SelectEntry(self.visibleList[self.SelectedIndex + 1])
	end
end

function TechMissionsController:select_prev()	
	if self.SelectedIndex == 1 then
		ui.playElementSound(nil, "click", "error")
	else
		self:SelectEntry(self.visibleList[self.SelectedIndex - 1])
	end
end

function TechMissionsController:commit_pressed(element)
	if self.SelectedEntry then
		mn.startMission(self.SelectedEntry)
	end
end

function TechMissionsController:options_button_clicked(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function TechMissionsController:help_clicked(element)
    self.help_shown  = not self.help_shown

    local help_texts = self.Document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

function TechMissionsController:unload()
	topics.simulator.unload:send(self)
end

return TechMissionsController
