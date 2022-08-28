local dialogs = require("dialogs")
local class = require("class")

local TechCutscenesController = class()

function TechCutscenesController:init()
	self.show_all = false
end

function TechCutscenesController:initialize(document)
    self.document = document
    self.elements = {}

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		local fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	--ba.warning(ui.TechRoom.Cutscenes[1].Filename)
	
	self.document:GetElementById("data_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("mission_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("cutscene_btn"):SetPseudoClass("checked", true)
	self.document:GetElementById("credits_btn"):SetPseudoClass("checked", false)
	
	self.SelectedEntry = nil
	self.list = {}
	
	local cutsceneList = ui.TechRoom.Cutscenes
	local i = 0
	while (i ~= #cutsceneList) do
		self.list[i+1] = {
			Name = cutsceneList[i].Name,
			Filename = cutsceneList[i].Filename,
			Description = cutsceneList[i].Description,
			Visibility = cutsceneList[i].Visibility,
			Index = i + 1
		}
		i = i + 1
	end
	
	--Only create entries if there are any to create
	if self.list[1] then
		self:CreateEntries(self.list)
	end
	
	if self.list[1].Name then
		self:SelectEntry(self.list[1])
	end
	
end

function TechCutscenesController:CreateEntryItem(entry, index)

	local li_el = self.document:CreateElement("li")

	li_el.inner_rml = "<div class=\"cutscenelist_name\">" .. entry.Name .. "</div>"
	li_el.id = entry.Filename

	li_el:SetClass("cutscenelist_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	
	entry.key = li_el.id
	
	if entry.Visibility == 0 then
		li_el:SetClass("hidden", not self.show_all)
	end

	return li_el
end

function TechCutscenesController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("cutscene_list_ul")

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function TechCutscenesController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
		
		if self.SelectedEntry then
			local oldEntry = self.document:GetElementById(self.SelectedEntry)
			if oldEntry then oldEntry:SetPseudoClass("checked", false) end
		end
		
		local thisEntry = self.document:GetElementById(entry.key)
		self.SelectedEntry = entry.key
		self.SelectedIndex = entry.Index
		thisEntry:SetPseudoClass("checked", true)
		
		self.document:GetElementById("cutscene_desc").inner_rml = entry.Description
		
	end

end

function TechCutscenesController:ChangeTechState(section)

	if section == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
	end
	if section == 2 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
	end
	if section == 3 then
		--This is where we are already, so don't do anything
		--ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
	end
	if section == 4 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
	end
	
end

function TechCutscenesController:global_keydown(element, event)
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
		if self.list[1].Name then
			self:SelectEntry(self.list[1])
		end
	end
end

function TechCutscenesController:prev_pressed(element)
	if self.SelectedIndex == 1 then
		ui.playElementSound(element, "click", "error")
	else
		newEntry = self.list[self.SelectedIndex - 1]
		if newEntry.Visibility == 1 or self.show_all == true then
			self:SelectEntry(newEntry)
		else
			ui.playElementSound(element, "click", "error")
		end
	end
end

function TechCutscenesController:next_pressed(element)
	local num = #ui.TechRoom.Cutscenes
	
	if self.SelectedIndex == num then
		ui.playElementSound(element, "click", "error")
	else
		newEntry = self.list[self.SelectedIndex + 1]
		if newEntry.Visibility == 1 or self.show_all == true then
			self:SelectEntry(newEntry)
		else
			ui.playElementSound(element, "click", "error")
		end
	end
end

function TechCutscenesController:play_pressed(element)
	RocketUiSystem.cutscene = self.SelectedEntry
	RocketUiSystem:beginSubstate("Cutscene")
	self.document:Close()
end

function TechCutscenesController:exit_pressed(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

return TechCutscenesController
