-----------------------------------
--This file sets up some default topics parameters and only runs on game init
-----------------------------------

(function()

    local Topics = require("lib_ui_topics")

    --Sets the first tech room button to the technical database game state
    Topics.techroom.btn1Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_TECH_MENU"])
    end)

    --Sets the second tech room button to the mission simulator game state
    Topics.techroom.btn2Action:bind(9999, function(message, context)
      if not ba.MultiplayerMode then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_SIMULATOR_ROOM"])
      else
        context.value = false
      end
    end)

    --Sets the third tech room button to the cutscene viewer game state
    Topics.techroom.btn3Action:bind(9999, function(message, context)
      if not ba.MultiplayerMode then
        ba.postGameEvent(ba.GameEvents["GS_EVENT_GOTO_VIEW_CUTSCENES_SCREEN"])
      else
        context.value = false
      end
    end)

    --Sets the fourth tech room button to the credits game state
    Topics.techroom.btn4Action:bind(9999, function(message, context)
      ba.postGameEvent(ba.GameEvents["GS_EVENT_CREDITS"])
    end)

  end)()