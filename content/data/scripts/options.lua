local utils    = require("utils")
local tblUtil  = utils.table

local rkt_util = require("rocket_util")

local dialogs  = require("dialogs")

local class    = require("class")

local function getFormatterName(key)
    return key:gsub("%.", "_")
end

local function getOptionElementId(option)
    local key = option.Key
    key       = key:gsub("%.", "_")
    key       = key:lower()

    return string.format("option_%s_element", key)
end

local DataSourceWrapper = class()

function DataSourceWrapper:init(option)
    self.option       = option

    local source      = DataSource.new(getFormatterName(option.Key))

    self.values       = option:getValidValues()
    source.GetNumRows = function()
        return #self.values
    end
    source.GetRow     = function(_, i, columns)
        local val = self.values[i]
        local out = {}
        for _, v in ipairs(columns) do
            if v == "serialized" then
                table.insert(out, val.Serialized)
            elseif v == "display" then
                table.insert(out, val.Display)
            else
                table.insert(out, "")
            end
        end
        return out
    end

    self.source       = source
end

function DataSourceWrapper:updateValues()
    self.values = self.option:getValidValues()
    self.source:NotifyRowChange("Default")
end

local function createOptionSource(option)
    return DataSourceWrapper(option)
end

local OptionsController = class()

function OptionsController:init()
    self.sources          = {}
    self.options          = {}
    self.category_options = {
        basic  = {},
        detail = {},
        other  = {},
        multi  = {}
    }
    -- A list of mappings option->ValueDescription which contains backups of the original values for special options
    -- that apply their changes immediately
    self.option_backup    = {}
end

function OptionsController:init_point_slider_element(value_el, btn_left, btn_right, point_buttons, option,
                                                     onchange_func)
    local value            = option.Value
    local range_val        = option:getInterpolantFromValue(value)
    local num_value_points = #point_buttons - 1

    local function updateRangeValue(value, range_val)
        option.Value = value
        if value_el then
            value_el.inner_rml = value.Display
        end

        -- This gives us the index of the last button that should be shown as active. The value is in the range between
        -- 0 and 1 so multiplying that with 9 maps that to our buttons since the first button has the value 0. We floor
        -- the value to get a definite index into our array
        -- + 1 is needed since Lua has 1-based arrays
        local last_active = math.floor(range_val * num_value_points) + 1

        for i, button in ipairs(point_buttons) do
            button:SetPseudoClass("checked", i <= last_active)
        end
    end

    updateRangeValue(value, range_val)

    for i, v in ipairs(point_buttons) do
        -- Basically the reverse from above, get the range value that corresponds to this button
        local btn_range_value = (i - 1) / num_value_points;

        v:AddEventListener("click", function()
            local option_val = option:getValueFromRange(btn_range_value)

            if option_val ~= option.Value then
                updateRangeValue(option_val, btn_range_value)

                if onchange_func then
                    onchange_func(option_val)
                end
            end
        end)
    end

    local function make_click_listener(value_increment)
        return function()
            local current_range_val = option:getInterpolantFromValue(option.Value)

            -- Every point more represents one num_value_points th of the range
            current_range_val       = current_range_val + value_increment
            if current_range_val < 0 then
                current_range_val = 0
            end
            if current_range_val > 1 then
                current_range_val = 1
            end

            local new_val = option:getValueFromRange(current_range_val)

            if new_val ~= option.Value then
                updateRangeValue(new_val, current_range_val)

                ui.playElementSound(btn_left, "click", "success")

                if onchange_func then
                    onchange_func(new_val)
                end
            else
                ui.playElementSound(btn_left, "click", "error")
            end
        end
    end

    btn_left:AddEventListener("click", make_click_listener(-(1.0 / num_value_points)))
    btn_right:AddEventListener("click", make_click_listener(1.0 / num_value_points))
end

function OptionsController:createTenPointRangeElement(option, parent_id, parameters, onchange_func)
    local parent_el                                                                                                      = self.document:GetElementById(parent_id)
    local actual_el, title_el, btn_left, btn_right, btn_0, btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9 = rkt_util.instantiate_template(self.document,
                                                                                                                                                         "tenpoint_selector_template",
                                                                                                                                                         getOptionElementId(option),
                                                                                                                                                         {
                                                                                                                                                             "tps_title_el",
                                                                                                                                                             "tps_left_arrow",
                                                                                                                                                             "tps_right_arrow",
                                                                                                                                                             "tps_button_0",
                                                                                                                                                             "tps_button_1",
                                                                                                                                                             "tps_button_2",
                                                                                                                                                             "tps_button_3",
                                                                                                                                                             "tps_button_4",
                                                                                                                                                             "tps_button_5",
                                                                                                                                                             "tps_button_6",
                                                                                                                                                             "tps_button_7",
                                                                                                                                                             "tps_button_8",
                                                                                                                                                             "tps_button_9",
                                                                                                                                                         },
                                                                                                                                                         parameters)
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

    self:init_point_slider_element(nil, btn_left, btn_right,
                                   { btn_0, btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9 }, option,
                                   onchange_func)

    return actual_el
