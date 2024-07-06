local class = require("class")
local topics = require("ui_topics")

local LoadScreenController = class()

function LoadScreenController:init()
end

function LoadScreenController:initialize(document)

    self.document = document

	---First set a generic bg
	self.document:GetElementById("main_background"):SetClass("loadscreen_default", true)
	---Then try to set it using the mission filename
	self.document:GetElementById("main_background"):SetClass(mn.getMissionFilename():gsub('.fs2', ''))
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.document:GetElementById("title").inner_rml = mn.getMissionTitle()
	
	if not ScpuiSystem.loadProgress then
		ScpuiSystem.loadProgress = 0
	end

	local load_img = topics.loadscreen.load_bar:send(self)
	
	ScpuiSystem.loadingBar = {}
	ScpuiSystem.loadingBar.img = gr.loadTexture(load_img, true)
	ScpuiSystem.loadingBar.tex = gr.createTexture(ScpuiSystem.loadingBar.img:getWidth(), ScpuiSystem.loadingBar.img:getHeight())
	ScpuiSystem.loadingBar.url = ui.linkTexture(ScpuiSystem.loadingBar.tex)
	local aniEl = self.document:CreateElement("img")
    aniEl:SetAttribute("src", ScpuiSystem.loadingBar.url)
	self.document:GetElementById("loadingbar"):AppendChild(aniEl)
	
	--Draw loading bar frame 0
	gr.setTarget(ScpuiSystem.loadingBar.tex)
	gr.clearScreen(0,0,0,0)
	if ScpuiSystem.loadingBar.img and ScpuiSystem.loadingBar.img:isValid() then	
		gr.drawImage(ScpuiSystem.loadingBar.img[0], 0, 0)
	end
	gr.setTarget()

	topics.loadscreen.initialize:send(self)
	
end

function LoadScreenController:setLoadingBar()
	gr.setTarget(ScpuiSystem.loadingBar.tex)
	gr.clearScreen(0,0,0,0)
	
	--find out which frame to draw
	--progress is between 0 and 1

	local index = 1
		
	if ScpuiSystem.loadingBar.img:getFramesLeft() then
		if not ScpuiSystem.loadingBar.LastProgress or ScpuiSystem.loadingBar.LastProgress < (ScpuiSystem.loadProgress * ScpuiSystem.loadingBar.img:getFramesLeft()) then
			index = math.floor(ScpuiSystem.loadProgress * ScpuiSystem.loadingBar.img:getFramesLeft())
			ScpuiSystem.loadingBar.LastProgress = index
		else
			index = ScpuiSystem.loadingBar.LastProgress
		end
				
		if index == 0 then index = 1 end
	end
	
	--then draw the loading bar
	
	if ScpuiSystem.loadingBar.img and ScpuiSystem.loadingBar.img:isValid() then	
		gr.drawImage(ScpuiSystem.loadingBar.img[index], 0, 0)
	end
	
	gr.setTarget()
end

function LoadScreenController:global_keydown(_, event)

end

function LoadScreenController:unload()
	ScpuiSystem.loadingBar.img:unload()
	ScpuiSystem.loadingBar.img:destroyRenderTarget()
	ScpuiSystem.loadingBar.img = nil
	ScpuiSystem.loadingBar.tex:unload()
	ScpuiSystem.loadingBar.tex:destroyRenderTarget()
	ScpuiSystem.loadingBar.tex = nil
	ScpuiSystem.loadingBar = nil
end

engine.addHook("On Frame", function()
	if ScpuiSystem.loadDoc ~= nil then
		LoadScreenController:setLoadingBar()
	end
end, {}, function()
    return false
end)

return LoadScreenController
