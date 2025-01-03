local rocket_utils = require("rocket_util")
local async_util = require("async_util")
local dialogs = require("dialogs")
local utils = require("utils")
local topics = require("ui_topics")

local class = require("class")

local DebriefingController = class()

function DebriefingController:init()
	if not ScpuiSystem.debriefInit then
		ScpuiSystem:maybePlayCutscene(MOVIE_PRE_DEBRIEF)
	end
    self.stages = {}
    self.recommendVisible = false
    self.player = nil
    self.page = 1
    self.help_shown = false
end

function DebriefingController:initialize(document)
    self.document = document
    self.selectedSection = 1
    self.audioPlaying = 0
	self.audioFinished = false
    
    if not ScpuiSystem.debriefInit then
        ui.Debriefing.initDebriefing()
        if not mn.hasDebriefing() then
			topics.debrief.skip:send()
            self:close()
            ui.Debriefing.acceptMission()
			ScpuiSystem:maybePlayCutscene(MOVIE_POST_DEBRIEF)
            return
        end
        self:startMusic()
        ScpuiSystem.debriefInit = true
    end
    
    self.player = ba.getCurrentPlayer()    
    
    if self.player.ShowSkipPopup and ui.Debriefing.canSkip() and ui.Debriefing.mustReplay() then
        self:OfferSkip()
    end
    
    ---Load background choice
    self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	self.chat_el = self.document:GetElementById("chat_window")
	self.input_id = self.document:GetElementById("chat_input")
    
    ---Load the desired font size from the save file
    self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
    
    self.document:GetElementById("mission_name").inner_rml = mn.getMissionTitle()
    self.document:GetElementById("awards_wrapper"):SetClass("hidden", true)
    
    local li_el = self.document:CreateElement("li")
    
    local promoStage, promoName, promoFile = ui.Debriefing.getEarnedPromotion()
    local badgeStage, badgeName, badgeFile = ui.Debriefing.getEarnedBadge()
    local medalName, medalFile = ui.Debriefing.getEarnedMedal()
    
    self.numStages = 0
    self.audioPlaying = 0
    
    local traitorStage = ui.Debriefing.getTraitor()
    
    if not traitorStage then
        if promoName then
            self.numStages = self.numStages + 1
            self.stages[self.numStages] = promoStage
            self.document:GetElementById("awards_wrapper"):SetClass("hidden", false)
            local awards_el = self.document:GetElementById("medal_image_wrapper")
            local imgEl = self.document:CreateElement("img")
            imgEl:SetAttribute("src", promoFile)
            imgEl:SetClass("medal_img", true)
            awards_el:AppendChild(imgEl)
            self.document:GetElementById("promotion_text").inner_rml = promoName
        end
        
        if badgeName then
            self.numStages = self.numStages + 1
            self.stages[self.numStages] = badgeStage
            self.document:GetElementById("awards_wrapper"):SetClass("hidden", false)
            local awards_el = self.document:GetElementById("medal_image_wrapper")
            local imgEl = self.document:CreateElement("img")
            imgEl:SetAttribute("src", badgeFile)
            imgEl:SetClass("medal_img", true)
            awards_el:AppendChild(imgEl)
            self.document:GetElementById("badge_text").inner_rml = badgeName
        end
        
        if medalName then
			--Check for an alt debrief bitmap
			if ScpuiSystem.medalInfo[medalName] then
				if ScpuiSystem.medalInfo[medalName].altDebriefBitmap then
					medalFile = ScpuiSystem.medalInfo[medalName].altDebriefBitmap
				end
			end
            self.document:GetElementById("awards_wrapper"):SetClass("hidden", false)
            local awards_el = self.document:GetElementById("medal_image_wrapper")
            local imgEl = self.document:CreateElement("img")
            imgEl:SetAttribute("src", medalFile)
            imgEl:SetClass("medal_img", true)
            awards_el:AppendChild(imgEl)
            self.document:GetElementById("medal_text").inner_rml = medalName
        end
        
        local debriefing = ui.Debriefing.getDebriefing()

        for i = 1, #debriefing do
            --- @type debriefing_stage
            local stage = debriefing[i]
            if stage:checkVisible() then
                self.numStages = self.numStages + 1
                self.stages[self.numStages] = stage
                --This is where we should replace variables and containers probably!
            end
        end
    else
        self.numStages = 1
        self.stages[1] = traitorStage
    end
	
	self.document:GetElementById("stage_select"):SetClass("hidden", true)
	self.document:GetElementById("play_cont"):SetClass("hidden", true)
	self.document:GetElementById("stop_cont"):SetClass("hidden", true)
    
    self:BuildText()
    
    self:start_audio()
    
    self.document:GetElementById("debrief_btn"):SetPseudoClass("checked", true)
    
	topics.debrief.initialize:send(self)

