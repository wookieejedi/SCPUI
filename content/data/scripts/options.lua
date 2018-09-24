local utils = require("utils")
local tblUtil = utils.table

local dialogs = require("dialogs")

local class = require("class")

local function getFormatterName(key)
    return key:gsub("%.", "_")
end

local DataSourceWrapper = class()

function DataSourceWrapper:init(option)
    self.option = option

    local source = DataSource.new(getFormatterName(option.Key))

    self.values = option:getValidValues()
    source.GetNumRows = function()
        return #self.values
    end
    source.GetRow = function(_, i, columns)
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

    self.source = source
end

function DataSourceWrapper:updateValues()
    ba.print("Updating values...")
    self.values = self.option:getValidValues()
    self.source:NotifyRowChange("Default")
end

local function createOptionSource(option)
    return DataSourceWrapper(option)
end

local OptionsController = class()

function OptionsController:init()
    self.sources = {}
    self.options = {}
    self.keyed_options = {}
end

function OptionsController:initialize(document)
    self.document = document

    -- Persist current changes since we might discard them in this screen
    opt.persistChanges()

    self.options = opt.Options
    for _, v in ipairs(self.options) do
        if v.Type == OPTION_TYPE_RANGE then
            local min, max = v:getNumberRange()
            ba.print(string.format("%q: [%d,%d]\n", v.Title, min, max))
        else
            ba.print(string.format("%q\n", v.Title))
            for _, v in ipairs(v:getValidValues()) do
                ba.print(string.format("\t%q\n", tostring(v)))
            end
        end

        if v.Type == OPTION_TYPE_SELECTION then
            self.sources[v.Key] = createOptionSource(v)
        end

        -- Also make the options available via their key
        self.keyed_options[v.Key] = v
    end

    self:init_selection_element(self.document:GetElementById("resolution_data_select"), "Graphics.Resolution")
    self:init_selection_element(self.document:GetElementById("display_data_select"), "Graphics.Display", function(_)
        self.sources["Graphics.Resolution"]:updateValues()
    end)
end

function OptionsController:init_selection_element(element, option_key, change_func)
    local select_el = Element.As.ElementFormControlDataSelect(element)
    select_el:SetDataSource(getFormatterName(option_key) .. ".Default")

    local option = self.keyed_options[option_key]

    local vals = option:getValidValues()
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

function OptionsController:accept_clicked(element)
    opt.persistChanges()
    ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
end

function OptionsController:global_keydown(element, event)
end

return OptionsController
