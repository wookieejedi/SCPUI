local utils = {}

utils.table = {}

function utils.loadOptionsFromFile(source, toPlayers)

	local json = require('dkjson')
  
	if toPlayers then
		location = 'data/players'
	else
		location = 'data/config'
	end
  
	local file = nil
	local config = {}
  
	if cf.fileExists('mod_options.cfg') then
		file = cf.openFile('mod_options.cfg', 'r', location)
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
		config[ba.getCurrentPlayer():getName()][mod] = {}
	end
  
	if not config[ba.getCurrentPlayer():getName()][mod][source] then
		return nil
	else
		return config[ba.getCurrentPlayer():getName()][mod][source]
	end
end

function utils.saveOptionsToFile(source, data, toPlayers)

	local json = require('dkjson')
  
	if toPlayers then
		location = 'data/players'
	else
		location = 'data/config'
	end
  
	local file = nil
	local config = {}
  
	if cf.fileExists('mod_options.cfg') then
		file = cf.openFile('mod_options.cfg', 'r', location)
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
		config[ba.getCurrentPlayer():getName()][mod] = {}
	end
  
	config[ba.getCurrentPlayer():getName()][mod][source] = data
	
	config = utils.cleanPilotsFromSaveData(config)
  
	file = cf.openFile('mod_options.cfg', 'w', location)
	file:write(json.encode(config))
	file:close()
end

function utils.cleanPilotsFromSaveData(data)
	
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

function utils.animExists(name)
	--remove extension if it's included
	local file = name:match("(.+)%..+")
	
	if file == nil then
		file = name
	end
	
	--now see if it exists
	local theseExts = {".png", ".ani", ".eff"}
	for i = 1, #theseExts do
		local thisFile = file .. theseExts[i]
		if cf.fileExists(thisFile, "", true) then
			return true
		end
	end
	return false
end

function utils.strip_extension(name)
    return string.gsub(name, "%..+$", "")
end

function utils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

function utils.loadConfig(filename)
  -- Load the config file.
  local file = cf.openFile(filename, 'r', 'data/config')
  local config = require('dkjson').decode(file:read('*a'))
  file:close()
  if not config then
    ba.error('Please ensure that ' .. filename .. ' exists in data/config and is valid JSON.')
  end
  return config
end

function utils.xstr(message)
  if type(message) == 'string' then
    ba.print('SCPUI: Got string with missing XSTR index: ' .. message .. "\n")
    return message
  else
    return ba.XSTR(message[1], message[2])
  end
end

--- find_first
---@param str string
---@param patterns string[]
---@param startIdx number
---
function utils.find_first_either(str, patterns, startIdx)
    local firstResult = nil
    for i, v in ipairs(patterns) do
        local values = { str:find(v, startIdx) }

        if values[1] ~= nil then
            if firstResult == nil then
                firstResult = values
            elseif values[1] < firstResult[1] then
                firstResult = values
            end
        end
    end

    if firstResult == nil then
        return nil
    else
        return unpack(firstResult)
    end
end

---
--- @param inputStr string
--- @return string
function utils.rml_escape(inputStr)
    return inputStr:gsub('[<>&"]', function(char)
        if char == "<" then
            return "&lt;"
        end

        if char == ">" then
            return "&gt;"
        end

        if char == "&" then
            return "&amp;"
        end

        if char == "\"" then
            return "&quot;"
        end
    end)
end

function utils.table.ifind(tbl, val, compare)
    for i, v in ipairs(tbl) do
        if compare ~= nil then
            if compare(v, val) then
                return i
            end
        else
            if v == val then
                return i
            end
        end
    end

    return -1
end

function utils.table.find(tbl, val, compare)
    for i, v in pairs(tbl) do
        if compare ~= nil then
            if compare(v, val) then
                return i
            end
        else
            if v == val then
                return i
            end
        end
    end

    return nil
end

function utils.table.contains(tbl, val, compare)
    return utils.table.find(tbl, val, compare) ~= nil
end

function utils.table.iremove_el(tbl, val, compare)
    local i = utils.table.ifind(tbl, val, compare)
    if i >= 1 then
        table.remove(tbl, i)
    end
    return i
end

--- Maps an input array using a function
--- @generic T
--- @generic V
--- @param tbl T[]
--- @param map_fun fun(el:T):V
--- @return V[]
function utils.table.map(tbl, map_fun)
    local out = {}
    for i, v in ipairs(tbl) do
        out[i] = map_fun(v)
    end
    return out
end

--- Reduces a list of values to a single value
--- @generic T
--- @generic V
--- @param tbl T[] The table to reduce
--- @param reduceFn fun(accumulator: V, el: T):V
--- @param initial V Initial value to use
--- @return V The final value after all elements have been looked at
function utils.table.reduce(tbl, reduceFn, initial)
    local acc = initial
    for _, v in ipairs(tbl) do
        acc = reduceFn(acc, v)
    end
    return acc
end

--- Computes the sum of the specified table
--- @param tbl number[]
--- @return number
function utils.table.sum(tbl)
    return utils.table.reduce(tbl, function(sum, el)
        return sum + el
    end, 0)
end

return utils
