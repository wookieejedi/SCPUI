local dialogs = require("dialogs")
local class = require("class")
local async_util = require("async_util")

--local AbstractBriefingController = require("briefingCommon")

--local BriefingController = class(AbstractBriefingController)

local ShipSelectController = class()

function ShipSelectController:init()
end

function ShipSelectController:initialize(document)
    --AbstractBriefingController.initialize(self, document)
	self.document = document

	---Load the desired font size from the save file
	if modOptionValues.Font_Multiplier then
		fontChoice = modOptionValues.Font_Multiplier
		self.document:GetElementById("main_background"):SetClass(("p1-" .. fontChoice), true)
	else
		self.document:GetElementById("main_background"):SetClass("p1-5", true)
	end
	
	ui.ShipWepSelect.initSelect()
	
	local loadout = ui.ShipWepSelect.Loadout_Wings[1]
	--ba.warning(#ui.ShipWepSelect.Loadout_Wings .. " " .. loadout.Name)
	one = loadout[1]
	two = loadout[2]
	three = loadout[3]
	four = loadout[4]
	
	local all = ""
	
	local i = 1
	while (i < 5) do
		all = all .. tostring(loadout[i].isDisabled) .. " "
		i = i + 1
	end
	
	ba.warning(all)
	
	local all = ""
	
	local i = 1
	while (i < 5) do
		local idx = loadout[i].ShipClassIndex
		local name = tb.ShipClasses[idx].Name
		all = all .. name .. " "
		i = i + 1
	end
	
	ba.warning(all)

end

function ShipSelectController:ChangeBriefState(state)
	if state == 1 then
		ba.postGameEvent(ba.GameEvents["GS_EVENT_START_BRIEFING"])
	elseif state == 2 then
		--Do nothing because we're this is the current state!
	elseif state == 3 then
		if mn.isScramble() then
			ad.playInterfaceSound(10)
		else
			ba.postGameEvent(ba.GameEvents["GS_EVENT_WEAPON_SELECTION"])
		end
	end
end

function ShipSelectController:DragOver(element)
	self.replace = element
end

function ShipSelectController:DragEnd(element)
	local replace_el = self.document:GetElementById(self.replace.id)
	local icon_el = self.document:GetElementById(element.id)
	local imgEl = self.document:CreateElement("img")
	imgEl:SetAttribute("src", icon_el.first_child:GetAttribute("src"))
	self.document:GetElementById(replace_el.id):RemoveChild(replace_el.first_child)
	self.document:GetElementById(replace_el.id):AppendChild(imgEl)
end

function ShipSelectController:acceptPressed()
    
	drawMap = nil
	--ba.postGameEvent(ba.GameEvents["GS_EVENT_ENTER_GAME"])
	ui.Briefing.commitToMission()

end

function ShipSelectController:skip_pressed()
    
	if mn.isTraining() then
		ui.Briefing.skipTraining()
	elseif mn.isInCampaignLoop() then
		ui.Briefing.exitLoop()
	elseif mn.isMissionSkipAllowed() then
		ui.Briefing.skipMission()
	end

end

function ShipSelectController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
	--elseif event.parameters.key_identifier == rocket.key_identifier.UP and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(3)
	--elseif event.parameters.key_identifier == rocket.key_identifier.DOWN and event.parameters.ctrl_key == 1 then
	--	self:ChangeTechState(1)
	end
end

function ShipSelectController:unload()
	
end

return ShipSelectController