end

function DebriefingController:start_audio()
	self.audioPlaying = 0
	self.audioFinished = false
	self:PlayVoice()
	self.document:GetElementById("play_cont"):SetClass("hidden", true)
	self.document:GetElementById("stop_cont"):SetClass("hidden", false)
end

function DebriefingController:stop_audio()
	self.audioPlaying = self.numStages
	self:StopVoice()
	self.document:GetElementById("play_cont"):SetClass("hidden", false)
	self.document:GetElementById("stop_cont"):SetClass("hidden", true)
end

function DebriefingController:PlayVoice()
	if self.selectedSection ~= 1 then
		return
	end
	-- If we've played all the audio then don't play any more!
	if self.audioPlaying == self.numStages then
		self.audioFinished = true
		self.document:GetElementById("play_cont"):SetClass("hidden", false)
		self.document:GetElementById("stop_cont"):SetClass("hidden", true)
		return
	end
    async.run(function()
        -- First, wait until the text has been shown fully
        async.await(async_util.wait_for(1.0))

        -- And now we can start playing the voice file
        if self.stages[self.audioPlaying + 1] then
            if self.stages[self.audioPlaying + 1].AudioFilename then
                self.audioPlaying = self.audioPlaying + 1
                local file = self.stages[self.audioPlaying].AudioFilename
                if #file > 0 and string.lower(file) ~= "none" then
					--If a voice is already playing then close it and start a new one
					self:StopVoice()
                    self.current_voice_handle = ad.openAudioStream(file, AUDIOSTREAM_VOICE)
                    self.current_voice_handle:play(ad.MasterVoiceVolume)
                end
            end
        end

        self:waitForStageFinishAsync()
        
        if self.selectedSection == 1 then
            self:PlayVoice()
        end
    end, async.OnFrameExecutor)
end

function DebriefingController:StopVoice()
	if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
		self.current_voice_handle:close(false)
	end
end

function DebriefingController:waitForStageFinishAsync()
    if self.current_voice_handle ~= nil and self.current_voice_handle:isValid() then
        while self.current_voice_handle:isPlaying() do
            async.await(async.yield())
        end
    else
        --Do nothing
    end

    -- Voice part is done so wait for a bit before saying we are actually finished
    async.await(async_util.wait_for(0.5))
end

function DebriefingController:BuildText()
    
    local text_el = self.document:GetElementById("debrief_text")
    
    self.RecIDs = {}

    for i = 1, #self.stages do
        local paragraph = self.document:CreateElement("p")
        text_el:AppendChild(paragraph)
        paragraph:SetClass("debrief_text_actual", true)
        local color_text = rocket_utils.set_briefing_text(paragraph, self.stages[i].Text)
        if self.stages[i].Recommendation ~= "" then
            local recommendation = self.document:CreateElement("p")
            self.RecIDs[i] = recommendation
            text_el:AppendChild(recommendation)
            recommendation.inner_rml = self.stages[i].Recommendation
            recommendation:SetClass("hidden", true)
            recommendation:SetClass("red", true)
            recommendation:SetClass("recommendation", true)
        end
    end

    if #self.RecIDs == 0 then
        local paragraph = self.document:CreateElement("p")
        text_el:AppendChild(paragraph)
        local recommendation = self.document:CreateElement("p")
        self.RecIDs[1] = recommendation
        text_el:AppendChild(recommendation)
        recommendation.inner_rml = ba.XSTR("We have no recommendations for you.", 888314)
        recommendation:SetClass("hidden", true)
        recommendation:SetClass("red", true)
        recommendation:SetClass("recommendation", true)
    end

