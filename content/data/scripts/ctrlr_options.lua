-----------------------------------
--Controller for the Options UI
-----------------------------------

local AsyncUtil = require("lib_async")
local DataSource = require("lib_datasource")
local Dialogs  = require("lib_dialogs")
local Templates = require("lib_templates")
local Topics = require("lib_ui_topics")
local Utils = require("lib_utils")

local Class = require("lib_class")

local function getCategoryFromKey(key)
	return key:match("([^%.]+)")
end

local function getOptionElementId(option)
    local key = option.Key
    key       = key:gsub("%.", "_")
    key       = key:lower()

    return string.format("option_%s_element", key)
end

--- Creates a data source from an option
--- @param option scpui_custom_option
--- @return scpui_option_data_source
local function createOptionSource(option)
    return DataSource(option)
end

local OptionsController = Class()

function OptionsController:init()
	self.CustomValues = ScpuiSystem.data.ScpuiOptionValues --- @type custom_option_data Shorthand reference to the global options table
	self.CustomOptions = {} --- @type scpui_custom_option_control[] A table of custom option controls that have been created
	self.GraphicsOptions = {} --- @type scpui_graphics_option_control[] A table of graphics option controls that have been created
	self.ModCustom = true --- @type boolean Whether or not the custom options have been modified
	self.GraphicsCustom = true --- @type boolean Whether or not the graphics options have been modified

	self.GraphicsPresets = {
		"option_graphics_detail_element",
		"option_graphics_nebuladetail_element",
		"option_graphics_texture_element",
		"option_graphics_particles_element",
		"option_graphics_smalldebris_element",
		"option_graphics_shieldeffects_element",
		"option_graphics_stars_element",
		"option_graphics_lighting_element",
		"option_graphics_shadows_element",
		"option_graphics_anisotropy_element",
		"option_graphics_aamode_element",
		"option_graphics_msaasamples_element",
		"option_graphics_postprocessing_element",
		"option_graphics_lightshafts_element",
		"option_graphics_softparticles_element",
		"option_graphics_deferredlighting_element"
	}

	self.FontChoice = nil --- @type string The font class to be applied to the main background element

    self.DataSources = {} --- @type scpui_option_data_source[] A table of data sources for the options
    self.Options = {} --- @type scpui_custom_option[] A table of custom options
    self.Categorized_Options = {
        Basic  = {}, --- @type scpui_custom_option[] A table of basic options
        Graphics = {}, --- @type scpui_custom_option[] A table of graphics options
        Misc  = {}, --- @type scpui_custom_option[] A table of miscellaneous options
        Multi  = {} --- @type scpui_custom_option[] A table of multi options
    }

	self.TooltipTimers = {} --- @type number[] A table of timers for the options UI
    self.OptionBackups = {} --- @class ValueDescription[] A table of mappings option->ValueDescription which contains backups of the original values for special options that apply their changes immediately

	if mn.isInMission() then
		ScpuiSystem:pauseAllAudio(true)
	end

end

