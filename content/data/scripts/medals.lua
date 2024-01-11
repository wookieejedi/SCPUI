local rocket_utils = require("rocket_util")
local topics = require("ui_topics")
local class = require("class")

local MedalsController = class(AbstractBriefingController)

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
	
	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("p1-" .. ScpuiSystem:getFontSize()), true)
	
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
	
	topics.medals.initialize:send(self)

end

function MedalsController:isBadge(medal)
	--Eventually we can check through the API directly
	--but for now we just gotta check the name
	return string.find(string.lower(medal.Name), "ace") ~= nil
	--return (medal.KillsNeeded > 0)
end

function MedalsController:isRank(medal)
	--Eventually we can check through the API directly
	--but for now we just gotta check the name
	return string.find(string.lower(medal.Name), "rank") ~= nil
	--return medal.isRank()
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
	local info = self:GetMedalInfo(id)
	
	local medal_el = self.document:CreateElement("div")
	medal_el.id = id
	medal_el:SetClass("medal", true)
	medal_el.style.position = "absolute"
	medal_el.style.width = info.w .. "%"
	medal_el.style.top = info.y .. "%"
	medal_el.style.left = info.x .. "%"
	
	local img_el = self.document:CreateElement("img")
	img_el:SetAttribute("src", id .. "_00.png")
	
	medal_el:AppendChild(img_el)
	parent_el:AppendChild(medal_el)
end

function MedalsController:showMedal(idx)

	local medal = ui.Medals.Medals_List[idx]
	
	--get the div
	local medal_el = self.document:GetElementById(string.lower(medal.Bitmap:match("(.+)%..+$")))
	
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
	
	local filename = medal_el.id .. num .. ".png"
	
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
		
		--draw the string
		gr.drawString(ScpuiSystem.drawMedalText.name, ScpuiSystem.drawMedalText.x - w, ScpuiSystem.drawMedalText.y - 15)
		
		--reset the color
		gr.setColor(r, g, b, a)
	end
end		

engine.addHook("On Frame", function()
	if ba.getCurrentGameState().Name == "GS_STATE_VIEW_MEDALS" then
		MedalsController:drawText()
	end
end, {}, function()
    return false
end)

return MedalsController
