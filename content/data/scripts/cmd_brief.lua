local utils = require("utils")
local rocket_utils = require("rocket_util")
local class = require("class")
local async_util = require("async_util")

local CommandBriefingController = class()

function CommandBriefingController:init()
    --- @type cmd_briefing_stage[]
    self.stages = {}

    --- @type audio_stream
    self.current_voice_handle = nil

    self.stage_instance_id = 0
end

function CommandBriefingController:initialize(document)
    self.document = document

    local briefing = ui.CommandBriefing.getBriefing()
    for i = 1, #briefing do
        --- @type cmd_briefing_stage
        local stage = briefing[i]

        self.stages[i] = stage
    end

    self:registerEventHandlers()

    -- Go to the first stage
    self:go_to_stage(1)

    self:startMusic()

    self.document:GetElementById("cmdpause_btn"):SetPseudoClass("checked", not ba.getCurrentPlayer().AutoAdvance)
end

function CommandBriefingController:unload()
    if self.music_handle ~= nil and self.music_handle:isValid() then
        self.music_handle:close(true)
    end
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:close(false)
    end
end

function CommandBriefingController:startMusic()
    local filename = ui.CommandBriefing.getBriefingMusicName()

    if #filename <= 0 then
        return
    end

    self.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC);
    async.run(function()
        async.await(async_util.wait_for(2.5))
        self.music_handle:play(ad.MasterEventMusicVolume, true)
    end)
end

function CommandBriefingController:registerEventHandlers()
    self.document:GetElementById("cmdlast_btn"):AddEventListener("click", function(_, el, _)
        if self.current_stage >= #self.stages then
            ui.playElementSound(el, "click", "fail")
            return
        end

        self:go_to_stage(#self.stages)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById("cmdnext_btn"):AddEventListener("click", function(_, el, _)
        if self.current_stage >= #self.stages then
            ui.playElementSound(el, "click", "fail")
            return
        end

        self:go_to_stage(self.current_stage + 1)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById("cmdprev_btn"):AddEventListener("click", function(_, el, _)
        if self.current_stage <= 1 then
            ui.playElementSound(el, "click", "fail")
            return
        end

        self:go_to_stage(self.current_stage - 1)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById("cmdfirst_btn"):AddEventListener("click", function(_, el, _)
        if self.current_stage <= 1 then
            ui.playElementSound(el, "click", "fail")
            return
        end

        self:go_to_stage(1)
        ui.playElementSound(el, "click", "success")
    end)
    self.document:GetElementById("accept_btn"):AddEventListener("click", function(_, el, _)
        if mn.isRedAlertMission() then
            ba.postGameEvent(ba.GameEvents["GS_EVENT_RED_ALERT"])
        else
            ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
        end
        ui.playElementSound(el, "click", "commit")
    end)
    self.document:GetElementById("options_btn"):AddEventListener("click", function(_, _, _)
        ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
    end)
    self.document:GetElementById("cmdpause_btn"):AddEventListener("click", function(_, el)
        local plr = ba.getCurrentPlayer()
        local val = plr.AutoAdvance
        plr.AutoAdvance = not val

        el:SetPseudoClass("checked", not plr.AutoAdvance)
    end)
end

function CommandBriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

function CommandBriefingController:waitForStageFinishAsync()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        while self.current_voice_handle:isPlaying() do
            async.await(async.yield())
        end
    else
        -- Estimate a wait time based on the briefing text. Formula is based on the retail way of computing this
        async.await(async_util.wait_for(math.max(5.0, self.current_stage_lines * 3.5)))
    end

    -- Voice part is done so wait for a bit before saying we are actually finished
    async.await(async_util.wait_for(1.0))
end

function CommandBriefingController:go_to_stage(stage_idx)
    self.current_stage = stage_idx
    self.stage_instance_id = self.stage_instance_id + 1

    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        self.current_voice_handle:stop()
        self.current_voice_handle = nil
    end

    local stage = self.stages[stage_idx]

    local text_el = self.document:GetElementById("cmd_text_el")
    self.current_stage_lines = rocket_utils.set_briefing_text(text_el, stage.Text)

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

    local stage_id = self.stage_instance_id
    -- This will ensure that this coroutine only runs if we are still in the same briefing stage and in the same game state
    local execution_context = async.context.combineContexts(async.context.captureGameState(),
        async.context.createLuaState(function()
            if self.stage_instance_id ~= stage_id then
                return CONTEXT_INVALID
            end

            return CONTEXT_VALID
        end))

    async.run(function()
        -- First, wait until the text has been shown fully
        async.await(async_util.wait_for(2.0))

        -- And now we can start playing the void file
        local voiceFile = stage.AudioFilename
        if #voiceFile > 0 and string.lower(voiceFile) ~= "none" then
            self.current_voice_handle = ad.openAudioStream(voiceFile, AUDIOSTREAM_VOICE)
            self.current_voice_handle:play(ad.MasterVoiceVolume)
        end

        self:waitForStageFinishAsync()

        if ba.getCurrentPlayer().AutoAdvance and self.current_stage < #self.stages then
            self:go_to_stage(self.current_stage + 1)
        end
    end, async.OnFrameExecutor, execution_context)
end

return CommandBriefingController