end

function OptionsController:createFivePointRangeElement(option, parent_id, onchange_func)
    local parent_el                                                                             = self.document:GetElementById(parent_id)
    local actual_el, title_el, value_el, btn_left, btn_right, btn_0, btn_1, btn_2, btn_3, btn_4 = rkt_util.instantiate_template(self.document,
                                                                                                                                "fivepoint_selector_template",
                                                                                                                                getOptionElementId(option),
                                                                                                                                {
                                                                                                                                    "fps_title_text",
                                                                                                                                    "fps_value_text",
                                                                                                                                    "fps_left_btn",
                                                                                                                                    "fps_right_btn",
                                                                                                                                    "fps_button_0",
                                                                                                                                    "fps_button_1",
                                                                                                                                    "fps_button_2",
                                                                                                                                    "fps_button_3",
                                                                                                                                    "fps_button_4",
                                                                                                                                })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

    self:init_point_slider_element(value_el, btn_left, btn_right, { btn_0, btn_1, btn_2, btn_3, btn_4 }, option,
                                   onchange_func)

    return actual_el
end

function OptionsController:init_binary_element(left_btn, right_btn, option, vals, change_func)
    left_btn:AddEventListener("click", function()
        if vals[1] ~= option.Value then
            option.Value = vals[1]
            left_btn:SetPseudoClass("checked", true)
            right_btn:SetPseudoClass("checked", false)
            if change_func then
                change_func(vals[1])
            end
        end
    end)
    right_btn:AddEventListener("click", function()
        if vals[2] ~= option.Value then
            option.Value = vals[2]
            left_btn:SetPseudoClass("checked", false)
            right_btn:SetPseudoClass("checked", true)
            if change_func then
                change_func(vals[2])
            end
        end
    end)

    local value          = option.Value
    local right_selected = value == vals[2]
    left_btn:SetPseudoClass("checked", not right_selected)
    right_btn:SetPseudoClass("checked", right_selected)
end

function OptionsController:createBinaryOptionElement(option, vals, parent_id, onchange_func)
    local parent_el                                                       = self.document:GetElementById(parent_id)
    local actual_el, title_el, btn_left, text_left, btn_right, text_right = rkt_util.instantiate_template(self.document,
                                                                                                          "binary_selector_template",
                                                                                                          getOptionElementId(option),
                                                                                                          {
                                                                                                              "binary_text_el",
                                                                                                              "binary_left_btn_el",
                                                                                                              "binary_left_text_el",
                                                                                                              "binary_right_btn_el",
                                                                                                              "binary_right_text_el",
                                                                                                          })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml   = option.Title

    text_left.inner_rml  = vals[1].Display
    text_right.inner_rml = vals[2].Display

    self:init_binary_element(btn_left, btn_right, option, vals, onchange_func)

    return actual_el
end

function OptionsController:init_selection_element(element, option, vals, change_func)
    local select_el = Element.As.ElementFormControlDataSelect(element)
    select_el:SetDataSource(getFormatterName(option.Key) .. ".Default")

    local value = option.Value

    element:AddEventListener("change", function(event, _, _)
        for _, v in ipairs(vals) do
            if v.Serialized == event.parameters.value and option.Value ~= v then
                option.Value = v
                if change_func then
                    change_func(v)
                end
            end
        end
    end)

    select_el.selection = tblUtil.ifind(vals, value)
end

function OptionsController:createSelectionOptionElement(option, vals, parent_id, parameters, onchange_func)
    local parent_el                         = self.document:GetElementById(parent_id)
    local actual_el, text_el, dataselect_el = rkt_util.instantiate_template(self.document, "dropdown_template",
                                                                            getOptionElementId(option), {
                                                                                "dropdown_text_el",
                                                                                "dropdown_dataselect_el"
                                                                            }, parameters)
    parent_el:AppendChild(actual_el)

    -- If no_title was specified then this element will be nil
    if text_el ~= nil then
        text_el.inner_rml = option.Title
    end

    self:init_selection_element(dataselect_el, option, vals, onchange_func)

    return actual_el
end

