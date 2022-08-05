local class = require("class")

local AbstractBriefingController = require("briefingCommon")

local BriefingController = class(AbstractBriefingController)

function BriefingController:init()
    --- @type briefing_stage[]
    self.stages = {}

    self.element_names = {
        pause_btn = "cmdpause_btn",
        last_btn = "cmdlast_btn",
        next_btn = "cmdnext_btn",
        prev_btn = "cmdprev_btn",
        first_btn = "cmdfirst_btn",
        text_el = "brief_text_el",
        stage_text_el = "brief_stage_text_el",
    }
end

function BriefingController:initialize(document)
    AbstractBriefingController.initialize(self, document)

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end

    local briefing = ui.Briefing.getBriefing()
    for i = 1, #briefing do
        --- @type briefing_stage
        local stage = briefing[i]

        self.stages[i] = stage
    end

    self:go_to_stage(1)
end

function BriefingController:go_to_stage(stage_idx)
    self:leaveStage()

    local stage = self.stages[stage_idx]

    self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
end

function BriefingController:acceptPressed()
    if mn.isRedAlertMission() then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_RED_ALERT"])
    else
        ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
    end
end

return BriefingController
