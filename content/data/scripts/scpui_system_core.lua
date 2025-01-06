local utils = require("utils")
local topics = require("ui_topics")

-----------------------------------
--This is the core SCPUI file. It handles state management and
--all necessary preloading of content. Disabling this, disables
--everything. Modify with care.
-----------------------------------

local updateCategory = engine.createTracingCategory("UpdateRocket", false)
local renderCategory = engine.createTracingCategory("RenderRocket", true)

ScpuiSystem = {}

---@type scpui_data
ScpuiSystem.data = {
	active = true,
	numFontSizes = 40,
	replacements = {},
	backgrounds = {},
	briefBackgrounds = {},
	preloadCoroutines = {},
	medalInfo = {},
	substate = "none",
	oldSubstate = "none",
	tableFlags = {
		disableInMulti = false,
		hideMulti = false,
		dataSaverMulti = 1,
		databaseShowNew = true,
		iconDimensions = {
			ship = {
				width = 128,
				height = 112,
			},
			weapon = {
				width = 112,
				height = 48,
			}
		}
	},
	stateInit = {
		debrief = false,
		select = false,
		loadScreen = false,
		preLoad = false,
	},
	memory = {
		cutscene = "none",
		logSection = 1,
		missionLoaded = false,
		MultiJoinReady = false,
		MultiReady = false,
		WarningCountShown = false,
	},
	render = true,
	tooltipTimers = {},
}

ScpuiOptionValues = {}

--RUN AWAY IT'S FRED!
if ba.inMissionEditor() then
	ScpuiSystem.data.active = nil
	return
end

--keep multiplayer standalone servers lean
if ba.getCurrentMPStatus() == "MULTIPLAYER_STANDALONE" then
	ScpuiSystem.data.active = nil
	return
end

--setting this to true will completely disable SCPUI
if false then
	ScpuiSystem.data.active = nil
	return
end

ScpuiSystem.data.context = rocket:CreateContext("menuui", Vector2i.new(gr.getCenterWidth(), gr.getCenterHeight()));

function ScpuiSystem:init()
	if cf.fileExists("scpui.tbl", "", true) then
		self:parseScpuiTable("scpui.tbl")
	end
	for _, v in ipairs(cf.listFiles("data/tables", "*-ui.tbm")) do
		self:parseScpuiTable(v)
	end

	self:loadSubmodels()
end

function ScpuiSystem:loadSubmodels()
    local scriptDir = "data/scripts"
    local files = cf.listFiles("data/scripts", "*.lua")
	local submodules_prefix = "scpui_sm_"

    if not files then
        return
    end

    for _, filename in ipairs(files) do
        if string.find(filename, submodules_prefix) then -- Check for "scpui_system_"
            local moduleName = filename:match(submodules_prefix .. "(.-).lua")
            if moduleName and moduleName ~= "core" then
                local modulePath = string.format("%s%s", submodules_prefix, moduleName)
                local ok, module = pcall(require, modulePath)
                if ok then
					require(modulePath)
                    ba.print("SCPUI loaded submodel: " .. moduleName .. "\n")
                else
                    ba.print("SCPUI Error loading submodel " .. modulePath .. ": " .. module .. "\n")
                end
            end
        end
    end
end

function ScpuiSystem:parseMedals()
	while parse.optionalString("$Medal:") do
	
		local id = parse.getString()
		
		self.data.medalInfo[id] = {}
		
		if parse.optionalString("+Alt Bitmap:") then
			self.data.medalInfo[id].altBitmap = parse.getString()
		end
		
		if parse.optionalString("+Alt Debrief Bitmap:") then
			self.data.medalInfo[id].altDebriefBitmap = parse.getString()
		end
		
		parse.requiredString("+Position X:")
		self.data.medalInfo[id].x = parse.getFloat()
		
		parse.requiredString("+Position Y:")
		self.data.medalInfo[id].y = parse.getFloat()
		
		parse.requiredString("+Width:")
		self.data.medalInfo[id].w = parse.getFloat()
	
	end
end