function OptionsController:init_range_element(element, value_el, option, change_func)
    local range_el = Element.As.ElementFormControlInput(element)

    element:AddEventListener("change", function(event, _, _)
        local value        = option:getValueFromRange(event.parameters.value)
        value_el.inner_rml = value.Display

        if option.Value ~= value then
            option.Value = value
            if change_func then
                change_func(value)
            end
        end
    end)

    range_el.value = option:getInterpolantFromValue(option.Value)
end

function OptionsController:createRangeOptionElement(option, parent_id, onchange_func)
    local parent_el                               = self.document:GetElementById(parent_id)
    local actual_el, title_el, value_el, range_el = rkt_util.instantiate_template(self.document, "slider_template",
                                                                                  getOptionElementId(option), {
                                                                                      "slider_title_el",
                                                                                      "slider_value_el",
                                                                                      "slider_range_el"
                                                                                  })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

    self:init_range_element(range_el, value_el, option, onchange_func)

    return actual_el
end

function OptionsController:create(option, parent_id, onchange_func)
    local parent_el                               = self.document:GetElementById(parent_id)
    local actual_el, title_el, value_el, range_el = rkt_util.instantiate_template(self.document, "slider_template",
                                                                                  getOptionElementId(option), {
                                                                                      "slider_title_el",
                                                                                      "slider_value_el",
                                                                                      "slider_range_el"
                                                                                  })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

    self:init_range_element(range_el, value_el, option, onchange_func)

    return actual_el
end

function OptionsController:createOptionElement(option, parent_id, onchange_func)
    if option.Type == OPTION_TYPE_SELECTION then
        local vals = option:getValidValues()

        if #vals == 2 and not option.Flags.ForceMultiValueSelection then
            -- Special case for binary options
            return self:createBinaryOptionElement(option, vals, parent_id, onchange_func)
        else
            return self:createSelectionOptionElement(option, vals, parent_id, nil, onchange_func)
        end
    elseif option.Type == OPTION_TYPE_RANGE then
        return self:createRangeOptionElement(option, parent_id, onchange_func)
    end
end

function OptionsController:handleBrightnessOption(option, onchange_func)
    local increase_btn = self.document:GetElementById("brightness_increase_btn")
    local decrease_btn = self.document:GetElementById("brightness_decrease_btn")
    local value_el     = self.document:GetElementById("brightness_value_el")

    local vals         = option:getValidValues()
    local current      = option.Value

    value_el.inner_rml = current.Display

    increase_btn:AddEventListener("click", function()
        local current_index = tblUtil.ifind(vals, option.Value)
        current_index       = current_index + 1
        if current_index > #vals then
            current_index = #vals
        end
        local new_val = vals[current_index]

        if new_val ~= option.Value then
            option.Value       = new_val
            value_el.inner_rml = new_val.Display

            if onchange_func then
                onchange_func(new_val)
            end

            ui.playElementSound(increase_btn, "click", "success")
        else
            ui.playElementSound(increase_btn, "click", "error")
        end
    end)
    decrease_btn:AddEventListener("click", function()
        local current_index = tblUtil.ifind(vals, option.Value)
        current_index       = current_index - 1
        if current_index < 1 then
            current_index = 1
        end
        local new_val = vals[current_index]

        if new_val ~= option.Value then
            option.Value       = new_val
            value_el.inner_rml = new_val.Display

            if onchange_func then
                onchange_func(new_val)
            end

            ui.playElementSound(decrease_btn, "click", "success")
        else
            ui.playElementSound(decrease_btn, "click", "error")
        end
    end)
end

function OptionsController:initialize_basic_options()
    for _, option in ipairs(self.category_options.basic) do
        local key = option.Key
        if key == "Input.Joystick" then
            self:createSelectionOptionElement(option, option:getValidValues(), "joystick_values_wrapper", {
                no_title = true
            })
        elseif key == "Input.JoystickDeadZone" then
            self:createTenPointRangeElement(option, "joystick_values_wrapper", {
                text_alignment = "right",
                no_background  = true
            })
        elseif key == "Input.JoystickSensitivity" then
            self:createTenPointRangeElement(option, "joystick_values_wrapper", {
                text_alignment = "right",
                no_background  = true
            })
        elseif key == "Input.UseMouse" then
            self:createOptionElement(option, "mouse_options_container")
        elseif key == "Input.MouseSensitivity" then
            self:createTenPointRangeElement(option, "mouse_options_container", {
                text_alignment = "left",
                no_background  = false
            })
        elseif key == "Audio.BriefingVoice" then
            self:createOptionElement(option, "briefing_voice_container")
        elseif key == "Audio.Effects" then
            -- The audio options are applied immediately so the user hears the effects
            self.option_backup[option] = option.Value

            self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
            end)
        elseif key == "Audio.Music" then
            self.option_backup[option] = option.Value

            self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
            end)
        elseif key == "Audio.Voice" then
            self.option_backup[option] = option.Value

            self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
                ui.OptionsMenu.playVoiceClip()
            end)
        elseif key == "Game.SkillLevel" then
            self:createFivePointRangeElement(option, "skill_level_container")
        elseif key == "Graphics.Gamma" then
            self.option_backup[option] = option.Value

            self:handleBrightnessOption(option, function(_)
                -- Apply changes immediately to make them visible
                option:persistChanges()
            end)
        end
    end
