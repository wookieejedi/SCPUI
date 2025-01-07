local class = require("lib_class")
local topics = require("lib_ui_topics")

local LoadScreenController = class()

function LoadScreenController:init()
end

---@param document Document
function LoadScreenController:initialize(document)

    self.Document = document

	---First set a generic bg
	self.Document:GetElementById("main_background"):SetClass("loadscreen_default", true)
	---Then try to set it using the mission filename
	self.Document:GetElementById("main_background"):SetClass(mn.getMissionFilename():gsub('.fs2', ''))
	
	---Load the desired font size from the save file
	self.Document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)
	
	self.Document:GetElementById("title").inner_rml = mn.getMissionTitle()
	
	if not ScpuiSystem.data.memory.loading_bar.LoadProgress then
		ScpuiSystem.data.memory.loading_bar.LoadProgress = 0
	end

	local load_img = topics.loadscreen.load_bar:send(self)
	ScpuiSystem.data.memory.loading_bar.ImageTexture = gr.loadTexture(load_img, true)
	ScpuiSystem.data.memory.loading_bar.Texture = gr.createTexture(ScpuiSystem.data.memory.loading_bar.ImageTexture:getWidth(), ScpuiSystem.data.memory.loading_bar.ImageTexture:getHeight())
	ScpuiSystem.data.memory.loading_bar.Url = ui.linkTexture(ScpuiSystem.data.memory.loading_bar.Texture)
	
	local aniEl = self.Document:CreateElement("img")
    aniEl:SetAttribute("src", ScpuiSystem.data.memory.loading_bar.Url)
	self.Document:GetElementById("loadingbar"):AppendChild(aniEl)
	
	--Draw loading bar frame 0
	gr.setTarget(ScpuiSystem.data.memory.loading_bar.Texture)
	gr.clearScreen(0,0,0,0)
	if ScpuiSystem.data.memory.loading_bar.ImageTexture and ScpuiSystem.data.memory.loading_bar.ImageTexture:isValid() then	
		gr.drawImage(ScpuiSystem.data.memory.loading_bar.ImageTexture[0], 0, 0)
	end
	gr.setTarget()

	topics.loadscreen.initialize:send(self)
	
end

function LoadScreenController:setLoadingBar()
	gr.setTarget(ScpuiSystem.data.memory.loading_bar.Texture)
	gr.clearScreen(0,0,0,0)
	local loopBar = true
	
	--find out which frame to draw
	--progress is between 0 and 1

	local index = 1
	
	if ScpuiSystem.data.memory.loading_bar.LoopLoadBar then
		-- Get the last frame or start at 1
		index = ScpuiSystem.data.memory.loading_bar.LastProgress or 1
	
		-- Loop back to the first frame if we exceed the total frame count
		if index > ScpuiSystem.data.memory.loading_bar.ImageTexture:getFramesLeft() then
			index = 1
		end
	
		-- Store the updated frame index
		ScpuiSystem.data.memory.loading_bar.LastProgress = index + 1
	elseif ScpuiSystem.data.memory.loading_bar.ImageTexture:getFramesLeft() then
		if not ScpuiSystem.data.memory.loading_bar.LastProgress or ScpuiSystem.data.memory.loading_bar.LastProgress < (ScpuiSystem.data.memory.loading_bar.LoadProgress * ScpuiSystem.data.memory.loading_bar.ImageTexture:getFramesLeft()) then
			index = math.floor(ScpuiSystem.data.memory.loading_bar.LoadProgress * ScpuiSystem.data.memory.loading_bar.ImageTexture:getFramesLeft())
			ScpuiSystem.data.memory.loading_bar.LastProgress = index
		else
			index = ScpuiSystem.data.memory.loading_bar.LastProgress
		end
				
		if index == 0 then index = 1 end
	end
	
	--then draw the loading bar
	if ScpuiSystem.data.memory.loading_bar.ImageTexture and ScpuiSystem.data.memory.loading_bar.ImageTexture:isValid() then	
		gr.drawImage(ScpuiSystem.data.memory.loading_bar.ImageTexture[index], 0, 0)
	end
	
	gr.setTarget()
end

function LoadScreenController:global_keydown(_, event)

end

function LoadScreenController:unload()
	ScpuiSystem.data.memory.loading_bar.ImageTexture:unload()
	ScpuiSystem.data.memory.loading_bar.ImageTexture:destroyRenderTarget()
	ScpuiSystem.data.memory.loading_bar.ImageTexture = nil
	ScpuiSystem.data.memory.loading_bar.Texture:unload()
	ScpuiSystem.data.memory.loading_bar.Texture:destroyRenderTarget()
	ScpuiSystem.data.memory.loading_bar.Texture = nil
	ScpuiSystem.data.memory.loading_bar.Url = nil
	ScpuiSystem.data.memory.loading_bar = {}
	
	topics.loadscreen.unload:send(self)
end

engine.addHook("On Frame", function()
	if ScpuiSystem.data.LoadDoc ~= nil then
		LoadScreenController:setLoadingBar()
	end
end, {}, function()
    return false
end)

return LoadScreenController
