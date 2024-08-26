local class = require("class")
local topics = require("ui_topics")

local GamehelpController = class()

function GamehelpController:init()
end

function GamehelpController:initialize(document)

    self.document = document

	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	if mn.isInMission() then
		ScpuiSystem:pauseAllAudio(true)
	end
	
	ui.GameHelp.initGameHelp()
	
	self.numSections = #ui.GameHelp.Help_Sections
	if ScpuiSystem.hideMulti then
		self.numSections = self.numSections - 1
	end
	self.sections = {}
	
	local count = 1
	for i = 1, #ui.GameHelp.Help_Sections do
		if ui.GameHelp.Help_Sections[i].Title == 'Multiplayer Keys' and ScpuiSystem.hideMulti then
			--Skip adding the multi keys
		else
			self.sections[count] = {
				Title = nil,
				Subtitle = nil,
				Header = nil,
				Keys = {},
				Texts = {}
			}
			self.sections[count].Title = ui.GameHelp.Help_Sections[i].Title
			self.sections[count].Subtitle = "Page " .. count .. " of " .. self.numSections
			self.sections[count].Header = ui.GameHelp.Help_Sections[i].Header
			self.sections[count].Keys = ui.GameHelp.Help_Sections[i].Keys
			self.sections[count].Texts = ui.GameHelp.Help_Sections[i].Texts
			
			count = count + 1
		end
	end
	
	ui.GameHelp.closeGameHelp()
	
	topics.gamehelp.initialize:send(self)
	
	self:ChangeSection(1)
	
end

function GamehelpController:ChangeSection(section)

	self.currentSection = section
	self:CreateEntries(section)
	self.document:GetElementById("gamehelp_title").inner_rml = self.sections[section].Title
	self.document:GetElementById("gamehelp_subtitle").inner_rml = self.sections[section].Subtitle
	self.document:GetElementById("gamehelp_header").inner_rml = self.sections[section].Header
	
end

function GamehelpController:CreateEntries(section)

	local list_el = self.document:GetElementById("list_keys_ul")

	ScpuiSystem:ClearEntries(list_el)
	
	for i = 1, #self.sections[self.currentSection].Keys do
		local line = self.sections[self.currentSection].Keys[i]
		local li_el = self.document:CreateElement("li")
		li_el.inner_rml = line
		list_el:AppendChild(li_el)
	end
	
	local list_el = self.document:GetElementById("list_texts_ul")

	ScpuiSystem:ClearEntries(list_el)
	
	for i = 1, #self.sections[self.currentSection].Texts do
		local line = self.sections[self.currentSection].Texts[i]
		local li_el = self.document:CreateElement("li")
		li_el.inner_rml = line
		list_el:AppendChild(li_el)
	end
end

function GamehelpController:DecrementSection(element)

    if self.currentSection == 1 then
		self:ChangeSection(self.numSections)
	else
		self:ChangeSection(self.currentSection - 1)
	end

end

function GamehelpController:IncrementSection(element)

    if self.currentSection == self.numSections then
		self:ChangeSection(1)
	else
		self:ChangeSection(self.currentSection + 1)
	end

end

function GamehelpController:Exit(element)

    ui.playElementSound(element, "click", "success")
	if mn.isInMission() then
		ScpuiSystem:pauseAllAudio(false)
	end
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])

end

function GamehelpController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()
		if mn.isInMission() then
			ScpuiSystem:pauseAllAudio(false)
		end
		ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

return GamehelpController
