local LoadoutHandler = {}

local topics = require('ui_topics')

LoadoutHandler.version = 2

--- Initialize LoadoutHandler. Must be called first.
--- @return nil
function LoadoutHandler:init()
	if not ScpuiSystem.data.stateInit.select then
		ui.ShipWepSelect.initSelect()
		ui.ShipWepSelect.resetSelect()
		ScpuiSystem.data.stateInit.select = true
		ScpuiSystem.data.loadouts = {
			shipPool = {},
			weaponPool = {},
			slots = {},
			shipInfo = {},
			primaryInfo = {},
			secondaryInfo = {},
			emptyWingSlotIcon = {},
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

--- Updates the loadout with the most recent data from the game engine
--- @return nil
function LoadoutHandler:update()
	self:getLoadout()
end

--- Resets loadout handler to an uninitialized state
--- Must be called on mission commit or cancel
--- @param missionCommit boolean
--- @return nil
function LoadoutHandler:unloadAll(missionCommit)
	ScpuiSystem.data.loadouts = nil
	ScpuiSystem.data.savedLoadouts = nil
	ScpuiSystem.data.backupLoadout = nil
	
	ScpuiSystem.data.stateInit.select = nil
	
	topics.loadouts.unload:send(missionCommit)
end

--- Gets the saved loadouts from disk, if any exist, and saves them to the ScpuiSystem.data.savedLoadouts table
--- Will also clean out any loadout data for mission files that do not exist in the currently loaded game
--- @return nil
function LoadoutHandler:getSavedLoadouts()
	
	ScpuiSystem.data.savedLoadouts = self:loadLoadoutsFromFile()
	
	if ScpuiSystem.data.savedLoadouts == nil then
		ScpuiSystem.data.savedLoadouts = {}
	end
	
	self:cleanSavedLoadouts()
	
end

--- Cleans out loadout data for mission files that do not exist in the currently loaded mod
--- This is ok because loadout save data is specific to mod versions and not FSO/player-wide
--- @return nil
function LoadoutHandler:cleanSavedLoadouts()

	--- Loop through all saved loadouts.
	--- @param k string The key (name) of the saved loadout.
	for k, _ in pairs(ScpuiSystem.data.savedLoadouts) do
		local file = k
		
		--If we have a key of two characters or less then that shouldn't be there. Clear it.
		if #file <= 2 then
			ScpuiSystem.data.savedLoadouts[k] = nil
			ba.print("SCPUI deleted the saved loadout `" .. k .. "' because the mission file does not exist!\n")
		else
			file =  string.sub(file, 1, #file - 2)
			
			--If the mission file doesn't exist, then remove the save data.
			if not cf.fileExists(file .. ".fs2", "", true) then
				ScpuiSystem.data.savedLoadouts[k] = nil
				ba.print("SCPUI deleted the saved loadout `" .. k .. "' because the mission file does not exist!\n")
			end
		end
	end

end

--- Saves the current loadout to disk, adding necessary version and date stamps
--- @return nil
function LoadoutHandler:saveCurrentLoadout()
	
	local key = self:getMissionKey()
	
	ScpuiSystem.data.savedLoadouts[key] = {
		version = self.version,
		datetime = mn.getMissionModifiedDate(),
		shipPool = ScpuiSystem.data.loadouts.shipPool,
		weaponPool = ScpuiSystem.data.loadouts.weaponPool,
		slots = ScpuiSystem.data.loadouts.slots,
		numShipClasses = #tb.ShipClasses,
		numWepClasses = #tb.WeaponClasses
	}
	
	topics.loadouts.saveLoadout:send(ScpuiSystem.data.savedLoadouts[key])
	
	self:saveLoadoutsToFile(ScpuiSystem.data.savedLoadouts)
end

--- Attempts to apply a saved loadout to the current mission
--- Will fail if the saved loadout version does not match the current version
--- Will fail if the mission date does not match the current mission date
--- Will fail if the number of ship or weapon classes in the game has changed since the loadout was saved
--- @return nil
function LoadoutHandler:maybeApplySavedLoadout()

	if topics.loadouts.rejectSavedLoadout:send() == true then
		return
	end
	
	local key = self:getMissionKey()
	
	if ScpuiSystem.data.savedLoadouts[key] ~= nil then
	
		--Check the loadout handler version that was used for this save and discard if it's incorrect
		if ScpuiSystem.data.savedLoadouts[key].version ~= self.version then
			ScpuiSystem.data.savedLoadouts[key] = nil
			return
		end
	
		--Check the mission datetime matches. If not, then discard the loadout
		if mn.getMissionModifiedDate() ~= ScpuiSystem.data.savedLoadouts[key].datetime then
			ScpuiSystem.data.savedLoadouts[key] = nil
			return
		end
		
		--Check here that the number of ship & weapon classes at the time of save is equal to the number that exist now
		if ScpuiSystem.data.savedLoadouts[key].numShipClasses == #tb.ShipClasses and ScpuiSystem.data.savedLoadouts[key].numWepClasses == #tb.WeaponClasses then
			
			topics.loadouts.loadLoadout:send(ScpuiSystem.data.savedLoadouts[key])
			
			ScpuiSystem.data.loadouts.shipPool = ScpuiSystem.data.savedLoadouts[key].shipPool
			ScpuiSystem.data.loadouts.weaponPool = ScpuiSystem.data.savedLoadouts[key].weaponPool
			ScpuiSystem.data.loadouts.slots = ScpuiSystem.data.savedLoadouts[key].slots
			
			ba.print("LOADOUT HANDLER: Applying saved loadout for mission " .. key .. "\n")
		else
			--If the class counts don't match then the saved loadout is invalid. Might as well clear it.
			ScpuiSystem.data.savedLoadouts[key] = nil
		end
	end
	
end

--- Loads the current loadout data from the game into loadout handler
--- @return nil
function LoadoutHandler:getLoadout()	
	ScpuiSystem.data.loadouts.shipPool = self:getPool(ui.ShipWepSelect.Ship_Pool, true)
	ScpuiSystem.data.loadouts.weaponPool = self:getPool(ui.ShipWepSelect.Weapon_Pool, false)
	ScpuiSystem.data.loadouts.slots = self:getSlots()
end

--- Iterates over the all loadout slots and takes ship classes used in them out of the ship pool
--- @return nil
function LoadoutHandler:cleanLoadoutShips()
	
	topics.loadouts.initPool:send()
	
	--FSO must have internal code to remove ships in wings from the pool
	--so let's do that manually here
	for i = 1, #ScpuiSystem.data.loadouts.slots do
		if ScpuiSystem.data.loadouts.slots[i].ShipClassIndex > 0 then
			self:TakeShipFromPool(ScpuiSystem.data.loadouts.slots[i].ShipClassIndex)
		end
	end
end

--- Copies the pool to a new table and returns it
--- @param pool integer[] The pool to copy from
--- @param shipPool boolean Whether or not this is the ship or weapon pool
--- @return integer[] data The copied pool
function LoadoutHandler:getPool(pool, shipPool)
	local data = {}
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

--- Make a complete lua copy of all the loadout information so we can change
--- it as much as we want without having to worry about FSO getting in the way.
--- The loadout will be saved on mission close or cancel
--- @return loadout_slot[] slots The copied loadout slots
function LoadoutHandler:getSlots()
	local utils = require("utils")

	--- @type loadout_slot[]
	local slots = {}
	
	-- If any of the data below is changed or added to then the LoadoutHandler.version global must be incremented!
	for i = 1, #ui.ShipWepSelect.Loadout_Ships do
		ba.print('LOADOUT HANDLER: Parsing ship slot ' .. i .. '\n')

		local wing, wingSlot = self:GetWingSlot(i)

		--- @type loadout_slot
		local data = {
			Weapons = self:parseWeapons(i),
			Amounts = self:parseAmounts(i),
			ShipClassIndex = ui.ShipWepSelect.Loadout_Ships[i].ShipClassIndex,
			Name = ui.ShipWepSelect.Loadout_Wings[wing].Name .. " " .. wingSlot,
			displayName = utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name) .. " " .. wingSlot,
			WingName = ui.ShipWepSelect.Loadout_Wings[wing].Name,
			displayWingName = utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name),
			Wing = wing,
			WingSlot = wingSlot,
			isShipLocked = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isShipLocked,
			isWeaponLocked = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isWeaponLocked,
			isDisabled = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isDisabled,
			isFilled = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isFilled,
			isPlayer = ui.ShipWepSelect.Loadout_Wings[wing][wingSlot].isPlayer
		}
		ba.print('LOADOUT HANDLER: Ship is ' .. tb.ShipClasses[data.ShipClassIndex].Name .. '\n')
		
		slots[i] = data
	end
	
	return slots
