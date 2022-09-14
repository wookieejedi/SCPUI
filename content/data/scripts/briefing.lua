local class = require("class")
local async_util = require("async_util")

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
	
	--Default width is 888, default height is 371
	
	briefView = self.document:GetElementById("briefing_grid")
						
	local viewLeft = briefView.offset_left + briefView.parent_node.offset_left + briefView.parent_node.parent_node.offset_left
	local viewTop = briefView.offset_top + briefView.parent_node.offset_top + briefView.parent_node.parent_node.offset_top
	
	--The grid needs to be a very specific aspect ratio, so we'll calculate
	--the percent change here and use that to calculate the height below.
	local percentChange = ((briefView.offset_width - 888) / 888) * 100
	
	local x1 = viewLeft
	local y1 = viewTop
	local x2 = briefView.offset_width
	local y2 = self:calcPercent(371, (100 + percentChange))

	ui.Briefing.startBriefingMap(x1, y1, x2, y2)
	
	if mn.hasNoBriefing() then
		ui.Briefing.commitToMission()
	end
		

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
		if stage.isVisible then
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
	
	if mn.isInCampaign() then
		if mn.isTraining() then
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Skip Training", -1)
			self.document:GetElementById("top_panel_a"):SetClass("hidden", false)
		elseif mn.isInCampaignLoop() then
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Exit Loop", -1)
			self.document:GetElementById("top_panel_a"):SetClass("hidden", false)
		elseif mn.isMissionSkipAllowed() then
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Skip Mission", -1)
			self.document:GetElementById("top_panel_a"):SetClass("hidden", false)
		else
			self.document:GetElementById("top_panel_a"):SetClass("hidden", true)
		end
	else
		self.document:GetElementById("top_panel_a"):SetClass("hidden", true)
	end
	
	if ba.inDebug() then
		local missionFile = mn.getMissionFilename() .. ".fs2"
		local missionDate = mn.getMissionModifiedDate()
		self.document:GetElementById("mission_debug_info").inner_rml = missionFile .. " mod " .. missionDate
	end
	
	self.document:GetElementById("brief_btn"):SetPseudoClass("checked", true)
	
	self:buildGoals()
	
	drawMap = true
end

function BriefingController:calcPercent(value, percent)
    if value == nil or percent == nil then  
		return false;
	end
    return value * (percent/100)
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
			if goal.isGoalValid and goal.Message ~= "" then
				if goal.Type == "primary" then
					local text = "<div class=\"goal\">" .. bulletHTML .. goal.Message .. "<br></br></div>"
					primaryText = primaryText .. text
				end
				if goal.Type == "secondary" then
					local text = bulletHTML .. goal.Message .. "<br></br></div>"
					secondaryText = "<div class=\"goal\">" .. secondaryText .. text
				end
				if goal.Type == "bonus" then
					local text = bulletHTML .. goal.Message .. "<br></br></div>"
					bonusText = "<div class=\"goal\">" .. bonusText .. text
				end
			end
		end
		primaryWrapper.inner_rml = primaryText
		secondaryWrapper.inner_rml = secondaryText
		bonusWrapper.inner_rml = bonusText
	end
end

function BriefingController:ChangeBriefState(state)
	if state == 1 then
		--Do nothing because we're this is the current state!
		--ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	elseif state == 2 then
		if mn.isScramble() then
			ad.playInterfaceSound(10)
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_SHIP_SELECTION"])
		end
	elseif state == 3 then
		if mn.isScramble() then
			ad.playInterfaceSound(10)
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_WEAPON_SELECTION"])
		end
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

function BriefingController:CutToStage()
	ad.playInterfaceSound(42)
	drawMap = false
	self.aniWrapper = self.document:GetElementById("brief_grid_cut")
	ad.playInterfaceSound(42)
    local aniEl = self.document:CreateElement("ani")
    aniEl:SetAttribute("src", "static.png")
	self.aniWrapper:ReplaceChild(aniEl, self.aniWrapper.first_child)
	
	async.run(function()
        async.await(async_util.wait_for(0.7))
        drawMap = true
		self.aniWrapper:RemoveChild(self.aniWrapper.first_child)
    end, async.OnFrameExecutor, self.uiActiveContext)
end

function BriefingController:acceptPressed()
    
	drawMap = nil
	--ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
	ui.Briefing.commitToMission()

end

function BriefingController:skip_pressed()
    
	if mn.isTraining() then
		ui.Briefing.skipTraining()
	elseif mn.isInCampaignLoop() then
		ui.Briefing.exitLoop()
	elseif mn.isMissionSkipAllowed() then
		ui.Briefing.skipMission()
	end

end

return BriefingController
