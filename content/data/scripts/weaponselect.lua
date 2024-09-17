local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")
local loadoutHandler = require("loadouthandler")
local topics = require("ui_topics")

local WeaponSelectController = class()

ScpuiSystem.modelDraw = nil

function WeaponSelectController:init()
	loadoutHandler:init()
	ScpuiSystem.modelDraw = {}
	self.help_shown = false
	self.enabled = false
	self.ships = {}
	self.banks = {}
	self.activeSlots = {}
	self.currentShipIndex = nil
	self.selectedWeapon = ''
end

function WeaponSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.Commit = false
	self.aniEl = self.document:CreateElement("img")
	self.aniWepEl = self.document:CreateElement("ani")
	self.requiredWeps = {}
	ScpuiSystem.modelDraw.Weapons = {}
	ScpuiSystem.modelDraw.banks = {
		bank1 = self.document:GetElementById("primary_one"),
		bank2 = self.document:GetElementById("primary_two"),
		bank3 = self.document:GetElementById("primary_three"),
		bank4 = self.document:GetElementById("secondary_one"),
		bank5 = self.document:GetElementById("secondary_two"),
		bank6 = self.document:GetElementById("secondary_three"),
		bank7 = self.document:GetElementById("secondary_four")
	}
	self.secondaryAmountEls = {
		self.document:GetElementById("secondary_amount_one"),
		self.document:GetElementById("secondary_amount_two"),
		self.document:GetElementById("secondary_amount_three"),
		self.document:GetElementById("secondary_amount_four")
	}
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
	
	self.weapon3d, self.weaponEffect, self.icon3d = ui.ShipWepSelect.get3dWeaponChoices()
	
	self.overhead3d, self.overheadEffect = ui.ShipWepSelect.get3dOverheadChoices()
	
	--Get all the required weapons
	j = 1
	while (j < #tb.WeaponClasses) do
		if tb.WeaponClasses[j]:isWeaponRequired() then
			self.requiredWeps[#self.requiredWeps + 1] = tb.WeaponClasses[j].Name
		end
		j = j + 1
	end
	
	--Create the anim here so that it can be restarted with each new selection
	local aniWrapper = self.document:GetElementById("ship_view")
	aniWrapper:AppendChild(self.aniEl)

	local aniWrapper = self.document:GetElementById("weapon_view")
	aniWrapper:ReplaceChild(self.aniWepEl, aniWrapper.first_child)
	

	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", true)
	
	self.SelectedEntry = nil
	self.SelectedShip = nil
	
	self.enabled = self:BuildWings()
	
	for i = 1, loadoutHandler:GetNumSlots() do
		table.insert(self.ships, 0)
	end
	
	if ScpuiSystem:inMultiGame() then
		self.document:GetElementById("chat_wrapper"):SetClass("hidden", false)
		self.document:GetElementById("c_panel_wrapper_multi"):SetClass("hidden", false)
		self.document:GetElementById("c_panel_wrapper"):SetClass("hidden", true)
		self.document:GetElementById("copy_to_wing_panel"):SetClass("hidden", true)
		self:updateLists()
		ui.MultiGeneral.setPlayerState()
	end
	
	topics.weaponselect.initialize:send(self)
	
	--Only create entries if there are any to create
	if loadoutHandler:GetNumPrimaryWeapons() > 0 and self.enabled == true then
		self:CreateEntries(loadoutHandler:GetPrimaryWeaponList())
	end
	if loadoutHandler:GetNumSecondaryWeapons() > 0 and self.enabled == true then
		self:CreateEntries(loadoutHandler:GetSecondaryWeaponList())
	end
	
	if self.enabled == true then
		self:SelectInitialItems()
	end
	
	self:startMusic()

end

function WeaponSelectController:BuildWings()

	local slotNum = 1
	local wrapperEl = self.document:GetElementById("wings_wrapper")
	ScpuiSystem:ClearEntries(wrapperEl)
	
	--Check that we actually have wing slots
	if loadoutHandler.GetNumWings() <= 0 then
		ba.warning("Mission has no loadout wings! Check the loadout in FRED!")
		return false
	end

	for i = 1, loadoutHandler.GetNumWings(), 1 do
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
		nameEl.inner_rml = loadoutHandler:GetWingName(i)
		wingEl:AppendChild(nameEl)
		
		--Check that the wing actually has valid ship slots
		if loadoutHandler:GetNumWingSlots(i) <= 0 then
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
			local slotIcon = loadoutHandler:getEmptyWingSlot()[2]
			if slotInfo.isDisabled then
				slotIcon = loadoutHandler:getEmptyWingSlot()[1]
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
				if slotInfo.isPlayer then
					slotIcon = entry.GeneratedIcon[1]
				elseif slotInfo.isWeaponLocked then
					slotIcon = entry.GeneratedIcon[4]
				elseif slotInfo.isShipLocked then
					slotIcon = entry.GeneratedIcon[6]
				else
					slotIcon = entry.GeneratedIcon[1]
				end
			end
			
			local slotImg = self.document:CreateElement("img")
			slotImg:SetAttribute("src", slotIcon)
			slotEl:AppendChild(slotImg)
			
			local slotName = self.document:CreateElement("div")
			slotName.inner_rml = slotInfo.Name
			slotName.id = "callsign_" .. slotNum
			slotName:SetClass("slot_name", true)
			slotEl:AppendChild(slotName)
			
			--This is here so that the event listeners use the correct slot index!
			local index = slotNum
			
			slotEl.id = "slot_" .. slotNum

			self:ActivateSlot(index)
			
			slotNum = slotNum + 1
		end
	end
	
	return true

end

function WeaponSelectController:ActivateSlot(slot)
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

	if slotInfo.ShipClassIndex > 0 then
		if not slotInfo.isShipLocked then
			
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
			self:ClickOnSlot(slot)
		end)
	end
end

function WeaponSelectController:SelectInitialItems()

	local selectSlot = 0
	for i = 1, loadoutHandler:GetNumSlots() do
		if loadoutHandler:GetShipLoadout(i).ShipClassIndex > 0 then
			selectSlot = i
			break
		end
	end
	
	if selectSlot > 0 then
		local ship = loadoutHandler:GetShipLoadout(selectSlot)

		self:SelectShip(ship.ShipClassIndex, ship.Name, selectSlot)
		
		if loadoutHandler:GetNumPrimaryWeapons() > 0 then
			self:SelectEntry(loadoutHandler:GetPrimaryWeaponList()[1])
		end
		
		if loadoutHandler:GetNumSecondaryWeapons() > 0 then
			self:SelectEntry(loadoutHandler:GetSecondaryWeaponList()[1])
		end
	end
	
end

function WeaponSelectController:ReloadList()

	ScpuiSystem.modelDraw.class = nil
	ScpuiSystem.modelDraw.OverheadClass = nil
	local list_items_el = self.document:GetElementById("primary_icon_list_ul")
	ScpuiSystem:ClearEntries(list_items_el)
	local list_items_el = self.document:GetElementById("secondary_icon_list_ul")
	ScpuiSystem:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self.SelectedShip = nil
	if loadoutHandler:GetNumPrimaryWeapons() > 0 then
		self:CreateEntries(loadoutHandler:GetPrimaryWeaponList())
	end
	if loadoutHandler:GetNumSecondaryWeapons() > 0 then
		self:CreateEntries(loadoutHandler:GetSecondaryWeaponList())
	end
	self:BuildWings()
	self:SelectInitialItems()
	self:UpdateUiElements()
end

function WeaponSelectController:ChangeIconAvailability(shipIndex)

	for i, v in pairs(loadoutHandler:GetPrimaryWeaponList()) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(v.Index) then
			iconEl:SetClass("drag", true)
			if self.icon3d then
				--iconEl:SetClass("available", true)
				--iconEl:SetClass("locked", false)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[1])
		else
			iconEl:SetClass("drag", false)
			if self.icon3d then
				--iconEl:SetClass("available", false)
				--iconEl:SetClass("locked", true)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[6])
		end
	end
	
	for i, v in pairs(loadoutHandler:GetSecondaryWeaponList()) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(v.Index) then
			iconEl:SetClass("drag", true)
			if self.icon3d then
				--iconEl:SetClass("available", true)
				--iconEl:SetClass("locked", false)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[1])
		else
			iconEl:SetClass("drag", false)
			if self.icon3d then
				--iconEl:SetClass("available", false)
				--iconEl:SetClass("locked", true)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[6])
		end
	end

