local dialogs = require("dialogs")
local class = require("class")
local topics = require("ui_topics")
local async_util = require("async_util")
local loadoutHandler = require("loadouthandler")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local ShipSelectController = class()

ScpuiSystem.modelDraw = nil

function ShipSelectController:init()
	loadoutHandler:init()
	ScpuiSystem.modelDraw = {}
	self.help_shown = false
	self.enabled = false
end

function ShipSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.aniEl = self.document:CreateElement("ani")
	self.requiredWeps = {}
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	self.ship3d, self.shipEffect, self.icon3d = ui.ShipWepSelect.get3dShipChoices()
	
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
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", false)
	self.document:GetElementById("s_select_btn"):SetPseudoClass("checked", true)
	self.document:GetElementById("w_select_btn"):SetPseudoClass("checked", false)
	
	self.SelectedEntry = nil
	
	self.enabled = self:BuildWings()
	
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
	if loadoutHandler.GetNumWings() <= 0 then
		ba.warning("Mission has no loadout wings! Check the loadout in FRED!")
		return false
	end

	for i = 1, loadoutHandler.GetNumWings() do

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
		if loadoutHandler:GetNumWingSlots(slotNum) <= 0 then
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
				else
					slotIcon = entry.GeneratedIcon[1]
				end
			end
			
			local slotImg = self.document:CreateElement("img")
			slotImg:SetAttribute("src", slotIcon)
			slotEl:AppendChild(slotImg)
			
			--This is here so that the event listeners use the correct slot index!
			local index = slotNum
			
			slotEl.id = "slot_" .. slotNum

			if not slotInfo.isDisabled then
				if shipIndex > 0 then
					local thisEntry = loadoutHandler:GetShipInfo(shipIndex)
					if thisEntry == nil then
						ba.warning("Ship Info did not exist! How? Who knows! Get Mjn!")
						thisEntry = loadoutHandler:AppendToShipInfo(shipIndex)
					end
					
					if not slotInfo.isShipLocked then
						--Add dragover detection
						slotEl:AddEventListener("dragdrop", function(_, _, _)
							self:DragOver(slotEl, index)
						end)
						
						--Add drag detection
						slotEl:SetClass("drag", true)
						slotEl:AddEventListener("dragend", function(_, _, _)
							self:DragSlotEnd(slotEl, thisEntry, index)
						end)
						
						if self.icon3d then
							slotEl:SetClass("available", true)
						end
					else
						if self.icon3d then
							slotEl:SetClass("locked", true)
						end
					end
					
					--Add click detection
					slotEl:SetClass("button_3", true)
					slotEl:AddEventListener("click", function(_, _, _)
						self:SelectEntry(thisEntry)
					end)
				else
					--Add dragover detection
					slotEl:AddEventListener("dragdrop", function(_, _, _)
						self:DragOver(slotEl, index)
					end)
				end
			end
			
			slotNum = slotNum + 1
		end
	end
	
	return true

end

function ShipSelectController:ReloadList()

	ScpuiSystem.modelDraw.class = nil
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
	countEl.inner_rml = loadoutHandler:GetShipPoolAmount(entry.Index)
	countEl:SetClass("amount", true)
	
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

function ShipSelectController:CreateEntries(list)

	local list_names_el = self.document:GetElementById("ship_icon_list_ul")
	
	ScpuiSystem:ClearEntries(list_names_el)

	for i, v in pairs(list) do
		list_names_el:AppendChild(self:CreateEntryItem(v, i))
	end
end

function ShipSelectController:HighlightShip(entry)

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

	for i = 1, loadoutHandler:GetNumSlots() do
		local ship = loadoutHandler:GetShipLoadout(i)
		local element = self.document:GetElementById("slot_" .. i)
		local shipIndex = ship.ShipClassIndex
		if shipIndex > 0 then
			local thisEntry = loadoutHandler:GetShipInfo(shipIndex)
			if ship.Name == entry.Name then
				if not ship.isPlayer then
					if ship.isShipLocked then
						element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[5])
					else
						element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[3])
					end
				end
			else
				if not ship.isPlayer then
					if ship.isShipLocked then
						element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[6])
					else
						element.first_child:SetAttribute("src", thisEntry.GeneratedIcon[1])
					end
				end
			end
		end
	end
				
end