end

function DebriefingController:BuildStats()

    local stats = self.player.Stats
    local name = self.player:getName()
    local difficulty = ba.getGameDifficulty()
    local missionTime = mn.getMissionTime() + mn.MissionHUDTimerPadding 
    
    --Convert mission time to minutes + seconds
    missionTime = (math.floor(missionTime/60)) .. ":" .. (math.floor(missionTime % 60))
    
    if difficulty == 1 then difficulty = ba.XSTR("Very Easy", 469, false) end
    if difficulty == 2 then difficulty = ba.XSTR("Easy", 470, false) end
    if difficulty == 3 then difficulty = ba.XSTR("Medium", 471, false) end
    if difficulty == 4 then difficulty = ba.XSTR("Hard", 472, false) end
    if difficulty == 5 then difficulty = ba.XSTR("Very Hard", 473, false) end
    
    local text_el = self.document:GetElementById("debrief_text")
    
    local titles = ""
    local numbers = ""
    
    --Build stats header
    local header = self.document:CreateElement("div")
    text_el:AppendChild(header)
    header:SetClass("blue", true)
    header:SetClass("stats_header", true)
    local name_el = self.document:CreateElement("p")
    local page_el = self.document:CreateElement("p")
    header:AppendChild(name_el)
    name_el:SetClass("stats_header_left", true)
    header:AppendChild(page_el)
    page_el:SetClass("stats_header_right", true)
    name_el.inner_rml = name
    page_el.inner_rml = self.page .. " of 4"
    
    --Build stats sub header
    local subheader = self.document:CreateElement("div")
    text_el:AppendChild(subheader)
    subheader:SetClass("stats_subheader", true)
    local name_el = self.document:CreateElement("p")
    local page_el = self.document:CreateElement("p")
    subheader:AppendChild(name_el)
    name_el:SetClass("stats_left", true)
    subheader:AppendChild(page_el)
    page_el:SetClass("stats_right", true)
    name_el.inner_rml = "Skill Level"
    page_el.inner_rml = difficulty
    
    --Build stats page 1
    if self.page == 1 then
        titles = "Mission Time<br></br><br></br>Mission Stats<br></br><br></br>Total Kills<br></br><br></br>Primary Weapon Shots<br></br>Primary Weapon Hits<br></br>Primary Friendly Hits<br></br>Primary Hit %<br></br>Primary Friendly Hit %<br></br><br></br>Secondary Weapon Shots<br></br>Secondary Weapon Hits<br></br>Secondary Friendly Hits<br></br>Secondary Hit %<br></br>Secondary Friendly Hit %<br></br><br></br>Assists"
        
        local primaryHitPer = math.floor((stats.MissionPrimaryShotsHit / stats.MissionPrimaryShotsFired) * 100) .. "%"
        local primaryFrHitPer = math.floor((stats.MissionPrimaryFriendlyHit / stats.MissionPrimaryShotsFired) * 100) .. "%"
        local secondaryHitPer = math.floor((stats.MissionSecondaryShotsHit / stats.MissionSecondaryShotsFired) * 100) .. "%"
        local secondaryFrHitPer = math.floor((stats.MissionSecondaryFriendlyHit / stats.MissionSecondaryShotsFired) * 100) .. "%"
        
        --Zero out percentages if appropriate
        if stats.MissionPrimaryShotsHit == 0 then
            primaryHitPer = 0 .. "%"
            primaryFrHitPer = 0 .. "%"
        end
        if stats.MissionSecondaryShotsHit == 0 then
            secondaryHitPer = 0 .. "%"
            secondaryFrHitPer = 0 .. "%"
        end
        
        numbers = missionTime .. "<br></br><br></br><br></br><br></br>" .. stats.MissionTotalKills .. "<br></br><br></br>" .. stats.MissionPrimaryShotsFired .. "<br></br>" .. stats.MissionPrimaryShotsHit  .. "<br></br>" .. stats.MissionPrimaryFriendlyHit .. "<br></br>" .. primaryHitPer .. "<br></br>" .. primaryFrHitPer .. "<br></br><br></br>" .. stats.MissionSecondaryShotsFired .. "<br></br>" .. stats.MissionSecondaryShotsHit .. "<br></br>" .. stats.MissionSecondaryFriendlyHit .. "<br></br>" .. secondaryHitPer .. "<br></br>" .. secondaryFrHitPer .. "<br></br><br></br>" .. stats.MissionAssists
    end
    
    if self.page == 2 then
        titles = "Mission Kills by Ship Type<br></br><br></br>"
        numbers = "<br></br><br></br>"
        
        for i = 1, #tb.ShipClasses do
            local kills = stats:getMissionShipclassKills(tb.ShipClasses[i])
            if kills > 0 then
                local name = topics.ships.name:send(tb.ShipClasses[i])
                titles = titles .. name .. "<br></br><br></br>"
                numbers = numbers .. kills .. "<br></br><br></br>"
            end
        end
    end
    
    if self.page == 3 then
        titles = "All Time Stats<br></br><br></br>Total Kills<br></br><br></br>Primary Weapon Shots<br></br>Primary Weapon Hits<br></br>Primary Friendly Hits<br></br>Primary Hit %<br></br>Primary Friendly Hit %<br></br><br></br>Secondary Weapon Shots<br></br>Secondary Weapon Hits<br></br>Secondary Friendly Hits<br></br>Secondary Hit %<br></br>Secondary Friendly Hit %<br></br><br></br>Assists"
        
        local primaryHitPer = math.floor((stats.PrimaryShotsHit / stats.PrimaryShotsFired) * 100) .. "%"
        local primaryFrHitPer = math.floor((stats.PrimaryFriendlyHit / stats.PrimaryShotsFired) * 100) .. "%"
        local secondaryHitPer = math.floor((stats.SecondaryShotsHit / stats.SecondaryShotsFired) * 100) .. "%"
        local secondaryFrHitPer = math.floor((stats.SecondaryFriendlyHit / stats.SecondaryShotsFired) * 100) .. "%"
        
        --Zero out percentages if appropriate
        if stats.MissionPrimaryShotsHit == 0 then
            primaryHitPer = 0 .. "%"
            primaryFrHitPer = 0 .. "%"
        end
        if stats.MissionSecondaryShotsHit == 0 then
            secondaryHitPer = 0 .. "%"
            secondaryFrHitPer = 0 .. "%"
        end
        
        numbers = "<br></br><br></br>" .. stats.TotalKills .. "<br></br><br></br>" .. stats.PrimaryShotsFired .. "<br></br>" .. stats.PrimaryShotsHit  .. "<br></br>" .. stats.PrimaryFriendlyHit .. "<br></br>" .. primaryHitPer .. "<br></br>" .. primaryFrHitPer .. "<br></br><br></br>" .. stats.SecondaryShotsFired .. "<br></br>" .. stats.SecondaryShotsHit .. "<br></br>" .. stats.SecondaryFriendlyHit .. "<br></br>" .. secondaryHitPer .. "<br></br>" .. secondaryFrHitPer .. "<br></br><br></br>" .. stats.Assists
    end
    
    if self.page == 4 then
        titles = "All Time Kills by Ship Type<br></br><br></br>"
        numbers = "<br></br><br></br>"
        
        for i = 1, #tb.ShipClasses do
            local kills = stats:getShipclassKills(tb.ShipClasses[i])
            if kills > 0 then
                local name = topics.ships.name:send(tb.ShipClasses[i])
                titles = titles .. name .. "<br></br><br></br>"
                numbers = numbers .. kills .. "<br></br><br></br>"
            end
        end
    end
    
    --Actually write the stats data here
    local stats = self.document:CreateElement("div")
    text_el:AppendChild(stats)
    local titles_el = self.document:CreateElement("p")
    local numbers_el = self.document:CreateElement("p")
    stats:AppendChild(titles_el)
    titles_el:SetClass("stats_left", true)
    stats:AppendChild(numbers_el)
    numbers_el:SetClass("stats_right", true)
    titles_el.inner_rml = titles
    numbers_el.inner_rml = numbers