end

function WeaponSelectController:CreateEntryItem(entry, idx)

	local li_el = self.document:CreateElement("li")
	local iconWrapper = self.document:CreateElement("div")
	iconWrapper.id = entry.Name
	iconWrapper:SetClass("select_item", true)
	
	li_el:AppendChild(iconWrapper)
	
	local countEl = self.document:CreateElement("div")
	countEl.inner_rml = loadoutHandler:GetWeaponPoolAmount(entry.Index)
	countEl:SetClass("amount", true)
	countEl.id = entry.Name .. "_count"
	
	iconWrapper:AppendChild(countEl)
	
	--local aniWrapper = self.document:GetElementById(entry.Icon)
	local iconEl = self.document:CreateElement("img")
	iconEl:SetAttribute("src", entry.GeneratedIcon[1])
	iconWrapper:AppendChild(iconEl)
	--iconWrapper:ReplaceChild(iconEl, iconWrapper.first_child)
	li_el.id = entry.Name

	--iconEl:SetClass("shiplist_element", true)
	iconEl:SetClass("button_3", true)
	iconEl:SetClass("icon", true)
	iconEl:SetClass("drag", true)
	iconEl:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	iconEl:AddEventListener("dragend", function(_, _, _)
		self:DragPoolEnd(iconEl, entry, entry.Index)
	end)
	iconEl:AddEventListener("dragstart", function(_,_,_)
		self.heldWeapon = entry.Index
		self.drag = true
	end)
	entry.key = li_el.id

	return li_el
end

function WeaponSelectController:CreateEntries(list)

	local list_names_el = nil

	if tb.WeaponClasses[list[1].Index]:isPrimary() then
		list_names_el = self.document:GetElementById("primary_icon_list_ul")
	elseif tb.WeaponClasses[list[1].Index]:isSecondary() then
		list_names_el = self.document:GetElementById("secondary_icon_list_ul")
	end
	
	if list_names_el ~= nil then
		ScpuiSystem:ClearEntries(list_names_el)

		for i, v in pairs(list) do
			list_names_el:AppendChild(self:CreateEntryItem(v, i))
		end
	end
end

function WeaponSelectController:BreakoutReader()
	local text = topics.weapons.description:send(tb.WeaponClasses[self.selectedWeapon])
	local title = "<span style=\"color:white;\">" .. topics.weapons.name:send(tb.WeaponClasses[self.selectedWeapon]) .. "</span>"
	local buttons = {}
	buttons[1] = {
		b_type = dialogs.BUTTON_TYPE_POSITIVE,
		b_text = ba.XSTR("Close", 888110),
		b_value = "",
		b_keypress = string.sub(ba.XSTR("Close", 888110), 1, 1)
	}
	self:Show(text, title, buttons)