function ScpuiSystem:parseScpuiTable(data)
	parse.readFileText(data, "data/tables")
	
	if parse.optionalString("#Settings") then
		
		if parse.optionalString("$Hide Multiplayer:") then
			ScpuiSystem.data.tableFlags.hideMulti = parse.getBoolean()
		end
		
		if parse.optionalString("$Disable during Multiplayer:") then
			ScpuiSystem.data.tableFlags.disableInMulti = parse.getBoolean()
		end
		
		if parse.optionalString("$Data Saver Multiplier:") then
			ScpuiSystem.data.tableFlags.dataSaverMulti = parse.getInt()
		end
		
		if parse.optionalString("$Ship Icon Width:") then
			ScpuiSystem.data.tableFlags.iconDimensions.ship.width = parse.getInt()
		end

		if parse.optionalString("$Ship Icon Height:") then
			ScpuiSystem.data.tableFlags.iconDimensions.ship.height = parse.getInt()
		end

		if parse.optionalString("$Weapon Icon Width:") then
			ScpuiSystem.data.tableFlags.iconDimensions.weapon.width = parse.getInt()
		end

		if parse.optionalString("$Weapon Icon Height:") then
			ScpuiSystem.data.tableFlags.iconDimensions.weapon.height = parse.getInt()
		end
		
		if parse.optionalString("$Show New In Database:") then
			ScpuiSystem.data.tableFlags.databaseShowNew = parse.getBoolean()
		end
		
	end

	if parse.optionalString("#State Replacement") then

	while parse.optionalString("$State:") do
		local state = parse.getString()

		if state == "GS_STATE_SCRIPTING" then
			parse.requiredString("+Substate:")
			local state = parse.getString()
			parse.requiredString("+Markup:")
			local markup = parse.getString()
			ba.print("SCPUI found definition for script substate " .. state .. " : " .. markup .. "\n")
			self.data.replacements[state] = {
				markup = markup
			}
		else
			parse.requiredString("+Markup:")
			local markup = parse.getString()
			ba.print("SCPUI found definition for game state " .. state .. " : " .. markup .. "\n")
			self.data.replacements[state] = {
				markup = markup
			}
		end
	end
	
	if parse.optionalString("#Background Replacement") then
	
		while parse.optionalString("$Campaign Background:") do
			parse.requiredString("+Campaign Filename:")
			local campaign = utils.strip_extension(parse.getString())
			
			parse.requiredString("+RCSS Class Name:")
			local classname = parse.getString()
			
			self.data.backgrounds[campaign] = classname
		end
	
	end
	
	end
	
	if parse.optionalString("#Background Replacement") then
	
		while parse.optionalString("$Campaign Background:") do
			parse.requiredString("+Campaign Filename:")
			local campaign = utils.strip_extension(parse.getString())
			
			parse.requiredString("+RCSS Class Name:")
			local classname = parse.getString()
			
			self.data.backgrounds[campaign] = classname
		end
	
	end
	
	if parse.optionalString("#Briefing Stage Background Replacement") then
	
		while parse.optionalString("$Briefing Grid Background:") do
		
			parse.requiredString("+Mission Filename:")
			local mission = utils.strip_extension(parse.getString())
			
			parse.requiredString("+Default Background Filename:")
			local default_file = parse.getString()
			
			if not utils.hasExtension(default_file) then
				ba.warning("SCPUI parsed background file, " .. default_file .. ", that does not include an extension!")
			end
			
			self.data.briefBackgrounds[mission] = {}
			
			self.data.briefBackgrounds[mission]["default"] = default_file
			
			while parse.optionalString("+Stage Override:") do
				local stage = tostring(parse.getInt())
				
				parse.requiredString("+Background Filename:")
				local file = parse.getString()
				
				if not utils.hasExtension(file) then
					ba.warning("SCPUI parsed background file, " .. default_file .. ", that does not include an extension!")
				end
				
				self.data.briefBackgrounds[mission][stage] = file
			end
			
		end
	
	end
	
	if parse.optionalString("#Medal Placements") then
		ScpuiSystem:parseMedals()
	end
		

	parse.requiredString("#End")

	parse.stop()
end

function ScpuiSystem:getDef(state)
	if self.data.render == false then
		return nil
	end
	return self.data.replacements[state]
end

function ScpuiSystem:cleanSelf()
	ba.print("SCPUI is closing document " .. ScpuiSystem.data.currentDoc.markup .. "\n")
	while ScpuiSystem.data.currentDoc.document:HasChildNodes() do
		ScpuiSystem.data.currentDoc.document:RemoveChild(ScpuiSystem.data.currentDoc.document.first_child)
		ba.print("SCPUI HAS KILLED A CHILD! But that's allowed in America.\n")
	end

	ScpuiSystem.data.currentDoc.document:Close()
	ScpuiSystem.data.currentDoc.document = nil
	ScpuiSystem.data.currentDoc = nil
	ScpuiSystem.data.tooltipTimers = {}
end

