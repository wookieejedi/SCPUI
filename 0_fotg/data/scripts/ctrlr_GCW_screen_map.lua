-----------------------------------
--Controller for the GCW Map UI
-----------------------------------

local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local GCW_Screen_Map = Class()

--- Called by the class constructor
--- @return nil
function GCW_Screen_Map:init()
	self.Document = nil ---@type Document The RML document
end

--- Called by the RML document
--- @param document Document
function GCW_Screen_Map:initialize(document)

    self.Document = document

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

end

--- The exit button was clicked
--- @param element Element The element that triggered the event
--- @return nil
function GCW_Screen_Map:exit(element)

    ui.playElementSound(element, "click", "success")
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])

end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function GCW_Screen_Map:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
		ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

--- Called when the screen is being unloaded
--- @return nil
function GCW_Screen_Map:unload()
	Topics.gamehelp.unload:send(self)
end

return GCW_Screen_Map
