local dialogs = require("dialogs")
local class = require("class")
local topics = require("ui_topics")
local async_util = require("async_util")
local loadoutHandler = require("loadouthandler")
local utils = require("utils")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local ShipSelectController = class()

ScpuiSystem.data.memory.modelDraw = nil

function ShipSelectController:init()
	loadoutHandler:init()
	ScpuiSystem.data.memory.modelDraw = {}
	self.help_shown = false
	self.enabled = false
	self.ships = {}
	self.activeSlots = {}
	self.selectedShip = ''
end

---@param document Document
function ShipSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.aniEl = self.document:CreateElement("ani")
	self.requiredWeps = {}
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
	
	self.ship3d, self.shipEffect, self.icon3d = ui.ShipWepSelect.get3dShipChoices()
	
	--Get all the required weapons
	local j = 1
	while (j < #tb.WeaponClasses) do
		if tb.WeaponClasses[j]:isWeaponRequired() then
			self.requiredWeps[#self.requiredWeps + 1] = tb.WeaponClasses[j].Name
		end
		j = j + 1
	end
	
	--Create the anim here so that it can be restarted with each new selection
	local aniWrapper = self.document:GetElementById("ship_view")
	aniWrapper:ReplaceChild(self.aniEl, aniWrapper.first_child)

	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", true)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", false)
	
	self.SelectedEntry = nil
	
	self.enabled = self:BuildWings()
	
	for i = 1, loadoutHandler:GetNumSlots() do
		table.insert(self.ships, 0)
	end
	
	if ScpuiSystem:inMultiGame() then
		self.document:GetElementById("chat_wrapper"):SetClass("hidden", false)
		self.document:GetElementById("c_panel_wrapper_multi"):SetClass("hidden", false)
		self.document:GetElementById("c_panel_wrapper"):SetClass("hidden", true)
		self:updateLists()
		ui.MultiGeneral.setPlayerState()
	end
	
	topics.shipselect.initialize:send(self)
	
	--Only create entries if there are any to create
	if loadoutHandler:GetNumShips() > 0 and self.enabled == true then
		self:CreateEntries(loadoutHandler:GetShipList())
	end
	
	if loadoutHandler:GetNumShips() > 0 and self.enabled == true then
		self:SelectEntry(loadoutHandler:GetShipList()[1])
	end
	
	self:startMusic()

end

function ShipSelectController:BuildWings()

	local slotNum = 1
	local wrapperEl = self.document:GetElementById("wings_wrapper")
	ScpuiSystem:ClearEntries(wrapperEl)
	
	--Check that we actually have wing slots
	if loadoutHandler:GetNumWings() <= 0 then
		ba.warning("Mission has no loadout wings! Check the loadout in FRED!")
		return false
	end

	for i = 1, loadoutHandler:GetNumWings() do

		--First create a wrapper for the whole wing
		local wingEl = self.document:CreateElement("div")
		wingEl:SetClass("wing", true)
		wrapperEl:AppendChild(wingEl)
		
		--Add the wrapper for the slots
		local slotsEl = self.document:CreateElement("div")
		slotsEl:SetClass("slot_wrapper", true)
		wingEl:ReplaceChild(slotsEl, wingEl.first_child)
		
		--Add the wing name
		local nameEl = self.document:CreateElement("div")
		nameEl:SetClass("wing_name", true)
		nameEl.inner_rml = loadoutHandler:GetWingDisplayName(i)
		wingEl:AppendChild(nameEl)
		
		--Check that the wing actually has valid ship slots
		if loadoutHandler:GetNumWingSlots(slotNum) <= 0 then
			ba.warning("Loadout wing '" .. loadoutHandler:GetWingName(i) .. "' has no valid ship slots! Check the loadout in FRED!")
			return false
		end
		
		--Now we add the actual wing slots
		for j = 1, loadoutHandler:GetNumWingSlots(i), 1 do
			local slotInfo = loadoutHandler:GetShipLoadout(slotNum)
			
			--This is really only used for multi to limit how often icons are changed
			self.ships[slotNum] = slotInfo.ShipClassIndex

			local slotEl = self.document:CreateElement("div")
			slotEl:SetClass("wing_slot", true)
			slotsEl:AppendChild(slotEl)
			
			--default to empty slot image for now, but don't show disabled slots
			local slotIcon = loadoutHandler:getEmptyWingSlotIcon()[2]
			if slotInfo.isDisabled then
				slotIcon = loadoutHandler:getEmptyWingSlotIcon()[1]
			end
			
			if slotInfo.WingSlot == 1 then
				slotEl:SetClass("wing_one", true)
			elseif slotInfo.WingSlot == 2 then
				slotEl:SetClass("wing_two", true)
			elseif slotInfo.WingSlot == 3 then
				slotEl:SetClass("wing_three", true)
			elseif slotInfo.WingSlot == 4 then
				slotEl:SetClass("wing_four", true)
			else
				ba.error("Got wing slot > 4! Need to add RCSS support!")
			end
			
			--Get the current ship in this slot
			local shipIndex = slotInfo.ShipClassIndex
			if shipIndex > 0 then
				local entry = loadoutHandler:GetShipInfo(shipIndex)
				if entry == nil then
					--This reeeeaaaaallly shouldn't happen, but it is for some multi missions
					ba.warning("Could not find " .. tb.ShipClasses[shipIndex].Name .. " in the loadout! Appending!")
					loadoutHandler:AppendToShipInfo(shipIndex)
					entry = loadoutHandler:GetShipInfo(shipIndex)
				end
				if entry then
					if slotInfo.isShipLocked then
						slotIcon = entry.GeneratedIcon[5]
					else
						slotIcon = entry.GeneratedIcon[1]
					end
				else
					ba.error("Failed to generate ship info for " .. tb.ShipClasses[shipIndex].Name .. "!")
				end
			end
			
			local slotImg = self.document:CreateElement("img")
			slotImg:SetAttribute("src", slotIcon)
			slotEl:AppendChild(slotImg)
			
			local slotName = self.document:CreateElement("div")
			slotName.inner_rml = slotInfo.displayName
			slotName.id = "callsign_" .. slotNum
			slotName:SetClass("slot_name", true)
			slotEl:AppendChild(slotName)
			
			--This is here so that the event listeners use the correct slot index!
			local index = slotNum
			
			slotEl.id = "slot_" .. index
			
			if ScpuiSystem:inMultiGame() then
				self:ActivateNameDrag(slotName, index)
			end

			self:ActivateSlot(index)
			
			slotNum = slotNum + 1
		end
	end
	
	return true

end

function ShipSelectController:ActivateNameDrag(name_el, slot)
	name_el:SetClass("drag", true)
	name_el:SetClass("available", true)
	name_el:SetClass("name_slot", true)
	name_el.id = "callsign_drag"
	
	--Add dragover detection
	name_el:AddEventListener("dragdrop", function(_, _, _)
		self:DragNameOver(name_el, slot)
	end)
	
	name_el:AddEventListener("dragend", function(_, _, _)
		self:DragNameEnd(name_el, slot)
	end)
end

function ShipSelectController:ActivateSlot(slot)
	local slotInfo = loadoutHandler:GetShipLoadout(slot)
	
	--Don't activate disabled slots
	if slotInfo.isDisabled == true then
		return
	end
	
	--Don't activate already active slots
	local utils = require("utils")
	if utils.table.contains(self.activeSlots, slot) then
		return
	end
	
	table.insert(self.activeSlots, slot)
	
	local element = self.document:GetElementById("slot_" .. slot)
	
	--Abort if the slot was never created
	if not element then
		return
	end
	
	--If we're in multi and we're activating then we need to deactivate name dragging
	if ScpuiSystem:inMultiGame() then
		local name_el = element.first_child.next_sibling
		name_el:SetClass("drag", false)
		name_el:SetClass("available", false)
		name_el.id = "callsign_" .. slot
	end
	
	--Add dragover detection
	element:AddEventListener("dragdrop", function(_, _, _)
		self:DragOver(element, slot)
	end)

	if slotInfo.ShipClassIndex > 0 then
		local thisEntry = loadoutHandler:GetShipInfo(slotInfo.ShipClassIndex)
		if thisEntry == nil then
			ba.warning("Ship Info did not exist! How? Who knows! Get Mjn!")
			thisEntry = loadoutHandler:AppendToShipInfo(slotInfo.ShipClassIndex)
		end
		
		if not slotInfo.isShipLocked then
			
			--Add drag detection
			element:SetClass("drag", true)
			element:AddEventListener("dragend", function(_, _, _)
				self.drag = false
				self:DragSlotEnd(element, thisEntry, slot)
			end)
			
			--Add dragstart detection
			element:AddEventListener("dragstart", function(_,_,_)
				self.drag = true
			end)
			
			--Add mouseover detection
			element:AddEventListener("mouseover", function(_, _, _)
				if self.drag then
					element:SetPseudoClass("valid", true)
				end
			end)
			
			--Add mouseout detection
			element:AddEventListener("mouseout", function(_, _, _)
				element:SetPseudoClass("valid", false)
			end)
			
			if self.icon3d then
				element:SetClass("available", true)
			end
		else
			if self.icon3d then
				element:SetClass("locked", true)
			end
		end
		
		--Add click detection
		element:SetClass("button_3", true)
		element:AddEventListener("click", function(_, _, _)
			self:ClickOnSlot(thisEntry, slot)
		end)
	end
end

function ShipSelectController:ReloadList()

	ScpuiSystem.data.memory.modelDraw.class = nil
	local list_items_el = self.document:GetElementById("ship_icon_list_ul")
	ScpuiSystem:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self:CreateEntries(loadoutHandler:GetShipList())
	self:BuildWings()
	if loadoutHandler:GetShipInfo(1) then
		self:SelectEntry(loadoutHandler:GetShipInfo(1))
	end
end

function ShipSelectController:CreateEntryItem(entry, idx)

	local li_el = self.document:CreateElement("li")
	local iconWrapper = self.document:CreateElement("div")
	iconWrapper.id = entry.Name
	iconWrapper:SetClass("select_item", true)
	
	li_el:AppendChild(iconWrapper)
	
	local countEl = self.document:CreateElement("div")
	countEl.inner_rml = tostring(loadoutHandler:GetShipPoolAmount(entry.Index))
	countEl:SetClass("amount", true)
	
	iconWrapper:AppendChild(countEl)
	
	--local aniWrapper = self.document:GetElementById(entry.Icon)
	local iconEl = self.document:CreateElement("img")
	iconEl:SetAttribute("src", entry.GeneratedIcon[1])
	iconWrapper:AppendChild(iconEl)
	--iconWrapper:ReplaceChild(iconEl, iconWrapper.first_child)
	li_el.id = entry.Name
	entry.key = li_el.id

	--iconEl:SetClass("shiplist_element", true)
	iconEl:SetClass("icon", true)
	iconEl:SetClass("button_3", true)
	iconEl:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	
	if topics.shipselect.poolentry:send({self, iconEl, entry}) then
		iconEl:SetClass("drag", true)
		iconEl:AddEventListener("dragend", function(_, _, _)
			self.drag = false
			self:DragPoolEnd(iconEl, entry, entry.Index)
		end)
		
		--Add dragstart detection
		iconEl:AddEventListener("dragstart", function(_,_,_)
			self.drag = true
		end)
	end

	return li_el
end

function ShipSelectController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("ship_icon_list_ul")
	
	ScpuiSystem:ClearEntries(list_names_el)

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function ShipSelectController:BreakoutReader()
	local text = topics.ships.description:send(tb.ShipClasses[self.selectedShip])
	local title = "<span style=\"color:white;\">" .. topics.ships.name:send(tb.ShipClasses[self.selectedShip]) .. "</span>"
	local buttons = {}
	buttons[1] = {
		b_type = dialogs.BUTTON_TYPE_POSITIVE,
		b_text = ba.XSTR("Close", 888110),
		b_value = "",
		b_keypress = string.sub(ba.XSTR("Close", 888110), 1, 1)
	}
	self:Show(text, title, buttons)
end

function ShipSelectController:HighlightShip(entry, slot)

	local list = loadoutHandler:GetShipList()

	for i, v in pairs(list) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if v.key == entry.key then
			if self.icon3d then
				iconEl:SetClass("highlighted", true)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[3])
		else
			if self.icon3d then
				iconEl:SetClass("highlighted", false)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[1])
		end
	end
	
	-- No ship slot to highlight!
	if slot == nil then
		return
	end

	for i = 1, loadoutHandler:GetNumSlots() do
		local ship = loadoutHandler:GetShipLoadout(i)
		local element = self.document:GetElementById("slot_" .. i)
		local shipIndex = ship.ShipClassIndex
		local thisEntry = loadoutHandler:GetShipInfo(shipIndex)
		if thisEntry ~= nil then
			if slot == i then
				if ship.isShipLocked then
					element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[6])
				else
					element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[3])
				end
			else
				if ship.isShipLocked then
					element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[5])
				else
					element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[1])
				end
			end
		end
	end
				
