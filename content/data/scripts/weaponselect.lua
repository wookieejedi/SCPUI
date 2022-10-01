local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local WeaponSelectController = class()

local modelDraw = nil

function WeaponSelectController:init()
	self.Counter = 0
	ui.ShipWepSelect.initSelect()
	modelDraw = {}
end

function WeaponSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.slots = {}
	self.aniEl = self.document:CreateElement("img")
	self.requiredWeps = {}
	self.select3d = false
	
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
	aniWrapper:ReplaceChild(self.aniEl, aniWrapper.first_child)

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", true)
	
	--ui.ShipWepSelect.initSelect()
	
	self.SelectedEntry = nil
	self.SelectedShip = nil
	self.list = {}
	
	local shipList = tb.ShipClasses
	local i = 1
	while (i ~= #shipList) do
		if ui.ShipWepSelect.Ship_Pool[i] > 0 then
			self.list[i] = {
				Index = i,
				Amount = ui.ShipWepSelect.Ship_Pool[i],
				Icon = shipList[i].SelectIconFilename,
				Anim = shipList[i].SelectAnimFilename,
				Overhead = shipList[i].SelectOverheadFilename,
				Name = shipList[i].Name,
				Type = shipList[i].TypeString,
				Length = shipList[i].LengthString,
				Velocity = shipList[i].VelocityString,
				Maneuverability = shipList[i].ManeuverabilityString,
				Armor = shipList[i].ArmorString,
				GunMounts = shipList[i].GunMountsString,
				MissileBanks = shipList[i].MissileBanksString,
				Manufacturer = shipList[i].ManufacturerString
			}
		end
		i = i + 1
	end
	
	--Only create entries if there are any to create
	--if self.list[1] then
	--	self.visibleList = {}
	--	self:CreateEntries(self.list)
	--end
	
	--self:InitSlots()
	self:BuildWings()
	local callsign = ui.ShipWepSelect.Loadout_Wings[1].Name .. " 1"
	self:SelectShip(ui.ShipWepSelect.Loadout_Ships[1].ShipClassIndex, callsign, 1)
	
	--if self.list[1] then
	--	self:SelectEntry(self.list[1])
	--end

end

function WeaponSelectController:BuildWings()

	local slotNum = 1
	local wrapperEl = self.document:GetElementById("wings_wrapper")
	self:ClearEntries(wrapperEl)

	--#ui.ShipWepSelect.Loadout_Wings
	for i = 1, #ui.ShipWepSelect.Loadout_Wings, 1 do
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
		nameEl.inner_rml = ui.ShipWepSelect.Loadout_Wings[i].Name
		wingEl:AppendChild(nameEl)
		
		--Now we add the actual wing slots
		for j = 1, #ui.ShipWepSelect.Loadout_Wings[i], 1 do
			self.slots[slotNum] = {}
			
			self.slots[slotNum].isDisabled = ui.ShipWepSelect.Loadout_Wings[i][j].isDisabled
			self.slots[slotNum].isFilled = ui.ShipWepSelect.Loadout_Wings[i][j].isFilled
			if ui.ShipWepSelect.Loadout_Wings[i][j].isShipLocked or ui.ShipWepSelect.Loadout_Wings[i][j].isWeaponLocked then
				self.slots[slotNum].isLocked = true
			end
			
			local slotEl = self.document:CreateElement("div")
			slotEl:SetClass("wing_slot", true)
			slotsEl:AppendChild(slotEl)
			
			--default to empty slot image for now, but don't show disabled slots
			local slotIcon = "iconwing01.ani"
			self.slots[slotNum].Name = nil
			local shipIndex = 0
			
			--This is messy, but we have to check which exact slot we are in the wing
			if j == 1 then
				slotEl:SetClass("wing_one", true)
				self.slots[slotNum].Callsign = ui.ShipWepSelect.Loadout_Wings[i].Name .. " 1"
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			elseif j == 2 then
				slotEl:SetClass("wing_two", true)
				self.slots[slotNum].Callsign = ui.ShipWepSelect.Loadout_Wings[i].Name .. " 2"
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			elseif j == 3 then
				slotEl:SetClass("wing_three", true)
				self.slots[slotNum].Callsign = ui.ShipWepSelect.Loadout_Wings[i].Name .. " 3"
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			else
				slotEl:SetClass("wing_four", true)
				self.slots[slotNum].Callsign = ui.ShipWepSelect.Loadout_Wings[i].Name .. " 4"
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			end
			--ba.warning(slotNum)
			--ba.warning(self.slots[slotNum].Name)
			
			local slotImg = self.document:CreateElement("ani")
			slotImg:SetAttribute("src", slotIcon)
			slotEl:AppendChild(slotImg)
			
			slotEl.id = "slot_" .. slotNum
			local index = slotNum
			if not self.slots[slotNum].isDisabled then
				if shipIndex > 0 then
					local thisEntry = self:GetShipEntry(self.slots[slotNum].Name)
					if thisEntry == nil then
						thisEntry = self:AppendToPool(self.slots[slotNum].Name)
					end
					local callsign = self.slots[slotNum].Callsign
					self.slots[slotNum].entry = thisEntry
					
					--Add click detection
					slotEl:SetClass("button_3", true)
					slotEl:AddEventListener("click", function(_, _, _)
						self:SelectShip(shipIndex, callsign, slotNum)
					end)
				else
					--ba.warning("got here")
					--ba.warning(ui.ShipWepSelect.Loadout_Ships[slotNum].Weapons[1] .. " " .. ui.ShipWepSelect.Loadout_Ships[slotNum].Amounts[1])
				end
			end
			
			slotNum = slotNum + 1
		end
	end

end

function WeaponSelectController:GetShipEntry(className)

	for i, v in ipairs(self.list) do
		if v.Name == className then
			return v
		end
	end

end

function WeaponSelectController:AppendToPool(className)

	i = #self.list + 1
	self.list[i] = {
		Index = tb.ShipClasses[className]:getShipClassIndex(),
		Amount = 0,
		Icon = tb.ShipClasses[className].SelectIconFilename,
		Anim = tb.ShipClasses[className].SelectAnimFilename,
		Name = tb.ShipClasses[className].Name,
		Type = tb.ShipClasses[className].TypeString,
		Length = tb.ShipClasses[className].LengthString,
		Velocity = tb.ShipClasses[className].VelocityString,
		Maneuverability = tb.ShipClasses[className].ManeuverabilityString,
		Armor = tb.ShipClasses[className].ArmorString,
		GunMounts = tb.ShipClasses[className].GunMountsString,
		MissileBanks = tb.ShipClasses[className].MissileBanksString,
		Manufacturer = tb.ShipClasses[className].ManufacturerString,
		key = tb.ShipClasses[className].Name
	}
	return self.list[i]
end

function WeaponSelectController:ReloadList()

	modelDraw.class = nil
	local list_items_el = self.document:GetElementById("primary_icon_list_ul")
	self:ClearEntries(list_items_el)
	local list_items_el = self.document:GetElementById("secondary_icon_list_ul")
	self:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self.SelectedShip = nil
	self.visibleList = {}
	self.Counter = 0
	self:CreateEntries(self.list)
	self:SelectEntry(self.visibleList[1])
	self:BuildWings()
	self:SelectShip(self:GetShipEntry(self.slots[1].Name))
end

function WeaponSelectController:CreateEntryItem(entry, idx)

	self.Counter = self.Counter + 1

	local li_el = self.document:CreateElement("li")
	local iconWrapper = self.document:CreateElement("div")
	iconWrapper.id = entry.Name
	iconWrapper:SetClass("select_item", true)
	
	li_el:AppendChild(iconWrapper)
	
	local countEl = self.document:CreateElement("div")
	countEl.inner_rml = entry.Amount
	countEl:SetClass("amount", true)
	
	iconWrapper:AppendChild(countEl)
	
	--local aniWrapper = self.document:GetElementById(entry.Icon)
	local iconEl = self.document:CreateElement("ani")
	iconEl:SetAttribute("src", entry.Icon)
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
	self.visibleList[self.Counter] = entry
	entry.key = li_el.id
	
	self.visibleList[self.Counter].idx = self.Counter

	return li_el
end

function WeaponSelectController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("ship_icon_list_ul")
	
	self:ClearEntries(list_names_el)

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function WeaponSelectController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
		
		self.SelectedEntry = entry.key
		
		self:BuildInfo(entry)
		
		if self.select3d or entry.Anim == nil then
			modelDraw.class = entry.Index
			modelDraw.element = self.document:GetElementById("ship_view_wrapper")
			modelDraw.start = true
		else
			--the anim is already created so we only need to remove and reset the src
			self.aniEl:RemoveAttribute("src")
			self.aniEl:SetAttribute("src", entry.Anim)
		end
		
	end

end

function WeaponSelectController:SelectShip(shipIndex, callsign, slot)

	if callsign ~= self.SelectedShip then
		
		self.SelectedShip = callsign
		self.currentShipSlot = slot
		
		self.document:GetElementById("ship_name").inner_rml = callsign
		
		local overhead = tb.ShipClasses[shipIndex].SelectOverheadFilename
		
		if self.select3d or overhead == nil then
			--This is where the 3D overhead view will be drawn
			--modelDraw.class = ship.Index
			--modelDraw.element = self.document:GetElementById("ship_view_wrapper")
			--modelDraw.start = true
		else
			--the anim is already created so we only need to remove and reset the src
			self.aniEl:RemoveAttribute("src")
			self.aniEl:SetAttribute("src", overhead)
		end
		
	end

end

function WeaponSelectController:ClearEntries(parent)

	while parent:HasChildNodes() do
		parent:RemoveChild(parent.first_child)
	end

end

function WeaponSelectController:BuildInfo(entry)

	local infoEl = self.document:GetElementById("ship_stats_info")
	
	local midString = "</p><p class=\"info\">"
	
	local shipClass    = "<p>" .. ba.XSTR("Class", 739) .. midString .. entry.Name .. "</p>"
	local shipType     = "<p>" .. ba.XSTR("Type", 740) .. midString .. entry.Type .. "</p>"
	local shipLength   = "<p>" .. ba.XSTR("Length", 741) .. midString .. entry.Length .. "</p>"
	local shipVelocity = "<p>" .. ba.XSTR("Max Velocity", 742) .. midString .. entry.Velocity .. "</p>"
	local shipManeuv   = "<p>" .. ba.XSTR("Maneuverability", 744) .. midString .. entry.Maneuverability .. "</p>"
	local shipArmor    = "<p>" .. ba.XSTR("Armor", 745) .. midString .. entry.Armor .. "</p>"
	local shipGuns     = "<p>" .. ba.XSTR("Gun Mounts", 746) .. midString .. entry.GunMounts .. "</p>"
	local shipMissiles = "<p>" .. ba.XSTR("Missile Banks", 747) .. midString .. entry.MissileBanks .. "</p>"
	local shipManufac  = "<p>" .. ba.XSTR("Manufacturer", 748) .. midString .. entry.Manufacturer .. "</p>"

	local completeRML = shipClass .. shipType .. shipLength .. shipVelocity .. shipManeuv .. shipArmor .. shipGuns .. shipMissiles .. shipManufac
	
	infoEl.inner_rml = completeRML

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

function WeaponSelectController:DragOver(element, slot)
	self.replace = element
	self.activeSlot = slot
end

function WeaponSelectController:DragPoolEnd(element, entry, shipIndex)
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		--Get the amount of the ship we're dragging
		local countEl = self.document:GetElementById(entry.Name).first_child
		local count = tonumber(countEl.first_child.inner_rml)
		if count > 0 then
			if self.slots[self.activeSlot].Name == nil then
				self.slots[self.activeSlot].Name = entry.Name
				local count = count - 1
				countEl.first_child.inner_rml = count
			else
				--Get the amount of the ship we're sending back
				local countBackEl = self.document:GetElementById(self.slots[self.activeSlot].Name).first_child
				local countBack = tonumber(countBackEl.first_child.inner_rml) + 1
				countBackEl.first_child.inner_rml = countBack
				self.slots[self.activeSlot].Name = entry.Name
				local count = count - 1
				countEl.first_child.inner_rml = count
			end
			local replace_el = self.document:GetElementById(self.replace.id)
			local imgEl = self.document:CreateElement("img")
			imgEl:SetAttribute("src", element:GetAttribute("src"))
			self.document:GetElementById(replace_el.id):RemoveChild(replace_el.first_child)
			self.document:GetElementById(replace_el.id):AppendChild(imgEl)
			replace_el:SetClass("drag", true)
			
			self:SetFilled(self.activeSlot, true)
			
			--This is where we return the previous ship and its weapons to the pool
			self:ReturnShip(self.activeSlot)
			--Now set the new ship and weapons
			ui.ShipWepSelect.Loadout_Ships[self.activeSlot].ShipClassIndex = shipIndex
			self:SetDefaultWeapons(self.activeSlot, shipIndex)
			
			replace_el:SetClass("button_3", true)
			replace_el:AddEventListener("click", function(_, _, _)
				self:SelectEntry(entry)
			end)
			
			self.replace = nil
		end
	end
end

function WeaponSelectController:DragSlotEnd(element, entry, shipIndex, currentSlot)
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		if self.slots[self.activeSlot].Name ~= nil then
			--Get the amount of the ship we're sending back
			local countBackEl = self.document:GetElementById(self.slots[self.activeSlot].Name).first_child
			local countBack = tonumber(countBackEl.first_child.inner_rml) + 1
			countBackEl.first_child.inner_rml = countBack
		end
		
		self.slots[self.activeSlot].Name = entry.Name
		
		local replace_el = self.document:GetElementById(self.replace.id)
		local imgEl = self.document:CreateElement("img")
		imgEl:SetAttribute("src", element.first_child:GetAttribute("src"))
		self.document:GetElementById(replace_el.id):RemoveChild(replace_el.first_child)
		self.document:GetElementById(replace_el.id):AppendChild(imgEl)
		replace_el:SetClass("drag", true)
		
		element.first_child:SetAttribute("src", "iconwing01.ani")
		ui.ShipWepSelect.Loadout_Ships[currentSlot].ShipClassIndex = -1
		self.slots[currentSlot].Name = nil
		element:SetClass("drag", false)
		
		self:SetFilled(currentSlot, false)
		self:SetFilled(self.activeSlot, true)
		
		--This is where we return the previous ship and its weapons to the pool
		self:ReturnShip(self.activeSlot)
		--Now set the new ship and weapons
		ui.ShipWepSelect.Loadout_Ships[self.activeSlot].ShipClassIndex = shipIndex
		self:SetDefaultWeapons(self.activeSlot, shipIndex)
		
		replace_el:SetClass("button_3", true)
		replace_el:AddEventListener("click", function(_, _, _)
			self:SelectEntry(entry)
		end)
		
		self.replace = nil
	elseif (self.replace ~= nil) and (self.activeSlot == 0) then	
		--Get the amount of the ship we're sending back
		local countBackEl = self.document:GetElementById(self.slots[currentSlot].Name).first_child
		local countBack = tonumber(countBackEl.first_child.inner_rml) + 1
		countBackEl.first_child.inner_rml = countBack
		element:SetClass("drag", false)
		
		element.first_child:SetAttribute("src", "iconwing01.ani")
		ui.ShipWepSelect.Loadout_Ships[currentSlot].ShipClassIndex = -1
		self.slots[currentSlot].Name = nil
		
		self:SetFilled(currentSlot, false)
	end
end

function WeaponSelectController:SetFilled(thisSlot, status)

	local curWing = 0
	local curSlot = 0
	if thisSlot < 5 then
		curWing = 1
		curSlot = thisSlot
	elseif thisSlot < 9 then
		curWing = 2
		curSlot = thisSlot - 4
	else
		curWing = 3
		curSlot = thisSlot - 8
	end
	ui.ShipWepSelect.Loadout_Wings[curWing][curSlot].isFilled = status
			
end

function WeaponSelectController:ReturnShip(slot)

	--Return all the weapons to the pool
	for i = 1, #ui.ShipWepSelect.Loadout_Ships[slot].Weapons, 1 do
		local weapon = ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i]
		if weapon > 0 then
			local amount = ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i]
			ui.ShipWepSelect.Weapon_Pool[weapon] = ui.ShipWepSelect.Weapon_Pool[weapon] + amount
		end
	end
	
	--Return the ship
	local ship = ui.ShipWepSelect.Loadout_Ships[slot].ShipClassIndex
	ui.ShipWepSelect.Ship_Pool[ship] = ui.ShipWepSelect.Ship_Pool[ship] + 1