function ScpuiSystem:stateStart()

	if ba.MultiplayerMode then
		self.data.render = not ScpuiSystem.data.tableFlags.disableInMulti
	else
		self.data.render = true
	end

	--This allows for states to correctly return to the previous state even if has no rocket ui defined
	ScpuiSystem.data.currentState = ba.getCurrentGameState()
	
	--If hv.NewState is nil then use the Current Game State; This allows for Script UIs to jump from substate to substate
	local state = hv.NewState or ba.getCurrentGameState()
	
	if not self:hasOverrideForState(ScpuiSystem:getRocketUiHandle(state)) then
		ba.print("No SCPUI document defined for " .. ScpuiSystem:getRocketUiHandle(state).Name .. " in scpui.tbl!\n")
		return
	end
	
	--Make sure we're all cleaned up
	if ScpuiSystem.data.currentDoc then
		self:cleanSelf()
	end
	
	ScpuiSystem.data.currentDoc = self:getDef(ScpuiSystem:getRocketUiHandle(state).Name)
	ba.print("SCPUI is loading document " .. ScpuiSystem.data.currentDoc.markup .. "\n")
	ScpuiSystem.data.currentDoc.document = self.data.context:LoadDocument(ScpuiSystem.data.currentDoc.markup)
	ScpuiSystem.data.currentDoc.document:Show()

	ui.enableInput(self.data.context)
end

function ScpuiSystem:stateFrame()
	if not self:hasOverrideForCurrentState() then
		return
	end

	-- Add some tracing scopes here to see how long this stuff takes
	updateCategory:trace(function()
		self.data.context:Update()
	end)
	renderCategory:trace(function()
		self.data.context:Render()
	end)
end

function ScpuiSystem:stateEnd(substate)

	--This allows for states to correctly return to the previous state even if has no rocket ui defined
	ScpuiSystem.data.lastState = ScpuiSystem.data.currentState
	
	--Provide a UI topic for custom mod options to apply user selections
	if hv.OldState.Name == "GS_STATE_INITIAL_PLAYER_SELECT" or hv.OldState.Name == "GS_STATE_OPTIONS_MENU" then
		topics.options.apply:send(nil)
	end

	if not substate then
		if not self:hasOverrideForState(ScpuiSystem:getRocketUiHandle(hv.OldState)) then
			return
		end
	end

	self:cleanSelf()

	ui.disableInput()
	
	if not substate and hv.OldState.Name == "GS_STATE_SCRIPTING" then
		ScpuiSystem.data.substate = "none"
	end
	
	if ba.MultiplayerMode then
		self.data.render = ScpuiSystem.data.tableFlags.disableInMulti
	end
end

function ScpuiSystem:getRocketUiHandle(state)
	if state.Name == "GS_STATE_SCRIPTING" then
		return {Name = ScpuiSystem.data.substate}
	else
		return state
	end
end

function ScpuiSystem:beginSubstate(state) 
	ScpuiSystem.data.oldSubstate = ScpuiSystem.data.substate
	ScpuiSystem.data.substate = state
	--If we're already in GS_STATE_SCRIPTING then force loading the new scpui define
	if ba.getCurrentGameState().Name == "GS_STATE_SCRIPTING" then
		ba.print("Got event SCPUI SCRIPTING SUBSTATE " .. ScpuiSystem.data.substate .. " in SCPUI SCRIPTING SUBSTATE " .. ScpuiSystem.data.oldSubstate .. "\n")
		--We don't actually change game states so we need to manually clean up
		ScpuiSystem:stateEnd(true)
		--Now we can start the new state
		ScpuiSystem:stateStart()
	else
		ba.print("Got event SCPUI SCRIPTING SUBSTATE " .. ScpuiSystem.data.substate .. "\n")
		ba.postGameEvent(ba.GameEvents["GS_EVENT_SCRIPTING"])
	end
end

--This allows for states to correctly return to the previous state even if has no rocket ui defined
function ScpuiSystem:ReturnToState(state)

	local event

	if state.Name == "GS_STATE_BRIEFING" then
		event = "GS_EVENT_START_BRIEFING"
	elseif state.Name == "GS_STATE_VIEW_CUTSCENES" then
		event = "GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"
	elseif state.Name == "GS_STATE_SCRIPTING" then
		ScpuiSystem:beginSubstate(ScpuiSystem.data.oldSubstate)
		return
	else
		event = string.gsub(state.Name, "STATE", "EVENT")
	end

	ba.postGameEvent(ba.GameEvents[event])

end

function ScpuiSystem:hasOverrideForState(state)
	return self:getDef(state.Name) ~= nil
end

function ScpuiSystem:hasOverrideForCurrentState()
	return self:hasOverrideForState(ScpuiSystem:getRocketUiHandle(ba.getCurrentGameState()))
end