function OptionsController:init_point_slider_element(value_el, btn_left, btn_right, point_buttons, option,
                                                     onchange_func, el_actual)
    local value = nil
    local range_val = nil
    local num_value_points = #point_buttons - 1
	local Key = option.Key
	local custom_init = 0
	local default = nil

	if option.Category ~= "Custom" then
		value = option.Value
		range_val = option:getInterpolantFromValue(value)
	else
		local cur_val = (ScpuiSystem.data.ScpuiOptionValues[Key]) or option.Value
		value = (cur_val / #point_buttons) or 0
		range_val = (cur_val / #point_buttons) or 0
		self.CustomValues[Key] = ScpuiSystem.data.ScpuiOptionValues[Key] or option.Value
		default = option.Value
	end

    local function updateRangeValue(value, range_val)
        option.Value = value
        if value_el then
			if option.Category ~= "Custom" then
				value_el.inner_rml = value.Display
			else
				local index = (math.floor(option.Value * #point_buttons)) + custom_init
				if index > 5 then index = 5 end
				if index < 1 then index = 1 end
				if option.DisplayNames then
					value_el.inner_rml = option.DisplayNames[index]
				else
					value_el.inner_rml = index
				end
			end
        end

		if option.Category == "Custom" then
			self.CustomValues[Key] = (math.ceil(option.Value * #point_buttons)) + custom_init
			self.CustomOptions[Key].CurrentValue = (math.ceil(option.Value * #point_buttons)) + custom_init
			self.CustomOptions[Key].IncrementValue = option.Value
			self.CustomOptions[Key].SavedValue = (math.ceil(option.Value * #point_buttons)) + custom_init
			self:setModDefaultStatus()
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

	--Save all the data for custom options here for resetting to default
	if option.Category == "Custom" then
		local displayStrings = nil
		if option.DisplayNames then
			displayStrings = option.DisplayNames
		end
		self.CustomOptions[Key] = {
			Key = Key,
			Type = "MultiPoint",
			DefaultValue = default,
			CurrentValue = self.CustomValues[Key],
			SavedValue = self.CustomValues[Key],
			IncrementValue = value,
			ParentEl = el_actual,
			Buttons = point_buttons,
			NumPoints = num_value_points,
			Strings = displayStrings,
			Range = range_val,
			ValueEl = value_el,
			HasDefault = option.NoDefault
		}
	end

    updateRangeValue(value, range_val)

    for i, v in ipairs(point_buttons) do
        -- Basically the reverse from above, get the range value that corresponds to this button
        local btn_range_value = (i - 1) / num_value_points


        v:AddEventListener("click", function()
			local option_val = nil
			custom_init = 1

			if option.Category ~= "Custom" then
				option_val = option:getValueFromRange(btn_range_value)
				if option_val ~= option.Value then
					updateRangeValue(option_val, btn_range_value)
					if onchange_func then
						onchange_func(option_val)
					end
				end
			else
				option_val = (i - 1) / (num_value_points +1)
				if option_val ~= self.CustomOptions[Key].IncrementValue then
					updateRangeValue(option_val, btn_range_value)
					self.CustomValues[Key] = (1 + math.ceil(option_val * #point_buttons))
					if onchange_func then
						onchange_func(option_val)
					end
				end
			end
        end)
    end

    local function make_click_listener(value_increment)
        return function()
			custom_init = 0
            local current_range_val = nil
			if option.Category ~= "Custom" then
				current_range_val = option:getInterpolantFromValue(option.Value)
			else
				current_range_val = self.CustomOptions[Key].IncrementValue
			end

            -- Every point more represents one num_value_points th of the range
            current_range_val       = current_range_val + value_increment
            if current_range_val < 0 then
                current_range_val = 0
            end
            if current_range_val > 1 then
                current_range_val = 1
            end

			local new_val = nil

			if option.Category ~= "Custom" then
				new_val = option:getValueFromRange(current_range_val)
			else
				new_val = current_range_val
			end

            if new_val ~= option.Value then
				if option.Category ~= "Custom" then
					updateRangeValue(new_val, current_range_val)
				else
					updateRangeValue(new_val, current_range_val)
					self.CustomValues[Key] = (math.ceil(new_val * #point_buttons))
				end

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
    local parent_el                                                                                                      = self.Document:GetElementById(parent_id)
    local actual_el, title_el, btn_left, btn_right, btn_0, btn_1, btn_2, btn_3, btn_4, btn_5, btn_6, btn_7, btn_8, btn_9 = Templates.instantiate_template(self.Document,
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
                                   onchange_func, actual_el)

    return actual_el
end

function OptionsController:createFivePointRangeElement(option, parent_id, onchange_func)
    local parent_el                                                                             = self.Document:GetElementById(parent_id)
    local actual_el, title_el, value_el, btn_left, btn_right, btn_0, btn_1, btn_2, btn_3, btn_4 = Templates.instantiate_template(self.Document,
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
                                   onchange_func, actual_el)

    return actual_el
end

function OptionsController:init_binary_element(left_btn, right_btn, option, vals, change_func, el_actual)

	local Key = option.Key
	local default = nil

    left_btn:AddEventListener("click", function()
		if option.Category == "Custom" then
			option.Value = vals[1]
			self.CustomValues[Key] = option.Value
			self.CustomOptions[Key].CurrentValue = option.Value
			self.CustomOptions[Key].SavedValue = option.Value
			left_btn:SetPseudoClass("checked", true)
            right_btn:SetPseudoClass("checked", false)
			self:setModDefaultStatus()
		elseif option.Category ~= "Custom" and vals[1] ~= option.Value then
			option.Value = vals[1]
            left_btn:SetPseudoClass("checked", true)
            right_btn:SetPseudoClass("checked", false)
            if change_func then
                change_func(vals[1])
            end
			self:setGraphicsDefaultStatus()
        end
    end)
    right_btn:AddEventListener("click", function()
		if option.Category == "Custom" then
			option.Value = vals[2]
			self.CustomValues[Key] = option.Value
			self.CustomOptions[Key].CurrentValue = option.Value
			self.CustomOptions[Key].SavedValue = option.Value
			left_btn:SetPseudoClass("checked", false)
            right_btn:SetPseudoClass("checked", true)
			self:setModDefaultStatus()
		elseif option.Category ~= "Custom" and vals[2] ~= option.Value then
			option.Value = vals[2]
            left_btn:SetPseudoClass("checked", false)
            right_btn:SetPseudoClass("checked", true)
            if change_func then
                change_func(vals[2])
            end
			self:setGraphicsDefaultStatus()
        end
    end)

	if option.Category == "Custom" then
		default = option.Value
		option.Value = ScpuiSystem.data.ScpuiOptionValues[Key] or option.Value
		self.CustomValues[Key] = ScpuiSystem.data.ScpuiOptionValues[Key] or option.Value
	end

    local value          = option.Value
    local right_selected = value == vals[2]
    left_btn:SetPseudoClass("checked", not right_selected)
    right_btn:SetPseudoClass("checked", right_selected)

	--Save all the data for custom options here for resetting to default
	if option.Category == "Custom" then
		self.CustomOptions[Key] = {
			Key = Key,
			Type = "Binary",
			DefaultValue = default,
			CurrentValue = option.Value,
			SavedValue = option.Value,
			ValidValues = vals,
			ParentEl = el_actual,
			HasDefault = option.NoDefault
		}
	else
		for _, v in pairs(self.GraphicsPresets) do
			if el_actual.id == v then
				self.GraphicsOptions[Key] = {
					Key = Key,
					Title = option.Title,
					Type = "Binary",
					Option = option,
					CurrentValue = value,
					SavedValue = value,
					ValidValues = vals,
					ParentEl = el_actual
				}
			end
		end
	end

end

function OptionsController:createBinaryOptionElement(option, vals, parent_id, onchange_func)
    local parent_el                                                       = self.Document:GetElementById(parent_id)
    local actual_el, title_el, btn_left, text_left, btn_right, text_right = Templates.instantiate_template(self.Document,
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

	--OR is for custom options built from the CFG file
    text_left.inner_rml  = vals[1].Display or option.DisplayNames[vals[1]]
    text_right.inner_rml = vals[2].Display or option.DisplayNames[vals[2]]

    self:init_binary_element(btn_left, btn_right, option, vals, onchange_func, actual_el)

    return actual_el
end

function OptionsController:init_selection_element(element, option, vals, change_func, el_actual)

	local Key = option.Key
	local default = nil

    local select_el = Element.As.ElementFormControlDataSelect(element)
	if option.Category ~= "Custom" then
		select_el:SetDataSource(option.Key:gsub("%.", "_") .. ".Default")
	else
		select_el:SetDataSource(option.Key .. ".Default")
	end

	if option.Category == "Custom" then
		--Find the index of the translated value
		local count = 1
		for i = 1, #option.ValidValues do
			if option.Value == option.DisplayNames[option.ValidValues[i]] then
				count = i
				break
			end
		end

		default = option.Value
		option.Value = ScpuiSystem.data.ScpuiOptionValues[Key] or option.ValidValues[count]
		self.CustomValues[Key] = ScpuiSystem.data.ScpuiOptionValues[Key] or option.ValidValues[count]
	end

	local value = option.Value

    element:AddEventListener("change", function(event, _, _)
        for _, v in ipairs(vals) do
            if v.Serialized == event.parameters.value and option.Value ~= v then
                option.Value = v
                if change_func then
                    change_func(v)
                end
            end
			if option.Category == "Custom" then

				--Find the index of the translated value
				local count = 1
				for i = 1, #option.ValidValues do
					if event.parameters.value == option.DisplayNames[option.ValidValues[i]] then
						count = i
						break
					end
				end

				--Use the index to save the actual internal value
				self.CustomValues[Key] = vals[count]
				self.CustomOptions[Key].CurrentValue = vals[count]
				self.CustomOptions[Key].SavedValue = vals[count]
			else
				for _, v in pairs(self.GraphicsPresets) do
					if el_actual.id == v then
						if el_actual.id == "option_graphics_anisotropy_element" then
							--This option saves reports the string so we need to save the known index
							local a_value = 5
							if event.parameters.value == "1.0" then a_value = 1 end
							if event.parameters.value == "2.0" then a_value = 2 end
							if event.parameters.value == "4.0" then a_value = 3 end
							if event.parameters.value == "8.0" then a_value = 4 end
							self.GraphicsOptions[Key].CurrentValue = a_value
							self.GraphicsOptions[Key].SavedValue = a_value
						else
							--Translate from a 0 based index to a 1 based index because reasons??
							if tonumber(event.parameters.value) then
								self.GraphicsOptions[Key].CurrentValue = event.parameters.value + 1
								self.GraphicsOptions[Key].SavedValue = event.parameters.value + 1
							end
						end
					end
				end
			end
        end
		if option.Category ~= "Custom" then
			self:setGraphicsDefaultStatus()
		else
			self:setModDefaultStatus()
		end
    end)

	--Save all the data for custom options here for resetting to default
	if option.Category == "Custom" then
		self.CustomOptions[Key] = {
			Key = Key,
			Type = "Multi",
			DefaultValue = default,
			CurrentValue = option.Value,
			SavedValue = option.Value,
			ValidVals = vals,
			ParentEl = el_actual,
			SelectEl = select_el,
			HasDefault = option.NoDefault
		}
	else
		for k, v in pairs(self.GraphicsPresets) do
			if el_actual.id == v then
				self.GraphicsOptions[Key] = {
					Key = Key,
					Type = "Multi",
					CurrentValue = Utils.table.ifind(vals, value),
					SavedValue = Utils.table.ifind(vals, value),
					ValidValues = vals,
					ParentEl = el_actual,
					SelectEl = select_el
				}
			end
		end
	end
    select_el.selection = Utils.table.ifind(vals, value)
end

function OptionsController:createSelectionOptionElement(option, vals, parent_id, parameters, onchange_func)
    local parent_el                         = self.Document:GetElementById(parent_id)
    local actual_el, text_el, dataselect_el = Templates.instantiate_template(self.Document, "dropdown_template",
                                                                            getOptionElementId(option), {
                                                                                "dropdown_text_el",
                                                                                "dropdown_dataselect_el"
                                                                            }, parameters)
    parent_el:AppendChild(actual_el)

    -- If no_title was specified then this element will be nil
    if text_el ~= nil then
        text_el.inner_rml = option.Title
    end

    self:init_selection_element(dataselect_el, option, vals, onchange_func, actual_el)

    return actual_el
end

function OptionsController:init_range_element(element, value_el, option, change_func, el_actual)

	local Key = option.Key
	local default = nil

    local range_el = Element.As.ElementFormControlInput(element)

    element:AddEventListener("change", function(event, _, _)
		local value = nil
		if option.Category ~= "Custom" then
			value        = option:getValueFromRange(event.parameters.value)
			value_el.inner_rml = value.Display
		else
			value        = event.parameters.value
			value_el.inner_rml = tostring(value * option.Max):sub(1,4)
			self.CustomValues[Key] = tostring(value * option.Max):sub(1,4)
			if self.CustomOptions[Key] then
				self.CustomOptions[Key].CurrentValue = tostring(value * option.Max):sub(1,4)
				self.CustomOptions[Key].SavedValue = tostring(value * option.Max):sub(1,4)
				self:setModDefaultStatus()
			end
		end

        if option.Value ~= value then
            option.Value = value
            if change_func then
                change_func(value)
            end
        end
    end)

	--This is a special case just for Font_Multiplier to allow live update
	if Key == "Font_Adjustment" then
		element:AddEventListener("click", function(event, _, _)
			range_el.value = self.CustomOptions[Key].CurrentValue
			self.FontChoice = "base_font" .. ScpuiSystem:getFontPixelSize(self.CustomOptions[Key].CurrentValue)
			--Clear all possible font classes
			for i = 1, ScpuiSystem.data.NumFontSizes do
				local f_class = "base_font" .. i
				self.Document:GetElementById("main_background"):SetClass(f_class, false)
			end

			--Now apply the new class
			self.Document:GetElementById("main_background"):SetClass(self.FontChoice, true)
		end)
	end


	if option.Category ~= "Custom" then
		range_el.value = option:getInterpolantFromValue(option.Value)
	else
		local thisValue = ScpuiSystem.data.ScpuiOptionValues[Key] or option.Value
		default = option.Value
		option.Value = thisValue
		range_el.value = thisValue / option.Max
		range_el.step = (option.Max - option.Min) / 100
	end

	--Save all the data for custom options here for resetting to default
	if option.Category == "Custom" then
		self.CustomOptions[Key] = {
			Key = Key,
			Type = "Range",
			DefaultValue = default,
			CurrentValue = option.Value,
			SavedValue = option.Value,
			ParentEl = el_actual,
			RangeEl = range_el,
			MaxValue = option.Max,
			HasDefault = option.NoDefault
		}
	end
end

function OptionsController:createRangeOptionElement(option, parent_id, onchange_func)
    local parent_el                               = self.Document:GetElementById(parent_id)
    local actual_el, title_el, value_el, range_el = Templates.instantiate_template(self.Document, "slider_template",
                                                                                  getOptionElementId(option), {
                                                                                      "slider_title_el",
                                                                                      "slider_value_el",
                                                                                      "slider_range_el"
                                                                                  })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

    self:init_range_element(range_el, value_el, option, onchange_func, actual_el)

    return actual_el
end

function OptionsController:createHeaderOptionElement(option, parent_id)
    local parent_el                               = self.Document:GetElementById(parent_id)
    local actual_el, title_el = Templates.instantiate_template(self.Document, "header_template",
                                                               getOptionElementId(option), {
                                                                   "header_title_el"
                                                               })
    parent_el:AppendChild(actual_el)

    title_el.inner_rml = option.Title

	---Load the desired font size from the save file
	self.Document:GetElementById(actual_el.id):SetClass("p2", true)

    return actual_el
end

function OptionsController:create(option, parent_id, onchange_func)
    local parent_el                               = self.Document:GetElementById(parent_id)
    local actual_el, title_el, value_el, range_el = Templates.instantiate_template(self.Document, "slider_template",
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

function OptionsController:createCustomOptionElement(option, parent_id, onchange_func)
    if (option.Type == "Binary") or (option.Type == "Multi") then
        local vals = option.ValidValues

		--self.sources[option.Key] = createOptionSource(option)

        if #vals == 2 and not option.ForceSelector then
            -- Special case for binary options
            return self:createBinaryOptionElement(option, vals, parent_id, onchange_func)
        else
			return self:createSelectionOptionElement(option, vals, parent_id, nil, onchange_func)
        end
    elseif option.Type == "Range" then
        return self:createRangeOptionElement(option, parent_id, onchange_func)
	elseif option.Type == "TenPoint" then
		--local wrapper = option.Key .. "_wrapper"
		return self:createTenPointRangeElement(option, parent_id, {
                text_alignment = "left",
                no_background  = false
            })
    elseif option.Type == "FivePoint" then
		return self:createFivePointRangeElement(option, parent_id)
	elseif option.Type == "Header" then
        return self:createHeaderOptionElement(option, parent_id)
	end
end

function OptionsController:handleBrightnessOption(option, onchange_func)
    local increase_btn = self.Document:GetElementById("brightness_increase_btn")
    local decrease_btn = self.Document:GetElementById("brightness_decrease_btn")
    local value_el     = self.Document:GetElementById("brightness_value_el")

    local vals         = option:getValidValues()
    local current      = option.Value

    value_el.inner_rml = current.Display

    increase_btn:AddEventListener("click", function()
        local current_index = Utils.table.ifind(vals, option.Value)
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
        local current_index = Utils.table.ifind(vals, option.Value)
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
	--Create the font size selector option
	local fontAdjustment = {
		Title = Utils.xstr({"Font Size Adjustment", 888393}),
		Description = Utils.xstr({"Increases or decreases the font size", 888394}),
		Key = "Font_Adjustment",
		Type = "Range",
		Category = "Custom",
		Min = 0,
		Max = 1,
		Value = 0.5
	}
	local font_adjust_el = self:createCustomOptionElement(fontAdjustment, "font_size_selector")
	self:AddOptionTooltip(fontAdjustment, font_adjust_el)

	--Create the briefing render style option
	local briefRenderChoice = {
		Title = Utils.xstr({"Brief Render Option", 888554}),
		Description = Utils.xstr({"Toggles rendering directly to screen or to a texture. Can fix flickering in the briefing map.", 888555}),
		Key = "Brief_Render_Option",
		Type = "Binary",
		Category = "Custom",
		ValidValues = {
			[1] = "Texture",
			[2] = "Screen",
		},
		DisplayNames = {
			["Texture"] = Utils.xstr({"Texture", 888556}),
			["Screen"] = Utils.xstr({"Screen", 888557}),
		},
		Value = "Texture",
		ForceSelector = true
	}
	self.DataSources[briefRenderChoice.Key] = createOptionSource(briefRenderChoice)
	local brief_choice_el = self:createCustomOptionElement(briefRenderChoice, "brief_choice_selector")
	self:AddOptionTooltip(briefRenderChoice, brief_choice_el)

    for _, option in ipairs(self.Categorized_Options.Basic) do
        local key = option.Key
		local opt_el = nil
        if key == "Input.Joystick2" then
            opt_el = self:createSelectionOptionElement(option, option:getValidValues(), "joystick_column_1", {
                --no_title = true
            })
		elseif key == "Input.Joystick" then
            opt_el = self:createSelectionOptionElement(option, option:getValidValues(), "joystick_column_1", {
                --no_title = true
            })
		elseif key == "Input.Joystick1" then
            opt_el = self:createSelectionOptionElement(option, option:getValidValues(), "joystick_column_2", {
                --no_title = true
            })
		elseif key == "Input.Joystick3" then
            opt_el = self:createSelectionOptionElement(option, option:getValidValues(), "joystick_column_2", {
                --no_title = true
            })
        elseif key == "Input.JoystickDeadZone" then
            opt_el = self:createTenPointRangeElement(option, "joystick_values_wrapper", {
                text_alignment = "right",
                --no_background  = true
            })
        elseif key == "Input.JoystickSensitivity" then
            opt_el = self:createTenPointRangeElement(option, "joystick_values_wrapper", {
                text_alignment = "right",
                --no_background  = true
            })
        elseif key == "Input.UseMouse" then
            opt_el = self:createOptionElement(option, "mouse_options_container")
        elseif key == "Input.MouseSensitivity" then
            opt_el = self:createTenPointRangeElement(option, "mouse_options_container", {
                text_alignment = "left",
                no_background  = false
            })
		elseif key == "Game.Language" then
            opt_el = self:createSelectionOptionElement(option, option:getValidValues(), "language_selector", {
                --no_title = true
            })
		elseif key == "Input.ForceFeedback" then
            opt_el = self:createOptionElement(option, "force_feeback_selector")
        elseif key == "Input.FFStrength" then
            opt_el = self:createOptionElement(option, "force_feedback_sensitivity")
		elseif key == "Input.HitEffect" then
            opt_el = self:createOptionElement(option, "directional_hit")
        elseif key == "Audio.Effects" then
            -- The audio options are applied immediately so the user hears the effects
            self.OptionBackups[option] = option.Value

            opt_el = self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
				Topics.options.changeEffectsVol:send(self)
            end)
        elseif key == "Audio.Music" then
            self.OptionBackups[option] = option.Value

            opt_el = self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
            end)
        elseif key == "Audio.Voice" then
            self.OptionBackups[option] = option.Value

            opt_el = self:createTenPointRangeElement(option, "volume_sliders_container", {
                text_alignment = "left",
                no_background  = true
            }, function(_)
                option:persistChanges()
                ui.OptionsMenu.playVoiceClip()
				Topics.options.changeVoiceVol:send(self)
            end)
        elseif key == "Game.SkillLevel" then
            opt_el = self:createFivePointRangeElement(option, "skill_level_container")
        elseif key == "Graphics.Gamma" then
            self.OptionBackups[option] = option.Value

            self:handleBrightnessOption(option, function(_)
                -- Apply changes immediately to make them visible
                option:persistChanges()
            end)

			opt_el = self.Document:GetElementById("gamma_option")
        end

		if option.Description then
			self:AddOptionTooltip(option, opt_el)
		end
    end
end

local built_in_graphics_keys = {
    "Graphics.NebulaDetail",
    "Graphics.Lighting",
    "Graphics.Detail",
    "Graphics.Texture",
    "Graphics.Particles",
    "Graphics.SmallDebris",
    "Graphics.ShieldEffects",
    "Graphics.Stars",
};

function OptionsController:initialize_graphics_options()
    local current_column = 3
    for _, option in ipairs(self.Categorized_Options.Graphics) do
		local opt_el = nil

        if option.Key == "Graphics.Resolution" then
            opt_el = self:createOptionElement(option, "graphics_column_1")
        elseif option.Key == "Graphics.WindowMode" then
            opt_el = self:createOptionElement(option, "graphics_column_1")
        elseif option.Key == "Graphics.Display" then
            opt_el = self:createOptionElement(option, "graphics_column_1", function(_)
                self.DataSources["Graphics.Resolution"]:updateValues()
            end)
        elseif Utils.table.contains(built_in_graphics_keys, option.Key) then
            opt_el = self:createOptionElement(option, "graphics_column_2")
        else
            local el = self:createOptionElement(option, string.format("graphics_column_%d", current_column))

			opt_el = el

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

		if option.Description then
			self:AddOptionTooltip(option, opt_el)
		end
    end

	self:setGraphicsDefaultStatus()
end

--Here are where we parse and place mod options into the Misc tab
function OptionsController:initialize_misc_options()
    local current_column = 1
	local count = 1

	--Handle built-in preferences options
	for _, option in ipairs(self.Categorized_Options.Misc) do
		local el = self:createOptionElement(option, string.format("misc_column_%d", current_column))

		if option.Description then
			self:AddOptionTooltip(option, el)
		end

		if current_column == 2 or current_column == 3 then
			el:SetClass("horz_middle", true)
		elseif current_column == 4 then
			el:SetClass("horz_right", true)
		end

		count = count + 1

		if count > 10 then
			current_column = current_column + 1
			if current_column > 4 then
				current_column = 1
			end
			count = 1
		end
	end

end

--Here are where we parse and place mod options into the Preferences tab
function OptionsController:initialize_custom_options()
    for _, option in ipairs(ScpuiSystem.data.Custom_Options) do
		option.Category = "Custom"
		--option.Title = option.Title
		local el = self:createCustomOptionElement(option, string.format("custom_column_%d", option.Column))

		if option.Description then
			self:AddOptionTooltip(option, el)
		end

		if option.Column == 2 or option.Column == 3 then
			el:SetClass("horz_middle", true)
		elseif option.Column == 4 then
			el:SetClass("horz_right", true)
		end
    end

	self:setModDefaultStatus()
end

function OptionsController:remove_selected_ip()
	if self.selectedIP then
		local ip_el = self.Document:GetElementById("ipaddress_list")
		for _, child in ipairs(ip_el.child_nodes) do
			if child.id == self.selectedIP.id then
				ip_el:RemoveChild(child)
				break
			end
		end
	end
end

function OptionsController:IsDuplicateIP(id)
	local ip_el = self.Document:GetElementById("ipaddress_list")
	for _, child in ipairs(ip_el.child_nodes) do
		if child.id == id then
			return true
		end
	end

	return false
end

function OptionsController:add_selected_ip()
	if string.len(self.submittedIP) > 0 then
		if not self:IsDuplicateIP(self.submittedIP) then
			if opt.verifyIPAddress(self.submittedIP) then
				local ip_el = self.Document:GetElementById("ipaddress_list")
				ip_el:AppendChild(self:CreateIPItem(self.submittedIP))
			else
				local builder      = Dialogs.new()
				builder:title(ba.XSTR("Invalid IP", 888376))
				builder:text(ba.XSTR("Ip string is invalid!", 888377))
				builder:escape(false)
				builder:button(Dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", 888286), true, string.sub(ba.XSTR("Ok", 888286), 1, 1))
				builder:show(self.Document.context):continueWith(function() end)
			end
		else
			local builder      = Dialogs.new()
			builder:title(ba.XSTR("Duplicate IP", 888380))
			builder:text(ba.XSTR("IP Address already listed!", 888381))
			builder:escape(false)
			builder:button(Dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", 888286), true, string.sub(ba.XSTR("Ok", 888286), 1, 1))
			builder:show(self.Document.context):continueWith(function() end)
		end
	end

	self.ip_input_el:SetAttribute("value", "")
	self.submittedIP = ""
end

function OptionsController:ip_input_change(event)
	--remove all whitespace
	local stringValue = event.parameters.value:gsub("^%s*(.-)%s*$", "%1")

	--If RETURN was not pressed then make sure the input is a number with no spaces. Else save the value, clear the field, and continue.
	if event.parameters.linebreak ~= 1 then
		local lastCharacter = string.sub(stringValue, -1)
		if type(tonumber(lastCharacter)) == "number" or lastCharacter == "." then
			self.ip_input_el:SetAttribute("value", stringValue)
		else
			--remove the trailing character because it was not valid
			stringValue = stringValue:sub(1, -2)
			self.ip_input_el:SetAttribute("value", stringValue)
		end

		self.submittedIP = self.ip_input_el:GetAttribute("value")
	else
		self:add_selected_ip()
	end
end

function OptionsController:SelectIP(el)
	if self.selectedIP then
		self.selectedIP:SetPseudoClass("checked", false)
	end
	self.selectedIP = el
	self.selectedIP:SetPseudoClass("checked", true)
end

function OptionsController:CreateIPItem(entry)

	local li_el = self.Document:CreateElement("li")

	li_el.inner_rml = entry
	li_el.id = entry

	li_el:SetClass("ipaddress_list_element", true)
	li_el:SetClass("button_1", true)
	li_el:AddEventListener("click", function(_, _, _)
		self:SelectIP(li_el)
	end)

	return li_el
end

function OptionsController:login_changed()
	self.login_changed = true
end

function OptionsController:password_changed()
	self.pass_changed = true
end

function OptionsController:squad_changed()
	self.squad_changed = true
end

function OptionsController:initialize_multi_options()

	--Handle the IP Address list
	local ips = opt.readIPAddressTable()
	self.submittedIP = ""
	self.ip_input_el = self.Document:GetElementById("add_ip_field")

	local ip_el = self.Document:GetElementById("ipaddress_list")

	for i = 1, #ips do
		ip_el:AppendChild(self:CreateIPItem(ips[i]))
	end

	local ip_opt = {
		Key = "ipaddress_list",
		Description = "IP Addresses to watch or something. I dunno. Mjn Fix this."
	}

	self:AddOptionTooltip(ip_opt, self.Document:GetElementById("ipaddress_list"))

	--Handle the login info
	self.Document:GetElementById("login_field"):SetAttribute("value", opt.MultiLogin)
	self.Document:GetElementById("squad_field"):SetAttribute("value", opt.MultiSquad)
	if opt.MultiPassword then
		self.Document:GetElementById("pass_field"):SetAttribute("value", "******")
	end

	self.login_changed = false
	self.pass_changed = false
	self.squad_changed = false

	local login_opt = {
		Key = "login_info",
		Description = "Your PXO multiplayer username"
	}

	local pass_opt = {
		Key = "password_info",
		Description = "Your PXO multiplayer password"
	}

	local squad_opt = {
		Key = "squad_info",
		Description = "Your PXO multiplayer squadron name"
	}

	self:AddOptionTooltip(login_opt, self.Document:GetElementById("login_field").parent_node)
	self:AddOptionTooltip(pass_opt, self.Document:GetElementById("pass_field").parent_node)
	self:AddOptionTooltip(squad_opt, self.Document:GetElementById("squad_field").parent_node)

	--Handle the rest of the options
	for _, option in ipairs(self.Categorized_Options.Multi) do
		local opt_el = nil
		if option.Key == "Multi.LocalBroadcast" then
			opt_el = self.Document:GetElementById("local_btn")
			opt_el:AddEventListener("click", function()
				local opt_el = self.Document:GetElementById("local_btn")
				local vals = option:getValidValues()
				if option.Value.Display == "On" then
					opt_el:SetPseudoClass("checked", false)
					option.Value = vals[1]
				else
					opt_el:SetPseudoClass("checked", true)
					option.Value = vals[2]
				end
			end)
			if option.Value.Display == "On" then
				opt_el:SetPseudoClass("checked", true)
			else
				opt_el:SetPseudoClass("checked", false)
			end
		elseif option.Key == "Multi.TogglePXO" then
			opt_el = self.Document:GetElementById("pxo_btn")
			opt_el:AddEventListener("click", function()
				local opt_el = self.Document:GetElementById("pxo_btn")
				local vals = option:getValidValues()
				if option.Value.Display == "On" then
					opt_el:SetPseudoClass("checked", false)
					option.Value = vals[1]
				else
					opt_el:SetPseudoClass("checked", true)
					option.Value = vals[2]
				end
			end)
			if option.Value.Display == "On" then
				opt_el:SetPseudoClass("checked", true)
			else
				opt_el:SetPseudoClass("checked", false)
			end
			self:AddOptionTooltip(option, opt_el)
		elseif option.Key == "Multi.TransferMissions" then
			opt_el = self:createOptionElement(option, "multi_column_2")
		elseif option.Key == "Multi.FlushCache" then
			opt_el = self:createOptionElement(option, "multi_column_2")
		end

		self:AddOptionTooltip(option, opt_el)
	end
end

function OptionsController:AddOptionTooltip(option, parent)
	if option == nil or parent == nil then
		return
	end

	local tool_el = self.Document:CreateElement("div")
	tool_el.id = option.Key .. "_tooltip"
	tool_el:SetClass("tooltip", true)
	tool_el.inner_rml = "<span class=\"tooltiptext\">" .. option.Description .. "</span>"
	parent:AppendChild(tool_el)

	parent:AddEventListener("mouseover", function()
		if self.TooltipTimers[option.Key] == nil then
			self.TooltipTimers[option.Key] = 0
		else
			self:MaybeShowTooltip(tool_el, option.Key)
		end
	end)

	parent:AddEventListener("mouseout", function()
		self.TooltipTimers[option.Key] = nil
		tool_el:SetPseudoClass("shown", false)
	end)
end

function OptionsController:MaybeShowTooltip(tool_el, key)
	if self.TooltipTimers[key] == nil then
		return
	end

	if self.TooltipTimers[key] >= 5 then
		tool_el:SetPseudoClass("shown", true)
	else
		async.run(function()
			async.await(AsyncUtil.wait_for(1.0))
			if self.TooltipTimers[key] ~= nil then
				self.TooltipTimers[key] = self.TooltipTimers[key] + 1
				self:MaybeShowTooltip(tool_el, key)
			end
		end, async.OnFrameExecutor)
	end
end

---@param document Document
function OptionsController:initialize(document)
    self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

    -- Persist current changes since we might discard them in this screen
    opt.persistChanges()

    self.Options = opt.Options
    ba.print("Printing option ID mapping:\n")
    for _, v_opt in ipairs(self.Options) do
        ba.print(string.format("%s (%s): %s\n", v_opt.Title, v_opt.Key, getOptionElementId(v_opt)))

		--Creates data sources for built-in dropdowns
        if v_opt.Type == OPTION_TYPE_SELECTION then
            self.DataSources[v_opt.Key] = createOptionSource(v_opt)
        end

		--Creates data sources for custom dropdowns
		for _, v_custopt in ipairs(ScpuiSystem.data.Custom_Options) do
			v_custopt.Category = "Custom"
			if (v_custopt.Type == "Multi") or (v_custopt.Type == "Binary") then
				self.DataSources[v_custopt.Key] = createOptionSource(v_custopt)
			end
		end

        local category = getCategoryFromKey(v_opt.Key)
        local key      = v_opt.Key

		local basicOptions = {
			"Input.Joystick",
			"Input.Joystick1",
			"Input.Joystick2",
			"Input.Joystick3",
			"Input.JoystickDeadZone",
			"Input.JoystickSensitivity",
			"Input.ForceFeedback",
			"Input.FFStrength",
			"Input.HitEffect",
			"Input.UseMouse",
			"Input.MouseSensitivity",
			"Game.Language",
			"Audio.Effects",
			"Audio.Music",
			"Audio.Voice",
			"Game.SkillLevel",
			"Graphics.Gamma"
		}

        if Utils.table.contains(basicOptions, key) then
            table.insert(self.Categorized_Options.Basic, v_opt)
        elseif category == "Graphics" then
            table.insert(self.Categorized_Options.Graphics, v_opt)
		elseif category == "Multi" then
			table.insert(self.Categorized_Options.Multi, v_opt)
		else
            table.insert(self.Categorized_Options.Misc, v_opt)
        end
    end
    ba.print("Done.\n")

    self:initialize_basic_options()

	self:initialize_misc_options()

    self:initialize_graphics_options()

	self:initialize_multi_options()

	self:initialize_custom_options()

	if ScpuiSystem.data.table_flags.HideMulti == true then
		self.Document:GetElementById("multi_btn"):SetClass("hidden", true)
	end

	Topics.options.initialize:send(self)
end

function OptionsController:acceptChanges(state)

	ScpuiSystem.data.ScpuiOptionValues = self.CustomValues

	--Save mod options to file
	ScpuiSystem:saveOptionsToFile(ScpuiSystem.data.ScpuiOptionValues)

	--Save mod options to global file for recalling before a player is selected
	local saveFilename = "scpui_options_global.cfg"

	---@type json
	local json = require('dkjson')
    local file = cf.openFile(saveFilename, 'w', 'data/players')
    file:write(json.encode(ScpuiSystem.data.ScpuiOptionValues))
    file:close()

	--Persist base options
    local unchanged = opt.persistChanges()

	--Save the IP table
	local ip_el = self.Document:GetElementById("ipaddress_list")
	local ip_tbl = {}
	for _, child in ipairs(ip_el.child_nodes) do
		table.insert(ip_tbl, child.inner_rml)
	end
	opt.writeIPAddressTable(ip_tbl)

	--Save the login info
	if self.login_changed == true then
		opt.MultiLogin = self.Document:GetElementById("login_field"):GetAttribute("value")
	end
	if self.pass_changed == true then
		opt.MultiPassword = self.Document:GetElementById("pass_field"):GetAttribute("value")
	end
	if self.squad_changed == true then
		opt.MultiSquad = self.Document:GetElementById("squad_field"):GetAttribute("value")
	end

	ui.OptionsMenu.savePlayerData()

    if #unchanged <= 0 then
        -- All options were applied
		if mn.isInMission() then
			ScpuiSystem:pauseAllAudio(false)
		end
        ba.postGameEvent(ba.GameEvents[state])
        return
    end

    local titles = {}
    for _, v in ipairs(unchanged) do
        table.insert(titles, string.format("<li>%s</li>", v.Title))
    end

    local changed_text = table.concat(titles, "\n")

    local dialog_text  = string.format(ba.XSTR("<p>The following changes require a restart to apply their changes:</p><p>%s</p>",
                                               888384), changed_text)

    local builder      = Dialogs.new()
    builder:title(ba.XSTR("Restart required", 888385))
    builder:text(dialog_text)
	builder:escape(false)
    builder:button(Dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("Cancel", 888091), false, string.sub(ba.XSTR("Cancel", 888091), 1, 1))
    builder:button(Dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", 888286), true, string.sub(ba.XSTR("Ok", 888286), 1, 1))
    builder:show(self.Document.context):continueWith(function(val)
        if val then

			if mn.isInMission() then
				ScpuiSystem:pauseAllAudio(false)
			end

            ba.postGameEvent(ba.GameEvents[state])
        end
    end)
end

function OptionsController:SetGraphicsBullet(level)

	local lowbullet = self.Document:GetElementById("det_low_btn")
	local medbullet = self.Document:GetElementById("det_med_btn")
	local higbullet = self.Document:GetElementById("det_hig_btn")
	local ultbullet = self.Document:GetElementById("det_ult_btn")
	local cstbullet = self.Document:GetElementById("det_cst_btn")
	local minbullet = self.Document:GetElementById("det_min_btn")

	minbullet:SetPseudoClass("checked", level == "min")
	lowbullet:SetPseudoClass("checked", level == "low")
	medbullet:SetPseudoClass("checked", level == "med")
	higbullet:SetPseudoClass("checked", level == "hig")
	ultbullet:SetPseudoClass("checked", level == "ult")
	cstbullet:SetPseudoClass("checked", level == "cst")

end

function OptionsController:set_detail_minimum(element)

	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		for _, v_gr_preset in pairs(self.GraphicsPresets) do
			if option.ParentEl.id == v_gr_preset then
				local parent = self.Document:GetElementById(option.ParentEl.id)
				local savedValue = option.SavedValue
				if option.Type == "Multi" then
					if option.ParentEl.id == "option_graphics_aamode_element" then
						option.CurrentValue = 1
						option.SelectEl.selection = 1
					elseif option.ParentEl.id == "option_graphics_msaasamples_element" then
						option.CurrentValue = 1
						option.SelectEl.selection = 1
					else
						option.CurrentValue = 1
						option.SelectEl.selection = 1
					end
				elseif option.Type == "Binary" then
					option.CurrentValue = option.ValidValues[1]
					local right_selected = option.CurrentValue == option.ValidValues[2]
					parent.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					parent.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
					local opts = opt.Options
					for _, v_opt in pairs(opts) do
						if v_opt.Key == option.Key then
							v_opt.Value = option.ValidValues[1]
						end
					end
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.GraphicsCustom = false
	self:SetGraphicsBullet("min")

end

function OptionsController:set_detail_low(element)

	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		for _, v_gr_preset in pairs(self.GraphicsPresets) do
			if option.ParentEl.id == v_gr_preset then
				local savedValue = option.SavedValue
				if option.Type == "Multi" then
					if option.ParentEl.id == "option_graphics_aamode_element" then
						option.CurrentValue = 5
						option.SelectEl.selection = 5
					elseif option.ParentEl.id == "option_graphics_msaasamples_element" then
						option.CurrentValue = 1
						option.SelectEl.selection = 1
					else
						option.CurrentValue = 2
						option.SelectEl.selection = 2
					end
				elseif option.Type == "Binary" then
					option.CurrentValue = option.ValidValues[1]
					local right_selected = option.CurrentValue == option.ValidValues[2]
					option.ParentEl.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					option.ParentEl.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
					local opts = opt.Options
					for _, v_opt in pairs(opts) do
						if v_opt.Key == option.Key then
							v_opt.Value = option.ValidValues[1]
						end
					end
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.GraphicsCustom = false
	self:SetGraphicsBullet("low")

end

function OptionsController:set_detail_medium(element)

	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		for _, v_gr_preset in pairs(self.GraphicsPresets) do
			if option.ParentEl.id == v_gr_preset then
				local savedValue = option.SavedValue
				if option.Type == "Multi" then
					if option.ParentEl.id == "option_graphics_aamode_element" then
						option.CurrentValue = 6
						option.SelectEl.selection = 6
					elseif option.ParentEl.id == "option_graphics_msaasamples_element" then
						option.CurrentValue = 2
						option.SelectEl.selection = 2
					else
						option.CurrentValue = 3
						option.SelectEl.selection = 3
					end
				elseif option.Type == "Binary" then
					option.CurrentValue = option.ValidValues[1]
					local right_selected = option.CurrentValue == option.ValidValues[2]
					option.ParentEl.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					option.ParentEl.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
					local opts = opt.Options
					for _, v_opt in pairs(opts) do
						if v_opt.Key == option.Key then
							v_opt.Value = option.ValidValues[1]
						end
					end
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.GraphicsCustom = false
	self:SetGraphicsBullet("med")

end

function OptionsController:set_detail_high(element)

	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		for _, v_gr_preset in pairs(self.GraphicsPresets) do
			if option.ParentEl.id == v_gr_preset then
				local savedValue = option.SavedValue
				if option.Type == "Multi" then
					if option.ParentEl.id == "option_graphics_aamode_element" then
						option.CurrentValue = 7
						option.SelectEl.selection = 7
					elseif option.ParentEl.id == "option_graphics_msaasamples_element" then
						option.CurrentValue = 3
						option.SelectEl.selection = 3
					else
						option.CurrentValue = 4
						option.SelectEl.selection = 4
					end
				elseif option.Type == "Binary" then
					option.CurrentValue = option.ValidValues[2]
					local right_selected = option.CurrentValue == option.ValidValues[2]
					option.ParentEl.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					option.ParentEl.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
					local opts = opt.Options
					for _, v_opt in pairs(opts) do
						if v_opt.Key == option.Key then
							v_opt.Value = option.ValidValues[2]
						end
					end
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.GraphicsCustom = false
	self:SetGraphicsBullet("hig")

end

function OptionsController:set_detail_ultra(element)

	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		for _, v_gr_preset in pairs(self.GraphicsPresets) do
			if option.ParentEl.id == v_gr_preset then
				local savedValue = option.SavedValue
				if option.Type == "Multi" then
					if option.ParentEl.id == "option_graphics_aamode_element" then
						option.CurrentValue = 8
						option.SelectEl.selection = 8
					elseif option.ParentEl.id == "option_graphics_msaasamples_element" then
						option.CurrentValue = 4
						option.SelectEl.selection = 4
					else
						option.CurrentValue = 5
						option.SelectEl.selection = 5
					end
				elseif option.Type == "Binary" then
					option.CurrentValue = option.ValidValues[2]
					local right_selected = option.CurrentValue == option.ValidValues[2]
					option.ParentEl.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					option.ParentEl.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
					local opts = opt.Options
					for _, v_opt in pairs(opts) do
						if v_opt.Key == option.Key then
							v_opt.Value = option.ValidValues[2]
						end
					end
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.GraphicsCustom = false
	self:SetGraphicsBullet("ult")

end

function OptionsController:set_detail_custom(element)

	if self.GraphicsCustom == false then
		for k_gr_option, _ in pairs(self.GraphicsOptions) do
			local option = self.GraphicsOptions[k_gr_option]
			for _, v_gr_preset in pairs(self.GraphicsPresets) do
				if option.ParentEl.id == v_gr_preset then
					if option.Type == "Multi" then
						option.CurrentValue = option.SavedValue
						option.SelectEl.selection = option.SavedValue
					elseif option.Type == "Binary" then
						option.CurrentValue = option.SavedValue
						local right_selected = option.SavedValue == option.ValidValues[2]
						option.ParentEl.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
						option.ParentEl.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
						local opts = opt.Options
						for _, v_opt in pairs(opts) do
							if v_opt.Key == option.Key then
								v_opt.Value = option.SavedValue
							end
						end
					end
				end
			end
		end

		self.GraphicsCustom = true
		self:SetGraphicsBullet("cst")
	end

end

function OptionsController:isGraphicsPreset(value)
	for k_gr_option, _ in pairs(self.GraphicsOptions) do
		local option = self.GraphicsOptions[k_gr_option]
		if option.ParentEl.id == "option_graphics_aamode_element" then
			local a_value = 8
			if value == 1 then a_value = 1 end
			if value == 2 then a_value = 5 end
			if value == 3 then a_value = 6 end
			if value == 4 then a_value = 7 end
			if option.CurrentValue ~= a_value then
				return false
			end
		elseif option.ParentEl.id == "option_graphics_postprocessing_element" then
			local a_value = "On"
			if value == 1 then a_value = "Off" end
			if value == 2 then a_value = "Off" end
			if value == 3 then a_value = "Off" end
			if value == 4 then a_value = "On" end
			if option.CurrentValue.Display ~= a_value then
				return false
			end
		elseif option.ParentEl.id == "option_graphics_lightshafts_element" then
			local a_value = "On"
			if value == 1 then a_value = "Off" end
			if value == 2 then a_value = "Off" end
			if value == 3 then a_value = "Off" end
			if value == 4 then a_value = "On" end
			if option.CurrentValue.Display ~= a_value then
				return false
			end
		elseif option.ParentEl.id == "option_graphics_softparticles_element" then
			local a_value = "On"
			if value == 1 then a_value = "Off" end
			if value == 2 then a_value = "Off" end
			if value == 3 then a_value = "Off" end
			if value == 4 then a_value = "On" end
			if option.CurrentValue.Display ~= a_value then
				return false
			end
		else
			if option.CurrentValue ~= value then
				return false
			end
		end
	end
	return true
end

function OptionsController:setGraphicsDefaultStatus()

	local preset = "cst"
	self.GraphicsCustom = true

	if self:isGraphicsPreset(1) then
		preset = "min"
		self.GraphicsCustom = false
	elseif self:isGraphicsPreset(2) then
		preset = "low"
		self.GraphicsCustom = false
	elseif self:isGraphicsPreset(3) then
		preset = "med"
		self.GraphicsCustom = false
	elseif self:isGraphicsPreset(4) then
		preset = "hig"
		self.GraphicsCustom = false
	elseif self:isGraphicsPreset(5) then
		preset = "ult"
		self.GraphicsCustom = false
	end

	self:SetGraphicsBullet(preset)

end

function OptionsController:set_mod_detail_default(element)

	for k, _ in pairs(self.CustomOptions) do
		local option = self.CustomOptions[k]
		if not option.HasDefault then
			if option.Type == "Binary" and option.CurrentValue ~= option.DefaultValue then
				local parent = self.Document:GetElementById(option.ParentEl.id)
				self.CustomValues[option.Key] = option.DefaultValue
				option.CurrentValue = option.DefaultValue
				local right_selected = option.DefaultValue == option.ValidValues[2]
				parent.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
				parent.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
			end

			if option.Type == "Multi" and option.CurrentValue ~= option.DefaultValue then
				local parent = self.Document:GetElementById(option.ParentEl.id)
				self.CustomValues[option.Key] = option.DefaultValue
				option.CurrentValue = option.DefaultValue
				local savedValue = option.SavedValue
				option.SelectEl.selection = Utils.table.ifind(option.ValidValues, option.DefaultValue)
				option.SavedValue = savedValue
			end

			if option.Type == "Range" and option.CurrentValue ~= option.DefaultValue then
				local parent = self.Document:GetElementById(option.ParentEl.id)
				self.CustomValues[option.Key] = option.DefaultValue
				option.CurrentValue = option.DefaultValue
				local savedValue = option.SavedValue
				option.RangeEl.value = option.DefaultValue / option.MaxValue
				option.SavedValue = savedValue
			end

			if option.Type == "MultiPoint" and option.CurrentValue ~= option.DefaultValue then
				local parent = self.Document:GetElementById(option.ParentEl.id)
				--local value_el = self.Document:GetElementById(option.valueID.id)
				--ba.warning(option.CurrentValue .. " \ " .. option.defaultValue)
				self.CustomValues[option.Key] = option.DefaultValue
				option.CurrentValue = option.DefaultValue
				local savedValue = option.SavedValue
				--if value_el then
					local index = option.DefaultValue
					if option.Strings then
						if index > 5 then index = 5 end
						if index < 1 then index = 1 end
						parent.first_child.first_child.next_sibling.next_sibling.inner_rml = option.Strings[index]
					else
						--value_el.inner_rml = index
					end
					option.IncrementValue = (option.DefaultValue / #option.Buttons)
					self.CustomValues[option.Key] = option.DefaultValue
					self.CustomOptions[option.Key].CurrentValue = option.DefaultValue
				--end

				local last_active = option.DefaultValue

				for i, button in ipairs(option.Buttons) do
					button:SetPseudoClass("checked", i <= last_active)
				end
				option.SavedValue = savedValue
			end
		end
	end

	self.ModCustom = false
	local custombullet = self.Document:GetElementById("mod_custom_btn")
	local modbullet = self.Document:GetElementById("mod_default_btn")
	custombullet:SetPseudoClass("checked", false)
	modbullet:SetPseudoClass("checked", true)

end

function OptionsController:set_mod_detail_custom(element)

	if self.ModCustom == false then
		for k, _ in pairs(self.CustomOptions) do
			local option = self.CustomOptions[k]
			if not option.HasDefault then
				if option.Type == "Binary" and option.CurrentValue ~= option.SavedValue then
					local parent = self.Document:GetElementById(option.ParentEl.id)
					self.CustomValues[option.Key] = option.SavedValue
					option.CurrentValue = option.SavedValue
					local right_selected = option.SavedValue == option.ValidValues[2]
					parent.first_child.next_sibling.first_child.first_child:SetPseudoClass("checked", not right_selected)
					parent.first_child.next_sibling.first_child.next_sibling.first_child:SetPseudoClass("checked", right_selected)
				end

				if option.Type == "Multi" and option.CurrentValue ~= option.SavedValue then
					local parent = self.Document:GetElementById(option.ParentEl.id)
					self.CustomValues[option.Key] = option.DefaultValue
					option.CurrentValue = option.SavedValue
					option.SelectEl.selection = Utils.table.ifind(option.ValidValues, option.SavedValue)
				end

				if option.Type == "Range" and option.CurrentValue ~= option.SavedValue then
					local parent = self.Document:GetElementById(option.ParentEl.id)
					self.CustomValues[option.Key] = option.DefaultValue
					option.CurrentValue = option.SavedValue
					option.RangeEl.value = option.SavedValue / option.MaxValue
				end

				if option.Type == "MultiPoint" and option.CurrentValue ~= option.SavedValue then
					local parent = self.Document:GetElementById(option.ParentEl.id)
					--local value_el = self.Document:GetElementById(option.valueID.id)
					self.CustomValues[option.Key] = option.SavedValue
					option.CurrentValue = option.SavedValue
					local savedValue = option.SavedValue
					--if value_el then
						local index = option.SavedValue
						if option.Strings then
							if index > 5 then index = 5 end
							if index < 1 then index = 1 end
							parent.first_child.first_child.next_sibling.next_sibling.inner_rml = option.Strings[index]
						else
							--value_el.inner_rml = index
						end
						option.IncrementValue = (option.SavedValue / #option.Buttons)
						self.CustomValues[option.Key] = option.SavedValue
						self.CustomOptions[option.Key].CurrentValue = option.SavedValue
					--end

					local last_active = option.SavedValue --math.floor(option.range * option.numPoints) + 1

					for i, button in ipairs(option.Buttons) do
						button:SetPseudoClass("checked", i <= last_active)
					end
					option.SavedValue = savedValue
				end
			end
		end

		self.ModCustom = true
		local custombullet = self.Document:GetElementById("mod_custom_btn")
		local modbullet = self.Document:GetElementById("mod_default_btn")
		custombullet:SetPseudoClass("checked", true)
		modbullet:SetPseudoClass("checked", false)
	end

end

function OptionsController:isModDefault()
	for k, _ in pairs(self.CustomOptions) do
		local option = self.CustomOptions[k]
		if not option.HasDefault then
			if option.CurrentValue ~= option.DefaultValue then
				return false
			end
		end
	end
	return true
end

function OptionsController:setModDefaultStatus()
	local custombullet = self.Document:GetElementById("mod_custom_btn")
	local modbullet = self.Document:GetElementById("mod_default_btn")

	if self:isModDefault() == true then
		custombullet:SetPseudoClass("checked", false)
		modbullet:SetPseudoClass("checked", true)
		self.ModCustom = false
	else
		custombullet:SetPseudoClass("checked", true)
		modbullet:SetPseudoClass("checked", false)
		self.ModCustom = true
	end
end

function OptionsController:discardChanges()
    opt.discardChanges()

    for opt, value in pairs(self.OptionBackups) do
        opt.Value = value
        opt:persistChanges()
    end
end

function OptionsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        self:discardChanges()

		if mn.isInMission() then
			ScpuiSystem:pauseAllAudio(false)
		end

        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

function OptionsController:accept_clicked(element)
	self:acceptChanges("GS_EVENT_PREVIOUS_STATE")
end

function OptionsController:control_config_clicked()
    self:acceptChanges("GS_EVENT_CONTROL_CONFIG")
end

function OptionsController:hud_config_clicked()
    self:acceptChanges("GS_EVENT_HUD_CONFIG")
end

function OptionsController:exit_game_clicked()
    local builder = Dialogs.new()
    builder:text(ba.XSTR("Exit Game?", 888390))
    builder:button(Dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("No", 888298), false)
    builder:button(Dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Yes", 888296), true)
    builder:show(self.Document.context):continueWith(function(result)
        if not result then
            return
        end
        ba.postGameEvent(ba.GameEvents["GS_EVENT_QUIT_GAME"])
    end)
end

function OptionsController:unload()
	Topics.options.unload:send(self)
end

return OptionsController
