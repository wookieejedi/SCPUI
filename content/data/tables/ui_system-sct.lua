local utils = require("utils")

local updateCategory = engine.createTracingCategory("UpdateRocket", false)
local renderCategory = engine.createTracingCategory("RenderRocket", true)

ScpuiSystem = {
    replacements = {},
	substate = "none",
	cutscene = "none",
	debriefInit = false,
	selectInit = false,
	shipSelectInit = false,
	music_handle = nil,
	current_played = nil,
	debrief_music = nil,
	initIcons = nil,
	logSection = 1,
	render = true,
	dialog = nil
}

ScpuiOptionValues = {}

--RUN AWAY IT'S FRED!
if ba.inMissionEditor() then
	return
end

--setting this to true will completely disable SCPUI
if false then
	return
end

ScpuiSystem.context = rocket:CreateContext("menuui", Vector2i.new(gr.getCenterWidth(), gr.getCenterHeight()));

function ScpuiSystem:init()
	if cf.fileExists("scpui.tbl") then
        self:parseTable("scpui.tbl")
    end
    for _, v in ipairs(cf.listFiles("data/tables", "*-ui.tbm")) do
        self:parseTable(v)
    end
end

function ScpuiSystem:parseTable(data)
	parse.readFileText(data, "data/tables")

	parse.requiredString("#State Replacement")

	while parse.optionalString("$State:") do
		local state = parse.getString()

		if state == "GS_STATE_SCRIPTING" then
			parse.requiredString("+Substate:")
			local state = parse.getString()
			parse.requiredString("+Markup:")
			local markup = parse.getString()
			ba.print("SCPUI found definition for script substate " .. state .. " : " .. markup .. "\n")
			self.replacements[state] = {
				markup = markup
			}
		else
			parse.requiredString("+Markup:")
			local markup = parse.getString()
			ba.print("SCPUI found definition for game state " .. state .. " : " .. markup .. "\n")
			self.replacements[state] = {
				markup = markup
			}
		end
	end

	parse.requiredString("#End")

	parse.stop()
end

function ScpuiSystem:getDef(state)
	if self.render == false then
		return nil
	end
    return self.replacements[state]
end

function ScpuiSystem:stateStart()

	if not ba.MultiplayerMode then
		self.render = true
	end

	--This allows for states to correctly return to the previous state even if has no rocket ui defined
	ScpuiSystem.currentState = ba.getCurrentGameState()
	
	--If hv.NewState is nil then use the Current Game State; This allows for Script UIs to jump from substate to substate
	local state = hv.NewState or ba.getCurrentGameState()
	
    if not self:hasOverrideForState(getRocketUiHandle(state)) then
        return
    end

    local def = self:getDef(getRocketUiHandle(state).Name)
    def.document = self.context:LoadDocument(def.markup)
    def.document:Show()

    ui.enableInput(self.context)
end

function ScpuiSystem:stateFrame()
    if not self:hasOverrideForCurrentState() then
        return
    end

    -- Add some tracing scopes here to see how long this stuff takes
    updateCategory:trace(function()
        self.context:Update()
    end)
    renderCategory:trace(function()
        self.context:Render()
    end)
end

function ScpuiSystem:stateEnd()

	--This allows for states to correctly return to the previous state even if has no rocket ui defined
	ScpuiSystem.lastState = ScpuiSystem.currentState

    if not self:hasOverrideForState(getRocketUiHandle(hv.OldState)) then
        return
    end

    local def = self:getDef(getRocketUiHandle(hv.OldState).Name)
	
	--def.document:Close() seems to be bugged and can't reliably clean up all child elements.
	--This is most noticeable on game exit when the issue cases a CTD.
	--So let's just sweep the floor a little bit before we close the document to help it along.
	while def.document:HasChildNodes() do
		def.document:RemoveChild(def.document.first_child)
	end

    def.document:Close()
    def.document = nil

    ui.disableInput()
	
	if hv.OldState.Name == "GS_STATE_SCRIPTING" then
		ScpuiSystem.substate = "none"
	end
	
	if ba.MultiplayerMode then
		self.render = false
	end
end

function getRocketUiHandle(state)
    if state.Name == "GS_STATE_SCRIPTING" then
        return {Name = ScpuiSystem.substate}
    else
        return state
    end
end

function ScpuiSystem:beginSubstate(state) 
	local oldSubstate = ScpuiSystem.substate
	ScpuiSystem.substate = state
	--If we're already in GS_STATE_SCRIPTING then force loading the new scpui define
	if ba.getCurrentGameState().Name == "GS_STATE_SCRIPTING" then
		ba.print("Got event SCPUI SCRIPTING SUBSTATE " .. ScpuiSystem.substate .. " in SCPUI SCRIPTING SUBSTATE " .. oldSubstate .. "\n")
		ScpuiSystem:stateStart()
	else
		ba.print("Got event SCPUI SCRIPTING SUBSTATE " .. ScpuiSystem.substate .. "\n")
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
	else
		event = string.gsub(state.Name, "STATE", "EVENT")
	end

	ba.postGameEvent(ba.GameEvents[event])

end

function ScpuiSystem:hasOverrideForState(state)
    return self:getDef(state.Name) ~= nil
end

function ScpuiSystem:hasOverrideForCurrentState()
    return self:hasOverrideForState(getRocketUiHandle(ba.getCurrentGameState()))
end

