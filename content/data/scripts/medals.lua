local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")

local MedalsController = class()

ScpuiSystem.drawMedalText = nil

function MedalsController:init()
	ScpuiSystem.drawMedalText = {
		name = nil,
		x = 0,
		y = 0
	}
end

function MedalsController:initialize(document)
	
	self.document = document
	self.ribbonColumn = 1
	
	--This will reparse the medal info data in SCPUI's tables to make positioning medals
	--easier. Basically this makes it so ctrl-shift-r will allow reflecting table data
	--changes without having to restart the entire game.
	self:reparseTableData()
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.playerMedals = ba.getCurrentPlayer().Stats.Medals
	self.playerRank = ba.getCurrentPlayer().Stats.Rank.Name
	self.playerName = ba.getCurrentPlayer():getName()
	
	for i = 1, #self.playerMedals do
		self:build_medal_div(i)
	end
	
	for i = 1, #self.playerMedals do
		if self.playerMedals[i] > 0 then
			self:showMedal(i)
		end
		
		--rank can be zero
		if ui.Medals.Medals_List[i].Name == "Rank" then
			self:showMedal(i)
		end
	end
	
	self.document:GetElementById("medals_text").inner_rml = self.playerName
	
	ScpuiSystem:loadRibbonsFromFile()
	
	table.sort(ScpuiSystem.PlayerRibbons, function(a, b)
        return a.name < b.name
    end)

	self.ribbonCounts = {}
	for i = 1, #ScpuiSystem.PlayerRibbons do
		self:build_ribbon_div(i)
	end
	
	topics.medals.initialize:send(self)
	
	self:change_view(false)

end

function MedalsController:reparseTableData()
	ScpuiSystem.medalInfo = {}
	if cf.fileExists("scpui.tbl") then
        self:parseMedalInfo("scpui.tbl")
    end
    for _, v in ipairs(cf.listFiles("data/tables", "*-ui.tbm")) do
        self:parseMedalInfo(v)
    end
end

function MedalsController:parseMedalInfo(data)
	parse.readFileText(data, "data/tables")
	
	if parse.skipToString("#Medal Placements") then
	
		ScpuiSystem:parseMedals()
	
	end
	
	parse.stop()
end

function MedalsController:isBadge(medal)
	return (medal.KillsNeeded > 0)
end

function MedalsController:isRank(medal)
	return medal.isRank()
end

function MedalsController:GetMedalInfo(id)
	local info = ScpuiSystem.medalInfo[id]
	
	if info == nil then
		info = {
			x = 0,
			y = 0,
			w = 10
		}
	end
	
	return info
end

function MedalsController:build_medal_div(idx)
	local medal = ui.Medals.Medals_List[idx]
	
	local parent_el = self.document:GetElementById("medals_wrapper_actual")
	
	local id = string.lower(medal.Bitmap:match("(.+)%..+$"))
	local info = self:GetMedalInfo(medal.Name)
	
	local medal_el = self.document:CreateElement("div")
	medal_el.id = id
	medal_el:SetClass("medal", true)
	medal_el.style.position = "absolute"
	medal_el.style.width = info.w .. "%"
	medal_el.style.top = info.y .. "%"
	medal_el.style.left = info.x .. "%"
	
	local filename = id
	if info.altBitmap then
		filename = info.altBitmap
	end
	
	local img_el = self.document:CreateElement("img")
	img_el:SetAttribute("src", filename .. "_00.png")
	
	medal_el:AppendChild(img_el)
	parent_el:AppendChild(medal_el)
end

function MedalsController:showMedal(idx)

	local medal = ui.Medals.Medals_List[idx]
	
	--get the div
	local medal_el = self.document:GetElementById(string.lower(medal.Bitmap:match("(.+)%..+$")))
	local info = self:GetMedalInfo(medal.Name)
	local filename = medal_el.id
	if info.altBitmap then
		filename = info.altBitmap
	end
	
	--create new image element based on number earned
	local img_el = self.document:CreateElement("img")
	
	local num = math.min(self.playerMedals[idx], ui.Medals.Medals_List[idx].NumMods)
	
	--create the display string
	local display = medal.Name
	if num > 1 then
		display = medal.Name .. " (" .. self.playerMedals[idx] .. ")"
	end
	
	--rank is special because reasons
	if medal.Name == "Rank" then
		num = num + 1
		display = self.playerRank
	end
	
	--now setup for the png name
	num = "_" .. self:setupCountString(num)
	
	--Special access to the png id for external scripts
	num = topics.medals.setRankBitmap:send({medal.Name, num})
	
	filename = filename .. num .. ".png"
	
	img_el:SetAttribute("src", filename)
	
	--replace the old image
	medal_el:ReplaceChild(img_el, medal_el.first_child)
	
	--add mouseover listener
	medal_el:AddEventListener("mouseover", function()
		ScpuiSystem.drawMedalText.name = display
	end)
	
	medal_el:AddEventListener("mouseout", function()
		ScpuiSystem.drawMedalText.name = nil
	end)
