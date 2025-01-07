-----------------------------------
--This file sets up some default topics parameters and only runs on game init
-----------------------------------

(function()

    local topics = require("lib_ui_topics")
    local utils = require("lib_utils")
    
    --Sets the first tech room button to the technical database game state
    topics.techroom.btn1Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
    end)
    
    --Sets the second tech room button to the mission simulator game state
    topics.techroom.btn2Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
    end)
    
    --Sets the third tech room button to the cutscene viewer game state
    topics.techroom.btn3Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
    end)
    
    --Sets the fourth tech room button to the credits game state
    topics.techroom.btn4Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
    end)
  
  end)()