local dialogs = require("dialogs")
local class = require("class")
local topics = require("ui_topics")
local async_util = require("async_util")
local loadoutHandler = require("loadouthandler")

local AbstractBriefingController = require("briefingCommon")

local BriefingController = class(AbstractBriefingController)

ScpuiSystem.drawBrMap = nil

function BriefingController:init()
	if not ScpuiSystem.cutscenePlayed then
		ScpuiSystem:maybePlayCutscene(MOVIE_PRE_BRIEF)
	end
	
	ScpuiSystem.cutscenePlayed = true
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
	
	loadoutHandler:init()
	
	--Whenever we start a new mission, we reset the log ui to goals
	ScpuiSystem.logSection = 1
	
	self.help_shown = false
	
end

function BriefingController:initialize(document)
    AbstractBriefingController.initialize(self, document)
	
	self.Commit = false
	self.requiredWeps = {}
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	ui.Briefing.initBriefing()
	
	if mn.hasNoBriefing() then
		self.Commit = true
		ScpuiSystem:stopMusic()
		ScpuiSystem.current_played = nil
		ui.Briefing.commitToMission()
	end
	
	if mn.isScramble() or mn.isTraining() then
		local ss_btn = self.document:GetElementById("s_select_btn")
		local ws_btn = self.document:GetElementById("w_select_btn")
		
		ss_btn:SetClass("hidden", true)
		ws_btn:SetClass("hidden", true)
		
		local text_el = self.document:CreateElement("div")
		text_el.style.width = "10%"
		text_el.style.position = "absolute"
		text_el.style.color = "#606060"
		text_el.style.top = "8%"
		text_el.style.left = "5%"
		text_el.inner_rml = ba.XSTR("Loadout selection not available", 888279)
		self.document:GetElementById("main_background"):AppendChild(text_el)
	end
		

	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
	
	--Get all the required weapons
	local j = 1
	while (j < #tb.WeaponClasses) do
		if tb.WeaponClasses[j]:isWeaponRequired() then
			self.requiredWeps[#self.requiredWeps + 1] = tb.WeaponClasses[j].Name
		end
		j = j + 1
	end
	
	self.document:GetElementById("mission_title").inner_rml = mn.getMissionTitle()

    local briefing = ui.Briefing.getBriefing()
	
	local numStages = 0
	
    for i = 1, #briefing do
        --- @type briefing_stage
        local stage = briefing[i]
		if stage then
			self.stages[i] = stage
			numStages = numStages + 1
			--This is where we should replace variables and containers probably!
		end
    end
	if mn.hasGoalsStage() then
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
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Skip Training", 888280)
			self.document:GetElementById("top_panel_a"):SetClass("hidden", false)
		elseif mn.isInCampaignLoop() then
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Exit Loop", 888281)
			self.document:GetElementById("top_panel_a"):SetClass("hidden", false)
		elseif mn.isMissionSkipAllowed() then
			self.document:GetElementById("skip_m_text").inner_rml = ba.XSTR("Skip Mission", 888282)
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
	
	--Default width is 888, default height is 371
	
	local briefView = self.document:GetElementById("briefing_grid")
	
	--The grid needs to be a very specific aspect ratio, so we'll calculate
	--the percent change here and use that to calculate the height below.
	local percentChange = ((briefView.offset_width - 888) / 888) * 100
	
	ScpuiSystem.drawBrMap.x1 = ScpuiSystem:getAbsoluteLeft(briefView)
	ScpuiSystem.drawBrMap.y1 = ScpuiSystem:getAbsoluteTop(briefView)
	ScpuiSystem.drawBrMap.x2 = briefView.offset_width
	ScpuiSystem.drawBrMap.y2 = self:calcPercent(371, (100 + percentChange))
	
	self:buildGoals()
	
	ScpuiSystem.drawBrMap.tex = gr.createTexture(ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
	ScpuiSystem.drawBrMap.url = ui.linkTexture(ScpuiSystem.drawBrMap.tex)
	ScpuiSystem.drawBrMap.draw = true
	local aniEl = self.document:CreateElement("img")
    aniEl:SetAttribute("src", ScpuiSystem.drawBrMap.url)
	briefView:ReplaceChild(aniEl, briefView.first_child)
	
	if ScpuiSystem:inMultiGame() then
		ui.MainHall.stopMusic(true) -- In multi we're coming from the Multi Sync UI so we need to stop these manually
		ui.MainHall.stopAmbientSound()
		self.document:GetElementById("chat_wrapper"):SetClass("hidden", false)
		--self.document:GetElementById("c_panel_wrapper_multi"):SetClass("hidden", false)
		self.document:GetElementById("bottom_panel_c"):SetClass("hidden", false)
		self:updateLists()
		ui.MultiGeneral.setPlayerState()
	end
	
	topics.briefing.initialize:send(self)

end

function BriefingController:calcPercent(value, percent)
    if value == nil or percent == nil then  
		return false;
	end
    return value * (percent/100)
end

function BriefingController:makeBullet()
	local bullet_el = self.document:CreateElement("div")
	bullet_el.id = "goalsdot_img"
	bullet_el:SetClass("goalsdot", true)
	bullet_el:SetClass("brightblue", true)
	
	local bullet_img = self.document:CreateElement("img")
	bullet_img:SetClass("psuedo_img", true)
	bullet_img:SetAttribute("src", "scroll-button.png")
	bullet_el:AppendChild(bullet_img)
	
	return bullet_el
end

function BriefingController:createGoalItem(title)
	local goal_el = self.document:CreateElement("li")
	goal_el:SetClass("goal", true)
	goal_el:AppendChild(self:makeBullet())
	
	local goal_text = self.document:CreateElement("div")
	goal_text.inner_rml = goal.Message .. "<br></br>"
	goal_el:AppendChild(goal_text)
	
	return goal_el
end

function BriefingController:buildGoals()
    if mn.hasGoalsStage() then
		local goals = ui.Briefing.Objectives
		local primaryList = self.document:GetElementById("primary_goal_list")
		local secondaryList = self.document:GetElementById("secondary_goal_list")
		local bonusList = self.document:GetElementById("bonus_goal_list")
		for i = 1, #goals do
			local goal = goals[i]
			if goal.isGoalValid and goal.Message ~= "" then
				if goal.Type == "primary" then
					primaryList:AppendChild(self:createGoalItem(goal.Message))
				end
				if goal.Type == "secondary" then
					secondaryList:AppendChild(self:createGoalItem(goal.Message))
				end
				if goal.Type == "bonus" then
					bonusList:AppendChild(self:createGoalItem(goal.Message))
				end
			end
		end
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
	local old_stage = self.current_stage or 0
    self:leaveStage()
	
	if ScpuiSystem.drawBrMap == nil then
		ScpuiSystem.drawBrMap = {
			tex = nil,
			modelRot = 40
		}
	end

    local stage = self.stages[stage_idx]
	
	ScpuiSystem.drawBrMap.bg = ScpuiSystem:getBriefingBackground(mn.getMissionFilename(), tostring(stage_idx))

	local brief_img = topics.briefing.brief_bg:send((mn.hasGoalsStage() and stage_idx == #self.stages))

	if mn.hasGoalsStage() and stage_idx == #self.stages then
		self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
		self.document:GetElementById("briefing_goals"):SetClass("hidden", false)
		ScpuiSystem.drawBrMap.goals = true
	else
		self:initializeStage(stage_idx, stage.Text, stage.AudioFilename)
		self.document:GetElementById("briefing_goals"):SetClass("hidden", true)
		ScpuiSystem.drawBrMap.goals = false
	end
	
	local brief_bg_src = self.document:CreateElement("img")
	brief_bg_src:SetAttribute("src", brief_img)
	local brief_bg_el = self.document:GetElementById("brief_grid_window")
	brief_bg_el:ReplaceChild(brief_bg_src, brief_bg_el.last_child)
	
	ui.Briefing.runBriefingStageHook(old_stage, stage_idx)
end

function BriefingController:CutToStage()
	ad.playInterfaceSound(42)
	ScpuiSystem.drawBrMap.draw = false
	self.aniWrapper = self.document:GetElementById("brief_grid_cut")
	ad.playInterfaceSound(42)
    local aniEl = self.document:CreateElement("ani")
    aniEl:SetAttribute("src", "static.png")
	self.aniWrapper:ReplaceChild(aniEl, self.aniWrapper.first_child)
	
	async.run(function()
        async.await(async_util.wait_for(0.7))
        ScpuiSystem.drawBrMap.draw = true
		self.aniWrapper:RemoveChild(self.aniWrapper.first_child)
    end, async.OnFrameExecutor, self.uiActiveContext)
end

function BriefingController:drawMap()

	if ScpuiSystem.drawBrMap == nil then
		return
	end
	
	--Testing icon ship rendering stuff
	ScpuiSystem.drawBrMap.modelRot = ScpuiSystem.drawBrMap.modelRot + (7 * ba.getRealFrametime())

	if ScpuiSystem.drawBrMap.modelRot >= 100 then
		ScpuiSystem.drawBrMap.modelRot = ScpuiSystem.drawBrMap.modelRot - 100
	end

	gr.setTarget(ScpuiSystem.drawBrMap.tex)
	
	local r = 160
	local g = 144
	local b = 160
	local a = 255
	gr.setLineWidth(2)
	
	if ScpuiSystem.drawBrMap.draw == true then
		if ScpuiOptionValues.Brief_Render_Option == nil then
			ScpuiOptionValues.Brief_Render_Option = "screen"
		end
		if string.lower(ScpuiOptionValues.Brief_Render_Option) == "texture" then
			gr.setTarget(ScpuiSystem.drawBrMap.tex)
			gr.clearScreen(0,0,0,0)
			if not ScpuiSystem.drawBrMap.goals then
				gr.drawImage(ScpuiSystem.drawBrMap.bg, 0, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
			end
			ui.Briefing.drawBriefingMap(0, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
			
			if not ScpuiSystem.drawBrMap.goals then
				gr.setColor(r, g, b, a)
				gr.drawLine(0, 0, 0, ScpuiSystem.drawBrMap.y2)
				gr.drawLine(0, 0, ScpuiSystem.drawBrMap.x2, 0)
				gr.drawLine(ScpuiSystem.drawBrMap.x2, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
				gr.drawLine(0, ScpuiSystem.drawBrMap.y2, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
			end
			
		elseif string.lower(ScpuiOptionValues.Brief_Render_Option) == "screen" then
			gr.clearScreen(0,0,0,0)
			if not ScpuiSystem.drawBrMap.goals then
				gr.drawImage(ScpuiSystem.drawBrMap.bg, 0, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
				
				gr.setColor(r, g, b, a)
				gr.drawLine(0, 0, 0, ScpuiSystem.drawBrMap.y2)
				gr.drawLine(0, 0, ScpuiSystem.drawBrMap.x2, 0)
				gr.drawLine(ScpuiSystem.drawBrMap.x2, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
				gr.drawLine(0, ScpuiSystem.drawBrMap.y2, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
			end
			gr.setTarget()
			ui.Briefing.drawBriefingMap(ScpuiSystem.drawBrMap.x1, ScpuiSystem.drawBrMap.y1, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
			
		end
		
	else
		gr.clearScreen(0,0,0,0)
		
		gr.setColor(r, g, b, a)
		gr.drawLine(0, 0, 0, ScpuiSystem.drawBrMap.y2)
		gr.drawLine(0, 0, ScpuiSystem.drawBrMap.x2, 0)
		gr.drawLine(ScpuiSystem.drawBrMap.x2, 0, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
		gr.drawLine(0, ScpuiSystem.drawBrMap.y2, ScpuiSystem.drawBrMap.x2, ScpuiSystem.drawBrMap.y2)
	end
	
	gr.setTarget()
	
	if ScpuiSystem.drawBrMap.pof ~= nil then
		
		--get the current color and save it
		local prev_c = {
			r = 0,
			g = 0,
			b = 0,
			a = 0
		}
		
		prev_c.r, prev_c.g, prev_c.b, prev_c.a = gr.getColor()
		
		--set the box coords and size
		local bx_size = math.floor(0.20 * gr.getScreenHeight()) --size of the box is 15% of screen height
		local bx_dist = 5 --this is the distance the box is drawn from the mouse in pixels
		local bx1 = ScpuiSystem.drawBrMap.bx - bx_size - bx_dist
		local by1 = ScpuiSystem.drawBrMap.by - bx_size - bx_dist
		local bx2 = ScpuiSystem.drawBrMap.bx - bx_dist
		local by2 = ScpuiSystem.drawBrMap.by - bx_dist
		
		--set the current color to black
		gr.setColor(0, 0, 0, 255)
		
		--draw a box at the mouse coords
		gr.drawRectangle(bx1, by1, bx2, by2)
		
		--set the current color to grey
		gr.setColor(50, 50, 50, 255)
		gr.drawLine(bx1, by1, bx1, by2)
		gr.drawLine(bx1, by1, bx2, by1)
		gr.drawLine(bx2, by2, bx1, by2)
		gr.drawLine(bx2, by2, bx2, by1)
		
		local ship = tb.ShipClasses[ScpuiSystem.drawBrMap.pof]
		if ship.Name == "" then
			local jumpnode = false
			if ScpuiSystem.drawBrMap.pof == "subspacenode.pof" then
				jumpnode = true
			end
			ui.Briefing.renderBriefingModel(ScpuiSystem.drawBrMap.pof, ScpuiSystem.drawBrMap.closeupZoom, ScpuiSystem.drawBrMap.closeupPos, bx1+1, by1+1, bx2-1, by2-1, ScpuiSystem.drawBrMap.modelRot, -15, 0, 1.1, true, jumpnode)
		else
			ship:renderTechModel(bx1+1, by1+1, bx2-1, by2-1, ScpuiSystem.drawBrMap.modelRot, -15, 0, 1.1)
		end
		
		--set the current color to light grey
		gr.setColor(150, 150, 150, 255)
		
		gr.drawString(ScpuiSystem.drawBrMap.label, bx1+1, by1+1, bx2-1, by2-1)
		
		--reset the color
		gr.setColor(prev_c.r, prev_c.g, prev_c.b, prev_c.a)
		gr.setLineWidth(1)
	end

end

function BriefingController:Show(text, title, buttons)
	--Create a simple dialog box with the text and title

	currentDialog = true
	ScpuiSystem.drawBrMap.draw = false
	
	local dialog = dialogs.new()
		dialog:title(title)
		dialog:text(text)
		for i = 1, #buttons do
			dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value, buttons[i].b_keypress)
		end
		dialog:escape("")
		dialog:show(self.document.context)
		:continueWith(function(response)
			ScpuiSystem.drawBrMap.draw = true
    end)
	-- Route input to our context until the user dismisses the dialog box.
	ui.enableInput(self.document.context)
end

function BriefingController:acceptPressed()

	if not topics.mission.commit:send(self) then
		return
	end

	--Apply the loadout
	loadoutHandler:SendAllToFSO_API()
    
	local errorValue = ui.Briefing.commitToMission(true)
	
	if errorValue == COMMIT_SUCCESS then
		--Save to the player file
		self.Commit = true
		loadoutHandler:SaveInFSO_API()
		--Cleanup
		if ScpuiSystem.drawBrMap then
			ScpuiSystem.drawBrMap.tex:unload()
			ScpuiSystem.drawBrMap.tex = nil
			ScpuiSystem.drawBrMap = nil
		end
		ScpuiSystem:stopMusic()
		ScpuiSystem.current_played = nil
		ScpuiSystem.cutscenePlayed = nil
	end

end

function BriefingController:skip_pressed()

	ScpuiSystem:stopMusic()
	
	loadoutHandler:unloadAll(false)
	ScpuiSystem.cutscenePlayed = nil
    
	if mn.isTraining() then
		ui.Briefing.skipMission()
	elseif mn.isInCampaignLoop() then
		ui.Briefing.exitLoop()
	elseif mn.isMissionSkipAllowed() then
		ui.Briefing.skipMission()
	end

end

function BriefingController:mouse_move(element, event)

	if ScpuiSystem.drawBrMap ~= nil then
		ScpuiSystem.drawBrMap.mx = event.parameters.mouse_x
		ScpuiSystem.drawBrMap.my = event.parameters.mouse_y
		
		--for the ship box preview coords regardless of briefing render type
		ScpuiSystem.drawBrMap.bx = event.parameters.mouse_x
		ScpuiSystem.drawBrMap.by = event.parameters.mouse_y
		
		--Get the grid coords
		local grid_el = self.document:GetElementById("briefing_grid")
		local gx = grid_el.offset_left + grid_el.parent_node.offset_left + grid_el.parent_node.parent_node.offset_left
		local gy = grid_el.offset_top + grid_el.parent_node.offset_top + grid_el.parent_node.parent_node.offset_top
			
		if string.lower(ScpuiOptionValues.Brief_Render_Option) == "texture" then
			
			ScpuiSystem.drawBrMap.mx = ScpuiSystem.drawBrMap.mx - gx
			ScpuiSystem.drawBrMap.my = ScpuiSystem.drawBrMap.my - gy

		end
		
		if ((ScpuiSystem.drawBrMap.mx ~= nil) and (ScpuiSystem.drawBrMap.my ~= nil)) then
			ScpuiSystem.drawBrMap.pof, ScpuiSystem.drawBrMap.closeupZoom, ScpuiSystem.drawBrMap.closeupPos, ScpuiSystem.drawBrMap.label, ScpuiSystem.drawBrMap.iconID = ui.Briefing.checkStageIcons(ScpuiSystem.drawBrMap.mx, ScpuiSystem.drawBrMap.my)
		end
		
		--double check we're still inside the map X coords
		if event.parameters.mouse_x < gx or event.parameters.mouse_x > (ScpuiSystem.drawBrMap.x2 + gx) then
			ScpuiSystem.drawBrMap.pof = nil
			return
		end
	
		--double check we're still inside the map Y coords
		if event.parameters.mouse_y < gy or event.parameters.mouse_y > (ScpuiSystem.drawBrMap.y2 + gy) then
			ScpuiSystem.drawBrMap.pof = nil
			return
		end
		
		if ScpuiSystem.drawBrMap.pof == nil then
			ScpuiSystem.drawBrMap.modelRot = 40
		end
	end

end

function BriefingController:help_clicked()
    self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

function BriefingController:lock_pressed()
	ui.MultiGeneral.getNetGame().Locked = true
end

function BriefingController:submit_pressed()
	if self.submittedValue then
		self:sendChat()
	end
end

function BriefingController:sendChat()
	if string.len(self.submittedValue) > 0 then
		ui.MultiGeneral.sendChat(self.submittedValue)
		self.input_id:SetAttribute("value", "")
		self.submittedValue = ""
	end
end

function BriefingController:InputFocusLost()
	--do nothing
end

function BriefingController:InputChange(event)
	if event.parameters.linebreak ~= 1 then
		local val = self.input_id:GetAttribute("value")
		self.submittedValue = val
	else
		local submit_id = self.document:GetElementById("submit_btn")
		ui.playElementSound(submit_id, "click")
		self:sendChat()
	end
end

function BriefingController:updateLists()
	local chat = ui.MultiGeneral.getChat()
	
	local txt = ""
	for i = 1, #chat do
		local line = ""
		if chat[i].Callsign ~= "" then
			line = chat[i].Callsign .. ": " .. chat[i].Message
		else
			line = chat[i].Message
		end
		txt = txt .. ScpuiSystem:replaceAngleBrackets(line) .. "<br></br>"
	end
	self.chat_el.inner_rml = txt
	self.chat_el.scroll_top = self.chat_el.scroll_height
	
	if ui.MultiGeneral.getNetGame().Locked == true then
		self.document:GetElementById("lock_btn"):SetPseudoClass("checked", true)
	else
		self.document:GetElementById("lock_btn"):SetPseudoClass("checked", false)
	end
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
end

engine.addHook("On Frame", function()
	if (ba.getCurrentGameState().Name == "GS_STATE_BRIEFING") and (ScpuiSystem.render == true) then
		BriefingController:drawMap()
	end
end, {}, function()
    return false
end)

--Prevent the briefing UI from being drawn if we're just going
--to skip it in a frame or two
engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_BRIEFING" and mn.hasNoBriefing() and not ui.isCutscenePlaying() then
		gr.clearScreen()
	end
end, {}, function()
    return false
end)

return BriefingController
