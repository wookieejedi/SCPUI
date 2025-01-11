-----------------------------------
--This script is a helper for the options system, providing wrapper class for Data Source options
-----------------------------------

local Class = require("lib_class")

local DataSourceWrapper = Class()

--- Initialize the data source wrapper
--- @param option scpui_custom_option
--- @return nil
function DataSourceWrapper:init(option)
    self.Option = nil --- @type scpui_custom_option | nil The option itself
    self.Values = nil --- @type any[] The values of a custom option only
    self.Source = nil --- @type DataSource The data source

	if option.Category ~= "Custom" then
		self.Option = option
	end

    ---@type DataSource
    local source = DataSource.new(option.Key:gsub("%.", "_"))

	if option.Category ~= "Custom" then
		self.Values   = option:getValidValues()
	else
		if string.lower(option.Type) == "binary" then
			--binary options don't need translation here
			self.Values = option.ValidValues
		elseif string.lower(option.Type) == "multi" then
			--multi selector options get translated
			self.Values = {}

			for i = 1, #option.ValidValues do
				local thisVal = option.DisplayNames[option.ValidValues[i]]
				table.insert(self.Values, thisVal)
			end
		else
			ba.error("Houston, how did we get here?! Get Mjn STAT!")
		end
	end

	if option.Category ~= "Custom" then
		source.GetNumRows = function()
			return #self.Values
		end
        ---@param _ any
        ---@param i integer
        ---@param columns string[]
		source.GetRow = function(_, i, columns)
			local val = self.Values[i]
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
	else
		source.GetNumRows = function()
			return #self.Values
		end
        ---@param _ any
        ---@param i integer
        ---@param columns string[]
		source.GetRow = function(_, i, columns)
			local val = self.Values[i]
			local out = {}
			for j, _ in ipairs(columns) do
				out[j] = val
			end
			return out
		end
	end

    self.Source = source

end

--- Update the values of the data source
function DataSourceWrapper:updateValues()
    self.Values = self.Option:getValidValues()
    self.Source:NotifyRowChange("Default")
end

return DataSourceWrapper