end

local built_in_detail_keys = {
    "Graphics.NebulaDetail",
    "Graphics.Lighting",
    "Graphics.Detail",
    "Graphics.Texture",
    "Graphics.Particles",
    "Graphics.SmallDebris",
    "Graphics.ShieldEffects",
    "Graphics.Stars",
};

function OptionsController:initialize_detail_options()
    local current_column = 3
    for _, option in ipairs(self.category_options.detail) do
        if option.Key == "Graphics.Resolution" then
            self:createOptionElement(option, "detail_column_1")
        elseif option.Key == "Graphics.WindowMode" then
            self:createOptionElement(option, "detail_column_1")
        elseif option.Key == "Graphics.Display" then
            self:createOptionElement(option, "detail_column_1", function(_)
                self.sources["Graphics.Resolution"]:updateValues()
            end)
        elseif tblUtil.contains(built_in_detail_keys, option.Key) then
            self:createOptionElement(option, "detail_column_2")
        else
            local el = self:createOptionElement(option, string.format("detail_column_%d", current_column))

            if current_column == 2 or current_column == 3 then
                el:SetClass("horz_middle", true)
            elseif current_column == 4 then
                el:SetClass("horz_right", true)
            end

            current_column = current_column + 1
            if current_column > 4 then
                current_column = 3
            end
        end
    end
end

function OptionsController:initialize(document)
    self.document = document

    -- Persist current changes since we might discard them in this screen
    opt.persistChanges()

    self.options = opt.Options
    ba.print("Printing option ID mapping:\n")
    for _, v in ipairs(self.options) do
        ba.print(string.format("%s (%s): %s\n", v.Title, v.Key, getOptionElementId(v)))

        if v.Type == OPTION_TYPE_SELECTION then
            self.sources[v.Key] = createOptionSource(v)
        end

        -- TODO: The category might be a translated string at some point so this needs to be fixed then
        local category = v.Category
        local key      = v.Key

        if category == "Input" or category == "Audio" or category == "Game" or key == "Graphics.Gamma" then
            table.insert(self.category_options.basic, v)
        elseif category == "Graphics" then
            table.insert(self.category_options.detail, v)
        end
    end
    ba.print("Done.\n")

    self:initialize_basic_options()

    self:initialize_detail_options()
end

function OptionsController:accept_clicked(element)
    local unchanged = opt.persistChanges()

    if #unchanged <= 0 then
        -- All options were applied
        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
        return
    end

    local titles = {}
    for _, v in ipairs(unchanged) do
        table.insert(titles, string.format("<li>%s</li>", v.Title))
    end

    local changed_text = table.concat(titles, "\n")

    local dialog_text  = string.format(ba.XSTR("<p>The following changes require a restart to apply their changes:</p><p>%s</p>",
                                               -1), changed_text)

    local builder      = dialogs.new()
    builder:title(ba.XSTR("Restart required", -1))
    builder:text(dialog_text)
    builder:button(dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("Cancel", -1), false)
    builder:button(dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", -1), true)
    builder:show(self.document.context, function(val)
        if val then
            ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
        end
    end)
end

function OptionsController:discardChanges()
    opt.discardChanges()

    for opt, value in pairs(self.option_backup) do
        opt.Value = value
        opt:persistChanges()
    end
end

function OptionsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        self:discardChanges()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

function OptionsController:control_config_clicked()
    ba.postGameEvent(ba.GameEvents["GS_EVENT_CONTROL_CONFIG"])
end

function OptionsController:hud_config_clicked()
    ba.postGameEvent(ba.GameEvents["GS_EVENT_HUD_CONFIG"])
end

function OptionsController:exit_game_clicked()
    local builder = dialogs.new()
    builder:text(ba.XSTR("Exit Game?", -1))
    builder:button(dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("No", -1), false)
    builder:button(dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Yes", -1), true)
    builder:show(self.document.context, function(result)
        if not result then
            return
        end
        ba.postGameEvent(ba.GameEvents["GS_EVENT_QUIT_GAME"])
    end)
end

return OptionsController
