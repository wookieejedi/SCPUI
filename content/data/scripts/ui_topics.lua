local Topic = require("Topic")

local function altNameOrName(x)
  local altName = x.AltName
  if altName and altName ~= '' then
    return altName
  else
    return x.Name
  end
end

local function simulatorTab(x)
  if x == 2 then
    return 1
  else
    return 2
  end
end

return {
  --Global
  Scpui = {
    pauseAudio           = Topic(nil)
  },
  --Objects
  ships = {
    filter               = Topic(function(x) return x.InTechDatabase end),
    name                 = Topic(altNameOrName),
    description          = Topic(function(x) return x.TechDescription end)
  },
  weapons = {
    filter               = Topic(function(x) return x.InTechDatabase end),
    name                 = Topic(altNameOrName),
    description          = Topic(function(x) return x.TechDescription end)
  },
  intel = {
    filter               = Topic(function(x) return x.InTechDatabase end),
    name                 = Topic(function(x) return x.Name end),
    description          = Topic(function(x) return x.Description end),
    type                 = Topic(function(x) return ba.XSTR('Other', -1) end)
  },
  
  --Interfaces
  pilotselect = {
    initialize               = Topic(nil), --Runs arbitrary script and expects no return value. Sends the document context
    startsound               = Topic(true), --Whether or not to start the default mainhall background sound. Sends the document context and expects boolean return
    escKeypress              = Topic(true), --Whether or not to use the default action on ESC keydown. Sends the document context and expects boolean return
    upKeypress               = Topic(true), --Whether or not to use the default action on UP keydown. Sends the document context and expects boolean return
    dwnKeypress              = Topic(true), --Whether or not to use the default action on DOWN keydown. Sends the document context and expects boolean return
    retKeypress              = Topic(true), --Whether or not to use the default action on RETURN keydown. Sends the document context and expects boolean return
    delKeypress              = Topic(true), --Whether or not to use the default action on DELETE keydown. Sends the document context and expects boolean return
    globalKeypress           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the document context and the event
    unload                   = Topic(nil) --Runs arbitrary script and expects no return value. Sends the document context
  },
  briefcommon = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the document context
  },
  fictionviewer = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
	accept               = Topic(true) --Whether or not to continue to with the Accept press. Sends the context and expects boolean return
  },
  cmdbriefing = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the UI context.
    stage                = Topic(function(x) return x[1] end) --Sends the stage handle and the stage index in a table, expects the stage returned
  },
  briefing = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the UI context.
    brief_bg             = Topic('brief-main-window.png') --Expects an image file returned, replaces the briefing goals stage BG
  },
  redalert = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the UI context.
    commit               = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  loopbrief = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  debrief = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the document context
    accept               = Topic(nil), --Runs arbitrary script and expects no return value
    reject               = Topic(nil), --Runs arbitrary script and expects no return value
    skip                 = Topic(nil) --Runs arbitrary script and expects no return value
  },
  campaign = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the document context
  },
  barracks = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the document context
  },
  loadouts = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value
	saveLoadout          = Topic(nil), --Runs arbitrary script and expects no return value. Sends the save data to be saved
	loadLoadout          = Topic(nil), --Runs arbitrary script and expects no return value. Sends the loaded save data
    rejectSavedLoadout   = Topic(false), --Runs arbitrary script and expects a boolean return, true to abort applying saved loadout
    initPool             = Topic(nil), --Runs arbitrary script and expects no return value. Sends the ship slot
    emptyShipSlot        = Topic(nil), --Runs arbitrary script and expects no return value. Sends the ship slot
    fillShipSlot         = Topic(nil), --Runs arbitrary script and expects no return value. Sends the ship slot
    returnShipSlot       = Topic(nil), --Runs arbitrary script and expects no return value. Sends the ship slot
    initWeaponInfo       = Topic(nil), --Runs arbitrary script and expects no return value. Sends the weapon data as a table
    initShipInfo         = Topic(nil), --Runs arbitrary script and expects no return value. Sends the ship data as a table
    copyShipSlot         = Topic(nil) --Runs arbitrary script and expects no return value. Sends the source ship slot and the target ship slot
  },
  medals = {
    initialize  = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    setRankBitmap        = Topic(function(x) return x[2] end) --Sends the medal name and bitmap suffix. Expects a new bitmap suffix returned
  },
  options = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    changeEffectsVol     = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    changeVoiceVol       = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context
  },
  missionlog = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context
  },
  controlconfig = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  hudconfig = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  hotkeyconfig = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  gamehelp = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  gamepaused = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the UI context.
  },
  shipselect = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    entryInfo            = Topic(nil) --Runs arbitrary script and expects no return value. Sends the ship entry and the stats UI element
  },
  weaponselect = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context.
    entryInfo            = Topic(nil), --Runs arbitrary script and expects no return value. Sends the weapon entry and the stats UI element
    selectShip           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context and the selected ship.
  },
  techroom = { --All tech room UIs!
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    btn1Action           = Topic(nil), --The code to run when tech room button 1 is clicked. When changing game states, lowest priority takes precedence.
    btn2Action           = Topic(nil), --The code to run when tech room button 2 is clicked. When changing game states, lowest priority takes precedence.
    btn3Action           = Topic(nil), --The code to run when tech room button 3 is clicked. When changing game states, lowest priority takes precedence.
    btn4Action           = Topic(nil) --The code to run when tech room button 4 is clicked. When changing game states, lowest priority takes precedence.
  },
  techdatabase = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    beginDataLoad        = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    initShipData         = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context and the ship
    initWeaponData       = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context and the weapon
    initIntelData        = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context and the intel
    initSortFuncs        = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    selectSection        = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    sortItems            = Topic(false), --Sends the context. Expects a boolean return for whether or not custom sort was sucessful
    sortCategories       = Topic(false), --Sends the context. Expects a boolean return for whether or not custom sort was sucessful
    setSortCat           = Topic(false), --Sends the context. Expects a boolean return for whether or not category was set
    uncheckSorts         = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    createHeader         = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    selectHeader         = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context
  },
  techcredits = {
    initialize           = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context
  },
  simulator = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    listSingle           = Topic(true), --Return true or false if the mission should be listed as a single mission. Sends the mission filename
    createitem           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the element being created
    newsection           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context and the section value
    sectionname          = Topic(nil), --Runs arbitrary script and expects a string return for the mission list internal name. Sends the section index.
    allowall             = Topic(true), --Return true or false for if ctrl-s should be allowed for the currently displayed section. Sends the context.
    tabkey               = Topic(simulatorTab) --Sends the currently selected section index and expects a number return for the new index to select when TAB is pressed.
  },
  cutscenes = {
    initialize           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context
    addParam             = Topic(nil), --Can add a parameter to a cutscene list item. Sends the current list item and te current cutscene entry.
    hideMovie            = Topic(false), --Return true or false if the cutscene should be globally hidden from the visible list. Sends the cutscene item.
    createList           = Topic(nil), --Runs arbitrary script and expects no return value. Sends the context and the current cutscene.
    selectScene          = Topic(nil) --Runs arbitrary script and expects no return value. Sends the context
  },
  deathpopup = {
    setText              = Topic('') --Runs arbitrary script and expects no return value. Sends the context and expects a string return
  }
}

