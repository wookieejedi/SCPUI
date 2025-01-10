-----------------------------------
--Controller for the Command Briefing UI
-----------------------------------

local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local AbstractBriefingController = require("ctrlr_briefing_common")

--- Briefing controller is merged with the Briefing Common Controller
local CommandBriefingController = Class(AbstractBriefingController)

--- Called by the class constructor
--- @return nil
function CommandBriefingController:init()

    --- Check if we should play a cutscene before the command briefing
	if not ScpuiSystem.data.memory.CutscenePlayed then
		ScpuiSystem:maybePlayCutscene(MOVIE_PRE_CMD_BRIEF)
	end
	ScpuiSystem.data.memory.CutscenePlayed = true

    --- Now initialize all our variables
    self.Stages_List = {} --- @type cmd_briefing_stage[] The stages of the command briefing
    self.HelpShown = false --- @type boolean Whether the help text is shown or not
    self.Document = nil --- @type Document The RML document

    --- @type scpui_brief_element_list List of ui element names for player control of the stages
    self.Element_Names = {
        PauseBtn = "cmdpause_btn",
        LastBtn = "cmdlast_btn",
        NextBtn = "cmdnext_btn",
        PrevBtn = "cmdprev_btn",
        FirstBtn = "cmdfirst_btn",
        TextEl = "cmd_text_el",
        StageTextEl = "cmd_stage_text_el",
    }

end

--- Called by the RML document
--- @param document Document
function CommandBriefingController:initialize(document)
    AbstractBriefingController.initialize(self, document)

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

    local briefing = ui.CommandBriefing.getCmdBriefing()

    for i = 1, #briefing do
		local stage = briefing[i]

		self.Stages_List[i] = Topics.cmdbriefing.stage:send({stage, i})
    end

	Topics.cmdbriefing.initialize:send(self)

    AbstractBriefingController.goToStage(self, 1)
end

--- The help button was clicked
--- @return nil
function CommandBriefingController:help_clicked()
    self.HelpShown  = not self.HelpShown

    local help_texts = self.Document:GetElementsByClassName("tooltip")
    for _, v in ipairs(help_texts) do
        v:SetPseudoClass("shown", self.HelpShown)
    end
end

return CommandBriefingController
