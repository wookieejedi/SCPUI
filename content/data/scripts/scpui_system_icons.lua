-----------------------------------
--This file contains all the methods used for SCPUI to generate weapon and ship select icons
-----------------------------------

rocketUiIcons = {}

local async_util = require("async_util")

function ScpuiSystem:openCache()

	local json = require('dkjson')
	local location = 'data/config'
	local file = nil
	
	local modname = string.sub(ScpuiSystem:getModTitle(), 1, 20)
	
	if modname == "" then
		ba.print("SCPUI could not load the icon cache because no mod name was found!\n")
		return {}
	end
	
	local filename = "scpui_" .. modname:gsub(" ", "") .. ".cache"

	if cf.fileExists(filename, location) then
		file = cf.openFile(filename, 'r', location)
		cache = json.decode(file:read('*a'))
		file:close()
		if not cache then
			cache = {}
		end
	end
	
	return cache

end

function ScpuiSystem:saveCache(cache)

	local json = require('dkjson')
	local location = 'data/config'
	
	local modname = string.sub(ScpuiSystem:getModTitle(), 1, 20)
	
	if modname == "" then
		ba.print("SCPUI could not get a valid mod name. Skipping icon caching!\n")
		return {}
	end
	
	local filename = "scpui_" .. modname:gsub(" ", "") .. ".cache"
	
	local file = cf.openFile(filename, 'w', location)
	file:write(json.encode(cache))
	file:close()

end

function ScpuiSystem:setIconFrames(item, is_ship)

	--If the icon was preloaded, then skip!
	if rocketUiIcons[item] ~= nil then
		return
	end
	
	local ship3d, shipEffect, shipicon3d = ui.ShipWepSelect.get3dShipChoices()
	local weapon3d, weaponEffect, weaponicon3d = ui.ShipWepSelect.get3dWeaponChoices()
	
	local gen3d = false
	
	if (shipicon3d and is_ship) or (weaponicon3d and not is_ship) then
		gen3d = true
	end
	
	local icon_details = {
		Icon = {}
	}
	
	local o_clr = gr.getColor(true)
	
	--Create a texture and then draw the image to it, save the output
	local function makeIconFromIconFile(filename)
		local imag_h = nil
		
		local validExtensions = {".ani", ".eff", ".png"}
		
		--Iterate through the extensions and check if the file exists
		local exists = false
		for _, extension in ipairs(validExtensions) do
			local fullFilename = filename .. extension
			if cf.fileExists(fullFilename, "", true) then
				exists = true
				break
			end
		end
		
		--Warn but continue because icon generation will create an empty frame for the icon.
		if not exists then
			ba.warning("Could not generate an icon from file " .. filename .. "! Check that the file exists...")
		end
		
		if is_ship == true then
			imag_h = gr.loadTexture(tb.ShipClasses[item].SelectIconFilename, true, true)
		else
			imag_h = gr.loadTexture(tb.WeaponClasses[item].SelectIconFilename, true, true)
		end
		
		local numFrames = 0
		
		--Invalid image files somehow don't fully error as a texture except when getting frames
		--So in that case we leave frames at 0 and the draw function will just create an empty
		--image for the icon frame. The log will show an error from the drawing function.
		if imag_h:isValid() then
			numFrames = imag_h:getFramesLeft()
		end
		
		local width = imag_h:getWidth()
		local height = imag_h:getHeight()
		local tex_h = gr.createTexture(width, height)
		gr.setTarget(tex_h)
		for j = 1, 6, 1 do
			gr.clearScreen(0,0,0,0)
			gr.drawImage(imag_h[math.min(j, numFrames)], 0, 0, width, height, 0, 1, 1, 0, 1)
			icon_details.Icon[j] = gr.screenToBlob()
		end
		icon_details.Width = width
		icon_details.Height = height
		
		--clean up
		gr.setTarget()
		tex_h:destroyRenderTarget()
		--imag_h:destroyRenderTarget() --Don't need to destroy this render target apparently
		imag_h:unload()
		tex_h:unload()
	end
	
	--Create a texture and then draw the model to it, save the output
	local function makeIconFromModel()
		local name = nil
		local icon = nil
		local model_h = nil
		local modelDetails = {
			width = nil,
			height = nil,
			heading = nil,
			pitch = nil,
			bank = nil,
			zoom = nil
		}

		if is_ship == true then
			name = tb.ShipClasses[item].Name
			icon = tb.ShipClasses[item].SelectIconFilename
			model_h = tb.ShipClasses[item]
			modelDetails.width = ScpuiSystem.iconDimentions.ship.width
			modelDetails.height = ScpuiSystem.iconDimentions.ship.height
			modelDetails.heading = 50
			modelDetails.pitch = 15
			modelDetails.bank = 50
			modelDetails.zoom = 1.1
		else
			name = tb.WeaponClasses[item].Name
			icon = tb.WeaponClasses[item].SelectIconFilename
			model_h = tb.WeaponClasses[item]
			modelDetails.width = ScpuiSystem.iconDimentions.weapon.width
			modelDetails.height = ScpuiSystem.iconDimentions.weapon.height
			modelDetails.heading = 75
			modelDetails.pitch = 0
			modelDetails.bank = 40
			modelDetails.zoom = 0.4
		end
		
		icon_details.Width = modelDetails.width
		icon_details.Height = modelDetails.height

		local tex_h = gr.createTexture(modelDetails.width, modelDetails.height)
		gr.setTarget(tex_h)
		gr.clearScreen(0,0,0,0)
		local result = model_h:renderTechModel(0, 0, modelDetails.width, modelDetails.height, modelDetails.heading, modelDetails.pitch, modelDetails.bank, modelDetails.zoom, false)
		if not result then
			--If we don't have an icon file then we're done!
			if not icon or #icon == 0 then
				ba.warning("An icon for " .. name .. " could not be created because it has neither a select icon or a tech model defined!")
			else
				--clean up this run
				gr.setTarget()
				gr.setColor(o_clr)
				tex_h:destroyRenderTarget()
				tex_h:unload()
				
				--now try a 2D icon
				makeIconFromIconFile(icon)
				return
			end
		end
		local blob = gr.screenToBlob()
		
		for j = 1, 5, 1 do -- 1 through 5 are the plain ship for now
			icon_details.Icon[j] = blob
		end
		
		function colorize(color, loop, monochrome, index)
			gr.setTarget() --Have to clear the target between textures
			local tex_i = gr.createTexture(modelDetails.width, modelDetails.height)
			gr.setTarget(tex_i)
			gr.clearScreen(0,0,0,0)
			--Draw the normal version first to have a solid base.. this is pretty hacky, but what are ya gonna do about it?
			gr.drawImage(tex_h, 0, 0, modelDetails.width, modelDetails.height, 0, 0, 1, 1, 2, false)
			gr.setColor(color)
			for l = 1, loop do -- Now draw the monochrome on top 4 times to "colorize" the image
				gr.drawImage(tex_h, 0, 0, modelDetails.width, modelDetails.height, 0, 0, 1, 1, 2, monochrome)
			end
			icon_details.Icon[index] = gr.screenToBlob()
			tex_i:destroyRenderTarget()
			tex_i:unload()
		end
		
		colorize(gr.createColor(255, 255, 255, 0.2), 1, true, 2) --Full color mouseover
		colorize(gr.createColor(255, 255, 255, 0.5), 1, true, 3) --Full color highlighted
		colorize(gr.createColor(255, 165, 0), 4, true, 4) --Orange for items being dragged
		colorize(gr.createColor(128, 128, 128), 4, true, 5) --Grey for locked
		colorize(gr.createColor(225, 225, 225), 4, true, 6) --Grey highlighted
		
		--clean up
		gr.setTarget()
		gr.setColor(o_clr)
		tex_h:destroyRenderTarget()
		tex_h:unload()
	end
	
	--Icon from 3D model or from a file?
	if gen3d then
		makeIconFromModel()
	else
		local icon = nil
		if is_ship == true then
			icon = tb.ShipClasses[item].SelectIconFilename
		else
			icon = tb.WeaponClasses[item].SelectIconFilename
		end
		
		--If we don't have a file then fallback to using the model
		if not icon or #icon == 0 then
			makeIconFromModel()
		else
			makeIconFromIconFile(icon)
		end
	end

	rocketUiIcons[item] = icon_details

