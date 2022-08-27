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

	ui.maybePlayCutscene(MOVIE_PRE_BRIEF, true, 0)
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
	
	local numStages = 0
	
    for i = 1, #briefing do
        --- @type briefing_stage
        local stage = briefing[i]
		if stage.isValid then
			self.stages[i] = stage
			numStages = numStages + 1
			--This is where we should replace variables and containers probably!
		end
    end
	if mn.hasGoalsSlide() then
		local g = numStages + 1
		self.stages[g] = {
			Text = ba.XSTR( "Please review your objectives for this mission.", 395)
		}
		numStages = numStages + 1
	end
	if #self.stages > 0 then
		self:go_to_stage(1)
	end
	
	self:buildGoals()
end

function BriefingController:buildGoals()
    if mn.hasGoalsSlide() then
		goals = ui.Briefing.Objectives
		local bulletHTML = "<div id=\"goalsdot_img\" class=\"goalsdot brightblue\"><img src=\"scroll-button.png\" class=\"psuedo_img\"></img></div>"
		local primaryWrapper = self.document:GetElementById("primary_goal_list")
		local primaryText = ""
		local secondaryWrapper = self.document:GetElementById("secondary_goal_list")
		local secondaryText = ""
		local bonusWrapper = self.document:GetElementById("bonus_goal_list")
		local bonusText = ""
		for i = 0, #goals do
			goal = goals[i]
			if goal.isValid and goal.Message ~= "" then
				if goal.Type == "primary" then
					local text = bulletHTML .. goal.Message .. "<br></br>"
					primaryText = primaryText .. text
				end
				if goal.Type == "secondary" then
					local text = bulletHTML .. goal.Message .. "<br></br>"
					secondaryText = secondaryText .. text
				end
				if goal.Type == "bonus" then
					local text = bulletHTML .. goal.Message .. "<br></br>"
					bonusText = bonusText .. text
				end
			end
		end
		primaryWrapper.inner_rml = primaryText
		secondaryWrapper.inner_rml = secondaryText
		bonusWrapper.inner_rml = bonusText
	end
end

function BriefingController:go_to_stage(stage_idx)
    self:leaveStage()

    local stage = self.stages[stage_idx]

	if mn.hasGoalsSlide() and stage_idx == #self.stages then
		self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
		self.document:GetElementById("briefing_goals"):SetClass("hidden", false)
	else
		self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
		self.document:GetElementById("briefing_goals"):SetClass("hidden", true)
	end
end

function BriefingController:acceptPressed()
    
	ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])

end

function BriefingController:skip_pressed()
    
	ui.Briefing.skipTraining()

end

return BriefingController
