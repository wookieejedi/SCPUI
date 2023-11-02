local class = require("class")
local topics = require("ui_topics")

local HotkeyController = class()

function HotkeyController:init()
end

function HotkeyController:initialize(document)

    self.document = document

	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	self.document:GetElementById("current_key"):SetClass(("h2-" .. ScpuiSystem:getFontSize()), true)
	
	if mn.isInMission() then
		ScpuiSystem:pauseAllAudio(true)
	end
	
	ui.MissionHotkeys.initHotkeysList()
	
	self:initHotkeys()
	self:createHotkeysList()
	
	topics.hotkeyconfig.initialize:send(self)
	
	self:ChangeKey(1)
	
	self.selectedIndex = 1
	local entry = self.indexList[self.selectedIndex]
	
	self:SelectEntry(entry[1], entry[2], entry[3], entry[4], 1)
end

function HotkeyController:initHotkeys()
	
	self.hotkeys = {}
	self.indexList = {}
	
	local section = 0
	local ship = 0
	
	for i = 1, #ui.MissionHotkeys.Hotkeys_List do
		local entry = ui.MissionHotkeys.Hotkeys_List[i]
		
		--maybe create a new section
		if entry.Type == HOTKEY_LINE_HEADING then
			section = #self.hotkeys + 1
			self.hotkeys[section] = {}
			self.hotkeys[section].heading = entry.Text
			self.hotkeys[section].ships = {}
			
			ship = 0
		else
			ship = ship + 1
			self.hotkeys[section].ships[ship] = {}
			
			self.hotkeys[section].ships[ship].text = entry.Text
			self.hotkeys[section].ships[ship].lineType = entry.Type
			self.hotkeys[section].ships[ship].keys = {}
			self.hotkeys[section].ships[ship].index = i
			
			local shipKeys = entry.Keys
			
			--on first run lets save how many hotkeys we have total
			if self.numKeys == nil then
				self.numKeys = #shipKeys
			end
			
			for key = 1, #shipKeys do
				local keyText = "F" .. tostring(key + 4)
				if shipKeys[key] then
					self.hotkeys[section].ships[ship].keys[key] = keyText
				else
					self.hotkeys[section].ships[ship].keys[key] = "&nbsp;"
				end
			end
		end
	end
end