end

function ShipSelectController:SelectEntry(entry, slot)

	--No issue to just re-highlight things
	--This allows all ship slots to highlight themselves when clicked
	self:HighlightShip(entry, slot)

	if entry.key ~= self.SelectedEntry then
		
		self.SelectedEntry = entry.key
		self.selectedShip = entry.Name
		
		self:BuildInfo(entry)
		
		if self.ship3d or entry.Anim == nil then
			ScpuiSystem.data.memory.modelDraw.class = entry.Index
			ScpuiSystem.data.memory.modelDraw.element = self.document:GetElementById("ship_view_wrapper")
			ScpuiSystem.data.memory.modelDraw.start = true
		else
			--the anim is already created so we only need to remove and reset the src
			self.aniEl:RemoveAttribute("src")
			self.aniEl:SetAttribute("src", entry.Anim)
		end
		
	end

end

function ShipSelectController:BuildInfo(entry)

	local infoEl = self.document:GetElementById("ship_stats_info")
	
	self.document:GetElementById("ship_stats_wrapper").scroll_top = 0
	
	ScpuiSystem:ClearEntries(infoEl)
	
	local midString = "</p><p class=\"info\">"
	
	--Setup the hitpoints string
	local hitpointsString = ''
	for i = 1, utils.round(entry.Hitpoints / 50) do
		hitpointsString = hitpointsString .. '++'
	end
	
	--Setup the shield hitpoints string
	local ShieldhitpointsString = ''
	for i = 1, utils.round(entry.ShieldHitpoints / 50) do
		ShieldhitpointsString = ShieldhitpointsString .. '++'
	end
	
	local array    = {
		{ba.XSTR("Class", 888414), entry.Name},
		{ba.XSTR("Type", 888116), entry.Type},
		{ba.XSTR("Length", 888416), entry.Length},
		{ba.XSTR("Max Velocity", 888417), entry.Velocity .. ' (' .. entry.AfterburnerVelocity .. ba.XSTR(" m/s with afterburner", 888418) .. ')'},
		{ba.XSTR("Maneuverability", 888419), entry.Maneuverability},
		--{ba.XSTR("Armor", 888420), entry.Armor}, --Removed because it doesn't usually offer much useful information
		{ba.XSTR("Hull Strength", 888421), hitpointsString},
		{ba.XSTR("Shield Strength", 888422), ShieldhitpointsString},
		{ba.XSTR("Gun Mounts", 888423), entry.GunMounts},
		{ba.XSTR("Missile Banks", 888424), entry.MissileBanks},
		{ba.XSTR("Manufacturer", 888425), entry.Manufacturer}
	}
	
	for _, v in ipairs(array) do
		infoEl:AppendChild(self:BuildInfoTitle(v[1]))
		infoEl:AppendChild(self:BuildInfoStat(v[2]))
	end
	
	topics.shipselect.entryInfo:send({entry, infoEl})