end

function WeaponSelectController:SelectEntry(entry, slot)
	if entry ~= nil then
		ScpuiSystem.modelDraw.Hover = slot
		if entry.key ~= self.SelectedEntry then
			
			self.SelectedEntry = entry.key
			self.selectedWeapon = entry.Name
			
			self:HighlightWeapon()
			
			self:BuildInfo(entry)
			
			if self.weapon3d or entry.Anim == nil then
				ScpuiSystem.modelDraw.class = entry.Index
				ScpuiSystem.modelDraw.element = self.document:GetElementById("weapon_view_window")
				ScpuiSystem.modelDraw.start = true
				
				self:refreshOverheadSlot()
			else
				--the anim is already created so we only need to remove and reset the src
				self.aniWepEl:RemoveAttribute("src")
				self.aniWepEl:SetAttribute("src", entry.Anim)
			end
			
		end
	end
end

function WeaponSelectController:SelectAssignedEntry(element, slot)

	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	local weapon = ship.Weapons[slot]
	
	local selectedEntry = nil
	
	if slot < 4 then
		selectedEntry = loadoutHandler:GetPrimaryInfo(weapon)
	else
		selectedEntry = loadoutHandler:GetSecondaryInfo(weapon)
	end
	
	self:SelectEntry(selectedEntry, slot)

end

function WeaponSelectController:HighlightWeapon()
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)

	for i, v in pairs(loadoutHandler:GetPrimaryWeaponList()) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if tb.ShipClasses[ship.ShipClassIndex]:isWeaponAllowedOnShip(v.Index) then
			if v.key == self.SelectedEntry then
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
	end
	
	for i, v in pairs(loadoutHandler:GetSecondaryWeaponList()) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if tb.ShipClasses[ship.ShipClassIndex]:isWeaponAllowedOnShip(v.Index) then
			if v.key == self.SelectedEntry then
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
	end
	
	for i, v in pairs(ScpuiSystem.modelDraw.banks) do
		local index = string.sub(i, -1)

		local weapon = ship.Weapons[index]
		if weapon ~= nil and weapon > 0 then
			local thisEntry = loadoutHandler:GetWeaponInfo(weapon)
			if v.first_child ~= nil then
				if tb.WeaponClasses[weapon].Name == self.SelectedEntry then
					v.first_child:SetAttribute("src", thisEntry.GeneratedIcon[3])
				else
					v.first_child:SetAttribute("src", thisEntry.GeneratedIcon[1])
				end
			end
		end
	end

end

function WeaponSelectController:HighlightShip(slot)
	
	for i = 1, loadoutHandler:GetNumSlots(), 1 do
		local slotEl = self.document:GetElementById("slot_" .. i)		
		local ship = loadoutHandler:GetShipLoadout(i)
		local shipIdx = ship.ShipClassIndex
		local thisEntry = loadoutHandler:GetShipInfo(shipIdx)
		if thisEntry ~= nil then
			local icon = nil
			if slot == i then
				if ship.isWeaponLocked then
					icon = thisEntry.GeneratedIcon[6] -- could be 4 (orange)
				elseif ship.isShipLocked then
					icon = thisEntry.GeneratedIcon[6]
				else
					icon = thisEntry.GeneratedIcon[3]
				end
			else
				if ship.isWeaponLocked then
					icon = thisEntry.GeneratedIcon[5] -- could be 4 (orange)
				elseif ship.isShipLocked then
					icon = thisEntry.GeneratedIcon[5]
				else
					icon = thisEntry.GeneratedIcon[1]
				end
			end
			
			slotEl.first_child:SetAttribute("src", icon)
			
		end
	end
	
	return true
				
end

function WeaponSelectController:ClickOnSlot(slot)
	local shipInfo = loadoutHandler:GetShipLoadout(slot)
	
	self:SelectShip(shipInfo.ShipClassIndex, shipInfo.Name, slot)
end

function WeaponSelectController:SelectShip(shipIndex, callsign, slot)

	if callsign ~= self.SelectedShip then
		
		self.SelectedShip = callsign
		self.currentShipSlot = slot
		self.currentShipIndex = shipIndex
		
		self.document:GetElementById("ship_name").inner_rml = callsign
		
		local thisEntry = loadoutHandler:GetShipInfo(shipIndex)

		--If we have an error highlighting the ship then the rest will fail, so bail
		if self:HighlightShip(slot) == false then
			return
		end
		
		local overhead = thisEntry.Overhead

		self:BuildWeaponSlots(shipIndex)
		
		self:ChangeIconAvailability(shipIndex)
		
		self:HighlightWeapon()
		
		topics.weaponselect.selectShip:send({self, shipIndex})
		
		if self.overhead3d or overhead == nil then
			ScpuiSystem.modelDraw.OverheadClass = shipIndex
			ScpuiSystem.modelDraw.OverheadElement = self.document:GetElementById("ship_view_wrapper")
			ScpuiSystem.modelDraw.overheadEffect = self.overheadEffect
			
			self:refreshOverheadSlot()
		else
			--the anim is already created so we only need to remove and reset the src
			self.aniEl:RemoveAttribute("src")
			self.aniEl:SetAttribute("src", overhead)
		end
		
	end

end