end

function ScpuiSystem:beginIconGeneration()
	rocketUiIcons = ScpuiSystem:openCache()
	
	if rocketUiIcons == nil or ScpuiSystemReset == true then
		ba.print("SCPUI is resetting icon cache!\n")
		rocketUiIcons = {}
	end
	
	--prevent the keypress hook now
	ScpuiSystemReset = true
end

function ScpuiSystem:finishIconGeneration()
	ScpuiSystem:saveCache(rocketUiIcons)

	ba.print("SCPUI successfully generated ship and weapon loadout icons!\n")

	gr.freeAllModels()
end

function ScpuiSystem:genIcons()

	if not ScpuiSystem.active then
		return
	end
	
	ScpuiSystem:addPreload(
		"SCPUI is starting generation of ship and weapon loadout icons!",
		"Initializing icon generation...",
		"ScpuiSystem:beginIconGeneration()",
		1
	)

	for i = 1, #tb.WeaponClasses do

		v = tb.WeaponClasses[i]

		if v:isPlayerAllowed() then		
			local safeName = v.Name:gsub("'", "\\'")
			ScpuiSystem:addPreload(
				"Generating icon for " .. v.Name, --log print
				"Generating " .. v.Name .. " icon", --on screen print
				"ScpuiSystem:setIconFrames('" .. safeName .. "', false)", --function to run
				1 --priority level
			)
		end

	end

	for i = 1, #tb.ShipClasses do

		v = tb.ShipClasses[i]

		if v:isPlayerAllowed() then
			local safeName = v.Name:gsub("'", "\\'")
			ScpuiSystem:addPreload(
				"Generating icon for " .. v.Name,
				"Generating " .. v.Name .. " icon",
				"ScpuiSystem:setIconFrames('" .. safeName .. "', true)",
				2
			)
		end

	end
	
	ScpuiSystem:addPreload(
		"Saving ship and weapon loadout icons!",
		"Finalizing icon generation...",
		"ScpuiSystem:finishIconGeneration()",
		2
	)

end

local function resetIconCache()
    if ScpuiSystemReset == nil and hv.Key == "F12" then
		ScpuiSystemReset = true
		ba.print("SCPUI got manual command to reset the icon cache!\n")
	end
end

engine.addHook("On Key Pressed", function()
	resetIconCache()
end)

ScpuiSystem:genIcons()