function HotkeyController:createHotkeysList()

	local parent_el = self.document:GetElementById("log_text_wrapper")
	
	for i = 1, #self.hotkeys do
	
		local group_el = self.document:CreateElement("div")
		group_el.id = "group_" .. i
		group_el:SetClass("hotkey_group")
		parent_el:AppendChild(group_el)
		
		--create the header for the group
		local header_el = self.document:CreateElement("div")
		header_el.id = "header_" .. i
		header_el:SetClass("hotkey_header", true)
		header_el:SetClass("brightblue", true)
		header_el.inner_rml = self.hotkeys[i].heading
		group_el:AppendChild(header_el)
		
		--create the entry list
		local list_el = self.document:CreateElement("ul")
		list_el.id = "hotkey_list"
		group_el:AppendChild(list_el)
		
		for entry = 1, #self.hotkeys[i].ships do
			local li_el = self.document:CreateElement("li")
			li_el.id = "line_" .. i .. "_" .. entry
			local entryHTML = ""
			
			--insert key texts into divs
			for key = 1, #self.hotkeys[i].ships[entry].keys do
				local keyID = "key_" .. i .. "_" .. entry .. "_" .. key
				entryHTML = entryHTML .. "<div id=\"" .. keyID .. "\" class=\"key_display\">" .. self.hotkeys[i].ships[entry].keys[key] .. "</div>"
			end
			
			--insert the wing icon div
			local wingHTML = ""
			if self.hotkeys[i].ships[entry].lineType == HOTKEY_LINE_WING then
				wingHTML = "<div class=\"wing_icon wing_icon_vis\"><img src=\"multiplayer-h.png\" class=\"psuedo_img\"></img></div>"
			else
				wingHTML = "<div class=\"wing_icon\"><img src=\"multiplayer-h.png\" class=\"psuedo_img\"></img></div>"
			end
			entryHTML = entryHTML .. wingHTML
			
			--ships in a wing get a little indent
			local shipClass = "<div class=\"ship_name\">"
			if self.hotkeys[i].ships[entry].lineType == HOTKEY_LINE_SUBSHIP then
				shipClass = "<div class=\"ship_name wing_item\">"
			end
			--insert the ship name div
			entryHTML = entryHTML .. shipClass .. self.hotkeys[i].ships[entry].text .. "</div>"
			
			li_el.inner_rml = entryHTML
			li_el:SetClass("hotkeylist_element", true)
			li_el:SetClass("button_1", true)
			li_el:AddEventListener("click", function(_, _, _)
				self:SelectEntry(self.hotkeys[i].ships[entry].index, li_el, i, entry, #self.indexList + 1)
			end)
			li_el:AddEventListener("dblclick", function(_, _, _)
				self:ToggleKey(self.hotkeys[i].ships[entry].index, li_el, i, entry)
			end)
			
			local t = {self.hotkeys[i].ships[entry].index, li_el, i, entry}
			table.insert(self.indexList, t)
			
			list_el:AppendChild(li_el)
		end
	end

end

function HotkeyController:SelectEntry(idx, element, group, item, listIdx)

	self.currentEntry = idx
	self.selectedIndex = listIdx
	
	if self.oldElement == nil then
		self.oldElement = element
	else
		self.oldElement:SetPseudoClass("checked", false)
		self.oldElement = element
	end
	
	element:SetPseudoClass("checked", true)
	
	self.selectedGroup = group
	self.selectedElement = item

end

function HotkeyController:ToggleKey(idx, element, group, item, key)
	
	self:SelectEntry(idx, element, group, item, self.selectedIndex)
	
	if key == nil then
		key = self.currentKey
	end
	
	local keyID = "key_" .. self.selectedGroup .. "_" .. self.selectedElement .. "_" .. key
	local key_el = self.document:GetElementById(keyID)
	
	local keyText = "F" .. tostring(key + 4)
	if key_el.inner_rml == keyText then
		self:RemKey(key)
	else
		self:AddKey(key)
	end
	
end

function HotkeyController:AddKey(key)

	if key == nil then
		ba.warning("How did that happen? Get Mjn")
		return
	end
	
	if self.currentEntry == nil then
		--nothing to do!
		return
	end

	ui.MissionHotkeys.Hotkeys_List[self.currentEntry]:addHotkey(key)
	
	local keyID = "key_" .. self.selectedGroup .. "_" .. self.selectedElement .. "_" .. key
	local key_el = self.document:GetElementById(keyID)
	
	local keyText = "F" .. tostring(key + 4)
	key_el.inner_rml = keyText
	
	self:CheckWings(key, keyText)
end

function HotkeyController:RemKey(key)

	if key == nil then
		ba.warning("How did that happen? Get Mjn")
		return
	end
	
	if self.currentEntry == nil then
		--nothing to do!
		return
	end
	
	ui.MissionHotkeys.Hotkeys_List[self.currentEntry]:removeHotkey(key)
	
	local keyID = "key_" .. self.selectedGroup .. "_" .. self.selectedElement .. "_" .. key
	local key_el = self.document:GetElementById(keyID)
	
	local keyText = "&nbsp;"
	key_el.inner_rml = keyText
	
	self:CheckWings(key, keyText)
end

function HotkeyController:SelectNext()

    if self.selectedIndex >= #self.indexList then
		return
	end
	
	self.selectedIndex = self.selectedIndex + 1
	
	local entry = self.indexList[self.selectedIndex]
	
	self:SelectEntry(entry[1], entry[2], entry[3], entry[4], self.selectedIndex)

end

function HotkeyController:SelectPrev()

	if self.selectedIndex <= 1 then
		return
	end
	
	self.selectedIndex = self.selectedIndex - 1
	
	local entry = self.indexList[self.selectedIndex]
	
	self:SelectEntry(entry[1], entry[2], entry[3], entry[4], self.selectedIndex)

end

function HotkeyController:CheckWings(key, text)

	if ui.MissionHotkeys.Hotkeys_List[self.currentEntry].Type == HOTKEY_LINE_WING then
		local idx = self.selectedElement
		--Max 6 ships in a wing so check all six following items in the list
		for i = self.currentEntry + 1, self.currentEntry + 6 do
			idx = idx + 1
			if ui.MissionHotkeys.Hotkeys_List[i].Type == HOTKEY_LINE_SUBSHIP then
				local keyID = "key_" .. self.selectedGroup .. "_" .. idx .. "_" .. key
				local key_el = self.document:GetElementById(keyID)
				key_el.inner_rml = text
			end
		end
		
	end
	
end

function HotkeyController:ChangeKey(key)
	self.currentKey = key
	local key_el = self.document:GetElementById("current_key")
	local keyText = "F" .. tostring(self.currentKey + 4)
	
	key_el.inner_rml = keyText
end

function HotkeyController:DecrementKey()

    if self.currentKey == 1 then
		self:ChangeKey(8)
	else
		self:ChangeKey(self.currentKey - 1)
	end

end

function HotkeyController:IncrementKey()

    if self.currentKey == 8 then
		self:ChangeKey(1)
	else
		self:ChangeKey(self.currentKey + 1)
	end

end

function HotkeyController:ResetKeys()

    ui.playElementSound(element, "click", "success")
	ui.MissionHotkeys.resetHotkeys()
	
	local parent_el = self.document:GetElementById("log_text_wrapper")
	ScpuiSystem:ClearEntries(parent_el)
	self:createHotkeysList()

end

function HotkeyController:ClearKey()

    ui.playElementSound(element, "click", "success")
	self:RemKey(self.currentKey)

end

function HotkeyController:SetDefaults()

    ui.playElementSound(element, "click", "success")
	ui.MissionHotkeys.resetHotkeysDefault()
	
	local parent_el = self.document:GetElementById("log_text_wrapper")
	ScpuiSystem:ClearEntries(parent_el)
	self:createHotkeysList()

end

function HotkeyController:Exit(element)

    ui.playElementSound(element, "click", "success")
	if mn.isInMission() then
		ScpuiSystem:pauseAllAudio(false)
	end
	ui.MissionHotkeys.saveHotkeys()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])