end

function ShipSelectController:BuildInfoTitle(text)
	local element = self.document:CreateElement("p")
	element.inner_rml = text
	return element
end

function ShipSelectController:BuildInfoStat(text)
	local element = self.document:CreateElement("p")
	element:SetClass("info", true)
	element.inner_rml = text
	return element
end

function ShipSelectController:ChangeBriefState(state)
	if state == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	elseif state == 2 then
		--Do nothing because we're this is the current state!
	elseif state == 3 then
		if mn.isScramble() then
			ad.playInterfaceSound(10)
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_WEAPON_SELECTION"])
		end
	end
end

function ShipSelectController:DragOver(element, slot)
	self.replace = element
	self.activeSlot = slot
	element:SetPseudoClass("valid", false)
end

function ShipSelectController:DragNameOver(element, slot)
	self.NameReplace = element
	self.NameActiveSlot = slot
end

function ShipSelectController:UpdateSlot(slot)
	local slotInfo = loadoutHandler:GetShipLoadout(slot)
	
	local replace_el = self.document:GetElementById("slot_" .. slot)
	
	--If the slot doesn't exist then bail
	if not replace_el then
		return
	end
	
	self:ActivateSlot(slot)
	
	replace_el.first_child.next_sibling.inner_rml = slotInfo.Name
	
	if self.ships[slot] == slotInfo.ShipClassIndex then
		return
	end
	
	self.ships[slot] = slotInfo.ShipClassIndex
	
	local slotIcon = loadoutHandler:getEmptyWingSlotIcon()[2]
	if slotInfo.isDisabled then
		slotIcon = loadoutHandler:getEmptyWingSlotIcon()[1]
	end
	
	--Get the current ship in this slot
	local shipIndex = slotInfo.ShipClassIndex
	if shipIndex > 0 then
		local entry = loadoutHandler:GetShipInfo(shipIndex)
		if entry == nil then
			ba.error("Could not find " .. tb.ShipClasses[shipIndex].Name .. " in the loadout!")
		else
			if slotInfo.isShipLocked then
				slotIcon = entry.GeneratedIcon[5]
			else
				slotIcon = entry.GeneratedIcon[1]
			end
		end
	end
	
	self:UpdateSlotImage(replace_el, slotIcon)