end

function DebriefingController:ClearText()
    self.document:GetElementById("debrief_text").inner_rml = ""
end

function DebriefingController:startMusic()
    local filename = ui.Debriefing.getDebriefingMusicName()
    
    ScpuiSystem.music_handle = ad.openAudioStream(filename, AUDIOSTREAM_MENUMUSIC)
    async.run(function()
        async.await(async_util.wait_for(2.5))
        ScpuiSystem.music_handle:play(ad.MasterEventMusicVolume, true, 0)
    end, async.OnFrameExecutor)
end

function DebriefingController:Show(text, title, buttons)
    --Create a simple dialog box with the text and title

    local dialog = dialogs.new()
        dialog:title(title)
        dialog:text(text)
        dialog:escape("cancel")
        for i = 1, #buttons do
            dialog:button(buttons[i].b_type, buttons[i].b_text, buttons[i].b_value, buttons[i].b_keypress)
        end
        dialog:show(self.document.context)
        :continueWith(function(response)
        self:dialog_response(response)
    end)
    -- Route input to our context until the user dismisses the dialog box.
    ui.enableInput(self.document.context)
end

function DebriefingController:dialog_response(response)
    local switch = {
        accept = function()
        
            topics.debrief.accept:send()
            
            self:close()
            ui.Debriefing.acceptMission()
			ScpuiSystem:maybePlayCutscene(MOVIE_POST_DEBRIEF)
        end, 
        acceptquit = function()
        
            topics.debrief.accept:send()
            
            self:close()
            ui.Debriefing.acceptMission(false)
			ScpuiSystem:maybePlayCutscene(MOVIE_POST_DEBRIEF)
            mn.unloadMission(true)
            ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
        end,
        replay = function()
        
            topics.debrief.reject:send()
            
            self:close()
            ui.Debriefing.clearMissionStats()
            ui.Debriefing.replayMission()
        end,
        quit = function()
        
            topics.debrief.reject:send()
        
            self:close()
            ui.Debriefing.clearMissionStats()
            ui.Debriefing.replayMission(false)
            mn.unloadMission(true)
            ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
        end,
        skip = function()
        
            topics.debrief.accept:send()
        
            self:close()
            ui.Debriefing.acceptMission(false)
			ScpuiSystem:maybePlayCutscene(MOVIE_POST_DEBRIEF)
            ui.Briefing.skipMission()
        end,
        optout = function()
            self.player.ShowSkipPopup = false
        end,
        cancel = function()
            --Do Nothing   
        end,
    }

    if switch[response] then
        switch[response]()
    else
        switch["cancel"]()
    end
