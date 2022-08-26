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
	
	ui.Briefing.startBriefingMap()
	--ba.warning(mn.getMissionModifiedDate())
	--ba.warning(mn.getMissionFilename() .. ".fs2")

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	self.document:GetElementById("mission_title").inner_rml = mn.getMissionTitle()

    local briefing = ui.Briefing.getBriefing()
    for i = 1, #briefing do
        --- @type briefing_stage
        local stage = briefing[i]

        self.stages[i] = stage
    end
	if #briefing > 0 then
		self:go_to_stage(1)
	end
end

function BriefingController:go_to_stage(stage_idx)
    self:leaveStage()

    local stage = self.stages[stage_idx]

    self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
end

function BriefingController:acceptPressed()
    
	ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])

end

function BriefingController:skip_pressed()
    
	ui.Briefing.skipTraining()

end

return BriefingController