end

function ShipSelectController:UpdateSlots()
	for i = 1, loadoutHandler:GetNumSlots() do
		self:UpdateSlot(i)
	end
end

function ShipSelectController:UpdatePool()
	local list = loadoutHandler:GetShipList()
	
	for i, v in pairs(list) do
		self:UpdatePoolCount(v.Name, loadoutHandler:GetShipPoolAmount(v.Index))
	end
end

function ShipSelectController:UpdatePoolCount(id, count)
	local parent = self.document:GetElementById(id)
	if not parent then
		return
	end
	local countEl = parent.first_child.first_child
	countEl.inner_rml = count
end

function ShipSelectController:UpdateSlotImage(element, img)
	local imgEl = self.document:CreateElement("img")
	imgEl:SetAttribute("src", img)

	element:RemoveChild(element.first_child)
	element:InsertBefore(imgEl, element.first_child)
	element:SetClass("drag", true)
	element:SetClass("button_3", true)
end

--entry is unreliable...?
function ShipSelectController:ClickOnSlot(entry, slot)
	local currentSlot = loadoutHandler:GetShipLoadout(slot)
	
	if currentSlot.ShipClassIndex > 0 then
		self:SelectEntry(loadoutHandler:GetShipInfo(currentSlot.ShipClassIndex), slot)
	end
