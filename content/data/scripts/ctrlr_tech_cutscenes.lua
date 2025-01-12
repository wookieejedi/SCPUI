-----------------------------------
--Controller for the Tech Cutscenes UI
-----------------------------------

local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local TechCutscenesController = Class()

TechCutscenesController.STATE_DATABASE = 0 --- @type number The enumeration for the database state
TechCutscenesController.STATE_SIMULATOR = 1 --- @type number The enumeration for the simulator state
TechCutscenesController.STATE_CUTSCENE = 2 --- @type number The enumeration for the cutscene state
TechCutscenesController.STATE_CREDITS = 3 --- @type number The enumeration for the credits state

--- Called by the class constructor
--- @return nil
function TechCutscenesController:init()
	self.ShowAll = false --- @type boolean Whether to show all cutscenes or only the visible ones
	self.Counter = 0 --- @type number The counter for the number of cutscenes
	self.SelectedEntry = nil --- @type string The currently selected cutscene id
	self.SelectedIndex = 0 --- @type number The index of the currently selected cutscene
	self.Cutscenes_List = {} --- @type scpui_cutscene_entry[] The list of cutscenes
	self.Visible_List = {} --- @type scpui_cutscene_entry[] The list of visible cutscenes
end

--- Called by the RML document
--- @param document Document
function TechCutscenesController:initialize(document)
    self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.Document:GetElementById("tech_btn_1"):SetPseudoClass("checked", false)
	self.Document:GetElementById("tech_btn_2"):SetPseudoClass("checked", false)
	self.Document:GetElementById("tech_btn_3"):SetPseudoClass("checked", true)
	self.Document:GetElementById("tech_btn_4"):SetPseudoClass("checked", false)

	Topics.techroom.initialize:send(self)

	self.SelectedEntry = nil
	self.Cutscenes_List = {}

	local cutscene_list = ui.TechRoom.Cutscenes
	local i = 1
	while (i <= #cutscene_list) do
		self.Cutscenes_List[i] = {
			Name = cutscene_list[i].Name,
			Filename = cutscene_list[i].Filename,
			Description = cutscene_list[i].Description,
			Visible = cutscene_list[i].isVisible,
			Index = i,
			Key = ''
		}
		Topics.cutscenes.addParam:send({self.Cutscenes_List[i], cutscene_list[i]})
		i = i + 1
	end

	Topics.cutscenes.initialize:send(self)

	--Only create entries if there are any to create
	if self.Cutscenes_List[1] then
		self.Visible_List = {}
		self:createCutsceneListElements(self.Cutscenes_List)
		if self.Cutscenes_List[1].Name then
			self:selectCutscene(self.Cutscenes_List[1])
		end
	end

end

--- Reloads the cutscenes list entirely and refreshes the UI
--- @return nil
function TechCutscenesController:reloadCutscenesList()
	local list_items_el = self.Document:GetElementById("cutscene_list_ul")
	ScpuiSystem:clearEntries(list_items_el)
	self.SelectedEntry = nil
	self.Visible_List = {}
	self.Counter = 0
	self:createCutsceneListElements(self.Cutscenes_List)
	self:selectCutscene(self.Visible_List[1])
end

--- Creates a cutscene list item element and returns it
--- @param entry scpui_cutscene_entry The cutscene entry to create an element for
--- @param index number The index of the cutscene entry
function TechCutscenesController:createCutsceneListItemElement(entry, index)

	self.Counter = self.Counter + 1

	local li_el = self.Document:CreateElement("li")

	li_el.inner_rml = "<div class=\"cutscenelist_name\">" .. entry.Name .. "</div>"
	li_el.id = entry.Filename

	li_el:SetClass("cutscenelist_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:selectCutscene(entry)
	end)
	self.Visible_List[self.Counter] = entry
	entry.Key = li_el.id

	self.Visible_List[self.Counter].Index = self.Counter

	return li_el
end

--- Creates all the cutscene entries in the list provided
--- @param list scpui_cutscene_entry[] The list of cutscenes to create entries for
--- @return nil
function TechCutscenesController:createCutsceneListElements(list)

	local list_names_el = self.Document:GetElementById("cutscene_list_ul")

	ScpuiSystem:clearEntries(list_names_el)

	for i, v in pairs(list) do

		if Topics.cutscenes.hideMovie:send(v) == false then

			Topics.cutscenes.createList:send({self, v})

			if self.ShowAll then
				list_names_el:AppendChild(self:createCutsceneListItemElement(v, i))
			elseif v.Visible == true then
				list_names_el:AppendChild(self:createCutsceneListItemElement(v, i))
			end
		end
	end
end

--- Selects a cutscene as the current scene
--- @param entry scpui_cutscene_entry The cutscene entry to select
--- @return nil
function TechCutscenesController:selectCutscene(entry)

	if entry.Key ~= self.SelectedEntry then

		Topics.cutscenes.selectScene:send({self, entry})

		if self.SelectedEntry then
			local prev_cutscene_element = self.Document:GetElementById(self.SelectedEntry)
			if prev_cutscene_element then prev_cutscene_element:SetPseudoClass("checked", false) end
		end

		local this_entry = self.Document:GetElementById(entry.Key)
		self.SelectedEntry = entry.Key
		self.SelectedIndex = entry.Index
		this_entry:SetPseudoClass("checked", true)

		self.Document:GetElementById("cutscene_desc").inner_rml = entry.Description

	end

end

--- Called by the RML to change the tech room game state
--- @param state number The state to change to. Should be one of the STATE_ enumerations
--- @return nil
function TechCutscenesController:change_tech_state(state)

	if state == self.STATE_DATABASE then
		Topics.techroom.btn1Action:send()
	end
	if state == self.STATE_SIMULATOR then
		Topics.techroom.btn2Action:send()
	end
	if state == self.STATE_CUTSCENE then
		--This is where we are already, so don't do anything
		--topics.techroom.btn3Action:send()
	end
	if state == self.STATE_CREDITS then
		Topics.techroom.btn4Action:send()
	end

end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function TechCutscenesController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    elseif event.parameters.key_identifier == rocket.key_identifier.S and event.parameters.ctrl_key == 1 and event.parameters.shift_key == 1 then
		self.ShowAll  = not self.ShowAll
		self:reloadCutscenesList()
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
		self:change_tech_state(2)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
		self:change_tech_state(4)
	elseif event.parameters.key_identifier == rocket.key_identifier.TAB then
		--do nothing
	elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.shift_key == 1 then
		self:scrollList(self.Document:GetElementById("cutscene_list"), 0)
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.shift_key == 1 then
		self:scrollList(self.Document:GetElementById("cutscene_list"), 1)
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

--- Global keyup function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function TechCutscenesController:global_keyup(element, event)
	if event.parameters.key_identifier == rocket.key_identifier.RETURN then
		self:play_pressed(element)
	end
end

--- Scrolls the list up or down
--- @param element Element The element to scroll
--- @param direction number The direction to scroll. 0 is up, 1 is down
--- @return nil
function TechCutscenesController:scrollList(element, direction)
	if direction == 0 then
		element.scroll_top = element.scroll_top - 15
	else
		element.scroll_top = element.scroll_top + 15
	end
end

--- Called by the RML when the previous button is pressed
--- @param element? Element The element that was clicked
--- @return nil
function TechCutscenesController:prev_pressed(element)
	if self.SelectedEntry ~= nil then
		if self.SelectedIndex == 1 then
			ui.playElementSound(element, "click", "error")
		else
			self:selectCutscene(self.Visible_List[self.SelectedIndex - 1])
		end
	end
end

--- Called by the RML when the next button is pressed
--- @param element? Element The element that was clicked
--- @return nil
function TechCutscenesController:next_pressed(element)
	if self.SelectedEntry ~= nil then
		local num = #self.Visible_List

		if self.SelectedIndex == num then
			ui.playElementSound(element, "click", "error")
		else
			self:selectCutscene(self.Visible_List[self.SelectedIndex + 1])
		end
	end
end

--- Called by the RML when the play button is pressed
--- @param element Element The element that was clicked
--- @return nil
function TechCutscenesController:play_pressed(element)
	if self.SelectedEntry ~= nil then
		ScpuiSystem.data.memory.Cutscene = self.SelectedEntry
		ScpuiSystem:beginSubstate("Cutscene")
		self.Document:Close()
	end
end

--- Called by the RML when the exit button is pressed
--- @param element Element The element that was clicked
--- @return nil
function TechCutscenesController:exit_pressed(element)
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

--- Called when the screen is being unloaded
--- @return nil
function TechCutscenesController:unload()
	Topics.cutscenes.unload:send(self)
end

return TechCutscenesController