function ScpuiSystem:dialogStart()
	local dialogs = require('dialogs')
	if hv.IsDeathPopup then
		self.data.DeathDialog = { Abort = {}, Submit = nil }
	else
		self.data.Dialog = { Abort = {}, Submit = nil }
	end
	local dialog = dialogs.new()
		dialog:title(hv.Title)
		dialog:text(hv.Text)
		dialog:input(hv.IsInputPopup)

		if hv.IsDeathPopup then
			dialog:style(2)
			dialog:text(topics.deathpopup.setText:send(self))
		else
			dialog:escape(-1) --Assuming that all non-death built-in popups can be cancelled safely with a negative response!
		end
	
	for i, button in ipairs(hv.Choices) do
		local positivity = dialogs.BUTTON_TYPE_NEUTRAL
		if button.Positivity == 1 then
			positivity = dialogs.BUTTON_TYPE_POSITIVE
		elseif button.Positivity == -1 then
			positivity = dialogs.BUTTON_TYPE_NEGATIVE
		end
		dialog:button(positivity, button.Text, i - 1, button.Shortcut)
	end
	
	if hv.IsDeathPopup then
		dialog:show(self.data.context, self.data.Dialog.Abort)
			:continueWith(function(response)
				self.data.DeathDialog.Submit = response
			end)
	else
		dialog:show(self.data.context, self.data.Dialog.Abort)
			:continueWith(function(response)
				self.data.Dialog.Submit = response
			end)
	end
	ui.enableInput(self.data.context)
end

function ScpuiSystem:dialogFrame()
	-- Add some tracing scopes here to see how long this stuff takes
	updateCategory:trace(function()
		if hv.Freeze ~= nil and hv.Freeze ~= true then
			self.data.context:Update()
		end
	end)
	renderCategory:trace(function()
		self.data.context:Render()
	end)

	if hv.IsDeathPopup then
		local submit = self.data.DeathDialog.Submit
		if submit == nil and not ScpuiSystem.data.dialog then
			-- We aren't showing a death popup when we should be, which is a softlock;
			-- default to 0 (Quickstart Mission) to get to a state we can proceed from
			submit = 0
		end
		if submit ~= nil then
			self.data.DeathDialog = nil
			hv.Submit(submit)
		end
	else
		if self.data.Dialog.Submit ~= nil then
			local submit = self.data.Dialog.Submit
			self.data.Dialog = nil
			hv.Submit(submit)
		end
	end
end

function ScpuiSystem:dialogEnd()
	ui.disableInput()
	
	if hv.IsDeathPopup then
		if self.data.DeathDialog and self.data.DeathDialog.Abort then
			if self.data.DeathDialog.Abort.Abort then
				self.data.DeathDialog.Abort.Abort()
			end
		end
	else
		if self.data.Dialog and self.data.Dialog.Abort then
			if self.data.Dialog.Abort.Abort then
				self.data.Dialog.Abort.Abort()
			end
		end
	end
	
	self:CloseDialog()
end

function ScpuiSystem:getModTitle()
    local title = ba.getModTitle()
    
    if title == "" then
        title = ba.getModRootName()
        
        -- Extract title up to the first "-"
        local extracted_title = title:match("^(.-)%s*%-")
        if extracted_title then
            title = extracted_title
        end
        
        if title ~= "SCPUI" then
            ba.warning("It is highly recommended that you set a Mod Title in your game settings.tbl!")
        else
            title = "SCPUI Development Mod"
        end
    end
    
    return title
end

function ScpuiSystem:addPreload(message, text, run, val)
	if self.data.preloadCoroutines == nil then
		self.data.preloadCoroutines = {}
	end
	
	local num = #self.data.preloadCoroutines + 1
	
	if val > 1 then
		val = 2
	else
		val = 1
	end
	
	self.data.preloadCoroutines[num] = {
		debugMessage = message,
		debugString = text,
		func = run,
		priority = val
	}
end	

function ScpuiSystem:CloseDialog()
	if ScpuiSystem.data.dialog ~= nil then
		ba.print("SCPUI is closing dialog `" .. ScpuiSystem.data.dialog.title .. "`\n")
		ScpuiSystem.data.dialog:Close()
		ScpuiSystem.data.dialog = nil
	end
	
	local state = hv.NewState or ba.getCurrentGameState()
	
	--If we're going back to an SCPUI state, then give it control
	--Otherwise cede control back to FSO
	if self:hasOverrideForState(ScpuiSystem:getRocketUiHandle(state)) then
		ui.enableInput(self.data.context)
	else
		ui.disableInput()
	end
end