end

function ShipSelectController:DragPoolEnd(element, entry, shipIndex)
	--No changes if wing positions are not locked!
	if ScpuiSystem:inMultiGame() and ui.MultiGeneral.getNetGame().Locked == false then
		return
	end
	
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		if ScpuiSystem:inMultiGame() then
			ui.ShipWepSelect.sendShipRequestPacket(2, 0, shipIndex, self.activeSlot, shipIndex)
			self.replace = nil
			return
		end
	
		--Get the pool amount of the ship we're dragging
		local count = loadoutHandler:GetShipPoolAmount(shipIndex)
		
		--If the pool count is 0 then abort!
		if count < 1 then
			self.replace = nil
			return
		end

		local targetSlot = loadoutHandler:GetShipLoadout(self.activeSlot)
		
		if targetSlot.isShipLocked then
			return
		end
		
		--If the target slot already has this ship, then abort!
		if targetSlot.ShipClassIndex == shipIndex then
			return
		end
		
		if count > 0 then
			if targetSlot.ShipClassIndex == -1 then
				loadoutHandler:TakeShipFromPool(shipIndex)
			else
				--Get the amount of the ship we're sending back
				local key = loadoutHandler:GetShipInfo(targetSlot.ShipClassIndex).Name
				self:UpdatePoolCount(key, loadoutHandler:GetShipPoolAmount(targetSlot.ShipClassIndex) + 1)

				loadoutHandler:TakeShipFromPool(shipIndex)
				loadoutHandler:ReturnShipToPool(self.activeSlot)
			end
			
			self:UpdatePoolCount(entry.Name, count - 1)
			
			local replace_el = self.document:GetElementById(self.replace.id)
			self:UpdateSlotImage(replace_el, element:GetAttribute("src"))
			
			loadoutHandler:SetFilled(self.activeSlot, true)
			
			--Now set the new ship and weapons
			loadoutHandler:AddShipToSlot(self.activeSlot, shipIndex)
			
			self.replace = nil
		end
	end