function WeaponSelectController:ClearWeaponSlots()
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank1)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank2)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank3)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank4)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank5)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank6)
	ScpuiSystem:ClearEntries(ScpuiSystem.modelDraw.banks.bank7)
	
	for i = 1, loadoutHandler:GetMaxBanks() do
		table.insert(self.banks, 0)
	end
	
	for i, v in pairs(ScpuiSystem.modelDraw.banks) do
		v:SetClass("slot_3d", false)
		v:SetClass("button_3", false)
		v:SetClass("weapon_locked", false)
	end
	
	for i, v in pairs(self.secondaryAmountEls) do
		v.inner_rml = ""
	end
end

function WeaponSelectController:BuildWeaponSlots(ship)

	if not ship then
		return
	end

	if self.currentShipIndex ~= ship then
		self:ClearWeaponSlots()
	end

	if tb.ShipClasses[ship].numPrimaryBanks > 0 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank1, 1)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank1:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numPrimaryBanks > 1 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank2, 2)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank2:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numPrimaryBanks > 2 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank3, 3)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank3:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numSecondaryBanks > 0 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank4, 4)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank4:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numSecondaryBanks > 1 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank5, 5)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank5:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numSecondaryBanks > 2 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank6, 6)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank6:SetClass("slot_3d", true)
		end
	end
	
	if tb.ShipClasses[ship].numSecondaryBanks > 3 then
		self:BuildSlot(ScpuiSystem.modelDraw.banks.bank7, 7)
		if self.overhead3d then
			ScpuiSystem.modelDraw.banks.bank7:SetClass("slot_3d", true)
		end
	end

end

function WeaponSelectController:BuildSlot(parentEl, bank)
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	
	--Maybe show slot as locked
	if ship.isWeaponLocked == true then
		parentEl:SetClass("weapon_locked", true)
	else
		parentEl:SetClass("weapon_locked", false)
	end
	
	--Get the weapon currently loaded in the slot
	local weapon = ship.Weapons[bank] or 0
	local amount = ship.Amounts[bank] or 0
	if amount < 1 then amount = "" end
	if bank > 3 then
		self.secondaryAmountEls[bank - 3].inner_rml = amount
	end
	
	if self.banks[bank] == weapon then
		return
	end
	
	self.banks[bank] = weapon
	
	ScpuiSystem:ClearEntries(parentEl)
	
	local slotImg = self.document:CreateElement("img")
	
	local slotIcon = nil
	if weapon > 0 then
		if ship.isWeaponLocked == false then
			slotIcon = loadoutHandler:GetWeaponInfo(weapon).GeneratedIcon[1]
			slotImg:SetClass("drag", true)
		else
			slotIcon = loadoutHandler:GetWeaponInfo(weapon).GeneratedIcon[4]
		end
		--slotIcon = tb.WeaponClasses[weapon].SelectIconFilename
		slotImg:SetClass("button_3", true)
		slotImg:SetAttribute("src", slotIcon)
		parentEl:AppendChild(slotImg)
	end
end

function WeaponSelectController:BuildInfo(entry)

	self.document:GetElementById("weapon_name").inner_rml = entry.Title
	
	local infoEl = self.document:GetElementById("weapon_stats")
	
	ScpuiSystem:ClearEntries(infoEl)
	
    local weapon = tb.WeaponClasses[entry.Index]
    ba.warning("Weapon reported as " .. weapon.Name)
	local power = round(entry.Power)
	local rof = entry.RoF
	local velocity = round(entry.Velocity)
	local range = round(1 * entry.Range)
	local cargoSize = entry.CargoSize
	
	local desc_el = self.document:CreateElement("p")
	desc_el.inner_rml = entry.Description
	desc_el:SetClass("white", true)
	
	local stats1_el = self.document:CreateElement("p")
	stats1_el.inner_rml = ba.XSTR("Velocity", 888430) .. ": " .. velocity .. "m/s, " .. ba.XSTR("Range", 888431) .. ": " .. range .. "m"
	stats1_el:SetClass("green", true)
	
	local stats2_el = self.document:CreateElement("p")
	stats2_el:SetClass("info", true)
    if weapon.SwarmInfo then
        local isSwarmer, swarmcount, swarmwait = weapon.SwarmInfo
        ba.warning("Swarm weapon " .. weapon.Name .. "detected with swarmcount" .. swarmcount)
    end
	local volley = entry.VolleySize or 1
	if entry.Type == "secondary" and entry.FireWait >= 1 then
		local hull = round(entry.HullDamage * volley)
		local shield = round(entry.ShieldDamage * volley)
		local subsystem = round(entry.SubsystemDamage * volley)
		local label = (volley == 1) and ba.XSTR("Damage per missile", 888432) or ba.XSTR("Damage per volley", 888433)
		stats2_el.inner_rml = label .. ": " .. hull .. " " .. ba.XSTR("Hull", 888434) .. ", " .. shield .. " " .. ba.XSTR("Shield", 888435) .. ", " .. subsystem .. " " .. ba.XSTR("Subsystem", 888436)
	else
		local hull = round(entry.HullDamage * volley / entry.FireWait)
		local shield = round(entry.ShieldDamage * volley / entry.FireWait)
		local subsystem = round(entry.SubsystemDamage * volley / entry.FireWait)
		stats2_el.inner_rml = ba.XSTR("Damage per second", 888437) .. ": " .. hull .. " " .. ba.XSTR("Hull", 888434) .. ", " .. shield .. " " .. ba.XSTR("Shield", 888435) .. ", " .. subsystem .. " " .. ba.XSTR("Subsystem", 888436)
	end
	stats2_el:SetClass("red", true)
	
	local stats3_el = self.document:CreateElement("p")
	stats3_el:SetClass("info", true)
	if entry.Type == "secondary" then
		stats3_el.inner_rml = ba.XSTR("Cargo Size", 888558) .. ": " .. cargoSize .. ", " .. ba.XSTR("Rate of Fire", 888443) .. ": " .. rof .. "/s"
	else
		stats3_el.inner_rml = ba.XSTR("Power Use", 888441) .. ": " .. power .. ba.XSTR("W", 888442) .. ", " .. ba.XSTR("Rate of Fire", 888443) .. ": " .. rof .. "/s"
	end
	stats3_el:SetClass("blue", true)
	
	infoEl:AppendChild(desc_el)
	infoEl:AppendChild(stats1_el)
	infoEl:AppendChild(stats2_el)
	infoEl:AppendChild(stats3_el)
	
	topics.weaponselect.entryInfo:send({entry, infoEl})

