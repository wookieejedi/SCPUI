local utils = require("utils")
local tblUtil = utils.table

local dialogs = require("dialogs")

local class = require("class")

local PilotSelectController = require("pilotSelect")

local BarracksScreenController = class(PilotSelectController)

function BarracksScreenController:init()
    self.mode = PilotSelectController.MODE_BARRACKS
end

return BarracksScreenController