end

function WeaponSelectController:SetDefaultWeapons(slot, shipIndex)

	--Primaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultPrimaries, 1 do
		local weapon = tb.ShipClasses[shipIndex].defaultPrimaries[i]:getWeaponClassIndex()
		--Check the weapon pool
		if ui.ShipWepSelect.Weapon_Pool[weapon] <= 0 then
			--Find a new weapon
			weapon = self:GetFirstAllowedWeapon(shipIndex, i, 2)
		end
		--Get an appropriate amount for the weapon and bank
			amount = self:GetWeaponAmount(shipIndex, weapon, i)
		--Set the weapon
		ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = weapon
		ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i] = amount
		--Subtract from the pool
		ui.ShipWepSelect.Weapon_Pool[weapon] = ui.ShipWepSelect.Weapon_Pool[weapon] - amount
	end
	
	--Secondaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultSecondaries, 1 do
		local weapon = tb.ShipClasses[shipIndex].defaultSecondaries[i]:getWeaponClassIndex()
		--Check the weapon pool
		if ui.ShipWepSelect.Weapon_Pool[weapon] <= 0 then
			--Find a new weapon
			weapon = self:GetFirstAllowedWeapon(shipIndex, i, 2)
			--Get an appropriate amount for the weapon and bank
			amount = self:GetWeaponAmount(shipIndex, weapon, i)
		end
		--Set the weapon
		ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i + 3] = weapon
		ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i + 3] = amount
		--Subtract from the pool
		ui.ShipWepSelect.Weapon_Pool[weapon] = ui.ShipWepSelect.Weapon_Pool[weapon] - amount
	end

