local rocket_utils = require("rocket_util")
local async_util = require("async_util")
local utils = require("utils")
local topics = require("ui_topics")
local loadoutHandler = require("loadouthandler")

local class = require("class")

local AbstractBriefingController = class()

function AbstractBriefingController:init()
    --- @type audio_stream
    self.current_voice_handle = nil

    self.current_stage = 0
    self.stage_instance_id = 0
	
	self.filename = nil

    self.loaded = true
	
	self.briefState = "briefing"

    self.uiActiveContext = async.context.combineContexts(async.context.captureGameState(),
        async.context.createLuaState(function()
            if not self.loaded then
                return CONTEXT_INVALID
            end

            return CONTEXT_VALID
        end))

    self.element_names = {
        pause_btn = nil,
        last_btn = nil,
        next_btn = nil,
        prev_btn = nil,
        first_btn = nil,
        text_el = nil,
        stage_text_el = nil,
    }
end

function AbstractBriefingController:initialize(document)
    self.document = document
    self.loaded = true
	
	if ba.getCurrentGameState().Name == "GS_STATE_FICTION_VIEWER" then
		self.briefState = "fiction"
	end
	
	if ba.getCurrentGameState().Name == "GS_STATE_CMD_BRIEF" then
		self.briefState = "command"
	end
    
	self:startMusic()

	if self.briefState ~= "fiction" then
		self:registerEventHandlers()
	end

    local player = ba.getCurrentPlayer()
    local autoAdvance = player.AutoAdvance
	
	if self.briefState ~= "fiction" then
		self.document:GetElementById(self.element_names.pause_btn):SetPseudoClass("checked", not autoAdvance)
	end
	
	topics.briefcommon.initialize:send(self)

end

function AbstractBriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
		ScpuiSystem:stopMusic()
		ScpuiSystem.current_played = nil
		ScpuiSystem.music_started = nil
		ScpuiSystem.drawBrMap = nil
		ScpuiSystem.cutscenePlayed = nil
		
		if self.briefState == "briefing" then
			loadoutHandler:saveCurrentLoadout()
			loadoutHandler:unloadAll(false)
		end
        event:StopPropagation()
		
		mn.unloadMission(true)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	elseif event.parameters.key_identifier == rocket.key_identifier.UP then
		self:scroll_down()
	elseif event.parameters.key_identifier == rocket.key_identifier.DOWN then
		self:scroll_up()
	elseif event.parameters.key_identifier == rocket.key_identifier.LEFT then
		self:go_to_prev_stage()
	elseif event.parameters.key_identifier == rocket.key_identifier.RIGHT then
		self:go_to_next_stage()
    end
end

function AbstractBriefingController:scroll_up()
	local text_el = self.document:GetElementById(self.element_names.text_el)
	text_el.parent_node.scroll_top = text_el.parent_node.scroll_top + 10
end

function AbstractBriefingController:scroll_down()
	local text_el = self.document:GetElementById(self.element_names.text_el)
	text_el.parent_node.scroll_top = text_el.parent_node.scroll_top - 10
end

function AbstractBriefingController:go_to_next_stage()
	if self.current_stage >= #self.stages then
		ui.playElementSound(nil, "click", "fail")
		return
	end
	
	if self.briefState == "briefing" then
		ui.Briefing.callNextMapStage()
		if self.stages[self.current_stage].hasForwardCut then
			self:CutToStage()
		end
	end

	self:go_to_stage(self.current_stage + 1)
	ui.playElementSound(nil, "click", "success")
end

function AbstractBriefingController:go_to_prev_stage()
	if self.current_stage <= 1 then
		ui.playElementSound(nil, "click", "fail")
		return
	end

	if self.briefState == "briefing" then
		ui.Briefing.callPrevMapStage()
		if self.stages[self.current_stage].hasBackwardCut then
			self:CutToStage()
		end
	end

	self:go_to_stage(self.current_stage - 1)
	ui.playElementSound(nil, "click", "success")
end