end

function DebriefingController:GetCharacterAtWord(text, index)

    local words = {}
    for word in text:gmatch("%S+") do table.insert(words, word) end
    
    if index > #words then index = #words end
    if index < 1 then index = 1 end
    
    return string.sub(words[index], 1, 1)

end

function DebriefingController:OfferSkip()
    local text = ba.XSTR("You have failed this mission five times.  If you like, you may advance to the next mission.", 888315)
    local title = ""
    local buttons = {}
    
    
    
    buttons[1] = {
        b_type = dialogs.BUTTON_TYPE_NEGATIVE,
        b_text = ba.XSTR("Do Not Skip This Mission", 888316),
        b_value = "cancel",
        b_keypress = self:GetCharacterAtWord(ba.XSTR("Do Not Skip This Mission", 888316), 2)
    }
    buttons[2] = {
        b_type = dialogs.BUTTON_TYPE_POSITIVE,
        b_text = ba.XSTR("Advance To The Next Mission", 888318),
        b_value = "skip",
        b_keypress = self:GetCharacterAtWord(ba.XSTR("Advance To The Next Mission", 888318), 1)
    }
    buttons[3] = {
        b_type = dialogs.BUTTON_TYPE_NEUTRAL,
        b_text = ba.XSTR("Don't Show Me This Again", 888320),
        b_value = "optout",
        b_keypress = self:GetCharacterAtWord(ba.XSTR("Don't Show Me This Again", 888320), 1)
    }
        
    self:Show(text, title, buttons)
end