function ScpuiSystem:loadStart()

	if ScpuiSystem.data.stateInit.loadScreen then
		return
	end

	if ba.MultiplayerMode then
		ScpuiSystem.data.render = not ScpuiSystem.data.tableFlags.disableInMulti
	else
		ScpuiSystem.data.render = true
	end
	
	if not self:hasOverrideForState({Name = "LOAD_SCREEN"}) then
		return
	end
	
	ScpuiSystem.data.loadDoc = self:getDef("LOAD_SCREEN")
	ba.print("SCPUI is loading document " .. ScpuiSystem.data.loadDoc.markup .. "\n")
	ScpuiSystem.data.loadDoc.document = self.data.context:LoadDocument(ScpuiSystem.data.loadDoc.markup)
	ScpuiSystem.data.loadDoc.document:Show(DocumentFocus.FOCUS)

	--ui.enableInput(self.data.context)
	
	ScpuiSystem.data.loadProgress = 0
	ScpuiSystem.data.stateInit.loadScreen = true
end

function ScpuiSystem:loadFrame()
	if ScpuiSystem.data.stateInit.loadScreen == nil then
		return
	end
	
	ScpuiSystem.data.loadProgress = hv.Progress
	
	--ba.warning(hv.Progress)

	-- Add some tracing scopes here to see how long this stuff takes
	updateCategory:trace(function()
		self.data.context:Update()
	end)
	renderCategory:trace(function()
		self.data.context:Render()
	end)
end

function ScpuiSystem:loadEnd(substate)

	if ScpuiSystem.data.stateInit.loadScreen == nil then
		return
	end

	self:CloseLoadScreen()

	--ui.disableInput()
	ScpuiSystem.data.loadProgress = nil
	ScpuiSystem.data.stateInit.loadScreen = nil
end

function ScpuiSystem:CloseLoadScreen()
	if ScpuiSystem.data.loadDoc ~= nil then
		ba.print("SCPUI is closing loading screen\n")
		ScpuiSystem.data.loadDoc.document:Close()
		ScpuiSystem.data.loadDoc = nil
	end
	
	local state = hv.NewState or ba.getCurrentGameState()
	
	--If we're going back to an SCPUI state, then give it control
	--Otherwise cede control back to FSO
	if self:hasOverrideForState(ScpuiSystem:getRocketUiHandle(state)) then
		ui.enableInput(self.data.context)
	else
		ui.disableInput()
	end
end

ScpuiSystem:init()

--Core Ui Takeover

engine.addHook("On State Start", function()
	ScpuiSystem:stateStart()
end, {}, function()
	return ScpuiSystem:hasOverrideForState(ScpuiSystem:getRocketUiHandle(hv.NewState))
end)

engine.addHook("On Frame", function()
	ScpuiSystem:stateFrame()
end, {}, function()
	return ScpuiSystem:hasOverrideForCurrentState()
end)

engine.addHook("On State End", function()
	ScpuiSystem:stateEnd()
end, {}, function()
	return ScpuiSystem:hasOverrideForState(ScpuiSystem:getRocketUiHandle(hv.OldState))
end)

--Dialog Takeover

engine.addHook("On Dialog Init", function()
	if ScpuiSystem.data.render == true then
		ScpuiSystem:dialogStart()
	end
end, {}, function()
	return ScpuiSystem.data.render
end)

engine.addHook("On Dialog Frame", function()
	if ScpuiSystem.data.render == true then
		ScpuiSystem:dialogFrame()
	end
end, {}, function()
	return ScpuiSystem.data.render
end)

engine.addHook("On Dialog Close", function()
	if ScpuiSystem.data.render == true then
		ScpuiSystem:dialogEnd()
	end
end, {}, function()
	return ScpuiSystem.data.render
end)

--Load Screen Takeover

engine.addHook("On Load Screen", function()
	ScpuiSystem:loadStart()
end, {}, function()
	return ScpuiSystem:hasOverrideForState({Name = "LOAD_SCREEN"})
end)

engine.addHook("On Load Screen", function()
	ScpuiSystem:loadFrame()
end, {}, function()
	return ScpuiSystem:hasOverrideForState({Name = "LOAD_SCREEN"})
end)

engine.addHook("On Load Complete", function()
	ScpuiSystem:loadEnd()
end, {}, function()
	return ScpuiSystem:hasOverrideForState({Name = "LOAD_SCREEN"})
end)

--Helpers

engine.addHook("On Load Screen", function()
	ScpuiSystem.data.memory.missionLoaded = true
end, {}, function()
	return false
end)

engine.addHook("On Mission End", function()
	ScpuiSystem.data.memory.missionLoaded = false
end, {}, function()
	return false
end)
