-----------------------------------
--Controller for the Medals UI
-----------------------------------

local Topics = require("lib_ui_topics")

local Class = require("lib_class")

local MedalsController = Class()

--- Called by the class constructor
--- @return nil
function MedalsController:init()
	self.Document = nil --- @type Document The RML document
	self.PlayerMedals = nil --- @type table<number, number> The player's medals
	self.PlayerRank = nil --- @type string The player's rank
	self.PlayerName = nil --- @type string The player's name
	self.RibbonCounts = nil --- @type table<string, number> The number of ribbons from each source
	self.RibbonColumn = nil --- @type number The current column for ribbons

	ScpuiSystem.data.memory.medal_text = {
		Name = nil,
		X = 0,
		Y = 0
	}
end

--- Called by the RML document
--- @param document Document
function MedalsController:initialize(document)

	self.Document = document
	self.RibbonColumn = 1

	--This will reparse the medal info data in SCPUI's tables to make positioning medals
	--easier. Basically this makes it so ctrl-shift-r will allow reflecting table data
	--changes without having to restart the entire game.
	self:reparseTableData()

	---Load background choice
	self.Document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)

	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

	self.PlayerMedals = ba.getCurrentPlayer().Stats.Medals
	self.PlayerRank = ba.getCurrentPlayer().Stats.Rank.Name
	self.PlayerName = ba.getCurrentPlayer():getName()

	for i = 1, #self.PlayerMedals do
		self:buildMedalDiv(i)
	end

	for i = 1, #self.PlayerMedals do
		if self.PlayerMedals[i] > 0 then
			self:showMedal(i)
		end

		--rank can be zero
		if ui.Medals.Medals_List[i].Name == "Rank" then
			self:showMedal(i)
		end
	end

	self.Document:GetElementById("medals_text").inner_rml = self.PlayerName

	ScpuiSystem:loadRibbonsFromFile()

	table.sort(ScpuiSystem.data.Player_Ribbons, function(a, b)
        return a.Name < b.Name
    end)

	self.RibbonCounts = {}
	for i = 1, #ScpuiSystem.data.Player_Ribbons do
		self:buildRibbonDiv(i)
	end

	Topics.medals.initialize:send(self)

	self:change_view(false)

end

--- Force reparsing of the medal info data in SCPUI's tables
--- @return nil
function MedalsController:reparseTableData()
	ScpuiSystem.data.Medal_Info = {}
	if cf.fileExists("scpui.tbl") then
        self:parseMedalInfo("scpui.tbl")
    end
    for _, v in ipairs(cf.listFiles("data/tables", "*-ui.tbm")) do
        self:parseMedalInfo(v)
    end
end

--- Parse the medals section of a table file, skipping to it
function MedalsController:parseMedalInfo(data)
	parse.readFileText(data, "data/tables")

	if parse.skipToString("#Medal Placements") then

		ScpuiSystem:parseMedals()

	end

	parse.stop()
end

--- Check if a medal is a badge
--- @param medal medal The medal to check
function MedalsController:isBadge(medal)
	return (medal.KillsNeeded > 0)
end

--- Check if a medal is a rank
--- @param medal medal The medal to check
function MedalsController:isRank(medal)
	return medal:isRank()
end

--- Get the medal info for a given id from SCPUI's medal data
--- @param id string The id of the medal
--- @return medal_info medal The medal info
function MedalsController:getMedalInfo(id)
	local info = ScpuiSystem.data.Medal_Info[id]

	if info == nil then
		info = {
			X = 0,
			Y = 0,
			W = 10
		}
	end

	return info
end

--- Create a div element for a medal, placing it in the correct position. Defaults to setting the image as the empty version
--- @param idx number The index of the medal in the list
--- @return nil
function MedalsController:buildMedalDiv(idx)
	local medal = ui.Medals.Medals_List[idx]

	local parent_el = self.Document:GetElementById("medals_wrapper_actual")

	local id = string.lower(medal.Bitmap:match("(.+)%..+$"))
	local info = self:getMedalInfo(medal.Name)

	local medal_el = self.Document:CreateElement("div")
	medal_el.id = id
	medal_el:SetClass("medal", true)
	medal_el.style.position = "absolute"
	medal_el.style.width = info.W .. "%"
	medal_el.style.top = info.Y .. "%"
	medal_el.style.left = info.X .. "%"

	local filename = id
	if info.AltBitmap then
		filename = info.AltBitmap
	end

	local img_el = self.Document:CreateElement("img")
	img_el:SetAttribute("src", filename .. "_00.png")

	medal_el:AppendChild(img_el)
	parent_el:AppendChild(medal_el)
end

--- If the player has earned one or more of the medal then replace the image with the earned version and setup the mouseover listeners
--- @param idx number The index of the medal in the list
--- @return nil
function MedalsController:showMedal(idx)

	local medal = ui.Medals.Medals_List[idx]

	--get the div
	local medal_el = self.Document:GetElementById(string.lower(medal.Bitmap:match("(.+)%..+$")))
	local info = self:getMedalInfo(medal.Name)
	local filename = medal_el.id
	if info.AltBitmap then
		filename = info.AltBitmap
	end

	--create new image element based on number earned
	local img_el = self.Document:CreateElement("img")

	local num = math.min(self.PlayerMedals[idx], ui.Medals.Medals_List[idx].NumMods)

	--create the display string
	local display = medal.Name
	if num > 1 then
		display = medal.Name .. " (" .. self.PlayerMedals[idx] .. ")"
	end

	--rank is special because reasons
	if medal.Name == "Rank" then
		num = num + 1
		display = self.PlayerRank
	end

	--now setup for the png name
	local num_string = "_" .. self:setupCountString(num)

	--Special access to the png id for external scripts
	num_string = Topics.medals.setRankBitmap:send({medal.Name, num_string})

	filename = filename .. num_string .. ".png"

	img_el:SetAttribute("src", filename)

	--replace the old image
	medal_el:ReplaceChild(img_el, medal_el.first_child)

	--add mouseover listener
	medal_el:AddEventListener("mouseover", function()
		ScpuiSystem.data.memory.medal_text.Name = display
	end)

	medal_el:AddEventListener("mouseout", function()
		ScpuiSystem.data.memory.medal_text.Name = nil
	end)
