local utils = {
    table = {}
}

function utils.strip_extension(name)
    return string.gsub(name, "%..+$", "")
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

return utils
