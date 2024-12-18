local LoadoutHandler = {}

local topics = require('ui_topics')

LoadoutHandler.version = 2

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
		
		topics.loadouts.initialize:send()
	end
end

function LoadoutHandler:update()
	self:getLoadout()
end

function LoadoutHandler:unloadAll(missionCommit)
	ScpuiSystem.loadouts = nil
	ScpuiSystem.savedLoadouts = nil
	ScpuiSystem.backupLoadout = nil
	
	ScpuiSystem.selectInit = nil
	
	topics.loadouts.unload:send(missionCommit)
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
		version = self.version,
		datetime = mn.getMissionModifiedDate(),
		shipPool = ScpuiSystem.loadouts.shipPool,
		weaponPool = ScpuiSystem.loadouts.weaponPool,
		slots = ScpuiSystem.loadouts.slots,
		numShipClasses = #tb.ShipClasses,
		numWepClasses = #tb.WeaponClasses
	}
	
	topics.loadouts.saveLoadout:send(ScpuiSystem.savedLoadouts[key])
	
	self:saveLoadoutsToFile(ScpuiSystem.savedLoadouts)
end

function LoadoutHandler:maybeApplySavedLoadout()

	if topics.loadouts.rejectSavedLoadout:send() == true then
		return
	end
	
	local key = self:getMissionKey()
	
	if ScpuiSystem.savedLoadouts[key] ~= nil then
	
		--Check the loadout handler version that was used for this save and discard if it's incorrect
		if ScpuiSystem.savedLoadouts[key].version ~= self.version then
			ScpuiSystem.savedLoadouts[key] = nil
			return
		end
	
		--Check the mission datetime matches. If not, then discard the loadout
		if mn.getMissionModifiedDate() ~= ScpuiSystem.savedLoadouts[key].datetime then
			ScpuiSystem.savedLoadouts[key] = nil
			return
		end
		
		--Check here that the number of ship & weapon classes at the time of save is equal to the number that exist now
		if ScpuiSystem.savedLoadouts[key].numShipClasses == #tb.ShipClasses and ScpuiSystem.savedLoadouts[key].numWepClasses == #tb.WeaponClasses then
			
			topics.loadouts.loadLoadout:send(ScpuiSystem.savedLoadouts[key])
			
			ScpuiSystem.loadouts.shipPool = ScpuiSystem.savedLoadouts[key].shipPool
			ScpuiSystem.loadouts.weaponPool = ScpuiSystem.savedLoadouts[key].weaponPool
			ScpuiSystem.loadouts.slots = ScpuiSystem.savedLoadouts[key].slots
			
			ba.print("LOADOUT HANDLER: Applying saved loadout for mission " .. key .. "\n")
		else
			--If the class counts don't match then the saved loadout is invalid. Might as well clear it.
			ScpuiSystem.savedLoadouts[key] = nil
		end
	end
	
end

function LoadoutHandler:getLoadout()	
	ScpuiSystem.loadouts.shipPool = self:getPool(ui.ShipWepSelect.Ship_Pool, true)
	ScpuiSystem.loadouts.weaponPool = self:getPool(ui.ShipWepSelect.Weapon_Pool, false)
	ScpuiSystem.loadouts.slots = self:getSlots()
end

function LoadoutHandler:cleanLoadoutShips()
	
	topics.loadouts.initPool:send()
	
	--FSO must have internal code to remove ships in wings from the pool
	--so let's do that manually here
	for i = 1, #ScpuiSystem.loadouts.slots do
		if ScpuiSystem.loadouts.slots[i].ShipClassIndex > 0 then
			self:TakeShipFromPool(ScpuiSystem.loadouts.slots[i].ShipClassIndex)
		end
	end
end

function LoadoutHandler:getPool(pool, shipPool)
	data = {}
	for i = 1, #pool do
		if pool[i] > 0 then
			if shipPool == true then
				ba.print("LOADOUT HANDLER: Ship pool item " .. tb.ShipClasses[i].Name .. " to amount " .. pool[i] .. "\n")
			else
				ba.print("LOADOUT HANDLER: Weapon pool item " .. tb.WeaponClasses[i].Name .. " to amount " .. pool[i] .. "\n")
			end
		end
		data[i] = pool[i]
	end
	return data
end