end

function HotkeyController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
		if mn.isInMission() then
			ScpuiSystem:pauseAllAudio(false)
		end
		ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
	elseif event.parameters.key_identifier == rocket.key_identifier.UP then
		self:SelectPrev()
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN then
		self:SelectNext()
	elseif event.parameters.key_identifier == rocket.key_identifier.RETURN then
		local entry = self.indexList[self.selectedIndex]
		self:ToggleKey(entry[1], entry[2], entry[3], entry[4])
    elseif event.parameters.key_identifier == rocket.key_identifier.F5 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 1)
		else
			self:ChangeKey(1)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F6 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 2)
		else
			self:ChangeKey(2)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F7 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 3)
		else
			self:ChangeKey(3)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F8 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 4)
		else
			self:ChangeKey(4)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F9 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 5)
		else
			self:ChangeKey(5)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F10 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 6)
		else
			self:ChangeKey(6)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F11 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 7)
		else
			self:ChangeKey(7)
		end
	elseif event.parameters.key_identifier == rocket.key_identifier.F12 then
		if event.parameters.shift_key == 1 then
			local entry = self.indexList[self.selectedIndex]
			self:ToggleKey(entry[1], entry[2], entry[3], entry[4], 8)
		else
			self:ChangeKey(8)
		end
	end
end

return HotkeyController
