-----------------------------------
--This file contains all the code necessary to save and load arbitrary data to player files on disk
-----------------------------------

local datasaver = {
	maxBackups = 10
}

--- Function to hash a string using a basic ascii char codes. Helps to make sure we have no mod name conflicts
--- @param input_string string
--- @return string
function datasaver:basicStringHash(input_string)
	local mult = 1

	--Check if we have SCPUI. If so, we can use the specified hash value
	if ScpuiSystem ~= nil then
		mult = ScpuiSystem.data.table_flags.DataSaverMultiplier
		if mult == nil then
			mult = 1 -- No SCPUI, so just use 1
		end
	end

    local hash = 0
    for i = 1, #input_string do
        local char_code = string.byte(input_string, i)
        hash = (hash * mult) + char_code  -- Adjust the multiplier as needed
    end
    return string.sub(hash, 1, 10)
end

--- Load data from disk and return the data as a table or nil if not found
--- @param source string The name of the data to find
--- @param persistent? boolean Whether to load the data from the player save file or the local save file
--- @return any data The data that was loaded. Nil if not found
function datasaver:loadDataFromFile(source, persistent)

	---@type json
	local Json = require('dkjson')
	local location = nil
	local filename = nil
	local id = self:basicStringHash(ScpuiSystem:getModTitle())

	if persistent == true then
		location = 'data/players'
		filename = id .. '_save_data.cfg'
	else
		location = 'data/config'
		filename = id .. '_save_data_local.cfg'
	end

	local file = nil
	local config = {}

	if cf.fileExists(filename) then
		file = cf.openFile(filename, 'r', location)
		config = Json.decode(file:read('*a'))
		file:close()

		if not config then
			ba.error('Please ensure that ' .. filename .. ' exists in ' .. location .. ' and is valid JSON.')
		end
	end

	--If this is the first load, then let's save a backup
	if not self.Loaded then
		self.Loaded = true
		self:backupSaveData()
	end

	if ba.getCurrentPlayer():getName() == "" then
		ba.warning('Cannot load data when there is no player selected!')
		return
	end

	if not config[ba.getCurrentPlayer():getName()] then
		config[ba.getCurrentPlayer():getName()] = {}
	end

	if not config[ba.getCurrentPlayer():getName()][source] then
		return nil
	else
		return config[ba.getCurrentPlayer():getName()][source]
	end
end

--- Save data to disk
--- @param source string The name of the data to save
--- @param data any The data to save
--- @param persistent? boolean Whether to save the data to the player save file or the local save file
--- @return nil
function datasaver:saveDataToFile(source, data, persistent)

	---@type json
	local Json = require('dkjson')
	local location = nil
	local filename = nil
	local id = self:basicStringHash(ScpuiSystem:getModTitle())

	if persistent == true then
		location = 'data/players'
		filename = id .. '_save_data.cfg'
	else
		location = 'data/config'
		filename = id .. '_save_data_local.cfg'
	end

	local file = nil
	local config = {}

	if cf.fileExists(filename) then
		file = cf.openFile(filename, 'r', location)
		config = Json.decode(file:read('*a'))
		file:close()

		if not config then
			ba.error('Please ensure that ' .. filename .. ' exists in ' .. location .. ' and is valid JSON.')
		end
	end

	if ba.getCurrentPlayer():getName() == "" then
		ba.warning('Cannot save data when there is no player selected!')
		return
	end

	if not config[ba.getCurrentPlayer():getName()] then
		config[ba.getCurrentPlayer():getName()] = {}
	end

	config[ba.getCurrentPlayer():getName()][source] = data

	local Utils = require("lib_utils")
	config = Utils.cleanPilotsFromSaveData(config)

	file = cf.openFile(filename, 'w', location)
	file:write(Json.encode(config))
	file:close()
end

--- Function to backup all of the player save data. Backs up to a maximum of 10 files before it overwrites the oldest
--- @return nil
function datasaver:backupSaveData()

	---@type json
	local Json = require('dkjson')

	local id = self:basicStringHash(ScpuiSystem:getModTitle())

	local fileroot = id .. '_save_backup_'

	local num = self:loadDataFromFile('backup_num', false)
	if num == nil then
		num = 1
	elseif num == self.maxBackups then
		num = 1
	else
		num = num + 1
	end
	self:saveDataToFile("backup_num", num, false)

	ba.print("Data Saver is backing up player save data...\n")

	--Backup the global data
	local global_filename = fileroot .. num .. '.cfg'
	local global_sourcefile = id .. '_save_data.cfg'
	local global_file, global_config
	if cf.fileExists(id .. '_save_data.cfg') then
		global_file = cf.openFile(id .. '_save_data.cfg', 'r', 'data/players')
		global_config = Json.decode(global_file:read('*a'))
		global_file:close()

		if not global_config then
			ba.error('Please ensure that ' .. global_sourcefile .. ' exists in data/players and is valid JSON.')
		end
	end
	if global_config then
		global_file = cf.openFile(global_filename, 'w', 'data/config')
		global_file:write(Json.encode(global_config))
		global_file:close()
	end

	--Backup the local data
	local local_filename = fileroot .. 'local_' .. num .. '.cfg'
	local local_sourcefile = id .. '_save_data_local.cfg'
	local local_file, local_config
	if cf.fileExists(local_sourcefile) then
		local_file = cf.openFile(local_sourcefile, 'r', 'data/config')
		local_config = Json.decode(local_file:read('*a'))
		local_file:close()

		if not local_config then
			ba.error('Please ensure that ' .. local_sourcefile .. ' exists in ' .. 'data/config' .. ' and is valid JSON.')
		end
	end
	if local_config then
		local_file = cf.openFile(local_filename, 'w', 'data/config')
		local_file:write(Json.encode(local_config))
		local_file:close()
	end
end

return datasaver