--Here we make a complete lua copy of all the loadout information so we can
--mess with it as much as we want without having to worry about FSO getting
--in the way. The loadout will be saved on mission close or cancel
function LoadoutHandler:getSlots()
	local utils = require("utils")
	local slots = {}
	
	-- If any of the data below is changed or added to then the LoadoutHandler.version global must be incremented!
	for i = 1, #ui.ShipWepSelect.Loadout_Ships do
		ba.print('LOADOUT HANDLER: Parsing ship slot ' .. i .. '\n')
		local data = {}
		data.Weapons = self:parseWeapons(i)
		data.Amounts = self:parseAmounts(i)
		data.ShipClassIndex = ui.ShipWepSelect.Loadout_Ships[i].ShipClassIndex
		ba.print('LOADOUT HANDLER: Ship is ' .. tb.ShipClasses[data.ShipClassIndex].Name .. '\n')
		
		local wing, wingSlot = self:GetWingSlot(i)
		
		data.Name = ui.ShipWepSelect.Loadout_Wings[wing].Name .. " " .. wingSlot
		data.displayName = utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name) .. " " .. wingSlot
		data.WingName = ui.ShipWepSelect.Loadout_Wings[wing].Name
		data.displayWingName = utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name)
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
			ba.print('LOADOUT HANDLER: Weapon in bank ' .. i .. ' is ' .. tb.WeaponClasses[data[i]].Name .. '\n')
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
			ba.print('LOADOUT HANDLER: Amount in bank ' .. i .. ' is ' .. data[i] .. '\n')
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
	while (i <= #shipList) do
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
		Anim = tb.ShipClasses[shipIdx].SelectAnimFilename,
		Name = tb.ShipClasses[shipIdx].Name,
		Type = tb.ShipClasses[shipIdx].TypeString,
		Length = tb.ShipClasses[shipIdx].LengthString,
		Velocity = tb.ShipClasses[shipIdx].VelocityString,
		AfterburnerVelocity = tb.ShipClasses[shipIdx].AfterburnerVelocityMax.z,
		Maneuverability = tb.ShipClasses[shipIdx].ManeuverabilityString,
		Armor = tb.ShipClasses[shipIdx].ArmorString,
		GunMounts = tb.ShipClasses[shipIdx].GunMountsString,
		MissileBanks = tb.ShipClasses[shipIdx].MissileBanksString,
		Manufacturer = tb.ShipClasses[shipIdx].ManufacturerString,
		Hitpoints = tb.ShipClasses[shipIdx].HitpointsMax,
		ShieldHitpoints = tb.ShipClasses[shipIdx].ShieldHitpointsMax,
		key = tb.ShipClasses[shipIdx].Name,
		GeneratedWidth = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Width,
		GeneratedHeight = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Height,
		GeneratedIcon = rocketUiIcons[tb.ShipClasses[shipIdx].Name].Icon
	}
	
	topics.loadouts.initShipInfo:send(ScpuiSystem.loadouts.shipInfo[i])
	
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
	
	local type_v = nil
	if tb.WeaponClasses[wepIdx]:isPrimary() then
		type_v = "primary"
	else
		type_v = "secondary"
	end
	local weaponClass = tb.WeaponClasses[wepIdx]
	local data = topics.weapons.stats:send(weaponClass)
	data.Index = wepIdx
	data.Amount = self:GetWeaponPoolAmount(wepIdx)
	data.Icon = weaponClass.SelectIconFilename
	data.Anim = weaponClass.SelectAnimFilename
	data.Name = weaponClass.Name
	data.Title = weaponClass.TechTitle
	data.Description = string.gsub(weaponClass.Description, "Level", "<br></br>Level")
	data.FireWait = weaponClass.FireWait
	data.Type = type_v
	data.key = weaponClass.Name
	data.GeneratedWidth = rocketUiIcons[weaponClass.Name].Width
	data.GeneratedHeight = rocketUiIcons[weaponClass.Name].Height
	data.GeneratedIcon = rocketUiIcons[weaponClass.Name].Icon
	topics.loadouts.initWeaponInfo:send(data)
	
	if weaponClass:isPrimary() then
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
	gr.setLineWidth(1)
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

function LoadoutHandler:GetWingName(wing)
	return ui.ShipWepSelect.Loadout_Wings[wing].Name
end

function LoadoutHandler:GetWingDisplayName(wing)
	local utils = require("utils")
	return utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name)
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
	if not slot then
		ba.error("Attempting to get loadout slot with a nil value! Get Mjn!")
		return nil
	else
		if slot < 0 or slot > #ScpuiSystem.loadouts.slots then
			ba.error("Attempting to get invalid loadout slot '" .. slot .. "'! Get Mjn!")
			return nil
		else
			return ScpuiSystem.loadouts.slots[slot]
		end
	end
end

--Get amount left in weapon pool
function LoadoutHandler:GetWeaponPoolAmount(idx)
	if not idx then
		ba.warning("Checking weapon amount for a nil weapon index! Get Mjn!")
		return 0
	else
		if idx < 0 or idx > #ScpuiSystem.loadouts.weaponPool then
			ba.warning("Checking invalid weapon index '" .. idx .. "' for pool amount! Returning 0! Get Mjn!")
			return 0
		else
			local val = ScpuiSystem.loadouts.weaponPool[idx]
			if val == nil then
				ba.error("Weapon amount for '" .. idx .. "' was nil! Get Mjn!")
				return 0
			else
				return val
			end
		end
	end
end

