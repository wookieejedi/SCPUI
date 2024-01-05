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
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", true)
	
	self.SelectedEntry = nil
	self.SelectedShip = nil
	
	self.enabled = self:BuildWings()
	
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
					ba.error("Could not find " .. tb.ShipClasses[shipIndex].Name .. " in the loadout!")
				end
				if slotInfo.isPlayer then
					slotIcon = entry.GeneratedIcon[4]
				elseif slotInfo.isShipLocked then
					slotIcon = entry.GeneratedIcon[6]
				elseif slotInfo.isWeaponLocked then
					slotIcon = entry.GeneratedIcon[6]
				else
					slotIcon = entry.GeneratedIcon[1]
				end
			end
			
			local slotImg = self.document:CreateElement("img")
			slotImg:SetAttribute("src", slotIcon)
			slotEl:AppendChild(slotImg)
			
			--This is here so that the event listeners use the correct slot index!
			local index = slotNum
			local callsign = slotInfo.Name
			
			slotEl.id = "slot_" .. slotNum

			if not slotInfo.isDisabled then
				if shipIndex > 0 then
					local thisEntry = loadoutHandler:GetShipInfo(shipIndex)
					if thisEntry == nil then
						ba.warning("Ship Info did not exist! How? Who knows! Get Mjn!")
						thisEntry = loadoutHandler:AppendToShipInfo(shipIndex)
					end
					
					--Add click detection
					slotEl:SetClass("button_3", true)
					slotEl:AddEventListener("click", function(_, _, _)
						self:SelectShip(shipIndex, callsign, index)
					end)
					
					if self.icon3d then
						if not slotInfo.isShipLocked then
							slotEl:SetClass("available", true)
						elseif slotInfo.isWeaponLocked then
							slotEl:SetClass("locked", true)
						else
							slotEl:SetClass("available", true)
						end
					end
				else
					--do nothing
				end
			end
			
			slotNum = slotNum + 1
		end
	end
	
	return true

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

		self:SelectShip(ship.ShipClassIndex, ship.Name, 1)
		
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
				iconEl:SetClass("available", true)
				iconEl:SetClass("locked", false)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[1])
		else
			iconEl:SetClass("drag", false)
			if self.icon3d then
				iconEl:SetClass("available", false)
				iconEl:SetClass("locked", true)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[4])
		end
	end
	
	for i, v in pairs(loadoutHandler:GetSecondaryWeaponList()) do
		local iconEl = self.document:GetElementById(v.key).first_child.first_child.next_sibling
		if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(v.Index) then
			iconEl:SetClass("drag", true)
			if self.icon3d then
				iconEl:SetClass("available", true)
				iconEl:SetClass("locked", false)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[1])
		else
			iconEl:SetClass("drag", false)
			if self.icon3d then
				iconEl:SetClass("available", false)
				iconEl:SetClass("locked", true)
			end
			iconEl:SetAttribute("src", v.GeneratedIcon[4])
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

function WeaponSelectController:SelectEntry(entry, slot)
	if entry ~= nil then
		ScpuiSystem.modelDraw.Hover = slot
		if entry.key ~= self.SelectedEntry then
			
			self.SelectedEntry = entry.key
			
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
				if ship.isPlayer then
					icon = thisEntry.GeneratedIcon[4]
				elseif ship.isShipLocked then
					icon = thisEntry.GeneratedIcon[5]
				elseif ship.isWeaponLocked then
					icon = thisEntry.GeneratedIcon[5]
				else
					icon = thisEntry.GeneratedIcon[3]
				end
			else
				if ship.isPlayer then
					icon = thisEntry.GeneratedIcon[4]
				elseif ship.isShipLocked then
					icon = thisEntry.GeneratedIcon[6]
				elseif ship.isWeaponLocked then
					icon = thisEntry.GeneratedIcon[6]
				else
					icon = thisEntry.GeneratedIcon[1]
				end
			end
			
			slotEl.first_child:SetAttribute("src", icon)
			
		end
	end
	
	return true
				
end

function WeaponSelectController:SelectShip(shipIndex, callsign, slot)

	if callsign ~= self.SelectedShip then
		
		self.SelectedShip = callsign
		self.currentShipSlot = slot
		
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
	
	for i, v in pairs(ScpuiSystem.modelDraw.banks) do
		v:SetClass("slot_3d", false)
		v:SetClass("button_3", false)
	end
	
	for i, v in pairs(self.secondaryAmountEls) do
		v.inner_rml = ""
	end
