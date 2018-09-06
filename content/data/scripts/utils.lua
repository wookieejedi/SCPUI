
local utils = {
	table = {}
}

function utils.table.ifind(tbl, val)
	for i, v in ipairs(tbl) do
		if v == val then
			return i
		end
	end

	return -1
end

function utils.table.find(tbl, val)
	for i, v in pairs(tbl) do
		if v == val then
			return i
		end
	end

	return nil
end

function utils.table.contains(tbl, val)
	return utils.table.find(tbl, val) ~= nil
end

return utils
