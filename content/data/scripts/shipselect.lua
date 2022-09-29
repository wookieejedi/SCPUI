local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local ShipSelectController = class()

function ShipSelectController:init()
	self.Counter = 0
	ui.ShipWepSelect.initSelect()
end

function ShipSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.slots = {}
	self.aniEl = self.document:CreateElement("ani")
	
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
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", true)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", false)
	
	--ui.ShipWepSelect.initSelect()
	
	self.SelectedEntry = nil
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
	if self.list[1] then
		self.visibleList = {}
		self:CreateEntries(self.list)
	end
	
	--self:InitSlots()
	self:BuildWings()
	
	if self.list[1] then
		self:SelectEntry(self.list[1])
	end

end

function ShipSelectController:BuildWings()

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
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			elseif j == 2 then
				slotEl:SetClass("wing_two", true)
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			elseif j == 3 then
				slotEl:SetClass("wing_three", true)
				--Get the current ship in this slot
				shipIndex = ui.ShipWepSelect.Loadout_Ships[slotNum].ShipClassIndex
				if shipIndex > 0 then
					slotIcon = tb.ShipClasses[shipIndex].SelectIconFilename
					self.slots[slotNum].Name = tb.ShipClasses[shipIndex].Name
				end
			else
				slotEl:SetClass("wing_four", true)
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
					self.slots[slotNum].entry = thisEntry
					
					if not self.slots[slotNum].isLocked then
						--Add dragover detection
						slotEl:AddEventListener("dragdrop", function(_, _, _)
							self:DragOver(slotEl, index)
						end)
						
						--Add drag detection
						slotEl:SetClass("drag", true)
						slotEl:AddEventListener("dragend", function(_, _, _)
							self:DragSlotEnd(slotEl, thisEntry, thisEntry.Index, index)
						end)
					end
					
					--Add click detection
					slotEl:SetClass("button_3", true)
					slotEl:AddEventListener("click", function(_, _, _)
						self:SelectEntry(thisEntry)
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

function ShipSelectController:GetShipEntry(className)

	for i, v in ipairs(self.list) do
		if v.Name == className then
			return v
		end
	end

end

function ShipSelectController:AppendToPool(className)

	i = #self.list + 1
	self.list[i] = {
		Index = i,
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

function ShipSelectController:ReloadList()

	local list_items_el = self.document:GetElementById("ship_icon_list_ul")
	self:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self.visibleList = {}
	self.Counter = 0
	self:CreateEntries(self.list)
	self:SelectEntry(self.visibleList[1])
	self:BuildWings()
end

function ShipSelectController:CreateEntryItem(entry, idx)

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

function ShipSelectController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("ship_icon_list_ul")
	
	self:ClearEntries(list_names_el)

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function ShipSelectController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
		
		if self.SelectedEntry then
			local oldEntry = self.document:GetElementById(self.SelectedEntry)
			if oldEntry then oldEntry:SetPseudoClass("checked", false) end
		end
		
		--local thisEntry = self.document:GetElementById(entry.key)
		self.SelectedEntry = entry.key
		--self.SelectedIndex = entry.Index
		--thisEntry:SetPseudoClass("checked", true)
		
		self:BuildInfo(entry)
		
		--the anim is already created so we only need to remove and reset the src
		self.aniEl:RemoveAttribute("src")
		self.aniEl:SetAttribute("src", entry.Anim)
		
	end

end

function ShipSelectController:ClearEntries(parent)

	while parent:HasChildNodes() do
		parent:RemoveChild(parent.first_child)
	end

end

function ShipSelectController:BuildInfo(entry)

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
end

function ShipSelectController:DragPoolEnd(element, entry, shipIndex)
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

function ShipSelectController:DragSlotEnd(element, entry, shipIndex, currentSlot)
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

function ShipSelectController:SetFilled(thisSlot, status)

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


function ShipSelectController:SetDefaultWeapons(slot, shipIndex)

	--Primaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultPrimaries, 1 do
		ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = tb.ShipClasses[shipIndex].defaultPrimaries[i]:getWeaponClassIndex()
		--Eventually we need to check the weapon pool here!
		ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i] = 1
	end
	
	--Secondaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultSecondaries, 1 do
		ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i + 3] = tb.ShipClasses[shipIndex].defaultSecondaries[i]:getWeaponClassIndex()
		--Eventually we need to check the weapon pool here!
		ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i + 3] = 1000
	end

end

function ShipSelectController:Show(text, title, buttons)
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

function ShipSelectController:reset_pressed(element)
    ui.playElementSound(element, "click", "success")
    ui.ShipWepSelect:resetSelect()
	self:ReloadList()
end

function ShipSelectController:accept_pressed()
    
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
		text = ba.XSTR("The %s is required for this mission, but it has not been added to any ship loadout.", 1624)
	--Two or more required weapons were not loaded on a ship
	elseif errorValue == 4 then
		text = ba.XSTR("The following weapons are required for this mission, but at least one of them has not been added to any ship loadout:\n\n%s", 1625)
	--There is a gap in a ship's weapon banks
	elseif errorValue == 5 then
		text = ba.XSTR("At least one ship has an empty weapon bank before a full weapon bank.\n\nAll weapon banks must have weapons assigned, or if there are any gaps, they must be at the bottom of the set of banks.", 1642)
	--A player has no weapons
	elseif errorValue == 6 then
		text = ba.XSTR("Player %s must select a place in player wing", 462)
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

function ShipSelectController:options_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function ShipSelectController:help_clicked(element)
    ui.playElementSound(element, "click", "success")
    --TODO
end

function ShipSelectController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	--elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(3)
	--elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(1)
	end
end

function ShipSelectController:unload()
	
end

return ShipSelectController