function DebriefingController:page_pressed(command)
    if self.selectedSection == 1 then
        ui.playElementSound(nil, "click", "failure")
        --FIXMEEEE
    else
        if command == 1 then
            self.page = 1
        end
        if command == 4 then
            self.page = 4
        end
        if command == 2 then
            self.page = self.page - 1
            if self.page <= 0 then
                self.page = 1
            end
        end
        if command == 3 then
            self.page = self.page + 1
            if self.page >= 5 then
                self.page = 4
            end
        end
        
        ui.playElementSound(nil, "click", "success")
        self:ClearText()
        self:BuildStats()
    end
end

function DebriefingController:debrief_pressed(element)
    if self.selectedSection ~= 1 then
        ui.playElementSound(element, "click", "success")
        self.document:GetElementById("debrief_btn"):SetPseudoClass("checked", true)
        self.document:GetElementById("stats_btn"):SetPseudoClass("checked", false)
        self.selectedSection = 1
        
        self.document:GetElementById("stage_select"):SetClass("hidden", true)
		self.document:GetElementById("play_controls"):SetClass("hidden", false)
        
        self:ClearText()
        self:BuildText()
		
		if not self.audioFinished then
			self:start_audio()
		end
        
        self.recommendVisible = false
    end
end

function DebriefingController:stats_pressed(element)
    if self.selectedSection ~= 2 then
        ui.playElementSound(element, "click", "success")
        self.document:GetElementById("debrief_btn"):SetPseudoClass("checked", false)
        self.document:GetElementById("stats_btn"):SetPseudoClass("checked", true)
        self.selectedSection = 2
        
        self.document:GetElementById("stage_select"):SetClass("hidden", false)
		self.document:GetElementById("play_controls"):SetClass("hidden", true)
        
        self:ClearText()
        self:StopVoice()
        self:BuildStats()
        
        self.recommendVisible = false
    end
end

function DebriefingController:recommend_pressed(element)
    ui.playElementSound(element, "click", "success")
    
    for i = 1, #self.RecIDs do
        self.RecIDs[i]:SetClass("hidden", self.recommendVisible)
    end
    
    self.recommendVisible = not self.recommendVisible
end
    

function DebriefingController:replay_pressed(element)
    ui.playElementSound(element, "click", "success")
    if ui.Debriefing:mustReplay() then
        ui.Debriefing.clearMissionStats()
        
        topics.debrief.reject:send()
        
        self:close()
        ui.Debriefing.replayMission()
    else
        local text = ba.XSTR("If you choose to replay this mission, you will be required to complete it again before proceeding to future missions.\n\nIn addition, any statistics gathered during this mission will be discarded if you choose to replay.", 888322)
        text = string.gsub(text,"\n","<br></br>")
        local title = ""
        local buttons = {}
        buttons[1] = {
            b_type = dialogs.BUTTON_TYPE_NEGATIVE,
            b_text = ba.XSTR("Cancel", 888091),
            b_value = "cancel",
            b_keypress = self:GetCharacterAtWord(ba.XSTR("Cancel", 888091), 1)
        }
        buttons[2] = {
            b_type = dialogs.BUTTON_TYPE_POSITIVE,
            b_text = ba.XSTR("Replay", 888325),
            b_value = "replay",
            b_keypress = self:GetCharacterAtWord(ba.XSTR("Replay", 888325), 1)
        }
            
        self:Show(text, title, buttons)
    end
end

function DebriefingController:accept_pressed()
    if ui.Debriefing:mustReplay() then
        local text
        if ui.Debriefing.getTraitor() then
            text = ba.XSTR("Your career is over, Traitor!  You can't accept new missions!", 888327)
        else
            text = ba.XSTR("You have failed this mission and cannot accept.  What do you you wish to do instead?", 888328)
        end
        local title = ""
        local buttons = {}
        buttons[1] = {
            b_type = dialogs.BUTTON_TYPE_NEUTRAL,
            b_text = ba.XSTR("Return to Debriefing", 888329),
            b_value = "cancel",
            b_keypress = self:GetCharacterAtWord(ba.XSTR("Return to Debriefing", 888329), 3)
        }
        buttons[2] = {
            b_type = dialogs.BUTTON_TYPE_NEUTRAL,
            b_text = ba.XSTR("Go to Flight Deck", 888331),
            b_value = "quit",
            b_keypress = self:GetCharacterAtWord(ba.XSTR("Go to Flight Deck", 888331), 1)
        }
        buttons[3] = {
            b_type = dialogs.BUTTON_TYPE_NEUTRAL,
            b_text = ba.XSTR("Replay Mission", 888058),
            b_value = "replay",
            b_keypress = self:GetCharacterAtWord(ba.XSTR("Replay Mission", 888058), 1)
        }
            
        self:Show(text, title, buttons)
    else
    
        topics.debrief.accept:send()
    
        self:close()
        ui.Debriefing.acceptMission()
		ScpuiSystem:maybePlayCutscene(MOVIE_POST_DEBRIEF)
    end