function AbstractBriefingController:registerEventHandlers()
    self.document:GetElementById(self.element_names.last_btn):AddEventListener("click", function(_, el, _)
        if self.current_stage >= #self.stages then
            ui.playElementSound(el, "click", "fail")
            return
        end
		
		if self.briefState == "briefing" then
			self:CutToStage()
			ui.Briefing.callLastMapStage()
		end
		
        self:go_to_stage(#self.stages)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById(self.element_names.next_btn):AddEventListener("click", function(_, el, _)
        self:go_to_next_stage()
    end)
    self.document:GetElementById(self.element_names.prev_btn):AddEventListener("click", function(_, el, _)
        self:go_to_prev_stage()
    end)
    self.document:GetElementById(self.element_names.first_btn):AddEventListener("click", function(_, el, _)
        if self.current_stage <= 1 then
            ui.playElementSound(el, "click", "fail")
            return
        end

		if self.briefState == "briefing" then
			self:CutToStage()
			ui.Briefing.callFirstMapStage()
		end

        self:go_to_stage(1)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById("accept_btn"):AddEventListener("click", function(_, el, _)
        self:acceptPressed()
        ui.playElementSound(el, "click", "commit")
    end)
    self.document:GetElementById("options_btn"):AddEventListener("click", function(_, _, _)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
    end)
    self.document:GetElementById(self.element_names.pause_btn):AddEventListener("click", function(_, el)
        local plr = ba.getCurrentPlayer()
        local val = plr.AutoAdvance
        plr.AutoAdvance = not val

        el:SetPseudoClass("checked", not plr.AutoAdvance)
    end)
end

function AbstractBriefingController:unload()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:close(false)
    end
	if ScpuiSystem.drawBrMap then
		ScpuiSystem.drawBrMap.tex:unload()
		ScpuiSystem.drawBrMap.tex = nil
		ScpuiSystem.drawBrMap = nil
	end
	
	if self.briefState == "briefing" then
		if self.Commit == true then
			loadoutHandler:saveCurrentLoadout()
			loadoutHandler:unloadAll(true)
			ScpuiSystem.drawBrMap = nil
			ScpuiSystem.cutscenePlayed = nil
		end
		ui.Briefing.closeBriefing()
	end
	
    -- We need to keep track of if we are loaded or not to abort coroutines that still have references to this instance
    self.loaded = false
	
	if self.briefState == "briefing" then
		topics.briefing.unload:send(self)
	elseif self.briefState == "command" then
		topics.cmdbriefing.unload:send(self)
	elseif self.briefState == "fiction" then
		topics.fictionviewer.unload:send(self)
	end
end

function AbstractBriefingController:startMusic()
	local filename = ui.Briefing.getBriefingMusicName()
	
	if self.briefState == "fiction" then
		filename = ui.FictionViewer.getFictionMusicName()
	end

    if #filename <= 0 then
        return
    end
	
	if filename ~= ScpuiSystem.current_played then
	
		if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
			ScpuiSystem.music_handle:close(true)
		end
	
		--ScpuiSystem.current_played = filename

		ScpuiSystem.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
		async.run(function()
			async.await(async_util.wait_for(2.5))
			ScpuiSystem.music_handle:play(ad.MasterEventMusicVolume, true)
			ScpuiSystem.current_played = filename
		end, async.OnFrameExecutor, self.uiActiveContext)
	end
end

function AbstractBriefingController:waitForStageFinishAsync(num_stage_lines)
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        while self.current_voice_handle:isPlaying() do
            async.await(async.yield())
        end
    else
        -- Estimate a wait time based on the briefing text. Formula is based on the retail way of computing this
        async.await(async_util.wait_for(math.max(5.0, num_stage_lines * 3.5)))
    end

    -- Voice part is done so wait for a bit before saying we are actually finished
    async.await(async_util.wait_for(1.0))
end

function AbstractBriefingController:leaveStage()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:stop()
        self.current_voice_handle = nil
    end
end

function AbstractBriefingController:initializeStage(stageIdx, briefingText, audioFileName)
    self.current_stage = stageIdx
    self.stage_instance_id = self.stage_instance_id + 1
	if not mn.hasNoBriefing() then
		ad.playInterfaceSound(20)
	end

    local text_el = self.document:GetElementById(self.element_names.text_el)
	text_el.parent_node.scroll_top = 0
    local num_stage_lines = rocket_utils.set_briefing_text(text_el, briefingText)

    local stage_indicator_el = self.document:GetElementById(self.element_names.stage_text_el)
    stage_indicator_el.inner_rml = string.format(ba.XSTR("Stage %d of %d", 888283), self.current_stage, #self.stages)

    local stage_id = self.stage_instance_id
    -- This will ensure that this coroutine only runs if we are still in the same briefing stage and in the same game state
    local execution_context = async.context.combineContexts(async.context.captureGameState(),
        self.uiActiveContext,
        async.context.createLuaState(function()
            if self.stage_instance_id ~= stage_id then
                return CONTEXT_INVALID
            end

            return CONTEXT_VALID
        end))

    async.run(function()
        -- First, wait until the text has been shown fully
        async.await(async_util.wait_for(2.0))

        -- And now we can start playing the voice file
		if self.stages[stageIdx].AudioFilename then
			if #audioFileName > 0 and string.lower(audioFileName) ~= "none" then
				self.current_voice_handle = ad.openAudioStream(audioFileName, AUDIOSTREAM_VOICE)
				self.current_voice_handle:play(ad.MasterVoiceVolume)
			end
		end

        self:waitForStageFinishAsync(num_stage_lines)

        if ba.getCurrentPlayer().AutoAdvance and self.current_stage < #self.stages then
            self:go_to_stage(self.current_stage + 1)
			if self.briefState == "briefing" then
				ui.Briefing.callNextMapStage()
			end
        end
    end, async.OnFrameExecutor, execution_context)
end

return AbstractBriefingController