end

--- If the slot has a ship then this will copie the weapon indecies to a new table and return it
--- @param ship integer The ship slot to parse
--- @return integer[] data The copied weapon indecies
function LoadoutHandler:parseWeapons(ship)

	---@type integer[]
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

--- If the slot has a ship then this will copie the weapon amounts to a new table and return it
--- @param ship integer The ship slot to parse
--- @return integer[] data The copied weapon amounts
function LoadoutHandler:parseAmounts(ship)

	---@type integer[]
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

--- Makes a complete copy of the current loadout in ScpuiSystem.data.backupLoadout
--- @return nil
function LoadoutHandler:backupLoadout()
	local utils = require("utils")
	ScpuiSystem.data.backupLoadout = {}
	ScpuiSystem.data.backupLoadout = utils.copy(ScpuiSystem.data.loadouts)
end

--- If a backup loadout exists this will copy the loadout from the backup to the current loadout data
--- @return nil
function LoadoutHandler:resetLoadout()
	if ScpuiSystem.data.backupLoadout ~= nil then
		local utils = require("utils")
		ScpuiSystem.data.loadouts = {}
		ScpuiSystem.data.loadouts = utils.copy(ScpuiSystem.data.backupLoadout)
	else
		ba.warning("Backup loadout was nil! Find Mjn!")
	end
