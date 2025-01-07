-----------------------------------
--This file contains the necessary methods to colorize text based on keywords
--It also contains the necessary methods to add tooltips to text
-----------------------------------

--- Initialize the keywords system and send the files to the keywords parser
--- This function is called when the SCPUI system is initialized
--- @return nil
function ScpuiSystem:initKeywords()
    local utils = require("lib_utils")

    ---@type scpui_keywords
    local affixes = {prefixes = {''}, suffixes = {''}}
    if cf.fileExists('keywords.tbl') then
        affixes = self:parseKeywords('keywords.tbl', affixes)
    end
  
    for _, v in ipairs(cf.listFiles("data/tables", "*-kwrd.tbm")) do
        self:parseKeywords(v, affixes)
    end
end

--- Parse the affixes section of the keywords table
--- @param source scpui_keywords
--- @return scpui_keywords
function ScpuiSystem:parseKeywordAffixes(source)
    local prefixes = {}
    local suffixes = {}
    for _, prefix in ipairs(source.prefixes) do
        table.insert(prefixes, prefix)
    end
    for _, suffix in ipairs(source.suffixes) do
        table.insert(suffixes, suffix)
    end
    while true do
        if parse.optionalString("+Prefix:") then
            table.insert(prefixes, parse.getString() .. ' ')
        elseif parse.optionalString("+Immediate Prefix:") then
            table.insert(prefixes, parse.getString())
        elseif parse.optionalString("+Suffix:") then
            table.insert(suffixes, ' ' .. parse.getString())
        elseif parse.optionalString("+Immediate Suffix:") then
            table.insert(suffixes, parse.getString())
        else
            return { prefixes = prefixes, suffixes = suffixes }
        end
    end
end

--- Parse the keywords table
--- @param data string The file to parse
--- @param inheritedAffixes scpui_keywords
--- @return scpui_keywords
function ScpuiSystem:parseKeywords(data, inheritedAffixes)
    local keywordAlgorithm = require("lib_keyword_agorithm")
    parse.readFileText(data, "data/tables")
    local lang = "#" .. ba.getCurrentLanguage()

    --If we can't find the language section then reset the parse and skip to Default
    if not parse.skipToString(lang) then
        parse.stop()
        parse.readFileText(data, "data/tables")
        if not parse.skipToString("#Default") then
        ba.error(data .. " is missing a valid language section!")
        end
    end

    ---@type scpui_keywords
    local globalAffixes = self:parseKeywordAffixes(inheritedAffixes)
    while parse.optionalString("$Style:") do
        local any = false
        local style = parse.getString()
        local affixes = self:parseKeywordAffixes(globalAffixes)
        while parse.optionalString("+Text:") do
            any = true
            local text = parse.getString()
            local tooltip = nil
            if parse.optionalString("++Tooltip:") then
                tooltip = parse.getString()
            end
            for _, prefix in ipairs(affixes.prefixes) do
                for _, suffix in ipairs(affixes.suffixes) do
                    local t = prefix .. text .. suffix
                    if not keywordAlgorithm.registerKeyword(t, style, tooltip) then
                        parse.displayMessage("SCPUI Keyword '" .. t .. "' already exists. Skipping!")
                    end
                end
            end
        end
        if not any then
            parse.displayMessage("Found '$Style: " .. style .. "' with no +Text: entries!")
        end
    end

    parse.requiredString("#End")
    parse.stop()
    return globalAffixes
end

--- Check the global timers table and show the tooltip if the timer is greater than 3
--- @param tool_el Element The tooltip element
--- @param id string The id of the tooltip
--- @return nil
function ScpuiSystem:maybeShowTooltip(tool_el, id)
    local async_util = require("lib_async")
    if ScpuiSystem.data.tooltipTimers[id] == nil then
        return
    end

    if ScpuiSystem.data.tooltipTimers[id] >= 3 then
        tool_el:SetPseudoClass("shown", true)
    else
        async.run(function()
            async.await(async_util.wait_for(1.0))
            if ScpuiSystem.data.tooltipTimers[id] ~= nil then
                ScpuiSystem.data.tooltipTimers[id] = ScpuiSystem.data.tooltipTimers[id] + 1
                ScpuiSystem:maybeShowTooltip(tool_el, id)
            end
        end, async.OnFrameExecutor)
    end
end

--- Add a tooltip to a document
--- @param document Document The document to add the tooltip to
--- @param id string The id to give the tooltip
--- @param tooltip string The tooltip to add
function ScpuiSystem:addTooltip(document, id, tooltip)
    if tooltip == nil or id == nil then
        return
    end

    local parent = document:GetElementById(id)

    if not parent then
        ba.print('Could not find tooltip parent!\n')
        return
    end

    local tool_el = document:CreateElement("div")
    tool_el.id = id .. "_tooltip"
    tool_el:SetClass("tooltip", true)
    tool_el.style.position = "fixed"

    -- Set the width of the tooltip
    -- Calculate the width of the tooltip element
    local maxCharacters = 25 -- Maximum characters before wrapping
    local fontPixelSize = ScpuiSystem:getFontPixelSize()
    local actualCharacters = math.min(maxCharacters, #tooltip)
    local elementWidth = fontPixelSize * actualCharacters

    tool_el.style.width = elementWidth .. "px"

    -- Calculate the number of characters that fit in one line
    local charactersPerLine = math.floor(elementWidth / fontPixelSize)

    -- Calculate the number of lines required
    local numberOfLines = math.ceil(#tooltip / charactersPerLine)

    local totalWidth = elementWidth + 10 -- Tooltip class has a padding of 5
    local totalHeight = ((numberOfLines * fontPixelSize) + 10)

    -- Now append!
    tool_el.inner_rml = "<span class=\"tooltiptext\">" .. tooltip .. "</span>"
    local root = document:GetElementById('main_background')
    root:AppendChild(tool_el)

    parent:AddEventListener("mouseover", function(event, _, _)
        local x = event.parameters.mouse_x - totalWidth
        local y = event.parameters.mouse_y - totalHeight
        tool_el.style.left = math.max(3, x) .. "px"
        tool_el.style.top = math.max(3, y) .. "px"
        if ScpuiSystem.data.tooltipTimers[id] == nil then
            ScpuiSystem.data.tooltipTimers[id] = 0
            ScpuiSystem:maybeShowTooltip(tool_el, id)
        end
    end)

    parent:AddEventListener("mouseout", function()
        ScpuiSystem.data.tooltipTimers[id] = nil
        tool_el:SetPseudoClass("shown", false)
    end)
end

--- Apply keyword classes to the input text which is then colorized
--- @param inputText string The text to colorize
--- @return string, table register The colorized text and a table of tooltips
function ScpuiSystem:applyKeywordClasses(inputText)
    local keywordAlgorithm = require("lib_keyword_agorithm")
    return keywordAlgorithm.colorize(inputText)
end

ScpuiSystem:initKeywords()