end

function WeaponSelectController:ChangeBriefState(state)
	if state == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	elseif state == 2 then
		if mn.isScramble() then
			ad.playInterfaceSound(10)
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_SHIP_SELECTION"])
		end
	elseif state == 3 then
		--Do nothing because we're this is the current state!
	end
end

function WeaponSelectController:DragDrop(element, slot)
	self.replace = element
	self.activeSlot = slot
	element:SetPseudoClass("valid", false)
	element:SetPseudoClass("invalid", false)
end

function WeaponSelectController:DragOver(element, slot)
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	local amount = ship.Weapons[slot]
	
	if not loadoutHandler:ShipHasBank(ship.ShipClassIndex, slot) then
		return
	end
	
	local allowed = false
	
	if self.drag and not ship.isWeaponLocked then
		if loadoutHandler:IsWeaponAllowedInBank(ship.ShipClassIndex, self.heldWeapon, slot) then
			allowed = true
		end
	end

	if allowed then
		element:SetPseudoClass("valid", true)
		if amount ~= nil then
			if amount > 0 then
				ScpuiSystem.modelDraw.Hover = slot
			end
		end
	else
		element:SetPseudoClass("invalid", true)
	end
end

function WeaponSelectController:DragSlotStart(element, slot)
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	self.heldWeapon = ship.Weapons[slot]
	self.drag = true
end

function WeaponSelectController:DragOut(element, slot)
	ScpuiSystem.modelDraw.Hover = -1
	element:SetPseudoClass("valid", false)
	element:SetPseudoClass("invalid", false)
end

function WeaponSelectController:ApplyWeaponToSlot(parentEl, slot, bank, weapon)

	local entry = loadoutHandler:GetWeaponInfo(weapon)
	local slotIcon = nil
	slotIcon = entry.GeneratedIcon[1]
	if parentEl.first_child == nil then
		local slotEl = self.document:CreateElement("img")
		parentEl:AppendChild(slotEl)
	end
	parentEl.first_child:SetAttribute("src", slotIcon)
	parentEl.first_child:SetClass("drag", true)

end

function WeaponSelectController:EmptySlot(element, slot)
	element:RemoveChild(element.first_child)
	if slot > 3 then
		self:UpdateSecondaryCount(slot)
	end
end

function WeaponSelectController:UpdateShipSlot(slot)
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
	
	local slotIcon = loadoutHandler:getEmptyWingSlot()[2]
	if slotInfo.isDisabled then
		slotIcon = loadoutHandler:getEmptyWingSlot()[1]
	end
	
	--Get the current ship in this slot
	local shipIndex = slotInfo.ShipClassIndex
	if shipIndex > 0 then
		local entry = loadoutHandler:GetShipInfo(shipIndex)
		if entry == nil then
			ba.error("Could not find " .. tb.ShipClasses[shipIndex].Name .. " in the loadout!")
		end
		if slotInfo.isShipLocked then
			slotIcon = entry.GeneratedIcon[5]
		else
			slotIcon = entry.GeneratedIcon[1]
		end
	end
	
	self:UpdateSlotImage(replace_el, slotIcon)
end

function WeaponSelectController:UpdateShipSlots()
	for i = 1, loadoutHandler:GetNumSlots() do
		self:UpdateShipSlot(i)
	end
end

function WeaponSelectController:UpdateAllPoolCounts()
	local primaryList = loadoutHandler:GetPrimaryWeaponList()
	for i = 1, #primaryList do
		self:UpdatePoolCount(primaryList[i])
	end
	local secondaryList = loadoutHandler:GetSecondaryWeaponList()
	for i = 1, #secondaryList do
		self:UpdatePoolCount(secondaryList[i])
	end
end

function WeaponSelectController:UpdateSlotImage(element, img)
	local imgEl = self.document:CreateElement("img")
	imgEl:SetAttribute("src", img)

	element:RemoveChild(element.first_child)
	element:InsertBefore(imgEl, element.first_child)
	element:SetClass("button_3", true)
end

function WeaponSelectController:UpdatePoolCount(data)
	local countEl = self.document:GetElementById(data.key .. "_count")
	
	if countEl == nil then return end

	countEl.inner_rml = loadoutHandler:GetWeaponPoolAmount(data.Index)
end

function WeaponSelectController:UpdateUiElements()
	self:UpdateAllPoolCounts()
	if self.currentShipSlot == nil then
		return
	end
	self:UpdateAllSecondaryCounts()
	self:BuildWeaponSlots(loadoutHandler:GetShipLoadout(self.currentShipSlot).ShipClassIndex)
	self:refreshOverheadSlot()
end

function WeaponSelectController:UpdateAllSecondaryCounts()
	for i = 1, #self.secondaryAmountEls do
		local bank = i + loadoutHandler:GetMaxPrimaries()
		
		self:UpdateSecondaryCount(bank)
	end
end

