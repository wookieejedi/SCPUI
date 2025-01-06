local class = require("class")
local topics = require("ui_topics")

local LoadScreenController = class()

function LoadScreenController:init()
end

---@param document Document
function LoadScreenController:initialize(document)

    self.document = document

	---First set a generic bg
	self.document:GetElementById("main_background"):SetClass("loadscreen_default", true)
	---Then try to set it using the mission filename
	self.document:GetElementById("main_background"):SetClass(mn.getMissionFilename():gsub('.fs2', ''))
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.document:GetElementById("title").inner_rml = mn.getMissionTitle()
	
	if not ScpuiSystem.data.memory.loadingBar.LoadProgress then
		ScpuiSystem.data.memory.loadingBar.LoadProgress = 0
	end

	local load_img = topics.loadscreen.load_bar:send(self)
	ScpuiSystem.data.memory.loadingBar.img = gr.loadTexture(load_img, true)
	ScpuiSystem.data.memory.loadingBar.tex = gr.createTexture(ScpuiSystem.data.memory.loadingBar.img:getWidth(), ScpuiSystem.data.memory.loadingBar.img:getHeight())
	ScpuiSystem.data.memory.loadingBar.url = ui.linkTexture(ScpuiSystem.data.memory.loadingBar.tex)
	
	local aniEl = self.document:CreateElement("img")
    aniEl:SetAttribute("src", ScpuiSystem.data.memory.loadingBar.url)
	self.document:GetElementById("loadingbar"):AppendChild(aniEl)
	
	--Draw loading bar frame 0
	gr.setTarget(ScpuiSystem.data.memory.loadingBar.tex)
	gr.clearScreen(0,0,0,0)
	if ScpuiSystem.data.memory.loadingBar.img and ScpuiSystem.data.memory.loadingBar.img:isValid() then	
		gr.drawImage(ScpuiSystem.data.memory.loadingBar.img[0], 0, 0)
	end
	gr.setTarget()

	topics.loadscreen.initialize:send(self)
	
end

function LoadScreenController:setLoadingBar()
	gr.setTarget(ScpuiSystem.data.memory.loadingBar.tex)
	gr.clearScreen(0,0,0,0)
	local loopBar = true
	
	--find out which frame to draw
	--progress is between 0 and 1

	local index = 1
	
	if ScpuiSystem.data.memory.loadingBar.LoopLoadBar then
		-- Get the last frame or start at 1
		index = ScpuiSystem.data.memory.loadingBar.LastProgress or 1
	
		-- Loop back to the first frame if we exceed the total frame count
		if index > ScpuiSystem.data.memory.loadingBar.img:getFramesLeft() then
			index = 1
		end
	
		-- Store the updated frame index
		ScpuiSystem.data.memory.loadingBar.LastProgress = index + 1
	elseif ScpuiSystem.data.memory.loadingBar.img:getFramesLeft() then
		if not ScpuiSystem.data.memory.loadingBar.LastProgress or ScpuiSystem.data.memory.loadingBar.LastProgress < (ScpuiSystem.data.memory.loadingBar.LoadProgress * ScpuiSystem.data.memory.loadingBar.img:getFramesLeft()) then
			index = math.floor(ScpuiSystem.data.memory.loadingBar.LoadProgress * ScpuiSystem.data.memory.loadingBar.img:getFramesLeft())
			ScpuiSystem.data.memory.loadingBar.LastProgress = index
		else
			index = ScpuiSystem.data.memory.loadingBar.LastProgress
		end
				
		if index == 0 then index = 1 end
	end
	
	--then draw the loading bar
	if ScpuiSystem.data.memory.loadingBar.img and ScpuiSystem.data.memory.loadingBar.img:isValid() then	
		gr.drawImage(ScpuiSystem.data.memory.loadingBar.img[index], 0, 0)
	end
	
	gr.setTarget()
end

function LoadScreenController:global_keydown(_, event)

end

function LoadScreenController:unload()
	ScpuiSystem.data.memory.loadingBar.img:unload()
	ScpuiSystem.data.memory.loadingBar.img:destroyRenderTarget()
	ScpuiSystem.data.memory.loadingBar.img = nil
	ScpuiSystem.data.memory.loadingBar.tex:unload()
	ScpuiSystem.data.memory.loadingBar.tex:destroyRenderTarget()
	ScpuiSystem.data.memory.loadingBar.tex = nil
	ScpuiSystem.data.memory.loadingBar.url = nil
	ScpuiSystem.data.memory.loadingBar = {}
	
	topics.loadscreen.unload:send(self)
end

engine.addHook("On Frame", function()
	if ScpuiSystem.data.loadDoc ~= nil then
		LoadScreenController:setLoadingBar()
	end
end, {}, function()
    return false
end)

return LoadScreenController