end

function ShipSelectController:DragSlotEnd(element, entry, slot)
	--No changes if wing positions are not locked!
	if ScpuiSystem:inMultiGame() and ui.MultiGeneral.getNetGame().Locked == false then
		return
	end
	
	if (self.replace ~= nil) and (self.activeSlot > 0) then		
		local targetSlot = loadoutHandler:GetShipLoadout(self.activeSlot)
		local currentSlot = loadoutHandler:GetShipLoadout(slot)
		
		if ScpuiSystem:inMultiGame() then
			ui.ShipWepSelect.sendShipRequestPacket(0, 0, slot, self.activeSlot, currentSlot.ShipClassIndex)
			self.replace = nil
			return
		end
		
		--If the target slot already has this ship, then abort!
		if targetSlot.ShipClassIndex == currentSlot.ShipClassIndex then
			return
		end
		
		--If the target slot has a ship in it then return it
		if targetSlot.ShipClassIndex > 0 then
			--Get the amount of the ship we're sending back
			local key = loadoutHandler:GetShipInfo(targetSlot.ShipClassIndex).Name
			self:UpdatePoolCount(key, loadoutHandler:GetShipPoolAmount(targetSlot.ShipClassIndex) + 1)
			loadoutHandler:ReturnShipToPool(self.activeSlot)
		end
		
		local replace_el = self.document:GetElementById(self.replace.id)
		self:UpdateSlotImage(replace_el, element.first_child:GetAttribute("src"))
		
		element.first_child:SetAttribute("src", loadoutHandler:getEmptyWingSlotIcon()[2])
		element:SetClass("drag", false)
		
		loadoutHandler:SetFilled(self.activeSlot, true)

		--Now set the new ship and weapons
		loadoutHandler:AddShipToSlot(self.activeSlot, currentSlot.ShipClassIndex)
		
		--empty the old slot
		loadoutHandler:TakeShipFromSlot(slot)
		
		self.replace = nil
		
	--If we're dragging into the pool
	elseif (self.replace ~= nil) and (self.activeSlot == 0) then			
		local sourceSlot = loadoutHandler:GetShipLoadout(slot)
		
		if ScpuiSystem:inMultiGame() then
			ui.ShipWepSelect.sendShipRequestPacket(0, 2, slot, sourceSlot.ShipClassIndex, sourceSlot.ShipClassIndex)
			self.replace = nil
			return
		end
		
		--If the target slot has a ship in it then return it
		if sourceSlot.ShipClassIndex > 0 then
			--Get the amount of the ship we're sending back
			local key = loadoutHandler:GetShipInfo(sourceSlot.ShipClassIndex).Name
			self:UpdatePoolCount(key, loadoutHandler:GetShipPoolAmount(sourceSlot.ShipClassIndex) + 1)
			loadoutHandler:ReturnShipToPool(slot)
		end
		element:SetClass("drag", false)
		
		element.first_child:SetAttribute("src", loadoutHandler:getEmptyWingSlotIcon()[2])
		loadoutHandler:TakeShipFromSlot(slot)
		
		self.replace = nil
	end
