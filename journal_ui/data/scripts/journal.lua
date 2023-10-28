local utils = require("utils")
local tblUtil = utils.table
local dialogs = require("dialogs")
local journal_topics = require("journal_topics")
local class = require("class")

local JournalController = class()

function JournalController:init()
end

function JournalController:initialize(document)

    self.document = document
	
	self.new = {"NEW", -1}

	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	self.document:GetElementById("journaltext"):SetClass(("p2-" .. ScpuiSystem:getFontSize()), true)

    self:registerEventHandlers()
	
	local player = ba.getCurrentPlayer()
	local campaignfilename = player:getCampaignFilename()
	
	self.Data = JournalUI:ParseTable(campaignfilename .. "-journal.tbl")
	
	if not self.Data then return end
	
	self.Data.VisibleList = {}
	self.SaveData = JournalUI:LoadDataFromFile()

	self.SelectedEntry = nil
	
	for i=1, #self.Data.Sections do
		if self.Data.Sections[i] then
			self.document:GetElementById("label_"..i).inner_rml = "<p>" .. self.Data.Sections[i].Display .. "</p>"
		end
	end
	
	journal_topics.journal.initialize:send(self)
	
	self.SelectedSection = nil
	self:ChangeSection(1)
	
end

function JournalController:ChangeSection(section)

	if self.Data and (section ~= self.SelectedSection) and self.Data.Sections[section] then

		if self.SelectedEntry then
			self:ClearEntry()
		end

		--If we had an old section on, remove the active class
		if self.SelectedSection then
			local oldbullet = self.document:GetElementById("btn_"..self.SelectedSection)
			oldbullet:SetPseudoClass("checked", false)
		end

		self.SelectedSection = section
		self:CreateEntries(self.SelectedSection)
		local newbullet = self.document:GetElementById("btn_"..self.SelectedSection)
		newbullet:SetPseudoClass("checked", true)

	end
	
end

function JournalController:CreateEntryItem(entry, unread)

    local li_el = self.document:CreateElement("li")

	if unread then
		li_el.inner_rml = "<span id=newstatus>" .. ba.XSTR(self.new[1], self.new[2]) .. "</span>" .. entry.Display
	else
		li_el.inner_rml = entry.Display
	end
    li_el:SetClass("journallist_element", true)
    li_el:AddEventListener("click", function(_, _, _)
        self:SelectEntry(entry.Key)
    end)
	
	self.Data.VisibleList[entry.Key] = li_el

    return li_el
	
end

function JournalController:CreateEntries(section)

	local list_el = self.document:GetElementById("list_items_ul")

	self:ClearEntries(list_el)

	for i, v in ipairs(self.Data.Entries[section]) do
		local savedData = self.SaveData[section][i]
		if savedData.Visible then
			-- Add all the elements
			ba.print("Adding entry " .. i .. ": " .. v.Name .. "\n" )
			list_el:AppendChild(self:CreateEntryItem(v,savedData.Unread))
		end
	end
end

function JournalController:ClearEntry()

	self.Data.VisibleList[self.SelectedEntry]:SetPseudoClass("checked", false)
	self.SelectedEntry = nil

	self.document:GetElementById("journaltext").inner_rml = "<p> </p>"

end

function JournalController:journal_text_to_rml(text)
    local lines = utils.split(text, "\n\n")

    local paragraphs = tblUtil.map(lines, function(line)
        return "<p>" .. utils.rml_escape(line) .. "</p>"
    end)

    return table.concat(paragraphs, "<br></br>")
end

function JournalController:SelectEntry(key)

	if self.Data then
		if key ~= self.SelectedEntry then
		
			if self.SelectedEntry then
				local oldEntry = self.Data.VisibleList[self.SelectedEntry]
				if oldEntry then oldEntry:SetPseudoClass("checked", false) end
			end
			
			local thisEntry = self.Data.VisibleList[key]
			self.SelectedEntry = key
			thisEntry:SetPseudoClass("checked", true)
			
			local index = self:GetIndexFromKey(key, self.SelectedSection)

			if index then

				local entryData = self.Data.Entries[self.SelectedSection][index]
				local filename = entryData.File
				local text = self:GetTextFromFile(filename)
				local image = entryData.Image
				local caption = entryData.Caption
					
				if text then
					self.document:GetElementById("journaltext").inner_rml = "<p>" ..  self:journal_text_to_rml(text) .."</p>"
					
					if image and caption then
						self.document:GetElementById("journaltext").inner_rml = "<div id=journalpic><img src=\"" .. image .."\"></img><div class=\"s1-" .. ScpuiSystem:getFontSize() .. "\" id=piccaption><p>" .. caption .. "</p></div></div>" .. self.document:GetElementById("journaltext").inner_rml
					elseif image then
						self.document:GetElementById("journaltext").inner_rml = "<div id=journalpic><img src=\"" .. image .."\"></img></div>" .. self.document:GetElementById("journaltext").inner_rml
					end
					
				else
					ba.error("Can't find journal text file ".. filename .. "\n")
				end
				
				local savedData = self.SaveData[self.SelectedSection][index]
				
				if savedData.Unread then
					thisEntry.inner_rml = self.Data.Entries[self.SelectedSection][index].Name
					savedData.Unread = false
					JournalUI:SaveDataToFile(self.SaveData)
				end

			end
		end	
	end

end

function JournalController:GetIndexFromKey(key, section)

	for i,v in ipairs(self.Data.Entries[section]) do
		if v.Key == key then return i end
	end

	return nil

end

function JournalController:GetTextFromFile(file)

	local thisFile = cf.openFile(file,"rb","data/fiction")
	local text = thisFile:read("*a")
	thisFile:close()

	return text

end

function JournalController:ClearEntries(parent)

	while parent:HasChildNodes() do
		parent:RemoveChild(parent.first_child)
	end

	self.Data.VisibleList = {}

end

function JournalController:Exit(element)

    ui.playElementSound(element, "click", "success")
	ScpuiSystem:ReturnToState(ScpuiSystem.lastState)
	self.document:Close()

end

function JournalController:registerEventHandlers()

end

function JournalController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
		self.document:Close()
		ScpuiSystem:ReturnToState(ScpuiSystem.lastState)
    end
end

return JournalController
