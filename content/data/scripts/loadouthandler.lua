local LoadoutHandler = {}

function LoadoutHandler:init()
	if not ScpuiSystem.selectInit then
		ui.ShipWepSelect.initSelect()
		ui.ShipWepSelect.resetSelect()
		ScpuiSystem.selectInit = true
		ScpuiSystem.loadouts = {
			shipPool = {},
			weaponPool = {},
			slots = {},
			shipInfo = {},
			primaryInfo = {},
			secondaryInfo = {},
			emptyWingSlot = {},
			WING_SIZE = 4,
			MAX_PRIMARIES = 3,
			MAX_SECONDARIES = 4
		}
		
		self:generateEmptySlotFrames()
		self:getLoadout()
		self:generateShipInfo()
		self:generateWeaponInfo()
		self:ValidateInfo()
		self:cleanLoadoutShips()
		self:backupLoadout()
		self:getSavedLoadouts()
		self:maybeApplySavedLoadout()
		
		--For BtA: Set the initial countermeasures
		self:initCountermeasureSlots()
	end
end

function LoadoutHandler:unloadAll()
	ScpuiSystem.loadouts = nil
	ScpuiSystem.savedLoadouts = nil
	ScpuiSystem.backupLoadout = nil
	
	ScpuiSystem.selectInit = nil
end

function LoadoutHandler:getSavedLoadouts()
	
	ScpuiSystem.savedLoadouts = self:loadLoadoutsFromFile()
	
	if ScpuiSystem.savedLoadouts == nil then
		ScpuiSystem.savedLoadouts = {}
	end
	
	self:cleanSavedLoadouts()
	
end

