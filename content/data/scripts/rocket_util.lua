local utils = require("utils")
local tblUtil = utils.table;

local M = {}

function M.remove_children(element)
    while element:HasChildNodes() do
        element:RemoveChild(element.first_child)
    end
end

---@param colorTable table<string, color>
local function add_text_element(parent, document, text, color_tag, colorTable)
    if #text == 0 then
        -- If no text, do not output anything
        return
    end

    local colorVal = colorTable[color_tag]

    local spanEl = document:CreateElement("span")
    local textEl = document:CreateTextNode(text)

    spanEl.style.color = ("rgba(%d, %d, %d, %d)"):format(colorVal.Red, colorVal.Green, colorVal.Blue, colorVal.Alpha)

    spanEl:AppendChild(textEl)

    parent:AppendChild(spanEl)
end

function M.set_briefing_text(parent, brief_text)
    -- First, clear all the children of this element
    M.remove_children(parent)

    local document = parent.owner_document

    local colorTags = ui.CommandBriefing.ColorTags
    local defaultColorTag = ui.CommandBriefing.DefaultTextColorTag

    local lines = utils.split(brief_text, "\n\n")
    local first = true
    ---@param line string
    for _, line in ipairs(lines) do
        if not first then
            local newLine = document:CreateElement("br")
            parent:AppendChild(newLine)
        else
            first = false
        end

        local paragraph = document:CreateElement("p")

        local searchIndex = 1
        local colorStack = { defaultColorTag }

        while true do
            local startIdx, endIdx, colorChar, groupChar = line:find("%$(%a?)([{}]?)%s*", searchIndex)
            if startIdx == nil then
                break
            end

            if #colorChar == 0 and groupChar ~= "}" then
                ba.error(string.format("Color block error in line %q", line))
            end

            -- Flush out text that was before our tag
            local pendingText = line:sub(searchIndex, startIdx - 1)
            add_text_element(paragraph, document, pendingText, colorStack[#colorStack], colorTags)

            searchIndex = endIdx + 1

            if #colorChar == 0 then
                -- This must be the end of a color group. Remove the last color from the stack and continue
                table.remove(colorStack)
            else
                table.insert(colorStack, colorChar)

                if groupChar == "{" then
                    -- The start of a group so there is nothing for us to do here at the moment
                else
                    -- We need to know if our word was terminated by white space or an explicit break so we store the whitespace
                    -- in a group and check that later
                    local rangeEndStart, rangeEndEnd, whitespace = utils.find_first_either(line, { "(%s)", "%$|" }, searchIndex)

                    local coloredText
                    if whitespace then
                        -- If we broke on whitespace then we still need to include those characters in the colored range
                        -- to ensure the spacing is correct. To do that, we build the substring until the end of the range
                        coloredText = line:sub(endIdx + 1, rangeEndEnd)
                    else
                        coloredText = line:sub(endIdx + 1, rangeEndStart - 1)
                    end
                    add_text_element(paragraph, document, coloredText, colorStack[#colorStack], colorTags)

                    table.remove(colorStack)

                    searchIndex = rangeEndEnd + 1
                end
            end
        end

        local remainingText = line:sub(searchIndex)
        add_text_element(paragraph, document, remainingText, colorStack[#colorStack], colorTags)

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