end

function MedalsController:setupCountString(num)
	local r_string
	if num < 10 then
		r_string = "0" .. num
	else
		r_string = num
	end
	return r_string
end

function MedalsController:build_ribbon_div(idx)
	local ribbon = ScpuiSystem.PlayerRibbons[idx]
	
	if not self.ribbonCounts[ribbon.source] then
		self.ribbonCounts[ribbon.source] = 1
	else
		self.ribbonCounts[ribbon.source] = self.ribbonCounts[ribbon.source] + 1
	end
	
	-- Don't display more than 5 ribbons from a single game
	if self.ribbonCounts[ribbon.source] > 5 then return end
	
	local img = ScpuiSystem:createRibbonImage(ribbon)
	
	local parent_id = "ribbon_column_" .. self.ribbonColumn
	self.ribbonColumn = self.ribbonColumn + 1
	if self.ribbonColumn > 5 then
		self.ribbonColumn = 1
	end
	
	local parent_el = self.document:GetElementById(parent_id)
	
	local ribbon_el = self.document:CreateElement("div")
	ribbon_el.id = "ribbon_" .. idx
	ribbon_el:SetClass("ribbon", true)
	
	--add mouseover listener
	ribbon_el:AddEventListener("mouseover", function()
		ScpuiSystem.drawMedalText.name = ribbon.description
	end)
	
	ribbon_el:AddEventListener("mouseout", function()
		ScpuiSystem.drawMedalText.name = nil
	end)
	
	local img_el = self.document:CreateElement("img")
	img_el:SetAttribute("src", img)
	
	local title_el = self.document:CreateElement("p")
	title_el.inner_rml = ribbon.name
	
	ribbon_el:AppendChild(img_el)
	ribbon_el:AppendChild(title_el)
	parent_el:AppendChild(ribbon_el)
end

function MedalsController:change_view(toggle)
	local medal_el = self.document:GetElementById("medals_wrapper")
	local ribbon_el = self.document:GetElementById("ribbons_wrapper")
	
	medal_el:SetClass("hidden", toggle)
	ribbon_el:SetClass("hidden", not toggle)
	
	local medal_btn_el = self.document:GetElementById("award_btn_1")
	local ribbon_btn_el = self.document:GetElementById("award_btn_2")
	
	medal_btn_el:SetPseudoClass("checked", not toggle)
	ribbon_btn_el:SetPseudoClass("checked", toggle)
end

function MedalsController:accept_pressed()
	ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
end

function MedalsController:global_keydown(_, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_PREVIOUS_STATE"])
    end
end

function MedalsController:mouse_move(element, event)
	ScpuiSystem.drawMedalText.x = event.parameters.mouse_x
	ScpuiSystem.drawMedalText.y = event.parameters.mouse_y
end

function MedalsController:drawText()
	if ScpuiSystem.drawMedalText.name ~= nil then
		--save the current color
		local r, g, b, a = gr.getColor()
		
		--set the color to white
		gr.setColor(255, 255, 255, 255)
		
		--get the string width
		local w = gr.getStringWidth(ScpuiSystem.drawMedalText.name)
		
		local draw = {}
		draw.x = ScpuiSystem.drawMedalText.x - w
		draw.y = ScpuiSystem.drawMedalText.y - 25
		
		if draw.x < 5 then
			draw.x = 5
		end
		
		--draw the string
		gr.setColor(255, 255, 0, 255)
		gr.drawRectangle(draw.x-2, draw.y-2, draw.x + w + 6+2, draw.y + 20+2)
		gr.setColor(0, 0, 0, 255)
		gr.drawRectangle(draw.x, draw.y, draw.x + w + 6, draw.y + 20)
		gr.setColor(255, 255, 255, 255)
		gr.drawString(ScpuiSystem.drawMedalText.name, draw.x + 3, draw.y + 3)
		
		--reset the color
		gr.setColor(r, g, b, a)
	end
end		

function MedalsController:unload()
	topics.medals.unload:send(self)
end

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_VIEW_MEDALS" then
		MedalsController:drawText()
	end
end, {}, function()
    return false
end)

return MedalsController
