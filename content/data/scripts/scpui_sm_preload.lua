-----------------------------------
--This file runs SCPUI's preload system and shows the splash screens
-----------------------------------

local async_util = require("async_util")

--- Run the preload system and interate through the preload coroutines
--- @return nil
function ScpuiSystem:preLoad()

	ba.print("SCPUI is starting preload functions...\n")
	
	local yieldTS = time.getCurrentTime()
	local splashTime = time.getCurrentTime()

	if ScpuiSystem.data.stateInit.preLoad == true then
		return
	end
	
	--fade in the splash screen
	while ((splashTime - yieldTS):getSeconds() * -1) < ScpuiSystem.data.memory.splash.fade do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.01 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			local i = ScpuiSystem.data.memory.splash.i
			ScpuiSystem.data.memory.splash.img[i].A = ScpuiSystem.data.memory.splash.img[i].A + (1.0 / ((ScpuiSystem.data.memory.splash.fade) / ba.getRealFrametime()))
			ScpuiSystem:drawSplash()
		end
	end
	
	ScpuiSystem.data.memory.splash.TD = true
	
	-- Do any modular methods here
	for _, v in ipairs(ScpuiSystem.data.preloadCoroutines) do
	
		if v.priority == 1 then
		
			ba.print("SCPUI: " .. v.debugMessage .. "\n")
			loadstring(v.func)()
			if (time.getCurrentTime() - yieldTS):getSeconds() > 0.1 then
				yieldTS = time.getCurrentTime()
				async.await(async.yield())
				ScpuiSystem.data.memory.splash.debugString = v.debugString
				ScpuiSystem:drawSplash()
			end
		
		end
		
	end
	
	ScpuiSystem.data.memory.splash.debugString = ""

	--make sure the splash logo is shown for at least 2 seconds
	while ((splashTime - yieldTS):getSeconds() * -1) < 2 do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.1 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			ScpuiSystem:drawSplash()
		end
	end
	
	--fade out the splash screen
	splashTime = time.getCurrentTime()
	while ((splashTime - yieldTS):getSeconds() * -1) < ScpuiSystem.data.memory.splash.fade do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.01 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			local i = ScpuiSystem.data.memory.splash.i
			ScpuiSystem.data.memory.splash.img[i].A = ScpuiSystem.data.memory.splash.img[i].A - (1.0 / ((ScpuiSystem.data.memory.splash.fade) / ba.getRealFrametime()))
			ScpuiSystem:drawSplash()
		end
	end
	
	--switch to the second splash image
	ScpuiSystem.data.memory.splash.i = 2
	splashTime = time.getCurrentTime()
	
	--fade in the splash screen
	while ((splashTime - yieldTS):getSeconds() * -1) < ScpuiSystem.data.memory.splash.fade do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.01 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			local i = ScpuiSystem.data.memory.splash.i
			ScpuiSystem.data.memory.splash.img[i].A = ScpuiSystem.data.memory.splash.img[i].A + (1.0 / ((ScpuiSystem.data.memory.splash.fade) / ba.getRealFrametime()))
			ScpuiSystem:drawSplash()
		end
	end
	
	-- Do any modular methods here
	for _, v in ipairs(ScpuiSystem.data.preloadCoroutines) do
	
		if v.priority == 2 then
		
			ba.print("SCPUI: " .. v.debugMessage .. "\n")
			loadstring(v.func)()
			if (time.getCurrentTime() - yieldTS):getSeconds() > 0.1 then
				yieldTS = time.getCurrentTime()
				async.await(async.yield())
				ScpuiSystem.data.memory.splash.debugString = v.debugString
				ScpuiSystem:drawSplash()
			end
		
		end
		
	end
	
	ScpuiSystem.data.memory.splash.debugString = ""
	
	--make sure the splash logo is shown for at least 2 seconds
	while ((splashTime - yieldTS):getSeconds() * -1) < 2 do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.1 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			ScpuiSystem:drawSplash()
		end
	end
	
	ScpuiSystem.data.memory.splash.TD = false
	
	--fade out the splash screen
	splashTime = time.getCurrentTime()
	while ((splashTime - yieldTS):getSeconds() * -1) < ScpuiSystem.data.memory.splash.fade do
		if (time.getCurrentTime() - yieldTS):getSeconds() > 0.01 then
			yieldTS = time.getCurrentTime()
			async.await(async.yield())
			local i = ScpuiSystem.data.memory.splash.i
			ScpuiSystem.data.memory.splash.img[i].A = ScpuiSystem.data.memory.splash.img[i].A - (1.0 / ((ScpuiSystem.data.memory.splash.fade) / ba.getRealFrametime()))
			ScpuiSystem:drawSplash()
		end
	end
	
	ScpuiSystem.data.stateInit.preLoad = true
	
	io.setCursorHidden(false)
end