end

function WeaponSelectController:BuildWeaponSlots(ship)

	self:ClearWeaponSlots()

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
	local slotImg = self.document:CreateElement("img")
	
	local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
	
	--Maybe show slot as locked
	if ship.isWeaponLocked == true then
		parentEl:SetClass("weapon_locked", true)
	else
		parentEl:SetClass("weapon_locked", false)
	end
	
	--Get the weapon currently loaded in the slot
	local weapon = ship.Weapons[bank]
	local amount = ship.Amounts[bank]
	if amount < 1 then amount = "" end
	if bank > 3 then
		self.secondaryAmountEls[bank - 3].inner_rml = amount
	end
	
	local slotIcon = nil
	if weapon > 0 then
		slotIcon = loadoutHandler:GetWeaponInfo(weapon).GeneratedIcon[1]
		--slotIcon = tb.WeaponClasses[weapon].SelectIconFilename
		if ship.isWeaponLocked == false then
			slotImg:SetClass("drag", true)
		end
		slotImg:SetClass("button_3", true)
		slotImg:SetAttribute("src", slotIcon)
		parentEl:AppendChild(slotImg)
	end
end

function WeaponSelectController:BuildInfo(entry)

	self.document:GetElementById("weapon_name").inner_rml = entry.Title
	
	local infoEl = self.document:GetElementById("weapon_stats")
	
	ScpuiSystem:ClearEntries(infoEl)
	
	local hull = entry.ArmorFactor * entry.Damage
	local shield = entry.ShieldFactor * entry.Damage
	local subsystem = entry.SubsystemFactor * entry.Damage
	local power = math.floor(entry.Power * 100)
	local rof = math.floor(100 / entry.FireWait) / 100
	
	local desc_el = self.document:CreateElement("p")
	desc_el.inner_rml = entry.Description
	
	local stats1_el = self.document:CreateElement("p")
	stats1_el.inner_rml = ba.XSTR("Velocity", -1) .. ": " .. entry.Velocity .. "m/s " .. ba.XSTR("Range", -1) .. ": " .. entry.Range .. "m"
	
	local stats2_el = self.document:CreateElement("p")
	stats2_el:SetClass("info", true)
	stats2_el.inner_rml = ba.XSTR("Damage", -1) .. ": " .. hull .. " " .. ba.XSTR("Hull", -1) .. ", " .. shield .. " " .. ba.XSTR("Shield", -1) .. ", " .. subsystem .. " " .. ba.XSTR("Subsystem", -1)
	
	local stats3_el = self.document:CreateElement("p")
	stats3_el:SetClass("info", true)
	stats3_el.inner_rml = ba.XSTR("Power Use", -1) .. ": " .. power .. ba.XSTR("W", -1) .. " " .. ba.XSTR("ROF", -1) .. ": " .. rof .. "/s"
	
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
end

function WeaponSelectController:DragOver(element, slot)
	if loadoutHandler:GetShipLoadout(self.currentShipSlot).Weapons[slot] > 0 then
		ScpuiSystem.modelDraw.Hover = slot
	end
end

function WeaponSelectController:DragOut(element, slot)
	ScpuiSystem.modelDraw.Hover = -1
end

function WeaponSelectController:ApplyWeaponToSlot(parentEl, slot, bank, weapon)

	local entry = loadoutHandler:GetWeaponInfo(weapon)
	local slotIcon = nil
	if entry.Name == self.SelectedEntry then
		slotIcon = entry.GeneratedIcon[3]
	else
		slotIcon = entry.GeneratedIcon[1]
	end
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

function WeaponSelectController:UpdatePoolCount(data)
	local countEl = self.document:GetElementById(data.key .. "_count")
	
	if countEl == nil then return end

	countEl.inner_rml = loadoutHandler:GetWeaponPoolAmount(data.Index)
end

