
ba.print("ui_system")

local RocketUiSystem = {
    replacements = {}
}

RocketUiSystem.context = rocket:CreateContext("menuui", Vector2i.new(gr.getCenterWidth(), gr.getCenterHeight()));

function RocketUiSystem:init()
    for _, v in ipairs(cf.listFiles("data/config", "*-ui.cfg")) do
        parse.readFileText(v, "data/config")

        parse.requiredString("#State Replacement")

        while parse.optionalString("$State:") do
            local state = parse.getString()

            parse.requiredString("+Markup:")

            local markup = parse.getString()

            self.replacements[state] = {
                markup = markup
            }
        end

        parse.requiredString("#End")

        parse.stop()
    end
end

function RocketUiSystem:getDef(state)
    return self.replacements[state]
end

function RocketUiSystem:stateStart()
    if not self:hasOverrideForState(hv.NewState) then
        return
    end

    local def = self:getDef(hv.NewState.Name)
    def.document = self.context:LoadDocument(def.markup)
    def.document:Show()

    ui.enableInput(self.context)
end

function RocketUiSystem:stateFrame()
    if not self:hasOverrideForCurrentState() then
        return
    end

    self.context:Update()
    self.context:Render()
end

function RocketUiSystem:stateEnd()
    if not self:hasOverrideForState(hv.OldState) then
        return
    end

    local def = self:getDef(hv.OldState.Name)

    def.document:Close()
    def.document = nil

    ui.disableInput()
end

function RocketUiSystem:hasOverrideForState(state)
    return self:getDef(state.Name) ~= nil
end

function RocketUiSystem:hasOverrideForCurrentState()
    return self:hasOverrideForState(ba.getCurrentGameState())
end

RocketUiSystem:init()

engine.addHook("On State Start", function()
    RocketUiSystem:stateStart()
end, {}, function()
    return RocketUiSystem:hasOverrideForState(hv.NewState)
end)

engine.addHook("On Frame", function()
    RocketUiSystem:stateFrame()
end, {}, function()
    return RocketUiSystem:hasOverrideForCurrentState()
end)

engine.addHook("On State End", function()
    RocketUiSystem:stateEnd()
end, {}, function()
    return RocketUiSystem:hasOverrideForState(hv.OldState)
end)