--- Prepare the splash screen images and text for display
--- @return nil
function ScpuiSystem:prepareSplash()

	ScpuiSystem.data.memory.splash = {
		img = {},
		fade = 2,
		Text = "",
		TX = 0,
		TY = 0,
		TW = 0,
		F = 1,
		TD = false,
		i = 1,
	}
	
	--first splash image
	local file = "fsolua.png"
	
	--screen center coords
	local x = gr.getScreenWidth() / 2
	local y = gr.getScreenHeight() / 2
	
	--scale the image
	local scale = math.min((gr.getScreenWidth() * 0.5)/gr.getImageWidth(file), (gr.getScreenHeight() * 0.5)/gr.getImageHeight(file))
	
	local w = gr.getImageWidth(file) * scale
	local h = gr.getImageHeight(file) * scale
	
	--save the first image
	ScpuiSystem.data.memory.splash.img[1] = {
		File = file,
		X = x,
		Y = y,
		W = w,
		H = h,
		A = 0
	}
	
	--second splash image
	file = "SCPUI.png"
	
	--scale the image
	scale = math.min((gr.getScreenWidth() * 0.8)/gr.getImageWidth(file), (gr.getScreenHeight() * 0.8)/gr.getImageHeight(file))
	
	w = gr.getImageWidth(file) * scale
	h = gr.getImageHeight(file) * scale
	
	--save the second image
	ScpuiSystem.data.memory.splash.img[2] = {
		File = file,
		X = x,
		Y = y,
		W = w,
		H = h,
		A = 0
	}
	
	local text = "Loading"
	local tw = gr.getStringWidth(text)
	
	--save the text data
	ScpuiSystem.data.memory.splash.Text = text
	ScpuiSystem.data.memory.splash.TX = x - (tw / 2)
	ScpuiSystem.data.memory.splash.TY = h + (h * 0.01)
	ScpuiSystem.data.memory.splash.TW = tw
	ScpuiSystem.data.memory.splash.F = 1
	ScpuiSystem.data.memory.splash.TD = false
	
	--start with the first image
	ScpuiSystem.data.memory.splash.i = 1
	
	--start timing the "dots" animation
	ScpuiSystem:calcFrames()

end

--- Calculate the number of dots to append to the "Loading" text
--- @return nil
function ScpuiSystem:calcFrames()

	if ScpuiSystem.data.stateInit.preLoad then
		return
	end

	if ScpuiSystem.data.memory.splash.F < 3 then
		ScpuiSystem.data.memory.splash.F = ScpuiSystem.data.memory.splash.F + 1
	else
		ScpuiSystem.data.memory.splash.F = 1
	end
	
	async.run(function()
        async.await(async_util.wait_for(0.1))
        self:calcFrames()
    end, async.OnFrameExecutor)
end

--- Actually draw the current splash screen and text
--- @return nil
function ScpuiSystem:drawSplash()

	io.setCursorHidden(true)

	gr.clearScreen(0, 0, 0, 255)
	
	--save the current color and set to white
	local r, g, b, a = gr.getColor()
	gr.setColor(255, 255, 255, 255)
	
	--calculate the number of dots to append
	local dots = ""
	for i = 1, ScpuiSystem.data.memory.splash.F do
		dots = dots .. "."
	end
	
	local img = ScpuiSystem.data.memory.splash.i
	
	local file = ScpuiSystem.data.memory.splash.img[img].File
	local x = ScpuiSystem.data.memory.splash.img[img].X
	local y = ScpuiSystem.data.memory.splash.img[img].Y
	local w = ScpuiSystem.data.memory.splash.img[img].W
	local h = ScpuiSystem.data.memory.splash.img[img].H
	
	--handle alpha
	if ScpuiSystem.data.memory.splash.img[img].A > 1 then
		ScpuiSystem.data.memory.splash.img[img].A = 1
	end
	if ScpuiSystem.data.memory.splash.img[img].A < 0 then
		ScpuiSystem.data.memory.splash.img[img].A = 0
	end
	local a = ScpuiSystem.data.memory.splash.img[img].A
	
	local text = ScpuiSystem.data.memory.splash.Text .. dots
	
	--draw!
	gr.drawImageCentered(file, x, y, w, h, 0, 0, 1, 1, a)
	if ScpuiSystem.data.memory.splash.TD then
		gr.drawString(text, ScpuiSystem.data.memory.splash.TX, ScpuiSystem.data.memory.splash.TY)
		if ba.inDebug() and string.len(ScpuiSystem.data.memory.splash.debugString) > 0 then
			local ds = "(" .. ScpuiSystem.data.memory.splash.debugString .. ")"
			local tw = gr.getStringWidth(ds)
			local x = (gr.getScreenWidth() / 2) - (tw / 2)
			gr.setColor(255, 255, 255, 150)
			gr.drawString(ds, x, ScpuiSystem.data.memory.splash.TY + 15)
		end
	end
	
	--reset the color back to what it was.
	gr.setColor(r, g, b, a)

end

--- Prepare the splash screens and run the preload system
--- @return nil
function ScpuiSystem:firstRun()
	ScpuiSystem:prepareSplash()
	
	ScpuiSystem:drawSplash()
	
	ScpuiSystem.data.stateInit.preLoad = false
    async.awaitRunOnFrame(function()
        async.await(async.yield())
        ScpuiSystem:preLoad()
    end)

end

--- Run the preload system if SCPUI is active and preload has not yet been run
--- @return nil
local function runPreload()
	if ScpuiSystem.data.active and not ScpuiSystem.data.stateInit.preLoad then
		ScpuiSystem:firstRun()
	end
end

engine.addHook("On Intro About To Play", function()
	runPreload()
end)