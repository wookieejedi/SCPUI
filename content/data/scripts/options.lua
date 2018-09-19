local utils = require("utils")
local tblUtil = utils.table

local dialogs = require("dialogs")

local class = require("class")

local OptionsController = class()

function OptionsController:initialize(document)
    self.document = document
end

function OptionsController:global_keydown(element, event)
end

return OptionsController