end

function ShipSelectController:DragNameEnd(element, slot)
	--No changes if not in multi
	if not ScpuiSystem:inMultiGame() then
		return
	end
	--No changes if wing positions are locked!
	if ui.MultiGeneral.getNetGame().Locked == true then
		return
	end
	
	if (self.NameReplace ~= nil) and (self.NameActiveSlot > 0) then		
		ui.ShipWepSelect.sendShipRequestPacket(1, 1, slot, self.NameActiveSlot, -1)
		self.NameReplace = nil
	end
end

function ShipSelectController:Show(text, title, buttons)
	--Create a simple dialog box with the text and title

	ScpuiSystem.data.memory.modelDraw.save = ScpuiSystem.data.memory.modelDraw.class
	ScpuiSystem.data.memory.modelDraw.class = nil
	
	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		dialog:escape("")
		for i = 1, #buttons do
			dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value, buttons[i].b_keypress)
		end
		dialog:show(self.document.context)
		:continueWith(function(response)
			ScpuiSystem.data.memory.modelDraw.class = ScpuiSystem.data.memory.modelDraw.save
			ScpuiSystem.data.memory.modelDraw.save = nil
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.document.context)
end

function ShipSelectController:reset_pressed(element)
	if self.enabled == true then
		ui.playElementSound(element, "click", "success")
		loadoutHandler:resetLoadout()
		self:ReloadList()
	end
end

function ShipSelectController:accept_pressed()

	if not topics.mission.commit:send(self) then
		return
	end
    
	--Apply the loadout
	loadoutHandler:SendAllToFSO_API()
	
	local errorValue = ui.Briefing.commitToMission()
	
	if errorValue == COMMIT_SUCCESS then
		--Save to the player file
		self.Commit = true
		loadoutHandler:SaveInFSO_API()
		--Cleanup
		if ScpuiSystem.data.memory.music_handle ~= nil and ScpuiSystem.data.memory.music_handle:isValid() then
			ScpuiSystem.data.memory.music_handle:close(true)
		end
		ScpuiSystem.data.memory.music_handle = nil
		ScpuiSystem.data.memory.current_music_file = nil
	end

end

function ShipSelectController:options_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function ShipSelectController:help_clicked(element)
    ui.playElementSound(element, "click", "success")
    
	self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

function ShipSelectController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
        --ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	--elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(3)
	--elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(1)
	end
end