--Cleans out loadout data for mission files that do not exist in the currently loaded mod
--This is ok because loadout save data is specific to mod versions and not FSO/player-wide
function LoadoutHandler:cleanSavedLoadouts()

	for k, _ in pairs(ScpuiSystem.savedLoadouts) do
		local file = k
		
		--If we have a key of two characters or less then that shouldn't be there. Clear it.
		if #file <= 2 then
			ScpuiSystem.savedLoadouts[k] = nil
			ba.print("SCPUI deleted the saved loadout `" .. k .. "' because the mission file does not exist!\n")
		else
			file =  string.sub(file, 1, #file - 2)
			
			--If the mission file doesn't exist, then remove the save data.
			if not cf.fileExists(file .. ".fs2", "", true) then
				ScpuiSystem.savedLoadouts[k] = nil
				ba.print("SCPUI deleted the saved loadout `" .. k .. "' because the mission file does not exist!\n")
			end
		end
	end

end

function LoadoutHandler:saveCurrentLoadout()
	
	local key = self:getMissionKey()
	
	ScpuiSystem.savedLoadouts[key] = {
		shipPool = ScpuiSystem.loadouts.shipPool,
		weaponPool = ScpuiSystem.loadouts.weaponPool,
		slots = ScpuiSystem.loadouts.slots,
		numShipClasses = #tb.ShipClasses,
		numWepClasses = #tb.WeaponClasses
	}
	self:saveLoadoutsToFile(ScpuiSystem.savedLoadouts)
end

function LoadoutHandler:maybeApplySavedLoadout()

	--For BtA: If backstock has updated then we must not load saved loadouts!
	if backstock.updated == true and mn.isInCampaign() then
		backstock.updated = nil
		return
	end
	
	local key = self:getMissionKey()
	
	if ScpuiSystem.savedLoadouts[key] ~= nil then
		
		--Check here that the number of ship & weapon classes at the time of save is equal to the number that exist now
		if ScpuiSystem.savedLoadouts[key].numShipClasses == #tb.ShipClasses and ScpuiSystem.savedLoadouts[key].numWepClasses == #tb.WeaponClasses then
			ScpuiSystem.loadouts.shipPool = ScpuiSystem.savedLoadouts[key].shipPool
			ScpuiSystem.loadouts.weaponPool = ScpuiSystem.savedLoadouts[key].weaponPool
			ScpuiSystem.loadouts.slots = ScpuiSystem.savedLoadouts[key].slots
		else
			--If the class counts don't match then the saved loadout is invalid. Might as well clear it.
			ScpuiSystem.savedLoadouts[key] = nil
		end
	end
	
end

function LoadoutHandler:getLoadout()	
	ScpuiSystem.loadouts.shipPool = self:getPool(ui.ShipWepSelect.Ship_Pool)
	ScpuiSystem.loadouts.weaponPool = self:getPool(ui.ShipWepSelect.Weapon_Pool)
	ScpuiSystem.loadouts.slots = self:getSlots()
end

function LoadoutHandler:cleanLoadoutShips()
	--For BtA: Check Inventory availability of all the ships
	if mn.isInCampaign() and string.sub(mn.getMissionFilename(), 1, 4) == "bta2" then
		self:applyInventoryLimits()
	end
	
	--FSO must have internal code to remove ships in wings from the pool
	--so let's do that manually here
	for i = 1, #ScpuiSystem.loadouts.slots do
		if ScpuiSystem.loadouts.slots[i].ShipClassIndex > 0 then
			self:TakeShipFromPool(ScpuiSystem.loadouts.slots[i].ShipClassIndex)
		end
	end
end

--For BtA: Here we apply limits set by the Inventory system in BtA2
function LoadoutHandler:applyInventoryLimits()

	--Make a copy of Inventory temporarily so we can decrement ship availability
	--as we go without messing with the actual Inventory data
	local utils = require("utils")
	local inventory = utils.copy(backstock.current.ships)
	local priorities = self:getPriorityList()
	
	if inventory == nil then
		ba.error("Inventory list is invalid in loadout handler!")
	end
	
	if priorities == nil then
		ba.error("Priority list is invalid in loadout handler!")
	end

	for i=1, self:GetNumSlots() do
		local ship = self:GetShipLoadout(i)
		
		local wing = string.lower(ship.WingName)
		
		--Only apply Inventory limits to Alpha, Beta, and Gamma wings
		if wing == "alpha" or wing == "beta" or wing == "gamma" then

			for _, v in pairs(inventory) do
				if v.name == tb.ShipClasses[ship.ShipClassIndex].Name then

					--We have this ship available, so decrement and continue
					if v.remaining > 0 then
						v.remaining = v.remaining - 1
					else --We ran out of this ship class. Now find a new one!
						v.remaining = 0
						local p_type = self:getShipPriority(v.name, priorities)
						local newShipClass = self:getNextShipFromInventory(inventory, p_type, priorities)
						if newShipClass then
							self:AddShipToSlot(i, newShipClass)
						else
							self:TakeShipFromSlot(i)
						end
						
					end
					
					break
					
				end
			end
			
		end
	end
	
end

--For BtA: Find the next available ship. This will be updated with a better
--version soon (tm)
function LoadoutHandler:getNextShipFromInventory(inventory, p_type, priorities)
	
	if p_type == nil then
		ba.warning("Current ship does not have a priority type! Using next available ship in Inventory!")
		
		for i, v in pairs(inventory) do
			if v.remaining > 0 then
				v.remaining = v.remaining - 1
				local idx = tb.ShipClasses[v.name]:getShipClassIndex()
				
				return idx
			end
		end
	else
		for i = 1, #priorities do
		
			for _, n in ipairs(priorities[p_type]) do
				for _, v in pairs(inventory) do
					if v.name == n then
						if v.remaining > 0 then
							local idx = tb.ShipClasses[v.name]:getShipClassIndex()
							--Make sure this ship is allowed in this mission's loadout as well
							if self:GetShipInfo(idx) ~= nil then
								v.remaining = v.remaining - 1
								return idx
							end
						end
					end
				end
			end
			
			p_type = p_type + 1
			
			if p_type > #priorities then
				p_type = 1
			end
			
		end
	end

end

--For BtA: Get a ship's priority type
function LoadoutHandler:getShipPriority(shipName, priorities)
	for i, _ in ipairs(priorities) do
		for _, v in ipairs(priorities[i]) do
			if v == shipName then
				return i
			end
		end
	end
	
	return nil
end

--For BtA: Load the ship_priority.cfg data
function LoadoutHandler:getPriorityList()
	local json = require('dkjson')
	
	--Loadouts are explicitely not saved across mod versions
	local location = 'data/config'
  
	local file = nil
	local config = {}
  
	if cf.fileExists('ship_priority.cfg') then
		file = cf.openFile('ship_priority.cfg', 'r', location)
		config = json.decode(file:read('*a'))
		file:close()
		if not config then
			config = {}
		end
	end
	
	--Validate the list
	for i, _ in ipairs(config) do
		for _, v in ipairs(config[i]) do
			if not tb.ShipClasses[v]:isValid() then
				ba.warning("Ship '" .. v .. "' is not a valid ship!")
			end
		end
	end
  
	return config
end

function LoadoutHandler:getPool(pool)
	data = {}
	for i = 1, #pool do
		data[i] = pool[i]
	end
	return data
end

--Here we make a complete lua copy of all the loadout information so we can
--mess with it as much as we want without having to worry about FSO getting
--in the way. The loadout will be saved on mission close or cancel
function LoadoutHandler:getSlots()
	local slots = {}
	
	for i = 1, #ui.ShipWepSelect.Loadout_Ships do
		local data = {}
		data.Weapons = self:parseWeapons(i)
		data.Amounts = self:parseAmounts(i)
		data.ShipClassIndex = ui.ShipWepSelect.Loadout_Ships[i].ShipClassIndex
		
		local wing, wingSlot = self:GetWingSlot(i)
		
		data.Name = ui.ShipWepSelect.Loadout_Wings[wing].Name .. " " .. wingSlot
		data.WingName = ui.ShipWepSelect.Loadout_Wings[wing].Name
		data.Wing = wing
		data.WingSlot = wingSlot
		data.isShipLocked = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isShipLocked
		data.isWeaponLocked = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isWeaponLocked
		data.isDisabled = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isDisabled
		data.isFilled = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isFilled
		data.isPlayer = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isPlayer
		
		slots[i] = data
	end
	
	return slots
end

function LoadoutHandler:parseWeapons(ship)
	local data = {}
	
	for i=1, #ui.ShipWepSelect.Loadout_Ships[ship].Weapons do
		if ui.ShipWepSelect.Loadout_Ships[ship].ShipClassIndex > 0 then
			data[i] = ui.ShipWepSelect.Loadout_Ships[ship].Weapons[i]
		else
			data[i] = -1
		end
	end
	
	return data
end

function LoadoutHandler:parseAmounts(ship)
	local data = {}
	
	for i=1, #ui.ShipWepSelect.Loadout_Ships[ship].Amounts do
		if ui.ShipWepSelect.Loadout_Ships[ship].ShipClassIndex > 0 then
			data[i] = ui.ShipWepSelect.Loadout_Ships[ship].Amounts[i]
		else
			data[i] = -1
		end
	end
	
	return data
end

function LoadoutHandler:backupLoadout()
	local utils = require("utils")
	ScpuiSystem.backupLoadout = {}
	ScpuiSystem.backupLoadout = utils.copy(ScpuiSystem.loadouts)
end

function LoadoutHandler:resetLoadout()
	if ScpuiSystem.backupLoadout ~= nil then
		local utils = require("utils")
		ScpuiSystem.loadouts = {}
		ScpuiSystem.loadouts = utils.copy(ScpuiSystem.backupLoadout)
	else
		ba.warning("Backup loadout was nil! Find Mjn!")
	end
end

function LoadoutHandler:generateShipInfo()
	local shipList = tb.ShipClasses
	local i = 1
	while (i ~= #shipList) do
		if self:GetShipPoolAmount(i) > 0 then
			if rocketUiIcons[shipList[i].Name] == nil then
				ba.warning("No generated icon was found for " .. shipList[i].Name .. "! Generating one now.")
				ScpuiSystem:setIconFrames(shipList[i].Name)
			end
			self:AppendToShipInfo(i)
		end
		i = i + 1
	end
	

	for i = 1, self:GetNumSlots() do
		if not self:IsSlotDisabled(i) then
			local shipIdx = self:GetShipLoadout(i).ShipClassIndex
			if shipIdx > 0 then
				local ship = self:GetShipInfo(shipIdx)	
				if ship == nil then
					self:AppendToShipInfo(shipIdx)
				end
			end
		end
	end

	table.sort(ScpuiSystem.loadouts.shipInfo, function(a,b) return a.Index < b.Index end)

end

function LoadoutHandler:AppendToShipInfo(shipIdx)

	if rocketUiIcons[tb.ShipClasses[shipIdx].Name] == nil then
		ba.warning("No generated icon was found for " .. tb.ShipClasses[shipIdx].Name .. "! Generating one now.")
		ScpuiSystem:setIconFrames(tb.ShipClasses[shipIdx].Name, true)
	end

	local i = #ScpuiSystem.loadouts.shipInfo + 1
	ScpuiSystem.loadouts.shipInfo[i] = {
		Index = tb.ShipClasses[shipIdx]:getShipClassIndex(),
		Amount = self:GetShipPoolAmount(shipIdx),
		Icon = tb.ShipClasses[shipIdx].SelectIconFilename,
		GeneratedIcon = {},
		Anim = tb.ShipClasses[shipIdx].SelectAnimFilename,
		Name = tb.ShipClasses[shipIdx].Name,
		Type = tb.ShipClasses[shipIdx].TypeString,
		Length = tb.ShipClasses[shipIdx].LengthString,
		Velocity = tb.ShipClasses[shipIdx].VelocityString,
		Maneuverability = tb.ShipClasses[shipIdx].ManeuverabilityString,
		Armor = tb.ShipClasses[shipIdx].ArmorString,
		GunMounts = tb.ShipClasses[shipIdx].GunMountsString,
		MissileBanks = tb.ShipClasses[shipIdx].MissileBanksString,
		Manufacturer = tb.ShipClasses[shipIdx].ManufacturerString,
		key = tb.ShipClasses[shipIdx].Name,
		GeneratedWidth = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Width,
		GeneratedHeight = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Height,
		GeneratedIcon = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Icon
	}
	return ScpuiSystem.loadouts.shipInfo[i]
end

function LoadoutHandler:generateWeaponInfo()
	local weaponList = tb.WeaponClasses
	local i = 1
	while (i ~= #weaponList) do
		if self:GetWeaponPoolAmount(i) > 0 then
			if rocketUiIcons[weaponList[i].Name] == nil then
				ba.warning("No generated icon was found for " .. weaponList[i].Name .. "! Generating one now.")
				ScpuiSystem:setIconFrames(weaponList[i].Name)
			end
			self:AppendToWeaponInfo(i)
		end
		i = i + 1
	end

	for i = 1, self:GetNumSlots() do
		if not self:IsSlotDisabled(i) then
			local ship = self:GetShipLoadout(i)
			if ship.ShipClassIndex > 0 then
				for j = 1, #ship.Weapons do
					local wepIdx = ship.Weapons[j]
					if ship.Amounts[j] > 0 then
						wep = self:GetWeaponInfo(wepIdx)
						if wep == nil then
							self:AppendToWeaponInfo(wepIdx)
						end
					end
				end
			end
		end
	end
	
	table.sort(ScpuiSystem.loadouts.primaryInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.loadouts.secondaryInfo, function(a,b) return a.Index < b.Index end)

end

function LoadoutHandler:AppendToWeaponInfo(wepIdx)
	
	if rocketUiIcons[tb.WeaponClasses[wepIdx].Name] == nil then
		ba.warning("No generated icon was found for " .. tb.WeaponClasses[wepIdx].Name .. "! Generating one now.")
		ScpuiSystem:setIconFrames(tb.WeaponClasses[wepIdx].Name)
	end
	
	local data = {}
	local type_v = nil
	if tb.WeaponClasses[wepIdx]:isPrimary() then
		type_v = "primary"
	else
		type_v = "secondary"
	end
	data = {
		Index = wepIdx,
		Amount = self:GetWeaponPoolAmount(wepIdx),
		Icon = tb.WeaponClasses[wepIdx].SelectIconFilename,
		GeneratedIcon = {},
		Anim = tb.WeaponClasses[wepIdx].SelectAnimFilename,
		Name = tb.WeaponClasses[wepIdx].Name,
		Title = tb.WeaponClasses[wepIdx].TechTitle,
		Description = string.gsub(tb.WeaponClasses[wepIdx].Description, "Level", "<br></br>Level"),
		Velocity = math.floor(tb.WeaponClasses[wepIdx].Speed*10)/10,
		Range = math.floor(tb.WeaponClasses[wepIdx].Speed*tb.WeaponClasses[wepIdx].LifeMax*10)/10,
		Damage = math.floor(tb.WeaponClasses[wepIdx].Damage*10)/10,
		ArmorFactor = math.floor(tb.WeaponClasses[wepIdx].ArmorFactor*10)/10,
		ShieldFactor = math.floor(tb.WeaponClasses[wepIdx].ShieldFactor*10)/10,
		SubsystemFactor = math.floor(tb.WeaponClasses[wepIdx].SubsystemFactor*10)/10,
		FireWait = math.floor(tb.WeaponClasses[wepIdx].FireWait*10)/10,
		Power = tb.WeaponClasses[wepIdx].EnergyConsumed,
		Type = type_v,
		key = tb.WeaponClasses[wepIdx].Name,
		GeneratedWidth = rocketUiIcons[tb.WeaponClasses[wepIdx].Name].Width,
		GeneratedHeight = rocketUiIcons[tb.WeaponClasses[wepIdx].Name].Height,
		GeneratedIcon = rocketUiIcons[tb.WeaponClasses[wepIdx].Name].Icon
	}
	
	if tb.WeaponClasses[wepIdx]:isPrimary() then
		local i = #ScpuiSystem.loadouts.primaryInfo + 1
		ScpuiSystem.loadouts.primaryInfo[i] = data
		return ScpuiSystem.loadouts.primaryInfo[i]
	else
		local i = #ScpuiSystem.loadouts.secondaryInfo + 1
		ScpuiSystem.loadouts.secondaryInfo[i] = data
		return ScpuiSystem.loadouts.secondaryInfo[i]
	end
end

function LoadoutHandler:generateEmptySlotFrames()
	if ScpuiSystem.loadouts.emptyWingSlot == nil then
		ScpuiSystem.loadouts.emptyWingSlot = {}
	end
	
	--Create a texture and then draw to it, save the output
	local imag_h = gr.loadTexture("iconwing01", true, true)
	local width = 128
	local height = 128
	local tex_h = gr.createTexture(width, height)
	local color = gr.createColor(0, 128, 128, 255)
	local saveColor = gr.getColor(true)
	gr.setTarget(tex_h)
	for j = 1, 2, 1 do
		gr.clearScreen(0,0,0,0)
		gr.setColor(color)
		gr.setLineWidth(5)
		--Make the big X
		gr.drawLine(0, 0, 128, 128)
		gr.drawLine(0, 128, 128, 0)
		--Maybe make the small Xs
		if j == 2 then
			gr.drawLine(0, 64, 64, 0)
			gr.drawLine(0, 64, 64, 128)
			gr.drawLine(128, 64, 64, 0)
			gr.drawLine(128, 64, 64, 128)
		end
		ScpuiSystem.loadouts.emptyWingSlot[j] = gr.screenToBlob()
	end
	ScpuiSystem.loadouts.emptyWingSlot.GeneratedWidth = width
	ScpuiSystem.loadouts.emptyWingSlot.GeneratedHeight = height
	
	--clean up
	gr.setColor(saveColor)
	gr.setTarget()
	imag_h:unload()
	tex_h:unload()

end

function LoadoutHandler:getEmptyWingSlot()
	return ScpuiSystem.loadouts.emptyWingSlot
end

function LoadoutHandler:GetShipInfo(shipIndex)

	for i, v in ipairs(ScpuiSystem.loadouts.shipInfo) do
		if v.Index == shipIndex then
			return v
		end
	end
	
	return nil

end

function LoadoutHandler:GetPrimaryInfo(wepIndex)

	for i, v in ipairs(ScpuiSystem.loadouts.primaryInfo) do
		if v.Index == wepIndex then
			return v
		end
	end
	
	return nil

end

function LoadoutHandler:GetSecondaryInfo(wepIndex)
	
	for i, v in ipairs(ScpuiSystem.loadouts.secondaryInfo) do
		if v.Index == wepIndex then
			return v
		end
	end
	
	return nil

end

function LoadoutHandler:GetWeaponInfo(wepIndex)
	if tb.WeaponClasses[wepIndex]:isPrimary() then
		return self:GetPrimaryInfo(wepIndex)
	elseif tb.WeaponClasses[wepIndex]:isSecondary() then
		return self:GetSecondaryInfo(wepIndex)
	else
		return nil
	end
end

function LoadoutHandler:ValidateInfo()

	--Validate ships
	for i = 1, #ScpuiSystem.loadouts.slots do
		if not self:IsSlotDisabled(i) then
			local shipIdx = ScpuiSystem.loadouts.slots[i].ShipClassIndex
			if shipIdx > 0 then
				if self:GetShipInfo(shipIdx) == nil then
					self:AppendToShipInfo(shipIdx)
				end
			end
		end
	end
	
	--Validate weapons
	for i = 1, #ScpuiSystem.loadouts.slots, 1 do
		if not self:IsSlotDisabled(i) then
			if ScpuiSystem.loadouts.slots[i].ShipClassIndex > 0 then
				for j = 1, #ScpuiSystem.loadouts.slots[i].Weapons, 1 do
					local wepIdx = ScpuiSystem.loadouts.slots[i].Weapons[j]
					if ScpuiSystem.loadouts.slots[i].Amounts[j] > 0 then
						if self:GetWeaponInfo(wepIdx) == nil then
							self:AppendToWeaponInfo(wepIdx)
						end
					end
				end
			end
		end
	end
	
	--Sort the tables by index
	table.sort(ScpuiSystem.loadouts.shipInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.loadouts.primaryInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.loadouts.secondaryInfo, function(a,b) return a.Index < b.Index end)

end

function LoadoutHandler:GetMaxPrimaries()
	return ScpuiSystem.loadouts.MAX_PRIMARIES
end

function LoadoutHandler:GetMaxSecondaries()
	return ScpuiSystem.loadouts.MAX_SECONDARIES
end

function LoadoutHandler:GetMaxBanks()
	return ScpuiSystem.loadouts.MAX_PRIMARIES + ScpuiSystem.loadouts.MAX_SECONDARIES
end

function LoadoutHandler:GetNumWings()
	return #ui.ShipWepSelect.Loadout_Wings
end

function LoadoutHandler:GetNumWingSlots(wing)
	return #ui.ShipWepSelect.Loadout_Wings[wing]
end

function LoadoutHandler:IsSlotDisabled(slot)
	return ScpuiSystem.loadouts.slots[slot].isDisabled
end

--Checks if a weapon is allowed on a specific ship
function LoadoutHandler:IsWeaponAllowed(shipIndex, weaponIndex)

	local primaryBanks = tb.ShipClasses[shipIndex].numPrimaryBanks
	local secondaryBanks = tb.ShipClasses[shipIndex].numSecondaryBanks
	local actualBank = nil
	
	if tb.WeaponClasses[weaponIndex]:isPrimary() then
		actualBank = self:ConvertBankSlotToBank(shipIndex, self.activeSlot, 1, true)
	else
		actualBank = self:ConvertBankSlotToBank(shipIndex, self.activeSlot, 2, true)
	end

	if actualBank == -1 then
		return false
	else
		return tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(weaponIndex, actualBank)
	end

end

--Get the entire ship info list
function LoadoutHandler:GetShipList()
	return ScpuiSystem.loadouts.shipInfo
end

--Get the entire primary weapon info list
function LoadoutHandler:GetPrimaryWeaponList()
	return ScpuiSystem.loadouts.primaryInfo
end

--Get the entire secondary weapon info list
function LoadoutHandler:GetSecondaryWeaponList()
	return ScpuiSystem.loadouts.secondaryInfo
end

--Get the entire ship info list
function LoadoutHandler:GetNumShips()
	return #ScpuiSystem.loadouts.shipInfo
end

--Get the entire primary weapon info list
function LoadoutHandler:GetNumPrimaryWeapons()
	return #ScpuiSystem.loadouts.primaryInfo
end

--Get the entire secondary weapon info list
function LoadoutHandler:GetNumSecondaryWeapons()
	return #ScpuiSystem.loadouts.secondaryInfo
end

--Get total slots we have in the loadout
function LoadoutHandler:GetNumSlots()
	return #ScpuiSystem.loadouts.slots
end

--Get the max supported wing size
function LoadoutHandler:GetWingSize()
	return ScpuiSystem.loadouts.WING_SIZE
end

--Get a ship slot
function LoadoutHandler:GetShipLoadout(slot)
	return ScpuiSystem.loadouts.slots[slot]
end

--Get amount left in weapon pool
function LoadoutHandler:GetWeaponPoolAmount(idx)
	return ScpuiSystem.loadouts.weaponPool[idx]
end

--Get amount left in ship pool
function LoadoutHandler:GetShipPoolAmount(idx)
	return ScpuiSystem.loadouts.shipPool[idx]
end

--Convert slot index to wing/slot position
function LoadoutHandler:GetWingSlot(slot)

	local wingSize = self:GetWingSize()
	local wing = math.floor((slot - 1) / wingSize) + 1
	local slot = ((slot - 1) % wingSize) + 1
	
	return wing, slot
end

--Convert wing/slot position to slot index
function LoadoutHandler:GetSlotIndex(wing, slot)

	local wingSize = self:GetWingSize()
	
	return (wing - 1) * wingSize + slot
end

--This one converts the slot (1-7) to actual banks (1-3 for primaries, 1-4 for secondaries)
--if classSpecific is true then converts to actual banks on the specific ship class (1-N where N is the last secondary)
function LoadoutHandler:ConvertBankSlotToBank(ship, bank, w_type, classSpecific)
	local primaryBanks = tb.ShipClasses[ship].numPrimaryBanks
	local secondaryBanks = tb.ShipClasses[ship].numSecondaryBanks
	
	local mod = 0
	
	if classSpecific then
		mod = primaryBanks
	end

	if (bank <= 3) and (w_type == 1) then
		if bank > primaryBanks then
			return -1
		else
			return bank
		end
	elseif (bank <= 7)  and (w_type == 2) then
		if (bank - 3) > secondaryBanks then
			return -1
		else
			return bank - 3 + mod
		end
	else
		return -1
	end
end

--Returns true if a ship has a specific bank and false if not
function LoadoutHandler:ShipHasBank(ship, bank)
	local primaryBanks = tb.ShipClasses[ship].numPrimaryBanks
	local secondaryBanks = tb.ShipClasses[ship].numSecondaryBanks
	
	local MAX_BANKS = ScpuiSystem.loadouts.MAX_PRIMARIES + ScpuiSystem.loadouts.MAX_SECONDARIES
	
	if bank < 1 then return false end
	if bank > MAX_BANKS then return false end
	
	--primary bank
	if bank <= ScpuiSystem.loadouts.MAX_PRIMARIES then
		if bank <= primaryBanks then
			return true
		end
	else
		if bank <= (secondaryBanks + ScpuiSystem.loadouts.MAX_PRIMARIES) then
			return true
		end
	end
	
	return false
end

--Return true if weapon is allowed on this ship bank, false otherwise
function LoadoutHandler:IsWeaponAllowedInBank(shipIdx, weaponIdx, bank)
	
	local w_type = 1
	if bank > tb.ShipClasses[shipIdx].numPrimaryBanks then
		w_type = 2
	end
	
	if w_type == 2 and tb.WeaponClasses[weaponIdx]:isPrimary() then
		return false
	end
	
	if w_type == 1 and tb.WeaponClasses[weaponIdx]:isSecondary() then
		return false
	end
	
	local actualBankIdx = self:ConvertBankSlotToBank(shipIdx, bank, w_type, true)
	return tb.ShipClasses[shipIdx]:isWeaponAllowedOnShip(weaponIdx, actualBankIdx)
end

--Returns the amount a ship bank can carry for a specific weapon
--Returns -1 if weapon is not allowed on the ship
function LoadoutHandler:GetWeaponAmount(shipIndex, weaponIndex, bank)
	
	if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(weaponIndex) then
		--Primaries always get set to 1, even ballistics
		if tb.WeaponClasses[weaponIndex]:isPrimary() then
			return 1
		end
		
		local capacity = tb.ShipClasses[shipIndex]:getSecondaryBankCapacity(bank)
		local amount = capacity / tb.WeaponClasses[weaponIndex].CargoSize
		return math.floor(amount+0.5)
	else
		return -1
	end

end

--Get the weapon type between primary or secondary
function LoadoutHandler:GetWeaponType(weapon)
	if tb.WeaponClasses[weapon]:isPrimary() then
		return 1
	else
		return 2
	end
end

--Add to weapon amount in weapon pool
function LoadoutHandler:AddWeaponToPool(weapon, amount)
	
	if amount == nil then
		ba.warning("Trying to add weapon to pool, but amount was nil!")
		return
	end
	if weapon == nil then
		ba.warning("Trying to add weapon to pool, but weapon was nil!")
		return
	end
	
	if amount > 0 then
		local num = ScpuiSystem.loadouts.weaponPool[weapon]
		ScpuiSystem.loadouts.weaponPool[weapon] = num + amount
	end
end

--Subtract from weapon amount in weapon pool
function LoadoutHandler:SubtractWeaponFromPool(weapon, amount)
	
	if amount == nil then
		ba.warning("Trying to subtract weapon from pool, but amount was nil!")
		return
	end
	if weapon == nil then
		ba.warning("Trying to subtract weapon from pool, but weapon was nil!")
		return
	end

	if amount > 0 then
		local num = ScpuiSystem.loadouts.weaponPool[weapon]
		ScpuiSystem.loadouts.weaponPool[weapon] = num - amount
	end
end

--Add weapon to a weapon bank
function LoadoutHandler:AddWeaponToBank(slot, bank, weaponIdx, amount)
	local ship = self:GetShipLoadout(slot)
	local shipIdx = ship.ShipClassIndex
	local w_type = self:GetWeaponType(weaponIdx)
	local actualBank = self:ConvertBankSlotToBank(shipIdx, bank, w_type)
	local actualBankIdx = self:ConvertBankSlotToBank(shipIdx, bank, w_type, true)

	if tb.ShipClasses[shipIdx]:isWeaponAllowedOnShip(weaponIdx, actualBankIdx) then
		--Get the capacity the bank can hold of the source weapon
		local capacity = self:GetWeaponAmount(shipIdx, weaponIdx, actualBank)
		if amount == nil then
			amount = capacity
		else
			if amount > capacity then
				amount = capacity
			end
		end
		--Do we have that much in the pool?
		local count = self:GetWeaponPoolAmount(weaponIdx)
		if count < amount then
			amount = count
		end
		if amount > 0 then
			--Now add the weapon
			self:SubtractWeaponFromPool(weaponIdx, amount)
			ship.Weapons[bank] = weaponIdx
			ship.Amounts[bank] = amount
			return true
		end
	end
	
	return false
end	

--Empty a weapon bank, returning its contents to the weapon pool
function LoadoutHandler:EmptyWeaponBank(slot, bank, onlyEmpty)

	--If this is true then we do not return the weapon to the pool, just empty the bank
	if not onlyEmpty then
		onlyEmpty = false
	end

	local ship = self:GetShipLoadout(slot)
	local weapon = ship.Weapons[bank]
	local amount = ship.Amounts[bank]
	
	if amount == nil then
		ba.warning("Trying to empty weapon bank for slot " .. slot .. ", bank " .. bank .. ", but amount was nil!")
		return
	end
	if weapon == nil then
		ba.warning("Trying to empty weapon bank for slot " .. slot .. ", bank " .. bank .. ", but weapon was nil!")
		return
	end
	
	if weapon > 0 and amount > 0 then
	
		if onlyEmpty == false then
			self:AddWeaponToPool(weapon, amount)
		end
		
		ship.Weapons[bank] = -1
		ship.Amounts[bank] = -1
	
	end
end

--For BtA: Init the countermeasure slots
function LoadoutHandler:initCountermeasureSlots()
	BtACustomLoadouts["countermeasures"] = {}
	for i = 1, self:GetNumSlots() do
		local ship = self:GetShipLoadout(i)
		local cmType = ""
		if ship.ShipClassIndex > 0 then
			cmType = self:GetDefaultCountermeasure(ship.ShipClassIndex)
		end
		
		BtACustomLoadouts["countermeasures"][i] = {ship.Name, cmType}
	end
end

--For BtA: Empty the countermeasure slot
function LoadoutHandler:EmptyCountermeasureSlot(slot)
	
	if BtACustomLoadouts["countermeasures"] == nil then return end

	local ship = self:GetShipLoadout(slot)
	BtACustomLoadouts["countermeasures"][slot] = {ship.Name, ""}
end

--For BtA: Get the default countermeasure type for the ship class
function LoadoutHandler:GetDefaultCountermeasure(shipIdx)
	return tb.ShipClasses[shipIdx].CountermeasureClass.Name
end

--For BtA: Set the countermeasure slot to default
function LoadoutHandler:SetDefaultCountermeasure(slot)
	
	if BtACustomLoadouts["countermeasures"] == nil then return end
	
	local ship = self:GetShipLoadout(slot)
	local cmType = self:GetDefaultCountermeasure(ship.ShipClassIndex)
	BtACustomLoadouts["countermeasures"][slot] = {ship.Name, cmType}
end

--For BtA: Set the countermeasure slot
function LoadoutHandler:SetCountermeasure(slot, cmType)

	if BtACustomLoadouts["countermeasures"] == nil then return end

	if self:isCountermeasureTypeValid(cmType) then
		local ship = self:GetShipLoadout(slot)
		BtACustomLoadouts["countermeasures"][slot] = {ship.Name, cmType}
	else
		ba.warning("Tried to set invalid countermeasure type " .. cmType .. "!")
	end
end

--For BtA: Get the countermeasure in the slot
function LoadoutHandler:GetCountermeasure(slot)
	local cm = BtACustomLoadouts["countermeasures"][slot]
	return cm[2]
end

--For BtA: Get the list of allowed countermeasures for a ship class
function LoadoutHandler:GetAllowedCountermeasures(shipIdx)
	local allowedCMs = {}
	if tb.ShipClasses[shipIdx]:hasCustomData() then
		local cm_string = tb.ShipClasses[shipIdx].CustomData["allowedCMs"]	
		if cm_string ~= nil then
			include("util.lua")
			allowedCMs = split(cm_string, ",")
		end
	end
	
	return allowedCMs
end

--For BtA: Return true if slot can have countermeasure type, false otherwise
function LoadoutHandler:isCountermeasureAllowed(slot, cmType)
	local ship = self:GetShipLoadout(slot)
	
	if cmType == self:GetDefaultCountermeasure(ship.ShipClassIndex) then
		return true
	end
	
	local allowedCMs = self:GetAllowedCountermeasures(ship.ShipClassIndex)
	
	if #allowedCMs <= 0 then
		return false
	end
	
	for j, v in pairs(allowedCMs) do
		if cmType == v then
			return true
		end
	end
	
	return false
end

--For BtA: Get the list of valid countermeasure types
function LoadoutHandler:GetCountermeasureList()
	return BtACustomLoadouts["cm_types"]
end

--For BtA: Get the number of valid countermeasure types
function LoadoutHandler:GetNumCountermeasureTypes()
	return #BtACustomLoadouts["cm_types"]
end

--For BtA: Get the list of valid countermeasure types
function LoadoutHandler:GetCountermeasureInfo(index)
	return BtACustomLoadouts["cm_types"][index]
end

function LoadoutHandler:isCountermeasureTypeValid(cm)
	for i = 1, self:GetNumCountermeasureTypes() do
		local v = self:GetCountermeasureInfo(i)
		if v == cm then
			return true
		end
	end
	
	return false
end

function LoadoutHandler:SetFilled(slot, state)

	ship = self:GetShipLoadout(slot)
	
	ship.isFilled = state
	ship.ShipClassIndex = -1
	
end

function LoadoutHandler:TakeShipFromSlot(slot)
	
	ScpuiSystem.loadouts.slots[slot].Weapons = {}
	ScpuiSystem.loadouts.slots[slot].Amounts = {}
	self:SetFilled(slot, false)
	
	--For BtA: Empty the countermeasure slot
	self:EmptyCountermeasureSlot(slot)

end

function LoadoutHandler:AddShipToSlot(slot, shipIdx)

	ScpuiSystem.loadouts.slots[slot].ShipClassIndex = shipIdx
	self:SetDefaultWeapons(slot, shipIdx)
	
	--For BtA: Set the countermeasure slot to default
	self:SetDefaultCountermeasure(slot)

end

function LoadoutHandler:TakeShipFromPool(shipIdx)
	
	local amount = self:GetShipPoolAmount(shipIdx)

	if amount > 0 then
		ScpuiSystem.loadouts.shipPool[shipIdx] = amount - 1
	end

end

function LoadoutHandler:ReturnShipToPool(slot)

	--Return all the weapons to the pool
	local ship = self:GetShipLoadout(slot)
	for i = 1, #ship.Weapons do
		self:EmptyWeaponBank(slot, i)
	end
	
	--Return the ship
	local amount = self:GetShipPoolAmount(ship.ShipClassIndex)
	ScpuiSystem.loadouts.shipPool[ship.ShipClassIndex] = amount + 1
	
	--For BtA: Empty the countermeasure slot
	self:EmptyCountermeasureSlot(slot)

end

function LoadoutHandler:SetDefaultWeapons(slot, shipIndex)

	--Primaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultPrimaries, 1 do
		local weapon = tb.ShipClasses[shipIndex].defaultPrimaries[i]:getWeaponClassIndex()
		--Check the weapon pool
		if self:GetWeaponPoolAmount(weapon) <= 0 then
			--Find a new weapon
			weapon = self:GetFirstAllowedWeapon(shipIndex, i, 1)
		end
		--Primaries always get amount of 1
		local amount = 1
		--Set the weapon and remove from pool
		self:AddWeaponToBank(slot, i, weapon)
	end
	
	--Secondaries
	for i = 1, #tb.ShipClasses[shipIndex].defaultSecondaries, 1 do
		local weapon = tb.ShipClasses[shipIndex].defaultSecondaries[i]:getWeaponClassIndex()
		--Check the weapon pool
		if self:GetWeaponPoolAmount(weapon) <= 0 then
			--Find a new weapon
			weapon = self:GetFirstAllowedWeapon(shipIndex, i, 2)
		end
		--Get an appropriate amount for the weapon and bank
		local amount = self:GetWeaponAmount(shipIndex, weapon, i)
		if amount > self:GetWeaponPoolAmount(weapon) then
			amount = self:GetWeaponPoolAmount(weapon)
		end
		--Set the weapon and remove from pool
		self:AddWeaponToBank(slot, i + 3, weapon)
	end

end

function LoadoutHandler:GetFirstAllowedWeapon(shipIndex, bank, category)

	i = 1
	while (i < #tb.WeaponClasses) do
		if (tb.WeaponClasses[i]:isPrimary() and (category == 1)) or (tb.WeaponClasses[i]:isSecondary() and (category == 2)) then
			if self:GetWeaponPoolAmount(i) > 0 then
				local actualBankIdx = self:ConvertBankSlotToBank(shipIndex, bank, category, true)
				if tb.ShipClasses[shipIndex]:isWeaponAllowedOnShip(i, actualBankIdx) then
					return i
				end
			end
		end
		i = i + 1
	end
	
	return -1

end

function LoadoutHandler:CopyToWing(sourceSlot)
	
	--Now get what the other slots are that we will copy to
	local slots = {}
	local wing, _ = self:GetWingSlot(sourceSlot)
	
	local count = 1
	for i=1, self:GetNumSlots() do
	
		local w, s = self:GetWingSlot(i)
	
		if w == wing then
			slots[count] = i
			count = count + 1
		end
		
	end

	local source = self:GetShipLoadout(sourceSlot)
	local sourceShip = source.ShipClassIndex
	--Now get the weapons that we will try to copy over
	for j = 1, #slots, 1 do
		if slots[j] ~= sourceSlot then
			local target = self:GetShipLoadout(slots[j])
			local targetShip = target.ShipClassIndex

			if (not target.isDisabled) and target.isFilled then
				if not target.isWeaponLocked then
					for i = 1, #source.Weapons, 1 do

						--Does the bank exist on the source ship?
						if self:ShipHasBank(sourceShip, i) then
							--Does the bank exist on the target ship?
							if self:ShipHasBank(targetShip, i) then
								--The weapon we want to copy
								local weapon = source.Weapons[i]
								
								--Return what's in the bank to the pool
								self:EmptyWeaponBank(j, i)
								
								--Maybe add the weapon
								self:AddWeaponToBank(j, i, weapon)
							end
						end
					end
					
					--For BtA: Copy the countermeasure slot if possible
					local sourceCM = self:GetCountermeasure(sourceSlot)
					if self:isCountermeasureAllowed(slots[j], sourceCM) then
						self:SetCountermeasure(slots[j], sourceCM)
					end
					
				end
			end
		end
	end
end

--Methods to save the loadout from Lua to the FSO API
function LoadoutHandler:SendShipToFSO_API(ship, slot)

	--Set the ship
	if ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isShipLocked == false then
		ui.ShipWepSelect.Loadout_Ships[slot].ShipClassIndex = ship.ShipClassIndex
		if ship.ShipClassIndex > 0 then
			ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isFilled = true
		else
			ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isFilled = false
			return
		end
	end
	
	--Set the weapons
	if ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isWeaponLocked == false then
		for i = 1, self:GetMaxBanks() do
			if self:ShipHasBank(ship.ShipClassIndex, i) then
				if ship.Weapons[i] > 0 then
					ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = ship.Weapons[i]
					ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i] = ship.Amounts[i]
				else
					ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = -1
				end
			end
		end
	end
end

function LoadoutHandler:SendAllToFSO_API()
	for i = 1, self:GetNumSlots() do
		local ship = self:GetShipLoadout(i)
		self:SendShipToFSO_API(ship, i)
	end
end

--Save to the player file use FSO's built-in loadout saving feature
function LoadoutHandler:SaveInFSO_API()
	ui.ShipWepSelect.saveLoadout()
end

function LoadoutHandler:ResetFSO_API()
	ui.ShipWepSelect.resetSelect()
end

--Methods for saving loadout data to a file
function LoadoutHandler:loadLoadoutsFromFile()

	local json = require('dkjson')
	
	--Loadouts are explicitely not saved across mod versions
	local location = 'data/config'
  
	local file = nil
	local config = {}
  
	if cf.fileExists('scpui_loadouts.cfg') then
		file = cf.openFile('scpui_loadouts.cfg', 'r', location)
		config = json.decode(file:read('*a'))
		file:close()
		if not config then
			config = {}
		end
	end
  
	if not config[ba.getCurrentPlayer():getName()] then
		config[ba.getCurrentPlayer():getName()] = {}
	end
	
	local mod = ba.getModTitle()
	
	if mod == "" then
		ba.error("SCPUI requires the current mod have a title in game_settings.tbl!")
	end
	
	if not config[ba.getCurrentPlayer():getName()][mod] then
		return nil
	else
		return config[ba.getCurrentPlayer():getName()][mod]
	end
end

function LoadoutHandler:saveLoadoutsToFile(data)

	local json = require('dkjson')
	
	--Loadouts are explicitely not saved across mod versions
	local location = 'data/config'
  
	local file = nil
	local config = {}
  
	if cf.fileExists('scpui_loadouts.cfg') then
		file = cf.openFile('scpui_loadouts.cfg', 'r', location)
		config = json.decode(file:read('*a'))
		file:close()
		if not config then
			config = {}
		end
	end
  
	if not config[ba.getCurrentPlayer():getName()] then
		config[ba.getCurrentPlayer():getName()] = {}
	end
	
	local mod = ba.getModTitle()
	
	if mod == "" then
		ba.error("SCPUI requires the current mod have a title in game_settings.tbl!")
	end
	
	config[ba.getCurrentPlayer():getName()][mod] = data
	
	config = self:cleanPilotsFromSaveData(config)
  
	file = cf.openFile('scpui_loadouts.cfg', 'w', location)
	file:write(json.encode(config))
	file:close()
end

function LoadoutHandler:cleanPilotsFromSaveData(data)
	
	--get the pilots list
	local pilots = ui.PilotSelect.enumeratePilots()
	
	local cleanData = {}
	
	-- for each existing pilot, keep the data
	for _, v in ipairs(pilots) do
		if data[v] ~= nil then
			cleanData[v] = data[v]
		end
    end

	return cleanData
end

function LoadoutHandler:getMissionKey()
	
	local key = mn.getMissionFilename()
	
	if key == "" then
		ba.error("Cannot save or load loadouts when not in a mission!")
	end
	
	if mn.isInCampaign() then
		key = key .. "_c"
	else
		key = key .. "_t"
	end
	
	return key

end

return LoadoutHandler