end

--- Goes through all existing ship classes in the game and checks if 1 or more is available in the loadout pool
--- If so it will check if icon frames have been generated for the ship and if not it will generate them
--- Then it will copy all necessary data about the ship class and save it to the ScpuiSystem.data.loadouts.shipInfo table
--- Finally it sorts the table by ship index
--- @return nil
function LoadoutHandler:generateShipInfo()
	local shipList = tb.ShipClasses
	local i = 1
	while (i <= #shipList) do
		if self:GetShipPoolAmount(i) > 0 then
			if ScpuiSystem.data.rocketUiIcons[shipList[i].Name] == nil then
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

	table.sort(ScpuiSystem.data.loadouts.shipInfo, function(a,b) return a.Index < b.Index end)

end

--- Gets the ship class by index and copies all necessary data to the ScpuiSystem.data.loadouts.shipInfo table
--- and then returns that table entry
--- @param shipIdx integer The index of the ship class to get
--- @return ship_loadout_info data The copied ship class data
function LoadoutHandler:AppendToShipInfo(shipIdx)

	if ScpuiSystem.data.rocketUiIcons[tb.ShipClasses[shipIdx].Name] == nil then
		ba.warning("No generated icon was found for " .. tb.ShipClasses[shipIdx].Name .. "! Generating one now.")
		ScpuiSystem:setIconFrames(tb.ShipClasses[shipIdx].Name, true)
	end

	local i = #ScpuiSystem.data.loadouts.shipInfo + 1
	ScpuiSystem.data.loadouts.shipInfo[i] = {
		Index = tb.ShipClasses[shipIdx]:getShipClassIndex(),
		Amount = self:GetShipPoolAmount(shipIdx),
		Icon = tb.ShipClasses[shipIdx].SelectIconFilename,
		Anim = tb.ShipClasses[shipIdx].SelectAnimFilename,
		Name = tb.ShipClasses[shipIdx].Name,
		Type = tb.ShipClasses[shipIdx].TypeString,
		Length = tb.ShipClasses[shipIdx].LengthString,
		Velocity = tb.ShipClasses[shipIdx].VelocityString,
		AfterburnerVelocity = tostring(tb.ShipClasses[shipIdx].AfterburnerVelocityMax["z"]),
		Maneuverability = tb.ShipClasses[shipIdx].ManeuverabilityString,
		Armor = tb.ShipClasses[shipIdx].ArmorString,
		GunMounts = tb.ShipClasses[shipIdx].GunMountsString,
		MissileBanks = tb.ShipClasses[shipIdx].MissileBanksString,
		Manufacturer = tb.ShipClasses[shipIdx].ManufacturerString,
		Hitpoints = tb.ShipClasses[shipIdx].HitpointsMax,
		ShieldHitpoints = tb.ShipClasses[shipIdx].ShieldHitpointsMax,
		key = tb.ShipClasses[shipIdx].Name,
		GeneratedWidth = ScpuiSystem.data.rocketUiIcons[tb.ShipClasses[shipIdx].Name].Width,
		GeneratedHeight = ScpuiSystem.data.rocketUiIcons[tb.ShipClasses[shipIdx].Name].Height,
		GeneratedIcon = ScpuiSystem.data.rocketUiIcons[tb.ShipClasses[shipIdx].Name].Icon,
		Overhead = tb.ShipClasses[shipIdx].SelectOverheadFilename
	}
	
	topics.loadouts.initShipInfo:send(ScpuiSystem.data.loadouts.shipInfo[i])
	
	return ScpuiSystem.data.loadouts.shipInfo[i]
end

--- Goes through all existing weapon classes in the game and checks if 1 or more is available in the loadout pool
--- If so it will check if icon frames have been generated for the weapon and if not it will generate them
--- Then it will copy all necessary data about the weapon class and save it to the ScpuiSystem.data.loadouts.weaponInfo table
--- Finally it sorts the table by weapon index
--- @return nil
function LoadoutHandler:generateWeaponInfo()
	local weaponList = tb.WeaponClasses
	local i = 1
	while (i ~= #weaponList) do
		if self:GetWeaponPoolAmount(i) > 0 then
			if ScpuiSystem.data.rocketUiIcons[weaponList[i].Name] == nil then
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
			if ship ~= nil then
				if ship.ShipClassIndex > 0 then
					for j = 1, #ship.Weapons do
						local wepIdx = ship.Weapons[j]
						if ship.Amounts[j] > 0 then
							local wep = self:GetWeaponInfo(wepIdx)
							if wep == nil then
								self:AppendToWeaponInfo(wepIdx)
							end
						end
					end
				end
			end
		end
	end
	
	table.sort(ScpuiSystem.data.loadouts.primaryInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.data.loadouts.secondaryInfo, function(a,b) return a.Index < b.Index end)

end

--- Gets the weapon class by index and copies all necessary data to the ScpuiSystem.data.loadouts.weaponInfo table
--- and then returns that table entry
--- @param wepIdx integer The index of the weapon class to get
--- @return weapon_loadout_info data The copied weapon class data
function LoadoutHandler:AppendToWeaponInfo(wepIdx)
	
	if ScpuiSystem.data.rocketUiIcons[tb.WeaponClasses[wepIdx].Name] == nil then
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
	data.GeneratedWidth = ScpuiSystem.data.rocketUiIcons[weaponClass.Name].Width
	data.GeneratedHeight = ScpuiSystem.data.rocketUiIcons[weaponClass.Name].Height
	data.GeneratedIcon = ScpuiSystem.data.rocketUiIcons[weaponClass.Name].Icon
	topics.loadouts.initWeaponInfo:send(data)
	
	if weaponClass:isPrimary() then
		local i = #ScpuiSystem.data.loadouts.primaryInfo + 1
		ScpuiSystem.data.loadouts.primaryInfo[i] = data
		return ScpuiSystem.data.loadouts.primaryInfo[i]
	else
		local i = #ScpuiSystem.data.loadouts.secondaryInfo + 1
		ScpuiSystem.data.loadouts.secondaryInfo[i] = data
		return ScpuiSystem.data.loadouts.secondaryInfo[i]
	end
end

--- Generates an empty slot icon and saves it to the ScpuiSystem.data.loadouts.emptyWingSlotIcon table
--- @return nil
function LoadoutHandler:generateEmptySlotFrames()
	if ScpuiSystem.data.loadouts.emptyWingSlotIcon == nil then
		ScpuiSystem.data.loadouts.emptyWingSlotIcon = {}
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
		ScpuiSystem.data.loadouts.emptyWingSlotIcon[j] = gr.screenToBlob()
	end

	-- These may not be needed anymore?
	--ScpuiSystem.data.loadouts.emptyWingSlotIcon.GeneratedWidth = width
	--ScpuiSystem.data.loadouts.emptyWingSlotIcon.GeneratedHeight = height
	
	--clean up
	gr.setColor(saveColor)
	gr.setTarget()
	gr.setLineWidth(1)
	imag_h:unload()
	tex_h:unload()

end

--- Returns the empty wing slot icon data
--- @return string[] data The empty wing slot icon data
function LoadoutHandler:getEmptyWingSlotIcon()
	return ScpuiSystem.data.loadouts.emptyWingSlotIcon
end

--- Returns the data for a ship class contained by loadout handler
--- @param shipIndex integer The index of the ship class to get
--- @return ship_loadout_info? data The ship class data
function LoadoutHandler:GetShipInfo(shipIndex)

	for i, v in ipairs(ScpuiSystem.data.loadouts.shipInfo) do
		if v.Index == shipIndex then
			return v
		end
	end
	
	return nil

end

--- Returns the data for a primary weapon class contained by loadout handler
--- @param wepIndex integer The index of the primary weapon class to get
--- @return weapon_loadout_info? data The primary weapon class data
function LoadoutHandler:GetPrimaryInfo(wepIndex)

	for i, v in ipairs(ScpuiSystem.data.loadouts.primaryInfo) do
		if v.Index == wepIndex then
			return v
		end
	end
	
	return nil

end

--- Returns the data for a secondary weapon class contained by loadout handler
--- @param wepIndex integer The index of the secondary weapon class to get
--- @return weapon_loadout_info? data The secondary weapon class data
function LoadoutHandler:GetSecondaryInfo(wepIndex)
	
	for i, v in ipairs(ScpuiSystem.data.loadouts.secondaryInfo) do
		if v.Index == wepIndex then
			return v
		end
	end
	
	return nil

end

--- Returns the data for a weapon class contained by loadout handler
--- Automatically tries to distinguish between primary and secondary weapons
--- @param wepIndex integer The index of the weapon class to get
--- @return weapon_loadout_info? data The weapon class data
function LoadoutHandler:GetWeaponInfo(wepIndex)
	if tb.WeaponClasses[wepIndex]:isPrimary() then
		return self:GetPrimaryInfo(wepIndex)
	elseif tb.WeaponClasses[wepIndex]:isSecondary() then
		return self:GetSecondaryInfo(wepIndex)
	else
		return nil
	end
end

--- Checks all ships and weapons in the loadout to ensure that the necessary
--- data is present in the shipInfo and weaponInfo tables
--- @return nil
function LoadoutHandler:ValidateInfo()

	--Validate ships
	for i = 1, #ScpuiSystem.data.loadouts.slots do
		if not self:IsSlotDisabled(i) then
			local shipIdx = ScpuiSystem.data.loadouts.slots[i].ShipClassIndex
			if shipIdx > 0 then
				if self:GetShipInfo(shipIdx) == nil then
					self:AppendToShipInfo(shipIdx)
				end
			end
		end
	end
	
	--Validate weapons
	for i = 1, #ScpuiSystem.data.loadouts.slots, 1 do
		if not self:IsSlotDisabled(i) then
			if ScpuiSystem.data.loadouts.slots[i].ShipClassIndex > 0 then
				for j = 1, #ScpuiSystem.data.loadouts.slots[i].Weapons, 1 do
					local wepIdx = ScpuiSystem.data.loadouts.slots[i].Weapons[j]
					if ScpuiSystem.data.loadouts.slots[i].Amounts[j] > 0 then
						if self:GetWeaponInfo(wepIdx) == nil then
							self:AppendToWeaponInfo(wepIdx)
						end
					end
				end
			end
		end
	end
	
	--Sort the tables by index
	table.sort(ScpuiSystem.data.loadouts.shipInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.data.loadouts.primaryInfo, function(a,b) return a.Index < b.Index end)
	table.sort(ScpuiSystem.data.loadouts.secondaryInfo, function(a,b) return a.Index < b.Index end)

end

--- Gets the MAX_PRIMARIES global
--- @return integer
function LoadoutHandler:GetMaxPrimaries()
	return ScpuiSystem.data.loadouts.MAX_PRIMARIES
end

--- Gets the MAX_SECONDARIES global
--- @return integer
function LoadoutHandler:GetMaxSecondaries()
	return ScpuiSystem.data.loadouts.MAX_SECONDARIES
end

--- Gets the maximum banks a ship can have across both primaries and secondaries
--- @return integer
function LoadoutHandler:GetMaxBanks()
	return ScpuiSystem.data.loadouts.MAX_PRIMARIES + ScpuiSystem.data.loadouts.MAX_SECONDARIES
end

--- Gets the total number of wings in the loadout
--- @return integer
function LoadoutHandler:GetNumWings()
	return #ui.ShipWepSelect.Loadout_Wings
end

--- Gets the number of slots in a specific wing
--- @param wing integer The wing index to get the number of slots for
--- @return integer
function LoadoutHandler:GetNumWingSlots(wing)
	return #ui.ShipWepSelect.Loadout_Wings[wing]
end

--- Gets the name of a specific wing
--- @param wing integer The wing index to get the name of
--- @return string
function LoadoutHandler:GetWingName(wing)
	return ui.ShipWepSelect.Loadout_Wings[wing].Name
end

--- Gets the display name of a specific wing
--- @param wing integer The wing index to get the display name of
--- @return string
function LoadoutHandler:GetWingDisplayName(wing)
	local utils = require("utils")
	return utils.truncateAtHash(ui.ShipWepSelect.Loadout_Wings[wing].Name)
end

--- Returns if a specific slot is disabled or not
--- @param slot integer The slot index to check
--- @return boolean
function LoadoutHandler:IsSlotDisabled(slot)
	return ScpuiSystem.data.loadouts.slots[slot].isDisabled
end

--- Checks if a weapon is allowed on a specific ship in the currently active weapon slot. True if allowed, false otherwise
--- @param shipIndex integer The index of the ship class to check
--- @param weaponIndex integer The index of the weapon class to check
--- @return boolean
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

--- Get the entire ship info list
--- @return ship_loadout_info[] data The ship info list
function LoadoutHandler:GetShipList()
	return ScpuiSystem.data.loadouts.shipInfo
end

--- Get the entire primary weapon info list
--- @return weapon_loadout_info[] data The primary weapon info list
function LoadoutHandler:GetPrimaryWeaponList()
	return ScpuiSystem.data.loadouts.primaryInfo
end

--- Get the entire secondary weapon info list
--- @return weapon_loadout_info[] data The secondary weapon info list
function LoadoutHandler:GetSecondaryWeaponList()
	return ScpuiSystem.data.loadouts.secondaryInfo
end

--- Get the number of ships in the ship info list
--- @return integer
function LoadoutHandler:GetNumShips()
	return #ScpuiSystem.data.loadouts.shipInfo
end

--- Get the number of primary weapons in the primary weapon info list
--- @return integer
function LoadoutHandler:GetNumPrimaryWeapons()
	return #ScpuiSystem.data.loadouts.primaryInfo
end

--- Get the number of secondary weapons in the secondary weapon info list
--- @return integer
function LoadoutHandler:GetNumSecondaryWeapons()
	return #ScpuiSystem.data.loadouts.secondaryInfo
end

--- Get total number slots we have in the loadout
--- @return integer
function LoadoutHandler:GetNumSlots()
	return #ScpuiSystem.data.loadouts.slots
end

--- Get the max supported wing size
--- @return integer
function LoadoutHandler:GetWingSize()
	return ScpuiSystem.data.loadouts.WING_SIZE
end

--- Get a ship slot
--- @param slot integer The slot index to get
--- @return loadout_slot data The slot data
function LoadoutHandler:GetShipLoadout(slot)
	if not slot then
		ba.error("Attempting to get loadout slot with a nil value! Get Mjn!")
	end
	if slot < 0 or slot > #ScpuiSystem.data.loadouts.slots then
		ba.error("Attempting to get invalid loadout slot '" .. slot .. "'! Get Mjn!")
	end
	
	return ScpuiSystem.data.loadouts.slots[slot]

end

--- Get amount of a weapon class left in weapon pool
--- @param idx integer The index of the weapon class to check
--- @return integer
function LoadoutHandler:GetWeaponPoolAmount(idx)
	if not idx then
		ba.warning("Checking weapon amount for a nil weapon index! Get Mjn!")
		return 0
	end
	if idx < 0 or idx > #ScpuiSystem.data.loadouts.weaponPool then
		ba.warning("Checking invalid weapon index '" .. idx .. "' for pool amount! Returning 0! Get Mjn!")
		return 0
	end

	local val = ScpuiSystem.data.loadouts.weaponPool[idx]
	if val == nil then
		ba.error("Weapon amount for '" .. idx .. "' was nil! Get Mjn!")
	end

	return val or 0
end

--- Get amount of a ship class left in ship pool
--- @param idx integer The index of the ship class to check
--- @return integer
function LoadoutHandler:GetShipPoolAmount(idx)
	if not idx then
		ba.warning("Checking ship amount for a nil ship index! Get Mjn!")
		return 0
	end
	if idx < 0 or idx > #ScpuiSystem.data.loadouts.shipPool then
		ba.warning("Checking invalid ship index '" .. idx .. "' for pool amount! Returning 0! Get Mjn!")
		return 0
	end

	local val = ScpuiSystem.data.loadouts.shipPool[idx]
	if val == nil then
		ba.error("Ship amount for '" .. idx .. "' was nil! Get Mjn!")
	end
	
	return val or 0
end

--- Convert slot index to wing/slot position
--- @param slot integer The slot index to convert
--- @return integer wing, integer slot The wing and slot position within that wing
function LoadoutHandler:GetWingSlot(slot)

	local wingSize = self:GetWingSize()
	local wing = math.floor((slot - 1) / wingSize) + 1
	local slot = ((slot - 1) % wingSize) + 1
	
	return wing, slot
end

--- Convert wing/slot position to slot index
--- @param wing integer The wing index
--- @param slot integer The slot index within that wing
--- @return integer slot The slot index
function LoadoutHandler:GetSlotIndex(wing, slot)

	local wingSize = self:GetWingSize()
	
	return (wing - 1) * wingSize + slot
end

--- This one converts the slot (1-7) to actual banks (1-3 for primaries, 1-4 for secondaries)
--- if classSpecific is true then converts to actual banks on the specific ship class (1-N where N is the last secondary)
--- @param ship integer The index of the ship class to convert for
--- @param bank integer The bank slot index to convert
--- @param w_type integer The weapon type to convert for (1 for primary, 2 for secondary)
--- @param classSpecific? boolean Whether or not to convert to actual banks on the specific ship class
--- @return integer actualBank The actual bank index
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

--- Returns true if a ship has a specific bank and false if not
--- @param ship integer The index of the ship class to check
--- @param bank integer The bank index to check
--- @return boolean
function LoadoutHandler:ShipHasBank(ship, bank)

	--If we're out of bounds then the ship doesn't have the bank!
	if (ship < 1) or (ship > #tb.ShipClasses) then
		return false
	end

	local primaryBanks = tb.ShipClasses[ship].numPrimaryBanks
	local secondaryBanks = tb.ShipClasses[ship].numSecondaryBanks
	
	local MAX_BANKS = ScpuiSystem.data.loadouts.MAX_PRIMARIES + ScpuiSystem.data.loadouts.MAX_SECONDARIES
	
	if bank < 1 then return false end
	if bank > MAX_BANKS then return false end
	
	--primary bank
	if bank <= ScpuiSystem.data.loadouts.MAX_PRIMARIES then
		if bank <= primaryBanks then
			return true
		end
	else
		if bank <= (secondaryBanks + ScpuiSystem.data.loadouts.MAX_PRIMARIES) then
			return true
		end
	end
	
	return false
end

--- Return true if weapon is allowed on this ship bank, false otherwise
--- @param shipIdx integer The index of the ship class to check
--- @param weaponIdx integer The index of the weapon class to check
--- @param bank integer The bank index to check
--- @return boolean
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

--- Returns the amount a ship bank can carry for a specific weapon
--- Returns -1 if weapon is not allowed on the ship
--- @param shipIndex integer The index of the ship class to check
--- @param weaponIndex integer The index of the weapon class to check
--- @param bank integer The bank index to check
--- @return integer
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

--- Get the weapon type between primary or secondary. Returns 1 for primary, 2 for secondary
--- @param weapon integer The index of the weapon class to check
--- @return integer
function LoadoutHandler:GetWeaponType(weapon)
	if tb.WeaponClasses[weapon]:isPrimary() then
		return 1
	else
		return 2
	end
end

--- Add to weapon amount to the weapon in the weapon pool
--- @param weapon integer The index of the weapon class to add to
--- @param amount integer The amount to add
--- @return nil
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
		local num = ScpuiSystem.data.loadouts.weaponPool[weapon]
		ScpuiSystem.data.loadouts.weaponPool[weapon] = num + amount
	end
end

--- Subtract from weapon amount from the weapon in the weapon pool
--- @param weapon integer The index of the weapon class to subtract
--- @param amount integer The amount to subtract
--- @return nil
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
		local num = ScpuiSystem.data.loadouts.weaponPool[weapon]
		ScpuiSystem.data.loadouts.weaponPool[weapon] = num - amount
	end
end

--- Add weapon to a weapon bank, removing that weapon from the weapon pool. Returns true if successful, false otherwise
--- @param slot integer The slot index to add the weapon to
--- @param bank integer The bank index to add the weapon to
--- @param weaponIdx integer The index of the weapon class to add to the bank
--- @param amount? integer The amount of the weapon to add to the bank. If nil, then full bank capacity will be assumed
--- @return boolean
function LoadoutHandler:AddWeaponToBank(slot, bank, weaponIdx, amount)
	local ship = self:GetShipLoadout(slot)
	if ship == nil then return false end

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

--- Empty a weapon bank, returning its contents to the weapon pool
--- @param slot integer The slot index to empty the weapon bank from
--- @param bank integer The bank index to empty
--- @param onlyEmpty? boolean If true, the weapon will not be returned to the pool
--- @return nil
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

--- Sets a ship slot as filled or unfilled and sets the ship class index to -1. True to fill, false to empty
--- @param slot integer The slot index to set as filled
--- @param state boolean The state to set the slot to
--- @return nil
function LoadoutHandler:SetFilled(slot, state)

	local ship = self:GetShipLoadout(slot)
	
	ship.isFilled = state
	ship.ShipClassIndex = -1
	
end

--- Empties a ship slot and clears the slot's Weapons and Amounts tables
--- @param slot integer The slot index to empty
--- @return nil
function LoadoutHandler:TakeShipFromSlot(slot)
	
	ScpuiSystem.data.loadouts.slots[slot].Weapons = {}
	ScpuiSystem.data.loadouts.slots[slot].Amounts = {}
	self:SetFilled(slot, false)
	
	topics.loadouts.emptyShipSlot:send(slot)

end

--- Adds a ship to a ship slot and tries to fill the weapon banks with default weapons
--- Does not verify that the ship class is available in the ship pool
--- @param slot integer The slot index to add the ship to
--- @param shipIdx integer The index of the ship class to add to the slot
--- @return nil
function LoadoutHandler:AddShipToSlot(slot, shipIdx)

	ScpuiSystem.data.loadouts.slots[slot].ShipClassIndex = shipIdx
	self:SetDefaultWeapons(slot, shipIdx)
	
	topics.loadouts.fillShipSlot:send(slot)

end

--- Removes a ship from the ship pool
--- @param shipIdx integer The index of the ship class to remove
--- @return nil
function LoadoutHandler:TakeShipFromPool(shipIdx)
	
	local amount = self:GetShipPoolAmount(shipIdx)

	if amount > 0 then
		ScpuiSystem.data.loadouts.shipPool[shipIdx] = amount - 1
	end

end

--- Returns a ship to the ship pool
--- @param slot integer The slot index to return the ship from
--- @return nil
function LoadoutHandler:ReturnShipToPool(slot)

	--Return all the weapons to the pool
	local ship = self:GetShipLoadout(slot)
	for i = 1, #ship.Weapons do
		self:EmptyWeaponBank(slot, i)
	end
	
	--Return the ship
	local amount = self:GetShipPoolAmount(ship.ShipClassIndex)
	ScpuiSystem.data.loadouts.shipPool[ship.ShipClassIndex] = amount + 1
	
	topics.loadouts.returnShipSlot:send(slot)

end

--- Attempts to apply default weapons to a ship's weapon banks based on what is allowed in the weapon pool.
--- If no weapons are available, the bank will be left empty.
--- @param slot integer The slot index to set the default weapons for
--- @param shipIndex integer The index of the ship class to set the default weapons for
--- @return nil
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

--- Returns the first allowed weapon for a specific ship and bank. Returns -1 if no weapon is allowed or available
--- @param shipIndex integer The index of the ship class to check
--- @param bank integer The bank index to check
--- @param category integer The weapon category to check (1 for primary, 2 for secondary)
--- @return integer index The index of the first weapon allowed and available
function LoadoutHandler:GetFirstAllowedWeapon(shipIndex, bank, category)

	local i = 1
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

--- Attempts to copy the loadout from the a slot to all other slots in the same wing
--- @param sourceSlot integer The slot index to copy the loadout from
--- @return nil
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

--- Sends the current ship loadout to the FSO API to actually apply to the ships in the mission.
--- Does minimal error checking, assuming the current loadout is valid
--- @param ship loadout_slot The ship loadout to send
--- @param slot integer The slot index to send the ship to
--- @param logging? boolean If true, will print debug messages
--- @return nil
function LoadoutHandler:SendShipToFSO_API(ship, slot, logging)

	if logging then
		ba.print("LOADOUT HANDLER: Setting ship slot " .. slot .. "\n")
		ba.print("LOADOUT HANDLER: Ship slot has name '" .. ScpuiSystem.data.loadouts.slots[slot].Name .. "'\n")
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

--- Sends all ship loadouts to the FSO API to actually apply to the ships in the mission.
--- Does minimal error checking, assuming the current loadout is valid
--- @return nil
function LoadoutHandler:SendAllToFSO_API()
	for i = 1, self:GetNumSlots() do
		local ship = self:GetShipLoadout(i)
		self:SendShipToFSO_API(ship, i, true)
	end
end

--- Save to the player file use FSO's built-in loadout saving feature
--- @return nil
function LoadoutHandler:SaveInFSO_API()
	ui.ShipWepSelect.saveLoadout()
end

--- Resets the FSO API to the default loadout
--- @return nil
function LoadoutHandler:ResetFSO_API()
	ui.ShipWepSelect.resetSelect()
end

--- Loads SCPUI's saved loadouts from disk, if any
--- @return saved_loadout[]?
function LoadoutHandler:loadLoadoutsFromFile()

	local json = require('dkjson')
	
	--Loadouts are explicitly not saved across mod versions
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

--- Save the current loadout to disk
--- @param data saved_loadout[] The loadout data to save
--- @return nil
function LoadoutHandler:saveLoadoutsToFile(data)

	local json = require('dkjson')
	
	--Loadouts are explicitly not saved across mod versions
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

--- Gets the mission key for the current mission used to save or load a loadout
--- The key is the mission filename appended with "_c" for campaign missions and "_t" for techroom missions
--- @return string
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