end

function WeaponSelectController:GetWeaponAmount(shipIndex, weaponIndex, bank)
	
	--Primaries always get set to 1, even ballistics
	if tb.WeaponClasses[weaponIndex]:isPrimary() then
		return 1
	end
	
	local capacity = tb.ShipClasses[shipIndex]:getSecondaryBankCapacity(bank)
	local amount = capacity / tb.WeaponClasses[weaponIndex].CargoSize
	return math.floor(amount+0.5)

end

function WeaponSelectController:GetFirstAllowedWeapon(shipIndex, bank, category)

	i = 1
	while (i < #tb.WeaponClasses) do
		if (tb.WeaponClasses[i]:isPrimary() and (category == 1)) or (tb.WeaponClasses[i]:isSecondary() and (category == 2)) then
			if ui.ShipWepSelect.Weapon_Pool[i] > 0 then
				if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(i, bank) then
					return i
				end
			end
		end
		i = i + 1
	end
	
	return -1

end

function WeaponSelectController:Show(text, title, buttons)
	--Create a simple dialog box with the text and title

	currentDialog = true
	
	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		for i = 1, #buttons do
			dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value)
		end
		dialog:show(self.document.context)
		:continueWith(function(response)
        --do nothing
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.document.context)
end

function WeaponSelectController:reset_pressed(element)
    ui.playElementSound(element, "click", "success")
    ui.ShipWepSelect:resetSelect()
	self:ReloadList()