function ShipSelectController:SelectEntry(entry)

	if entry.key ~= self.SelectedEntry then
		
		self.SelectedEntry = entry.key
		
		self:HighlightShip(entry)
		
		self:BuildInfo(entry)
		
		if self.ship3d or entry.Anim == nil then
			ScpuiSystem.modelDraw.class = entry.Index
			ScpuiSystem.modelDraw.element = self.document:GetElementById("ship_view_wrapper")
			ScpuiSystem.modelDraw.start = true
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
	
	local array    = {
		{ba.XSTR("Class", 739), entry.Name},
		{ba.XSTR("Type", 740), entry.Type},
		{ba.XSTR("Length", 741), entry.Length},
		{ba.XSTR("Max Velocity", 742), entry.Velocity},
		{ba.XSTR("Maneuverability", 744), entry.Maneuverability},
		{ba.XSTR("Armor", 745), entry.Armor},
		{ba.XSTR("Gun Mounts", 746), entry.GunMounts},
		{ba.XSTR("Missile Banks", 747), entry.MissileBanks},
		{ba.XSTR("Manufacturer", 748), entry.Manufacturer}
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
end

function ShipSelectController:UpdatePoolCount(id, count)
	local countEl = self.document:GetElementById(id).first_child.first_child
	countEl.inner_rml = count
end

function ShipSelectController:UpdateSlotImage(element, img)
	local imgEl = self.document:CreateElement("img")
	imgEl:SetAttribute("src", img)
	self.document:GetElementById(element.id):RemoveChild(element.first_child)
	self.document:GetElementById(element.id):AppendChild(imgEl)
	element:SetClass("drag", true)
	element:SetClass("button_3", true)
end

function ShipSelectController:DragPoolEnd(element, entry, shipIndex)
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		--Get the pool amount of the ship we're dragging
		local count = loadoutHandler:GetShipPoolAmount(shipIndex)
		
		--If the pool count is 0 then abort!
		if count < 1 then
			self.replace = nil
			return
		end

		local targetSlot = loadoutHandler:GetShipLoadout(self.activeSlot)
		
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
			replace_el:AddEventListener("click", function(_, _, _)
				self:SelectEntry(entry)
			end)
			
			loadoutHandler:SetFilled(self.activeSlot, true)
			
			--Now set the new ship and weapons
			loadoutHandler:AddShipToSlot(self.activeSlot, shipIndex)
			
			self.replace = nil
		end
	end
end

function ShipSelectController:DragSlotEnd(element, entry, slot)
	if (self.replace ~= nil) and (self.activeSlot > 0) then
		local targetSlot = loadoutHandler:GetShipLoadout(self.activeSlot)
		local currentSlot = loadoutHandler:GetShipLoadout(slot)
		
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
		replace_el:AddEventListener("click", function(_, _, _)
			self:SelectEntry(entry)
		end)
		
		element.first_child:SetAttribute("src", loadoutHandler:getEmptyWingSlot()[2])
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
		
		--If the target slot has a ship in it then return it
		if sourceSlot.ShipClassIndex > 0 then
			--Get the amount of the ship we're sending back
			local key = loadoutHandler:GetShipInfo(sourceSlot.ShipClassIndex).Name
			self:UpdatePoolCount(key, loadoutHandler:GetShipPoolAmount(sourceSlot.ShipClassIndex) + 1)
			loadoutHandler:ReturnShipToPool(slot)
		end
		element:SetClass("drag", false)
		
		element.first_child:SetAttribute("src", loadoutHandler:getEmptyWingSlot()[2])
		loadoutHandler:ReturnShipToPool(slot)
		loadoutHandler:TakeShipFromSlot(slot)
	end
end

function ShipSelectController:Show(text, title, buttons)
	--Create a simple dialog box with the text and title

	currentDialog = true
	ScpuiSystem.modelDraw.save = ScpuiSystem.modelDraw.class
	ScpuiSystem.modelDraw.class = nil
	
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
		if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
			ScpuiSystem.music_handle:close(true)
		end
		ScpuiSystem.music_handle = nil
		ScpuiSystem.current_played = nil
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
	ScpuiSystem.modelDraw.class = nil
	
	if self.Commit == true then
		loadoutHandler:unloadAll()
	end
end

function ShipSelectController:startMusic()
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

function ShipSelectController:drawSelectModel()

	if ScpuiSystem.modelDraw.class and ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then  --Haaaaaaacks

		--local thisItem = tb.ShipClasses(modelDraw.class)
		
		local modelView = ScpuiSystem.modelDraw.element	
		local modelLeft = modelView.parent_node.offset_left + modelView.offset_left --This is pretty messy, but it's functional
		local modelTop = modelView.parent_node.offset_top + modelView.parent_node.parent_node.offset_top + modelView.offset_top
		local modelWidth = modelView.offset_width
		local modelHeight = modelView.offset_height
		
		--This is just a multipler to make the rendered model a little bigger
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
		
		local test = tb.ShipClasses[ScpuiSystem.modelDraw.class]:renderSelectModel(ScpuiSystem.modelDraw.start, modelLeft, modelTop, modelWidth, modelHeight)
		
		ScpuiSystem.modelDraw.start = false
		
	end

end

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_SHIP_SELECT" then
		ShipSelectController:drawSelectModel()
	end
end, {}, function()
    return false
end)

return ShipSelectController
