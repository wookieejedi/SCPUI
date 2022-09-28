local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local ShipSelectController = class()

function ShipSelectController:init()
	self.Counter = 0
end

function ShipSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document
	self.elements = {}
	self.slots = {}

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
	
	ui.ShipWepSelect.initSelect()
	
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
	
	if self.list[1].Name then
		self:SelectEntry(self.list[1])
	end
	
	self:InitSlots()
			
	
	--[[local loadout = ui.ShipWepSelect.Loadout_Wings[1]
	--ba.warning(#ui.ShipWepSelect.Loadout_Wings .. " " .. loadout.Name)
	one = loadout[1]
	two = loadout[2]
	three = loadout[3]
	four = loadout[4]
	
	local all = ""
	
	local i = 1
	while (i < 5) do
		all = all .. tostring(loadout[i].isDisabled) .. " "
		i = i + 1
	end
	--ba.warning(all)
	
	local all = ""
	
	local i = 1
	while (i < 5) do
		local idx = loadout[i].ShipClassIndex
		local name = tb.ShipClasses[idx].Name
		all = all .. name .. " "
		i = i + 1
	end
	--ba.warning(all)
	
	local idx = loadout[2].ShipClassIndex
	--ba.warning("Num " .. tb.ShipClasses[idx].Name .. "s avail is " .. ui.ShipWepSelect.Ship_Pool[idx])
	
	local Widx = 5
	--ba.warning("Num " .. tb.WeaponClasses[Widx].Name .. "s avail is " .. ui.ShipWepSelect.Weapon_Pool[Widx])
	
	local ship = ui.ShipWepSelect.Loadout_Ships[1]
	--ba.warning(tb.ShipClasses[ships.ShipClassIndex].Name)
	local weapon1 = ship.Weapons[1]
	local amount1 = ship.Amounts[1]
	local weapon2 = ship.Weapons[2]
	local amount2 = ship.Amounts[2]
	local weapon3 = ship.Weapons[4]
	local amount3 = ship.Amounts[4]
	local weapon4 = ship.Weapons[5]
	local amount4 = ship.Amounts[5]
	ba.warning("Ship in slot 1 is " .. tb.ShipClasses[ship.ShipClassIndex].Name .. " and the loaded weapons are " .. tb.WeaponClasses[weapon1].Name .. " with amount " .. amount1 .. ", " .. tb.WeaponClasses[weapon2].Name .. " with amount " .. amount2 .. ", " .. tb.WeaponClasses[weapon3].Name .. " with amount " .. amount3 .. ", " .. tb.WeaponClasses[weapon4].Name .. " with amount " .. amount4)

	--ship.ShipClassIndex = 1
	ui.ShipWepSelect.Loadout_Ships[1].ShipClassIndex = 5
	ui.ShipWepSelect.Loadout_Ships[1].Weapons[1] = 1
	ui.ShipWepSelect.Loadout_Ships[1].Amounts[1] = 1
	ui.ShipWepSelect.Loadout_Ships[1].Weapons[2] = 8
	ui.ShipWepSelect.Loadout_Ships[1].Amounts[2] = 1
	ui.ShipWepSelect.Loadout_Ships[1].Weapons[4] = (11 +52)
	ui.ShipWepSelect.Loadout_Ships[1].Amounts[4] = 1000
	ui.ShipWepSelect.Loadout_Ships[1].Weapons[5] = (6 + 52)
	ui.ShipWepSelect.Loadout_Ships[1].Amounts[5] = 1000
	
	local weapon1 = ship.Weapons[1]
	local amount1 = ship.Amounts[1]
	local weapon2 = ship.Weapons[2]
	local amount2 = ship.Amounts[2]
	local weapon3 = ship.Weapons[4]
	local amount3 = ship.Amounts[4]
	local weapon4 = ship.Weapons[5]
	local amount4 = ship.Amounts[5]
	
	ba.warning("Ship in slot 1 is " .. tb.ShipClasses[ship.ShipClassIndex].Name .. " and the loaded weapons are " .. tb.WeaponClasses[weapon1].Name .. " with amount " .. amount1 .. ", " .. tb.WeaponClasses[weapon2].Name .. " with amount " .. amount2 .. ", " .. tb.WeaponClasses[weapon3].Name .. " with amount " .. amount3 .. ", " .. tb.WeaponClasses[weapon4].Name .. " with amount " .. amount4)]]--

end

function ShipSelectController:InitSlots()

	local slotNum = 1
	for i = 1, #ui.ShipWepSelect.Loadout_Wings, 1 do
		for j = 1, #ui.ShipWepSelect.Loadout_Wings[i], 1 do
			self.slots[slotNum] = {}
			if ui.ShipWepSelect.Loadout_Wings[i][j].isDisabled then
				self.slots[slotNum].isDisabled = true
			else
				self.slots[slotNum].isDisabled = false
			end
			self.slots[slotNum].Class = nil
			slotNum = slotNum + 1
		end
	end

end

function ShipSelectController:ReloadList()

	local list_items_el = self.document:GetElementById("ship_icon_list_ul")
	self:ClearEntries(list_items_el)
	self.SelectedEntry = nil
	self.visibleList = {}
	self.Counter = 0
	self:CreateEntries(self.list)
	self:SelectEntry(self.visibleList[1])

end

function ShipSelectController:CreateEntryItem(entry, idx)

	self.Counter = self.Counter + 1

	local li_el = self.document:CreateElement("li")
	local iconWrapper = self.document:CreateElement("div")
	iconWrapper.id = entry.Name
	
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
	iconEl:SetClass("button_1", true)
	iconEl:SetClass("icon", true)
	iconEl:AddEventListener("click", function(_, _, _)
		self:SelectEntry(entry)
	end)
	iconEl:AddEventListener("dragend", function(_, _, _)
		self:DragEnd(iconEl, entry.Name, entry.Index)
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
		
		local thisEntry = self.document:GetElementById(entry.key)
		self.SelectedEntry = entry.key
		--self.SelectedIndex = entry.Index
		thisEntry:SetPseudoClass("checked", true)
		
		self:BuildInfo(entry)
		
		local aniWrapper = self.document:GetElementById("ship_view")
		aniWrapper:RemoveChild(aniWrapper.first_child)
		local aniEl = self.document:CreateElement("ani")
		aniEl:SetAttribute("src", entry.Anim)
		aniEl:SetClass("anim", true)
		aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
		
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

function ShipSelectController:BuildShipList()

	

end

function ShipSelectController:DragOver(element, slot)
	self.replace = element
	self.activeSlot = slot
end

function ShipSelectController:DragEnd(element, class, index)
	if self.replace ~= nil then
		if self.slots[self.activeSlot].Class == nil then
			self.slots[self.activeSlot].Class = class
			local countEl = self.document:GetElementById(class).first_child
			local count = tonumber(countEl.first_child.inner_rml) - 1
			countEl.first_child.inner_rml = count
		else
			local countEl = self.document:GetElementById(self.slots[self.activeSlot].Class).first_child
			local count = tonumber(countEl.first_child.inner_rml) + 1
			countEl.first_child.inner_rml = count
			self.slots[self.activeSlot].Class = class
			local countEl = self.document:GetElementById(class).first_child
			local count = tonumber(countEl.first_child.inner_rml) - 1
			countEl.first_child.inner_rml = count
		end
		local replace_el = self.document:GetElementById(self.replace.id)
		local icon_el = self.document:GetElementById(element.id)
		local imgEl = self.document:CreateElement("img")
		imgEl:SetAttribute("src", element:GetAttribute("src"))
		self.document:GetElementById(replace_el.id):RemoveChild(replace_el.first_child)
		self.document:GetElementById(replace_el.id):AppendChild(imgEl)
		
		ui.ShipWepSelect.Loadout_Ships[self.activeSlot].ShipClassIndex = index
		self:SetDefaultWeapons(self.activeSlot, index)
		self.replace = nil
	end
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

function ShipSelectController:accept_pressed()
    
	drawMap = nil
	--ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
	local errorValue = ui.Briefing.commitToMission()
	
	--ba.warning(errorValue)

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
