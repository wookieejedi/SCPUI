local utils = {}

utils.table = {}


--round number function shared among all topics 
function utils.round(num, decimalPlaces)
    local places = decimalPlaces or 0
    local multiplier = 10^places
    return math.floor(num * multiplier + 0.5) / multiplier
end

--Parses an XSTR from Custom data if it's formatted like so:
-- +Val: NAME "string", #
--and returns the string and id in a table
function utils.parseCustomXSTR(text)

	local inputString = text
	local result = {}

	-- Remove the leading and trailing parentheses
	text = string.gsub(text, "^%(", "")
	text = string.gsub(text, "%)$", "")

	-- Extract the values inside quotation marks
	local quotedValue = string.match(inputString, '"([^"]+)"')

	-- Extract the number after the comma
	local numberValue = tonumber(string.match(inputString, ',%s*(-?%d+)'))
	
	if not quotedValue then
		ba.warning("Could not find the string in the xstr '" .. inputString .. "'. Expected it to be contained within quotation marks.")
		quotedValue = ""
	end
	
	if not numberValue then
		ba.warning("Could not find the number in the xstr '" .. inputString .. "'. Expected it to be a valid number after a comma.")
		numberValue = -1
	end

	table.insert(result, quotedValue)
	table.insert(result, numberValue)

	return result

end

--Parses a comma separated list into a table of values
function utils.parseCommaSeparatedList(inputString)
    local result = {}
    -- Split the string by comma
    for value in inputString:gmatch("[^,]+") do
        -- Trim leading and trailing whitespace from each value
        local trimmedValue = value:match("^%s*(.-)%s*$")
        table.insert(result, trimmedValue)
    end

    return result
end

--Translates an XSTR from Custom data if it's formatted like so:
-- +Val: NAME "string", #
--and returns translated string
function utils.translateCustomXSTR(text)
	local result = utils.parseCustomXSTR(text)
	result = ba.XSTR(result[1], result[2])
	return result
end

--A wrapper for mn.runSEXP that is not fucking stupid.
function utils.runSEXP(sexp, ...)

	local sexp = sexp
	local warned = false
  
	for _, data in ipairs(arg) do
  
		if data ~= nil and data ~= "" then
			local param = ""
	
			if type(data) == "boolean" then
				param = "( " .. tostring(data) .. " )"
			elseif type(data) == "number" then
				param = math.floor(data)
			elseif type(data) == "string" then
                param = "!" .. data:gsub("!", "!!") .. "!"
            end
		  
			if param ~= "" then
				sexp = sexp .. " " .. param
			else
				ba.warning("Util runSEXP() got parameter '" .. tostring(data) .. "' which is not a valid data type! Must be boolean, number, or string.")
				warned = true
			end
	  
		end
	
	end
  
	if not warned then
		return mn.runSEXP("( " .. sexp .. " )")
	end
  
	return false
  
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

function utils.getTableIndex(tab, val)

	for i, v in ipairs(tab) do
		if v.name == val then
			return i
		end
	end
	
	return ""

end

function utils.strip_extension(name)
    return string.gsub(name, "%..+$", "")
end

function utils.hasExtension(filename)
    local lastDotIndex = filename:find("%.[^%.]*$")
    return lastDotIndex ~= nil
end

function utils.isOneOf(val, ...)
    for _,k in ipairs({...}) do 
        if val == k then
            return true
        end
    end
    return false
end

function utils.extractString(inputstr, stop)
	local startIndex, endIndex = string.find(inputstr, stop)
    
    -- Check if an underscore was found
    if startIndex then
        -- Extract the substring from the start to the first underscore
        return string.sub(inputstr, 1, startIndex - 1)
    else
		return inputstr
	end
end

function utils.split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
        table.insert(t, utils.trim(str))
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

function utils.xstr(message, id)
  if id then
    return ba.XSTR(message, id)
  elseif type(message) == 'string' then
    ba.print('Utils.lua: Got string with missing XSTR index: ' .. message .. "\n")
    return message
  else
    return ba.XSTR(message[1], message[2])
  end
end

function utils.clamp(value, minimum, maximum)
  if value < minimum then
    return minimum
  elseif value > maximum then
    return maximum
  else
    return value
  end
end

-- Call this as copy(someTable) and ignore the seen parameter. It's used internally.
function utils.copy(obj, seen)
  if type(obj) ~= 'table' then return obj end
  if seen and seen[obj] then return seen[obj] end
  local s = seen or {}
  local res = setmetatable({}, getmetatable(obj))
  s[obj] = res
  for k, v in pairs(obj) do res[utils.copy(k, s)] = utils.copy(v, s) end
  return res
end

function utils.compute_percentage(fract, total)
    if total <= 0 then
        return "0%"
    end

    return string.format("%.2f%%", (fract / total) * 100)
end

function utils.safeRand(min, max, exact)
    if (min == nil and max ~= nil) then
        return max
    elseif (max == nil and min ~= nil) then
        return min
    elseif (min == nil and max == nil) then
        return 0
    end

    if (min == max) then
        return min
    end

    if (exact) then
        if (min > max) then
            return math.random(max, min)
        else
            return math.random(min, max)
        end
    else
        if (min > max) then
            return max + (min - max) * math.random()
        else
            return min + (max - min) * math.random()
        end
    end
end

function utils.tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function utils.stringStartsWith(str, pattern)
	return str:sub(1, #pattern) == pattern
end

function utils.trim(str)
	return str:find'^%s*$' and '' or str:match'^%s*(.*%S)'
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

---
--- @param inputStr string
--- @return string
function utils.truncateAtHash(inputString)
    local hashPosition = inputString:find("#") -- Find the position of the first #
    if hashPosition then
        return inputString:sub(1, hashPosition - 1) -- Return the substring up to (but not including) the #
    else
        return inputString -- If no # is found, return the original string
    end
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