function WeaponSelectController:UpdateUiElements()
	self:UpdateAllPoolCounts()
	self:UpdateAllSecondaryCounts()
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
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		
		--Get the slot information: ship, weapon, and amount
		local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
		local shipIdx = ship.ShipClassIndex 
		local slotWeapon = ship.Weapons[self.activeSlot]
		local slotAmount = ship.Amounts[self.activeSlot]
	
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
			text = ba.XSTR("That weapon slot can't accept that weapon type", -1)
			local title = ""
			local buttons = {}
			buttons[1] = {
				b_type = dialogs.BUTTON_TYPE_POSITIVE,
				b_text = ba.XSTR("Okay", -1),
				b_value = "",
				b_keypress = string.sub(ba.XSTR("Ok", -1), 1, 1)
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
	if (self.replace ~= nil) and (self.activeSlot > -1) then
	
		local dropSlot = self.activeSlot
		
		--Get the slot information of what's being dragged: ship, weapon, and amount
		local ship = loadoutHandler:GetShipLoadout(self.currentShipSlot)
		local shipIdx = ship.ShipClassIndex 
		local slotWeapon = ship.Weapons[slot]
		local slotAmount = ship.Amounts[slot]
		
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
			text = ba.XSTR("That weapon slot can't accept that weapon type", -1)
			local title = ""
			local buttons = {}
			buttons[1] = {
				b_type = dialogs.BUTTON_TYPE_POSITIVE,
				b_text = ba.XSTR("Okay", -1),
				b_value = "",
				b_keypress = string.sub(ba.XSTR("Ok", -1), 1, 1)
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

	--Apply the loadout
	loadoutHandler:SendAllToFSO_API()
    
	local errorValue = ui.Briefing.commitToMission()
	local text = ""
	
	--General Fail
	if errorValue == 1 then
		text = ba.XSTR("An error has occured", -1)
	--A player ship has no weapons
	elseif errorValue == 2 then
		text = ba.XSTR("Player ship has no weapons", 461)
	--The required weapon was not loaded on a ship
	elseif errorValue == 3 then
		text = ba.XSTR("The " .. self.requiredWeps[1] .. " is required for this mission, but it has not been added to any ship loadout.", 1624)
	--Two or more required weapons were not loaded on a ship
	elseif errorValue == 4 then
		local WepsString = ""
		for i = 1, #self.requiredWeps, 1 do
			WepsString = WepsString .. self.requiredWeps[i] .. "\n"
		end
		text = ba.XSTR("The following weapons are required for this mission, but at least one of them has not been added to any ship loadout:\n\n" .. WepsString, 1625)
	--There is a gap in a ship's weapon banks
	elseif errorValue == 5 then
		text = ba.XSTR("At least one ship has an empty weapon bank before a full weapon bank.\n\nAll weapon banks must have weapons assigned, or if there are any gaps, they must be at the bottom of the set of banks.", 1642)
	--A player has no weapons
	elseif errorValue == 6 then
		local player = ba.getCurrentPlayer():getName()
		text = ba.XSTR("Player " .. player .. " must select a place in player wing", 462)
	--Success!
	else
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

	if text ~= nil then
		text = string.gsub(text,"\n","<br></br>")
		local title = ""
		local buttons = {}
		buttons[1] = {
			b_type = dialogs.BUTTON_TYPE_POSITIVE,
			b_text = ba.XSTR("Okay", -1),
			b_value = "",
			b_keypress = string.sub(ba.XSTR("Ok", -1), 1, 1)
		}
		
		self:Show(text, title, buttons)
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
		if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
			ScpuiSystem.music_handle:close(true)
		end
		ScpuiSystem.music_handle = nil
		ScpuiSystem.current_played = nil
        event:StopPropagation()

		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	end
end

function WeaponSelectController:unload()
	
	loadoutHandler:saveCurrentLoadout()
	ScpuiSystem.modelDraw.class = nil
	
	if self.Commit == false then
		loadoutHandler:ResetFSO_API()
		loadoutHandler:SaveInFSO_API()
	end
	
	if self.Commit == true then
		loadoutHandler:unloadAll()
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
		
		local test = tb.WeaponClasses[ScpuiSystem.modelDraw.class]:renderSelectModel(ScpuiSystem.modelDraw.start, modelLeft, modelTop, modelWidth, modelHeight)
		
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

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_WEAPON_SELECT" then
		WeaponSelectController:drawSelectModel()
		WeaponSelectController:drawOverheadModel()
	end
end, {}, function()
    return false
end)

return WeaponSelectController