function WeaponSelectController:UpdateSecondaryCount(bank)
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	local amount = ship.Amounts[bank]
	
	if amount == nil or amount < 1 then
		amount = ""
	end
	
	local element = self.secondaryAmountEls[bank - 3]
	element.inner_rml = amount
end

function WeaponSelectController:DragPoolEnd(element, entry, weaponIndex)
	self.heldWeapon = nil
	
	--No changes if wing positions are not locked!
	if ScpuiSystem:inMultiGame() and ui.MultiGeneral.getNetGame().Locked == false then
		return
	end
	
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		
		--Get the slot information: ship, weapon, and amount
		local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
		local shipIdx = ship.ShipClassIndex 
		local slotWeapon = ship.Weapons[self.activeSlot]
		local slotAmount = ship.Amounts[self.activeSlot]
		
		if ScpuiSystem:inMultiGame() then
			ui.ShipWepSelect.sendWeaponRequestPacket(0, self.activeSlot, weaponIndex, 0, self.currentShipSlot)
			self.replace = nil
			return
		end
	
		--Get the amount of the weapon we're dragging
		local count = loadoutHandler:GetWeaponPoolAmount(weaponIndex)

		--If the pool count is 0 then abort!
		if count < 1 then
			self.replace = nil
			return
		end
		
		--If the ship is weapon locked then abort!
		if ship.isWeaponLocked then
			self.replace = nil
			return
		end
		
		--If the slot can't accept the weapon then abort!
		if not loadoutHandler:IsWeaponAllowedInBank(shipIdx, weaponIndex, self.activeSlot) then
			self.replace = nil
			text = ba.XSTR("That weapon slot can't accept that weapon type", 888444)
			local title = ""
			local buttons = {}
			buttons[1] = {
				b_type = dialogs.BUTTON_TYPE_POSITIVE,
				b_text = ba.XSTR("Okay", 888290),
				b_value = "",
				b_keypress = string.sub(ba.XSTR("Ok", 888286), 1, 1)
			}
			
			self:Show(text, title, buttons)
			return
		end
		
		--If the slot already has that weapon then abort!
		if weaponIndex == slotWeapon then
			self.replace = nil
			return
		end
		
		--If slot doesn't exist on current ship then abort!
		if not loadoutHandler:ShipHasBank(shipIdx, self.activeSlot) then
			self.replace = nil
			return
		end
		
		if count > 0 then
		
			--return weapons to pool if appropriate
			loadoutHandler:EmptyWeaponBank(self.currentShipSlot, self.activeSlot)
			
			--Apply to the actual loadout
			loadoutHandler:AddWeaponToBank(self.currentShipSlot, self.activeSlot, weaponIndex)
		
			self:ApplyWeaponToSlot(self.replace, self.currentShipSlot, self.activeSlot, weaponIndex)
			
			self.replace = nil
		end
		
		self:UpdateUiElements()
	end
end

function WeaponSelectController:DragSlotEnd(element, slot)
	self.heldWeapon = nil
	
	--No changes if wing positions are not locked!
	if ScpuiSystem:inMultiGame() and ui.MultiGeneral.getNetGame().Locked == false then
		return
	end
	
	if (self.replace ~= nil) and (self.activeSlot > -1) then
	
		local dropSlot = self.activeSlot
		
		--Get the slot information of what's being dragged: ship, weapon, and amount
		local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
		local shipIdx = ship.ShipClassIndex 
		local slotWeapon = ship.Weapons[slot]
		local slotAmount = ship.Amounts[slot]
		
		if ScpuiSystem:inMultiGame() then
			local wepIdx = slotWeapon
			if dropSlot > 0 then
				wepIdx = 0
			end
			ui.ShipWepSelect.sendWeaponRequestPacket(slot, self.activeSlot, 0, wepIdx, self.currentShipSlot)
			self.replace = nil
			return
		end
		
		--If the ship is weapon locked then abort!
		if ship.isWeaponLocked then
			self.replace = nil
			return
		end
		
		--Get the slot information of what's being dropped onto: weapon, and amount
		if dropSlot > 0 then
			local activeWeapon = ship.Weapons[dropSlot]
			local activeAmount = ship.Amounts[dropSlot]
		else
			--If we're just returning something to the pool then empty the slot and abort!
			loadoutHandler:EmptyWeaponBank(self.currentShipSlot, slot)
			self:EmptySlot(element, slot)
			
			self.replace = nil
			self:UpdateUiElements()
			return
		end
		
		--If the slot can't accept the weapon then abort!
		if not loadoutHandler:IsWeaponAllowedInBank(shipIdx, slotWeapon, dropSlot) then
			self.replace = nil
			text = ba.XSTR("That weapon slot can't accept that weapon type", 888444)
			local title = ""
			local buttons = {}
			buttons[1] = {
				b_type = dialogs.BUTTON_TYPE_POSITIVE,
				b_text = ba.XSTR("Okay", 888290),
				b_value = "",
				b_keypress = string.sub(ba.XSTR("Ok", 888286), 1, 1)
			}
			
			self:Show(text, title, buttons)
			return
		end
		
		--If the slot already has that weapon then abort!
		if activeWeapon == slotWeapon then
			self.replace = nil
			return
		end

		--If slot doesn't exist on current ship then abort!
		if not loadoutHandler:ShipHasBank(shipIdx, dropSlot) then
			self.replace = nil
			return
		end
		
		--If what is being dragged has an amount greater than 0
		if slotAmount > 0 then
		
			--return weapons to pool if appropriate
			loadoutHandler:EmptyWeaponBank(self.currentShipSlot, dropSlot)
			loadoutHandler:EmptyWeaponBank(self.currentShipSlot, slot)
			
			--Apply to the actual loadout
			loadoutHandler:AddWeaponToBank(self.currentShipSlot, dropSlot, slotWeapon, slotAmount)
			
			self:EmptySlot(element, slot)
			self:ApplyWeaponToSlot(self.replace, self.currentShipSlot, dropSlot, slotWeapon)
			
			self.replace = nil
		end
		
		self:UpdateUiElements()
	end		