--Get amount left in ship pool
function LoadoutHandler:GetShipPoolAmount(idx)
	if not idx then
		ba.warning("Checking ship amount for a nil ship index! Get Mjn!")
		return 0
	else
		if idx < 0 or idx > #ScpuiSystem.loadouts.shipPool then
			ba.warning("Checking invalid ship index '" .. idx .. "' for pool amount! Returning 0! Get Mjn!")
			return 0
		else
			local val = ScpuiSystem.loadouts.shipPool[idx]
			if val == nil then
				ba.error("Ship amount for '" .. idx .. "' was nil! Get Mjn!")
			else
				return val
			end
		end
	end
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

	--If we're out of bounds then the ship doesn't have the bank!
	if (ship < 1) or (ship > #tb.ShipClasses) then
		return false
	end

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
		ba.print("LOADOUT HANDLER: Trying to empty weapon bank for slot " .. slot .. ", bank " .. bank .. ", but amount was nil!")
		return
	end
	if weapon == nil then
		ba.print("LOADOUT HANDLER: Trying to empty weapon bank for slot " .. slot .. ", bank " .. bank .. ", but weapon was nil!")
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

function LoadoutHandler:SetFilled(slot, state)

	ship = self:GetShipLoadout(slot)
	
	ship.isFilled = state
	ship.ShipClassIndex = -1
	
end

function LoadoutHandler:TakeShipFromSlot(slot)
	
	ScpuiSystem.loadouts.slots[slot].Weapons = {}
	ScpuiSystem.loadouts.slots[slot].Amounts = {}
	self:SetFilled(slot, false)
	
	topics.loadouts.emptyShipSlot:send(slot)

end

function LoadoutHandler:AddShipToSlot(slot, shipIdx)

	ScpuiSystem.loadouts.slots[slot].ShipClassIndex = shipIdx
	self:SetDefaultWeapons(slot, shipIdx)
	
	topics.loadouts.fillShipSlot:send(slot)

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
	
	topics.loadouts.returnShipSlot:send(slot)

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
		--No weapons available, so leave the bank empty
		if weapon < 0 then
			return
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
	
	for i=1, self:GetNumSlots() do
	
		local w, s = self:GetWingSlot(i)
		
		if w == wing then
			table.insert(slots, i)
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
								self:EmptyWeaponBank(slots[j], i)
								
								--Maybe add the weapon
								self:AddWeaponToBank(slots[j], i, weapon)
							end
						end
					end
					
					topics.loadouts.copyShipSlot:send({sourceSlot, slots[j]})
				end
			end
		end
	end
end

--Methods to save the loadout from Lua to the FSO API
function LoadoutHandler:SendShipToFSO_API(ship, slot, logging)

	if logging then
		ba.print("LOADOUT HANDLER: Setting ship slot " .. slot .. "\n")
		ba.print("LOADOUT HANDLER: Ship slot has name '" .. ScpuiSystem.loadouts.slots[slot].Name .. "'\n")
	end

	--Set the ship
	ui.ShipWepSelect.Loadout_Ships[slot].ShipClassIndex = ship.ShipClassIndex
	if ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isShipLocked == false then
		ba.print("LOADOUT HANDLER: Ship is not locked, setting filled status!\n")
		if ship.ShipClassIndex > 0 then
			ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isFilled = true
			if logging then
				ba.print("LOADOUT HANDLER: Setting filled ship to class '" .. ship.Name .. "'\n")
			end
		else
			ui.ShipWepSelect.Loadout_Wings[ship.Wing][ship.WingSlot].isFilled = false
			if logging then
				ba.print("LOADOUT HANDLER: Setting ship slot to empty!\n")
			end
			return
		end
	else
		ba.print("LOADOUT HANDLER: Ship is locked, cannot set filled status!\n")
	end
	
	--Set the weapons
	for i = 1, self:GetMaxBanks() do
		if self:ShipHasBank(ship.ShipClassIndex, i) then
			if logging then
				ba.print("LOADOUT HANDLER: Setting ship bank " .. i .. "\n")
			end
			if ship.Weapons[i] > 0 then
				ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = ship.Weapons[i]
				ui.ShipWepSelect.Loadout_Ships[slot].Amounts[i] = ship.Amounts[i]
				if logging then
					ba.print("LOADOUT HANDLER: Setting ship bank weapon to '" .. tb.WeaponClasses[ship.Weapons[i]].Name .. "'\n")
					ba.print("LOADOUT HANDLER: Setting ship bank amount to '" .. ship.Amounts[i] .. "'\n")
				end
			else
				ui.ShipWepSelect.Loadout_Ships[slot].Weapons[i] = -1
				if logging then
					ba.print("LOADOUT HANDLER: Setting ship bank weapon to empty!\n")
				end
			end
		end
	end
	
	if logging then
		ba.print("LOADOUT HANDLER: Done with slot " .. slot .. "\n")
	end
end

function LoadoutHandler:SendAllToFSO_API()
	for i = 1, self:GetNumSlots() do
		local ship = self:GetShipLoadout(i)
		self:SendShipToFSO_API(ship, i, true)
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
	
	local mod = ScpuiSystem:getModTitle()
	
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
	
	local mod = ScpuiSystem:getModTitle()
	
	if mod == "" then
		ba.error("SCPUI requires the current mod have a title in game_settings.tbl!")
	end
	
	config[ba.getCurrentPlayer():getName()][mod] = data
	local utils = require("utils")
	config = utils.cleanPilotsFromSaveData(config)
  
	file = cf.openFile('scpui_loadouts.cfg', 'w', location)
	file:write(json.encode(config))
	file:close()
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
