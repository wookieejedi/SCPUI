local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")
local async_util = require("async_util")
local utils = require("utils")

local PXOHelpController = class(AbstractBriefingController)

function PXOHelpController:init()

end

function PXOHelpController:initialize(document)
	
	self.document = document
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	local text = ui.MultiPXO.getHelpText()
	local fullHelp = ""
	for i = 1, #text do
		fullHelp = fullHelp .. ScpuiSystem:replaceAngleBrackets(text[i]) .. "<br/>"
	end
	self.help_el = self.document:GetElementById("help_div")
	self.help_el.inner_rml = fullHelp
	
	self:updateLists()
	ui.MultiGeneral.setPlayerState()
	
	topics.multipxohelp.initialize:send(self)

end

function PXOHelpController:exit()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PXO"])
end

function PXOHelpController:accept_pressed()
	self:exit()
end

function PXOHelpController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
       self:exit()
	end
end

function PXOHelpController:updateLists()
	ui.MultiPXO.runNetwork()
	
	async.run(function()
        async.await(async_util.wait_for(0.01))
        self:updateLists()
    end, async.OnFrameExecutor)
	
end

function PXOHelpController:unload()
	topics.multipxohelp.unload:send(self)
end

return PXOHelpController