end

function WeaponSelectController:CopyToWing()
	if self.enabled == true then
		loadoutHandler:CopyToWing(self.currentShipSlot)
		self:UpdateUiElements()
	end
end

function WeaponSelectController:Show(text, title, buttons)
	--Create a simple dialog box with the text and title

	currentDialog = true
	ScpuiSystem.modelDraw.save = ScpuiSystem.modelDraw.class
	ScpuiSystem.modelDraw.class = nil
	ScpuiSystem.modelDraw.OverheadSave = ScpuiSystem.modelDraw.OverheadClass
	ScpuiSystem.modelDraw.OverheadClass = nil
	
	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		dialog:escape("")
		for i = 1, #buttons do
			dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value, buttons[i].b_keypress)
		end
		dialog:show(self.document.context)
		:continueWith(function(response)
			ScpuiSystem.modelDraw.class = ScpuiSystem.modelDraw.save
			ScpuiSystem.modelDraw.save = nil
			ScpuiSystem.modelDraw.OverheadClass = ScpuiSystem.modelDraw.OverheadSave
			ScpuiSystem.modelDraw.OverheadSave = nil
        --do nothing
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.document.context)
end

function WeaponSelectController:reset_pressed(element)
    if self.enabled == true then
		ui.playElementSound(element, "click", "success")
		loadoutHandler:resetLoadout()
		self:ReloadList()
	end
end

function WeaponSelectController:accept_pressed()

	if not topics.mission.commit:send(self) then
		return
	end

	--Apply the loadout
	loadoutHandler:SendAllToFSO_API()
    
	local errorValue = ui.Briefing.commitToMission(true)
	
	if errorValue == COMMIT_SUCCESS then
		--Save to the player file
		self.Commit = true
		loadoutHandler:SaveInFSO_API()
		--Cleanup
		text = nil
		if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
			ScpuiSystem.music_handle:close(true)
		end
		ScpuiSystem.music_handle = nil
		ScpuiSystem.current_played = nil
	end

end

function WeaponSelectController:options_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function WeaponSelectController:help_clicked(element)
    ui.playElementSound(element, "click", "success")
    
	self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

function WeaponSelectController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	end
end

function WeaponSelectController:unload()
	
	loadoutHandler:saveCurrentLoadout()
	ScpuiSystem.modelDraw.class = nil
	
	if self.Commit == true then
		ScpuiSystem.drawBrMap = nil
		ScpuiSystem.cutscenePlayed = nil
		loadoutHandler:unloadAll(true)
		ScpuiSystem:stopMusic()
	end
	
end

function WeaponSelectController:startMusic()
	local filename = ui.Briefing.getBriefingMusicName()

    if #filename <= 0 then
        return
    end
	
	if filename ~= ScpuiSystem.current_played then
	
		if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
			ScpuiSystem.music_handle:close(true)
		end

		ScpuiSystem.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
		ScpuiSystem.music_handle:play(ad.MasterEventMusicVolume, true)
		ScpuiSystem.current_played = filename
	end
end

function WeaponSelectController:drawSelectModel()

	if ScpuiSystem.modelDraw.class and (ba.getCurrentGameState().Name == "GS_STATE_WEAPON_SELECT") and (ScpuiSystem.modelDraw.element ~= nil) then  --Haaaaaaacks
		
		--local thisItem = tb.ShipClasses(modelDraw.class)
		modelView = ScpuiSystem.modelDraw.element	
		local modelLeft = modelView.parent_node.offset_left + modelView.offset_left --This is pretty messy, but it's functional
		local modelTop = modelView.parent_node.offset_top + modelView.parent_node.parent_node.offset_top + modelView.offset_top
		local modelWidth = modelView.offset_width
		local modelHeight = modelView.offset_height
		
		--This is just a multipler to make the rendered model a little bigger
		--renderSelectModel() has forced centering, so we need to calculate
		--the screen size so we can move it slightly left and up while it
		--multiple it's size
		local val = -0.3
		local ratio = (gr.getScreenWidth() / gr.getScreenHeight()) * 2
		
		--Increase by percentage and move slightly left and up.
		modelLeft = modelLeft * (1 - (val/ratio))
		modelTop = modelTop * (1 - val)
		modelWidth = modelWidth * (1 + val)
		modelHeight = modelHeight * (1 + val)
		
		tb.WeaponClasses[ScpuiSystem.modelDraw.class]:renderSelectModel(ScpuiSystem.modelDraw.start, modelLeft, modelTop, modelWidth, modelHeight, -1, 1.3)
		
		ScpuiSystem.modelDraw.start = false
		
	end

end

function WeaponSelectController:refreshOverheadSlot()
	if self.overhead3d or overhead == nil then
		local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
		ScpuiSystem.modelDraw.Weapons = ship.Weapons
	end
end

