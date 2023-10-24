local class = require("class")
local utils = require("utils")
local topics = require("ui_topics")

local AbstractBriefingController = require("briefingCommon")

local CommandBriefingController = class(AbstractBriefingController)

function CommandBriefingController:init()
	ScpuiSystem:maybePlayCutscene(MOVIE_PRE_CMD_BRIEF)
    --- @type cmd_briefing_stage[]
    self.stages = {}

    self.element_names = {
        pause_btn = "cmdpause_btn",
        last_btn = "cmdlast_btn",
        next_btn = "cmdnext_btn",
        prev_btn = "cmdprev_btn",
        first_btn = "cmdfirst_btn",
        text_el = "cmd_text_el",
        stage_text_el = "cmd_stage_text_el",
    }
	self.help_shown = false
end

function CommandBriefingController:initialize(document)
    AbstractBriefingController.initialize(self, document)
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	self.document:GetElementById("cmd_text"):SetClass(("p2-" .. ScpuiSystem:getFontSize()), true)

    local briefing = ui.CommandBriefing.getCmdBriefing()
	
    for i = 1, #briefing do
		local stage = briefing[i]

		self.stages[i] = topics.cmdbriefing.stage:send({stage, i})
    end

    self:go_to_stage(1)
end

function CommandBriefingController:acceptPressed()
    if mn.isRedAlertMission() then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_RED_ALERT"])
    else
        ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
    end
end

function CommandBriefingController:go_to_stage(stage_idx)
    local old_stage = self.current_stage or 0
    self:leaveStage()

    local stage = self.stages[stage_idx]

    self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)

    local aniWrapper = self.document:GetElementById("cmd_anim")
    if #stage.AniFilename > 0 then
        local aniEl = self.document:CreateElement("ani")

		if utils.animExists(stage.AniFilename) then
			aniEl:SetAttribute("src", stage.AniFilename)
		end

        aniWrapper:ReplaceChild(aniEl, aniWrapper.first_child)
    else
        aniWrapper:RemoveChild(aniWrapper.first_child)
    end

    ui.Briefing.runBriefingStageHook(old_stage, stage_idx)
end

function CommandBriefingController:help_clicked()
    self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

return CommandBriefingController