function ShipSelectController:unload()
	
	loadoutHandler:saveCurrentLoadout()
	ScpuiSystem.data.memory.modelDraw.class = nil
	
	if self.Commit == true then
		loadoutHandler:unloadAll(true)
		ScpuiSystem.data.memory.drawBrMap = nil
		ScpuiSystem.data.memory.cutscenePlayed = nil
		ScpuiSystem:stopMusic()
	end
	
	topics.shipselect.unload:send(self)
end

function ShipSelectController:startMusic()
	local filename = ui.Briefing.getBriefingMusicName()

    if #filename <= 0 then
        return
    end

	if filename ~= ScpuiSystem.data.memory.current_music_file then
	
		if ScpuiSystem.data.memory.music_handle ~= nil and ScpuiSystem.data.memory.music_handle:isValid() then
			ScpuiSystem.data.memory.music_handle:close(true)
		end

		ScpuiSystem.data.memory.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
		ScpuiSystem.data.memory.music_handle:play(ad.MasterEventMusicVolume, true)
		ScpuiSystem.data.memory.current_music_file = filename
	end
end

function ShipSelectController:drawSelectModel()

	if ScpuiSystem.data.memory.modelDraw.class and ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then  --Haaaaaaacks

		--local thisItem = tb.ShipClasses(modelDraw.class)
		
		local modelView = ScpuiSystem.data.memory.modelDraw.element
		
		--If the modelView is not valid then abort this frame
		if not modelView then
			return
		end

		local modelLeft = modelView.parent_node.offset_left + modelView.offset_left --This is pretty messy, but it's functional
		local modelTop = modelView.parent_node.offset_top + modelView.parent_node.parent_node.offset_top + modelView.offset_top
		local modelWidth = modelView.offset_width
		local modelHeight = modelView.offset_height
		
		--This is just a multiplier to make the rendered model a little bigger
		--renderSelectModel() has forced centering, so we need to calculate
		--the screen size so we can move it slightly left and up while we
		--multiple it's size
		local val = 0.15
		local ratio = (gr.getScreenWidth() / gr.getScreenHeight()) * 2
		
		--Increase by percentage and move slightly left and up.
		modelLeft = modelLeft * (1 - (val/ratio))
		modelTop = modelTop * (1 - val)
		modelWidth = modelWidth * (1 + val)
		modelHeight = modelHeight * (1 + val)
		
		tb.ShipClasses[ScpuiSystem.data.memory.modelDraw.class]:renderSelectModel(ScpuiSystem.data.memory.modelDraw.start, modelLeft, modelTop, modelWidth, modelHeight, -1, 1.3)
		
		ScpuiSystem.data.memory.modelDraw.start = false
		
	end

end

function ShipSelectController:lock_pressed()
	ui.MultiGeneral.getNetGame().Locked = true
end

function ShipSelectController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function ShipSelectController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function ShipSelectController:InputFocusLost()
	--do nothing
end

function ShipSelectController:InputChange(event)
	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end
end

function ShipSelectController:updateLists()
	local chat = ui.MultiGeneral.getChat()
	
	local txt = ""
	for i = 1, #chat do
		local line = ""
		if chat[i].Callsign ~= "" then
			line = chat[i].Callsign .. ": " .. chat[i].Message
		else
			line = chat[i].Message
		end
		txt = txt .. ScpuiSystem:replaceAngleBrackets(line) .. "<br></br>"
	end
	self.chat_el.inner_rml = txt
	self.chat_el.scroll_top = self.chat_el.scroll_height
	
	if ui.MultiGeneral.getNetGame().Locked == true then
		self.document:GetElementById("lock_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("lock_btn"):SetPseudoClass("checked", false)
	end
	
	--Update the loadout from the network
	loadoutHandler:update()
	self:UpdatePool()
	self:UpdateSlots()
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
end

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then
		ShipSelectController:drawSelectModel()
	end
end, {}, function()
    return false
end)

return ShipSelectController
