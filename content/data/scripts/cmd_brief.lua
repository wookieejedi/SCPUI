local utils = require("utils")
local tblUtil = utils.table
local dialogs = require("dialogs")
local class = require("class")

local function brief_text_to_rml(brief_text)
    local lines = utils.split(brief_text, "\n\n")

    local paragraphs = tblUtil.map(lines, function(line)
        return "<p>" .. utils.rml_escape(line) .. "</p>"
    end)

    return table.concat(paragraphs, "<br></br>")
end

local CommandBriefingController = class()

function CommandBriefingController:init()
end

function CommandBriefingController:initialize(document)
    self.document = document

    --- @type cmd_briefing_stage[]
    self.stages = {}

    local briefing = ui.CommandBriefing.getBriefing()
    for i = 1, #briefing do
        --- @type cmd_briefing_stage
        local stage = briefing[i]

        self.stages[i] = stage
    end

    self:registerEventHandlers()

    -- Go to the first stage
    self:go_to_stage(1)
end

function CommandBriefingController:registerEventHandlers()
    self.document:GetElementById("cmdlast_btn"):AddEventListener("click", function(_, _, _)
        self:go_to_stage(#self.stages)
    end)
    self.document:GetElementById("cmdnext_btn"):AddEventListener("click", function(_, _, _)
        if self.current_stage >= #self.stages then
            -- TODO play error sound
            return
        end

        self:go_to_stage(self.current_stage + 1)
    end)
    self.document:GetElementById("cmdprev_btn"):AddEventListener("click", function(_, _, _)
        if self.current_stage <= 1 then
            -- TODO play error sound
            return
        end

        self:go_to_stage(self.current_stage - 1)
    end)
    self.document:GetElementById("cmdfirst_btn"):AddEventListener("click", function(_, _, _)
        self:go_to_stage(1)
    end)
end

function CommandBriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
    end
end

function CommandBriefingController:go_to_stage(stage_idx)
    self.current_stage = stage_idx

    local stage = self.stages[stage_idx]

    local text_el = self.document:GetElementById("cmd_text")
    text_el.inner_rml = brief_text_to_rml(stage.Text)

    local stage_indicator_el = self.document:GetElementById("cmd_stage_text_el")
    stage_indicator_el.inner_rml = string.format(ba.XSTR("Stage %d of %d", -1), self.current_stage, #self.stages)

    local aniWrapper = self.document:GetElementById("cmd_anim")
    if #stage.AniFilename > 0 then
        local aniEl = self.document:CreateElement("ani")
        aniEl:SetAttribute("src", stage.AniFilename)

        aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
    else
        aniWrapper:RemoveChild(aniWrapper.first_child)
    end
end

return CommandBriefingController
