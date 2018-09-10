local utils = require("utils")
local tblUtil = utils.table

local dialogs = require("dialogs")

local VALID_MODES = { "single", "multi" }

pilot_select = {
    selection = nil,
    elements = {},
    callsign_input_active = false
}

function pilot_select:initialize(document)
    self.document = document

    local pilot_ul = document:GetElementById("pilotlist_ul")
    local pilots = ui.PilotSelect.enumeratePilots()

    local last = ui.PilotSelect.getLastPilot()
    if last ~= nil then
        -- Make sure that the last pilot appears at the top of the list
        local index = tblUtil.ifind(pilots, last.callsign)
        if index >= 0 then
            table.remove(pilots, index)
            table.insert(pilots, 1, last.callsign)
        end

        if last.is_multi then
            self:set_player_mode("multi")
        else
            self:set_player_mode("single")
        end
    end

    for i = 1, 20 do
        table.insert(pilots, "test " .. tostring(i))
    end

    self.pilots = pilots
    for _, v in ipairs(self.pilots) do
        local li_el = self:create_pilot_li(v)

        pilot_ul:AppendChild(li_el)
    end

    document:GetElementById("fso_version_info").inner_rml = ba.getVersionString()
    if last ~= nil then
        self:selectPilot(last.callsign)
    end
end

function pilot_select:create_pilot_li(pilot_name)
    local li_el = self.document:CreateElement("li")

    li_el.inner_rml = pilot_name
    li_el:SetClass("pilotlist_element", true)
    li_el:AddEventListener("click", function(_, _, _) self:selectPilot(pilot_name) end)

    self.elements[pilot_name] = li_el

    return li_el
end

function pilot_select:selectPilot(pilot)
    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[self.selection]:SetPseudoClass("checked", false)
    end

    self.selection = pilot

    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[pilot]:SetPseudoClass("checked", true)
        self.elements[pilot]:ScrollIntoView()
    end
end

function pilot_select:commit_pressed()
    local button = self.document:GetElementById("playercommit_btn")

    if self.selection == nil then
        ui.playElementSound(button, "click", "error")
        return
    end

    ui.PilotSelect.selectPilot(self.selection, self.current_mode == "multi")
    ui.playElementSound(button, "click", "commit")
end

function pilot_select:set_player_mode(mode)
    assert(tblUtil.contains(VALID_MODES, mode), "Mode " .. tostring(mode) .. " is not valid!")

    local elements = {
        {
            multi = "multiplayer_btn",
            single = "singleplayer_btn"
        },
        {
            multi = "multiplayer_text",
            single = "singleplayer_text"
        },
    }

    local is_single = mode == "single"
    self.current_mode = mode

    for _, v in ipairs(elements) do
        local multi_el = self.document:GetElementById(v.multi)
        local single_el = self.document:GetElementById(v.single)

        multi_el:SetPseudoClass("checked", not is_single)
        single_el:SetPseudoClass("checked", is_single)
    end
end

function pilot_select:callsign_input_focus_lost()
end

function pilot_select:callsign_input_cancel()
    local input_el = Element.As.ElementFormControlInput(self.document:GetElementById("pilot_name_input"))
    input_el:SetClass("hidden", true) -- Show the element
    input_el.value = ""

    self.callsign_input_active = false
    self.callsign_submit_action = nil
end

function pilot_select:callsign_input_change(event)
    if not self.callsign_input_active then
        -- Only process enter events when we are actually inputting something
        return
    end

    if event.parameters.linebreak ~= 1 then
        return
    end

    event:StopPropagation()
    self.callsign_submit_action(event.parameters.value)
    self:callsign_input_cancel()
end

function pilot_select:begin_callsign_input(end_action)
    local input_el = self.document:GetElementById("pilot_name_input")
    input_el:SetClass("hidden", false) -- Show the element
    input_el:Focus()

    self.callsign_input_active = true

    -- This is the function that will be executed when the name has been entered and submitted
    self.callsign_submit_action = end_action
end

function pilot_select:create_player()
    self:begin_callsign_input(function(callsign)
        if tblUtil.contains(self.pilots, callsign, function(left, right) return left:lower() == right:lower() end) then
            -- TODO: Add a popup asking the user for confirmation here
            return
        end

        if not ui.PilotSelect.createPilot(callsign, self.current_mode == "multi") then
            -- TODO: Play a fail sound here
            return
        end

        local pilot_ul = self.document:GetElementById("pilotlist_ul")
        local new_li = self:create_pilot_li(callsign)
        -- If first_child is nil then this will add at the end of the list
        pilot_ul:InsertBefore(new_li, pilot_ul.first_child)

        self:selectPilot(callsign)
    end)
end

function pilot_select:clone_player()
    local current = self.selection

    if current == nil then
        -- TODO: Add dialog here to let the player know that they need to select a pilot!
        return
    end

    self:begin_callsign_input(function(callsign)
        if tblUtil.contains(self.pilots, callsign, function(left, right) return left:lower() == right:lower() end) then
            -- TODO: Add a popup asking the user for confirmation here
            return
        end

        if not ui.PilotSelect.createPilot(callsign, self.current_mode == "multi", current) then
            -- TODO: Play a fail sound here
            return
        end

        local pilot_ul = self.document:GetElementById("pilotlist_ul")
        local new_li = self:create_pilot_li(callsign)
        -- If first_child is nil then this will add at the end of the list
        pilot_ul:InsertBefore(new_li, pilot_ul.first_child)

        self:selectPilot(callsign)
    end)
end

function pilot_select:delete_player()
    if self.selection == nil then
        return
    end

    if self.current_mode == "multi" then
        -- TODO: Add code for displaying a popup to let the player know that deleting only works in single player mode
        return
    end

    -- ui.PilotSelect.deletePilot(self.selection)

    -- Remove the element from the list
    local removed_el = self.elements[self.selection]
    removed_el.parent_node:RemoveChild(removed_el)
    self.elements[self.selection] = nil

    tblUtil.iremove_el(self.pilots, self.selection)

    self:selectPilot(nil)
end

function pilot_select:select_first()
    if #self.pilots <= 0 then
        self:selectPilot(nil)
        return
    end

    self:selectPilot(self.pilots[1])
end

function pilot_select:up_button_pressed()
    local builder = dialogs.new()
    builder:title("Title!")
    builder:text("Text!")
    builder:button(dialogs.BUTTON_TYPE_POSITIVE, "Yes!")
    builder:button(dialogs.BUTTON_TYPE_NEGATIVE, "No!")
    builder:show(self.document.context, function(result)
        ba.print(tostring(result))
    end)

    if self.selection == nil then
        self:select_first()
        return
    end

    local idx = tblUtil.ifind(self.pilots, self.selection)
    idx = idx + 1
    if idx > #self.pilots then
        idx = 1
    end

    self:selectPilot(self.pilots[idx])
end

function pilot_select:down_button_pressed()
    if self.selection == nil then
        self:select_first()
        return
    end

    local idx = tblUtil.ifind(self.pilots, self.selection)
    idx = idx - 1
    if idx < 1 then
        idx = #self.pilots
    end

    self:selectPilot(self.pilots[idx])
end