function ScpuiSystem:dialogStart()
    ui.enableInput(self.context)
    
    local dialogs = require('dialogs')
	if hv.IsDeathPopup then
		self.DeathDialog = { Abort = {}, Submit = nil }
	else
		self.Dialog = { Abort = {}, Submit = nil }
	end
    local dialog = dialogs.new()
        dialog:title(hv.Title)
        dialog:text(hv.Text)
		dialog:input(hv.IsInputPopup)

		if hv.IsDeathPopup then
			dialog:style(2)
		else
			dialog:escape(-1) --Assuming that all non-death built-in popups can be cancelled safely with a negative response!
		end
    
    for i, button in ipairs(hv.Choices) do
        local positivity = nil
        if button.Positivity == 0 then
            positivity = dialogs.BUTTON_TYPE_NEUTRAL
        elseif button.Positivity == 1 then
            positivity = dialogs.BUTTON_TYPE_POSITIVE
        elseif button.Positivity == -1 then
            positivity = dialogs.BUTTON_TYPE_NEGATIVE
        end
        dialog:button(positivity, button.Text, i - 1, button.Shortcut)
    end
	
	if hv.IsDeathPopup then
		dialog:show(self.context, self.DialogAbort)
			:continueWith(function(response)
				self.DeathDialog.Submit = response
			end)
	else
		dialog:show(self.context, self.DialogAbort)
			:continueWith(function(response)
				self.Dialog.Submit = response
			end)
	end
end

function ScpuiSystem:dialogFrame()
    -- Add some tracing scopes here to see how long this stuff takes
    updateCategory:trace(function()
		if hv.Freeze ~= nil and hv.Freeze ~= true then
			self.context:Update()
		end
    end)
    renderCategory:trace(function()
        self.context:Render()
    end)
	
	--So that the skip mission popup can re-enable the death popup on dialog end
	if self.Reenable ~= nil and self.Reenable == true then
		ui.enableInput(self.context)
		self.Reenable = nil
	end
		
    
	if hv.IsDeathPopup then
		if self.DeathDialog.Submit ~= nil then
			local submit = self.DeathDialog.Submit
			self.DeathDialog = nil
			hv.Submit(submit)
		end
	else
		if self.Dialog.Submit ~= nil then
			local submit = self.Dialog.Submit
			self.Dialog = nil
			hv.Submit(submit)
		end
	end
end

function ScpuiSystem:dialogEnd()
    ui.disableInput(self.context)
	
	if not hv.IsDeathPopup then
		self.Reenable = true
	end

	if hv.IsDeathPopup then
		if self.DeathDialog ~= nil and self.DeathDialog.Abort ~= nil then
			self.DeathDialog.Abort.Abort()
		end
	else
		if self.Dialog ~= nil and self.Dialog.Abort ~= nil then
			self.Dialog.Abort.Abort()
		end
	end
	
	self:CloseDialog()
end

function ScpuiSystem:getFontSize(val)
	-- If we have don't have val, then get the stored one
	if val == nil then
		if ScpuiOptionValues == nil then
			ba.warning("Cannot get font size before SCPUI is initialized! Using default.")
			return 5
		else
			val = ScpuiOptionValues.Font_Multiplier
			
			-- If value is not set then use default
			if val == nil then
				return 5
			end
		end
	end
	
	-- Make sure val is a number
	val = tonumber(val)
	if val == nil then
		ba.warning("SCPUI got invalid data for Font Multiplier! Using default.")
		return 5
	end
	
	-- If value is greater than 1, then it's an old style and we can just return it directly
	-- But math.floor it just in case.
	if val > 1.0 then
		return math.floor(val)
	end
	
	-- Range check
	if val < 0.0 then
        val = 0.0
    elseif val > 1.0 then
        val = 1.0
    end

    -- Perform the conversion
    local convertedValue = 1 + (val * 19)
    return math.floor(convertedValue)
end

function ScpuiSystem:CloseDialog()
	if ScpuiSystem.dialog ~= nil then
		ba.print("SCPUI is closing dialog `" .. ScpuiSystem.dialog.title .. "`\n")
		ScpuiSystem.dialog:Close()
		ScpuiSystem.dialog = nil
	end
end

ScpuiSystem:init()

engine.addHook("On State Start", function()
	ScpuiSystem:stateStart()
end, {}, function()
    return ScpuiSystem:hasOverrideForState(getRocketUiHandle(hv.NewState))
end)

engine.addHook("On Frame", function()
	ScpuiSystem:stateFrame()
end, {}, function()
    return ScpuiSystem:hasOverrideForCurrentState()
end)

engine.addHook("On State End", function()
	ScpuiSystem:stateEnd()
end, {}, function()
    return ScpuiSystem:hasOverrideForState(getRocketUiHandle(hv.OldState))
end)

engine.addHook("On Dialog Init", function()
	if ScpuiSystem.render == true then
		ScpuiSystem:dialogStart()
	end
end, {}, function()
    return ScpuiSystem.render
end)

engine.addHook("On Dialog Frame", function()
	if ScpuiSystem.render == true then
		ScpuiSystem:dialogFrame()
	end
end, {}, function()
    return ScpuiSystem.render
end)

engine.addHook("On Dialog Close", function()
	if ScpuiSystem.render == true then
		ScpuiSystem:dialogEnd()
	end
end, {}, function()
    return ScpuiSystem.render
end)

