local utils = require("utils")
local tblUtil = utils.table;

local M = {}

function M.remove_children(element)
    while element:HasChildNodes() do
        element:RemoveChild(element.first_child)
    end
end

function M.set_briefing_text(parent, brief_text)
    -- First, clear all the children of this element
    M.remove_children(parent)

    local document = parent.owner_document

    local lines = utils.split(brief_text, "\n\n")
    local first = true
    for _, v in ipairs(lines) do
        if not first then
            local newLine = document:CreateElement("br")
            parent:AppendChild(newLine)
        else
            first = false
        end

        local paragraph = document:CreateElement("p")
        paragraph:AppendChild(document:CreateTextNode(v))
        parent:AppendChild(paragraph)
    end

    -- Try to estimate the amount of lines this will get. The value 130 is chosen based on the original width of the
    -- text window in retail FS2
    local paragraphLines = tblUtil.map(lines, function(line)
        return #line / 130
    end)

    return tblUtil.sum(paragraphLines) + #lines
end

return M
