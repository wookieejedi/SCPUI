local dialogs = require("dialogs")
local class = require("class")

local TechMissionsController = class()

function TechMissionsController:init()
	self.help_shown = false
	self.show_all = false
end

function TechMissionsController:initialize(document)
    self.document = document
    self.elements = {}
    self.section = 1

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	ui.TechRoom.buildMissionList()
	
	self:GetCampaign()
	
	self.document:GetElementById("campaign_title").inner_rml = self.campaignName
	self.document:GetElementById("campaign_file").inner_rml = self.campaignFilename
	
	self.document:GetElementById("data_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("mission_btn"):SetPseudoClass("checked", true)
	self.document:GetElementById("cutscene_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("credits_btn"):SetPseudoClass("checked", false)
	
	self.SelectedEntry = nil
	
	self.SelectedSection = nil
	self:ChangeSection("single")
	
end

function TechMissionsController:ChangeTechState(section)

	if section == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
	end
	if section == 2 then
		--This is where we are already, so don't do anything
		--ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
	end
	if section == 3 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	end
	if section == 4 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
	end
	
end

function TechMissionsController:ChangeSection(section)

	if section == 1 then section = "single" end
	if section == 2 then section = "campaign" end

	if section ~= self.SelectedSection then
	
		local missionList = nil
		self.list = {}
	
		if section == "single" then
			self.document:GetElementById("campaign_name_wrapper"):SetClass("hidden", true)
			missionList = ui.TechRoom.SingleMissions
			local i = 0
			while (i ~= #missionList) do
				self.list[i+1] = {
					Name = missionList[i].Name,
					Filename = missionList[i].Filename,
					Description = missionList[i].Description,
					Author = missionList[i].Author,
					Visibility = 1
				}
				i = i + 1
			end
		elseif section == "campaign" then
			self.document:GetElementById("campaign_name_wrapper"):SetClass("hidden", false)
			missionList = ui.TechRoom.CampaignMissions
			local i = 0
			while (i ~= #missionList) do
				self.list[i+1] = {
					Name = missionList[i].Name,
					Filename = missionList[i].Filename,
					Description = missionList[i].Description,
					Author = missionList[i].Author,
					Visibility = missionList[i].Visibility
				}
				i = i + 1
			end
		end
		
		if self.SelectedEntry then
			self:ClearEntry()
		end
		
		--If we had an old section on, remove the active class
		if self.SelectedSection then
			local oldbullet = self.document:GetElementById(self.SelectedSection.."_btn")
			oldbullet:SetPseudoClass("checked", false)
		end
		
		self.SelectedSection = section
		
		--Only create entries if there are any to create
		if self.list[1] then
			self:CreateEntries(self.list)
		else
			local list_names_el = self.document:GetElementById("list_item_names_ul")
			local list_filenames_el = self.document:GetElementById("list_item_filenames_ul")
			self:ClearEntries(list_names_el)
			self:ClearEntries(list_filenames_el)
			self:ClearData()
		end

		local newbullet = self.document:GetElementById(self.SelectedSection.."_btn")
		newbullet:SetPseudoClass("checked", true)
		
	end
	
end

function TechMissionsController:CreateEntryItem(entry, index)

	local li_el = self.document:CreateElement("li")

	li_el.inner_rml = "<div class=\"missionlist_name\">" .. entry.Name .. "</div><div class=\"missionlist_author\">" .. entry.Author .. "</div><div class=\"missionlist_filename\">" .. entry.Filename .. "</div><div class=\"missionlist_description\">" .. entry.Description .. "</div>"
	li_el.id = entry.Filename

	li_el:SetClass("missionlist_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry.key)
	end)
	
	entry.key = li_el.id
	
	if entry.Visibility == 0 then
		li_el:SetClass("hidden", not self.show_all)
	end

	return li_el
end

function TechMissionsController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("list_item_names_ul")

	self:ClearEntries(list_names_el)

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function TechMissionsController:ClearEntry()

	self.document:GetElementById(self.SelectedEntry):SetPseudoClass("checked", false)
	self.SelectedEntry = nil

end

function TechMissionsController:ClearData()

	--We have nothing to clear here!
	
end

function TechMissionsController:ClearEntries(parent)

	while parent:HasChildNodes() do
		parent:RemoveChild(parent.first_child)
	end

end

function TechMissionsController:SelectEntry(key)

	if key ~= self.SelectedEntry then
		
		if self.SelectedEntry then
			local oldEntry = self.document:GetElementById(self.SelectedEntry)
			if oldEntry then oldEntry:SetPseudoClass("checked", false) end
		end
		
		local thisEntry = self.document:GetElementById(key)
		self.SelectedEntry = key
		thisEntry:SetPseudoClass("checked", true)
		
	end

end

function TechMissionsController:GetCampaign()

	ui.CampaignMenu.loadCampaignList();

    local names, fileNames, descriptions = ui.CampaignMenu.getCampaignList()

    local currentCampaignFile = ba.getCurrentPlayer():getCampaignFilename()
    local selectedCampaign = nil

    self.names = names
    self.descriptions = {}
    self.fileNames = {}
    for i, v in ipairs(names) do
        self.descriptions[v] = descriptions[i]
        self.fileNames[v] = fileNames[i]

        if fileNames[i] == currentCampaignFile then
            selectedCampaign = v
        end
    end
	
	self.campaignFilename = currentCampaignFile .. ".fc2"
	self.campaignName = selectedCampaign
	
end

function TechMissionsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    elseif event.parameters.key_identifier == rocket.key_identifier.S and event.parameters.ctrl_key == 1 and event.parameters.shift_key == 1 then
		self.show_all  = not self.show_all
		for i, v in pairs(self.list) do
			if v.Visibility == 0 then
				self.document:GetElementById(v.key):SetClass("hidden", not self.show_all)
			end
		end
	end
end

function TechMissionsController:commit_pressed(element)
	mn.startMission(self.SelectedEntry)
end

function TechMissionsController:options_button_clicked(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function TechMissionsController:help_clicked(element)
    self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

return TechMissionsController
