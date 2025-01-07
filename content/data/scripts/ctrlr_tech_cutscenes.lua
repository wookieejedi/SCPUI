local dialogs = require("lib_dialogs")
local class = require("lib_class")
local topics = require("lib_ui_topics")

local TechCutscenesController = class()

function TechCutscenesController:init()
	self.show_all = false
	self.Counter = 0
end

---@param document Document
function TechCutscenesController:initialize(document)
    self.document = document
    self.elements = {}
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.document:GetElementById("tech_btn_1"):SetPseudoClass("checked", false)
	self.document:GetElementById("tech_btn_2"):SetPseudoClass("checked", false)
	self.document:GetElementById("tech_btn_3"):SetPseudoClass("checked", true)
	self.document:GetElementById("tech_btn_4"):SetPseudoClass("checked", false)
	
	topics.techroom.initialize:send(self)
	
	self.SelectedEntry = nil
	self.list = {}
	
	local cutsceneList = ui.TechRoom.Cutscenes
	local i = 1
	while (i <= #cutsceneList) do
		self.list[i] = {
			Name = cutsceneList[i].Name,
			Filename = cutsceneList[i].Filename,
			Description = cutsceneList[i].Description,
			isVisible = cutsceneList[i].isVisible,
			Index = i
		}
		topics.cutscenes.addParam:send({self.list[i], cutsceneList[i]})
		i = i + 1
	end
	
	topics.cutscenes.initialize:send(self)
	
	--Only create entries if there are any to create
	if self.list[1] then
		self.visibleList = {}
		self:CreateEntries(self.list)
		if self.list[1].Name then
			self:SelectEntry(self.list[1])
		end
	end
	
end

function TechCutscenesController:ReloadList()

	local list_items_el = self.document:GetElementById("cutscene_list_ul")
	ScpuiSystem:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self.visibleList = {}
	self.Counter = 0
	self:CreateEntries(self.list)
	self:SelectEntry(self.visibleList[1])

end

function TechCutscenesController:CreateEntryItem(entry, index)

	self.Counter = self.Counter + 1

	local li_el = self.document:CreateElement("li")

	li_el.inner_rml = "<div class=\"cutscenelist_name\">" .. entry.Name .. "</div>"
	li_el.id = entry.Filename

	li_el:SetClass("cutscenelist_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	self.visibleList[self.Counter] = entry
	entry.key = li_el.id
	
	self.visibleList[self.Counter].Index = self.Counter

	return li_el
end

function TechCutscenesController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("cutscene_list_ul")
	
	ScpuiSystem:ClearEntries(list_names_el)

	for i, v in pairs(list) do
	
		if topics.cutscenes.hideMovie:send(v) == false then
						
			topics.cutscenes.createList:send({self, v})
		
			if self.show_all then
				list_names_el:AppendChild(self:CreateEntryItem(v, i))
			elseif v.isVisible == true then
				list_names_el:AppendChild(self:CreateEntryItem(v, i))
			end
		end
	end
end

function TechCutscenesController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
	
		topics.cutscenes.selectScene:send({self, entry})
		
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

function TechCutscenesController:ChangeTechState(state)

	if state == 1 then
		topics.techroom.btn1Action:send()
	end
	if state == 2 then
		topics.techroom.btn2Action:send()
	end
	if state == 3 then
		--This is where we are already, so don't do anything
		--topics.techroom.btn3Action:send()
	end
	if state == 4 then
		topics.techroom.btn4Action:send()
	end
	
end

function TechCutscenesController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    elseif event.parameters.key_identifier == rocket.key_identifier.S and event.parameters.ctrl_key == 1 and event.parameters.shift_key == 1 then
		self.show_all  = not self.show_all
		self:ReloadList()
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
		self:ChangeTechState(2)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
		self:ChangeTechState(4)
	elseif event.parameters.key_identifier == rocket.key_identifier.TAB then
		--do nothing
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.shift_key == 1 then
		self:ScrollList(self.document:GetElementById("cutscene_list"), 0)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.shift_key == 1 then
		self:ScrollList(self.document:GetElementById("cutscene_list"), 1)
	elseif event.parameters.key_identifier == rocket.key_identifier.UP then
		self:prev_pressed()
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN then
		self:next_pressed()
	elseif event.parameters.key_identifier == rocket.key_identifier.LEFT then
		--self:select_prev()
	elseif event.parameters.key_identifier == rocket.key_identifier.RIGHT then
		--self:select_next()
	elseif event.parameters.key_identifier == rocket.key_identifier.F1 then
		--self:help_clicked(element)
	elseif event.parameters.key_identifier == rocket.key_identifier.F2 then
		--self:options_button_clicked(element)
	end
end

function TechCutscenesController:global_keyup(element, event)
	if event.parameters.key_identifier == rocket.key_identifier.RETURN then
		self:play_pressed(element)
	end
end

function TechCutscenesController:ScrollList(element, direction)
	if direction == 0 then
		element.scroll_top = element.scroll_top - 15
	else
		element.scroll_top = element.scroll_top + 15
	end
end

function TechCutscenesController:prev_pressed(element)
	if self.SelectedEntry ~= nil then
		if self.SelectedIndex == 1 then
			ui.playElementSound(element, "click", "error")
		else
			self:SelectEntry(self.visibleList[self.SelectedIndex - 1])
		end
	end
end

function TechCutscenesController:next_pressed(element)
	if self.SelectedEntry ~= nil then
		local num = #self.visibleList
		
		if self.SelectedIndex == num then
			ui.playElementSound(element, "click", "error")
		else
			self:SelectEntry(self.visibleList[self.SelectedIndex + 1])
		end
	end
end

function TechCutscenesController:play_pressed(element)
	if self.SelectedEntry ~= nil then
		ScpuiSystem.data.memory.cutscene = self.SelectedEntry
		ScpuiSystem:beginSubstate("Cutscene")
		self.document:Close()
	end
end

function TechCutscenesController:exit_pressed(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

function TechCutscenesController:unload()
	topics.cutscenes.unload:send(self)
end

return TechCutscenesController