function WeaponSelectController:drawOverheadModel()

	if ScpuiSystem.modelDraw.OverheadClass and ba.getCurrentGameState().Name == "GS_STATE_WEAPON_SELECT" then  --Haaaaaaacks
	
		if ScpuiSystem.modelDraw.class == nil then ScpuiSystem.modelDraw.class = -1 end
		if ScpuiSystem.modelDraw.Hover == nil then ScpuiSystem.modelDraw.Hover = -1 end
		
		--local thisItem = tb.ShipClasses(modelDraw.class)
		modelView = ScpuiSystem.modelDraw.OverheadElement	
		local modelLeft = modelView.parent_node.offset_left + modelView.offset_left --This is pretty messy, but it's functional
		local modelTop = modelView.parent_node.offset_top + modelView.parent_node.parent_node.offset_top + modelView.offset_top
		local modelWidth = modelView.offset_width
		local modelHeight = modelView.offset_height
		
		--Get bank coords. This is all super messy but it's the best we can do
		--without absolute coords available in the librocket Lua API
		local primary_offset = 15
		local secondary_offset = -15
		
		local bank1_x = ScpuiSystem.modelDraw.banks.bank1.offset_left + ScpuiSystem.modelDraw.banks.bank1.parent_node.offset_left + modelLeft + ScpuiSystem.modelDraw.banks.bank1.offset_width + primary_offset
		local bank1_y = ScpuiSystem.modelDraw.banks.bank1.offset_top + ScpuiSystem.modelDraw.banks.bank1.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank1.offset_height / 2)
		
		local bank2_x = ScpuiSystem.modelDraw.banks.bank2.offset_left + ScpuiSystem.modelDraw.banks.bank2.parent_node.offset_left + modelLeft + ScpuiSystem.modelDraw.banks.bank2.offset_width + primary_offset
		local bank2_y = ScpuiSystem.modelDraw.banks.bank2.offset_top + ScpuiSystem.modelDraw.banks.bank2.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank2.offset_height / 2)
		
		local bank3_x = ScpuiSystem.modelDraw.banks.bank3.offset_left + ScpuiSystem.modelDraw.banks.bank3.parent_node.offset_left + modelLeft + ScpuiSystem.modelDraw.banks.bank3.offset_width + primary_offset
		local bank3_y = ScpuiSystem.modelDraw.banks.bank3.offset_top + ScpuiSystem.modelDraw.banks.bank3.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank3.offset_height / 2)
		
		local bank4_x = ScpuiSystem.modelDraw.banks.bank4.offset_left + ScpuiSystem.modelDraw.banks.bank4.parent_node.offset_left + modelLeft + secondary_offset
		local bank4_y = ScpuiSystem.modelDraw.banks.bank4.offset_top + ScpuiSystem.modelDraw.banks.bank4.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank4.offset_height / 2)
		
		local bank5_x = ScpuiSystem.modelDraw.banks.bank4.offset_left + ScpuiSystem.modelDraw.banks.bank5.parent_node.offset_left + modelLeft + secondary_offset
		local bank5_y = ScpuiSystem.modelDraw.banks.bank5.offset_top + ScpuiSystem.modelDraw.banks.bank5.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank5.offset_height / 2)
		
		local bank6_x = ScpuiSystem.modelDraw.banks.bank4.offset_left + ScpuiSystem.modelDraw.banks.bank6.parent_node.offset_left + modelLeft + secondary_offset
		local bank6_y = ScpuiSystem.modelDraw.banks.bank6.offset_top + ScpuiSystem.modelDraw.banks.bank6.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank6.offset_height / 2)
		
		local bank7_x = ScpuiSystem.modelDraw.banks.bank4.offset_left + ScpuiSystem.modelDraw.banks.bank7.parent_node.offset_left + modelLeft + secondary_offset
		local bank7_y = ScpuiSystem.modelDraw.banks.bank7.offset_top + ScpuiSystem.modelDraw.banks.bank7.parent_node.offset_top + modelTop + (ScpuiSystem.modelDraw.banks.bank7.offset_height / 2)
		
		--This is just a multipler to make the rendered model a little bigger
		--renderSelectModel() has forced centering, so we need to calculate
		--the screen size so we can move it slightly left and up while it
		--multiple it's size
		local val = 0.0
		local ratio = (gr.getScreenWidth() / gr.getScreenHeight()) * 2
		
		--Increase by percentage and move slightly left and up.
		modelLeft = modelLeft * (1 - (val/ratio))
		modelTop = modelTop * (1 - val)
		modelWidth = modelWidth * (1 + val)
		modelHeight = modelHeight * (1 + val)
		
		local test = tb.ShipClasses[ScpuiSystem.modelDraw.OverheadClass]:renderOverheadModel(modelLeft, modelTop, modelWidth, modelHeight, ScpuiSystem.modelDraw.Weapons, ScpuiSystem.modelDraw.class, ScpuiSystem.modelDraw.Hover, bank1_x, bank1_y, bank2_x, bank2_y, bank3_x, bank3_y, bank4_x, bank4_y, bank5_x, bank5_y, bank6_x, bank6_y, bank7_x, bank7_y, ScpuiSystem.modelDraw.overheadEffect)
		
		ScpuiSystem.modelDraw.start = false
		
	end

end

function WeaponSelectController:lock_pressed()
	ui.MultiGeneral.getNetGame().Locked = true
end

function WeaponSelectController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function WeaponSelectController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function WeaponSelectController:InputFocusLost()
	--do nothing
end

function WeaponSelectController:InputChange(event)
	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end
end

function WeaponSelectController:updateLists()
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
	
	loadoutHandler:update()
	self:UpdateShipSlots()
	self:UpdateUiElements()
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
end

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_WEAPON_SELECT" then
		WeaponSelectController:drawSelectModel()
		WeaponSelectController:drawOverheadModel()
	end
end, {}, function()
    return false
end)

return WeaponSelectController