end

function DebriefingController:medals_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    self.selectedSection = 0
    ba.postGameEvent(ba.GameEvents["GS_EVENT_VIEW_MEDALS"])
end

function DebriefingController:options_button_clicked(element)
    ui.playElementSound(element, "click", "success")
    self.selectedSection = 0
    ba.postGameEvent(ba.GameEvents["GS_EVENT_OPTIONS_MENU"])
end

function DebriefingController:help_clicked(element)
    ui.playElementSound(element, "click", "success")
    
    self.help_shown  = not self.help_shown

    local help_texts = self.document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.help_shown)
    end
end

function DebriefingController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
        if ui.Debriefing:mustReplay() then
            local text = ba.XSTR("Because this mission was a failure, you must replay this mission when you continue your campaign.\n\nReturn to the Flight Deck?", 888335)
            text = string.gsub(text,"\n","<br></br>")
            local title = ""
            local buttons = {}
            buttons[1] = {
                b_type = dialogs.BUTTON_TYPE_NEGATIVE,
                b_text = ba.XSTR("No", 888298),
                b_value = "cancel",
                b_keypress = self:GetCharacterAtWord(ba.XSTR("No", 888298), 1)
            }
            buttons[2] = {
                b_type = dialogs.BUTTON_TYPE_POSITIVE,
                b_text = ba.XSTR("Yes", 888296),
                b_value = "quit",
                b_keypress = self:GetCharacterAtWord(ba.XSTR("Yes", 888296), 1)
            }
                
            self:Show(text, title, buttons)
        else
            local text = ba.XSTR("Accept this mission outcome?", 888340)
            local title = ""
            local buttons = {}
            buttons[1] = {
                b_type = dialogs.BUTTON_TYPE_NEGATIVE,
                b_text = ba.XSTR("Cancel", 888091),
                b_value = "cancel",
                b_keypress = self:GetCharacterAtWord(ba.XSTR("Cancel", 888091), 1)
            }
            buttons[2] = {
                b_type = dialogs.BUTTON_TYPE_POSITIVE,
                b_text = ba.XSTR("Yes", 888296),
                b_value = "acceptquit",
                b_keypress = self:GetCharacterAtWord(ba.XSTR("Yes", 888296), 1)
            }
            buttons[3] = {
                b_type = dialogs.BUTTON_TYPE_NEUTRAL,
                b_text = ba.XSTR("No, retry later", 888345),
                b_value = "quit",
                b_keypress = self:GetCharacterAtWord(ba.XSTR("No, retry later", 888345), 1)
            }
                
            self:Show(text, title, buttons)
        end
    end
end

function DebriefingController:close()
    if ScpuiSystem.music_handle ~= nil and ScpuiSystem.music_handle:isValid() then
        ScpuiSystem.music_handle:close(false)
        ScpuiSystem.music_handle = nil
    end
	self:unload()
    ScpuiSystem.debriefInit = false
end

function DebriefingController:unload()
	self.selectedSection = 0
    self:StopVoice()
	
	topics.debrief.unload:send(self)
end

--Prevent the debriefing UI from being drawn if we're just going
--to skip it in a frame or two
engine.addHook("On Frame", function()
    if ba.getCurrentGameState().Name == "GS_STATE_DEBRIEF" and not mn.hasDebriefing() and not ui.isCutscenePlaying() then
        gr.clearScreen()
    end
end, {}, function()
    return false
end)

return DebriefingController