end

--- Setup the count string for the medal image. If the number is less than 10 then add a leading zero
--- @param num number The number to format
--- @return string r_string The formatted string
function MedalsController:setupCountString(num)
	local r_string
	if num < 10 then
		r_string = "0" .. num
	else
		r_string = tostring(num)
	end
	return r_string
end

--- Create a div element for a ribbon, placing it in the correct position
--- @param idx number The index of the ribbon in the list
--- @return nil
function MedalsController:buildRibbonDiv(idx)
	local ribbon = ScpuiSystem.data.Player_Ribbons[idx]

	if not self.RibbonCounts[ribbon.Source] then
		self.RibbonCounts[ribbon.Source] = 1
	else
		self.RibbonCounts[ribbon.Source] = self.RibbonCounts[ribbon.Source] + 1
	end

	-- Don't display more than 5 ribbons from a single game
	if self.RibbonCounts[ribbon.Source] > 5 then return end

	local img = ScpuiSystem:createRibbonImage(ribbon)

	local parent_id = "ribbon_column_" .. self.RibbonColumn
	self.RibbonColumn = self.RibbonColumn + 1
	if self.RibbonColumn > 5 then
		self.RibbonColumn = 1
	end

	local parent_el = self.Document:GetElementById(parent_id)

	local ribbon_el = self.Document:CreateElement("div")
	ribbon_el.id = "ribbon_" .. idx
	ribbon_el:SetClass("ribbon", true)

	--add mouseover listener
	ribbon_el:AddEventListener("mouseover", function()
		ScpuiSystem.data.memory.medal_text.Name = ribbon.Description
	end)

	ribbon_el:AddEventListener("mouseout", function()
		ScpuiSystem.data.memory.medal_text.Name = nil
	end)

	local img_el = self.Document:CreateElement("img")
	img_el:SetAttribute("src", img)

	local title_el = self.Document:CreateElement("p")
	title_el.inner_rml = ribbon.Name

	ribbon_el:AppendChild(img_el)
	ribbon_el:AppendChild(title_el)
	parent_el:AppendChild(ribbon_el)
end

--- Called by the RML to toggle between medals and ribbons. True for ribbons, false for medals
--- @param toggle boolean The toggle value
--- @return nil
function MedalsController:change_view(toggle)
	local medal_el = self.Document:GetElementById("medals_wrapper")
	local ribbon_el = self.Document:GetElementById("ribbons_wrapper")

	medal_el:SetClass("hidden", toggle)
	ribbon_el:SetClass("hidden", not toggle)

	local medal_btn_el = self.Document:GetElementById("award_btn_1")
	local ribbon_btn_el = self.Document:GetElementById("award_btn_2")

	medal_btn_el:SetPseudoClass("checked", not toggle)
	ribbon_btn_el:SetPseudoClass("checked", toggle)
end

--- Called by the RML to exit the medals screen
--- @return nil
function MedalsController:accept_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
end

--- Global keydown function handles all keypresses
--- @param element Element The main document element
--- @param event Event The event that was triggered
--- @return nil
function MedalsController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

--- Called by the RML when the mouse moves over the medals elements
--- @param element Element The element that the mouse is over
--- @param event Event The event that was triggered
--- @return nil
function MedalsController:mouse_move(element, event)
	ScpuiSystem.data.memory.medal_text.X = event.parameters.mouse_x
	ScpuiSystem.data.memory.medal_text.Y = event.parameters.mouse_y
end

--- Draw the current text for a medal at the mouse coordinates
--- @return nil
function MedalsController:drawText()
	if ScpuiSystem.data.memory.medal_text.Name ~= nil then
		--save the current color
		local r, g, b, a = gr.getColor()

		--set the color to white
		gr.setColor(255, 255, 255, 255)

		--get the string width
		local w = gr.getStringWidth(ScpuiSystem.data.memory.medal_text.Name)

		local draw = {}
		draw.x = ScpuiSystem.data.memory.medal_text.X - w
		draw.y = ScpuiSystem.data.memory.medal_text.Y - 25

		if draw.x < 5 then
			draw.x = 5
		end

		--draw the string
		gr.setColor(255, 255, 0, 255)
		gr.drawRectangle(draw.x-2, draw.y-2, draw.x + w + 6+2, draw.y + 20+2)
		gr.setColor(0, 0, 0, 255)
		gr.drawRectangle(draw.x, draw.y, draw.x + w + 6, draw.y + 20)
		gr.setColor(255, 255, 255, 255)
		gr.drawString(ScpuiSystem.data.memory.medal_text.Name, draw.x + 3, draw.y + 3)

		--reset the color
		gr.setColor(r, g, b, a)
	end
end

--- Called when the screen is being unloaded
--- @return nil
function MedalsController:unload()
	Topics.medals.unload:send(self)
end

--- Every frame if the mouse is over a medal, draw a text box with the name of th medal
engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_VIEW_MEDALS" then
		MedalsController:drawText()
	end
end, {}, function()
    return false
end)

return MedalsController