end

function WeaponSelectController:accept_pressed()
    
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
		text = nil
	end

	if text ~= nil then
		text = string.gsub(text,"\n","<br></br>")
		local title = ""
		local buttons = {}
		buttons[1] = {
			b_type = dialogs.BUTTON_TYPE_POSITIVE,
			b_text = ba.XSTR("Okay", -1),
			b_value = ""
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
    --TODO
end

function WeaponSelectController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	--elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(3)
	--elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(1)
	end
end

function WeaponSelectController:unload()

	modelDraw.class = nil
	ui.ShipWepSelect:saveLoadout()
	
end

function WeaponSelectController:drawSelectModel()

	if modelDraw.class and ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then  --Haaaaaaacks

		--local thisItem = tb.ShipClasses(modelDraw.class)
		
		modelView = modelDraw.element	
		local modelLeft = modelView.parent_node.offset_left + modelView.offset_left --This is pretty messy, but it's functional
		local modelTop = modelView.parent_node.offset_top + modelView.parent_node.parent_node.offset_top + modelView.offset_top
		local modelWidth = modelView.offset_width
		local modelHeight = modelView.offset_height
		
		--This is just a multipler to make the rendered model a little bigger
		--renderSelectModel() has forced centering, so we need to calculate
		--the screen size so we can move it slightly left and up while it
		--multiple it's size
		local val = 0.3
		local ratio = (gr.getScreenWidth() / gr.getScreenHeight()) * 2
		
		--Increase by percentage and move slightly left and up.
		modelLeft = modelLeft * (1 - (val/ratio))
		modelTop = modelTop * (1 - val)
		modelWidth = modelWidth * (1 + val)
		modelHeight = modelHeight * (1 + val)
		
		local test = tb.ShipClasses[modelDraw.class]:renderSelectModel(modelDraw.start, modelLeft, modelTop, modelWidth, modelHeight)
		
		modelDraw.start = false
		
	end

end

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then
		WeaponSelectController:drawSelectModel()
	end
end, {}, function()
    return false
end)

return WeaponSelectController
