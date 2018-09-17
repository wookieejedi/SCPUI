local utils = require("utils")
local tblUtil = utils.table

local dialogs = require("dialogs")

local class = require("class")

local PilotSelectController = require("pilotSelect")

local BarracksScreenController = class(PilotSelectController)

function BarracksScreenController:init()
    self.mode = PilotSelectController.MODE_BARRACKS
end

function BarracksScreenController:initialize(document)
    self.pilotImages = ui.Barracks.listPilotImages()

    PilotSelectController.initialize(self, document)
end

function BarracksScreenController:changeImage(new_img)
    if new_img == nil then
        document:GetElementById("pilot_head_text_el").inner_rml = ""
        document:GetElementById("pilot_head_img_el"):SetAttribute("src", "")
        return
    end

    new_img = utils.strip_extension(new_img) -- The image may have an extension
    local index = tblUtil.ifind(self.pilotImages, new_img)

    local text_el = self.document:GetElementById("pilot_head_text_el")
    text_el.inner_rml = string.format("%d of %d", index, #self.pilotImages)

    self.document:GetElementById("pilot_head_img_el"):SetAttribute("src", new_img)
end

function BarracksScreenController:change_img_index(element, diff)
    if self.selection == nil or #self.pilotImages <= 0 then
        ui.playElementSound(element, "click", "error")
        return
    end

    local current_img = utils.strip_extension(self.selectedPilot.ImageFilename) -- The image may have an extension
    local index = tblUtil.ifind(self.pilotImages, current_img)

    index = index + diff
    if index > #self.pilotImages then
        index = 1
    elseif index < 1 then
        index = #self.pilotImages
    end

    self.selectedPilot.ImageFilename = self.pilotImages[index]
    self:changeImage(self.pilotImages[index])

    ui.playElementSound(element, "click", "success")
end

function BarracksScreenController:next_image_pressed(element)
    self:change_img_index(element, 1)
end

function BarracksScreenController:prev_image_pressed(element)
    self:change_img_index(element, -1)
end

function BarracksScreenController:add_heading_element(parent, text)
    local container = self.document:CreateElement("div")
    local text_el = self.document:CreateTextNode(text)

    container:AppendChild(text_el)
    container:SetClass("stats_heading", true)

    parent:AppendChild(container)
end

function BarracksScreenController:add_value_element(parent, text, value)
    local text_container = self.document:CreateElement("div")
    local text_el = self.document:CreateTextNode(text)
    text_container:AppendChild(text_el)
    text_container:SetClass("stats_value_label", true)

    local value_container = self.document:CreateElement("div")
    local value_el = self.document:CreateTextNode(tostring(value))
    value_container:AppendChild(value_el)
    value_container:SetClass("stats_value_text", true)

    parent:AppendChild(text_container)
    parent:AppendChild(value_container)
end

function BarracksScreenController:add_empty_line(parent)
    local text_container = self.document:CreateElement("div")
    text_container:SetClass("stats_empty_line", true)

    parent:AppendChild(text_container)
end

local function compute_percentage(fract, total)
    if total <= 0 then
        return "0%"
    end

    return tostring((fract / total) * 100) .. "%"
end

function BarracksScreenController:initialize_stats_text()
    local text_container = self.document:GetElementById("pilot_stats_text")

    if self.selectedPilot == nil then
        text_container.inner_rml = ""
        return
    end

    local stats = self.selectedPilot.Stats

    self:add_heading_element(text_container, "All Time Stats")
    self:add_value_element(text_container, "Primary weapon shots:", stats.PrimaryShotsFired)
    self:add_value_element(text_container, "Primary weapon hits:", stats.PrimaryShotsHit)
    self:add_value_element(text_container, "Primary friendly hits:", stats.PrimaryFriendlyHit)
    self:add_value_element(text_container, "Primary hit %:", compute_percentage(stats.PrimaryShotsHit, stats.PrimaryShotsFired))
    self:add_value_element(text_container, "Primary friendly hit %:", compute_percentage(stats.PrimaryFriendlyHit, stats.PrimaryShotsFired))
    self:add_empty_line(text_container)

    self:add_value_element(text_container, "Secondary weapon shots:", stats.SecondaryShotsFired)
    self:add_value_element(text_container, "Secondary weapon hits:", stats.SecondaryShotsHit)
    self:add_value_element(text_container, "Secondary friendly hits:", stats.SecondaryFriendlyHit)
    self:add_value_element(text_container, "Secondary hit %:", compute_percentage(stats.SecondaryShotsHit, stats.SecondaryShotsFired))
    self:add_value_element(text_container, "Secondary friendly hit %:", compute_percentage(stats.SecondaryFriendlyHit, stats.SecondaryShotsFired))
    self:add_empty_line(text_container)

    self:add_value_element(text_container, "Total kills:", stats.TotalKills)
    self:add_value_element(text_container, "Assists:", stats.Assists)
    self:add_empty_line(text_container)

    self:add_value_element(text_container, "Current Score:", stats.Score)
    self:add_empty_line(text_container)
    self:add_empty_line(text_container)

    self:add_heading_element(text_container, "Kills by Ship Type")
    local score_from_kills = 0
    for i=1,#tb.ShipClasses do
        local ship_cls = tb.ShipClasses[i]
        local kills = stats:getShipclassKills(ship_cls)

        if kills > 0 then
            score_from_kills = score_from_kills + kills * ship_cls.Score
            self:add_value_element(text_container, ship_cls.Name .. ":", kills)
        end
    end
    self:add_value_element(text_container, "Score from kills only:", score_from_kills)
end

function BarracksScreenController:pilotSelected(pilot)
    if self.selectedPilot ~= nil then
        self.selectedPilot:loadCampaignSavefile()
    end

    if pilot == nil then
        self:changeImage(nil)
    else
        self:changeImage(self.selectedPilot.ImageFilename)
    end

    self:initialize_stats_text()
end

function BarracksScreenController:getInitialCallsign()
    return ba.getCurrentPlayer():getName()
end

function BarracksScreenController:commit_pressed(element)
    if self.selection == nil then
        ui.playElementSound(element, "click", "error")
        return
    end

    if not ui.PilotSelect.checkPilotLanguage(self.selection) then
        ui.playElementSound(element, "click", "error")

        self:showWrongPilotLanguageDialog()
        return
    end

    ui.playElementSound(element, "click", "commit")
    ui.Barracks.acceptPilot(self.selectedPilot)
end

function BarracksScreenController:medals_button_clicked(element)
    if self.selectedPilot ~= nil then
        ba.savePlayer(self.selectedPilot) -- Save the player in case there were changes
    end
    ba.postGameEvent(ba.GameEvents['GS_EVENT_VIEW_MEDALS'])
end

return BarracksScreenController
