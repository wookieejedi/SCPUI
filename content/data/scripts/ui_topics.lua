local Topic = require("Topic")

local function altNameOrName(x)
  local altName = x.AltName
  if altName and altName ~= '' then
    return altName
  else
    return x.Name
  end
end

local function defaultBG()
  return ScpuiSystem:getBackgroundClass()
end

local function simulatorTab(x)
  if x == 2 then
    return 1
  else
    return 2
  end
end

return {
  --Objects
  ships = {
    filter      = Topic(function(x) return x.InTechDatabase end),
    name        = Topic(altNameOrName),
    description = Topic(function(x) return x.TechDescription end)
  },
  weapons = {
    filter      = Topic(function(x) return x.InTechDatabase end),
    name        = Topic(altNameOrName),
    description = Topic(function(x) return x.TechDescription end)
  },
  intel = {
    filter      = Topic(function(x) return x.InTechDatabase end),
    name        = Topic(function(x) return x.Name end),
    description = Topic(function(x) return x.Description end),
    type        = Topic(function(x) return ba.XSTR('Other', -1) end)
  },
  
  --Interfaces
  briefcommon = {
    initialize  = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the document context
  },
  cmdbriefing = {
    stage       = Topic(function(x) return x[1] end) --Sends the stage handle and the stage index in a table, expects the stage returned
  },
  briefing = {
    brief_bg    = Topic(function() return "brief-main-window.png" end) --Expects an image file returned, replaces the briefing goals stage BG
  },
  redalert = {
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the UI context.
	commit      = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  debrief = {
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the document context
	accept      = Topic(function() return nil end), --Runs arbitrary script and expects no return value
	reject      = Topic(function() return nil end), --Runs arbitrary script and expects no return value
    skip        = Topic(function() return nil end) --Runs arbitrary script and expects no return value
  },
  campaign = {
    initialize  = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the document context
  },
  barracks = {
    initialize  = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the document context
  },
  loadouts = {
    initialize          = Topic(function() return nil end), --Runs arbitrary script and expects no return value
	rejectSavedLoadout  = Topic(function() return false end), --Runs arbitrary script and expects a boolean return, true to abort applying saved loadout
	initPool            = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the ship slot
	emptyShipSlot       = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the ship slot
	fillShipSlot        = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the ship slot
	returnShipSlot      = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the ship slot
	copyShipSlot        = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the source ship slot and the target ship slot
  },
  weaponselect = {
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context.
	selectShip  = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the context and the selected ship.
  },
  medals = {
    setRankBitmap       = Topic(function(x) return x[2] end) --Sends the medal name and bitmap suffix. Expects a new bitmap suffix returned
  },
  options = {
    background  = Topic(defaultBG) --Sends the UI contet, expects a css class returned
  },
  gamepaused = {
    bg          = Topic(function() return nil end) --Expects a CSS class returned
  },
  techroom = { --All tech room UIs!
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context
	btn1Action  = Topic(function() return nil end), --The code to run when tech room button 1 is clicked. When changing game states, lowest priority takes precedence.
	btn2Action  = Topic(function() return nil end), --The code to run when tech room button 2 is clicked. When changing game states, lowest priority takes precedence.
	btn3Action  = Topic(function() return nil end), --The code to run when tech room button 3 is clicked. When changing game states, lowest priority takes precedence.
	btn4Action  = Topic(function() return nil end) --The code to run when tech room button 4 is clicked. When changing game states, lowest priority takes precedence.
  },
  simulator = {
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context
	listSingle  = Topic(function() return true end), --Return true or false if the mission should be listed as a single mission. Sends the mission filename
	createitem  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the element being created
	newsection  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context and the section value
	sectionname = Topic(function() return nil end), --Runs arbitrary script and expects a string return for the mission list internal name. Sends the section index.
	allowall    = Topic(function() return true end), --Return true or false for if ctrl-s should be allowed for the currently displayed section. Sends the context.
	tabkey      = Topic(simulatorTab) --Sends the currently selected section index and expects a number return for the new index to select when TAB is pressed.
  },
  cutscenes = {
    initialize  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context
    addParam    = Topic(function() return nil end), --Can add a parameter to a cutscene list item. Sends the current list item and te current cutscene entry.
	hideMovie   = Topic(function() return false end), --Return true or false if the cutscene should be globally hidden from the visible list. Sends the cutscene item.
	createList  = Topic(function() return nil end), --Runs arbitrary script and expects no return value. Sends the context and the current cutscene.
	selectScene = Topic(function() return nil end) --Runs arbitrary script and expects no return value. Sends the context
  },
  deathpopup = {
    setText     = Topic(function() return "" end) --Runs arbitrary script and expects no return value. Sends the context and expects a string return
  }
}
