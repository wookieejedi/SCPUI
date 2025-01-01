-- Lua Stub File
-- Generated for FSO v24.3.0 (FS2_Open Scripting)

-- Lua Version: Lua 5.1.5
---@meta
-- Conditions:
-- State
-- Campaign
-- Mission
-- KeyPress
-- Version
-- Application
-- Multi type
-- VR device

-- FRED On Mission Load:
--   Invoked when a new mission is loaded.
--   This hook is NOT overridable

-- FRED On Mission Specs Save:
--   Invoked when the Mission Specs dialog OK Button has been hit and all data is sucessfully saved.
--   This hook is NOT overridable

-- On Action:
--   Invoked whenever a user action was invoked through control input.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Action string The name of the action that was executed.
--
--   Hook-specific Conditions:
--
--      Action
--         Description: Specifies the action triggered by a keypress.
--

-- On Action Stopped:
--   Invoked whenever a user action is no longer invoked through control input.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Action string The name of the action that was stopped.
--
--   Hook-specific Conditions:
--
--      Action
--         Description: Specifies the action triggered by a keypress.
--

-- On Afterburner Engage:
--   Invoked whenever a ship engages its afterburners
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship engaging its afterburners
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Afterburner Stop:
--   Invoked whenever a ship stops using its afterburners
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship which had been using its afterburners
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Asteroid Collision:
--   Invoked when an asteroid collides with another object.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The "other" object that collided with the asteroid.
--- Object object The asteroid object with which the "other" object collided with. Provided for consistency with other collision hooks.
--- Asteroid object Same as "Object"
--- Hitpos vector The world position where the collision was detected
--- Debris object The debris object with which the asteroid collided (only set for debris collisions)
--- Ship ship The ship object with which the asteroid collided (only set for ship collisions)
--- Weapon weapon The weapon object with which the asteroid collided (only set for weapon collisions)
--- Beam weapon The beam object with which the asteroid collided (only set for beam collisions)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Ship
--         Description: Specifies the name of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Weapon class
--         Description: Specifies the name of the weapon class which was part of the collision. At least one weapon must be part of the collision and match.
--      Ship type
--         Description: Specifies the type of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Object type
--         Description: Specifies the type of the object which was part of the collision. At least one object must match.
--

-- On Asteroid Created:
--   Called when an asteroid has been created.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Asteroid asteroid The asteroid that was created.
--

-- On Asteroid Death:
--   Called when an asteroid has been destroyed.  Supersedes On Death for asteroids.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Asteroid asteroid The asteroid that was destroyed.
--- Hitpos vector The world coordinates of the killing blow.
--

-- On Beam Collision:
--   Invoked when a beam collides with another object.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The "other" object that collided with the beam.
--- Object weapon The beam object with which the "other" object collided with. Provided for consistency with other collision hooks.
--- Beam weapon Same as "Object"
--- Hitpos vector The world position where the collision was detected
--- Debris object The debris object with which the beam collided (only set for debris collisions)
--- Ship ship The ship object with which the beam collided (only set for ship collisions)
--- Asteroid object The asteroid object with which the beam collided (only set for asteroid collisions)
--- Weapon weapon The weapon object with which the beam collided (only set for weapon collisions)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Ship
--         Description: Specifies the name of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Weapon class
--         Description: Specifies the name of the weapon class which was part of the collision. At least one weapon must be part of the collision and match.
--      Ship type
--         Description: Specifies the type of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Object type
--         Description: Specifies the type of the object which was part of the collision. At least one object must match.
--

-- On Beam Death:
--   Called when a beam has been removed from the mission (whether by finishing firing, destruction of turret, etc.).
--   This hook is NOT overridable
--   Hook Variables:
--
--- Beam beam The beam that was removed.
--

-- On Beam Fire:
--   Invoked when a beam starts firing (after warming up).
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that is firing the beam.
--- Beam beam The spawned beam object.
--- Target object The current target of the shot.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Beam Warmdown:
--   Invoked when a beam starts "warming down" after firing.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that is firing the beam.
--- Beam beam The spawned beam object.
--- Target object The current target of the shot.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Beam Warmup:
--   Invoked when a beam starts warming up to fire.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that is firing the beam.
--- Beam beam The spawned beam object.
--- Target object The current target of the shot.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Briefing Stage:
--   Invoked for each briefing stage what it is shown.
--   This hook is NOT overridable
--   Hook Variables:
--
--- OldStage number The index of the previous briefing stage.
--- NewStage number The index of the new briefing stage.
--

-- On Camera Set Up:
--   Called every frame when the camera is positioned and oriented for rendering.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Camera camera The camera about to be used for rendering.
--

-- On Campaign Begin:
--   Called when a campaign is started from the beginning or is reset
--   This hook is NOT overridable
--   Hook Variables:
--
--- Campaign string The campaign filename (without the extension)
--

-- On Campaign Mission Accept:
--   Invoked after a campaign mission once the player accepts the result and moves on to the next mission instead of replaying it.
--   This hook is NOT overridable

-- On Cheat:
--   Called when a cheat is used
--   This hook is NOT overridable
--   Hook Variables:
--
--- Cheat string The cheat code the user typed
--

-- On Countermeasure Fire:
--   Called when a ship fires a countermeasure.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship that has fired the countermeasure.
--- CountermeasuresLeft number The number of countermeasures left on the ship after firing the current countermeasure.
--- Countermeasure weapon The countermeasure object that was just fired.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Death:
--   Invoked when an object (ship or asteroid) has been destroyed.  Deprecated in favor of On Ship Death and On Asteroid Death.
--   This hook is overridable
--   DEPRECATED starting with version 23.0.0.
--   Hook Variables:
--
--- Self object The object that was killed
--- Ship ship The ship that was destroyed (only set for ships)
--- Killer object The object that caused the death (only set for ships)
--- Hitpos vector The position of the hit that caused the death (only set for ships and only if available)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that died.
--      Ship
--         Description: Specifies the name of the ship that died.
--      Weapon class
--         Description: Specifies the class of the weapon that died.
--      Ship type
--         Description: Specifies the type of the ship that died.
--      Object type
--         Description: Specifies the type of the object that died.
--

-- On Debris Collision:
--   Invoked when a debris piece collides with another object.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The "other" object that collided with the debris.
--- Object debris The debris object with which the "other" object collided with. Provided for consistency with other collision hooks.
--- Debris debris Same as "Object"
--- Hitpos vector The world position where the collision was detected
--- Asteroid object The asteroid object with which the debris collided (only set for asteroid collisions)
--- Ship ship The ship object with which the debris collided (only set for ship collisions).
--- Weapon weapon The weapon object with which the debris collided (only set for weapon collisions)
--- Beam weapon The beam object with which the debris collided (only set for beam collisions)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Ship
--         Description: Specifies the name of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Weapon class
--         Description: Specifies the name of the weapon class which was part of the collision. At least one weapon must be part of the collision and match.
--      Ship type
--         Description: Specifies the type of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Object type
--         Description: Specifies the type of the object which was part of the collision. At least one object must match.
--

-- On Debris Created:
--   Invoked when a piece of debris is created.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Debris debris The newly created debris object
--- Source object The object (probably a ship) from which this debris piece was spawned.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Debris Death:
--   Called when a piece of debris has been destroyed.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Debris debris The piece of debris that was destroyed.
--- Hitpos vector The world coordinates of the killing blow.  Could be nil.
--

-- On Departure Started:
--   Called when a ship starts the departure process.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Self ship An alias for Ship.
--- Ship ship The ship that has begun the departure process.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that departed.
--      Ship
--         Description: Specifies the name of the ship that departed.
--      Ship type
--         Description: Specifies the type of the ship that departed.
--

-- On Dialog Close:
--   Invoked when a dialog closes.
--   This hook is NOT overridable
--   Hook Variables:
--
--- IsDeathPopup boolean True if this popup is an in-mission death popup and should be styled as such.
--

-- On Dialog Frame:
--   Invoked each frame for a system dialog. Override to prevent the system dialog from rendering and evaluating.
--   This hook is overridable
--   Hook Variables:
--
--- Submit function(number | string | nil result) -> nil A callback function that should be called if the popup resolves. Should be string only if it is an input popup. Pass nil to abort.
--- IsDeathPopup boolean True if this popup is an in-mission death popup and should be styled as such.
--- Freeze boolean If not nil and true, the popup should not process any inputs but just render.
--

-- On Dialog Init:
--   Invoked when a system dialog initializes. Override to prevent the system dialog from loading dialog-related resources (requires retail files)
--   This hook is overridable
--   Hook Variables:
--
--- Choices table A table containing the different choices for this dialog. Contains subtables, each consisting of Positivity (an int, 0 if neutral, 1 if positive, and -1 if negative), Text (a string, the text of the button), and Shorcut (a string, the keypress that should activate the choice or nil if no valid shortcut).
--- Title string The title of the popup window. Nil for a death popup.
--- Text string The text to be displayed in the popup window. Nil for a death popup.
--- IsTimeStopped boolean True if mission time was interrupted for this popup.
--- IsStateRunning boolean True if the underlying state is still being processed and rendered.
--- IsInputPopup boolean True if this popup is for entering text.
--- IsDeathPopup boolean True if this popup is an in-mission death popup and should be styled as such.
--- AllowedInput string A string of characters allowed to be present in the input popup. Nil if not an input popup.
--- DeathMessage string The death message if the dialog is a death popup. Nil if not a death popup.
--

-- On Frame:
--   Called every frame as the last action before showing the frame result to the user.
--   This hook is overridable

-- On Game Init:
--   Executed at the start of the engine after all game data has been loaded.
--   This hook is NOT overridable

-- On Gameplay Start:
--   Invoked when the gameplay portion of a mission starts.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Player object The player object.
--

-- On Goals Cleared:
--   Invoked whenever a ship has its goals cleared.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship whose goals are cleared.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On HUD Comm Menu Closed:
--   Invoked when the HUD comm menu, or squad message menu, is hidden.
--   This hook is overridable
--   Hook Variables:
--
--- Player object The player object.
--

-- On HUD Comm Menu Opened:
--   Invoked when the HUD comm menu, or squad message menu, is displayed.
--   This hook is overridable
--   Hook Variables:
--
--- Player object The player object.
--

-- On HUD Draw:
--   Invoked when the HUD is rendered.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The object from which the scene is viewed.
--- Player object The player object.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was drawn / drawn from.
--      Ship
--         Description: Specifies the name of the ship that was drawn / drawn from.
--      Weapon class
--         Description: Specifies the class of the weapon that was drawn / drawn from.
--      Ship type
--         Description: Specifies the type of the ship that was drawn / drawn from.
--      Object type
--         Description: Specifies the type of the object that was drawn / drawn from.
--

-- On HUD Message Received:
--   Called when a HUD message is received. For normal messages this will be called with the final text that appears on the HUD (e.g. [ship]: [message]). Will also be called for engine generated messages.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Text string The text of the message.
--- SourceType number The type of message sent by the engine.
--

-- On Intro About To Play:
--   Executed just before the intro movie is played.
--   This hook is overridable

-- On Key Pressed:
--   Invoked whenever a key is pressed. If overridden, FSO behaves as if this key has simply not been pressed. The only thing that FSO will do with this key if overridden is fire the corresponding OnKeyReleased hook once the key is released. Be especially careful if overriding modifier keys (such as Alt and Shift) with this.
--   This hook is overridable
--   Hook Variables:
--
--- Key string The scancode of the key that has been pressed.
--- RawKey string The scancode of the key that has been pressed, without modifiers applied.
--
--   Hook-specific Conditions:
--
--      Raw KeyPress
--         Description: The key that is pressed, with no consideration for any modifier keys.
--

-- On Key Released:
--   Invoked whenever a key is released.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Key string The scancode of the key that has been pressed.
--- RawKey string The scancode of the key that has been pressed, without modifiers applied.
--- TimeHeld number The time that this key has been held down in milliseconds. Can be 0 if input latency fluctuates.
--- WasOverridden boolean Whether or not the key press corresponding to this release was overridden.
--
--   Hook-specific Conditions:
--
--      Raw KeyPress
--         Description: The key that is pressed, with no consideration for any modifier keys.
--

-- On Load Complete:
--   Executed once a mission load has completed.
--   This hook is NOT overridable

-- On Load Screen:
--   Executed regularly during loading of a mission.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Progress number A number from 0 to 1 indicating how far along the loading process the game is.
--

-- On Loadout About To Parse:
--   Called during mission load just before parsing the team loadout.
--   This hook is NOT overridable

-- On Message Received:
--   Invoked when a mission sends a message.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Name string The name of the message in the mission
--- Message string The text of the sent message. This will have any placeholder expanded (e.g. SEXP variables) and will be what the player sees on the HUD.
--- SenderString string The source of the message as a string. Same as used by the engine on the HUD.
--- Builtin boolean true if this is a builtin message, false of this is a mission message
--- Sender ship If sent from an object, the object that has sent the message. Invalid if not sent from an object
--- MessageHandle message The scripting handle of the message being sent.
--

-- On Missile Death:
--   Called when a missile has been destroyed (whether by impact, interception, or expiration).
--   This hook is NOT overridable
--   Hook Variables:
--
--- Weapon weapon The weapon that was destroyed.
--- Object object The object that the weapon hit - a ship, asteroid, or piece of debris.  Always set but could be invalid if there is no other object.  If this missile was destroyed by another weapon, the 'other object' will be invalid but the DestroyedByWeapon flag will be set.
--
--   Hook-specific Conditions:
--
--      Weapon class
--         Description: Specifies the class of the weapon that died.
--

-- On Missile Death Started:
--   Called when a missile is about to be destroyed (whether by impact, interception, or expiration).
--   This hook is NOT overridable
--   Hook Variables:
--
--- Weapon weapon The weapon that was destroyed.
--- Object object The object that the weapon hit - a ship, asteroid, or piece of debris.  Always set but could be invalid if there is no other object.  If this missile was destroyed by another weapon, the 'other object' will be invalid but the DestroyedByWeapon flag will be set.
--
--   Hook-specific Conditions:
--
--      Weapon class
--         Description: Specifies the class of the weapon that died.
--

-- On Mission About To End:
--   Called when a mission is about to end but has not run any mission-ending logic
--   This hook is NOT overridable

-- On Mission End:
--   Called when a mission has ended
--   This hook is overridable

-- On Mission Start:
--   Invoked when a mission starts.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Player object The player object.
--

-- On Mouse Moved:
--   Invoked whenever the mouse is moved.
--   This hook is NOT overridable

-- On Mouse Pressed:
--   Invoked whenever a mouse button is pressed.
--   This hook is NOT overridable

-- On Mouse Released:
--   Invoked whenever a mouse button is released.
--   This hook is NOT overridable

-- On Mouse Wheel:
--   Called when the mouse wheel is moved in any direction.
--   This hook is NOT overridable
--   Hook Variables:
--
--- MouseWheelY number Positive if moved up, negative if moved down.
--- MouseWheelX number Positive if moved right, negative if moved left.
--

-- On Movie About To Play:
--   Executed just before any cutscene movie is played.
--   This hook is overridable
--   Hook Variables:
--
--- Filename string The filename of the movie that is about to play.
--- ViaTechRoom boolean Whether the movie player was invoked through the tech room.
--

-- On Object Render:
--   Invoked every time an object is rendered.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The object which is rendered.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was drawn / drawn from.
--      Ship
--         Description: Specifies the name of the ship that was drawn / drawn from.
--      Weapon class
--         Description: Specifies the class of the weapon that was drawn / drawn from.
--      Ship type
--         Description: Specifies the type of the ship that was drawn / drawn from.
--      Object type
--         Description: Specifies the type of the object that was drawn / drawn from.
--

-- On Pain Flash:
--   Called when a pain flash is displayed.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Pain_Type number The type of pain flash displayed: shield = 0 and hull = 1.
--

-- On Player Loaded:
--   Called when a player has been successfully loaded
--   This hook is NOT overridable
--   Hook Variables:
--
--- Player object The player object
--

-- On Primary Fire:
--   Invoked when a primary weapon is fired.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has fired the weapon.
--- Target object The current target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Secondary Fire:
--   Invoked when a secondary weapon is fired.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has fired the weapon.
--- Target object The current target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Ship Arrive:
--   Invoked when a ship arrives in mission.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship that has arrived.
--- Parent object The object which serves as the arrival anchor of the ship. Could be nil.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that arrived.
--      Ship
--         Description: Specifies the name of the ship that arrived.
--      Ship type
--         Description: Specifies the type of the ship that arrived.
--

-- On Ship Collision:
--   Invoked when a ship collides with another object. Note: When two ships collide this will be called twice, once with each ship as the "Self" parameter.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The object the ship collided with.
--- Object ship The ship that collided with "Self". Provided for consistency with other collision hooks.
--- Ship ship For ship-on-ship collisions, the same as "Self". For ship-on-object collisions, the same as "Object".
--- Hitpos vector The world position where the collision was detected
--- ShipSubmodel submodel The submodel of "Ship" involved in the collision, if "Ship" was the heavier object
--- Debris object The debris object with which the ship collided (only set for debris collisions)
--- Asteroid object The asteroid object with which the ship collided (only set for asteroid collisions)
--- ShipB ship For ship-on-ship collisions, the same as "Object" (only set for ship-on-ship collisions)
--- ShipBSubmodel submodel For ship-on-ship collisions, the submodel of "ShipB" involved in the collision, if "ShipB" was the heavier object
--- Weapon weapon The weapon object with which the ship collided (only set for weapon collisions)
--- Beam weapon The beam object with which the ship collided (only set for beam collisions)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Ship
--         Description: Specifies the name of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Weapon class
--         Description: Specifies the name of the weapon class which was part of the collision. At least one weapon must be part of the collision and match.
--      Ship type
--         Description: Specifies the type of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Object type
--         Description: Specifies the type of the object which was part of the collision. At least one object must match.
--

-- On Ship Death:
--   Called when a ship has been destroyed.  Supersedes On Death for ships.
--   This hook is overridable
--   Hook Variables:
--
--- Ship ship The ship that was destroyed.
--- Killer object The object responsible for killing the ship.  Always set but could be invalid if there is no killer.
--- Hitpos vector The world coordinates of the killing blow.  Could be nil.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that died.
--      Ship
--         Description: Specifies the name of the ship that died.
--      Ship type
--         Description: Specifies the type of the ship that died.
--

-- On Ship Death Started:
--   Called when a ship starts the death process.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship that has begun the death process.
--- Killer object The object responsible for killing the ship.  Always set but could be invalid if there is no killer.
--- Hitpos vector The world coordinates of the killing blow.  Could be nil.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that died.
--      Ship
--         Description: Specifies the name of the ship that died.
--      Ship type
--         Description: Specifies the type of the ship that died.
--

-- On Ship Depart:
--   Invoked when a ship departs the mission without being destroyed.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship departing the mission
--- JumpNode string The name of the jump node the ship jumped out of. Can be nil.
--- Method ship The name of the method the ship used to depart. One of: 'SHIP_DEPARTED', 'SHIP_DEPARTED_WARP', 'SHIP_DEPARTED_BAY', 'SHIP_VANISHED', 'SHIP_DEPARTED_REDALERT'.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that departed.
--      Ship
--         Description: Specifies the name of the ship that departed.
--      Ship type
--         Description: Specifies the type of the ship that departed.
--

-- On Simulation:
--   Invoked every time that FSO processes physics and AI.
--   This hook is NOT overridable

-- On Splash End:
--   Executed just after the splash screen fades out.
--   This hook is NOT overridable

-- On Splash Screen:
--   Will be called once when the splash screen shows for the first time.
--   This hook is overridable
--   DEPRECATED (+Override removed) starting with version 23.0.0.

-- On State About To End:
--   Called when a game state is about to end but has not run any state-ending logic
--   This hook is NOT overridable
--   Hook Variables:
--
--- OldState gamestate The game state that has ended.
--- NewState gamestate The game state that will begin next.
--

-- On State End:
--   Called when a game state has ended
--   This hook is overridable
--   Hook Variables:
--
--- OldState gamestate The game state that has ended.
--- NewState gamestate The game state that will begin next.
--

-- On State Start:
--   Executed whenever a new state is entered.
--   This hook is overridable
--   Hook Variables:
--
--- OldState gamestate The gamestate that was executing.
--- NewState gamestate The gamestate that will be executing.
--

-- On Subsystem Destroyed:
--   Called when a subsystem is destroyed.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship that held the subsystem.
--- Subsystem subsystem The subsystem that has been destroyed.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship whose subsystem got destroyed.
--      Ship
--         Description: Specifies the name of the ship whose subsystem got destroyed.
--      Ship type
--         Description: Specifies the type of the ship whose subsystem got destroyed.
--

-- On Turret Fired:
--   Invoked when a turret is fired.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship that has fired the turret.
--- Weapon weapon The spawned weapon object (nil if the turret fired a beam).
--- Beam beam The spawned beam object (nil unless the turret fired a beam).
--- Target object The current target of the shot.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Warp In:
--   Called when a ship warps in.
--   This hook is overridable
--   Hook Variables:
--
--- Self ship The object that is warping in.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Warp Out:
--   Called when a ship warps out.
--   This hook is overridable
--   Hook Variables:
--
--- Self ship The object that is warping out.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Warp Out Complete:
--   Called when a ship has completed the warp out animation
--   This hook is overridable
--   Hook Variables:
--
--- Self ship The object that is warping out.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Waypoints Done:
--   Invoked whenever a ship stops using its afterburners
--   This hook is NOT overridable
--   Hook Variables:
--
--- Ship ship The ship which has completed the waypoints.
--- Wing wing The wing which the ship belongs to. Can be invalid.
--- Waypointlist waypointlist The set of waypoints which was completed.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that was the source of the event.
--      Ship
--         Description: Specifies the name of the ship that was the source of the event.
--      Ship type
--         Description: Specifies the type of the ship that was the source of the event.
--

-- On Weapon Collision:
--   Invoked when a weapon collides with another object. Note: When two weapons collide this will be called twice, once with each weapon object as the "Weapon" parameter.
--   This hook is overridable
--   Hook Variables:
--
--- Self object The "other" object that collided with the weapon.
--- Object weapon The weapon object with which the "other" object collided with. Provided for consistency with other collision hooks.
--- Weapon weapon Same as "Object"
--- Hitpos vector The world position where the collision was detected
--- Debris object The debris object with which the weapon collided (only set for debris collisions)
--- Asteroid object The asteroid object with which the weapon collided (only set for asteroid collisions)
--- Ship ship The ship object with which the weapon collided (only set for ship collisions).
--- WeaponB weapon For weapon on weapon collisions, the "other" weapon.
--- Beam weapon The beam object with which the weapon collided (only set for beam collisions)
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Ship
--         Description: Specifies the name of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Weapon class
--         Description: Specifies the name of the weapon class which was part of the collision. At least one weapon must be part of the collision and match.
--      Ship type
--         Description: Specifies the type of the ship which was part of the collision. At least one ship must be part of the collision and match.
--      Object type
--         Description: Specifies the type of the object which was part of the collision. At least one object must match.
--

-- On Weapon Created:
--   Invoked every time a weapon object is created.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Weapon weapon The weapon object.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--      Object type
--         Description: Specifies the type of the object that is the parent of this weapon.
--

-- On Weapon Delete:
--   Invoked whenever a weapon is deleted from the scene.
--   This hook is NOT overridable
--   Hook Variables:
--
--- Weapon weapon The weapon that was deleted.
--- Self weapon An alias for "Weapon".
--
--   Hook-specific Conditions:
--
--      Weapon class
--         Description: Specifies the class of the weapon that died.
--

-- On Weapon Deselected:
--   Invoked when a weapon is deselected.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has deselected the weapon.
--- Target object The current target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that has deselected the weapon.
--      Ship
--         Description: Specifies the name of the ship that has deselected the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was deselected.
--      Ship type
--         Description: Specifies the type of the ship that has deselected the weapon.
--

-- On Weapon Equipped:
--   Invoked for each ship for each frame, allowing to be filtered for whether a weapon is equipped by the ship using conditions.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has a weapon equipped.
--- Target object The current AI target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that has the weapon equipped.
--      Ship
--         Description: Specifies the name of the ship that has the weapon equipped.
--      Weapon class
--         Description: Specifies the class of the weapon that the ship needs to have equipped in at least one bank.
--      Ship type
--         Description: Specifies the type of the ship that has the weapon equipped.
--

-- On Weapon Fired:
--   Invoked when a weapon is fired.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has fired the weapon.
--- Target object The current target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that fired the weapon.
--      Ship
--         Description: Specifies the name of the ship that fired the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was fired.
--      Ship type
--         Description: Specifies the type of the ship that fired the weapon.
--

-- On Weapon Selected:
--   Invoked when a new weapon is selected.
--   This hook is NOT overridable
--   Hook Variables:
--
--- User ship The ship that has selected the weapon.
--- Target object The current target of this ship.
--
--   Hook-specific Conditions:
--
--      Ship class
--         Description: Specifies the class of the ship that has selected the weapon.
--      Ship
--         Description: Specifies the name of the ship that has selected the weapon.
--      Weapon class
--         Description: Specifies the class of the weapon that was selected.
--      Ship type
--         Description: Specifies the type of the ship that has selected the weapon.
--

-- Global Hook Variables (accessible through 'hv'):
--- @type table
hv = {}
--
--- Player object The player object in a mission. Does not need to be a ship (e.g. in multiplayer). Not present if not in a game play state.
--
--
--
-- active_game object: Active Game handle
active_game = {}
--- @class active_game
--- @field active_game.Status string The status of the game The status
--- @field active_game.Type string The type of the game The type
--- @field active_game.Speed string The speed of the game The speed
--- @field active_game.Standalone boolean Whether or not the game is standalone True for standalone, false otherwise
--- @field active_game.Campaign boolean Whether or not the game is campaign True for campaign, false otherwise
--- @field active_game.Server string The server name of the game The server
--- @field active_game.Mission string The mission name of the game The mission
--- @field active_game.Ping number The ping average of the game The ping
--- @field active_game.Players number The number of players in the game The number of players
--Detects whether handle is valid
--- @function active_game:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function active_game:isValid()end

--Sets the specified game as the selected game to possibly join. Must be used before sendJoinRequest will work.
--- @function active_game:setSelected(): nothing
--- @return nil
function active_game:setSelected()end

-- ai_helper object: A helper object to access functions for ship manipulation during AI phase
ai_helper = {}
--- @class ai_helper
--- @field ai_helper.Ship ship The ship this AI runs for The ship, or invalid ship if the handle is invalid
--- @field ai_helper.Pitch number The pitch thrust rate for the ship this frame, -1 to 1 The pitch rate, or 0 if the handle is invalid
--- @field ai_helper.Bank number The bank thrust rate for the ship this frame, -1 to 1 The bank rate, or 0 if the handle is invalid
--- @field ai_helper.Heading number The heading thrust rate for the ship this frame, -1 to 1 The heading rate, or 0 if the handle is invalid
--- @field ai_helper.ForwardThrust number The forward thrust rate for the ship this frame, -1 to 1 The forward thrust rate, or 0 if the handle is invalid
--- @field ai_helper.VerticalThrust number The vertical thrust rate for the ship this frame, -1 to 1 The vertical thrust rate, or 0 if the handle is invalid
--- @field ai_helper.SidewaysThrust number The sideways thrust rate for the ship this frame, -1 to 1 The sideways thrust rate, or 0 if the handle is invalid
--turns the ship towards the specified point during this frame
--- @function ai_helper:turnTowardsPoint(target: vector, respectDifficulty: boolean, turnrateModifier: vector, bank: number): nothing
--- @param target vector 
--- @param respectDifficulty boolean? 
--- @param turnrateModifier vector? 100% of tabled values in all rotation axes by default
--- @param bank number? native bank-on-heading by default
--- @return nil
function ai_helper:turnTowardsPoint(target, respectDifficulty, turnrateModifier, bank)end

--turns the ship towards the specified orientation during this frame
--- @function ai_helper:turnTowardsOrientation(target: orientation, respectDifficulty: boolean, turnrateModifier: vector): nothing
--- @param target orientation 
--- @param respectDifficulty boolean? 
--- @param turnrateModifier vector? 100% of tabled values in all rotation axes by default
--- @return nil
function ai_helper:turnTowardsOrientation(target, respectDifficulty, turnrateModifier)end

-- animation_handle object: A handle for animation instances
animation_handle = {}
--- @class animation_handle
--Triggers an animation. Forwards controls the direction of the animation. ResetOnStart will cause the animation to play from its initial state, as opposed to its current state. CompleteInstant will immediately complete the animation. Pause will instead stop the animation at the current state.
--- @function animation_handle:start(forwards: boolean, resetOnStart: boolean, completeInstant: boolean, pause: boolean): boolean
--- @param forwards boolean? 
--- @param resetOnStart boolean? 
--- @param completeInstant boolean? 
--- @param pause boolean? 
--- @return boolean # True if successful, false if no animation was started or nil on failure
function animation_handle:start(forwards, resetOnStart, completeInstant, pause)end

--Returns the total duration of this animation, unaffected by the speed set, in seconds.
--- @function animation_handle:getTime(): number
--- @return number # The time this animation will take to complete
function animation_handle:getTime()end

--Will stop this looping animation on its next repeat.
--- @function animation_handle:stopNextLoop(): nothing
--- @return nil
function animation_handle:stopNextLoop()end

-- asteroid object: Asteroid handle
asteroid = {}
--- @class asteroid
--- @field asteroid.Target object Asteroid target object; may be object derivative, such as ship. Target object, or invalid handle if asteroid handle is invalid
--Kills the asteroid. Set "killer" to designate a specific ship as having been the killer, and "hitpos" to specify the world position of the hit location; if nil, the asteroid center is used.
--- @function asteroid:kill(killer: ship, hitpos: vector): boolean
--- @param killer ship? 
--- @param hitpos vector? 
--- @return boolean # True if successful, false or nil otherwise
function asteroid:kill(killer, hitpos)end

-- audio_stream object: An audio stream handle
audio_stream = {}
--- @class audio_stream
--Starts playing the audio stream
--- @function audio_stream:play(volume: number, loop: boolean): boolean
--- @param volume number? By default sets the last used volume of this stream, if applicable. Otherwise, uses preset volume of the stream type
--- @param loop boolean? 
--- @return boolean # true on success, false otherwise
function audio_stream:play(volume, loop)end

--Pauses the audio stream
--- @function audio_stream:pause(): boolean
--- @return boolean # true on success, false otherwise
function audio_stream:pause()end

--Unpauses the audio stream
--- @function audio_stream:unpause(): boolean
--- @return boolean # true on success, false otherwise
function audio_stream:unpause()end

--Stops the audio stream so that it can be started again later
--- @function audio_stream:stop(): boolean
--- @return boolean # true on success, false otherwise
function audio_stream:stop()end

--Irrevocably closes the audio file and optionally fades the music before stopping playback. This invalidates the audio stream handle.
--- @function audio_stream:close(fade: boolean): boolean
--- @param fade boolean? 
--- @return boolean # true on success, false otherwise
function audio_stream:close(fade)end

--Determines if the audio stream is still playing
--- @function audio_stream:isPlaying(): boolean
--- @return boolean # true when still playing, false otherwise
function audio_stream:isPlaying()end

--Sets the volume of the audio stream, 0 - 1
--- @function audio_stream:setVolume(volume: number): boolean
--- @param volume number 
--- @return boolean # true on success, false otherwise
function audio_stream:setVolume(volume)end

--Gets the duration of the stream
--- @function audio_stream:getDuration(): number
--- @return number # the duration in float seconds or nil if invalid
function audio_stream:getDuration()end

--Determines if the handle is valid
--- @function audio_stream:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function audio_stream:isValid()end

-- background_element object: Background element handle
background_element = {}
--- @class background_element
--- @field background_element.Orientation orientation Backround element orientation (treating the angles as correctly calculated) Orientation, or null orientation if handle is invalid
--- @field background_element.DivX number Division X Division X, or 0 if handle is invalid
--- @field background_element.DivY number Division Y Division Y, or 0 if handle is invalid
--- @field background_element.ScaleX number Scale X Scale X, or 0 if handle is invalid
--- @field background_element.ScaleY number Scale Y Scale Y, or 0 if handle is invalid
--Determines if this handle is valid
--- @function background_element:isValid(): boolean
--- @return boolean # true if valid, false if not.
function background_element:isValid()end

--Sets Division X and Division Y at the same time.  For Bitmaps this avoids a double recalculation of the vertex buffer, if both values need to be set.  For all background elements this also avoids fetching and setting the data twice.
--- @function background_element:setDiv(param1: number, param2: number): boolean
--- @param param1 number 
--- @param param2 number 
--- @return boolean # True if the operation was successful
function background_element:setDiv(param1, param2)end

--Sets Scale X and Scale Y at the same time.  For Bitmaps this avoids a double recalculation of the vertex buffer, if both values need to be set.  For all background elements this also avoids fetching and setting the data twice.
--- @function background_element:setScale(param1: number, param2: number): boolean
--- @param param1 number 
--- @param param2 number 
--- @return boolean # True if the operation was successful
function background_element:setScale(param1, param2)end

--Sets Scale X, Scale Y, Division X, and Division Y at the same time.  For Bitmaps this avoids a quadruple recalculation of the vertex buffer, if all four values need to be set.  For all background elements this also avoids fetching and setting the data four times.
--- @function background_element:setScaleAndDiv(param1: number, param2: number, param3: number, param4: number): boolean
--- @param param1 number 
--- @param param2 number 
--- @param param3 number 
--- @param param4 number 
--- @return boolean # True if the operation was successful
function background_element:setScaleAndDiv(param1, param2, param3, param4)end

-- beam object: Beam handle
beam = {}
--- @class beam
--- @field beam.Class weaponclass Weapon's class Weapon class, or invalid weaponclass handle if beam handle is invalid
--- @field beam.LastShot vector End point of the beam vector or null vector if beam handle is not valid
--- @field beam.LastStart vector Start point of the beam vector or null vector if beam handle is not valid
--- @field beam.Target object Target of beam. Value may also be a deriviative of the 'object' class, such as 'ship'. Beam target, or invalid object handle if beam handle is invalid
--- @field beam.TargetSubsystem subsystem Subsystem that beam is targeting. Target subsystem, or invalid subsystem handle if beam handle is invalid
--- @field beam.ParentShip object Parent of the beam. Beam parent, or invalid object handle if beam handle is invalid
--- @field beam.ParentSubsystem subsystem Subsystem that beam is fired from. Parent subsystem, or invalid subsystem handle if beam handle is invalid
--- @field beam.Team team Beam's team Beam team, or invalid team handle if beam handle is invalid
--Get the number of collisions in frame.
--- @function beam:getCollisionCount(): number
--- @return number # Number of beam collisions
function beam:getCollisionCount()end

--Get the position of the defined collision.
--- @function beam:getCollisionPosition(param1: number): vector
--- @param param1 number 
--- @return vector # World vector
function beam:getCollisionPosition(param1)end

--Get the collision information of the specified collision
--- @function beam:getCollisionInformation(param1: number): collision_info
--- @param param1 number 
--- @return collision_info # handle to information or invalid handle on error
function beam:getCollisionInformation(param1)end

--Get the target of the defined collision.
--- @function beam:getCollisionObject(param1: number): object
--- @param param1 number 
--- @return object # Object the beam collided with
function beam:getCollisionObject(param1)end

--Checks if the defined collision was exit collision.
--- @function beam:isExitCollision(param1: number): boolean
--- @param param1 number 
--- @return boolean # True if the collision was exit collision, false if entry, nil otherwise
function beam:isExitCollision(param1)end

--Gets the start information about the direction. The vector is a normalized vector from LastStart showing the start direction of a slashing beam
--- @function beam:getStartDirectionInfo(): vector
--- @return vector # The start direction or null vector if invalid
function beam:getStartDirectionInfo()end

--Gets the end information about the direction. The vector is a normalized vector from LastStart showing the end direction of a slashing beam
--- @function beam:getEndDirectionInfo(): vector
--- @return vector # The start direction or null vector if invalid
function beam:getEndDirectionInfo()end

--Vanishes this beam from the mission.
--- @function beam:vanish(): boolean
--- @return boolean # True if the deletion was successful, false otherwise.
function beam:vanish()end

-- briefing object: Briefing handle
briefing = {}
--- @class briefing
--The list of stages in the briefing.
--- @function briefing:__indexer(index: number): briefing_stage
--- @param index number 
--- @return briefing_stage # The stage at the specified location.
function briefing:__indexer(index)end

--The number of stages in the briefing
--- @function briefing:__len(): number
--- @return number # The number of stages.
function briefing:__len()end

-- briefing_stage object: Briefing stage handle
briefing_stage = {}
--- @class briefing_stage
--- @field briefing_stage.Text string The text of the stage The text
--- @field briefing_stage.AudioFilename string The filename of the audio file to play The file name
--- @field briefing_stage.hasForwardCut boolean If the stage has a forward cut flag true if the stage is set to cut to the next stage, false otherwise
--- @field briefing_stage.hasBackwardCut boolean If the stage has a backward cut flag true if the stage is set to cut to the previous stage, false otherwise
-- bytearray object: An array of binary data
bytearray = {}
--- @class bytearray
--The number of bytes in this array
--- @function bytearray:__len(): number
--- @return number # The length in bytes
function bytearray:__len()end

-- camera object: Camera handle
camera = {}
--- @class camera
--- @field camera.Name string New camera name Camera name
--- @field camera.FOV number New camera FOV (in radians) Camera FOV (in radians)
--- @field camera.Orientation orientation New camera orientation Camera orientation
--- @field camera.Position vector New camera position Camera position
--- @field camera.Self object New mount object Camera object
--- @field camera.SelfSubsystem subsystem New mount object subsystem Subsystem that the camera is mounted on
--- @field camera.Target object New target object Camera target object
--- @field camera.TargetSubsystem subsystem New target subsystem Subsystem that the camera is pointed at
--Camera name
--- @function camera:__tostring(): string
--- @return string # Camera name, or an empty string if handle is invalid
function camera:__tostring()end

--True if valid, false or nil if not
--- @function camera:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function camera:isValid()end

--Sets camera FOV<br>FOV is the final field of view, in radians, of the camera.<br>Zoom Time is the total time to take zooming in or out.<br>Acceleration Time is the total time it should take the camera to get up to full zoom speed.<br>Deceleration Time is the total time it should take the camera to slow down from full zoom speed.
--- @function camera:setFOV(FOV: number, ZoomTime: number, ZoomAccelerationTime: number, ZoomDecelerationTime: number): boolean
--- @param FOV number? 
--- @param ZoomTime number? 
--- @param ZoomAccelerationTime number? 
--- @param ZoomDecelerationTime number? 
--- @return boolean # true if successful, false or nil otherwise
function camera:setFOV(FOV, ZoomTime, ZoomAccelerationTime, ZoomDecelerationTime)end

--Sets camera orientation and velocity data.<br>Orientation is the final orientation for the camera, after it has finished moving. If not specified, the camera will simply stop at its current orientation.<br>Rotation time (seconds) is how long total, including acceleration, the camera should take to rotate. If it is not specified, the camera will jump to the specified orientation.<br>Acceleration time (seconds) is how long it should take the camera to get 'up to speed'. If not specified, the camera will instantly start moving.<br>Deceleration time (seconds) is how long it should take the camera to slow down. If not specified, the camera will instantly stop moving.
--- @function camera:setOrientation(WorldOrientation: orientation, RotationTime: number, AccelerationTime: number, DecelerationTime: number): boolean
--- @param WorldOrientation orientation? 
--- @param RotationTime number? 
--- @param AccelerationTime number? 
--- @param DecelerationTime number? 
--- @return boolean # true if successful, false or nil otherwise
function camera:setOrientation(WorldOrientation, RotationTime, AccelerationTime, DecelerationTime)end

--Sets camera position and velocity data.<br>Position is the final position for the camera. If not specified, the camera will simply stop at its current position.<br>Translation time (seconds) is how long total, including acceleration, the camera should take to move. If it is not specified, the camera will jump to the specified position.<br>Acceleration time (seconds) is how long it should take the camera to get 'up to speed'. If not specified, the camera will instantly start moving.<br>Deceleration time (seconds) is how long it should take the camera to slow down. If not specified, the camera will instantly stop moving.
--- @function camera:setPosition(Position: vector, TranslationTime: number, AccelerationTime: number, DecelerationTime: number): boolean
--- @param Position vector? 
--- @param TranslationTime number? 
--- @param AccelerationTime number? 
--- @param DecelerationTime number? 
--- @return boolean # true if successful, false or nil otherwise
function camera:setPosition(Position, TranslationTime, AccelerationTime, DecelerationTime)end

-- cmd_briefing object: Command briefing handle
cmd_briefing = {}
--- @class cmd_briefing
--The list of stages in the command briefing.
--- @function cmd_briefing:__indexer(index: number): cmd_briefing_stage
--- @param index number 
--- @return cmd_briefing_stage # The stage at the specified location.
function cmd_briefing:__indexer(index)end

--The number of stages in the command briefing
--- @function cmd_briefing:__len(): number
--- @return number # The number of stages.
function cmd_briefing:__len()end

-- cmd_briefing_stage object: Command briefing stage handle
cmd_briefing_stage = {}
--- @class cmd_briefing_stage
--- @field cmd_briefing_stage.Text string The text of the stage The text
--- @field cmd_briefing_stage.AniFilename string The filename of the animation to play The file name
--- @field cmd_briefing_stage.AudioFilename string The filename of the audio file to play The file name
-- cockpitdisplays object: Array of cockpit display information
cockpitdisplays = {}
--- @class cockpitdisplays
--Number of cockpit displays for this ship class
--- @function cockpitdisplays:__len(): number
--- @return number # number of cockpit displays or -1 on error
function cockpitdisplays:__len()end

--Returns the handle at the requested index or the handle with the specified name
--- @function cockpitdisplays:__indexer(param1: number | string): display_info
--- @param param1 number | string 
--- @return display_info # display handle or invalid handle on error
function cockpitdisplays:__indexer(param1)end

--Detects whether this handle is valid
--- @function cockpitdisplays:isValid(): boolean
--- @return boolean # true if valid, false otehrwise
function cockpitdisplays:isValid()end

-- collision_info object: Information about a collision
collision_info = {}
--- @class collision_info
--- @field collision_info.Model model The model this collision info is about The model, or an invalid model if the handle is not valid
--The submodel where the collision occurred, if applicable
--- @function collision_info:getCollisionSubmodel(): submodel
--- @return submodel # The submodel, or nil if none or if the handle is not valid
function collision_info:getCollisionSubmodel()end

--The distance to the closest collision point
--- @function collision_info:getCollisionDistance(): number
--- @return number # distance or -1 on error
function collision_info:getCollisionDistance()end

--The collision point of this information (local to the object if boolean is set to <i>true</i>)
--- @function collision_info:getCollisionPoint(localVal: boolean): vector
--- @param localVal boolean? 
--- @return vector # The collision point, or nil if none or if the handle is not valid
function collision_info:getCollisionPoint(localVal)end

--The collision normal of this information (local to object if boolean is set to <i>true</i>)
--- @function collision_info:getCollisionNormal(localVal: boolean): vector
--- @param localVal boolean? 
--- @return vector # The collision normal, or nil if none or if the handle is not valid
function collision_info:getCollisionNormal(localVal)end

--Detects if this handle is valid
--- @function collision_info:isValid(): boolean
--- @return boolean # true if valid false otherwise
function collision_info:isValid()end

-- color object: A color value
color = {}
--- @class color
--- @field color.Red number The 'red' value of the color in the range from 0 to 255 The 'red' value
--- @field color.Green number The 'green' value of the color in the range from 0 to 255 The 'green' value
--- @field color.Blue number The 'blue' value of the color in the range from 0 to 255 The 'blue' value
--- @field color.Alpha number The 'alpha' or opacity value of the color in the range from 0 to 255. 0 is totally transparent, 255 is completely opaque. The 'alpha' value
-- control object: Control handle
control = {}
--- @class control
--- @field control.Name string The name of the control The name
--- @field control.Bindings table<number, string> Gets a table of bindings for the control The keys table
--- @field control.Shifted boolean Returns whether or not the keybind is Shifted True if shifted, false otherwise.
--- @field control.Alted boolean Returns whether or not the keybind is Alted True if alted, false otherwise.
--- @field control.Tab number The tab the control belongs in. 0 = Target Tab, 1 = Ship Tab, 2 = Weapon Tab, 3 = Computer Tab The tab number
--- @field control.Disabled boolean Whether or not the control is disabled and should be hidden. True for disabled, false otherwise
--- @field control.IsAxis boolean Whether or not the bound control is an axis control. True for axis, false otherwise
--- @field control.IsModifier boolean Whether or not the bound control is a modifier. True for modifier, false otherwise
--- @field control.Conflicted boolean Whether or not the bound control has a conflict. Returns the conflict string if true, nil otherwise
--Returns if the selected bind is inverted. Number is 1 for first bind 2 for second.
--- @function control:isBindInverted(Bind: number): boolean
--- @param Bind number 
--- @return boolean # True if inverted, false otherwise. False if the bind is not an axis.
function control:isBindInverted(Bind)end

--Waits for a keypress to use as a keybind. Binds the key if found. Will need to disable UI input if enabled first. Should run On Frame. Item is first bind (1) or second bind (2)
--- @function control:detectKeypress(Item: number): number
--- @param Item number 
--- @return number # 1 if successful or ESC was pressed, 0 otherwise. Returns -1 if the keypress is invalid
function control:detectKeypress(Item)end

--Clears the control binding. Item is all controls (1), first control (2), or second control (3)
--- @function control:clearBind(Item: number): boolean
--- @param Item number 
--- @return boolean # Returns true if successful, false otherwise
function control:clearBind(Item)end

--Clears all binds that conflict with the selected bind index.
--- @function control:clearConflicts(): boolean
--- @return boolean # Returns true if successful, false otherwise
function control:clearConflicts()end

--Toggles whether or not the current bind uses SHIFT modifier.
--- @function control:toggleShifted(): boolean
--- @return boolean # Returns true if successful, false otherwise
function control:toggleShifted()end

--Toggles whether or not the current bind uses ALT modifier.
--- @function control:toggleAlted(): boolean
--- @return boolean # Returns true if successful, false otherwise
function control:toggleAlted()end

--Toggles whether or not the current bind axis is inverted. Item is all controls (1), first control (2), or second control (3)
--- @function control:toggleInverted(Item: number): boolean
--- @param Item number 
--- @return boolean # Returns true if successful, false otherwise
function control:toggleInverted(Item)end

-- control_info object: control info handle
control_info = {}
--- @class control_info
--- @field control_info.Pitch number Pitch of the player ship Pitch
--- @field control_info.Heading number Heading of the player ship Heading
--- @field control_info.Bank number Bank of the player ship Bank
--- @field control_info.Vertical number Vertical control of the player ship Vertical control
--- @field control_info.Sideways number Sideways control of the player ship Sideways control
--- @field control_info.Forward number Forward control of the player ship Forward
--- @field control_info.ForwardCruise number Forward control of the player ship Forward
--- @field control_info.PrimaryCount number Number of primary weapons that will fire Number of weapons to fire, or 0 if handle is invalid
--- @field control_info.SecondaryCount number Number of secondary weapons that will fire Number of weapons to fire, or 0 if handle is invalid
--- @field control_info.CountermeasureCount number Number of countermeasures that will launch Number of countermeasures to launch, or 0 if handle is invalid
--- @field control_info.AllButtonPolling boolean Toggles the all button polling for lua If the all button polling is enabled or not
--Clears the lua button control info
--- @function control_info:clearLuaButtonInfo(): nothing
--- @return nil
function control_info:clearLuaButtonInfo()end

--Access the four bitfields containing the button info
--- @function control_info:getButtonInfo(): number, number, number, number
--- @return number, number, number, number # Four bitfields
function control_info:getButtonInfo()end

--Access the four bitfields containing the button info
--- @function control_info:accessButtonInfo(param1: number, param2: number, param3: number, param4: number): number, number, number, number
--- @param param1 number 
--- @param param2 number 
--- @param param3 number 
--- @param param4 number 
--- @return number, number, number, number # Four bitfields
function control_info:accessButtonInfo(param1, param2, param3, param4)end

--Adds the defined button control to lua button control data, if number is -1 it tries to use the string
--- @function control_info:useButtonControl(param1: number, param2: string): nothing
--- @param param1 number 
--- @param param2 string 
--- @return nil
function control_info:useButtonControl(param1, param2)end

--Gives the name of the command corresponding with the given number
--- @function control_info:getButtonControlName(param1: number): string
--- @param param1 number 
--- @return string # Name of the command
function control_info:getButtonControlName(param1)end

--Gives the number of the command corresponding with the given string
--- @function control_info:getButtonControlNumber(param1: string): number
--- @param param1 string 
--- @return number # Number of the command
function control_info:getButtonControlNumber(param1)end

--Access the four bitfields containing the button info
--- @function control_info:pollAllButtons(): number, number, number, number
--- @return number, number, number, number # Four bitfields
function control_info:pollAllButtons()end

-- cutscene_info object: Tech Room cutscene handle
cutscene_info = {}
--- @class cutscene_info
--- @field cutscene_info.Name string The name of the cutscene The cutscene name
--- @field cutscene_info.Filename string The filename of the cutscene The cutscene filename
--- @field cutscene_info.Description string The cutscene description The cutscene description
--- @field cutscene_info.isVisible boolean If the cutscene should be visible by default true if visible, false if not visible
--- @field cutscene_info.CustomData table Gets the custom data table for this cutscene The cutscene's custom data table
--Detects whether the cutscene has any custom data
--- @function cutscene_info:hasCustomData(): boolean
--- @return boolean # true if the cutscene's custom_data is not empty, false otherwise
function cutscene_info:hasCustomData()end

--Detects whether cutscene is valid
--- @function cutscene_info:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function cutscene_info:isValid()end

-- debriefing object: Debriefing handle
debriefing = {}
--- @class debriefing
--The list of stages in the debriefing.
--- @function debriefing:__indexer(index: number): debriefing_stage
--- @param index number 
--- @return debriefing_stage # The stage at the specified location.
function debriefing:__indexer(index)end

--The number of stages in the debriefing
--- @function debriefing:__len(): number
--- @return number # The number of stages.
function debriefing:__len()end

-- debriefing_stage object: Debriefing stage handle
debriefing_stage = {}
--- @class debriefing_stage
--- @field debriefing_stage.Text string The text of the stage The text
--- @field debriefing_stage.AudioFilename string The filename of the audio file to play The file name
--- @field debriefing_stage.Recommendation string The recommendation text of the stage The recommendation text
--Evaluates the stage formula and returns the result. Could potentially have side effects if the stage formula has a 'perform-actions' or similar operator. Note that the standard UI evaluates the formula exactly once per stage on debriefing initialization.
--- @function debriefing_stage:checkVisible(): boolean
--- @return boolean # true if the stage should be displayed, false otherwise
function debriefing_stage:checkVisible()end

-- debris object: Debris handle
debris = {}
--- @class debris
--- @field debris.IsHull boolean Whether or not debris is a piece of hull Whether debris is a hull fragment, or false if handle is invalid
--- @field debris.OriginClass shipclass The shipclass of the ship this debris originates from The shipclass of the ship that created this debris
--- @field debris.DoNotExpire boolean Whether the debris should expire.  Normally, debris does not expire if it is from ships destroyed before mission or from ships that are more than 50 meters in radius. True if flag is set, false if flag is not set and nil on error
--- @field debris.LifeLeft number The time this debris piece will last.  When this is 0 (and DoNotExpire is false) the debris will explode. The amount of time, in seconds, the debris will last
--The radius of this debris piece
--- @function debris:getDebrisRadius(): number
--- @return number # The radius of this debris piece or -1 if invalid
function debris:getDebrisRadius()end

--Return if this debris handle is valid
--- @function debris:isValid(): boolean
--- @return boolean # true if valid false otherwise
function debris:isValid()end

--Return if this debris is the generic debris model, not a model subobject
--- @function debris:isGeneric(): boolean
--- @return boolean # true if Debris_model
function debris:isGeneric()end

--Return if this debris is the vaporized debris model, not a model subobject
--- @function debris:isVaporized(): boolean
--- @return boolean # true if Debris_vaporize_model
function debris:isVaporized()end

--Vanishes this piece of debris from the mission.
--- @function debris:vanish(): boolean
--- @return boolean # True if the deletion was successful, false otherwise.
function debris:vanish()end

-- decaldefinition object: Decal definition handle
decaldefinition = {}
--- @class decaldefinition
--- @field decaldefinition.Name string Decal definition name Decal definition name, or empty string if handle is invalid
--Decal definition name
--- @function decaldefinition:__tostring(): string
--- @return string # Decal definition unique id, or an empty string if handle is invalid
function decaldefinition:__tostring()end

--Checks if the two definitions are equal
--- @function decaldefinition:__eq(param1: decaldefinition, param2: decaldefinition): boolean
--- @param param1 decaldefinition 
--- @param param2 decaldefinition 
--- @return boolean # true if equal, false otherwise
function decaldefinition:__eq(param1, param2)end

--Detects whether handle is valid
--- @function decaldefinition:isValid(): boolean
--- @return boolean # true if valid, false if invalid, nil if a syntax/type error occurs
function decaldefinition:isValid()end

--Creates a decal with the specified parameters.  A negative value for either lifetime will result in a perpetual decal.  The position and orientation are in the frame-of-reference of the submodel.
--- @function decaldefinition:create(width: number, height: number, minLifetime: number, maxLifetime: number, host: object, submodel: submodel, local_pos: vector, local_orient: orientation): nothing
--- @param width number 
--- @param height number 
--- @param minLifetime number 
--- @param maxLifetime number 
--- @param host object 
--- @param submodel submodel 
--- @param local_pos vector? 
--- @param local_orient orientation? 
--- @return nil # Nothing
function decaldefinition:create(width, height, minLifetime, maxLifetime, host, submodel, local_pos, local_orient)end

-- default_primary object: weapon index
default_primary = {}
--- @class default_primary
--Array of ship default primaries for each bank. Returns the Weapon Class or nil if the bank is invalid for the ship class.
--- @function default_primary:__indexer(idx: number): weaponclass
--- @param idx number 
--- @return weaponclass # The weapon index
function default_primary:__indexer(idx)end

--The number of primary banks with defaults
--- @function default_primary:__len(): number
--- @return number # The number of primary banks.
function default_primary:__len()end

-- default_secondary object: weapon index
default_secondary = {}
--- @class default_secondary
--Array of ship default secondaries for each bank. Returns the Weapon Class or nil if the bank is invalid for the ship class.
--- @function default_secondary:__indexer(idx: number): weaponclass
--- @param idx number 
--- @return weaponclass # The weapon index
function default_secondary:__indexer(idx)end

--The number of secondary banks with defaults
--- @function default_secondary:__len(): number
--- @return number # The number of secondary banks.
function default_secondary:__len()end

-- display object: Cockpit display handle
display = {}
--- @class display
--Starts rendering to this cockpit display. That means if you get a valid texture handle from this function then the rendering system is ready to do a render to texture. If setClip is true then the clipping region will be set to the region of the cockpit display.<br><b>Important:</b> You have to call stopRendering after you're done or this render target will never be released!
--- @function display:startRendering(setClip: boolean): texture
--- @param setClip boolean? 
--- @return texture # texture handle that is being drawn to or invalid handle on error
function display:startRendering(setClip)end

--Stops rendering to this cockpit display
--- @function display:stopRendering(): boolean
--- @return boolean # true if successful, false otherwise
function display:stopRendering()end

--Gets the background texture handle of this cockpit display
--- @function display:getBackgroundTexture(): texture
--- @return texture # texture handle or invalid handle if no background texture or an error happened
function display:getBackgroundTexture()end

--Gets the foreground texture handle of this cockpit display<br><b>Important:</b> If you want to do render to texture then you have to use startRendering/stopRendering
--- @function display:getForegroundTexture(): texture
--- @return texture # texture handle or invalid handle if no foreground texture or an error happened
function display:getForegroundTexture()end

--Gets the size of this cockpit display
--- @function display:getSize(): number, number
--- @return number, number # Width and height of the display or -1, -1 on error
function display:getSize()end

--Gets the offset of this cockpit display
--- @function display:getOffset(): number, number
--- @return number, number # x and y offset of the display or -1, -1 on error
function display:getOffset()end

--Detects whether this handle is valid or not
--- @function display:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function display:isValid()end

-- display_info object: Ship cockpit display information handle
display_info = {}
--- @class display_info
--Gets the name of this cockpit display as defined in ships.tbl
--- @function display_info:getName(): string
--- @return string # Name string or empty string on error
function display_info:getName()end

--Gets the file name of the target texture of this cockpit display
--- @function display_info:getFileName(): string
--- @return string # Texture name string or empty string on error
function display_info:getFileName()end

--Gets the file name of the foreground texture of this cockpit display
--- @function display_info:getForegroundFileName(): string
--- @return string # Foreground texture name string or nil if texture is not set or on error
function display_info:getForegroundFileName()end

--Gets the file name of the background texture of this cockpit display
--- @function display_info:getBackgroundFileName(): string
--- @return string # Background texture name string or nil if texture is not set or on error
function display_info:getBackgroundFileName()end

--Gets the size of this cockpit display
--- @function display_info:getSize(): number, number
--- @return number, number # Width and height of the display or -1, -1 on error
function display_info:getSize()end

--Gets the offset of this cockpit display
--- @function display_info:getOffset(): number, number
--- @return number, number # x and y offset of the display or -1, -1 on error
function display_info:getOffset()end

--Detects whether this handle is valid
--- @function display_info:isValid(): boolean
--- @return boolean # true if valid false otherwise
function display_info:isValid()end

-- displays object: Player cockpit displays array handle
displays = {}
--- @class displays
--Gets the number of cockpit displays for the player ship
--- @function displays:__len(): number
--- @return number # number of displays or -1 on error
function displays:__len()end

--Gets a cockpit display from the present player displays by either the index or the name of the display
--- @function displays:__indexer(param1: number | string): display
--- @param param1 number | string 
--- @return display # Display handle or invalid handle on error
function displays:__indexer(param1)end

--Detects whether this handle is valid or not
--- @function displays:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function displays:isValid()end

-- dockingbay object: Handle to a model docking bay
dockingbay = {}
--- @class dockingbay
--Gets the number of docking points in this bay
--- @function dockingbay:__len(): number
--- @return number # The number of docking points or 0 on error
function dockingbay:__len()end

--Gets the name of this docking bay
--- @function dockingbay:getName(): string
--- @return string # The name or an empty string on error
function dockingbay:getName()end

--Gets the location of a docking point in this bay
--- @function dockingbay:getPoint(index: number): vector
--- @param index number 
--- @return vector # The local location or empty vector on error
function dockingbay:getPoint(index)end

--Gets the normal of a docking point in this bay
--- @function dockingbay:getNormal(index: number): vector
--- @param index number 
--- @return vector # The normal vector or empty vector on error
function dockingbay:getNormal(index)end

--Computes the final position and orientation of a docker bay that docks with this bay.
--- @function dockingbay:computeDocker(param1: dockingbay): vector, orientation
--- @param param1 dockingbay 
--- @return vector, orientation # The local location and orientation of the docker vessel in the reference to the vessel of the docking bay handle, or a nil value on error
function dockingbay:computeDocker(param1)end

--Detects whether is valid or not
--- @function dockingbay:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function dockingbay:isValid()end

-- dockingbays object: The docking bays of a model
dockingbays = {}
--- @class dockingbays
--Gets a dockingbay handle from this model. If a string is given then a dockingbay with that name is searched.
--- @function dockingbays:__indexer(param1: dockingbay): dockingbay
--- @param param1 dockingbay 
--- @return dockingbay # Handle or invalid handle on error
function dockingbays:__indexer(param1)end

--Retrieves the number of dockingbays on this model
--- @function dockingbays:__len(): number
--- @return number # number of docking bays or 0 on error
function dockingbays:__len()end

-- dogfight_scores object: Dogfight scores handle
dogfight_scores = {}
--- @class dogfight_scores
--- @field dogfight_scores.Callsign string Gets the callsign for the player who's scores these are the callsign or nil if invalid
--Detects whether handle is valid
--- @function dogfight_scores:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function dogfight_scores:isValid()end

--Detects whether handle is valid
--- @function dogfight_scores:getKillsOnPlayer(param1: net_player): boolean
--- @param param1 net_player 
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function dogfight_scores:getKillsOnPlayer(param1)end

-- enumeration object: Enumeration object
enumeration = {}
--- @class enumeration
--- @field enumeration.IntValue number Internal value of the enum.  Probably not useful unless this enum is a bitfield or corresponds to a #define somewhere else in the source code. Integer (index) value of the enum
--- @field enumeration.Value number Internal bitfield value of the enum. -1 if the enum is not a bitfield Integer value of the enum
--Sets enumeration to specified value (if it is not a global)
--- @function enumeration:__newindex(param1: enumeration): enumeration
--- @param param1 enumeration 
--- @return enumeration # enumeration
function enumeration:__newindex(param1)end

--Returns enumeration name
--- @function enumeration:__tostring(): string
--- @return string # Enumeration name, or "<INVALID>" if invalid
function enumeration:__tostring()end

--Compares the two enumerations for equality
--- @function enumeration:__eq(param1: enumeration): boolean
--- @param param1 enumeration 
--- @return boolean # true if equal, false otherwise
function enumeration:__eq(param1)end

--Calculates the logical OR of the two enums. Only applicable for certain bitfield enums (OS_*, DC_*, ...)
--- @function enumeration:__add(param1: enumeration): enumeration
--- @param param1 enumeration 
--- @return enumeration # Result of the OR operation. Invalid enum if input was not a valid enum or a bitfield enum.
function enumeration:__add(param1)end

--Calculates the logical AND of the two enums. Only applicable for certain bitfield enums (OS_*, DC_*, ...)
--- @function enumeration:__mul(param1: enumeration): enumeration
--- @param param1 enumeration 
--- @return enumeration # Result of the AND operation. Invalid enum if input was not a valid enum or a bitfield enum.
function enumeration:__mul(param1)end

-- event object: Mission event handle
event = {}
--- @class event
--- @field event.Name string Mission event name
--- @field event.DirectiveText string Directive text
--- @field event.DirectiveKeypressText string Raw directive keypress text, as seen in FRED.
--- @field event.Interval number Time for event to repeat (in seconds) Repeat time, or 0 if invalid handle
--- @field event.ObjectCount number Number of objects left for event Repeat count, or 0 if invalid handle
--- @field event.RepeatCount number Event repeat count Repeat count, or 0 if invalid handle
--- @field event.Score number Event score Event score, or 0 if invalid handle
--Detects whether handle is valid
--- @function event:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function event:isValid()end

-- execution_context object: An execution context for asynchronous operations
execution_context = {}
--- @class execution_context
--Determines the current state of the context.
--- @function execution_context:determineState(): enumeration
--- @return enumeration # One of the CONTEXT_ enumerations
function execution_context:determineState()end

--Determines if the handle is valid
--- @function execution_context:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function execution_context:isValid()end

-- executor object: An executor that can be used for scheduling the execution of a function.
executor = {}
--- @class executor
--Takes a function that returns a boolean and schedules that for execution on this executor. If the function returns true it will be run again the. If it returns false it will be removed from the executor.<br>Note: Use this with care since using this without proper care can lead to the function being run in states that are not desired. Consider using async.run.
--- @function executor:schedule(param1: function()): boolean
--- @param param1 function() 
--- @return boolean # true if function was scheduled, false otherwise.
function executor:schedule(param1)end

--Determined if this handle is valid
--- @function executor:isValid(): boolean
--- @return boolean # true if valid, false otherwise.
function executor:isValid()end

-- eyepoint object: Eyepoint handle
eyepoint = {}
--- @class eyepoint
--- @field eyepoint.Normal vector Eyepoint normal Eyepoint normal, or null vector if handle is invalid
--- @field eyepoint.Position vector Eyepoint location (Local vector) Eyepoint location, or null vector if handle is invalid
--Detect whether this handle is valid
--- @function eyepoint:isValid(): boolean
--- @return boolean # true if valid false otherwise
function eyepoint:isValid()end

--Detect whether this handle is valid
--- @function eyepoint:IsValid(): boolean
--- @return boolean # true if valid false otherwise
function eyepoint:IsValid()end

-- eyepoints object: Array of model eye points
eyepoints = {}
--- @class eyepoints
--Gets the number of eyepoints on this model
--- @function eyepoints:__len(): number
--- @return number # Number of eyepoints on this model or 0 on error
function eyepoints:__len()end

--Gets an eyepoint handle
--- @function eyepoints:__indexer(param1: eyepoint): eyepoint
--- @param param1 eyepoint 
--- @return eyepoint # eye handle or invalid handle on error
function eyepoints:__indexer(param1)end

--Detects whether handle is valid or not
--- @function eyepoints:isValid(): boolean
--- @return boolean # true if valid false otherwise
function eyepoints:isValid()end

-- fiction_viewer_stage object: Fiction Viewer stage handle
fiction_viewer_stage = {}
--- @class fiction_viewer_stage
--- @field fiction_viewer_stage.TextFile string The text file of the stage The text filename
--- @field fiction_viewer_stage.FontFile string The font file of the stage The font filename
--- @field fiction_viewer_stage.VoiceFile string The voice file of the stage The voice filename
-- file object: File handle
file = {}
--- @class file
--Detects whether handle is valid
--- @function file:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function file:isValid()end

--Instantly closes file and invalidates all file handles
--- @function file:close(): nothing
--- @return nil
function file:close()end

--Flushes file buffer to disk.
--- @function file:flush(): boolean
--- @return boolean # True for success, false on failure
function file:flush()end

--Returns the name of the given file
--- @function file:getName(): string
--- @return string # Name of the file handle, or an empty string if it doesn't have one, or the handle is invalid
function file:getName()end

--Determines path of the given file
--- @function file:getPath(): string
--- @return string # Path string of the file handle, or an empty string if it doesn't have one, or the handle is invalid
function file:getPath()end

--Reads part of or all of a file, depending on arguments passed. Based on basic Lua file:read function.Returns nil when the end of the file is reached.<br><ul><li>"*n" - Reads a number.</li><li>"*a" - Reads the rest of the file and returns it as a string.</li><li>"*l" - Reads a line. Skips the end of line markers.</li><li>(number) - Reads given number of characters, then returns them as a string.</li></ul>
--- @function file:read(param1: number | string, param2: any): number | string
--- @param param1 number | string 
--- @param param2 any 
--- @return number | string # Requested data, or nil if the function fails
function file:read(param1, param2)end

--Changes position of file, or gets location.Whence can be:<li>"set" - File start.</li><li>"cur" - Current position in file.</li><li>"end" - File end.</li></ul>
--- @function file:seek(Whence: string, Offset: number): number
--- @param Whence string? 
--- @param Offset number? 
--- @return number # new offset, or false or nil on failure
function file:seek(Whence, Offset)end

--Writes a series of Lua strings or numbers to the current file.
--- @function file:write(param1: string | number, param2: any): number
--- @param param1 string | number 
--- @param param2 any 
--- @return number # Number of items successfully written.
function file:write(param1, param2)end

--Writes the specified data to the file
--- @function file:writeBytes(bytes: bytearray): number
--- @param bytes bytearray 
--- @return number # Number of bytes successfully written.
function file:writeBytes(bytes)end

--Reads the entire contents of the file as a byte array.<br><b>Warning:</b> This may change the position inside the file.
--- @function file:readBytes(): bytearray
--- @return bytearray # The bytes read from the file or empty array on error
function file:readBytes()end

-- fireball object: Fireball handle
fireball = {}
--- @class fireball
--- @field fireball.Class fireballclass Fireball's class Fireball class, or invalid fireballclass handle if fireball handle is invalid
--- @field fireball.RenderType enumeration Fireball's render type Fireball rendertype, or handle to invalid enum if fireball handle is invalid or a bad enum was given
--- @field fireball.TimeElapsed number Time this fireball exists in seconds Time this fireball exists or 0 if fireball handle is invalid
--- @field fireball.TotalTime number Total lifetime of the fireball's animation in seconds Total lifetime of the fireball's animation or 0 if fireball handle is invalid
--Checks if the fireball is a warp effect.
--- @function fireball:isWarp(): boolean
--- @return boolean # boolean value of the fireball warp status or false if the handle is invalid
function fireball:isWarp()end

--Vanishes this fireball from the mission.
--- @function fireball:vanish(): boolean
--- @return boolean # True if the deletion was successful, false otherwise.
function fireball:vanish()end

-- fireballclass object: Fireball class handle
fireballclass = {}
--- @class fireballclass
--- @field fireballclass.UniqueID string Fireball class name Fireball class unique id, or empty string if handle is invalid
--- @field fireballclass.Filename string Fireball class animation filename (LOD 0) Filename, or empty string if handle is invalid
--- @field fireballclass.NumberFrames number Amount of frames the animation has (LOD 0) Amount of frames, or -1 if handle is invalid
--- @field fireballclass.FPS number The FPS with which this fireball's animation is played (LOD 0) FPS, or -1 if handle is invalid
--Fireball class name
--- @function fireballclass:__tostring(): string
--- @return string # Fireball class unique id, or an empty string if handle is invalid
function fireballclass:__tostring()end

--Checks if the two classes are equal
--- @function fireballclass:__eq(param1: fireballclass, param2: fireballclass): boolean
--- @param param1 fireballclass 
--- @param param2 fireballclass 
--- @return boolean # true if equal, false otherwise
function fireballclass:__eq(param1, param2)end

--Detects whether handle is valid
--- @function fireballclass:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function fireballclass:isValid()end

--Gets the index value of the fireball class
--- @function fireballclass:getTableIndex(): number
--- @return number # index value of the fireball class
function fireballclass:getTableIndex()end

-- font object: font handle
font = {}
--- @class font
--- @field font.Filename string Name of font (including extension)<br><b>Important:</b>This variable is deprecated. Use <i>Name</i> instead.
--- @field font.Name string Name of font (including extension)
--- @field font.Height number Height of font (in pixels) Font height, or 0 if the handle is invalid
--- @field font.TopOffset number The offset this font has from the baseline of textdrawing downwards. (in pixels) Font top offset, or 0 if the handle is invalid
--- @field font.BottomOffset number The space (in pixels) this font skips downwards after drawing a line of text Font bottom offset, or 0 if the handle is invalid
--Name of font
--- @function font:__tostring(): string
--- @return string # Font filename, or an empty string if the handle is invalid
function font:__tostring()end

--Checks if the two fonts are equal
--- @function font:__eq(param1: font, param2: font): boolean
--- @param param1 font 
--- @param param2 font 
--- @return boolean # true if equal, false otherwise
function font:__eq(param1, param2)end

--True if valid, false or nil if not
--- @function font:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function font:isValid()end

-- gameevent object: Game event
gameevent = {}
--- @class gameevent
--- @field gameevent.Name string Game event name Game event name, or empty string if handle is invalid
--Game event name
--- @function gameevent:__tostring(): string
--- @return string # Game event name, or empty string if handle is invalid
function gameevent:__tostring()end

-- gamestate object: Game state
gamestate = {}
--- @class gamestate
--- @field gamestate.Name string Game state name Game state name, or empty string if handle is invalid
--Game state name
--- @function gamestate:__tostring(): string
--- @return string # Game state name, or empty string if handle is invalid
function gamestate:__tostring()end

-- gauge_config object: Gauge config handle
gauge_config = {}
--- @class gauge_config
--- @field gauge_config.Name string The name of this gauge The name
--- @field gauge_config.CurrentColor color Gets the current color of the gauge. If setting the color, gauges that use IFF for color cannot be set. The gauge color or nil if the gauge is invalid
--- @field gauge_config.ShowGaugeFlag boolean Gets the current status of the show gauge flag. True if on, false if otherwise
--- @field gauge_config.PopupGaugeFlag boolean Gets the current status of the popup gauge flag. True if on, false otherwise
--- @field gauge_config.CanPopup boolean Gets whether or not the gauge can have the popup flag. True if can popup, false otherwise
--- @field gauge_config.UsesIffForColor boolean Gets whether or not the gauge uses IFF for color. True if uses IFF, false otherwise
--Sets if the gauge is the currently selected gauge for drawing as selected.
--- @function gauge_config:setSelected(param1: boolean): nothing
--- @param param1 boolean 
--- @return nil
function gauge_config:setSelected(param1)end

--Detects whether handle is valid
--- @function gauge_config:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function gauge_config:isValid()end

-- glowpoint object: A model glowpoint
glowpoint = {}
--- @class glowpoint
--- @field glowpoint.Position vector The (local) vector to the position of the glowpoint The local vector to the glowpoint or nil if invalid
--- @field glowpoint.Normal vector The normal of the glowpoint The normal of the glowpoint or nil if invalid
--- @field glowpoint.Radius number The radius of the glowpoint The radius of the glowpoint or -1 if invalid
--Returns whether this handle is valid or not
--- @function glowpoint:isValid(): boolean
--- @return boolean # True if handle is valid, false otherwise
function glowpoint:isValid()end

-- glowpointbank object: A model glow point bank
glowpointbank = {}
--- @class glowpointbank
--Gets the number of glow points in this bank
--- @function glowpointbank:__len(): number
--- @return number # Number of glow points in this bank or 0 on error
function glowpointbank:__len()end

--Gets a glow point handle
--- @function glowpointbank:__indexer(param1: glowpoint): glowpoint
--- @param param1 glowpoint 
--- @return glowpoint # glowpoint handle or invalid handle on error
function glowpointbank:__indexer(param1)end

--Detects whether handle is valid or not
--- @function glowpointbank:isValid(): boolean
--- @return boolean # true if valid false otherwise
function glowpointbank:isValid()end

-- glowpointbanks object: Array of model glow point banks
glowpointbanks = {}
--- @class glowpointbanks
--Gets the number of glow point banks on this model
--- @function glowpointbanks:__len(): number
--- @return number # Number of glow point banks on this model or 0 on error
function glowpointbanks:__len()end

--Gets a glow point bank handle
--- @function glowpointbanks:__indexer(param1: glowpointbank): glowpointbank
--- @param param1 glowpointbank 
--- @return glowpointbank # glowpointbank handle or invalid handle on error
function glowpointbanks:__indexer(param1)end

--Detects whether handle is valid or not
--- @function glowpointbanks:isValid(): boolean
--- @return boolean # true if valid false otherwise
function glowpointbanks:isValid()end

-- help_section object: Help Section handle
help_section = {}
--- @class help_section
--- @field help_section.Title string The title of the help section The title
--- @field help_section.Header string The header of the help section The header
--- @field help_section.Keys table<number, string> Gets a table of keys in the help section The keys table
--- @field help_section.Texts table<number, string> Gets a table of texts in the help section The texts table
--Detects whether handle is valid
--- @function help_section:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function help_section:isValid()end

-- hotkey_ship object: Hotkey handle
hotkey_ship = {}
--- @class hotkey_ship
--- @field hotkey_ship.Text string The text of this hotkey line The text
--- @field hotkey_ship.Type enumeration The type of this hotkey line: HOTKEY_LINE_NONE, HOTKEY_LINE_HEADING, HOTKEY_LINE_WING, HOTKEY_LINE_SHIP, or HOTKEY_LINE_SUBSHIP. The type
--- @field hotkey_ship.Keys table<number, boolean> Gets a table of hotkeys set to the ship in the order from F5 - F12 The hotkeys table
--Detects whether handle is valid
--- @function hotkey_ship:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function hotkey_ship:isValid()end

--Adds a hotkey to the to the ship in the list. 1-8 correspond to F5-F12. Returns nothing.
--- @function hotkey_ship:addHotkey(Key: number): nothing
--- @param Key number 
--- @return nil
function hotkey_ship:addHotkey(Key)end

--Removes a hotkey from the ship in the list. 1-8 correspond to F5-F12. Returns nothing.
--- @function hotkey_ship:removeHotkey(Key: number): nothing
--- @param Key number 
--- @return nil
function hotkey_ship:removeHotkey(Key)end

--Clears all hotkeys from the ship in the list. Returns nothing.
--- @function hotkey_ship:clearHotkeys(): nothing
--- @return nil
function hotkey_ship:clearHotkeys()end

-- hud_preset object: Hud preset handle
hud_preset = {}
--- @class hud_preset
--- @field hud_preset.Name string The name of this preset The name
--Deletes the preset file
--- @function hud_preset:deletePreset(): nothing
--- @return nil
function hud_preset:deletePreset()end

--Detects whether handle is valid
--- @function hud_preset:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function hud_preset:isValid()end

-- HudGauge object: HUD Gauge handle
HudGauge = {}
--- @class HudGauge
--- @field HudGauge.Name string Custom HUD Gauge name Custom HUD Gauge name, or nil if this is a default gauge or the handle is invalid
--- @field HudGauge.Text string Custom HUD Gauge text Custom HUD Gauge text, or nil if this is a default gauge or the handle is invalid
--- @field HudGauge.ConfigType string The config type (such as "LEAD_INDICATOR") of this HUD Gauge HUD Gauge config type, or nil if this gauge does not have a config type (custom gauges and some default gauges do not) or if the handle is invalid
--- @field HudGauge.ObjectType string The object type (such as "Lead indicator") of this HUD Gauge HUD Gauge object type, or nil if this gauge does not have an object type or if the handle is invalid
--- @field HudGauge.RenderFunction function(HudGaugeDrawFunctions) For scripted HUD gauges, the function that will be called for rendering the HUD gauge Render function or nil if no action is set or handle is invalid
--Custom HUD Gauge status
--- @function HudGauge:isCustom(): boolean
--- @return boolean # Returns true if this is a custom HUD gauge, or false if it is a non-custom (default) HUD gauge
function HudGauge:isCustom()end

--Returns the base width and base height (which may be different from the screen width and height) used by the specified HUD gauge.
--- @function HudGauge:getBaseResolution(): number, number
--- @return number, number # Base width and height
function HudGauge:getBaseResolution()end

--Returns the aspect quotient (ratio between the current aspect ratio and the HUD's native aspect ratio) used by the specified HUD gauge.
--- @function HudGauge:getAspectQuotient(): number
--- @return number # Aspect quotient
function HudGauge:getAspectQuotient()end

--Returns the position of the specified HUD gauge.
--- @function HudGauge:getPosition(): number, number
--- @return number, number # X and Y coordinates
function HudGauge:getPosition()end

--Sets the position of the specified HUD gauge.
--- @function HudGauge:setPosition(param1: number, param2: number): nothing
--- @param param1 number 
--- @param param2 number 
--- @return nil
function HudGauge:setPosition(param1, param2)end

--Returns the font used by the specified HUD gauge.
--- @function HudGauge:getFont(): font
--- @return font # The font handle
function HudGauge:getFont()end

--Returns the origin and offset of the specified HUD gauge as specified in the table.
--- @function HudGauge:getOriginAndOffset(): number, number, number, number
--- @return number, number, number, number # Origin X, Origin Y, Offset X, Offset Y
function HudGauge:getOriginAndOffset()end

--Returns the coordinates of the specified HUD gauge as specified in the table.
--- @function HudGauge:getCoords(): boolean, number, number
--- @return boolean, number, number # Coordinates flag (whether coordinates are used), X, Y
function HudGauge:getCoords()end

--Returns whether this is a hi-res HUD gauge, determined by whether the +Filename property is prefaced with "2_".  Not all gauges have such a filename.
--- @function HudGauge:isHiRes(): boolean
--- @return boolean # Whether the HUD gauge is known to be hi-res
function HudGauge:isHiRes()end

--Returns the current color used by this HUD gauge.
--- @function HudGauge:getColor(): number, number, number, number
--- @return number, number, number, number # The current color, in red, green, blue, and alpha components from 0 to 255
function HudGauge:getColor()end

--Sets the current color used by this HUD gauge.  Numbers must be 0-255 in red/green/blue/alpha components; alpha is optional.
--- @function HudGauge:setColor(param1: number, param2: number, param3: number, param4: number): nothing
--- @param param1 number 
--- @param param2 number 
--- @param param3 number 
--- @param param4 number? 
--- @return nil
function HudGauge:setColor(param1, param2, param3, param4)end

-- HudGaugeDrawFunctions object: Handle to the rendering functions used for HUD gauges. Do not keep a reference to this since these are only useful inside the rendering callback of a HUD gauge.
HudGaugeDrawFunctions = {}
--- @class HudGaugeDrawFunctions
--Draws a string in the context of the HUD gauge.
--- @function HudGaugeDrawFunctions:drawString(text: string, x: number, y: number): boolean
--- @param text string 
--- @param x number 
--- @param y number 
--- @return boolean # true on success, false otherwise
function HudGaugeDrawFunctions:drawString(text, x, y)end

--Draws a line in the context of the HUD gauge.
--- @function HudGaugeDrawFunctions:drawLine(X1: number, Y1: number, X2: number, Y2: number): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @return boolean # true on success, false otherwise
function HudGaugeDrawFunctions:drawLine(X1, Y1, X2, Y2)end

--Draws a circle in the context of the HUD gauge.
--- @function HudGaugeDrawFunctions:drawCircle(radius: number, X: number, Y: number, filled: boolean): boolean
--- @param radius number 
--- @param X number 
--- @param Y number 
--- @param filled boolean? 
--- @return boolean # true on success, false otherwise
function HudGaugeDrawFunctions:drawCircle(radius, X, Y, filled)end

--Draws a rectangle in the context of the HUD gauge.
--- @function HudGaugeDrawFunctions:drawRectangle(X1: number, Y1: number, X2: number, Y2: number, Filled: boolean): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param Filled boolean? 
--- @return boolean # true on success, false otherwise
function HudGaugeDrawFunctions:drawRectangle(X1, Y1, X2, Y2, Filled)end

--Draws an image in the context of the HUD gauge.
--- @function HudGaugeDrawFunctions:drawImage(Texture: texture, X: number, Y: number): boolean
--- @param Texture texture 
--- @param X number? 
--- @param Y number? 
--- @return boolean # true on success, false otherwise
function HudGaugeDrawFunctions:drawImage(Texture, X, Y)end

-- intel_entry object: Intel entry handle
intel_entry = {}
--- @class intel_entry
--- @field intel_entry.Name string Intel entry name Intel entry name, or an empty string if handle is invalid
--- @field intel_entry.Description string Intel entry description Description, or empty string if handle is invalid
--- @field intel_entry.AnimFilename string Intel entry animation filename Filename, or empty string if handle is invalid
--- @field intel_entry.InTechDatabase boolean Gets or sets whether this intel entry is visible in the tech room True or false
--- @field intel_entry.CustomData table Gets the custom data table for this entry The entry's custom data table
--Intel entry name
--- @function intel_entry:__tostring(): string
--- @return string # Intel entry name, or an empty string if handle is invalid
function intel_entry:__tostring()end

--Checks if the two entries are equal
--- @function intel_entry:__eq(param1: intel_entry, param2: intel_entry): boolean
--- @param param1 intel_entry 
--- @param param2 intel_entry 
--- @return boolean # true if equal, false otherwise
function intel_entry:__eq(param1, param2)end

--Detects whether the entry has any custom data
--- @function intel_entry:hasCustomData(): boolean
--- @return boolean # true if the entry's custom_data is not empty, false otherwise
function intel_entry:hasCustomData()end

--Detects whether handle is valid
--- @function intel_entry:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function intel_entry:isValid()end

--Gets the index value of the intel entry
--- @function intel_entry:getIntelEntryIndex(): number
--- @return number # index value of the intel entry
function intel_entry:getIntelEntryIndex()end

-- keybinding object: Key Binding
keybinding = {}
--- @class keybinding
--- @field keybinding.Name string Key binding name Key binding name, or empty string if handle is invalid
--Key binding name
--- @function keybinding:__tostring(): string
--- @return string # Key binding name, or empty string if handle is invalid
function keybinding:__tostring()end

--The name of the bound input
--- @function keybinding:getInputName(primaryBinding: boolean): string
--- @param primaryBinding boolean? 
--- @return string # The name of the bound input, or empty string if nothing is bound or handle is invalid
function keybinding:getInputName(primaryBinding)end

--Locks this control binding when true, disables if false. Persistent between missions.
--- @function keybinding:lock(lock: boolean): nothing
--- @param lock boolean 
--- @return nil
function keybinding:lock(lock)end

--If this control is locked
--- @function keybinding:isLocked(): boolean
--- @return boolean # If this control is locked, nil if the handle is invalid
function keybinding:isLocked()end

--Registers a hook for this keybinding, either as a normal hook, or as an override
--- @function keybinding:registerHook(hook: function(), enabledByDefault: boolean, isOverride: boolean): nothing
--- @param hook function() 
--- @param enabledByDefault boolean? 
--- @param isOverride boolean? 
--- @return nil
function keybinding:registerHook(hook, enabledByDefault, isOverride)end

--Enables scripted control hooks for this keybinding when true, disables if false. Not persistent between missions.
--- @function keybinding:enableScripting(enable: boolean): nothing
--- @param enable boolean 
--- @return nil
function keybinding:enableScripting(enable)end

-- loadout_amount object: Loadout handle
loadout_amount = {}
--- @class loadout_amount
--Array of ship bank weapons. 1-3 are Primary weapons. 4-7 are Secondary weapons. Note that banks that do not exist on the ship class are still valid here as a loadout slot. Also note that primary banks will hold the value of 1 even if it is ballistic. If the amount to set is greater than the bank's capacity then it will be set to capacity. Set to -1 to empty the slot. Amounts less than -1 will be set to -1.
--- @function loadout_amount:__indexer(bank: number, amount: number): number
--- @param bank number 
--- @param amount number 
--- @return number # Amount of the currently loaded weapon, -1 if bank has no weapon, or nil if the ship or index is invalid
function loadout_amount:__indexer(bank, amount)end

--The number of weapon banks in the slot
--- @function loadout_amount:__len(): number
--- @return number # The number of banks.
function loadout_amount:__len()end

-- loadout_ship object: Loadout handle
loadout_ship = {}
--- @class loadout_ship
--- @field loadout_ship.ShipClassIndex number The index of the Ship Class. When setting the ship class this will also set the weapons to empty slots. Use .Weapons and .Amounts to set those afterwards. Set to -1 to empty the slot and be sure to set the slot to empty using Loadout_Wings[slot].isFilled. The index or nil if handle is invalid
--- @field loadout_ship.Weapons loadout_weapon Array of weapons in the loadout slot The weapons array or nil if handle is invalid
--- @field loadout_ship.Amounts loadout_amount Array of weapon amounts in the loadout slot The weapon amounts array or nil if handle is invalid
-- loadout_weapon object: Loadout handle
loadout_weapon = {}
--- @class loadout_weapon
--Array of ship bank weapons. 1-3 are Primary weapons. 4-7 are Secondary weapons. Note that banks that do not exist on the ship class are still valid here as a loadout slot. When setting the weapon it will be checked if it is valid for the ship and bank. If it is not then it will be set to -1 and the amount will be set to -1. If it is valid for the ship then the amount is set to 0. Use .Amounts to set the amount afterwards. Set to -1 to empty the slot.
--- @function loadout_weapon:__indexer(bank: number, WeaponIndex: number): number
--- @param bank number 
--- @param WeaponIndex number 
--- @return number # index into Weapon Classes, 0 if bank is empty, -1 if the ship cannot carry the weapon, or nil if the ship or index is invalid
function loadout_weapon:__indexer(bank, WeaponIndex)end

--The number of weapon banks in the slot
--- @function loadout_weapon:__len(): number
--- @return number # The number of banks.
function loadout_weapon:__len()end

-- loadout_wing object: Loadout handle
loadout_wing = {}
--- @class loadout_wing
--- @field loadout_wing.Name string The name of the wing The wing
--Array of loadout wing slot data
--- @function loadout_wing:__indexer(idx: number): loadout_wing_slot
--- @param idx number 
--- @return loadout_wing_slot # loadout slot handle, or invalid handle if index is invalid
function loadout_wing:__indexer(idx)end

--The number of slots in the wing
--- @function loadout_wing:__len(): number
--- @return number # The number of slots.
function loadout_wing:__len()end

-- loadout_wing_slot object: Loadout wing slot handle
loadout_wing_slot = {}
--- @class loadout_wing_slot
--- @field loadout_wing_slot.isShipLocked boolean If the slot's ship is locked The slot ship status
--- @field loadout_wing_slot.isWeaponLocked boolean If the slot's weapons are locked The slot weapon status
--- @field loadout_wing_slot.isDisabled boolean If the slot is not used in the current mission or disabled for the current player in multi The slot disabled status
--- @field loadout_wing_slot.isFilled boolean If the slot is empty or filled. true if filled, false if empty The slot filled status
--- @field loadout_wing_slot.isPlayer boolean If the slot is a player ship The slot player status
--- @field loadout_wing_slot.isPlayerAllowed boolean If the slot is allowed to have player ship. In single player this is functionally the same as isPlayer. The slot player allowed status
--- @field loadout_wing_slot.ShipClassIndex number The index of the ship class assigned to the slot The ship class index
--- @field loadout_wing_slot.Callsign string The callsign of the ship slot. In multiplayer this may be the player's callsign. the callsign
-- log_entry object: Log Entry handle
log_entry = {}
--- @class log_entry
--- @field log_entry.Timestamp string The timestamp of the log entry The timestamp
--- @field log_entry.paddedTimestamp string The timestamp of the log entry that accounts for timer padding The timestamp
--- @field log_entry.Flags number The flag of the log entry. 1 for Goal True, 2 for Goal Failed, 0 otherwise. The flag
--- @field log_entry.ObjectiveText string The objective text of the log entry The objective text
--- @field log_entry.ObjectiveColor color The objective color of the log entry. The objective color
--- @field log_entry.SegmentTexts table<number, string> Gets a table of segment texts in the log entry The segment texts table
--- @field log_entry.SegmentColors table<number, color> Gets a table of segment colors in the log entry. The segment colors table
--Detects whether handle is valid
--- @function log_entry:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function log_entry:isValid()end

-- loop_brief_stage object: Loop Brief stage handle
loop_brief_stage = {}
--- @class loop_brief_stage
--- @field loop_brief_stage.Text string The text of the stage The text
--- @field loop_brief_stage.AniFilename string The ani filename of the stage The ani filename
--- @field loop_brief_stage.AudioFilename string The audio file of the stage The audio filename
-- LuaAISEXP object: Lua AI SEXP handle
LuaAISEXP = {}
--- @class LuaAISEXP
--- @field LuaAISEXP.ActionEnter function(ai_helper, any) The action of this AI SEXP to be executed once when the AI receives this order. Return true if the AI goal is complete. The action function or nil on error
--- @field LuaAISEXP.ActionFrame function(ai_helper, any) The action of this AI SEXP to be executed each frame while active. Return true if the AI goal is complete. The action function or nil on error
--- @field LuaAISEXP.Achievability function(ship, any) An optional function that specifies whether the AI mode is achieveable. Return LUAAI_ACHIEVABLE if it can be achieved, LUAAI_NOT_YET_ACHIEVABLE if it can be achieved later and execution should be delayed, and LUAAI_UNACHIEVABLE if the AI mode will never be achievable and should be cancelled. Assumes LUAAI_ACHIEVABLE if not specified. The achievability function or nil on error
--- @field LuaAISEXP.TargetRestrict function(ship, oswpt | nil) An optional function that specifies whether a target is a valid target for a player order. Result must be true and the player order +Target Restrict: must be fulfilled for the target to be valid. Assumes true if not specified. The target restrict function or nil on error
-- LuaEnum object: Lua Enum handle
LuaEnum = {}
--- @class LuaEnum
--- @field LuaEnum.Name string The enum name The enum name or nil if handle is invalid
--Array of enum items
--- @function LuaEnum:__indexer(Index: number): string
--- @param Index number 
--- @return string # enum item string, or nil if index or enum handle is invalid
function LuaEnum:__indexer(Index)end

--The number of Lua enum items
--- @function LuaEnum:__len(): number
--- @return number # The number of Lua enums item or nil if handle is invalid
function LuaEnum:__len()end

--Adds an enum item with the given string.
--- @function LuaEnum:addEnumItem(itemname: string): boolean
--- @param itemname string 
--- @return boolean # Returns true if successful, false otherwise
function LuaEnum:addEnumItem(itemname)end

--Removes an enum item with the given string.
--- @function LuaEnum:removeEnumItem(itemname: string): boolean
--- @param itemname string 
--- @return boolean # Returns true if successful, false otherwise
function LuaEnum:removeEnumItem(itemname)end

--Detects whether handle is valid
--- @function LuaEnum:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function LuaEnum:isValid()end

-- LuaSEXP object: Lua SEXP handle
LuaSEXP = {}
--- @class LuaSEXP
--- @field LuaSEXP.Action function(any) The action of this SEXP The action function or nil on error
-- medal object: Medal handle
medal = {}
--- @class medal
--- @field medal.Name string The name of the medal The name
--- @field medal.Bitmap string The bitmap of the medal The bitmap
--- @field medal.NumMods number The number of mods of the medal The number of mods
--- @field medal.FirstMod number The first mod of the medal. Some start at 1, some start at 0 The first mod
--- @field medal.KillsNeeded number The number of kills needed to earn this badge. If not a badge, then returns 0 The number of kills needed
--Detects whether handle is valid
--- @function medal:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function medal:isValid()end

--Detects whether medal is the rank medal
--- @function medal:isRank(): boolean
--- @return boolean # true if yes, false if not, nil if a syntax/type error occurs
function medal:isRank()end

-- message object: Handle to a mission message
message = {}
--- @class message
--- @field message.Name string The name of the message as specified in the mission file The name or an empty string if handle is invalid
--- @field message.Message string The unaltered text of the message, see getMessage() for options to replace variables<br><b>NOTE:</b> Changing the text will also change the text for messages not yet played but already in the message queue! The message or an empty string if handle is invalid
--- @field message.VoiceFile soundfile The voice file of the message The voice file handle or invalid handle when not present
--- @field message.Persona persona The persona of the message The persona handle or invalid handle if not present
--Gets the text of the message and optionally replaces SEXP variables with their respective values.
--- @function message:getMessage(replaceVars: boolean): string
--- @param replaceVars boolean? 
--- @return string # The message or an empty string if handle is invalid
function message:getMessage(replaceVars)end

--Checks if the message handle is valid
--- @function message:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function message:isValid()end

-- message_entry object: Message Entry handle
message_entry = {}
--- @class message_entry
--- @field message_entry.Timestamp string The timestamp of the message entry The timestamp
--- @field message_entry.paddedTimestamp string The timestamp of the message entry that accounts for mission timer padding The timestamp
--- @field message_entry.Color color The color of the message entry. The color
--- @field message_entry.Text string The text of the message entry The text
--Detects whether handle is valid
--- @function message_entry:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function message_entry:isValid()end

-- mission_goal object: Mission objective handle
mission_goal = {}
--- @class mission_goal
--- @field mission_goal.Name string The name of the goal The goal name
--- @field mission_goal.Message string The message of the goal The goal message
--- @field mission_goal.Type string The goal type primary, secondary, bonus, or none
--- @field mission_goal.Team team The goal team The goal team
--- @field mission_goal.isGoalSatisfied number The status of the goal 0 if failed, 1 if complete, 2 if incomplete
--- @field mission_goal.Score number The score of the goal the score
--- @field mission_goal.isGoalValid boolean The goal validity true if valid, false otherwise
--Detect if the handle is valid
--- @function mission_goal:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function mission_goal:isValid()end

-- model object: 3D Model (POF) handle
model = {}
--- @class model
--- @field model.Submodels submodels Model submodels Model submodels, or an invalid submodels handle if the model handle is invalid
--- @field model.Textures textures Model textures Model textures, or an invalid textures handle if the model handle is invalid
--- @field model.Thrusters thrusters Model thrusters Model thrusters, or an invalid thrusters handle if the model handle is invalid
--- @field model.GlowPointBanks glowpointbanks Model glow point banks Model glow point banks, or an invalid glowpointbanks handle if the model handle is invalid
--- @field model.Eyepoints eyepoints Model eyepoints Array of eyepoints, or an invalid eyepoints handle if the model handle is invalid
--- @field model.Dockingbays dockingbays Model docking bays Array of docking bays, or an invalid dockingbays handle if the model handle is invalid
--- @field model.BoundingBoxMax vector Model bounding box maximum Model bounding box, or an empty vector if the handle is not valid
--- @field model.BoundingBoxMin vector Model bounding box minimum Model bounding box, or an empty vector if the handle is not valid
--- @field model.Filename string Model filename Model filename, or an empty string if the handle is not valid
--- @field model.Mass number Model mass Model mass, or 0 if the model handle is invalid
--- @field model.MomentOfInertia orientation Model moment of inertia Moment of Inertia matrix or identity matrix if invalid
--- @field model.Radius number Model radius (Used for collision & culling detection) Model Radius or 0 if invalid
--Returns the root submodel of the specified detail level - 0 for detail0, etc.
--- @function model:getDetailRoot(detailLevel: number): submodel
--- @param detailLevel number? 
--- @return submodel # A submodel, or an invalid submodel if handle is not valid
function model:getDetailRoot(detailLevel)end

--True if valid, false or nil if not
--- @function model:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function model:isValid()end

-- model_instance object: Model instance handle
model_instance = {}
--- @class model_instance
--- @field model_instance.Textures modelinstancetextures Gets model instance textures Model instance textures, or invalid modelinstancetextures handle if modelinstance handle is invalid
--- @field model_instance.SubmodelInstances submodel_instances Submodel instances Model submodel instances, or an invalid modelsubmodelinstances handle if the model instance handle is invalid
--Returns the model used by this instance
--- @function model_instance:getModel(): model
--- @return model # A model
function model_instance:getModel()end

--Returns the object that this instance refers to
--- @function model_instance:getObject(): object
--- @return object # An object
function model_instance:getObject()end

--True if valid, false or nil if not
--- @function model_instance:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function model_instance:isValid()end

-- modelinstancetextures object: Model instance textures handle
modelinstancetextures = {}
--- @class modelinstancetextures
--Number of textures on a model instance
--- @function modelinstancetextures:__len(): number
--- @return number # Number of textures on the model instance, or 0 if handle is invalid
function modelinstancetextures:__len()end

--Array of model instance textures
--- @function modelinstancetextures:__indexer(IndexOrTextureFilename: number | string): texture
--- @param IndexOrTextureFilename number | string 
--- @return texture # Texture, or invalid texture handle on failure
function modelinstancetextures:__indexer(IndexOrTextureFilename)end

--Detects whether handle is valid
--- @function modelinstancetextures:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function modelinstancetextures:isValid()end

-- modelpath object: Path of a model
modelpath = {}
--- @class modelpath
--- @field modelpath.Name string The name of this model path The name or empty string if handle is invalid
--Gets the number of points in this path
--- @function modelpath:__len(): number
--- @return number # The number of points or 0 on error
function modelpath:__len()end

--Determines if the handle is valid
--- @function modelpath:isValid(): boolean
--- @return boolean # True if valid, false otherwise
function modelpath:isValid()end

--Returns the point in the path with the specified index
--- @function modelpath:__indexer(param1: number): modelpathpoint
--- @param param1 number 
--- @return modelpathpoint # The point or invalid handle if index is invalid
function modelpath:__indexer(param1)end

-- modelpathpoint object: Point in a model path
modelpathpoint = {}
--- @class modelpathpoint
--- @field modelpathpoint.Position vector The current, global position of this path point. The current position of the point.
--- @field modelpathpoint.Radius number The radius of the path point. The radius of the point.
--Determines if the handle is valid
--- @function modelpathpoint:isValid(): boolean
--- @return boolean # True if valid, false otherwise
function modelpathpoint:isValid()end

-- movie_player object: A movie player instance
movie_player = {}
--- @class movie_player
--- @field movie_player.Width number Determines the width in pixels of this movie <b>Read-only</b> The width of the movie or -1 if handle is invalid
--- @field movie_player.Height number Determines the height in pixels of this movie <b>Read-only</b> The height of the movie or -1 if handle is invalid
--- @field movie_player.FPS number Determines the frames per second of this movie <b>Read-only</b> The FPS of the movie or -1 if handle is invalid
--- @field movie_player.Duration number Determines the duration in seconds of this movie <b>Read-only</b> The duration of the movie or -1 if handle is invalid
--Updates the current state of the movie and moves the internal timer forward by the specified time span.
--- @function movie_player:update(step_time: timespan): boolean
--- @param step_time timespan 
--- @return boolean # true if there is more to display, false otherwise
function movie_player:update(step_time)end

--Determines if the player is ready to display the movie. Since the movie frames are loaded asynchronously there is a short delay between the creation of a player and when it is possible to start displaying the movie. This function can be used to determine if playback is possible at the moment.
--- @function movie_player:isPlaybackReady(): boolean
--- @return boolean # true if playback is ready, false otherwise
function movie_player:isPlaybackReady()end

--Draws the current frame of the movie at the specified coordinates.
--- @function movie_player:drawMovie(x1: number, y1: number, x2: number, y2: number): nothing
--- @param x1 number 
--- @param y1 number 
--- @param x2 number? 
--- @param y2 number? 
--- @return nil # Returns nothing
function movie_player:drawMovie(x1, y1, x2, y2)end

--Explicitly stops playback. This function should be called when the player isn't needed anymore to free up some resources.
--- @function movie_player:stop(): nothing
--- @return nil # Returns nothing
function movie_player:stop()end

--Determines if this handle is valid
--- @function movie_player:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function movie_player:isValid()end

-- net_campaign object: Net Campaign handle
net_campaign = {}
--- @class net_campaign
--- @field net_campaign.Name string The name of the mission The name
--- @field net_campaign.Filename string The filename of the mission The filename
--- @field net_campaign.Players number The max players for the mission The max number of players
--- @field net_campaign.Respawn number The mission specified respawn count The respawn count
--- @field net_campaign.Tracker boolean The validity status of the mission tracker true if valid, false if invalid, nil if unknown or handle is invalid
--- @field net_campaign.Type enumeration The type of mission. Can be MULTI_TYPE_COOP, MULTI_TYPE_TEAM, or MULTI_TYPE_DOGFIGHT the type
--- @field net_campaign.Builtin boolean Is true if the mission is a built-in Volition mission. False otherwise builtin
--Detects whether handle is valid
--- @function net_campaign:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function net_campaign:isValid()end

-- net_join_choice object: Join Choice handle
net_join_choice = {}
--- @class net_join_choice
--- @field net_join_choice.Name string Gets the name of the ship the name or nil if invalid
--- @field net_join_choice.ShipIndex string Gets the index of the ship class the index or nil if invalid
--Detects whether handle is valid
--- @function net_join_choice:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function net_join_choice:isValid()end

--Gets the table of primary weapon indexes on the ship
--- @function net_join_choice:getPrimaryWeaponsList(): table
--- @return table # the table of indexes or nil if invalid
function net_join_choice:getPrimaryWeaponsList()end

--Gets the table of secondary weapon indexes on the ship
--- @function net_join_choice:getSecondaryWeaponsList(): table
--- @return table # the table of indexes or nil if invalid
function net_join_choice:getSecondaryWeaponsList()end

--Gets the status of the ship's hull and shields
--- @function net_join_choice:getStatus(): number
--- @return number # The hull health and then a table of shield quadrant healths
function net_join_choice:getStatus()end

--Sets the current ship as chosen when Accept is clicked
--- @function net_join_choice:setChoice(): boolean
--- @return boolean # returns true if successful, Nil if there's handle error.
function net_join_choice:setChoice()end

-- net_mission object: Net Mission handle
net_mission = {}
--- @class net_mission
--- @field net_mission.Name string The name of the mission The name
--- @field net_mission.Filename string The filename of the mission The filename
--- @field net_mission.Players number The max players for the mission The max number of players
--- @field net_mission.Respawn number The mission specified respawn count The respawn count
--- @field net_mission.Tracker boolean The validity status of the mission tracker true if valid, false if invalid, nil if unknown or handle is invalid
--- @field net_mission.Type enumeration The type of mission. Can be MULTI_TYPE_COOP, MULTI_TYPE_TEAM, or MULTI_TYPE_DOGFIGHT the type
--- @field net_mission.Builtin boolean Is true if the mission is a built-in Volition mission. False otherwise builtin
--Detects whether handle is valid
--- @function net_mission:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function net_mission:isValid()end

-- net_player object: Net Player handle
net_player = {}
--- @class net_player
--- @field net_player.Name string The player's callsign The player callsign
--- @field net_player.Team number The player's team as an integer The team
--- @field net_player.State string The player's current state string The state
--- @field net_player.Master boolean Whether or not the player is the game master The master value
--- @field net_player.Host boolean Whether or not the player is the game host The host value
--- @field net_player.Observer boolean Whether or not the player is an observer The observer value
--- @field net_player.Captain boolean Whether or not the player is the team captain The captain value
--Detects whether handle is valid
--- @function net_player:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function net_player:isValid()end

--Whether or not the player is the current game instance's player
--- @function net_player:isSelf(): boolean
--- @return boolean # The self value
function net_player:isSelf()end

--Gets a handle of the player stats by player name or invalid handle if the name is invalid
--- @function net_player:getStats(): scoring_stats
--- @return scoring_stats # Player stats handle
function net_player:getStats()end

--Kicks the player from the game
--- @function net_player:kickPlayer(): nothing
--- @return nil
function net_player:kickPlayer()end

-- netgame object: Netgame handle
netgame = {}
--- @class netgame
--- @field netgame.Name string The name of the game the name
--- @field netgame.MissionFilename string The filename of the currently selected mission the mission filename
--- @field netgame.MissionTitle string The title of the currently selected mission the mission title
--- @field netgame.CampaignName string The name of the currently selected campaign the campaign name
--- @field netgame.Password string The current password for the game the password
--- @field netgame.Closed boolean Whether or not the game is closed true for closed, false otherwise
--- @field netgame.HostModifiesShips boolean Whether or not the only the host can modify ships true if enabled, false otherwise
--- @field netgame.Orders enumeration Who can give orders during the game. Will be one of the MULTI_OPTION enums. Returns nil if there's an error. the option type
--- @field netgame.EndMission enumeration Who can end the game. Will be one of the MULTI_OPTION enums. Returns nil if there's an error. the option type
--- @field netgame.SkillLevel number The current skill level the game, 0-4 the skill level
--- @field netgame.RespawnLimit number The current respawn limit the respawn limit
--- @field netgame.TimeLimit number The current time limit in minutes. -1 means no limit. the time limit
--- @field netgame.KillLimit number The current kill limit the kill limit
--- @field netgame.ObserverLimit number The current observer limit the observer limit
--- @field netgame.Locked number Whether or not the loadouts have been locked for the current team. Can be set only by the host or team captain. the locked status
--- @field netgame.Type enumeration The current game type. Will be one of the MULTI_TYPE enums. Returns nil if there's an error. the game type
--Detects whether handle is valid
--- @function netgame:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function netgame:isValid()end

--Accepts the current game options and pushes them to the the network.
--- @function netgame:acceptOptions(): boolean
--- @return boolean # returns true if successful, false otherwise
function netgame:acceptOptions()end

--Sets the mission or campaign for the Netgame. Handles changing all netgame values and updating the server.
--- @function netgame:setMission(param1: net_mission | net_campaign): boolean
--- @param param1 net_mission | net_campaign? 
--- @return boolean # returns true if successful, false otherwise
function netgame:setMission(param1)end

-- object object: Object handle
object = {}
--- @class object
--- @field object.Parent object Parent of the object. Value may also be a deriviative of the 'object' class, such as 'ship'. Parent handle, or invalid handle if object is invalid
--- @field object.Radius number Radius of an object Radius, or 0 if handle is invalid
--- @field object.Position vector Object world position (World vector) World position, or null vector if handle is invalid
--- @field object.LastPosition vector Object world position as of last frame (World vector) World position, or null vector if handle is invalid
--- @field object.Orientation orientation Object world orientation (World orientation) Orientation, or null orientation if handle is invalid
--- @field object.LastOrientation orientation Object world orientation as of last frame (World orientation) Orientation, or null orientation if handle is invalid
--- @field object.ModelInstance model_instance model instance used by this object Model instance, nil if this object does not have one, or invalid model instance handle if object handle is invalid
--- @field object.Physics physics Physics data used to move ship between frames Physics data, or invalid physics handle if object handle is invalid
--- @field object.HitpointsLeft number Hitpoints an object has left Hitpoints left, or 0 if handle is invalid
--- @field object.SimHitpointsLeft number Simulated hitpoints an object has left Simulated hitpoints left, or 0 if handle is invalid
--- @field object.Shields shields Shields Shields handle, or invalid shields handle if object handle is invalid
--- @field object.CollisionGroups number Collision group data Current set of collision groups. NOTE: This is a bitfield, NOT a normal number.
--Checks whether two object handles are for the same object
--- @function object:__eq(param1: object, param2: object): boolean
--- @param param1 object 
--- @param param2 object 
--- @return boolean # True if equal, false if not or a handle is invalid
function object:__eq(param1, param2)end

--Returns name of object (if any)
--- @function object:__tostring(): string
--- @return string # Object name, or empty string if handle is invalid
function object:__tostring()end

--Gets the object's unique signature
--- @function object:getSignature(): number
--- @return number # Returns the object's unique numeric signature, or -1 if invalid.  Useful for creating a metadata system
function object:getSignature()end

--Detects whether handle is valid
--- @function object:isValid(): boolean
--- @return boolean # true if handle is valid, false if handle is invalid, nil if a syntax/type error occurs
function object:isValid()end

--Checks whether the object has the should-be-dead flag set, which will cause it to be deleted within one frame
--- @function object:isExpiring(): boolean
--- @return boolean # true or false according to the flag, or nil if a syntax/type error occurs
function object:isExpiring()end

--Gets the FreeSpace type name
--- @function object:getBreedName(): string
--- @return string # FreeSpace type name ('Ship', 'Weapon', etc.), or empty string if handle is invalid
function object:getBreedName()end

--Adds this object to the specified collision group.  The group must be between 0 and 31, inclusive.
--- @function object:addToCollisionGroup(group: number): nothing
--- @param group number 
--- @return nil # Returns nothing
function object:addToCollisionGroup(group)end

--Removes this object from the specified collision group.  The group must be between 0 and 31, inclusive.
--- @function object:removeFromCollisionGroup(group: number): nothing
--- @param group number 
--- @return nil # Returns nothing
function object:removeFromCollisionGroup(group)end

--Returns the objects' current fvec.
--- @function object:getfvec(normalize: boolean): vector
--- @param normalize boolean? 
--- @return vector # Objects' forward vector, or nil if invalid. If called with a true argument, vector will be normalized.
function object:getfvec(normalize)end

--Returns the objects' current uvec.
--- @function object:getuvec(normalize: boolean): vector
--- @param normalize boolean? 
--- @return vector # Objects' up vector, or nil if invalid. If called with a true argument, vector will be normalized.
function object:getuvec(normalize)end

--Returns the objects' current rvec.
--- @function object:getrvec(normalize: boolean): vector
--- @param normalize boolean? 
--- @return vector # Objects' rvec, or nil if invalid. If called with a true argument, vector will be normalized.
function object:getrvec(normalize)end

--Checks the collisions between the polygons of the current object and a ray.  Start and end vectors are in world coordinates.  If a submodel is specified, collision is restricted to that submodel if checkSubmodelChildren is false, or to that submodel and its children if it is true.
--- @function object:checkRayCollision(StartPoint: vector, EndPoint: vector, Local: boolean, submodel: submodel, checkSubmodelChildren: boolean): vector, collision_info
--- @param StartPoint vector 
--- @param EndPoint vector 
--- @param Local boolean? 
--- @param submodel submodel? 
--- @param checkSubmodelChildren boolean? 
--- @return vector, collision_info # Returns collision point in world coordinates (local coordinates if Local is true) and the specific collision info; returns nil if no collisions
function object:checkRayCollision(StartPoint, EndPoint, Local, submodel, checkSubmodelChildren)end

--Registers a callback on this object which is called every time <i>before</i> the physics rules are applied to the object. The callback is attached to this specific object and will not be called anymore once the object is deleted. The parameter of the function is the object that is being moved.
--- @function object:addPreMoveHook(callback: function(object)): nothing
--- @param callback function(object) 
--- @return nil # Returns nothing.
function object:addPreMoveHook(callback)end

--Registers a callback on this object which is called every time <i>after</i> the physics rules are applied to the object. The callback is attached to this specific object and will not be called anymore once the object is deleted. The parameter of the function is the object that is being moved.
--- @function object:addPostMoveHook(callback: function(object)): nothing
--- @param callback function(object) 
--- @return nil # Returns nothing.
function object:addPostMoveHook(callback)end

--Assigns a sound to this object, with optional offset, sound flags (OS_XXXX), and associated subsystem.
--- @function object:assignSound(GameSnd: soundentry, Offset: vector, Flags: enumeration, Subsys: subsystem): number
--- @param GameSnd soundentry 
--- @param Offset vector? 
--- @param Flags enumeration? 
--- @param Subsys subsystem? 
--- @return number # Returns the index of the sound on this object, or -1 if a sound could not be assigned.
function object:assignSound(GameSnd, Offset, Flags, Subsys)end

--Removes an assigned sound from this object.
--- @function object:removeSoundByIndex(index: number): nothing
--- @param index number 
--- @return nil # Returns nothing.
function object:removeSoundByIndex(index)end

--Returns the current number of sounds assigned to this object
--- @function object:getNumAssignedSounds(): number
--- @return number # the number of sounds
function object:getNumAssignedSounds()end

--Removes all sounds of the given type from the object or object's subsystem
--- @function object:removeSound(GameSnd: soundentry, Subsys: subsystem): nothing
--- @param GameSnd soundentry 
--- @param Subsys subsystem? 
--- @return nil # Returns nothing.
function object:removeSound(GameSnd, Subsys)end

--Gets the IFF color of the object. False to return raw rgb, true to return color object. Defaults to false.
--- @function object:getIFFColor(ReturnType: boolean): number, number, number, number, color
--- @param ReturnType boolean 
--- @return number, number, number, number, color # IFF rgb color of the object or nil if object invalid
function object:getIFFColor(ReturnType)end

-- option object: Option handle
option = {}
--- @class option
--- @field option.Title string The title of this option (read-only) The title or nil on error
--- @field option.Description string The description of this option (read-only) The description or nil on error
--- @field option.Key string The configuration key of this option. This will be a unique string. (read-only) The key or nil on error
--- @field option.Category string The category of this option. (read-only) The category or nil on error
--- @field option.Type enumeration The type of this option. One of the OPTION_TYPE_* values. (read-only) The enum or nil on error
--- @field option.Value ValueDescription The current value of this option. The current value or nil on error
--- @field option.Flags table<string, boolean> Contains a list mapping a flag name to its value. Possible names are:<ul><li><b>ForceMultiValueSelection:</b> If true, a selection option with two values should be displayed the same as an option with more possible values</li><li><b>RetailBuiltinOption:</b> If true, the option is one of the original retail options</li><li><b>RangeTypeInteger:</b> If true, this range option requires an integer for the range value rather than a float</li></ul> The table of flags values.
--Gets a value from an option range. The specified value must be between 0 and 1.
--- @function option:getValueFromRange(interpolant: number): ValueDescription
--- @param interpolant number 
--- @return ValueDescription # The value at the specifiedposition
function option:getValueFromRange(interpolant)end

--From a value description of this option, determines the range value.
--- @function option:getInterpolantFromValue(value: ValueDescription): number
--- @param value ValueDescription 
--- @return number # The range value or 0 on error.
function option:getInterpolantFromValue(value)end

--Gets the valid values of this option. The order or the returned values must be maintained in the UI. This is only valid for selection or boolean options.
--- @function option:getValidValues(): ValueDescription
--- @return ValueDescription # A table containing the possible values or nil on error.
function option:getValidValues()end

--Immediately persists any changes made to this specific option.
--- @function option:persistChanges(): boolean
--- @return boolean # true if the change was applied successfully, false otherwise. nil on error.
function option:persistChanges()end

-- order object: order handle
order = {}
--- @class order
--- @field order.Priority number Priority of the given order Order priority or 0 if invalid
--- @field order.Target object Target of the order. Value may also be a deriviative of the 'object' class, such as 'ship'. Target object or invalid object handle if order handle is invalid or order requires no target.
--- @field order.TargetSubsystem subsystem Target subsystem of the order. Target subsystem, or invalid subsystem handle if order handle is invalid or order requires no subsystem target.
--Removes the given order from the ship's priority queue.
--- @function order:remove(): boolean
--- @return boolean # True if order was successfully removed, otherwise false or nil.
function order:remove()end

--Gets the type of the order.
--- @function order:getType(): enumeration
--- @return enumeration # The type of the order as one of the ORDER_* enumerations.
function order:getType()end

--Detects whether handle is valid
--- @function order:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function order:isValid()end

-- orientation object: Orientation matrix object
orientation = {}
--- @class orientation
--Orientation component - pitch, bank, heading, or index into 3x3 matrix (1-9)
--- @function orientation:__indexer(axis: string): number
--- @param axis string p, b, h
--- @return number # Number at the specified index, or 0 if index is invalid.
function orientation:__indexer(axis)end--- @function orientation:__indexer(element: number): number
--- @param element number 1-9
--- @return number # Number at the specified index, or 0 if index is invalid.
function orientation:__indexer(element)end

--Multiplies two matrix objects)
--- @function orientation:__mul(param1: orientation): orientation
--- @param param1 orientation 
--- @return orientation # matrix, or empty matrix if unsuccessful
function orientation:__mul(param1)end

--Converts a matrix to a string with format "[r1c1 r2c1 r3c1 | r1c2 r2c2 r3c2| r1c3 r2c3 r3c3]"
--- @function orientation:__tostring(): string
--- @return string # Formatted string or "<NULL"
function orientation:__tostring()end

--Returns a copy of the orientation
--- @function orientation:copy(): orientation
--- @return orientation # The copy, or null orientation on failure
function orientation:copy()end

--Returns orientation that has been interpolated to Final by Factor (0.0-1.0).  This is a pure linear interpolation with no consideration given to matrix validity or normalization.  You may want 'rotationalInterpolate' instead.
--- @function orientation:getInterpolated(Final: orientation, Factor: number): orientation
--- @param Final orientation 
--- @param Factor number 
--- @return orientation # Interpolated orientation, or null orientation on failure
function orientation:getInterpolated(Final, Factor)end

--Interpolates between this (initial) orientation and a second one, using t as the multiplier of progress between them.  Intended values for t are [0.0f, 1.0f], but values outside this range are allowed.
--- @function orientation:rotationalInterpolate(final: orientation, t: number): orientation
--- @param final orientation 
--- @param t number 
--- @return orientation # The interpolated orientation, or NIL if any handle is invalid
function orientation:rotationalInterpolate(final, t)end

--Returns a transpose version of the specified orientation
--- @function orientation:getTranspose(): orientation
--- @return orientation # Transpose matrix, or null orientation on failure
function orientation:getTranspose()end

--Returns rotated version of given vector
--- @function orientation:rotateVector(Input: vector): vector
--- @param Input vector 
--- @return vector # Rotated vector, or empty vector on error
function orientation:rotateVector(Input)end

--Returns unrotated version of given vector
--- @function orientation:unrotateVector(Input: vector): vector
--- @param Input vector 
--- @return vector # Unrotated vector, or empty vector on error
function orientation:unrotateVector(Input)end

--Returns the vector that points up (0,1,0 unrotated by this matrix)
--- @function orientation:getUvec(): vector
--- @return vector # Vector or null vector on error
function orientation:getUvec()end

--Returns the vector that points to the front (0,0,1 unrotated by this matrix)
--- @function orientation:getFvec(): vector
--- @return vector # Vector or null vector on error
function orientation:getFvec()end

--Returns the vector that points to the right (1,0,0 unrotated by this matrix)
--- @function orientation:getRvec(): vector
--- @return vector # Vector or null vector on error
function orientation:getRvec()end

--Create a new normalized vector, randomly perturbed around a cone in the given orientation.  Angles are in degrees.  If only one angle is specified, it is the max angle.  If both are specified, the first is the minimum and the second is the maximum.
--- @function orientation:perturb(angle1: number, angle2: number): vector
--- @param angle1 number 
--- @param angle2 number? 
--- @return vector # A vector, somewhat perturbed from the experience
function orientation:perturb(angle1, angle2)end

-- oswpt object: Handle for LuaSEXP arguments that can hold different types (Object/Ship/Wing/Waypoint/Team)
oswpt = {}
--- @class oswpt
--The data-type this OSWPT yields on the get method.
--- @function oswpt:getType(): string
--- @return string # The name of the data type. Either 'ship', 'parseobject' (a yet-to-spawn ship), 'wing' (can include yet-to-arrive wings with 0 current ships), 'team' (both explicit and ship-on-team), 'waypoint',  or 'none' (either explicitly specified, a ship that doesn't exist anymore, or invalid OSWPT object).
function oswpt:getType()end

--Returns the data held by this OSWPT.
--- @function oswpt:get(): ship | parse_object | wing | team | waypoint | nil
--- @return ship | parse_object | wing | team | waypoint | nil # Returns the data held by this OSWPT, nil if type is 'none'.
function oswpt:get()end

--Applies this function to each (present) ship this OSWPT applies to.
--- @function oswpt:forAllShips(body: function(ship)): nothing
--- @param body function(ship) 
--- @return nil
function oswpt:forAllShips(body)end

--Applies this function to each not-yet-present ship (includes not-yet-present wings and not-yet-present ships of a specified team!) this OSWPT applies to.
--- @function oswpt:forAllParseObjects(body: function(parse_object)): nothing
--- @param body function(parse_object) 
--- @return nil
function oswpt:forAllParseObjects(body)end

-- parse_object object: Handle to a parsed ship
parse_object = {}
--- @class parse_object
--- @field parse_object.Name string The name of the parsed ship. If possible, don't set the name but set the display name instead. The name or empty string on error
--- @field parse_object.DisplayName string The display name of the parsed ship. If the name should be shown to the user, use this since it can be translated. The display name or empty string on error
--- @field parse_object.Position vector The position at which the parsed ship will arrive. The position of the parsed ship.
--- @field parse_object.Orientation orientation The orientation of the parsed ship. The orientation
--- @field parse_object.ShipClass shipclass The ship class of the parsed ship. The ship class
--- @field parse_object.Team team The team of the parsed ship. The team
--- @field parse_object.InitialHull number The initial hull percentage of this parsed ship. The initial hull
--- @field parse_object.InitialShields number The initial shields percentage of this parsed ship. The initial shields
--- @field parse_object.MainStatus parse_subsystem Gets the "subsystem" status of the ship itself. This is a special subsystem that represents the primary and secondary weapons and the AI class. The subsystem handle or invalid handle if there were no changes to the main status
--- @field parse_object.Subsystems parse_subsystem Get the list of subsystems of this parsed ship An array of the parse subsystems of this parsed ship
--- @field parse_object.ArrivalLocation string The ship's arrival location Arrival location, or nil if handle is invalid
--- @field parse_object.DepartureLocation string The ship's departure location Departure location, or nil if handle is invalid
--- @field parse_object.ArrivalAnchor string The ship's arrival anchor Arrival anchor, or nil if handle is invalid
--- @field parse_object.DepartureAnchor string The ship's departure anchor Departure anchor, or nil if handle is invalid
--- @field parse_object.ArrivalPathMask number The ship's arrival path mask Arrival path mask, or nil if handle is invalid
--- @field parse_object.DeparturePathMask number The ship's departure path mask Departure path mask, or nil if handle is invalid
--- @field parse_object.ArrivalDelay number The ship's arrival delay Arrival delay, or nil if handle is invalid
--- @field parse_object.DepartureDelay number The ship's departure delay Departure delay, or nil if handle is invalid
--- @field parse_object.ArrivalDistance number The ship's arrival distance Arrival distance, or nil if handle is invalid
--- @field parse_object.CollisionGroups number Collision group data Current set of collision groups. NOTE: This is a bitfield, NOT a normal number.
--Detect whether the parsed ship handle is valid
--- @function parse_object:isValid(): boolean
--- @return boolean # true if valid false otherwise
function parse_object:isValid()end

--Gets the FreeSpace type name
--- @function parse_object:getBreedName(): string
--- @return string # 'Parse Object', or empty string if handle is invalid
function parse_object:getBreedName()end

--Checks whether the parsed ship is a player ship
--- @function parse_object:isPlayer(): boolean
--- @return boolean # Whether the parsed ship is a player ship
function parse_object:isPlayer()end

--Sets or clears one or more flags - this function can accept an arbitrary number of flag arguments.  The flag names can be any string that the alter-ship-flag SEXP operator supports.
--- @function parse_object:setFlag(set_it: boolean, flag_name: string): nothing
--- @param set_it boolean 
--- @param flag_name string 
--- @return nil # Returns nothing
function parse_object:setFlag(set_it, flag_name)end

--Checks whether one or more flags are set - this function can accept an arbitrary number of flag arguments.  The flag names can be any string that the alter-ship-flag SEXP operator supports.
--- @function parse_object:getFlag(flag_name: string): boolean
--- @param flag_name string 
--- @return boolean # Returns whether all flags are set, or nil if the parsed ship is not valid
function parse_object:getFlag(flag_name)end

--Determines if this parsed ship is a player start.
--- @function parse_object:isPlayerStart(): boolean
--- @return boolean # true if player start, false if not or if invalid
function parse_object:isPlayerStart()end

--Returns the ship that was created from this parsed ship, if it is present in the mission.  Note that parse objects are reused when a wing has multiple waves, so this will always return a ship from the most recently created wave.
--- @function parse_object:getShip(): ship
--- @return ship # The created ship, an invalid handle if no ship exists, or nil if the current handle is invalid
function parse_object:getShip()end

--Returns the wing that this parsed ship belongs to, if any
--- @function parse_object:getWing(): wing
--- @return wing # The parsed ship's wing, an invalid wing handle if no wing exists, or nil if the handle is invalid
function parse_object:getWing()end

--Causes this parsed ship to arrive as if its arrival cue had become true.  Note that reinforcements are only marked as available, not actually created.
--- @function parse_object:makeShipArrive(): boolean
--- @return boolean # true if created, false otherwise
function parse_object:makeShipArrive()end

--Adds this parsed ship to the specified collision group.  The group must be between 0 and 31, inclusive.
--- @function parse_object:addToCollisionGroup(group: number): nothing
--- @param group number 
--- @return nil # Returns nothing
function parse_object:addToCollisionGroup(group)end

--Removes this parsed ship from the specified collision group.  The group must be between 0 and 31, inclusive.
--- @function parse_object:removeFromCollisionGroup(group: number): nothing
--- @param group number 
--- @return nil # Returns nothing
function parse_object:removeFromCollisionGroup(group)end

-- parse_subsystem object: Handle to a parse subsystem
parse_subsystem = {}
--- @class parse_subsystem
--- @field parse_subsystem.Name string The name of the subsystem. If possible, don't set the name but set the display name instead. The name or empty string on error
--- @field parse_subsystem.Damage number The percentage to what the subsystem is damage The percentage or negative on error
--- @field parse_subsystem.PrimaryBanks weaponclass The overridden primary banks The primary bank weapons or nil if not changed from default
--- @field parse_subsystem.PrimaryAmmo weaponclass The overridden primary ammunition, as a percentage of the default The primary bank ammunition percantage or nil if not changed from default
--- @field parse_subsystem.SecondaryBanks weaponclass The overridden secondary banks The secondary bank weapons or nil if not changed from default
--- @field parse_subsystem.SecondaryAmmo weaponclass The overridden secondary ammunition, as a percentage of the default The secondary bank ammunition percantage or nil if not changed from default
-- particle object: Handle to a particle
particle = {}
--- @class particle
--- @field particle.Position vector The current position of the particle (world vector) The current position
--- @field particle.Velocity vector The current velocity of the particle (world vector) The current velocity
--- @field particle.Age number The time this particle already lives The current age or -1 on error
--- @field particle.MaximumLife number The time this particle can live The maximal life or -1 on error
--- @field particle.Looping boolean The looping status of the particle. If a particle loops then it will not be removed when its max_life value has been reached. Instead its animation will be reset to the start. When the particle should finally be removed then set this to false and set MaxLife to 0. The looping status
--- @field particle.Radius number The radius of the particle The radius or -1 on error
--- @field particle.TracerLength number The tracer legth of the particle The radius or -1 on error
--- @field particle.AttachedObject object The object this particle is attached to. If valid the position will be relative to this object and the velocity will be ignored. Attached object or invalid object handle on error
--Detects whether this handle is valid
--- @function particle:isValid(): boolean
--- @return boolean # true if valid false if not
function particle:isValid()end

--Sets the color for a particle.  If the particle does not support color, the function does nothing.  (Currently only debug particles support color.)
--- @function particle:setColor(r: number, g: number, b: number): nothing
--- @param r number 
--- @param g number 
--- @param b number 
--- @return nil
function particle:setColor(r, g, b)end

-- persona object: Persona handle
persona = {}
--- @class persona
--- @field persona.Name string The name of the persona The name or empty string on error
--Detect if the handle is valid
--- @function persona:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function persona:isValid()end

-- physics object: Physics handle
physics = {}
--- @class physics
--- @field physics.AfterburnerAccelerationTime number Afterburner acceleration time Afterburner acceleration time, or 0 if handle is invalid
--- @field physics.AfterburnerVelocityMax vector Afterburner max velocity (Local vector) Afterburner max velocity, or null vector if handle is invalid
--- @field physics.BankingConstant number Banking constant Banking constant, or 0 if handle is invalid
--- @field physics.ForwardAccelerationTime number Forward acceleration time Forward acceleration time, or 0 if handle is invalid
--- @field physics.ForwardDecelerationTime number Forward deceleration time Forward deceleration time, or 0 if handle is invalid
--- @field physics.ForwardThrust number Forward thrust amount (-1 - 1), used primarily for thruster graphics and does not affect any physical behavior Forward thrust, or 0 if handle is invalid
--- @field physics.Mass number Object mass Object mass, or 0 if handle is invalid
--- @field physics.RotationalVelocity vector Rotational velocity (Local vector) Rotational velocity, or null vector if handle is invalid
--- @field physics.RotationalVelocityDamping number Rotational damping, ie derivative of rotational speed Rotational damping, or 0 if handle is invalid
--- @field physics.RotationalVelocityDesired vector Desired rotational velocity Desired rotational velocity, or null vector if handle is invalid
--- @field physics.RotationalVelocityMax vector Maximum rotational velocity (Local vector) Maximum rotational velocity, or null vector if handle is invalid
--- @field physics.ShockwaveShakeAmplitude number How much shaking from shockwaves is applied to object Shockwave shake amplitude, or 0 if handle is invalid
--- @field physics.SideThrust number Side thrust amount (-1 - 1), used primarily for thruster graphics and does not affect any physical behavior Side thrust amount, or 0 if handle is invalid
--- @field physics.SlideAccelerationTime number Time to accelerate to maximum slide velocity Sliding acceleration time, or 0 if handle is invalid
--- @field physics.SlideDecelerationTime number Time to decelerate from maximum slide speed Sliding deceleration time, or 0 if handle is invalid
--- @field physics.Velocity vector Object world velocity (World vector). Setting this value may have minimal effect unless the $Fix scripted velocity game settings flag is used. Object velocity, or null vector if handle is invalid
--- @field physics.VelocityDamping number Damping, the natural period (1 / omega) of the dampening effects on top of the acceleration model. Called 'side_slip_time_const' in code base.  Damping, or 0 if handle is invalid
--- @field physics.VelocityDesired vector Desired velocity (World vector) Desired velocity, or null vector if handle is invalid
--- @field physics.VelocityMax vector Object max local velocity (Local vector) Maximum velocity, or null vector if handle is invalid
--- @field physics.VerticalThrust number Vertical thrust amount (-1 - 1), used primarily for thruster graphics and does not affect any physical behavior Vertical thrust amount, or 0 if handle is invalid
--- @field physics.AfterburnerActive boolean Specifies if the afterburner is active or not true if afterburner is active false otherwise
--- @field physics.GravityConst number Multiplier for the effect of gravity on this object Multiplier, or 0 if handle is invalid
--True if valid, false or nil if not
--- @function physics:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function physics:isValid()end

--Gets total speed as of last frame
--- @function physics:getSpeed(): number
--- @return number # Total speed, or 0 if handle is invalid
function physics:getSpeed()end

--Gets total speed in the ship's 'forward' direction as of last frame
--- @function physics:getForwardSpeed(): number
--- @return number # Total forward speed, or 0 if handle is invalid
function physics:getForwardSpeed()end

--True if Afterburners are on, false or nil if not
--- @function physics:isAfterburnerActive(): boolean
--- @return boolean # Detects whether afterburner is active
function physics:isAfterburnerActive()end

--True if glide mode is on, false or nil if not
--- @function physics:isGliding(): boolean
--- @return boolean # Detects if ship is gliding
function physics:isGliding()end

--Applies a whack to an object based on an impulse vector, indicating the direction and strength of whack and optionally at a position relative to the ship in world orientation, the ship's center being default.
--- @function physics:applyWhack(Impulse: vector, Position: vector): boolean
--- @param Impulse vector 
--- @param Position vector? 
--- @return boolean # true if it succeeded, false otherwise
function physics:applyWhack(Impulse, Position)end

--Applies a whack to an object based on an impulse vector, indicating the direction and strength of whack and optionally at a world position, the ship's center being default.
--- @function physics:applyWhackWorld(Impulse: vector, Position: vector): boolean
--- @param Impulse vector 
--- @param Position vector? 
--- @return boolean # true if it succeeded, false otherwise
function physics:applyWhackWorld(Impulse, Position)end

-- player object: Player handle
player = {}
--- @class player
--- @field player.Stats scoring_stats The scoring stats of this player (read-only) The player stats or invalid handle
--- @field player.ImageFilename string The image filename of this pilot Player image filename, or empty string if handle is invalid
--- @field player.SingleSquadFilename string The singleplayer squad filename of this pilot singleplayer squad image filename, or empty string if handle is invalid
--- @field player.MultiSquadFilename string The multiplayer squad filename of this pilot Multiplayer squad image filename, or empty string if handle is invalid
--- @field player.IsMultiplayer boolean Determines if this player is currently configured for multiplayer. true if this is a multiplayer pilot, false otherwise or if the handle is invalid
--- @field player.WasMultiplayer boolean Determines if this player is currently configured for multiplayer. true if this is a multiplayer pilot, false otherwise or if the handle is invalid
--- @field player.AutoAdvance boolean Determines if briefing stages should be auto advanced. true if auto advance is enabled, false otherwise or if the handle is invalid
--- @field player.ShowSkipPopup boolean Determines if the skip mission popup is shown for the current mission. true if it should be shown, false otherwise or if the handle is invalid
--Detects whether handle is valid
--- @function player:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function player:isValid()end

--Gets current player name
--- @function player:getName(): string
--- @return string # Player name, or empty string if handle is invalid
function player:getName()end

--Gets current player campaign filename
--- @function player:getCampaignFilename(): string
--- @return string # Campaign name, or empty string if handle is invalid
function player:getCampaignFilename()end

--Gets current player image filename
--- @function player:getImageFilename(): string
--- @return string # Player image filename, or empty string if handle is invalid
function player:getImageFilename()end

--Gets player's current main hall name
--- @function player:getMainHallName(): string
--- @return string # Main hall name, or name of first mainhall in campaign if something goes wrong
function player:getMainHallName()end

--Gets player's current main hall number
--- @function player:getMainHallIndex(): number
--- @return number # Main hall index, or index of first mainhall in campaign if something goes wrong
function player:getMainHallIndex()end

--Gets current player squad name
--- @function player:getSquadronName(): string
--- @return string # Squadron name, or empty string if handle is invalid
function player:getSquadronName()end

--Gets current player multi squad name
--- @function player:getMultiSquadronName(): string
--- @return string # Squadron name, or empty string if handle is invalid
function player:getMultiSquadronName()end

--Loads the specified campaign save file.
--- @function player:loadCampaignSavefile(campaign: string): boolean
--- @param campaign string? 
--- @return boolean # true on success, false otherwise
function player:loadCampaignSavefile(campaign)end

--Loads the specified campaign file and return to it's mainhall.
--- @function player:loadCampaign(campaign: string): boolean
--- @param campaign string 
--- @return boolean # true on success, false otherwise
function player:loadCampaign(campaign)end

-- preset object: Control Preset handle
preset = {}
--- @class preset
--- @field preset.Name string The name of the preset The name
--Clones the preset into a new preset with the specified name. Sets it as the active preset
--- @function preset:clonePreset(Name: string): boolean
--- @param Name string 
--- @return boolean # Returns true if successful, false otherwise
function preset:clonePreset(Name)end

--Deletes the preset file entirely. Cannot delete a currently active preset.
--- @function preset:deletePreset(): boolean
--- @return boolean # Returns true if successful, false otherwise
function preset:deletePreset()end

-- promise object: A promise that represents an operation that will return a value at some point in the future
promise = {}
--- @class promise
--When the called on promise resolves, this function will be called with the resolved value of the promise.
--- @function promise:continueWith(param1: function(any)): promise
--- @param param1 function(any) 
--- @return promise # A promise that will resolve with the return value of the passed function.
function promise:continueWith(param1)end

--When the called on promise produces an error, this function will be called with the error value of the promise.
--- @function promise:catch(param1: function(any)): promise
--- @param param1 function(any) 
--- @return promise # A promise that will resolve with the return value of the passed function.
function promise:catch(param1)end

--Checks if the promise is already resolved.
--- @function promise:isResolved(): boolean
--- @return boolean # true if resolved, false if result is still pending.
function promise:isResolved()end

--Checks if the promise is already in an error state.
--- @function promise:isErrored(): boolean
--- @return boolean # true if errored, false if result is still pending.
function promise:isErrored()end

--Gets the resolved value of this promise. Causes an error when used on an unresolved or errored promise!
--- @function promise:getValue(): any
--- @return any # The resolved values.
function promise:getValue()end

--Gets the error value of this promise. Causes an error when used on an unresolved or resolved promise!
--- @function promise:getErrorValue(): any
--- @return any # The error values.
function promise:getErrorValue()end

-- pxo_channel object: Channel Section handle
pxo_channel = {}
--- @class pxo_channel
--- @field pxo_channel.Name string The name of the channel The name
--- @field pxo_channel.Description string The description of the channel The description
--- @field pxo_channel.NumPlayers string The number of players in the channel The number of players
--- @field pxo_channel.NumGames string The number of games the channel The number of games
--Detects whether handle is valid
--- @function pxo_channel:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function pxo_channel:isValid()end

--Returns whether this is the current channel
--- @function pxo_channel:isCurrent(): boolean
--- @return boolean # true for current, false otherwise. Nil if invalid.
function pxo_channel:isCurrent()end

--Joins the specified channel
--- @function pxo_channel:joinChannel(): nothing
--- @return nil
function pxo_channel:joinChannel()end

-- rank object: Rank handle
rank = {}
--- @class rank
--- @field rank.Name string The name of the rank The name
--- @field rank.AltName string The alt name of the rank The alt name
--- @field rank.Title string The title of the rank The title
--- @field rank.Bitmap string The bitmap of the rank The bitmap
--- @field rank.Index number The index of the rank within the Ranks list The rank index
--Detects whether handle is valid
--- @function rank:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function rank:isValid()end

-- red_alert_stage object: Red Alert stage handle
red_alert_stage = {}
--- @class red_alert_stage
--- @field red_alert_stage.Text string The briefing text of the stage The text string
--- @field red_alert_stage.AudioFilename string The audio file of the stage The audio file
-- rpc object: A function object for remote procedure calls
rpc = {}
--- @class rpc
--Sets the function to be called when the RPC is invoked on this client
--- @function rpc:__newindex(rpc_body: function(any)): function(any)
--- @param rpc_body function(any) 
--- @return function(any) # The function the RPC is set to
function rpc:__newindex(rpc_body)end

--Calls the RPC on the specified recipients with the given argument.
--- @function rpc:__call(param1: any, recipient: enumeration): boolean
--- @param param1 any? 
--- @param recipient enumeration? as set on RPC creation
--- @return boolean # True, if RPC call happened (not a guarantee for arrival at the recipient!)
function rpc:__call(param1, recipient)end

--Performs an asynchronous wait until this RPC has been evoked on this client and the RPC function has finished running. Does NOT trigger when the RPC is called from this client.
--- @function rpc:waitRPC(): promise
--- @return promise # A promise with no return value that resolves when this RPC has been called the next time.
function rpc:waitRPC()end

-- scoring_stats object: Player related scoring stats.
scoring_stats = {}
--- @class scoring_stats
--- @field scoring_stats.Score number The current score. The score value
--- @field scoring_stats.PrimaryShotsFired number The number of primary shots that have been fired. The score value
--- @field scoring_stats.PrimaryShotsHit number The number of primary shots that have hit. The score value
--- @field scoring_stats.PrimaryFriendlyHit number The number of primary friendly fire hits. The score value
--- @field scoring_stats.SecondaryShotsFired number The number of secondary shots that have been fired. The score value
--- @field scoring_stats.SecondaryShotsHit number The number of secondary shots that have hit. The score value
--- @field scoring_stats.SecondaryFriendlyHit number The number of secondary friendly fire hits. The score value
--- @field scoring_stats.TotalKills number The total number of kills. The score value
--- @field scoring_stats.Assists number The total number of assists. The score value
--- @field scoring_stats.MissionPrimaryShotsFired number The number of primary shots that have been fired in the current mission. The score value
--- @field scoring_stats.MissionPrimaryShotsHit number The number of primary shots that have hit in the current mission. The score value
--- @field scoring_stats.MissionPrimaryFriendlyHit number The number of primary friendly fire hits in the current mission. The score value
--- @field scoring_stats.MissionSecondaryShotsFired number The number of secondary shots that have been fired in the current mission. The score value
--- @field scoring_stats.MissionSecondaryShotsHit number The number of secondary shots that have hit in the current mission. The score value
--- @field scoring_stats.MissionSecondaryFriendlyHit number The number of secondary friendly fire hits in the current mission. The score value
--- @field scoring_stats.MissionTotalKills number The total number of kills in the current mission. The score value
--- @field scoring_stats.MissionAssists number The total number of assists in the current mission. The score value
--- @field scoring_stats.Medals table<number, number> Gets a table of medals that the player has earned. The number returned is the number of times the player has won that medal. The index position in the table is an index into Medals. The medals table
--- @field scoring_stats.Rank rank Returns the player's current rank The current rank
--Returns the number of kills of a specific ship class recorded in this statistics structure.
--- @function scoring_stats:getShipclassKills(class: shipclass): number
--- @param class shipclass 
--- @return number # The kills for that specific ship class
function scoring_stats:getShipclassKills(class)end

--Returns the number of kills of a specific ship class recorded in this statistics structure for the current mission.
--- @function scoring_stats:getMissionShipclassKills(class: shipclass): number
--- @param class shipclass 
--- @return number # The kills for that specific ship class
function scoring_stats:getMissionShipclassKills(class)end

--Sets the number of kills of a specific ship class recorded in this statistics structure for the current mission. Returns true if successful.
--- @function scoring_stats:setMissionShipclassKills(class: shipclass, kills: number): boolean
--- @param class shipclass 
--- @param kills number 
--- @return boolean # True if successful
function scoring_stats:setMissionShipclassKills(class, kills)end

-- sexpvariable object: SEXP Variable handle
sexpvariable = {}
--- @class sexpvariable
--- @field sexpvariable.Name string SEXP Variable name. SEXP Variable name, or empty string if handle is invalid
--- @field sexpvariable.Persistence enumeration SEXP Variable persistence, uses SEXPVAR_*_PERSISTENT enumerations SEXPVAR_*_PERSISTENT enumeration, or invalid numeration if handle is invalid
--- @field sexpvariable.Type enumeration SEXP Variable type, uses SEXPVAR_TYPE_* enumerations SEXPVAR_TYPE_* enumeration, or invalid numeration if handle is invalid
--- @field sexpvariable.Value string SEXP variable value SEXP variable contents, or nil if the variable is of an invalid type or the handle is invalid
--Returns SEXP name
--- @function sexpvariable:__tostring(): string
--- @return string # SEXP name, or empty string if handle is invalid
function sexpvariable:__tostring()end

--Detects whether handle is valid
--- @function sexpvariable:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function sexpvariable:isValid()end

--Deletes a SEXP Variable
--- @function sexpvariable:delete(): boolean
--- @return boolean # True if successful, false if the handle is invalid
function sexpvariable:delete()end

-- shields object: Shields handle
shields = {}
--- @class shields
--- @field shields.CombinedLeft number Total shield hitpoints left (for all segments combined) Combined shield strength, or 0 if handle is invalid
--- @field shields.CombinedMax number Maximum shield hitpoints (for all segments combined) Combined maximum shield strength, or 0 if handle is invalid
--Number of shield segments
--- @function shields:__len(): number
--- @return number # Number of shield segments or 0 if handle is invalid
function shields:__len()end

--Gets or sets shield segment strength. Use "SHIELD_*" enumerations (for standard 4-quadrant shields) or index of a specific segment, or NONE for the entire shield
--- @function shields:__indexer(param1: enumeration | number): number
--- @param param1 enumeration | number 
--- @return number # Segment/shield strength, or 0 if handle is invalid
function shields:__indexer(param1)end

--Detects whether handle is valid
--- @function shields:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function shields:isValid()end

-- ship object: Ship handle
ship = {}
--- @class ship
--- @field ship.ShieldArmorClass string Current Armor class of the ships' shield Armor class name, or empty string if none is set
--- @field ship.ImpactDamageClass string Current Impact Damage class Impact Damage class name, or empty string if none is set
--- @field ship.ArmorClass string Current Armor class Armor class name, or empty string if none is set
--- @field ship.Name string Ship name. This is the actual name of the ship. Use <i>getDisplayString</i> to get the string which should be displayed to the player. Ship name, or empty string if handle is invalid
--- @field ship.DisplayName string Ship display name The display name of the ship or empty if there is no display string
--- @field ship.AfterburnerFuelLeft number Afterburner fuel left Afterburner fuel left, or 0 if handle is invalid
--- @field ship.AfterburnerFuelMax number Afterburner fuel capacity Afterburner fuel capacity, or 0 if handle is invalid
--- @field ship.Class shipclass Ship class Ship class, or invalid shipclass handle if ship handle is invalid
--- @field ship.CountermeasuresLeft number Number of countermeasures left Countermeasures left, or 0 if ship handle is invalid
--- @field ship.CockpitDisplays displays An array of the cockpit displays on this ship.<br>NOTE: Only the ship of the player has these displays handle or invalid handle on error
--- @field ship.CountermeasureClass weaponclass Weapon class mounted on this ship's countermeasure point Countermeasure hardpoint weapon class, or invalid weaponclass handle if no countermeasure class or ship handle is invalid
--- @field ship.HitpointsMax number Total hitpoints Ship maximum hitpoints, or 0 if handle is invalid
--- @field ship.ShieldRegenRate number Maximum percentage/100 of shield energy regenerated per second. For example, 0.02 = 2% recharge per second. Ship maximum shield regeneration rate, or 0 if handle is invalid
--- @field ship.WeaponRegenRate number Maximum percentage/100 of weapon energy regenerated per second. For example, 0.02 = 2% recharge per second. Ship maximum weapon regeneration rate, or 0 if handle is invalid
--- @field ship.WeaponEnergyLeft number Current weapon energy reserves Ship current weapon energy reserve level, or 0 if invalid
--- @field ship.WeaponEnergyMax number Maximum weapon energy Ship maximum weapon energy reserve level, or 0 if invalid
--- @field ship.AutoaimFOV number FOV of ship's autoaim, if any FOV (in degrees), or 0 if ship uses no autoaim or if handle is invalid
--- @field ship.PrimaryTriggerDown boolean Determines if primary trigger is pressed or not True if pressed, false if not, nil if ship handle is invalid
--- @field ship.PrimaryBanks weaponbanktype Array of primary weapon banks Primary weapon banks, or invalid weaponbanktype handle if ship handle is invalid
--- @field ship.SecondaryBanks weaponbanktype Array of secondary weapon banks Secondary weapon banks, or invalid weaponbanktype handle if ship handle is invalid
--- @field ship.TertiaryBanks weaponbanktype Array of tertiary weapon banks Tertiary weapon banks, or invalid weaponbanktype handle if ship handle is invalid
--- @field ship.Target object Target of ship. Value may also be a deriviative of the 'object' class, such as 'ship'. Target object, or invalid object handle if no target or ship handle is invalid
--- @field ship.TargetSubsystem subsystem Target subsystem of ship. Target subsystem, or invalid subsystem handle if no target or ship handle is invalid
--- @field ship.Team team Ship's team Ship team, or invalid team handle if ship handle is invalid
--- @field ship.PersonaIndex number Persona index The index of the persona from messages.tbl, 0 if no persona is set
--- @field ship.Textures modelinstancetextures Gets ship textures Ship textures, or invalid shiptextures handle if ship handle is invalid
--- @field ship.FlagAffectedByGravity boolean Checks for the "affected-by-gravity" flag True if flag is set, false if flag is not set and nil on error
--- @field ship.Disabled boolean The disabled state of this ship true if ship is disabled, false otherwise
--- @field ship.Stealthed boolean Stealth status of this ship true if stealthed, false otherwise or on error
--- @field ship.HiddenFromSensors boolean Hidden from sensors status of this ship true if invisible to hidden from sensors, false otherwise or on error
--- @field ship.Gliding boolean Specifies whether this ship is currently gliding or not. true if gliding, false otherwise or in case of error
--- @field ship.EtsEngineIndex number (SET not implemented, see EtsSetIndexes) Ships ETS Engine index value, 0 to MAX_ENERGY_INDEX
--- @field ship.EtsShieldIndex number (SET not implemented, see EtsSetIndexes) Ships ETS Shield index value, 0 to MAX_ENERGY_INDEX
--- @field ship.EtsWeaponIndex number (SET not implemented, see EtsSetIndexes) Ships ETS Weapon index value, 0 to MAX_ENERGY_INDEX
--- @field ship.Orders shiporders Array of ship orders Ship orders, or invalid handle if ship handle is invalid
--- @field ship.WaypointSpeedCap number Waypoint speed cap The limit on the ship's speed for traversing waypoints.  -1 indicates no speed cap.  0 will be returned if handle is invalid.
--- @field ship.ArrivalLocation string The ship's arrival location Arrival location, or nil if handle is invalid
--- @field ship.DepartureLocation string The ship's departure location Departure location, or nil if handle is invalid
--- @field ship.ArrivalAnchor string The ship's arrival anchor Arrival anchor, or nil if handle is invalid
--- @field ship.DepartureAnchor string The ship's departure anchor Departure anchor, or nil if handle is invalid
--- @field ship.ArrivalPathMask number The ship's arrival path mask Arrival path mask, or nil if handle is invalid
--- @field ship.DeparturePathMask number The ship's departure path mask Departure path mask, or nil if handle is invalid
--- @field ship.ArrivalDelay number The ship's arrival delay Arrival delay, or nil if handle is invalid
--- @field ship.DepartureDelay number The ship's departure delay Departure delay, or nil if handle is invalid
--- @field ship.ArrivalDistance number The ship's arrival distance Arrival distance, or nil if handle is invalid
--Array of ship subsystems
--- @function ship:__indexer(NameOrIndex: string | number): subsystem
--- @param NameOrIndex string | number 
--- @return subsystem # Subsystem handle, or invalid subsystem handle if index or ship handle is invalid
function ship:__indexer(NameOrIndex)end

--Number of subsystems on ship
--- @function ship:__len(): number
--- @return number # Subsystem number, or 0 if handle is invalid
function ship:__len()end

--Sets or clears one or more flags - this function can accept an arbitrary number of flag arguments.  The flag names can be any string that the alter-ship-flag SEXP operator supports.
--- @function ship:setFlag(set_it: boolean, flag_name: string): nothing
--- @param set_it boolean 
--- @param flag_name string 
--- @return nil # Returns nothing
function ship:setFlag(set_it, flag_name)end

--Checks whether one or more flags are set - this function can accept an arbitrary number of flag arguments.  The flag names can be any string that the alter-ship-flag SEXP operator supports.
--- @function ship:getFlag(flag_name: string): boolean
--- @param flag_name string 
--- @return boolean # Returns whether all flags are set, or nil if the ship is not valid
function ship:getFlag(flag_name)end

--Checks whether the ship is a player ship
--- @function ship:isPlayer(): boolean
--- @return boolean # Whether the ship is a player ship
function ship:isPlayer()end

--Sends a message from the given ship with the given priority.<br>If delay is specified, the message will be delayed by the specified time in seconds.
--- @function ship:sendMessage(message: message, delay: number, priority: enumeration): boolean
--- @param message message 
--- @param delay number? 
--- @param priority enumeration? 
--- @return boolean # true if successful, false otherwise
function ship:sendMessage(message, delay, priority)end

--turns the ship towards the specified point during this frame
--- @function ship:turnTowardsPoint(target: vector, respectDifficulty: boolean, turnrateModifier: vector, bank: number): nothing
--- @param target vector 
--- @param respectDifficulty boolean? 
--- @param turnrateModifier vector? 100% of tabled values in all rotation axes by default
--- @param bank number? native bank-on-heading by default
--- @return nil
function ship:turnTowardsPoint(target, respectDifficulty, turnrateModifier, bank)end

--turns the ship towards the specified orientation during this frame
--- @function ship:turnTowardsOrientation(target: orientation, respectDifficulty: boolean, turnrateModifier: vector): nothing
--- @param target orientation 
--- @param respectDifficulty boolean? 
--- @param turnrateModifier vector? 100% of tabled values in all rotation axes by default
--- @return nil
function ship:turnTowardsOrientation(target, respectDifficulty, turnrateModifier)end

--Returns the position of the ship's physical center, which may not be the position of the origin of the model
--- @function ship:getCenterPosition(): vector
--- @return vector # World position of the center of the ship, or nil if an error occurred
function ship:getCenterPosition()end

--Kills the ship. Set "Killer" to a ship (or a weapon fired by that ship) to credit it for the kill in the mission log. Set it to the ship being killed to self-destruct. Set "Hitpos" to the world coordinates of the weapon impact.
--- @function ship:kill(Killer: object, Hitpos: vector): boolean
--- @param Killer object? 
--- @param Hitpos vector? 
--- @return boolean # True if successful, false or nil otherwise
function ship:kill(Killer, Hitpos)end

--checks if a ship can appear on the viewer's radar. If a viewer is not provided it assumes the viewer is the player. 
--- @function ship:checkVisibility(viewer: ship): number
--- @param viewer ship? 
--- @return number # Returns 0 - not visible, 1 - partially visible, 2 - fully visible
function ship:checkVisibility(viewer)end

--Activates an effect for this ship. Effect names are defined in Post_processing.tbl, and need to be implemented in the main shader. This functions analogous to the ship-effect sexp. NOTE: only one effect can be active at any time, adding new effects will override effects already in progress. 
--- @function ship:addShipEffect(name: string, durationMillis: number): boolean
--- @param name string 
--- @param durationMillis number 
--- @return boolean # Returns true if the effect was successfully added, false otherwise
function ship:addShipEffect(name, durationMillis)end

--Checks if the ship explosion event has already happened
--- @function ship:hasShipExploded(): number
--- @return number # Returns 1 if first explosion timestamp is passed, 2 if second is passed, 0 otherwise
function ship:hasShipExploded()end

--Checks if the ship is arriving via warp.  This includes both stage 1 (when the portal is opening) and stage 2 (when the ship is moving through the portal).
--- @function ship:isArrivingWarp(): boolean
--- @return boolean # True if the ship is warping in, false otherwise
function ship:isArrivingWarp()end

--Checks if the ship is departing via warp
--- @function ship:isDepartingWarp(): boolean
--- @return boolean # True if the Depart_warp flag is set, false otherwise
function ship:isDepartingWarp()end

--Checks if the ship is departing via warp
--- @function ship:isDepartingDockbay(): boolean
--- @return boolean # True if the Depart_dockbay flag is set, false otherwise
function ship:isDepartingDockbay()end

--Checks if the ship is dying (doing its death roll or exploding)
--- @function ship:isDying(): boolean
--- @return boolean # True if the Dying flag is set, false otherwise
function ship:isDying()end

--Launches a countermeasure from the ship
--- @function ship:fireCountermeasure(): boolean
--- @return boolean # Whether countermeasure was launched or not
function ship:fireCountermeasure()end

--Fires ship primary bank(s)
--- @function ship:firePrimary(): number
--- @return number # Number of primary banks fired
function ship:firePrimary()end

--Fires ship secondary bank(s)
--- @function ship:fireSecondary(): number
--- @return number # Number of secondary banks fired
function ship:fireSecondary()end

--Gets time that animation will be done
--- @function ship:getAnimationDoneTime(Type: number, Subtype: number): number
--- @param Type number 
--- @param Subtype number 
--- @return number # Time (seconds), or 0 if ship handle is invalid
function ship:getAnimationDoneTime(Type, Subtype)end

--Clears a ship's orders list
--- @function ship:clearOrders(): boolean
--- @return boolean # True if successful, otherwise false or nil
function ship:clearOrders()end

--Uses the goal code to execute orders
--- @function ship:giveOrder(Order: enumeration, Target: object, TargetSubsystem: subsystem, Priority: number, TargetShipclass: shipclass): boolean
--- @param Order enumeration 
--- @param Target object? 
--- @param TargetSubsystem subsystem? 
--- @param Priority number? 
--- @param TargetShipclass shipclass? 
--- @return boolean # True if order was given, otherwise false or nil
function ship:giveOrder(Order, Target, TargetSubsystem, Priority, TargetShipclass)end

--Sets ship maneuver over the defined time period
--- @function ship:doManeuver(Duration: number, Heading: number, Pitch: number, Bank: number, ApplyAllRotation: boolean, Vertical: number, Sideways: number, Forward: number, ApplyAllMovement: boolean, ManeuverBitfield: number): boolean
--- @param Duration number 
--- @param Heading number 
--- @param Pitch number 
--- @param Bank number 
--- @param ApplyAllRotation boolean 
--- @param Vertical number 
--- @param Sideways number 
--- @param Forward number 
--- @param ApplyAllMovement boolean 
--- @param ManeuverBitfield number 
--- @return boolean # True if maneuver order was given, otherwise false or nil
function ship:doManeuver(Duration, Heading, Pitch, Bank, ApplyAllRotation, Vertical, Sideways, Forward, ApplyAllMovement, ManeuverBitfield)end

--Triggers an animation. Type is the string name of the animation type, Subtype is the subtype number, such as weapon bank #, Forwards and Instant are boolean, defaulting to true & false respectively.<br><strong>IMPORTANT: Function is in testing and should not be used with official mod releases</strong>
--- @function ship:triggerAnimation(Type: string, Subtype: number, Forwards: boolean, Instant: boolean): boolean
--- @param Type string 
--- @param Subtype number? 
--- @param Forwards boolean? 
--- @param Instant boolean? 
--- @return boolean # True if successful, false or nil otherwise
function ship:triggerAnimation(Type, Subtype, Forwards, Instant)end

--Triggers an animation. If used often with the same type / triggeredBy, consider using getSubmodelAnimation for performance reasons. Type is the string name of the animation type, triggeredBy is a closer specification which animation should trigger. See *-anim.tbm specifications. Forwards controls the direction of the animation. ResetOnStart will cause the animation to play from its initial state, as opposed to its current state. CompleteInstant will immediately complete the animation. Pause will instead stop the animation at the current state.
--- @function ship:triggerSubmodelAnimation(type: string, triggeredBy: string, forwards: boolean, resetOnStart: boolean, completeInstant: boolean, pause: boolean): boolean
--- @param type string 
--- @param triggeredBy string 
--- @param forwards boolean? 
--- @param resetOnStart boolean? 
--- @param completeInstant boolean? 
--- @param pause boolean? 
--- @return boolean # True if successful, false or nil otherwise
function ship:triggerSubmodelAnimation(type, triggeredBy, forwards, resetOnStart, completeInstant, pause)end

--Gets an animation handle. Type is the string name of the animation type, triggeredBy is a closer specification which animation should trigger. See *-anim.tbm specifications. 
--- @function ship:getSubmodelAnimation(type: string, triggeredBy: string): animation_handle
--- @param type string 
--- @param triggeredBy string 
--- @return animation_handle # The animation handle for the specified animation, nil if invalid arguments.
function ship:getSubmodelAnimation(type, triggeredBy)end

--Stops a currently looping animation after it has finished its current loop. If used often with the same type / triggeredBy, consider using getSubmodelAnimation for performance reasons. Type is the string name of the animation type, triggeredBy is a closer specification which animation was triggered. See *-anim.tbm specifications. 
--- @function ship:stopLoopingSubmodelAnimation(type: string, triggeredBy: string): boolean
--- @param type string 
--- @param triggeredBy string 
--- @return boolean # True if successful, false or nil otherwise
function ship:stopLoopingSubmodelAnimation(type, triggeredBy)end

--Sets the speed multiplier at which an animation runs. If used often with the same type / triggeredBy, consider using getSubmodelAnimation for performance reasons. Anything other than 1 will not work in multiplayer. Type is the string name of the animation type, triggeredBy is a closer specification which animation should trigger. See *-anim.tbm specifications.
--- @function ship:setAnimationSpeed(type: string, triggeredBy: string, speedMultiplier: number): nothing
--- @param type string 
--- @param triggeredBy string 
--- @param speedMultiplier number? 
--- @return nil
function ship:setAnimationSpeed(type, triggeredBy, speedMultiplier)end

--Gets time that animation will be done. If used often with the same type / triggeredBy, consider using getSubmodelAnimation for performance reasons.
--- @function ship:getSubmodelAnimationTime(type: string, triggeredBy: string): number
--- @param type string 
--- @param triggeredBy string 
--- @return number # Time (seconds), or 0 if ship handle is invalid
function ship:getSubmodelAnimationTime(type, triggeredBy)end

--Updates a moveable animation. Name is the name of the moveable. For what values needs to contain, please refer to the table below, depending on the type of the moveable:Orientation:  	Three numbers, x, y, z rotation respectively, in degrees  Rotation:  	Three numbers, x, y, z rotation respectively, in degrees  Axis Rotation:  	One number, rotation angle in degrees  Inverse Kinematics:  	Three required numbers: x, y, z position target relative to base, in 1/100th meters  	Three optional numbers: x, y, z rotation target relative to base, in degrees  
--- @function ship:updateSubmodelMoveable(name: string, values: table): boolean
--- @param name string 
--- @param values table 
--- @return boolean # True if successful, false or nil otherwise
function ship:updateSubmodelMoveable(name, values)end

--Warps ship in
--- @function ship:warpIn(): boolean
--- @return boolean # True if successful, or nil if ship handle is invalid
function ship:warpIn()end

--Warps ship out
--- @function ship:warpOut(): boolean
--- @return boolean # True if successful, or nil if ship handle is invalid
function ship:warpOut()end

--Checks whether ship has a working subspace drive, is allowed to use it, and is not disabled or limited by subsystem strength.
--- @function ship:canWarp(): boolean
--- @return boolean # True if successful, or nil if ship handle is invalid
function ship:canWarp()end

--Checks whether ship has a bay departure location and if its mother ship is present.
--- @function ship:canBayDepart(): boolean
--- @return boolean # True if successful, or nil if ship handle is invalid
function ship:canBayDepart()end

--Checks if ship is in stage 1 of warping in
--- @function ship:isWarpingIn(): boolean
--- @return boolean # True if the ship is in stage 1 of warping in; false if not; nil for an invalid handle
function ship:isWarpingIn()end

--Checks if ship is in stage 1 of warping in, which is the stage when the warp portal is opening but before the ship has gone through.  During this stage, the ship's radar blip is blue, while the ship itself is invisible, does not collide, and has velocity 0.
--- @function ship:isWarpingStage1(): boolean
--- @return boolean # True if the ship is in stage 1 of warping in; false if not; nil for an invalid handle
function ship:isWarpingStage1()end

--Checks if ship is in stage 2 of warping in, which is the stage when it is traversing the warp portal.  Stage 2 ends as soon as the ship is completely through the portal and does not include portal closing or ship deceleration.
--- @function ship:isWarpingStage2(): boolean
--- @return boolean # True if the ship is in stage 2 of warping in; false if not; nil for an invalid handle
function ship:isWarpingStage2()end

--Returns the current emp effect strength acting on the object
--- @function ship:getEMP(): number
--- @return number # Current EMP effect strength or NIL if object is invalid
function ship:getEMP()end

--Returns the time in seconds until the ship explodes (the ship's final_death_time timestamp)
--- @function ship:getTimeUntilExplosion(): number
--- @return number # Time until explosion or -1, if invalid handle or ship isn't exploding
function ship:getTimeUntilExplosion()end

--Sets the time in seconds until the ship explodes (the ship's final_death_time timestamp).  This function will only work if the ship is in its death roll but hasn't exploded yet, which can be checked via isDying() or getTimeUntilExplosion().
--- @function ship:setTimeUntilExplosion(Time: number): boolean
--- @param Time number 
--- @return boolean # True if successful, false if the ship is invalid or not currently exploding
function ship:setTimeUntilExplosion(Time)end

--Gets the callsign of the ship in the current mission
--- @function ship:getCallsign(): string
--- @return string # The callsign or an empty string if the ship doesn't have a callsign or an error occurs
function ship:getCallsign()end

--Gets the alternate class name of the ship
--- @function ship:getAltClassName(): string
--- @return string # The alternate class name or an empty string if the ship doesn't have such a thing or an error occurs
function ship:getAltClassName()end

--Gets the maximum speed of the ship with the given energy on the engines
--- @function ship:getMaximumSpeed(energy: number): number
--- @param energy number? 
--- @return number # The maximum speed or -1 on error
function ship:getMaximumSpeed(energy)end

--Sets ships ETS systems to specified values
--- @function ship:EtsSetIndexes(EngineIndex: number, ShieldIndex: number, WeaponIndex: number): boolean
--- @param EngineIndex number 
--- @param ShieldIndex number 
--- @param WeaponIndex number 
--- @return boolean # True if successful, false if target ships ETS was missing, or only has one system
function ship:EtsSetIndexes(EngineIndex, ShieldIndex, WeaponIndex)end

--Returns the parsed ship that was used to create this ship, if any
--- @function ship:getParsedShip(): parse_object
--- @return parse_object # The parsed ship, an invalid handle if no parsed ship exists, or nil if the current handle is invalid
function ship:getParsedShip()end

--Returns the ship's wing
--- @function ship:getWing(): wing
--- @return wing # Wing handle, or invalid wing handle if ship is not part of a wing
function ship:getWing()end

--Returns the string which should be used when displaying the name of the ship to the player
--- @function ship:getDisplayString(): string
--- @return string # The display string or empty if handle is invalid
function ship:getDisplayString()end

--Vanishes this ship from the mission. Works in Singleplayer only and will cause the ship exit to not be logged.
--- @function ship:vanish(): boolean
--- @return boolean # True if the deletion was successful, false otherwise.
function ship:vanish()end

--Activates or deactivates one or more of a ship's glow point banks - this function can accept an arbitrary number of bank arguments.  Omit the bank number or specify -1 to activate or deactivate all banks.
--- @function ship:setGlowPointBankActive(active: boolean, bank: number): nothing
--- @param active boolean 
--- @param bank number? 
--- @return nil # Returns nothing
function ship:setGlowPointBankActive(active, bank)end

--Returns the number of ships this ship is directly docked with
--- @function ship:numDocked(): number
--- @return number # The number of ships
function ship:numDocked()end

--Returns whether this ship is docked to all of the specified dockee ships, or is docked at all if no ships are specified
--- @function ship:isDocked(dockee_ships: ship): boolean
--- @param dockee_ships ship? 
--- @return boolean # Returns whether the ship is docked
function ship:isDocked(dockee_ships)end

--Immediately docks this ship with another ship.
--- @function ship:setDocked(dockee_ship: ship, docker_point: string | number, dockee_point: string | number): boolean
--- @param dockee_ship ship 
--- @param docker_point string | number? 
--- @param dockee_point string | number? 
--- @return boolean # Returns whether the docking was successful, or nil if an input was invalid
function ship:setDocked(dockee_ship, docker_point, dockee_point)end

--Immediately undocks one or more dockee ships from this ship.
--- @function ship:setUndocked(dockee_ships: ship): number
--- @param dockee_ships ship? All docked ships by default
--- @return number # Returns the number of ships undocked
function ship:setUndocked(dockee_ships)end

--Jettisons one or more dockee ships from this ship at the specified speed.
--- @function ship:jettison(jettison_speed: number, dockee_ships: ship): number
--- @param jettison_speed number 
--- @param dockee_ships ship? All docked ships by default
--- @return number # Returns the number of ships jettisoned
function ship:jettison(jettison_speed, dockee_ships)end

--Creates an electric arc on the ship between two points in the ship's reference frame, for the specified duration in seconds, and the specified width in meters.
--- @function ship:AddElectricArc(firstPoint: vector, secondPoint: vector, duration: number, width: number): number
--- @param firstPoint vector 
--- @param secondPoint vector 
--- @param duration number 
--- @param width number 
--- @return number # The arc index if successful, 0 otherwise
function ship:AddElectricArc(firstPoint, secondPoint, duration, width)end

--Removes the specified electric arc from the ship.
--- @function ship:DeleteElectricArc(index: number): nothing
--- @param index number 
--- @return nil
function ship:DeleteElectricArc(index)end

--Sets the endpoints (in the ship's reference frame) and width of the specified electric arc on the ship, .
--- @function ship:ModifyElectricArc(index: number, firstPoint: vector, secondPoint: vector, width: number): nothing
--- @param index number 
--- @param firstPoint vector 
--- @param secondPoint vector 
--- @param width number? 
--- @return nil
function ship:ModifyElectricArc(index, firstPoint, secondPoint, width)end

-- ship_registry_entry object: Ship entry handle
ship_registry_entry = {}
--- @class ship_registry_entry
--- @field ship_registry_entry.Name string Name of ship Ship name, or empty string if handle is invalid
--- @field ship_registry_entry.Status enumeration Status of ship INVALID, NOT_YET_PRESENT, PRESENT, DEATH_ROLL, EXITED, or nil if handle is invalid
--Detects whether handle is valid
--- @function ship_registry_entry:isValid(): boolean
--- @return boolean # true if valid, false if invalid, nil if a syntax/type error occurs
function ship_registry_entry:isValid()end

--Return the parsed ship associated with this ship registry entry
--- @function ship_registry_entry:getParsedShip(): parse_object
--- @return parse_object # The parsed ship, or nil if handle is invalid.  If this ship entry is for a ship-create'd ship, the returned handle may be invalid.
function ship_registry_entry:getParsedShip()end

--Return the ship associated with this ship registry entry
--- @function ship_registry_entry:getShip(): ship
--- @return ship # The ship, or nil if handle is invalid.  The returned handle will be invalid if the ship has not yet arrived in-mission.
function ship_registry_entry:getShip()end

-- shipclass object: Ship class handle
shipclass = {}
--- @class shipclass
--- @field shipclass.Name string Ship class name Ship class name, or an empty string if handle is invalid
--- @field shipclass.ShortName string Ship class short name Ship short name, or empty string if handle is invalid
--- @field shipclass.TypeString string Ship class type string Type string, or empty string if handle is invalid
--- @field shipclass.ManeuverabilityString string Ship class maneuverability string Maneuverability string, or empty string if handle is invalid
--- @field shipclass.ArmorString string Ship class armor string Armor string, or empty string if handle is invalid
--- @field shipclass.ManufacturerString string Ship class manufacturer Manufacturer, or empty string if handle is invalid
--- @field shipclass.LengthString string Ship class length Length, or empty string if handle is invalid
--- @field shipclass.GunMountsString string Ship class gun mounts Gun mounts, or empty string if handle is invalid
--- @field shipclass.MissileBanksString string Ship class missile banks Missile banks, or empty string if handle is invalid
--- @field shipclass.VelocityString string Ship class velocity velocity, or empty string if handle is invalid
--- @field shipclass.Description string Ship class description Description, or empty string if handle is invalid
--- @field shipclass.SelectIconFilename string Ship class select icon filename Filename, or empty string if handle is invalid
--- @field shipclass.SelectAnimFilename string Ship class select animation filename Filename, or empty string if handle is invalid
--- @field shipclass.SelectOverheadFilename string Ship class select overhead filename Filename, or empty string if handle is invalid
--- @field shipclass.TechDescription string Ship class tech description Tech description, or empty string if handle is invalid
--- @field shipclass.numPrimaryBanks number Number of primary banks on this ship class number of banks or nil is ship handle is invalid
--- @field shipclass.numSecondaryBanks number Number of secondary banks on this ship class number of banks or nil is ship handle is invalid
--- @field shipclass.defaultPrimaries default_primary Array of default primary weapons The weapons array or nil if handle is invalid
--- @field shipclass.defaultSecondaries default_secondary Array of default secondary weapons The weapons array or nil if handle is invalid
--- @field shipclass.AfterburnerFuelMax number Afterburner fuel capacity Afterburner capacity, or 0 if handle is invalid
--- @field shipclass.ScanTime number Ship scan time Time required to scan, or 0 if handle is invalid. This property is read-only
--- @field shipclass.CountermeasureClass weaponclass The default countermeasure class assigned to this ship class Countermeasure hardpoint weapon class, or invalid weaponclass handle if no countermeasure class or ship handle is invalid
--- @field shipclass.CountermeasuresMax number Maximum number of countermeasures the ship can carry Countermeasure capacity, or 0 if handle is invalid
--- @field shipclass.Model model Model Ship class model, or invalid model handle if shipclass handle is invalid
--- @field shipclass.CockpitModel model Model used for first-person cockpit Cockpit model
--- @field shipclass.CockpitDisplays cockpitdisplays Gets the cockpit display information array of this ship class Array handle containing the information or invalid handle on error
--- @field shipclass.HitpointsMax number Ship class hitpoints Hitpoints, or 0 if handle is invalid
--- @field shipclass.ShieldHitpointsMax number Ship class shield hitpoints Shield hitpoints, or 0 if handle is invalid
--- @field shipclass.Species species Ship class species Ship class species, or invalid species handle if shipclass handle is invalid
--- @field shipclass.Type shiptype Ship class type Ship type, or invalid handle if shipclass handle is invalid
--- @field shipclass.AltName string Alternate name for ship class Alternate string or empty string if handle is invalid
--- @field shipclass.VelocityMax vector Ship's lateral and forward speeds Maximum velocity, or null vector if handle is invalid
--- @field shipclass.VelocityDamping number Damping, the natural period (1 / omega) of the dampening effects on top of the acceleration model.  Damping, or 0 if handle is invalid
--- @field shipclass.RearVelocityMax number The maximum rear velocity of the ship Speed, or 0 if handle is invalid
--- @field shipclass.ForwardAccelerationTime number Forward acceleration time Forward acceleration time, or 0 if handle is invalid
--- @field shipclass.ForwardDecelerationTime number Forward deceleration time Forward deceleration time, or 0 if handle is invalid
--- @field shipclass.RotationTime vector Maximum rotation time on each axis Full rotation time for each axis, or null vector if handle is invalid
--- @field shipclass.RotationalVelocityDamping number Rotational damping, ie derivative of rotational speed Rotational damping, or 0 if handle is invalid
--- @field shipclass.AfterburnerAccelerationTime number Afterburner acceleration time Afterburner acceleration time, or 0 if handle is invalid
--- @field shipclass.AfterburnerVelocityMax vector Afterburner max velocity Afterburner max velocity, or null vector if handle is invalid
--- @field shipclass.AfterburnerRearVelocityMax number Afterburner maximum rear velocity Rear velocity, or 0 if handle is invalid
--- @field shipclass.Score number The score of this ship class The score or -1 on invalid ship class
--- @field shipclass.InTechDatabase boolean Gets or sets whether this ship class is visible in the tech room True or false
--- @field shipclass.AllowedInCampaign boolean Gets or sets whether this ship class is allowed in loadouts in campaign mode True or false
--- @field shipclass.PowerOutput number Gets or sets a ship class' power output The ship class' current power output
--- @field shipclass.ScanningTimeMultiplier number Time multiplier for scans performed by this ship class Scanning time multiplier, or 0 if handle is invalid
--- @field shipclass.ScanningRangeMultiplier number Range multiplier for scans performed by this ship class Scanning range multiplier, or 0 if handle is invalid
--- @field shipclass.CustomData table Gets the custom data table for this ship class The ship class's custom data table
--- @field shipclass.CustomStrings table Gets the indexed custom string table for this ship. Each item in the table is a table with the following values: Name - the name of the custom string, Value - the value associated with the custom string, String - the custom string itself. The ship's custom data table
--Ship class name
--- @function shipclass:__tostring(): string
--- @return string # Ship class name, or an empty string if handle is invalid
function shipclass:__tostring()end

--Checks if the two classes are equal
--- @function shipclass:__eq(param1: shipclass, param2: shipclass): boolean
--- @param param1 shipclass 
--- @param param2 shipclass 
--- @return boolean # true if equal, false otherwise
function shipclass:__eq(param1, param2)end

--Returns the capacity of the specified primary bank
--- @function shipclass:getPrimaryBankCapacity(index: number): number
--- @param index number 
--- @return number # The bank capacity or nil if the index is invalid
function shipclass:getPrimaryBankCapacity(index)end

--Returns the capacity of the specified secondary bank
--- @function shipclass:getSecondaryBankCapacity(index: number): number
--- @param index number 
--- @return number # The bank capacity or nil if the index is invalid
function shipclass:getSecondaryBankCapacity(index)end

--Gets whether or not a weapon is allowed on a ship class. Optionally check a specific bank. Banks are 1 to a maximum of 7 where the first banks are Primaries and rest are Secondaries. Exact numbering depends on the ship class being checked. Note also that this will consider dogfight weapons only if a dogfight mission has been loaded. Index is index into Weapon Classes.
--- @function shipclass:isWeaponAllowedOnShip(index: number, bank: number): boolean
--- @param index number 
--- @param bank number? 
--- @return boolean # True if allowed, false if not.
function shipclass:isWeaponAllowedOnShip(index, bank)end

--Detects whether the ship class has any custom data
--- @function shipclass:hasCustomData(): boolean
--- @return boolean # true if the shipclass's custom_data is not empty, false otherwise
function shipclass:hasCustomData()end

--Detects whether the ship has any custom strings
--- @function shipclass:hasCustomStrings(): boolean
--- @return boolean # true if the ship's custom_strings is not empty, false otherwise
function shipclass:hasCustomStrings()end

--Detects whether handle is valid
--- @function shipclass:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function shipclass:isValid()end

--Gets whether or not the ship class is available in the techroom
--- @function shipclass:isInTechroom(): boolean
--- @return boolean # Whether ship has been revealed in the techroom, false if handle is invalid
function shipclass:isInTechroom()end

--Draws ship model as if in techroom. True for regular lighting, false for flat lighting.
--- @function shipclass:renderTechModel(X1: number, Y1: number, X2: number, Y2: number, RotationPercent: number, PitchPercent: number, BankPercent: number, Zoom: number, Lighting: boolean): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param RotationPercent number? 
--- @param PitchPercent number? 
--- @param BankPercent number? 
--- @param Zoom number? 
--- @param Lighting boolean? 
--- @return boolean # Whether ship was rendered
function shipclass:renderTechModel(X1, Y1, X2, Y2, RotationPercent, PitchPercent, BankPercent, Zoom, Lighting)end

--Draws ship model as if in techroom
--- @function shipclass:renderTechModel2(X1: number, Y1: number, X2: number, Y2: number, Orientation: orientation, Zoom: number): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param Orientation orientation? 
--- @param Zoom number? 
--- @return boolean # Whether ship was rendered
function shipclass:renderTechModel2(X1, Y1, X2, Y2, Orientation, Zoom)end

--Draws the 3D select ship model with the chosen effect at the specified coordinates. Restart should be true on the first frame this is called and false on subsequent frames. Valid selection effects are 1 (fs1) or 2 (fs2), defaults to the mod setting or the model's setting. Zoom is a multiplier to the model's closeup_zoom value.
--- @function shipclass:renderSelectModel(restart: boolean, x: number, y: number, width: number, height: number, currentEffectSetting: number, zoom: number): boolean
--- @param restart boolean 
--- @param x number 
--- @param y number 
--- @param width number? 
--- @param height number? 
--- @param currentEffectSetting number? 
--- @param zoom number? 
--- @return boolean # true if rendered, false if error
function shipclass:renderSelectModel(restart, x, y, width, height, currentEffectSetting, zoom)end

--Draws the 3D overhead ship model with the lines pointing from bank weapon selections to bank firepoints. SelectedSlot refers to loadout ship slots 1-12 where wing 1 is 1-4, wing 2 is 5-8, and wing 3 is 9-12. SelectedWeapon is the index into weapon classes. HoverSlot refers to the bank slots 1-7 where 1-3 are primaries and 4-6 are secondaries. Lines will be drawn from any bank containing the SelectedWeapon to the firepoints on the model of that bank. Similarly, lines will be drawn from the bank defined by HoverSlot to the firepoints on the model of that slot. Line drawing for HoverSlot takes precedence over line drawing for SelectedWeapon. Set either or both to -1 to stop line drawing. The bank coordinates are the coordinates from which the lines for that bank will be drawn. It is expected that primary slots will be on the left of the ship model and secondaries will be on the right. The lines have a hard-coded curve expecing to be drawn from those directions. Style can be 0 or 1. 0 for the ship to be drawn stationary from top down, 1 for the ship to be rotating.
--- @function shipclass:renderOverheadModel(x: number, y: number, width: number, height: number, param5: number | table, selectedWeapon: number, hoverSlot: number, bank1_x: number, bank1_y: number, bank2_x: number, bank2_y: number, bank3_x: number, bank3_y: number, bank4_x: number, bank4_y: number, bank5_x: number, bank5_y: number, bank6_x: number, bank6_y: number, bank7_x: number, bank7_y: number, style: number): boolean
--- @param x number 
--- @param y number 
--- @param width number? 
--- @param height number? 
--- @param param5 number | table? selectedSlot = -1 or empty table
--- @param selectedWeapon number? 
--- @param hoverSlot number? 
--- @param bank1_x number? 
--- @param bank1_y number? 
--- @param bank2_x number? 
--- @param bank2_y number? 
--- @param bank3_x number? 
--- @param bank3_y number? 
--- @param bank4_x number? 
--- @param bank4_y number? 
--- @param bank5_x number? 
--- @param bank5_y number? 
--- @param bank6_x number? 
--- @param bank6_y number? 
--- @param bank7_x number? 
--- @param bank7_y number? 
--- @param style number? 
--- @return boolean # true if rendered, false if error
function shipclass:renderOverheadModel(x, y, width, height, param5, selectedWeapon, hoverSlot, bank1_x, bank1_y, bank2_x, bank2_y, bank3_x, bank3_y, bank4_x, bank4_y, bank5_x, bank5_y, bank6_x, bank6_y, bank7_x, bank7_y, style)end

--Checks if the model used for this shipclass is loaded or not and optionally loads the model, which might be a slow operation.
--- @function shipclass:isModelLoaded(Load: boolean): boolean
--- @param Load boolean? 
--- @return boolean # If the model is loaded or not
function shipclass:isModelLoaded(Load)end

--Detects whether the ship has the player allowed flag
--- @function shipclass:isPlayerAllowed(): boolean
--- @return boolean # true if player allowed, false otherwise, nil if a syntax/type error occurs
function shipclass:isPlayerAllowed()end

--Gets the index value of the ship class
--- @function shipclass:getShipClassIndex(): number
--- @return number # index value of the ship class
function shipclass:getShipClassIndex()end

-- shiporders object: Ship orders
shiporders = {}
--- @class shiporders
--Number of ship orders
--- @function shiporders:__len(): number
--- @return number # Number of ship orders, or 0 if handle is invalid
function shiporders:__len()end

--Array of ship orders
--- @function shiporders:__indexer(Index: number): order
--- @param Index number 
--- @return order # Order, or invalid order handle on failure
function shiporders:__indexer(Index)end

--Detects whether handle is valid
--- @function shiporders:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function shiporders:isValid()end

-- shiptype object: Ship type handle
shiptype = {}
--- @class shiptype
--- @field shiptype.Name string Ship type name Ship type name, or empty string if handle is invalid
--Detects whether handle is valid
--- @function shiptype:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function shiptype:isValid()end

-- sim_mission object: Tech Room mission handle
sim_mission = {}
--- @class sim_mission
--- @field sim_mission.Name string The name of the mission The name
--- @field sim_mission.Filename string The filename of the mission The filename
--- @field sim_mission.Description string The mission description The description
--- @field sim_mission.Author string The mission author The author
--- @field sim_mission.isVisible boolean If the mission should be visible by default true if visible, false if not visible
--- @field sim_mission.isCampaignMission boolean If the mission is campaign or single true if campaign, false if single
-- sound object: sound instance handle
sound = {}
--- @class sound
--- @field sound.Pitch number Pitch of sound, from 100 to 100000 Pitch, or 0 if handle is invalid
--The remaining time of this sound handle
--- @function sound:getRemainingTime(): number
--- @return number # Remaining time, or -1 on error
function sound:getRemainingTime()end

--Sets the volume of this sound instance. Set voice to true to use the voice channel multiplier, or false to use the effects channel multiplier
--- @function sound:setVolume(param1: number, voice: boolean): boolean
--- @param param1 number 
--- @param voice boolean? 
--- @return boolean # true if succeeded, false otherwise
function sound:setVolume(param1, voice)end

--Sets the panning of this sound. Argument ranges from -1.0 for left to 1.0 for right
--- @function sound:setPanning(param1: number): boolean
--- @param param1 number 
--- @return boolean # true if succeeded, false otherwise
function sound:setPanning(param1)end

--Sets the absolute position of the sound. If boolean argument is true then the value is given as a percentage.<br>This operation fails if there is no backing soundentry!
--- @function sound:setPosition(value: number, percent: boolean): boolean
--- @param value number 
--- @param percent boolean? 
--- @return boolean # true if successful, false otherwise
function sound:setPosition(value, percent)end

--Rewinds the sound by the given number of seconds<br>This operation fails if there is no backing soundentry!
--- @function sound:rewind(param1: number): boolean
--- @param param1 number 
--- @return boolean # true if succeeded, false otherwise
function sound:rewind(param1)end

--Skips the given number of seconds of the sound<br>This operation fails if there is no backing soundentry!
--- @function sound:skip(param1: number): boolean
--- @param param1 number 
--- @return boolean # true if succeeded, false otherwise
function sound:skip(param1)end

--Checks if this handle is currently playing
--- @function sound:isPlaying(): boolean
--- @return boolean # true if playing, false if otherwise
function sound:isPlaying()end

--Stops the sound of this handle
--- @function sound:stop(): boolean
--- @return boolean # true if succeeded, false otherwise
function sound:stop()end

--Pauses the sound of this handle
--- @function sound:pause(): boolean
--- @return boolean # true if succeeded, false otherwise
function sound:pause()end

--Resumes the sound of this handle
--- @function sound:resume(): boolean
--- @return boolean # true if succeeded, false otherwise
function sound:resume()end

--Detects whether this sound, as well as its associated sound entry, are both valid.<br><b>Warning:</b> A sound can be usable without a sound entry! This function will not return true for sounds started by a directly loaded sound file. Use isSoundValid() in that case instead.
--- @function sound:isValid(): boolean
--- @return boolean # true if sound and entry are both valid, false if not, nil if a syntax/type error occurs
function sound:isValid()end

--Checks if the sound is valid without regard for whether the entry is valid. Should be used for non soundentry sounds.
--- @function sound:isSoundValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function sound:isSoundValid()end

-- sound3D object: 3D sound instance handle
sound3D = {}
--- @class sound3D
--Updates the given 3D sound with the specified position and an optional range value.<br>This operation fails if there is no backing soundentry!
--- @function sound3D:updatePosition(Position: vector, radius: number): boolean
--- @param Position vector 
--- @param radius number? 
--- @return boolean # true if succeeded, false otherwise
function sound3D:updatePosition(Position, radius)end

-- soundentry object: sounds.tbl table entry handle
soundentry = {}
--- @class soundentry
--- @field soundentry.DefaultVolume number The default volume of this game sound. If the sound entry has a volume range then the maximum volume will be returned by this. Volume in the range from 1 to 0 or -1 on error
--Returns the filename of this sound. If the sound has multiple entries then the filename of the first entry will be returned.
--- @function soundentry:getFilename(): string
--- @return string # filename or empty string on error
function soundentry:getFilename()end

--Returns the length of the sound in seconds. If the sound has multiple entries or a pitch range then the maximum duration of the sound will be returned.
--- @function soundentry:getDuration(): number
--- @return number # the length, or -1 on error
function soundentry:getDuration()end

--Computes the volume and the panning of the sound when it would be played from the specified position.<br>If range is given then the volume will diminish when the listener is within that distance to the source.<br>The position of the listener is always the the current viewing position.
--- @function soundentry:get3DValues(Position: vector, radius: number): number, number
--- @param Position vector 
--- @param radius number? 
--- @return number, number # The volume and the panning, in that sequence, or both -1 on error
function soundentry:get3DValues(Position, radius)end

--Detects whether handle is valid
--- @function soundentry:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function soundentry:isValid()end

--Detects whether handle references a sound that can be loaded
--- @function soundentry:tryLoad(): boolean
--- @return boolean # true if a load succeeded, false if not, nil if a syntax/type error occurs
function soundentry:tryLoad()end

-- soundfile object: Handle to a sound file
soundfile = {}
--- @class soundfile
--- @field soundfile.Duration number The duration of the sound file, in seconds The duration or -1 on error
--- @field soundfile.Filename string The filename of the file The file name or empty string on error
--Plays the sound. If voice is true then uses the Voice channel volume, else uses the Effects channel volume.
--- @function soundfile:play(volume: number, panning: number, voice: boolean): sound
--- @param volume number? 
--- @param panning number? 
--- @param voice boolean? 
--- @return sound # A sound handle or invalid handle on error
function soundfile:play(volume, panning, voice)end

--Unloads the audio data loaded for this sound file. This invalidates the handle on which this is called!
--- @function soundfile:unload(): boolean
--- @return boolean # true if successful, false otherwise
function soundfile:unload()end

--Checks if the soundfile handle is valid
--- @function soundfile:isValid(): boolean
--- @return boolean # true if valid, false otherwise
function soundfile:isValid()end

-- species object: Species handle
species = {}
--- @class species
--- @field species.Name string Species name Species name, or empty string if handle is invalid
--Detects whether handle is valid
--- @function species:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function species:isValid()end

-- streaminganim object: Streaming Animation handle
streaminganim = {}
--- @class streaminganim
--- @field streaminganim.Loop boolean Make the streaming animation loop. Is the animation looping, or nil if anim invalid
--- @field streaminganim.Pause boolean Pause the streaming animation. Is the animation paused, or nil if anim invalid
--- @field streaminganim.Reverse boolean Make the streaming animation play in reverse. Is the animation playing in reverse, or nil if anim invalid
--- @field streaminganim.Grayscale boolean Whether the streaming animation is drawn as grayscale multiplied by the current color (the HUD method). Boolean flag
--Get the filename of the animation
--- @function streaminganim:getFilename(): string
--- @return string # Filename or nil if invalid
function streaminganim:getFilename()end

--Get the number of frames in the animation.
--- @function streaminganim:getFrameCount(): number
--- @return number # Total number of frames
function streaminganim:getFrameCount()end

--Get the current frame index of the animation
--- @function streaminganim:getFrameIndex(): number
--- @return number # Current frame index
function streaminganim:getFrameIndex()end

--Get the height of the animation in pixels
--- @function streaminganim:getHeight(): number
--- @return number # Height or nil if invalid
function streaminganim:getHeight()end

--Get the width of the animation in pixels
--- @function streaminganim:getWidth(): number
--- @return number # Width or nil if invalid
function streaminganim:getWidth()end

--Detects whether handle is valid
--- @function streaminganim:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function streaminganim:isValid()end

--Load all apng animations into memory, enabling apng frame cache if not already enabled
--- @function streaminganim:preload(): boolean
--- @return boolean # true if preload was successful, nil if a syntax/type error occurs
function streaminganim:preload()end

--Processes a streaming animation, including selecting the correct frame & drawing it.
--- @function streaminganim:process(x1: number, y1: number, x2: number, y2: number, u0: number, v0: number, u1: number, v1: number, alpha: number, draw: boolean): boolean
--- @param x1 number? 
--- @param y1 number? 
--- @param x2 number? 
--- @param y2 number? 
--- @param u0 number? 
--- @param v0 number? 
--- @param u1 number? 
--- @param v1 number? 
--- @param alpha number? 
--- @param draw boolean? 
--- @return boolean # True if processing was successful, otherwise nil
function streaminganim:process(x1, y1, x2, y2, u0, v0, u1, v1, alpha, draw)end

--Reset a streaming animation back to its 1st frame
--- @function streaminganim:reset(): boolean
--- @return boolean # True if successful, otherwise nil
function streaminganim:reset()end

--Get the amount of time left in the animation, in seconds
--- @function streaminganim:timeLeft(): number
--- @return number # Time left in secs or nil if invalid
function streaminganim:timeLeft()end

--Unloads a streaming animation from memory
--- @function streaminganim:unload(): nothing
--- @return nil
function streaminganim:unload()end

-- submodel object: Handle to a submodel
submodel = {}
--- @class submodel
--- @field submodel.Name string Gets the submodel's name The name or an empty string if invalid
--- @field submodel.Index number Gets the submodel's index The number (adjusted for lua) or -1 if invalid
--- @field submodel.Offset vector Gets the submodel's offset from its parent submodel The offset vector or a empty vector if invalid
--- @field submodel.Radius number Gets the submodel's radius The radius of the submodel or -1 if invalid
--- @field submodel.NoCollide boolean Whether the submodel and its children ignore collisions The flag, or error-false if invalid
--- @field submodel.NoCollideThisOnly boolean Whether the submodel itself ignores collisions The flag, or error-false if invalid
--Returns the number of vertices in the submodel's mesh
--- @function submodel:NumVertices(): number
--- @return number # The number of vertices, or 0 if the submodel was invalid
function submodel:NumVertices()end

--Gets the specified vertex, or a random one if no index specified
--- @function submodel:GetVertex(index: number): vector
--- @param index number? 
--- @return vector # The vertex position in the submodel's frame of reference, or nil if the submodel was invalid
function submodel:GetVertex(index)end

--Gets the model that this submodel belongs to
--- @function submodel:getModel(): model
--- @return model # A model, or an invalid model if the handle is not valid
function submodel:getModel()end

--Gets the first child submodel of this submodel
--- @function submodel:getFirstChild(): submodel
--- @return submodel # A submodel, or nil if there is no child, or an invalid submodel if the handle is not valid
function submodel:getFirstChild()end

--Gets the next sibling submodel of this submodel
--- @function submodel:getNextSibling(): submodel
--- @return submodel # A submodel, or nil if there are no remaining siblings, or an invalid submodel if the handle is not valid
function submodel:getNextSibling()end

--Gets the parent submodel of this submodel
--- @function submodel:getParent(): submodel
--- @return submodel # A submodel, or nil if there is no parent, or an invalid submodel if the handle is not valid
function submodel:getParent()end

--True if valid, false or nil if not
--- @function submodel:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function submodel:isValid()end

-- submodel_instance object: Submodel instance handle
submodel_instance = {}
--- @class submodel_instance
--- @field submodel_instance.Orientation orientation Gets or sets the submodel instance orientation Orientation, or identity orientation if handle is not valid
--- @field submodel_instance.TranslationOffset vector Gets or sets the translated submodel instance offset.  This is relative to the existing submodel offset to its parent; a non-translated submodel will have a TranslationOffset of zero. Offset, or zero vector if handle is not valid
--Gets the model instance of this submodel
--- @function submodel_instance:getModelInstance(): model_instance
--- @return model_instance # A model instancve
function submodel_instance:getModelInstance()end

--Gets the submodel of this instance
--- @function submodel_instance:getSubmodel(): submodel
--- @return submodel # A submodel
function submodel_instance:getSubmodel()end

--Calculates the world coordinates of a point in a submodel's frame of reference
--- @function submodel_instance:findWorldPoint(param1: vector): vector
--- @param param1 vector 
--- @return vector # Point, or empty vector if handle is not valid
function submodel_instance:findWorldPoint(param1)end

--Calculates the world direction of a vector in a submodel's frame of reference
--- @function submodel_instance:findWorldDir(param1: vector): vector
--- @param param1 vector 
--- @return vector # Vector, or empty vector if handle is not valid
function submodel_instance:findWorldDir(param1)end

--Calculates the coordinates and orientation, in an object's frame of reference, of a point and orientation in a submodel's frame of reference
--- @function submodel_instance:findObjectPointAndOrientation(param1: vector, param2: orientation): vector, orientation
--- @param param1 vector 
--- @param param2 orientation 
--- @return vector, orientation # Vector and orientation, or empty values if a handle is invalid
function submodel_instance:findObjectPointAndOrientation(param1, param2)end

--Calculates the world coordinates and orientation of a point and orientation in a submodel's frame of reference
--- @function submodel_instance:findWorldPointAndOrientation(param1: vector, param2: orientation): vector, orientation
--- @param param1 vector 
--- @param param2 orientation 
--- @return vector, orientation # Vector and orientation, or empty values if a handle is invalid
function submodel_instance:findWorldPointAndOrientation(param1, param2)end

--Calculates the coordinates and orientation in the submodel's frame of reference, of a point and orientation in world coordinates [world = true] / in the object's frame of reference [world = false]
--- @function submodel_instance:findLocalPointAndOrientation(param1: vector, param2: orientation, world: boolean): vector, orientation
--- @param param1 vector 
--- @param param2 orientation 
--- @param world boolean? 
--- @return vector, orientation # Vector and orientation, or empty values if a handle is invalid
function submodel_instance:findLocalPointAndOrientation(param1, param2, world)end

--True if valid, false or nil if not
--- @function submodel_instance:isValid(): boolean
--- @return boolean # Detects whether handle is valid
function submodel_instance:isValid()end

-- submodel_instances object: Array of submodel instances
submodel_instances = {}
--- @class submodel_instances
--Number of submodel instances on model
--- @function submodel_instances:__len(): number
--- @return number # Number of model submodel instances
function submodel_instances:__len()end

--number|string IndexOrName
--- @function submodel_instances:__indexer(param1: submodel_instance): submodel_instance
--- @param param1 submodel_instance 
--- @return submodel_instance # Model submodel instances, or invalid modelsubmodelinstances handle if model instance handle is invalid
function submodel_instances:__indexer(param1)end

--Detects whether handle is valid
--- @function submodel_instances:isValid(): boolean
--- @return boolean # true if valid, false if invalid, nil if a syntax/type error occurs
function submodel_instances:isValid()end

-- submodels object: Array of submodels
submodels = {}
--- @class submodels
--Number of submodels on model
--- @function submodels:__len(): number
--- @return number # Number of model submodels
function submodels:__len()end

--number|string IndexOrName
--- @function submodels:__indexer(param1: submodel): submodel
--- @param param1 submodel 
--- @return submodel # Model submodels, or invalid modelsubmodels handle if model handle is invalid
function submodels:__indexer(param1)end

--Detects whether handle is valid
--- @function submodels:isValid(): boolean
--- @return boolean # true if valid, false if invalid, nil if a syntax/type error occurs
function submodels:isValid()end

-- subsystem object: Ship subsystem handle
subsystem = {}
--- @class subsystem
--- @field subsystem.ArmorClass string Current Armor class Armor class name, or empty string if none is set
--- @field subsystem.AWACSIntensity number Subsystem AWACS intensity AWACS intensity, or 0 if handle is invalid
--- @field subsystem.AWACSRadius number Subsystem AWACS radius AWACS radius, or 0 if handle is invalid
--- @field subsystem.Orientation orientation Orientation of subobject or turret base Subsystem orientation, or identity orientation if handle is invalid
--- @field subsystem.GunOrientation orientation Orientation of turret gun Gun orientation, or null orientation if handle is invalid
--- @field subsystem.TranslationOffset vector Gets or sets the translated submodel instance offset of the subsystem or turret base.  This is relative to the existing submodel offset to its parent; a non-translated submodel will have a TranslationOffset of zero. Offset, or zero vector if handle is not valid
--- @field subsystem.HitpointsLeft number Subsystem hitpoints left Hitpoints left, or 0 if handle is invalid. Setting a value of 0 will disable it - set a value of -1 or lower to actually blow it up.
--- @field subsystem.HitpointsMax number Subsystem hitpoints max Max hitpoints, or 0 if handle is invalid
--- @field subsystem.Position vector Subsystem position with regards to main ship (Local Vector) Subsystem position, or null vector if subsystem handle is invalid
--- @field subsystem.WorldPosition vector Subsystem position in world space. This handles subsystem attached to a rotating submodel properly. Subsystem position, or null vector if subsystem handle is invalid
--- @field subsystem.GunPosition vector Subsystem gun position with regards to main ship (Local vector) Gun position, or null vector if subsystem handle is invalid
--- @field subsystem.Name string Subsystem name Subsystem name, or an empty string if handle is invalid
--- @field subsystem.NameOnHUD string Subsystem name as it would be displayed on the HUD Subsystem name on HUD, or an empty string if handle is invalid
--- @field subsystem.NumFirePoints number Number of firepoints Number of fire points, or 0 if handle is invalid
--- @field subsystem.FireRateMultiplier number Factor by which turret's rate of fire is multiplied.  This can also be set with the turret-set-rate-of-fire SEXP.  As with the SEXP, assigning a negative value will cause this to be reset to default. Firing rate multiplier, or 0 if handle is invalid
--- @field subsystem.PrimaryBanks weaponbanktype Array of primary weapon banks Primary banks, or invalid weaponbanktype handle if subsystem handle is invalid
--- @field subsystem.SecondaryBanks weaponbanktype Array of secondary weapon banks Secondary banks, or invalid weaponbanktype handle if subsystem handle is invalid
--- @field subsystem.Target object Object targeted by this subsystem. If used to set a new target or clear it, AI targeting will be switched off. Targeted object, or invalid object handle if subsystem handle is invalid
--- @field subsystem.TurretResets boolean Specifies whether this turrets resets after a certain time of inactivity true if turret resets, false otherwise
--- @field subsystem.TurretResetDelay number The time (in milliseconds) after that the turret resets itself Reset delay
--- @field subsystem.TurnRate number The turn rate Turnrate or -1 on error
--- @field subsystem.Targetable boolean Targetability of this subsystem true if targetable, false otherwise or on error
--- @field subsystem.Radius number The radius of this subsystem The radius or 0 on error
--- @field subsystem.TurretLocked boolean Whether the turret is locked. Setting to true locks the turret; setting to false frees it. True if turret is locked, false otherwise
--- @field subsystem.TurretLockedWithTimestamp boolean Behaves like TurretLocked, but when the turret is freed, there will be a short random delay (between 50 and 4000 milliseconds) before firing, to be consistent with SEXP behavior. True if turret is locked, false otherwise
--- @field subsystem.BeamFree boolean Whether the turret is beam-freed. Setting to true beam-frees the turret; setting to false beam-locks it. True if turret is beam-freed, false otherwise
--- @field subsystem.BeamFreeWithTimestamp boolean Behaves like BeamFree, but when the turret is freed, there will be a short random delay (between 50 and 4000 milliseconds) before firing, to be consistent with SEXP behavior. True if turret is beam-freed, false otherwise
--- @field subsystem.NextFireTimestamp number The next time the turret may attempt to fire Mission time (seconds) or -1 on error
--- @field subsystem.ModelPath modelpath The model path points belonging to this subsystem The model path of this subsystem
--Returns name of subsystem
--- @function subsystem:__tostring(): string
--- @return string # Subsystem name, or empty string if handle is invalid
function subsystem:__tostring()end

--Returns the original name of the subsystem in the model file
--- @function subsystem:getModelName(): string
--- @return string # name or empty string on error
function subsystem:getModelName()end

--If set to true, AI targeting for this turret is switched off. If set to false, the AI will take over again.
--- @function subsystem:targetingOverride(param1: boolean): boolean
--- @param param1 boolean 
--- @return boolean # Returns true if successful, false otherwise
function subsystem:targetingOverride(param1)end

--Checks whether one or more <a href="https://wiki.hard-light.net/index.php/Subsystem#.24Flags:">model subsystem flags</a> are set - this function can accept an arbitrary number of flag arguments.  The flag names can be any string that the alter-ship-flag SEXP operator supports.
--- @function subsystem:getModelFlag(flag_name: string): boolean
--- @param flag_name string 
--- @return boolean # Returns whether all flags are set, or nil if the subsystem is not valid
function subsystem:getModelFlag(flag_name)end

--Determine if a subsystem has fired
--- @function subsystem:hasFired(): boolean
--- @return boolean # true if if fired, false if not fired, or nil if invalid. resets fired flag when called.
function subsystem:hasFired()end

--Determines if this subsystem is a turret
--- @function subsystem:isTurret(): boolean
--- @return boolean # true if subsystem is turret, false otherwise or nil on error
function subsystem:isTurret()end

--Determines if this subsystem is a multi-part turret
--- @function subsystem:isMultipartTurret(): boolean
--- @return boolean # true if subsystem is multi-part turret, false otherwise or nil on error
function subsystem:isMultipartTurret()end

--Determines if the object is in the turrets FOV
--- @function subsystem:isTargetInFOV(Target: object): boolean
--- @param Target object 
--- @return boolean # true if in FOV, false if not, nil on error or if subsystem is not a turret 
function subsystem:isTargetInFOV(Target)end

--Determines if a position is in the turrets FOV
--- @function subsystem:isPositionInFOV(Target: vector): boolean
--- @param Target vector 
--- @return boolean # true if in FOV, false if not, nil on error or if subsystem is not a turret 
function subsystem:isPositionInFOV(Target)end

--Fires weapon on turret
--- @function subsystem:fireWeapon(TurretWeaponIndex: number, FlakRange: number, OverrideFiringVec: vector): nothing
--- @param TurretWeaponIndex number? 
--- @param FlakRange number? 
--- @param OverrideFiringVec vector? 
--- @return nil
function subsystem:fireWeapon(TurretWeaponIndex, FlakRange, OverrideFiringVec)end

--Rotates the turret to face Pos or resets the turret to its original state
--- @function subsystem:rotateTurret(Pos: vector, reset: boolean): boolean
--- @param Pos vector 
--- @param reset boolean? 
--- @return boolean # true on success false otherwise
function subsystem:rotateTurret(Pos, reset)end

--Returns the turrets forward vector
--- @function subsystem:getTurretHeading(): vector
--- @return vector # Returns a normalized version of the forward vector in the ship's reference frame or null vector on error
function subsystem:getTurretHeading()end

--Returns current turrets FOVs
--- @function subsystem:getFOVs(): number, number, number
--- @return number, number, number # Standard FOV, maximum barrel elevation, turret base fov.
function subsystem:getFOVs()end

--Retrieves the next position and firing normal this turret will fire from. This function returns a world position
--- @function subsystem:getNextFiringPosition(): vector, vector
--- @return vector, vector # vector or null vector on error
function subsystem:getNextFiringPosition()end

--Returns current subsystems turret matrix
--- @function subsystem:getTurretMatrix(): orientation
--- @return orientation # Turret matrix.
function subsystem:getTurretMatrix()end

--The object parent of this subsystem, is of type ship
--- @function subsystem:getParent(): object
--- @return object # object handle or invalid handle on error
function subsystem:getParent()end

--Checks if the subsystem is in view from the specified position. This only checks for occlusion by the parent object, not by other objects in the mission.
--- @function subsystem:isInViewFrom(from: vector): boolean
--- @param from vector 
--- @return boolean # true if in view, false otherwise
function subsystem:isInViewFrom(from)end

--Detects whether handle is valid
--- @function subsystem:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function subsystem:isValid()end

-- team object: Team handle
team = {}
--- @class team
--- @field team.Name string Team name Team name, or empty string if handle is invalid
--Checks whether two teams are the same team
--- @function team:__eq(param1: team, param2: team): boolean
--- @param param1 team 
--- @param param2 team 
--- @return boolean # true if equal, false otherwise
function team:__eq(param1, param2)end

--Gets the IFF color of the specified Team. False to return raw rgb, true to return color object. Defaults to false.
--- @function team:getColor(ReturnType: boolean): number, number, number, number, color
--- @param ReturnType boolean 
--- @return number, number, number, number, color # rgb color for the specified team or nil if invalid
function team:getColor(ReturnType)end

--Detects whether handle is valid
--- @function team:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function team:isValid()end

--Gets the FreeSpace type name
--- @function team:getBreedName(): string
--- @return string # 'Team', or empty string if handle is invalid
function team:getBreedName()end

--Checks the IFF status of another team
--- @function team:attacks(param1: team): boolean
--- @param param1 team 
--- @return boolean # True if this team attacks the specified team
function team:attacks(param1)end

-- texture object: Texture handle
texture = {}
--- @class texture
--Checks if two texture handles refer to the same texture
--- @function texture:__eq(param1: texture, param2: texture): boolean
--- @param param1 texture 
--- @param param2 texture 
--- @return boolean # True if textures are equal
function texture:__eq(param1, param2)end

--Returns texture handle to specified frame number in current texture's animation.This means that [1] will always return the first frame in an animation, no matter what frame an animation is.You cannot change a texture animation frame.
--- @function texture:__indexer(param1: number): texture
--- @param param1 number 
--- @return texture # Texture handle, or invalid texture handle if index is invalid
function texture:__indexer(param1)end

--Detects whether handle is valid
--- @function texture:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function texture:isValid()end

--Unloads a texture from memory
--- @function texture:unload(): nothing
--- @return nil
function texture:unload()end

--Destroys a texture's render target. Call this when done drawing to a texture, as it frees up resources.
--- @function texture:destroyRenderTarget(): nothing
--- @return nil
function texture:destroyRenderTarget()end

--Returns filename for texture
--- @function texture:getFilename(): string
--- @return string # Filename, or empty string if handle is invalid
function texture:getFilename()end

--Gets texture width
--- @function texture:getWidth(): number
--- @return number # Texture width, or 0 if handle is invalid
function texture:getWidth()end

--Gets texture height
--- @function texture:getHeight(): number
--- @return number # Texture height, or 0 if handle is invalid
function texture:getHeight()end

--Gets frames-per-second of texture
--- @function texture:getFPS(): number
--- @return number # Texture FPS, or 0 if handle is invalid
function texture:getFPS()end

--Gets number of frames left, from handle's position in animation
--- @function texture:getFramesLeft(): number
--- @return number # Frames left, or 0 if handle is invalid
function texture:getFramesLeft()end

--Get the frame number from the elapsed time of the animation<br>The 1st argument is the time that has elapsed since the animation started<br>If 2nd argument is set to true, the animation is expected to loop when the elapsed time exceeds the duration of a single playback
--- @function texture:getFrame(ElapsedTimeSeconds: number, Loop: boolean): number
--- @param ElapsedTimeSeconds number 
--- @param Loop boolean? 
--- @return number # Frame number
function texture:getFrame(ElapsedTimeSeconds, Loop)end

-- textures object: Array of textures
textures = {}
--- @class textures
--Number of textures on model
--- @function textures:__len(): number
--- @return number # Number of model textures
function textures:__len()end

--number Index/string TextureName
--- @function textures:__indexer(param1: texture): texture
--- @param param1 texture 
--- @return texture # Model textures, or invalid modeltextures handle if model handle is invalid
function textures:__indexer(param1)end

--Detects whether handle is valid
--- @function textures:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function textures:isValid()end

-- thrusterbank object: A model thrusterbank
thrusterbank = {}
--- @class thrusterbank
--Number of thrusters on this thrusterbank
--- @function thrusterbank:__len(): number
--- @return number # Number of thrusters on this bank or 0 if handle is invalid
function thrusterbank:__len()end

--Array of glowpoint
--- @function thrusterbank:__indexer(Index: number): glowpoint
--- @param Index number 
--- @return glowpoint # Glowpoint, or invalid glowpoint handle on failure
function thrusterbank:__indexer(Index)end

--Detects if this handle is valid
--- @function thrusterbank:isValid(): boolean
--- @return boolean # true if this handle is valid, false otherwise
function thrusterbank:isValid()end

-- thrusters object: The thrusters of a model
thrusters = {}
--- @class thrusters
--Number of thruster banks on the model
--- @function thrusters:__len(): number
--- @return number # Number of thrusterbanks
function thrusters:__len()end

--Array of all thrusterbanks on this thruster
--- @function thrusters:__indexer(Index: number): thrusterbank
--- @param Index number 
--- @return thrusterbank # Handle to the thrusterbank or invalid handle if index is invalid
function thrusters:__indexer(Index)end

--Detects whether handle is valid
--- @function thrusters:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function thrusters:isValid()end

-- timespan object: A difference between two time stamps
timespan = {}
--- @class timespan
--Gets the value of this timestamp in seconds
--- @function timespan:getSeconds(): number
--- @return number # The timespan value in seconds
function timespan:getSeconds()end

-- timestamp object: A real time time stamp of unspecified precision and resolution.
timestamp = {}
--- @class timestamp
--Computes the difference between two timestamps
--- @function timestamp:__sub(other: timestamp): timespan
--- @param other timestamp 
--- @return timespan # The time difference
function timestamp:__sub(other)end

-- tracing_category object: A category for tracing engine performance
tracing_category = {}
--- @class tracing_category
--Traces the run time of the specified function that will be invoked in this call.
--- @function tracing_category:trace(body: function()): nothing
--- @param body function() 
--- @return nil
function tracing_category:trace(body)end

-- ValueDescription object: An option value that contains a displayable string and the serialized value.
ValueDescription = {}
--- @class ValueDescription
--- @field ValueDescription.Display string Value display string The display string or nil on error
--- @field ValueDescription.Serialized string Serialized string value of the contained value The serialized string or nil on error
--Value display string
--- @function ValueDescription:__tostring(): string
--- @return string # The display string or nil on error
function ValueDescription:__tostring()end

--Compares two value descriptions
--- @function ValueDescription:__eq(other: ValueDescription): string
--- @param other ValueDescription 
--- @return string # True if equal, false otherwise
function ValueDescription:__eq(other)end

-- vector object: Vector object
vector = {}
--- @class vector
--Vector component
--- @function vector:__indexer(axis: string): number
--- @param axis string x,y,z
--- @return number # Value at index, or 0 if vector handle is invalid
function vector:__indexer(axis)end--- @function vector:__indexer(element: number): number
--- @param element number 1-3
--- @return number # Value at index, or 0 if vector handle is invalid
function vector:__indexer(element)end

--Adds vector by another vector, or adds all axes by value
--- @function vector:__add(param1: number | vector): vector
--- @param param1 number | vector 
--- @return vector # Final vector, or null vector if error occurs
function vector:__add(param1)end

--Subtracts vector from another vector, or subtracts all axes by value
--- @function vector:__sub(param1: number | vector): vector
--- @param param1 number | vector 
--- @return vector # Final vector, or null vector if error occurs
function vector:__sub(param1)end

--Scales vector object (Multiplies all axes by number), or multiplies each axes by the other vector's axes.
--- @function vector:__mul(param1: number | vector): vector
--- @param param1 number | vector 
--- @return vector # Final vector, or null vector if error occurs
function vector:__mul(param1)end

--Scales vector object (Divide all axes by number), or divides each axes by the dividing vector's axes.
--- @function vector:__div(param1: number | vector): vector
--- @param param1 number | vector 
--- @return vector # Final vector, or null vector if error occurs
function vector:__div(param1)end

--Converts a vector to string with format "(x,y,z)"
--- @function vector:__tostring(): string
--- @return string # Vector as string, or empty string if handle is invalid
function vector:__tostring()end

--Returns a copy of the vector
--- @function vector:copy(): vector
--- @return vector # The copy, or null vector on failure
function vector:copy()end

--Returns vector that has been interpolated to Final by Factor (0.0-1.0)
--- @function vector:getInterpolated(Final: vector, Factor: number): vector
--- @param Final vector 
--- @param Factor number 
--- @return vector # Interpolated vector, or null vector on failure
function vector:getInterpolated(Final, Factor)end

--Interpolates between this (initial) vector and a second one, using t as the multiplier of progress between them, rotating around their cross product vector.  Intended values for t are [0.0f, 1.0f], but values outside this range are allowed.
--- @function vector:rotationalInterpolate(final: vector, t: number): vector
--- @param final vector 
--- @param t number 
--- @return vector # The interpolated vector, or NIL if any handle is invalid
function vector:rotationalInterpolate(final, t)end

--Returns orientation object representing the direction of the vector. Does not require vector to be normalized.  Note: the orientation is constructed with the vector as the forward vector (fvec).  You can also specify up (uvec) and right (rvec) vectors as optional arguments.
--- @function vector:getOrientation(): orientation
--- @return orientation # Orientation object, or null orientation object if handle is invalid
function vector:getOrientation()end

--Returns the magnitude of a vector (Total regardless of direction)
--- @function vector:getMagnitude(): number
--- @return number # Magnitude of vector, or 0 if handle is invalid
function vector:getMagnitude()end

--Distance
--- @function vector:getDistance(otherPos: vector): number
--- @param otherPos vector 
--- @return number # Returns distance from another vector
function vector:getDistance(otherPos)end

--Distance squared
--- @function vector:getDistanceSquared(otherPos: vector): number
--- @param otherPos vector 
--- @return number # Returns distance squared from another vector
function vector:getDistanceSquared(otherPos)end

--Returns dot product of vector object with vector argument
--- @function vector:getDotProduct(OtherVector: vector): number
--- @param OtherVector vector 
--- @return number # Dot product, or 0 if a handle is invalid
function vector:getDotProduct(OtherVector)end

--Returns cross product of vector object with vector argument
--- @function vector:getCrossProduct(OtherVector: vector): vector
--- @param OtherVector vector 
--- @return vector # Cross product, or null vector if a handle is invalid
function vector:getCrossProduct(OtherVector)end

--Gets screen cordinates of a world vector
--- @function vector:getScreenCoords(): number, number
--- @return number, number # X (number), Y (number), or false if off-screen
function vector:getScreenCoords()end

--Returns a normalized version of the vector
--- @function vector:getNormalized(): vector
--- @return vector # Normalized Vector, or NIL if invalid
function vector:getNormalized()end

--Returns a projection of the vector along a unit vector.  The unit vector MUST be normalized.
--- @function vector:projectParallel(unitVector: vector): vector
--- @param unitVector vector 
--- @return vector # The projected vector, or NIL if a handle is invalid
function vector:projectParallel(unitVector)end

--Returns a projection of the vector onto a plane defined by a surface normal.  The surface normal MUST be normalized.
--- @function vector:projectOntoPlane(surfaceNormal: vector): vector
--- @param surfaceNormal vector 
--- @return vector # The projected vector, or NIL if a handle is invalid
function vector:projectOntoPlane(surfaceNormal)end

--Finds the point on the line defined by point1 and point2 that is closest to this point.  (The line is assumed to extend infinitely in both directions; the closest point will not necessarily be between the two points.)
--- @function vector:findNearestPointOnLine(point1: vector, point2: vector): vector, number
--- @param point1 vector 
--- @param point2 vector 
--- @return vector, number # Returns two arguments.  The first is the nearest point, and the second is a value indicating where on the line the point lies.  From the code: '0.0 means nearest_point is p1; 1.0 means it's p2; 2.0 means it's beyond p2 by 2x; -1.0 means it's "before" p1 by 1x'.
function vector:findNearestPointOnLine(point1, point2)end

--Create a new normalized vector, randomly perturbed around a given (normalized) vector.  Angles are in degrees.  If only one angle is specified, it is the max angle.  If both are specified, the first is the minimum and the second is the maximum.
--- @function vector:perturb(angle1: number, angle2: number): vector
--- @param angle1 number 
--- @param angle2 number? 
--- @return vector # A vector, somewhat perturbed from the experience
function vector:perturb(angle1, angle2)end

--Given this vector (the origin point), an orientation, and a radius, generate a point on the plane of the circle.  If on_edge is true, the point will be on the edge of the circle. If bias_towards_center is true, the probability will be higher towards the center.
--- @function vector:randomInCircle(orient: orientation, radius: number, on_edge: boolean, bias_towards_center: boolean): vector
--- @param orient orientation 
--- @param radius number 
--- @param on_edge boolean 
--- @param bias_towards_center boolean? 
--- @return vector # A point within the plane of the circle
function vector:randomInCircle(orient, radius, on_edge, bias_towards_center)end

--Given this vector (the origin point) and a radius, generate a point in the volume of the sphere.  If on_surface is true, the point will be on the surface of the sphere. If bias_towards_center is true, the probability will be higher towards the center
--- @function vector:randomInSphere(radius: number, on_surface: boolean, bias_towards_center: boolean): vector
--- @param radius number 
--- @param on_surface boolean 
--- @param bias_towards_center boolean? 
--- @return vector # A point within the plane of the circle
function vector:randomInSphere(radius, on_surface, bias_towards_center)end

-- waypoint object: waypoint handle
waypoint = {}
--- @class waypoint
--Returns the waypoint list
--- @function waypoint:getList(): waypointlist
--- @return waypointlist # waypointlist handle or invalid handle if waypoint was invalid
function waypoint:getList()end

-- waypointlist object: waypointlist handle
waypointlist = {}
--- @class waypointlist
--- @field waypointlist.Name string Name of WaypointList Waypointlist name, or empty string if handle is invalid
--Array of waypoints that are part of the waypoint list
--- @function waypointlist:__indexer(Index: number): waypoint
--- @param Index number 
--- @return waypoint # Waypoint, or invalid handle if the index or waypointlist handle is invalid
function waypointlist:__indexer(Index)end

--Number of waypoints in the list. Note that the value returned cannot be relied on for more than one frame.
--- @function waypointlist:__len(): number
--- @return number # Number of waypoints in the list, or 0 if handle is invalid
function waypointlist:__len()end

--Return if this waypointlist handle is valid
--- @function waypointlist:isValid(): boolean
--- @return boolean # true if valid false otherwise
function waypointlist:isValid()end

-- weapon object: Weapon handle
weapon = {}
--- @class weapon
--- @field weapon.Class weaponclass Weapon's class Weapon class, or invalid weaponclass handle if weapon handle is invalid
--- @field weapon.DestroyedByWeapon boolean Whether weapon was destroyed by another weapon True if weapon was destroyed by another weapon, false if weapon was destroyed by another object or if weapon handle is invalid
--- @field weapon.LifeLeft number Weapon life left (in seconds) Life left (seconds) or 0 if weapon handle is invalid
--- @field weapon.FlakDetonationRange number Range at which flak will detonate (meters) Detonation range (meters) or 0 if weapon handle is invalid
--- @field weapon.Target object Target of weapon. Value may also be a deriviative of the 'object' class, such as 'ship'. Weapon target, or invalid object handle if weapon handle is invalid
--- @field weapon.ParentTurret subsystem Turret which fired this weapon. Turret subsystem handle, or an invalid handle if the weapon not fired from a turret
--- @field weapon.HomingObject object Object that weapon will home in on. Value may also be a deriviative of the 'object' class, such as 'ship' Object that weapon is homing in on, or an invalid object handle if weapon is not homing or the weapon handle is invalid
--- @field weapon.HomingPosition vector Position that weapon will home in on (World vector), setting this without a homing object in place will not have any effect! Homing point, or null vector if weapon handle is invalid
--- @field weapon.HomingSubsystem subsystem Subsystem that weapon will home in on. Homing subsystem, or invalid subsystem handle if weapon is not homing or weapon handle is invalid
--- @field weapon.Team team Weapon's team Weapon team, or invalid team handle if weapon handle is invalid
--- @field weapon.OverrideHoming boolean Whether homing is overridden for this weapon. When homing is overridden then the engine will not update the homing position of the weapon which means that it can be handled by scripting. true if homing is overridden
--Checks if the weapon is armed.
--- @function weapon:isArmed(HitTarget: boolean): boolean
--- @param HitTarget boolean? 
--- @return boolean # boolean value of the weapon arming status
function weapon:isArmed(HitTarget)end

--Returns the collision information for this weapon
--- @function weapon:getCollisionInformation(): collision_info
--- @return collision_info # The collision information or invalid handle if none
function weapon:getCollisionInformation()end

--Triggers an animation. Type is the string name of the animation type, triggeredBy is a closer specification which animation should trigger. See *-anim.tbm specifications. Forwards controls the direction of the animation. ResetOnStart will cause the animation to play from its initial state, as opposed to its current state. CompleteInstant will immediately complete the animation. Pause will instead stop the animation at the current state.
--- @function weapon:triggerSubmodelAnimation(type: string, triggeredBy: string, forwards: boolean, resetOnStart: boolean, completeInstant: boolean, pause: boolean): boolean
--- @param type string 
--- @param triggeredBy string 
--- @param forwards boolean? 
--- @param resetOnStart boolean? 
--- @param completeInstant boolean? 
--- @param pause boolean? 
--- @return boolean # True if successful, false or nil otherwise
function weapon:triggerSubmodelAnimation(type, triggeredBy, forwards, resetOnStart, completeInstant, pause)end

--Gets time that animation will be done
--- @function weapon:getSubmodelAnimationTime(type: string, triggeredBy: string): number
--- @param type string 
--- @param triggeredBy string 
--- @return number # Time (seconds), or 0 if weapon handle is invalid
function weapon:getSubmodelAnimationTime(type, triggeredBy)end

--Vanishes this weapon from the mission.
--- @function weapon:vanish(): boolean
--- @return boolean # True if the deletion was successful, false otherwise.
function weapon:vanish()end

-- weaponbank object: Ship/subystem weapons bank handle
weaponbank = {}
--- @class weaponbank
--- @field weaponbank.WeaponClass weaponclass Class of weapon mounted in the bank. As of FSO 21.0, also changes the maximum ammo to its proper value, which is what the support ship will rearm the ship to. Weapon class, or an invalid weaponclass handle if bank handle is invalid
--- @field weaponbank.AmmoLeft number Ammo left for the current bank Ammo left, or 0 if handle is invalid
--- @field weaponbank.AmmoMax number Maximum ammo for the current bank<br><b>Note:</b> Setting this value actually sets the <i>capacity</i> of the weapon bank. To set the actual maximum ammunition use <tt>AmmoMax = <amount> * class.CargoSize</tt> Ammo capacity, or 0 if handle is invalid
--- @field weaponbank.Armed boolean Weapon armed status. Does not take linking into account. True if armed, false if unarmed or handle is invalid
--- @field weaponbank.Capacity number The actual capacity of a weapon bank as specified in the table The capacity or -1 if handle is invalid
--- @field weaponbank.FOFCooldown number The FOF cooldown value. A value of 0 means the default weapon FOF is used. A value of 1 means that the max FOF will be used The cooldown value or -1 if invalid
--- @field weaponbank.BurstCounter number The burst counter for this bank. Starts at 1, counting every shot up to and including the weapon class's burst shots value before resetting to 1. The counter or -1 if handle is invalid
--- @field weaponbank.BurstSeed number A random seed associated to the current burst. Changes only when a new burst starts. The seed or -1 if handle is invalid
--Detects whether handle is valid
--- @function weaponbank:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function weaponbank:isValid()end

-- weaponbanktype object: Ship/subsystem weapons bank type handle
weaponbanktype = {}
--- @class weaponbanktype
--- @field weaponbanktype.Linked boolean Whether bank is in linked or unlinked fire mode (Primary-only) Link status, or false if handle is invalid
--- @field weaponbanktype.DualFire boolean Whether bank is in dual fire mode (Secondary-only) Dual fire status, or false if handle is invalid
--Array of weapon banks
--- @function weaponbanktype:__indexer(Index: number): weaponbank
--- @param Index number 
--- @return weaponbank # Weapon bank, or invalid handle on failure
function weaponbanktype:__indexer(Index)end

--Detects whether handle is valid
--- @function weaponbanktype:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function weaponbanktype:isValid()end

--Number of weapons in the mounted bank
--- @function weaponbanktype:__len(): number
--- @return number # Number of bank weapons, or 0 if handle is invalid
function weaponbanktype:__len()end

-- weaponclass object: Weapon class handle
weaponclass = {}
--- @class weaponclass
--- @field weaponclass.Name string Weapon class name. This is the possibly untranslated name. Use tostring(class) to get the string which should be shown to the user. Weapon class name, or empty string if handle is invalid
--- @field weaponclass.AltName string The alternate weapon class name. Alternate weapon class name, or empty string if handle is invalid
--- @field weaponclass.TurretName string The name displayed for a turret if the turret's first weapon is this weapon class. Turret name (aka alternate subsystem name), or empty string if handle is invalid
--- @field weaponclass.Title string Weapon class title Weapon class title, or empty string if handle is invalid
--- @field weaponclass.Description string Weapon class description string Description string, or empty string if handle is invalid
--- @field weaponclass.TechTitle string Weapon class tech title Tech title, or empty string if handle is invalid
--- @field weaponclass.TechAnimationFilename string Weapon class animation filename Filename, or empty string if handle is invalid
--- @field weaponclass.SelectIconFilename string Weapon class select icon filename Filename, or empty string if handle is invalid
--- @field weaponclass.SelectAnimFilename string Weapon class select animation filename Filename, or empty string if handle is invalid
--- @field weaponclass.TechDescription string Weapon class tech description string Description string, or empty string if handle is invalid
--- @field weaponclass.Model model Model Weapon class model, or invalid model handle if weaponclass handle is invalid
--- @field weaponclass.ArmorFactor number Amount of weapon damage applied to ship hull (0-1.0) Armor factor, or empty string if handle is invalid
--- @field weaponclass.Damage number Amount of damage that weapon deals Damage amount, or 0 if handle is invalid
--- @field weaponclass.DamageType number No description available. Damage Type index, or 0 if handle is invalid. Index is index into armor.tbl
--- @field weaponclass.FireWait number Weapon fire wait (cooldown time) in seconds Fire wait time, or 0 if handle is invalid
--- @field weaponclass.FreeFlightTime number The time the weapon will fly before turing onto its target Free flight time or empty string if invalid
--- @field weaponclass.SwarmInfo boolean No description available. Returns whether the weapon has the swarm flag, or nil if the handle is invalid.
--- @field weaponclass.CorkscrewInfo boolean, number, number, number, boolean, number No description available. Returns whether the weapon has the corkscrew flag, or nil if the handle is invalid.
--- @field weaponclass.LifeMax number Life of weapon in seconds Life of weapon, or 0 if handle is invalid
--- @field weaponclass.Range number Range of weapon in meters Weapon Range, or 0 if handle is invalid
--- @field weaponclass.Mass number Weapon mass Weapon mass, or 0 if handle is invalid
--- @field weaponclass.ShieldFactor number Amount of weapon damage applied to ship shields (0-1.0) Shield damage factor, or 0 if handle is invalid
--- @field weaponclass.SubsystemFactor number Amount of weapon damage applied to ship subsystems (0-1.0) Subsystem damage factor, or 0 if handle is invalid
--- @field weaponclass.TargetLOD number LOD used for weapon model in the targeting computer LOD number, or 0 if handle is invalid
--- @field weaponclass.Speed number Weapon max speed, aka $Velocity in weapons.tbl Weapon speed, or 0 if handle is invalid
--- @field weaponclass.EnergyConsumed number No description available. Energy Consumed, or 0 if handle is invalid
--- @field weaponclass.ShockwaveDamage number Damage the shockwave is set to if damage is overridden Shockwave Damage if explicitly specified via table, or -1 if unspecified. Returns nil if handle is invalid
--- @field weaponclass.InnerRadius number Radius at which the full explosion damage is done. Marks the line where damage attenuation begins. Same as $Inner Radius in weapons.tbl Inner Radius, or 0 if handle is invalid
--- @field weaponclass.OuterRadius number Maximum Radius at which any damage is done with this weapon. Same as $Outer Radius in weapons.tbl Outer Radius, or 0 if handle is invalid
--- @field weaponclass.Bomb boolean Is weapon class flagged as bomb New flag
--- @field weaponclass.CustomData table Gets the custom data table for this weapon class The weapon class's custom data table
--- @field weaponclass.CustomStrings table Gets the indexed custom string table for this weapon. Each item in the table is a table with the following values: Name - the name of the custom string, Value - the value associated with the custom string, String - the custom string itself. The weapon's custom data table
--- @field weaponclass.InTechDatabase boolean Gets or sets whether this weapon class is visible in the tech room True or false
--- @field weaponclass.AllowedInCampaign boolean Gets or sets whether this weapon class is allowed in loadouts in campaign mode True or false
--- @field weaponclass.CargoSize number The cargo size of this weapon class The new cargo size or -1 on error
--- @field weaponclass.heatEffectiveness number The heat effectiveness of this weapon class if it's a countermeasure. Otherwise returns -1 The heat effectiveness or -1 on error
--- @field weaponclass.aspectEffectiveness number The aspect effectiveness of this weapon class if it's a countermeasure. Otherwise returns -1 The aspect effectiveness or -1 on error
--- @field weaponclass.effectiveRange number The effective range of this weapon class if it's a countermeasure. Otherwise returns -1 The effective range or -1 on error
--- @field weaponclass.pulseInterval number The pulse interval of this weapon class if it's a countermeasure. Otherwise returns -1 The pulse interval or -1 on error
--- @field weaponclass.BurstShots number The number of shots in a burst from this weapon. Burst shots, 1 for non-burst weapons, or 0 if handle is invalid
--- @field weaponclass.BurstDelay number The time in seconds between shots in a burst. Burst delay, or 0 if handle is invalid
--- @field weaponclass.FieldOfFire number The angular spread for shots of this weapon. Fof in degrees, or 0 if handle is invalid
--- @field weaponclass.MaxFieldOfFire number The maximum field of fire this weapon can have if it increases while firing. Max Fof in degrees, or 0 if handle is invalid
--- @field weaponclass.BeamLife number The time in seconds that a beam lasts while firing. Beam life, or 0 if handle is invalid or the weapon is not a beam
--- @field weaponclass.BeamWarmup number The time in seconds that a beam takes to warm up. Warmup time, or 0 if handle is invalid or the weapon is not a beam
--- @field weaponclass.BeamWarmdown number The time in seconds that a beam takes to warm down. Warmdown time, or 0 if handle is invalid or the weapon is not a beam
--Weapon class name
--- @function weaponclass:__tostring(): string
--- @return string # Weapon class name, or an empty string if handle is invalid
function weaponclass:__tostring()end

--Checks if the two classes are equal
--- @function weaponclass:__eq(param1: weaponclass, param2: weaponclass): boolean
--- @param param1 weaponclass 
--- @param param2 weaponclass 
--- @return boolean # true if equal, false otherwise
function weaponclass:__eq(param1, param2)end

--- @function weaponclass:getSwarmInfo(): boolean, number, number
--- @return boolean, number, number # Returns three values: a) whether the weapon has the swarm flag, b) the number of swarm missiles fired, c) the swarm wait. Returns nil if the handle is invalid.
function weaponclass:getSwarmInfo()end

--- @function weaponclass:getCorkscrewInfo(): boolean, number, number, number, boolean, number
--- @return boolean, number, number, number, boolean, number # Returns six values: a) whether the weapon has the corkscrew flag, b) the number of corkscrew missiles fired, c) the radius, d) the fire delay, e) whether the weapon counter-rotations, f) the twist value. Returns nil if the handle is invalid.
function weaponclass:getCorkscrewInfo()end

--Detects whether the weapon class has any custom data
--- @function weaponclass:hasCustomData(): boolean
--- @return boolean # true if the weaponclass's custom_data is not empty, false otherwise
function weaponclass:hasCustomData()end

--Detects whether the weapon has any custom strings
--- @function weaponclass:hasCustomStrings(): boolean
--- @return boolean # true if the weapon's custom_strings is not empty, false otherwise
function weaponclass:hasCustomStrings()end

--Detects whether handle is valid
--- @function weaponclass:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function weaponclass:isValid()end

--Draws weapon tech model. True for regular lighting, false for flat lighting.
--- @function weaponclass:renderTechModel(X1: number, Y1: number, X2: number, Y2: number, RotationPercent: number, PitchPercent: number, BankPercent: number, Zoom: number, Lighting: boolean): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param RotationPercent number? 
--- @param PitchPercent number? 
--- @param BankPercent number? 
--- @param Zoom number? 
--- @param Lighting boolean? 
--- @return boolean # Whether weapon was rendered
function weaponclass:renderTechModel(X1, Y1, X2, Y2, RotationPercent, PitchPercent, BankPercent, Zoom, Lighting)end

--Draws weapon tech model
--- @function weaponclass:renderTechModel2(X1: number, Y1: number, X2: number, Y2: number, Orientation: orientation, Zoom: number): boolean
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param Orientation orientation? 
--- @param Zoom number? 
--- @return boolean # Whether weapon was rendered
function weaponclass:renderTechModel2(X1, Y1, X2, Y2, Orientation, Zoom)end

--Draws the 3D select weapon model with the chosen effect at the specified coordinates. Restart should be true on the first frame this is called and false on subsequent frames. Note that primary weapons will not render anything if they do not have a valid pof model defined! Valid selection effects are 1 (fs1) or 2 (fs2), defaults to the mod setting or the model's setting. Zoom is a multiplier to the model's closeup_zoom value.
--- @function weaponclass:renderSelectModel(x: number, y: number, width: number, height: number, currentEffectSetting: number, zoom: number): boolean
--- @param x number 
--- @param y number 
--- @param width number? 
--- @param height number? 
--- @param currentEffectSetting number? 
--- @param zoom number? 
--- @return boolean # true if rendered, false if error
function weaponclass:renderSelectModel(x, y, width, height, currentEffectSetting, zoom)end

--Gets the index value of the weapon class
--- @function weaponclass:getWeaponClassIndex(): number
--- @return number # index value of the weapon class
function weaponclass:getWeaponClassIndex()end

--Return true if the weapon is a 'laser' weapon, which also includes ballistic (ammo-based) weapons.  This also includes most beams, but not necessarily all of them.  See also isPrimary().
--- @function weaponclass:isLaser(): boolean
--- @return boolean # true if the weapon is a laser weapon, false otherwise
function weaponclass:isLaser()end

--Return true if the weapon is a 'missile' weapon.  See also isSecondary().
--- @function weaponclass:isMissile(): boolean
--- @return boolean # true if the weapon is a missile weapon, false otherwise
function weaponclass:isMissile()end

--Return true if the weapon is a primary weapon.  This also includes most beams, but not necessarily all of them.  This function is equivalent to isLaser().
--- @function weaponclass:isPrimary(): boolean
--- @return boolean # true if the weapon is a primary, false otherwise
function weaponclass:isPrimary()end

--Return true if the weapon is a primary weapon that is not a beam.
--- @function weaponclass:isNonBeamPrimary(): boolean
--- @return boolean # true if the weapon is a non-beam primary, false otherwise
function weaponclass:isNonBeamPrimary()end

--Return true if the weapon is a secondary weapon.  This function is equivalent to isMissile().
--- @function weaponclass:isSecondary(): boolean
--- @return boolean # true if the weapon is a secondary, false otherwise
function weaponclass:isSecondary()end

--Return true if the weapon is a beam
--- @function weaponclass:isBeam(): boolean
--- @return boolean # true if the weapon is a beam, false otherwise
function weaponclass:isBeam()end

--Return true if the weapon is a countermeasure
--- @function weaponclass:isCountermeasure(): boolean
--- @return boolean # true if the weapon is a countermeasure, false otherwise
function weaponclass:isCountermeasure()end

--Checks if a weapon is required for the currently loaded mission
--- @function weaponclass:isWeaponRequired(): boolean
--- @return boolean # true if required, false if otherwise. Nil if the weapon class is invalid or a mission has not been loaded
function weaponclass:isWeaponRequired()end

--Detects whether the weapon has the player allowed flag
--- @function weaponclass:isPlayerAllowed(): boolean
--- @return boolean # true if player allowed, false otherwise, nil if a syntax/type error occurs
function weaponclass:isPlayerAllowed()end

--Return true if the weapon is paged in.
--- @function weaponclass:isWeaponUsed(): boolean
--- @return boolean # True if the weapon is paged in, false if otherwise
function weaponclass:isWeaponUsed()end

--Pages in a weapon. Returns True on success.
--- @function weaponclass:loadWeapon(): boolean
--- @return boolean # True if page in was successful, false otherwise.
function weaponclass:loadWeapon()end

-- wing object: Wing handle
wing = {}
--- @class wing
--- @field wing.Name string Name of Wing Wing name, or empty string if handle is invalid
--- @field wing.Formation wingformation Gets or sets the formation of the wing. Wing formation, or nil if wing is invalid
--- @field wing.FormationScale number Gets or sets the scale (i.e. distance multiplier) of the current wing formation. scale of wing formation, nil if wing or formation invalid
--- @field wing.CurrentCount number Gets the number of ships in the wing that are currently present Number of ships, or nil if invalid handle
--- @field wing.WaveCount number Gets the maximum number of ships in a wave for this wing Number of ships, or nil if invalid handle
--- @field wing.NumWaves number Gets the number of waves for this wing Number of waves, or nil if invalid handle
--- @field wing.CurrentWave number Gets the current wave number for this wing Wave number, 0 if the wing has not yet arrived, or nil if invalid handle
--- @field wing.TotalArrived number Gets the number of ships that have arrived over the course of the mission, regardless of wave Number of ships, or nil if invalid handle
--- @field wing.TotalDestroyed number Gets the number of ships that have been destroyed over the course of the mission, regardless of wave Number of ships, or nil if invalid handle
--- @field wing.TotalDeparted number Gets the number of ships that have departed over the course of the mission, regardless of wave Number of ships, or nil if invalid handle
--- @field wing.TotalVanished number Gets the number of ships that have vanished over the course of the mission, regardless of wave Number of ships, or 0 if invalid handle
--- @field wing.ArrivalLocation string The wing's arrival location Arrival location, or nil if handle is invalid
--- @field wing.DepartureLocation string The wing's departure location Departure location, or nil if handle is invalid
--- @field wing.ArrivalAnchor string The wing's arrival anchor Arrival anchor, or nil if handle is invalid
--- @field wing.DepartureAnchor string The wing's departure anchor Departure anchor, or nil if handle is invalid
--- @field wing.ArrivalPathMask number The wing's arrival path mask Arrival path mask, or nil if handle is invalid
--- @field wing.DeparturePathMask number The wing's departure path mask Departure path mask, or nil if handle is invalid
--- @field wing.ArrivalDelay number The wing's arrival delay Arrival delay, or nil if handle is invalid
--- @field wing.DepartureDelay number The wing's departure delay Departure delay, or nil if handle is invalid
--- @field wing.ArrivalDistance number The wing's arrival distance Arrival distance, or nil if handle is invalid
--- @field wing.WaveDelayMinimum number The wing's minimum wave delay Min wave delay, or nil if handle is invalid
--- @field wing.WaveDelayMaximum number The wing's maximum wave delay Max wave delay, or nil if handle is invalid
--Array of ships in the wing
--- @function wing:__indexer(Index: number): ship
--- @param Index number 
--- @return ship # Ship handle, or invalid ship handle if index is invalid or wing handle is invalid
function wing:__indexer(Index)end

--Gets the number of ships in the wing
--- @function wing:__len(): number
--- @return number # Number of ships in wing, or 0 if invalid handle
function wing:__len()end

--Detects whether handle is valid
--- @function wing:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function wing:isValid()end

--Gets the FreeSpace type name
--- @function wing:getBreedName(): string
--- @return string # 'Wing', or empty string if handle is invalid
function wing:getBreedName()end

--Sets or clears one or more flags - this function can accept an arbitrary number of flag arguments.  The flag names are currently limited to the arrival and departure parseable flags.
--- @function wing:setFlag(set_it: boolean, flag_name: string): nothing
--- @param set_it boolean 
--- @param flag_name string 
--- @return nil # Returns nothing
function wing:setFlag(set_it, flag_name)end

--Checks whether one or more flags are set - this function can accept an arbitrary number of flag arguments.  The flag names are currently limited to the arrival and departure parseable flags.
--- @function wing:getFlag(flag_name: string): boolean
--- @param flag_name string 
--- @return boolean # Returns whether all flags are set, or nil if the wing is not valid
function wing:getFlag(flag_name)end

--Causes this wing to arrive as if its arrival cue had become true.  Note that reinforcements are only marked as available, not actually created.
--- @function wing:makeWingArrive(): boolean
--- @return boolean # true if created, false otherwise
function wing:makeWingArrive()end

-- wingformation object: Wing formation handle
wingformation = {}
--- @class wingformation
--- @field wingformation.Name string Wing formation name Wing formation name, or empty string if handle is invalid
--Wing formation name
--- @function wingformation:__tostring(): string
--- @return string # Wing formation name, or an empty string if handle is invalid
function wingformation:__tostring()end

--Checks if the two formations are equal
--- @function wingformation:__eq(param1: wingformation, param2: wingformation): boolean
--- @param param1 wingformation 
--- @param param2 wingformation 
--- @return boolean # true if equal, false otherwise
function wingformation:__eq(param1, param2)end

--Detects whether handle is valid
--- @function wingformation:isValid(): boolean
--- @return boolean # true if valid, false if handle is invalid, nil if a syntax/type error occurs
function wingformation:isValid()end

-- Async: Support library for asynchronous operations
async = {}
--- @class Async
--- @field async.OnFrameExecutor executor An executor that executes operations at the end of rendering a frame. The executor handle
--- @field async.OnSimulationExecutor executor An executor that executes operations after all object simulation has been done but before rendering starts. This is the place to do physics manipulations. The executor handle
--Creates a promise that resolves when the resolve function of the callback is called or errors if the reject function is called. The function will be called on its own.
--- @function async.promise(body: function(function(any), function(any))): promise
--- @param body function(function(any), function(any)) 
--- @return promise # The promise or nil on error
function async.promise(body)end

--Creates a resolved promise with the values passed to this function.
--- @function async.resolved(resolveValues: any): promise
--- @param resolveValues any 
--- @return promise # Resolved promise
function async.resolved(resolveValues)end

--Creates an errored promise with the values passed to this function.
--- @function async.errored(errorValues: any): promise
--- @param errorValues any 
--- @return promise # Errored promise
function async.errored(errorValues)end

--Runs an asynchronous function. Inside this function you can use async.await to suspend the function until a promise resolves. Also allows to specify an executor on which the code of the coroutine should be executed. If captureContext is true then the game context (the game state) at the time of the call is captured and the coroutine is only run if that state is still active.
--- @function async.run(body: function(), executeOn: executor, captureContext: boolean | execution_context): promise
--- @param body function() 
--- @param executeOn executor? 
--- @param captureContext boolean | execution_context? Captures game state context by default
--- @return promise # A promise that resolves with the return value of the body when it reaches a return statement
function async.run(body, executeOn, captureContext)end

--Runs an asynchronous function in an OnFrameExecutor context and busy-waits for the coroutine to finish. Inside this function you can use async.await to suspend the function until a promise resolves. This is useful for cases where you need a scripting process to run over multiple frames, even when the engine is not in a stable game state (such as showing animations during game state switches, etc.).
--- @function async.awaitRunOnFrame(body: function(), allowMultiProcessing: boolean): any | nil
--- @param body function() 
--- @param allowMultiProcessing boolean? 
--- @return any | nil # The result of the function body or nil if the function errored
function async.awaitRunOnFrame(body, allowMultiProcessing)end

--Suspends an asynchronous coroutine until the passed promise resolves.
--- @function async.await(param1: promise): any
--- @param param1 promise 
--- @return any # The resolve value of the promise
function async.await(param1)end

--Returns a promise that will resolve on the next execution of the current executor. Effectively allows to asynchronously wait until the next frame.
--- @function async.yield(): promise
--- @return promise # The promise
function async.yield()end

--Causes the currently running coroutine to fail with an error with the specified values.
--- @function async.error(errorValues: any): nothing
--- @param errorValues any 
--- @return nil # Does not return
function async.error(errorValues)end

-- Audio: Sound/Music Library
ad = {}
--- @class Audio
--- @field ad.MasterVoiceVolume number The current master voice volume. This property is read-only. The volume in the range from 0 to 1
--- @field ad.MasterEventMusicVolume number The current master event music volume. This property is read-only. The volume in the range from 0 to 1
--- @field ad.MasterEffectsVolume number The current master effects volume. This property is read-only. The volume in the range from 0 to 1
--Return a sound entry matching the specified index or name. If you are using a number then the first valid index is 1
--- @function ad.getSoundentry(param1: string | number): soundentry
--- @param param1 string | number 
--- @return soundentry # soundentry or invalid handle on error
function ad.getSoundentry(param1)end

--Loads the specified sound file
--- @function ad.loadSoundfile(filename: string): soundfile
--- @param filename string 
--- @return soundfile # A soundfile handle
function ad.loadSoundfile(filename)end

--Plays the specified sound entry handle
--- @function ad.playSound(param1: soundentry): sound
--- @param param1 soundentry 
--- @return sound # A handle to the playing sound
function ad.playSound(param1)end

--Plays the specified sound as a looping sound
--- @function ad.playLoopingSound(param1: soundentry): sound
--- @param param1 soundentry 
--- @return sound # A handle to the playing sound or invalid handle if playback failed
function ad.playLoopingSound(param1)end

--Plays the specified sound entry handle. Source if by default 0, 0, 0 and listener is by default the current viewposition
--- @function ad.play3DSound(param1: soundentry, source: vector, listener: vector): sound3D
--- @param param1 soundentry 
--- @param source vector? 
--- @param listener vector? 
--- @return sound3D # A handle to the playing sound
function ad.play3DSound(param1, source, listener)end

--Plays a sound from #Game Sounds in sounds.tbl. A priority of 0 indicates that the song must play; 1-3 will specify the maximum number of that sound that can be played
--- @function ad.playGameSound(index: sound, Panning: number, Volume: number, Priority: number, VoiceMessage: boolean): boolean
--- @param index sound 
--- @param Panning number? -1.0 left to 1.0 right
--- @param Volume number? in percent
--- @param Priority number? 0-3
--- @param VoiceMessage boolean? 
--- @return boolean # True if sound was played, false if not (Replaced with a sound instance object in the future)
function ad.playGameSound(index, Panning, Volume, Priority, VoiceMessage)end

--Plays a sound from #Interface Sounds in sounds.tbl
--- @function ad.playInterfaceSound(index: number): boolean
--- @param index number 
--- @return boolean # True if sound was played, false if not
function ad.playInterfaceSound(index)end

--Plays a sound from #Interface Sounds in sounds.tbl by specifying the name of the sound entry. Sounds using the retail sound syntax can be accessed by specifying the index number as a string.
--- @function ad.playInterfaceSoundByName(name: string): boolean
--- @param name string 
--- @return boolean # True if sound was played, false if not
function ad.playInterfaceSoundByName(name)end

--Plays a music file using FS2Open's builtin music system. Volume is currently ignored, uses players music volume setting. Files passed to this function are looped by default.
--- @function ad.playMusic(Filename: string, volume: number, looping: boolean): number
--- @param Filename string 
--- @param volume number? 
--- @param looping boolean? 
--- @return number # Audiohandle of the created audiostream, or -1 on failure
function ad.playMusic(Filename, volume, looping)end

--Stops a playing music file, provided audiohandle is valid. If the 3rd arg is set to one of briefing,credits,mainhall then that music will be stopped despite the audiohandle given.
--- @function ad.stopMusic(audiohandle: number, fade: boolean, music_type: string): nothing
--- @param audiohandle number 
--- @param fade boolean? 
--- @param music_type string? briefing|credits|mainhall
--- @return nil
function ad.stopMusic(audiohandle, fade, music_type)end

--Pauses or unpauses a playing music file, provided audiohandle is valid. The boolean argument should be true to pause and false to unpause. If the audiohandle is -1, *all* audio streams are paused or unpaused.
--- @function ad.pauseMusic(audiohandle: number, pause: boolean): nothing
--- @param audiohandle number 
--- @param pause boolean 
--- @return nil
function ad.pauseMusic(audiohandle, pause)end

--Opens an audio stream of the specified file and type. An audio stream is meant for more long time sounds since they are streamed from the file instead of loaded in its entirety.
--- @function ad.openAudioStream(fileName: string, stream_type: enumeration): audio_stream
--- @param fileName string 
--- @param stream_type enumeration AUDIOSTREAM_* values
--- @return audio_stream # A handle to the opened stream or invalid on error
function ad.openAudioStream(fileName, stream_type)end

--Pauses or unpauses all weapon sounds. The boolean argument should be true to pause and false to unpause.
--- @function ad.pauseWeaponSounds(pause: boolean): nothing
--- @param pause boolean 
--- @return nil
function ad.pauseWeaponSounds(pause)end

--Pauses or unpauses all voice message sounds. The boolean argument should be true to pause and false to unpause.
--- @function ad.pauseVoiceMessages(pause: boolean): nothing
--- @param pause boolean 
--- @return nil
function ad.pauseVoiceMessages(pause)end

--Kills all currently playing voice messages.
--- @function ad.killVoiceMessages(): nothing
--- @return nil
function ad.killVoiceMessages()end

-- Base: Base FreeSpace 2 functions
ba = {}
--- @class Base
--- @field ba.MultiplayerMode boolean Determines if the game is currently in single- or multiplayer mode true if in multiplayer mode, false if in singleplayer. If neither is the case (e.g. on game init) nil will be returned
--Prints a string
--- @function ba.print(Message: string): nothing
--- @param Message string 
--- @return nil
function ba.print(Message)end

--Prints a string with a newline
--- @function ba.println(Message: string): nothing
--- @param Message string 
--- @return nil
function ba.println(Message)end

--Displays a FreeSpace warning (debug build-only) message with the string provided
--- @function ba.warning(Message: string): nothing
--- @param Message string 
--- @return nil
function ba.warning(Message)end

--Displays a FreeSpace error message with the string provided
--- @function ba.error(Message: string): nothing
--- @param Message string 
--- @return nil
function ba.error(Message)end

--Calls FSO's Random::next() function, which is higher-quality than Lua's ANSI C math.random().  If called with no arguments, returns a random integer from [0, 0x7fffffff].  If called with one argument, returns an integer from [0, a).  If called with two arguments, returns an integer from [a, b].
--- @function ba.rand32(a: number, b: number): number
--- @param a number? 
--- @param b number? 
--- @return number # A random integer
function ba.rand32(a, b)end

--Calls FSO's Random::next() function and transforms the result to a float.  If called with no arguments, returns a random float from [0.0, 1.0).  If called with one argument, returns a float from [0.0, max).
--- @function ba.rand32f(max: number): number
--- @param max number? 
--- @return number # A random float
function ba.rand32f(max)end

--Given 0 arguments, creates an identity orientation; 3 arguments, creates an orientation from pitch/bank/heading (in radians); 9 arguments, creates an orientation from a 3x3 row-major order matrix.
--- @function ba.createOrientation(): orientation
--- @return orientation # New orientation object, or the identity orientation on failure
function ba.createOrientation()end--- @function ba.createOrientation(p: number, b: number, h: number): orientation
--- @param p number 
--- @param b number 
--- @param h number 
--- @return orientation # New orientation object, or the identity orientation on failure
function ba.createOrientation(p, b, h)end--- @function ba.createOrientation(r1c1: number, r1c2: number, r1c3: number, r2c1: number, r2c2: number, r2c3: number, r3c1: number, r3c2: number, r3c3: number): orientation
--- @param r1c1 number 
--- @param r1c2 number 
--- @param r1c3 number 
--- @param r2c1 number 
--- @param r2c2 number 
--- @param r2c3 number 
--- @param r3c1 number 
--- @param r3c2 number 
--- @param r3c3 number 
--- @return orientation # New orientation object, or the identity orientation on failure
function ba.createOrientation(r1c1, r1c2, r1c3, r2c1, r2c2, r2c3, r3c1, r3c2, r3c3)end

--Given 0 to 3 arguments, creates an orientation object from 0 to 3 vectors.  (This is essentially a wrapper for the vm_vector_2_matrix function.)  If supplied 0 arguments, this will return the identity orientation.  The first vector, if supplied, must be non-null.
--- @function ba.createOrientationFromVectors(fvec: vector, uvec: vector, rvec: vector): orientation
--- @param fvec vector? 
--- @param uvec vector? 
--- @param rvec vector? 
--- @return orientation # New orientation object, or the identity orientation on failure
function ba.createOrientationFromVectors(fvec, uvec, rvec)end

--Creates a vector object
--- @function ba.createVector(x: number, y: number, z: number): vector
--- @param x number? 
--- @param y number? 
--- @param z number? 
--- @return vector # Vector object
function ba.createVector(x, y, z)end

--Creates a random normalized vector object.
--- @function ba.createRandomVector(): vector
--- @return vector # Vector object
function ba.createRandomVector()end

--Creates a random orientation object.
--- @function ba.createRandomOrientation(): orientation
--- @return orientation # Orientation object
function ba.createRandomOrientation()end

--Determines the surface normal of the plane defined by three points.  Returns a normalized vector.
--- @function ba.createSurfaceNormal(point1: vector, point2: vector, point3: vector): vector
--- @param point1 vector 
--- @param point2 vector 
--- @param point3 vector 
--- @return vector # The surface normal, or NIL if a handle is invalid
function ba.createSurfaceNormal(point1, point2, point3)end

--Determines the point at which two lines intersect.  (The lines are assumed to extend infinitely in both directions; the intersection will not necessarily be between the points.)
--- @function ba.findIntersection(line1_point1: vector, line1_point2: vector, line2_point1: vector, line2_point2: vector): vector, number
--- @param line1_point1 vector 
--- @param line1_point2 vector 
--- @param line2_point1 vector 
--- @param line2_point2 vector 
--- @return vector, number # Returns two arguments.  The first is the point of intersection, if it exists and is unique (otherwise it will be NIL).  The second is the find_intersection return value: 0 for a unique intersection, -1 if the lines are colinear, and -2 if the lines do not intersect.
function ba.findIntersection(line1_point1, line1_point2, line2_point1, line2_point2)end

--Determines the point on line 1 closest to line 2 when the lines are skew (non-intersecting in 3D space).  (The lines are assumed to extend infinitely in both directions; the point will not necessarily be between the other points.)
--- @function ba.findPointOnLineNearestSkewLine(line1_point1: vector, line1_point2: vector, line2_point1: vector, line2_point2: vector): vector
--- @param line1_point1 vector 
--- @param line1_point2 vector 
--- @param line2_point1 vector 
--- @param line2_point2 vector 
--- @return vector # The closest point, or NIL if a handle is invalid
function ba.findPointOnLineNearestSkewLine(line1_point1, line1_point2, line2_point1, line2_point2)end

--The overall frame time in fix units (seconds * 65536) since the engine has started
--- @function ba.getFrametimeOverall(): number
--- @return number # Overall time (fix units)
function ba.getFrametimeOverall()end

--The overall time in seconds since the engine has started
--- @function ba.getSecondsOverall(): number
--- @return number # Overall time (seconds)
function ba.getSecondsOverall()end

--Gets how long this frame is calculated to take. Use it to for animations, physics, etc to make incremental changes. Increased or decreased based on current time compression
--- @function ba.getMissionFrametime(): number
--- @return number # Frame time (seconds)
function ba.getMissionFrametime()end

--Gets how long this frame is calculated to take in real time. Not affected by time compression.
--- @function ba.getRealFrametime(): number
--- @return number # Frame time (seconds)
function ba.getRealFrametime()end

--Gets how long this frame is calculated to take. Use it to for animations, physics, etc to make incremental changes.
--- @function ba.getFrametime(adjustForTimeCompression: boolean): number
--- @param adjustForTimeCompression boolean? 
--- @return number # Frame time (seconds)
function ba.getFrametime(adjustForTimeCompression)end

--Gets current FreeSpace state; if a depth is specified, the state at that depth is returned. (IE at the in-game options game, a depth of 1 would give you the game state, while the function defaults to 0, which would be the options screen.
--- @function ba.getCurrentGameState(depth: number): gamestate
--- @param depth number? 
--- @return gamestate # Current game state at specified depth, or invalid handle if no game state is active yet
function ba.getCurrentGameState(depth)end

--Gets this computers current MP status
--- @function ba.getCurrentMPStatus(): string
--- @return string # Current MP status
function ba.getCurrentMPStatus()end

--Gets a handle of the currently used player.<br><b>Note:</b> If there is no current player then the first player will be returned, check the game state to make sure you have a valid player handle.
--- @function ba.getCurrentPlayer(): player
--- @return player # Player handle
function ba.getCurrentPlayer()end

--Loads the player with the specified callsign.
--- @function ba.loadPlayer(callsign: string): player
--- @param callsign string 
--- @return player # Player handle or invalid handle on load failure
function ba.loadPlayer(callsign)end

--Saves the specified player.
--- @function ba.savePlayer(plr: player): boolean
--- @param plr player 
--- @return boolean # true of successful, false otherwise
function ba.savePlayer(plr)end

--Sets the current control mode for the game.
--- @function ba.setControlMode(mode: nil | enumeration): string
--- @param mode nil | enumeration LE_*_CONTROL
--- @return string # Current control mode
function ba.setControlMode(mode)end

--Sets the current control mode for the game.
--- @function ba.setButtonControlMode(mode: nil | enumeration): string
--- @param mode nil | enumeration LE_*_BUTTON_CONTROL
--- @return string # Current control mode
function ba.setButtonControlMode(mode)end

--Gets the control info handle.
--- @function ba.getControlInfo(): control_info
--- @return control_info # control info handle
function ba.getControlInfo()end

--Sets whether to display tips of the day the next time the current pilot enters the mainhall.
--- @function ba.setTips(param1: boolean): nothing
--- @param param1 boolean 
--- @return nil
function ba.setTips(param1)end

--Returns the difficulty level from 1-5, 1 being the lowest, (Very Easy) and 5 being the highest (Insane)
--- @function ba.getGameDifficulty(): number
--- @return number # Difficulty level as integer
function ba.getGameDifficulty()end

--Sets current game event. Note that you can crash FreeSpace 2 by posting an event at an improper time, so test extensively if you use it.
--- @function ba.postGameEvent(Event: gameevent): boolean
--- @param Event gameevent 
--- @return boolean # True if event was posted, false if passed event was invalid
function ba.postGameEvent(Event)end

--Gets the translated version of text with the given id. This uses the tstrings.tbl for performing the translation by default. Set tstrings to false to use strings.tbl instead. Passing -1 as the id will always return the given text.
--- @function ba.XSTR(text: string, id: number, tstrings: boolean): string
--- @param text string 
--- @param id number 
--- @param tstrings boolean? 
--- @return string # The translated text
function ba.XSTR(text, id, tstrings)end

--Returns a string that replaces any default control binding to current binding (same as Directive Text). Default binding must be encapsulated by '$$' for replacement to work.
--- @function ba.replaceTokens(text: string): string
--- @param text string 
--- @return string # Updated string or nil if invalid
function ba.replaceTokens(text)end

--Returns a string that replaces any variable name with the variable value (same as text in Briefings, Debriefings, or Messages). Variable name must be preceded by '$' for replacement to work.
--- @function ba.replaceVariables(text: string): string
--- @param text string 
--- @return string # Updated string or nil if invalid
function ba.replaceVariables(text)end

--Determine if the current script is running in the mission editor (e.g. FRED2). This should be used to control which code paths will be executed even if running in the editor.
--- @function ba.inMissionEditor(): boolean
--- @return boolean # true when we are in the mission editor, false otherwise
function ba.inMissionEditor()end

--Determines if FSO is running in Release or Debug
--- @function ba.inDebug(): boolean
--- @return boolean # true if debug, false if release
function ba.inDebug()end

--Checks if the current version of the engine is at least the specified version. This can be used to check if a feature introduced in a later version of the engine is available.
--- @function ba.isEngineVersionAtLeast(major: number, minor: number, build: number, revision: number): boolean
--- @param major number 
--- @param minor number 
--- @param build number 
--- @param revision number? 
--- @return boolean # true if the version is at least the specified version. false otherwise.
function ba.isEngineVersionAtLeast(major, minor, build, revision)end

--Checks if the '$Lua API returns nil instead of invalid object:' option is set in game_settings.tbl.
--- @function ba.usesInvalidInsteadOfNil(): boolean
--- @return boolean # true if the option is set, false otherwise
function ba.usesInvalidInsteadOfNil()end

--Determines the language that is being used by the engine. This returns the full name of the language (e.g. "English").
--- @function ba.getCurrentLanguage(): string
--- @return string # The current game language
function ba.getCurrentLanguage()end

--Determines the file extension of the language that is being used by the engine. This returns a short code for the current language that can be used for creating language specific file names (e.g. "gr" when the current language is German). This will return an empty string for the default language.
--- @function ba.getCurrentLanguageExtension(): string
--- @return string # The current game language
function ba.getCurrentLanguageExtension()end

--Returns a string describing the version of the build that is currently running. This is mostly intended to be displayed to the user and not processed by a script so don't rely on the exact format of the string.
--- @function ba.getVersionString(): string
--- @return string # The version information
function ba.getVersionString()end

--Returns the name of the current mod's root folder.
--- @function ba.getModRootName(): string
--- @return string # The mod root
function ba.getModRootName()end

--Returns the title of the current mod as defined in game_settings.tbl. Will return an empty string if not defined.
--- @function ba.getModTitle(): string
--- @return string # The mod title
function ba.getModTitle()end

--Returns the version of the current mod as defined in game_settings.tbl. If the version is semantic versioning then the returned numbers will reflect that. String always returns the complete string. If semantic version is not used then the returned numbers will all be -1
--- @function ba.getModVersion(): string, number, number, number
--- @return string, number, number, number # The mod version string; the major, minor, patch version numbers or -1 if invalid
function ba.getModVersion()end

--Serializes the specified value so that it can be stored and restored consistently later. The actual format of the returned data is implementation specific but will be deserializable by at least this engine version and following versions.
--- @function ba.serializeValue(value: any): bytearray
--- @param value any 
--- @return bytearray # The serialized representation of the value or nil on error.
function ba.serializeValue(value)end

--Deserializes a previously serialized Lua value.
--- @function ba.deserializeValue(serialized: bytearray): any
--- @param serialized bytearray 
--- @return any # The deserialized Lua value.
function ba.deserializeValue(serialized)end

--Sets the Discord presence to a specific string. If Gameplay is true then the string is ignored and presence will be set as if the player is in-mission. The latter will fail if the player is not in a mission.
--- @function ba.setDiscordPresence(DisplayText: string, Gameplay: boolean): nothing
--- @param DisplayText string 
--- @param Gameplay boolean? 
--- @return nil # nothing
function ba.setDiscordPresence(DisplayText, Gameplay)end

--Returns if the game engine has focus or not
--- @function ba.hasFocus(): boolean
--- @return boolean # True if the game has focus, false if it has been lost
function ba.hasFocus()end

-- BitOps: Bitwise Operations library
bit = {}
--- @class BitOps
--Values for which bitwise boolean AND operation is performed
--- @function bit.AND(param1: number, param2: number, param3: number, param4: number, param5: number, param6: number, param7: number, param8: number, param9: number, param10: number): number
--- @param param1 number 
--- @param param2 number 
--- @param param3 number? 
--- @param param4 number? 
--- @param param5 number? 
--- @param param6 number? 
--- @param param7 number? 
--- @param param8 number? 
--- @param param9 number? 
--- @param param10 number? 
--- @return number # Result of the AND operation
function bit.AND(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)end

--Values for which bitwise boolean OR operation is performed
--- @function bit.OR(param1: number, param2: number, param3: number, param4: number, param5: number, param6: number, param7: number, param8: number, param9: number, param10: number): number
--- @param param1 number 
--- @param param2 number 
--- @param param3 number? 
--- @param param4 number? 
--- @param param5 number? 
--- @param param6 number? 
--- @param param7 number? 
--- @param param8 number? 
--- @param param9 number? 
--- @param param10 number? 
--- @return number # Result of the OR operation
function bit.OR(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)end

--Values for which bitwise boolean AND operation is performed
--- @function bit.EnumAND(param1: enumeration, param2: enumeration, param3: enumeration, param4: enumeration, param5: enumeration, param6: enumeration, param7: enumeration, param8: enumeration, param9: enumeration, param10: enumeration): number
--- @param param1 enumeration 
--- @param param2 enumeration 
--- @param param3 enumeration? 
--- @param param4 enumeration? 
--- @param param5 enumeration? 
--- @param param6 enumeration? 
--- @param param7 enumeration? 
--- @param param8 enumeration? 
--- @param param9 enumeration? 
--- @param param10 enumeration? 
--- @return number # Result of the AND operation
function bit.EnumAND(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)end

--Values for which bitwise boolean OR operation is performed
--- @function bit.EnumOR(param1: enumeration, param2: enumeration, param3: enumeration, param4: enumeration, param5: enumeration, param6: enumeration, param7: enumeration, param8: enumeration, param9: enumeration, param10: enumeration): number
--- @param param1 enumeration 
--- @param param2 enumeration 
--- @param param3 enumeration? 
--- @param param4 enumeration? 
--- @param param5 enumeration? 
--- @param param6 enumeration? 
--- @param param7 enumeration? 
--- @param param8 enumeration? 
--- @param param9 enumeration? 
--- @param param10 enumeration? 
--- @return number # Result of the OR operation
function bit.EnumOR(param1, param2, param3, param4, param5, param6, param7, param8, param9, param10)end

--Values for which bitwise boolean XOR operation is performed
--- @function bit.XOR(param1: number, param2: number): number
--- @param param1 number 
--- @param param2 number 
--- @return number # Result of the XOR operation
function bit.XOR(param1, param2)end

--Toggles the value of the set bit in the given number for 32 bit integer
--- @function bit.toggleBit(baseNumber: number, bit: number): number
--- @param baseNumber number 
--- @param bit number 
--- @return number # Result of the operation
function bit.toggleBit(baseNumber, bit)end

--Checks the value of the set bit in the given number for 32 bit integer
--- @function bit.checkBit(baseNumber: number, bit: number): boolean
--- @param baseNumber number 
--- @param bit number 
--- @return boolean # Was the bit true of false
function bit.checkBit(baseNumber, bit)end

--Performs inclusive or (OR) operation on the set bit of the value
--- @function bit.addBit(baseNumber: number, bit: number): number
--- @param baseNumber number 
--- @param bit number 
--- @return number # Result of the operation
function bit.addBit(baseNumber, bit)end

--Turns on the specified bit of baseNumber (sets it to 1)
--- @function bit.setBit(baseNumber: number, bit: number): number
--- @param baseNumber number 
--- @param bit number 
--- @return number # Result of the operation
function bit.setBit(baseNumber, bit)end

--Turns off the specified bit of baseNumber (sets it to 0)
--- @function bit.unsetBit(baseNumber: number, bit: number): number
--- @param baseNumber number 
--- @param bit number 
--- @return number # Result of the operation
function bit.unsetBit(baseNumber, bit)end

-- Campaign: Campaign Library
ca = {}
--- @class Campaign
--Gets next mission filename
--- @function ca.getNextMissionFilename(): string
--- @return string # Next mission filename, or nil if the next mission is invalid
function ca.getNextMissionFilename()end

--Gets previous mission filename
--- @function ca.getPrevMissionFilename(): string
--- @return string # Previous mission filename, or nil if the previous mission is invalid
function ca.getPrevMissionFilename()end

--Jumps to a mission based on the filename. Optionally, the player can be sent to a hub mission without setting missions to skipped.
--- @function ca.jumpToMission(filename: string, hub: boolean): boolean
--- @param filename string 
--- @param hub boolean? 
--- @return boolean # Jumps to a mission, or returns nil.
function ca.jumpToMission(filename, hub)end

-- CFile: CFile FS2 filesystem access
cf = {}
--- @class CFile
--Deletes given file. Path must be specified. Use a slash for the root directory.
--- @function cf.deleteFile(Filename: string, Path: string): boolean
--- @param Filename string 
--- @param Path string 
--- @return boolean # True if deleted, false
function cf.deleteFile(Filename, Path)end

--Checks if a file exists. Use a blank string for path for any directory, or a slash for the root directory.
--- @function cf.fileExists(Filename: string, Path: string, CheckVPs: boolean): boolean
--- @param Filename string 
--- @param Path string? 
--- @param CheckVPs boolean? 
--- @return boolean # True if file exists, false or nil otherwise
function cf.fileExists(Filename, Path, CheckVPs)end

--Lists all the files in the specified directory matching a filter. The filter must have the format "*<rest>" (the wildcard has to appear at the start), "<subfolder>/*<rest>" (to check subfolder(s)) or "*/*<rest>" (for a glob search).
--- @function cf.listFiles(directory: string, filter: string): string
--- @param directory string 
--- @param filter string 
--- @return string # A table with all matching files or nil on error
function cf.listFiles(directory, filter)end

--Opens a file. 'Mode' uses standard C fopen arguments. In read mode use a blank string for path for any directory, or a slash for the root directory. When using write mode a valid path must be specified. Be EXTREMELY CAREFUL when using this function, as you may PERMANENTLY delete any file by accident
--- @function cf.openFile(Filename: string, Mode: string, Path: string): file
--- @param Filename string 
--- @param Mode string? 
--- @param Path string? 
--- @return file # File handle, or invalid file handle if the specified file couldn't be opened
function cf.openFile(Filename, Mode, Path)end

--Opens a temp file that is automatically deleted when closed
--- @function cf.openTempFile(): file
--- @return file # File handle, or invalid file handle if tempfile couldn't be created
function cf.openTempFile()end

--Renames given file. Path must be specified. Use a slash for the root directory.
--- @function cf.renameFile(CurrentFilename: string, NewFilename: string, Path: string): boolean
--- @param CurrentFilename string 
--- @param NewFilename string 
--- @param Path string 
--- @return boolean # True if file was renamed, otherwise false
function cf.renameFile(CurrentFilename, NewFilename, Path)end

-- Controls: Controls library
io = {}
--- @class Controls
--- @field io.XAxisInverted boolean Gets or sets whether the heading axis action's primary binding is inverted True/false
--- @field io.YAxisInverted boolean Gets or sets whether the pitch axis action's primary binding is inverted True/false
--- @field io.ZAxisInverted boolean Gets or sets whether the bank axis action's primary binding is inverted True/false
--- @field io.HeadingAxisPrimaryInverted boolean Gets or sets whether the heading axis action's primary binding is inverted True/false
--- @field io.HeadingAxisSecondaryInverted boolean Gets or sets whether the heading axis action's secondary binding is inverted True/false
--- @field io.PitchAxisPrimaryInverted boolean Gets or sets whether the pitch axis action's primary binding is inverted True/false
--- @field io.PitchAxisSecondaryInverted boolean Gets or sets whether the pitch axis action's secondary binding is inverted True/false
--- @field io.BankAxisPrimaryInverted boolean Gets or sets whether the bank axis action's primary binding is inverted True/false
--- @field io.BankAxisSecondaryInverted boolean Gets or sets whether the bank axis action's secondary binding is inverted True/false
--- @field io.AbsoluteThrottleAxisPrimaryInverted boolean Gets or sets whether the absolute throttle axis action's primary binding is inverted True/false
--- @field io.AbsoluteThrottleAxisSecondaryInverted boolean Gets or sets whether the absolute throttle axis action's secondary binding is inverted True/false
--- @field io.RelativeThrottleAxisPrimaryInverted boolean Gets or sets whether the relative throttle axis action's primary binding is inverted True/false
--- @field io.RelativeThrottleAxisSecondaryInverted boolean Gets or sets whether the relative throttle axis action's secondary binding is inverted True/false
--- @field io.FlightCursorMode enumeration Flight Mode; uses LE_FLIGHTMODE_* enumerations. enumeration flight mode
--- @field io.FlightCursorExtent number How far from the center the cursor can go. Flight cursor extent in radians
--- @field io.FlightCursorDeadzone number How far from the center the cursor needs to go before registering. Flight cursor deadzone in radians
--- @field io.FlightCursorPitch number Flight cursor pitch value Flight cursor pitch value
--- @field io.FlightCursorHeading number Flight cursor heading value Flight cursor heading value
--- @field io.MouseControlStatus boolean Gets and sets the retail mouse control status if the retail mouse is on or off
--Gets Mouse X pos
--- @function io.getMouseX(): number
--- @return number # Mouse x position, or 0 if mouse is not initialized yet
function io.getMouseX()end

--Gets Mouse Y pos
--- @function io.getMouseY(): number
--- @return number # Mouse y position, or 0 if mouse is not initialized yet
function io.getMouseY()end

--Returns whether the specified mouse buttons are up or down
--- @function io.isMouseButtonDown(buttonCheck1: enumeration, buttonCheck2: enumeration, buttonCheck3: enumeration): boolean
--- @param buttonCheck1 enumeration MOUSE_*_BUTTON
--- @param buttonCheck2 enumeration? MOUSE_*_BUTTON
--- @param buttonCheck3 enumeration? MOUSE_*_BUTTON
--- @return boolean # Whether specified mouse buttons are down, or false if mouse is not initialized yet
function io.isMouseButtonDown(buttonCheck1, buttonCheck2, buttonCheck3)end

--Returns the pressed count of the specified button.  The count is then reset, unless reset_count (which defaults to true) is false.
--- @function io.mouseButtonDownCount(buttonCheck: enumeration, reset_count: boolean): number
--- @param buttonCheck enumeration any one of MOUSE_LEFT_BUTTON, MOUSE_RIGHT_BUTTON, MOUSE_MIDDLE_BUTTON, MOUSE_X1_BUTTON, MOUSE_X2_BUTTON
--- @param reset_count boolean? 
--- @return number # The number of frames this button has been pressed, or -1 if the mouse has not been initialized
function io.mouseButtonDownCount(buttonCheck, reset_count)end

--Clears mouse input data, including button press count, button flags, wheel scroll value, and position delta.
--- @function io.flushMouse(): nothing
--- @return nil # Returns nothing
function io.flushMouse()end

--Gets or sets the given Joystick or Mouse axis inversion state.  Mouse cid = -1, Joystick cid = [0, 3]
--- @function io.AxisInverted(cid: number, axis: number, inverted: boolean): boolean
--- @param cid number 
--- @param axis number 
--- @param inverted boolean 
--- @return boolean # True/false
function io.AxisInverted(cid, axis, inverted)end

--Resets flight cursor position to the center of the screen.
--- @function io.resetFlightCursor(): nothing
--- @return nil
function io.resetFlightCursor()end

--Sets mouse cursor image, and allows you to lock/unlock the image. (A locked cursor may only be changed with the unlock parameter)
--- @function io.setCursorImage(filename: string): boolean
--- @param filename string 
--- @return boolean # true if successful, false otherwise
function io.setCursorImage(filename)end

--Hides the cursor when <i>hide</i> is true, otherwise shows it. <i>grab</i> determines if the mouse will be restricted to the window. Set this to true when hiding the cursor while in game. By default grab will be true when we are in the game play state, false otherwise.
--- @function io.setCursorHidden(hide: boolean, grab: boolean): nothing
--- @param hide boolean 
--- @param grab boolean? 
--- @return nil
function io.setCursorHidden(hide, grab)end

--function to force mouse position
--- @function io.forceMousePosition(x: number, y: number): boolean
--- @param x number 
--- @param y number 
--- @return boolean # if the operation succeeded or not
function io.forceMousePosition(x, y)end

--Gets mouse sensitivity setting
--- @function io.getMouseSensitivity(): number
--- @return number # Mouse sensitivity in range of 0-9
function io.getMouseSensitivity()end

--Gets joystick sensitivity setting
--- @function io.getJoySensitivity(): number
--- @return number # Joystick sensitivity in range of 0-9
function io.getJoySensitivity()end

--Gets joystick deadzone setting
--- @function io.getJoyDeadzone(): number
--- @return number # Joystick deadzone in range of 0-9
function io.getJoyDeadzone()end

--Updates Tracking Data. Call before using get functions
--- @function io.updateTrackIR(): boolean
--- @return boolean # Checks if trackir is available and updates variables, returns true if successful, otherwise false
function io.updateTrackIR()end

--Gets pitch axis from last update
--- @function io.getTrackIRPitch(): number
--- @return number # Pitch value -1 to 1, or 0 on failure
function io.getTrackIRPitch()end

--Gets yaw axis from last update
--- @function io.getTrackIRYaw(): number
--- @return number # Yaw value -1 to 1, or 0 on failure
function io.getTrackIRYaw()end

--Gets roll axis from last update
--- @function io.getTrackIRRoll(): number
--- @return number # Roll value -1 to 1, or 0 on failure
function io.getTrackIRRoll()end

--Gets x position from last update
--- @function io.getTrackIRX(): number
--- @return number # X value -1 to 1, or 0 on failure
function io.getTrackIRX()end

--Gets y position from last update
--- @function io.getTrackIRY(): number
--- @return number # Y value -1 to 1, or 0 on failure
function io.getTrackIRY()end

--Gets z position from last update
--- @function io.getTrackIRZ(): number
--- @return number # Z value -1 to 1, or 0 on failure
function io.getTrackIRZ()end

-- Engine: Basic engine access functions
engine = {}
--- @class Engine
--Adds a function to be called from the specified game hook
--- @function engine.addHook(name: string, hookFunction: function(), conditionals: table, override_func: function()): boolean
--- @param name string 
--- @param hookFunction function() 
--- @param conditionals table? Empty table by default
--- @param override_func function()? Function returning false by default
--- @return boolean # true if hook was installed properly, false otherwise
function engine.addHook(name, hookFunction, conditionals, override_func)end

--Executes a <b>blocking</b> sleep. Usually only necessary for development or testing purposes. Use with care!
--- @function engine.sleep(seconds: number): nothing
--- @param seconds number 
--- @return nil
function engine.sleep(seconds)end

--Creates a new category for tracing the runtime of a code segment. Also allows to trace how long the corresponding code took on the GPU.
--- @function engine.createTracingCategory(name: string, gpu_category: boolean): tracing_category
--- @param name string 
--- @param gpu_category boolean? 
--- @return tracing_category # The allocated category.
function engine.createTracingCategory(name, gpu_category)end

--Closes and reopens the fs2_open.log
--- @function engine.restartLog(): nothing
--- @return nil
function engine.restartLog()end

-- Graphics: Graphics Library
gr = {}
--- @class Graphics
--- @field gr.CurrentFont font Current font
--- @field gr.CurrentOpacityType enumeration Current alpha blending type; uses ALPHABLEND_* enumerations
--- @field gr.CurrentRenderTarget texture Current rendering target Current rendering target, or invalid texture handle if screen is render target
--- @field gr.CurrentResizeMode enumeration Current resize mode; uses GR_RESIZE_* enumerations.  This resize mode will be used by the gr.* drawing methods.
--Sets the intensity of the specified post-processing effect. Optionally sets RGB values for effects that use them (valid values are 0.0 to 1.0)
--- @function gr.setPostEffect(name: string, value: number, red: number, green: number, blue: number): boolean
--- @param name string 
--- @param value number? 
--- @param red number? 
--- @param green number? 
--- @param blue number? 
--- @return boolean # true when successful, false otherwise
function gr.setPostEffect(name, value, red, green, blue)end

--Resets all post-processing effects to their default values
--- @function gr.resetPostEffects(): boolean
--- @return boolean # true if successful, false otherwise
function gr.resetPostEffects()end

--Calls gr_clear(), which fills the entire screen with the currently active color.  Useful if you want to have a fresh start for drawing things.  (Call this between setClip and resetClip if you only want to clear part of the screen.)
--- @function gr.clear(): nothing
--- @return nil
function gr.clear()end

--Clears the screen to black, or the color specified.
--- @function gr.clearScreen(param1: number | color, green: number, blue: number, alpha: number): nothing
--- @param param1 number | color? red value or color object
--- @param green number? 
--- @param blue number? 
--- @param alpha number? 
--- @return nil
function gr.clearScreen(param1, green, blue, alpha)end

--Creates a new camera using the specified position and orientation (World)
--- @function gr.createCamera(Name: string, Position: vector, Orientation: orientation): camera
--- @param Name string 
--- @param Position vector? 
--- @param Orientation orientation? 
--- @return camera # Camera handle, or invalid camera handle if camera couldn't be created
function gr.createCamera(Name, Position, Orientation)end

--Returns whether the standard interface is stretched
--- @function gr.isMenuStretched(): boolean
--- @return boolean # True if stretched, false if aspect ratio is maintained
function gr.isMenuStretched()end

--Gets screen width
--- @function gr.getScreenWidth(): number
--- @return number # Width in pixels, or 0 if graphics are not initialized yet
function gr.getScreenWidth()end

--Gets screen height
--- @function gr.getScreenHeight(): number
--- @return number # Height in pixels, or 0 if graphics are not initialized yet
function gr.getScreenHeight()end

--Gets width of center monitor (should be used in conjunction with getCenterOffsetX)
--- @function gr.getCenterWidth(): number
--- @return number # Width of center monitor in pixels, or 0 if graphics are not initialized yet
function gr.getCenterWidth()end

--Gets height of center monitor (should be used in conjunction with getCenterOffsetY)
--- @function gr.getCenterHeight(): number
--- @return number # Height of center monitor in pixels, or 0 if graphics are not initialized yet
function gr.getCenterHeight()end

--Gets X offset of center monitor
--- @function gr.getCenterOffsetX(): number
--- @return number # X offset of center monitor in pixels
function gr.getCenterOffsetX()end

--Gets Y offset of center monitor
--- @function gr.getCenterOffsetY(): number
--- @return number # Y offset of center monitor in pixels
function gr.getCenterOffsetY()end

--Gets the current camera handle, if argument is <i>true</i> then it will also return the main camera when no custom camera is in use
--- @function gr.getCurrentCamera(param1: boolean): camera
--- @param param1 boolean? 
--- @return camera # camera handle or invalid handle on error
function gr.getCurrentCamera(param1)end

--Returns a vector through screen coordinates x and y. If depth is specified, vector is extended to Depth units into spaceIf normalize is true, vector will be normalized.
--- @function gr.getVectorFromCoords(X: number, Y: number, Depth: number, normalize: boolean): vector
--- @param X number? 
--- @param Y number? 
--- @param Depth number? 
--- @param normalize boolean? 
--- @return vector # Vector, or zero vector on failure
function gr.getVectorFromCoords(X, Y, Depth, normalize)end

--If texture is specified, sets current rendering surface to a texture.Otherwise, sets rendering surface back to screen.
--- @function gr.setTarget(Texture: texture): boolean
--- @param Texture texture? 
--- @return boolean # True if successful, false otherwise
function gr.setTarget(Texture)end

--Sets current camera, or resets camera if none specified
--- @function gr.setCamera(Camera: camera): boolean
--- @param Camera camera? 
--- @return boolean # true if successful, false or nil otherwise
function gr.setCamera(Camera)end

--Sets 2D drawing color; each color number should be from 0 (darkest) to 255 (brightest)
--- @function gr.setColor(param1: number | color, Green: number, Blue: number, Alpha: number): nothing
--- @param param1 number | color red value or color object
--- @param Green number 
--- @param Blue number 
--- @param Alpha number? 
--- @return nil
function gr.setColor(param1, Green, Blue, Alpha)end

--Gets the active 2D drawing color. False to return raw rgb, true to return a color object. Defaults to false.
--- @function gr.getColor(param1: boolean): number, number, number, number, color
--- @param param1 boolean? 
--- @return number, number, number, number, color # rgba color which is currently in use for 2D drawing
function gr.getColor(param1)end

--Sets the line width for lines. This call might fail if the specified width is not supported by the graphics implementation. Then the width will be the nearest supported value.
--- @function gr.setLineWidth(width: number): boolean
--- @param width number? 
--- @return boolean # true if succeeded, false otherwise
function gr.setLineWidth(width)end

--Draws a circle
--- @function gr.drawCircle(Radius: number, X: number, Y: number, Filled: boolean): nothing
--- @param Radius number 
--- @param X number 
--- @param Y number 
--- @param Filled boolean? 
--- @return nil
function gr.drawCircle(Radius, X, Y, Filled)end

--Draws an arc
--- @function gr.drawArc(Radius: number, X: number, Y: number, StartAngle: number, EndAngle: number, Filled: boolean): nothing
--- @param Radius number 
--- @param X number 
--- @param Y number 
--- @param StartAngle number 
--- @param EndAngle number 
--- @param Filled boolean? 
--- @return nil
function gr.drawArc(Radius, X, Y, StartAngle, EndAngle, Filled)end

--Draws a curve
--- @function gr.drawCurve(X: number, Y: number, Radius: number): nothing
--- @param X number 
--- @param Y number 
--- @param Radius number 
--- @return nil
function gr.drawCurve(X, Y, Radius)end

--Draws a line from (x1,y1) to (x2,y2) with the CurrentColor that steadily fades out
--- @function gr.drawGradientLine(X1: number, Y1: number, X2: number, Y2: number): nothing
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @return nil
function gr.drawGradientLine(X1, Y1, X2, Y2)end

--Draws a line from (x1,y1) to (x2,y2) with CurrentColor
--- @function gr.drawLine(X1: number, Y1: number, X2: number, Y2: number): nothing
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @return nil
function gr.drawLine(X1, Y1, X2, Y2)end

--Sets pixel to CurrentColor
--- @function gr.drawPixel(X: number, Y: number): nothing
--- @param X number 
--- @param Y number 
--- @return nil
function gr.drawPixel(X, Y)end

--Draws a polygon. May not work properly in hooks other than On Object Render.
--- @function gr.drawPolygon(Texture: texture, Position: vector, Orientation: orientation, Width: number, Height: number): nothing
--- @param Texture texture 
--- @param Position vector? Default is null vector
--- @param Orientation orientation? 
--- @param Width number? 
--- @param Height number? 
--- @return nil
function gr.drawPolygon(Texture, Position, Orientation, Width, Height)end

--Draws a rectangle with CurrentColor. May be rotated by passing the angle parameter in radians.
--- @function gr.drawRectangle(X1: number, Y1: number, X2: number, Y2: number, Filled: boolean, angle: number): nothing
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number 
--- @param Y2 number 
--- @param Filled boolean? 
--- @param angle number? 
--- @return nil
function gr.drawRectangle(X1, Y1, X2, Y2, Filled, angle)end

--Draws a rectangle centered at X,Y with CurrentColor. May be rotated by passing the angle parameter in radians.
--- @function gr.drawRectangleCentered(X: number, Y: number, Width: number, Height: number, Filled: boolean, angle: number): nothing
--- @param X number 
--- @param Y number 
--- @param Width number 
--- @param Height number 
--- @param Filled boolean? 
--- @param angle number? 
--- @return nil
function gr.drawRectangleCentered(X, Y, Width, Height, Filled, angle)end

--Draws a sphere with radius Radius at world vector Position. May not work properly in hooks other than On Object Render.
--- @function gr.drawSphere(Radius: number, Position: vector): boolean
--- @param Radius number? 
--- @param Position vector? 
--- @return boolean # True if successful, false or nil otherwise
function gr.drawSphere(Radius, Position)end

--Draws a line from origin to destination. The line may be translucent or solid. Translucent lines will NOT use the alpha value, instead being more transparent the darker the color is. The thickness at the start can be different from the thickness at the end, to draw a line that tapers or expands.
--- @function gr.draw3dLine(origin: vector, destination: vector, translucent: boolean, thickness: number, thicknessEnd: number): nothing
--- @param origin vector 
--- @param destination vector 
--- @param translucent boolean? 
--- @param thickness number? 
--- @param thicknessEnd number? 
--- @return nil
function gr.draw3dLine(origin, destination, translucent, thickness, thicknessEnd)end

--Draws the given model with the specified position and orientation.  Note: this method does NOT use CurrentResizeMode.
--- @function gr.drawModel(model: model, position: vector, orientation: orientation): number
--- @param model model 
--- @param position vector 
--- @param orientation orientation 
--- @return number # Zero if successful, otherwise an integer error code
function gr.drawModel(model, position, orientation)end

--Draws the given model with the specified position and orientation
--- @function gr.drawModelOOR(Model: model, Position: vector, Orientation: orientation, Flags: number): number
--- @param Model model 
--- @param Position vector 
--- @param Orientation orientation 
--- @param Flags number? 
--- @return number # Zero if successful, otherwise an integer error code
function gr.drawModelOOR(Model, Position, Orientation, Flags)end

--Gets the edge positions of targeting brackets for the specified object. The brackets will only be drawn if draw is true or the default value of draw is used. Brackets are drawn with the current color. The brackets will have a padding (distance from the actual bounding box); the default value (used elsewhere in FS2) is 5.  Note: this method does NOT use CurrentResizeMode.
--- @function gr.drawTargetingBrackets(Object: object, draw: boolean, padding: number): number, number, number, number
--- @param Object object 
--- @param draw boolean? 
--- @param padding number? 
--- @return number, number, number, number # Left, top, right, and bottom positions of the brackets, or nil if invalid
function gr.drawTargetingBrackets(Object, draw, padding)end

--Gets the edge position of the targeting brackets drawn for a subsystem as if they were drawn on the HUD. Only actually draws the brackets if <i>draw</i> is true, optionally sets the color the as if it was drawn on the HUD
--- @function gr.drawSubsystemTargetingBrackets(subsys: subsystem, draw: boolean, setColor: boolean): number, number, number, number
--- @param subsys subsystem 
--- @param draw boolean? 
--- @param setColor boolean? 
--- @return number, number, number, number # Left, top, right, and bottom positions of the brackets, or nil if invalid or off-screen
function gr.drawSubsystemTargetingBrackets(subsys, draw, setColor)end

--Draws an off-screen indicator for the given object. The indicator will not be drawn if draw=false, but the coordinates will be returned in either case. The indicator will be drawn using the current color if setColor=true and using the IFF color of the object if setColor=false.
--- @function gr.drawOffscreenIndicator(Object: object, draw: boolean, setColor: boolean): number, number
--- @param Object object 
--- @param draw boolean? 
--- @param setColor boolean? 
--- @return number, number # Coordinates of the indicator (at the very edge of the screen), or nil if object is on-screen
function gr.drawOffscreenIndicator(Object, draw, setColor)end

--Draws a string. Use x1/y1 to control position, x2/y2 to limit textbox size.Text will automatically move onto new lines, if x2/y2 is specified.Additionally, calling drawString with only a string argument will automaticallydraw that string below the previously drawn string (or 0,0 if no stringshave been drawn yet
--- @function gr.drawString(Message: string | boolean, X1: number, Y1: number, X2: number, Y2: number): number
--- @param Message string | boolean 
--- @param X1 number? 
--- @param Y1 number? 
--- @param X2 number? 
--- @param Y2 number? 
--- @return number # Number of lines drawn, or 0 on failure
function gr.drawString(Message, X1, Y1, X2, Y2)end

--Draws a string, scaled according to the GR_RESIZE_* parameter. Use x1/y1 to control position, x2/y2 to limit textbox size.Text will automatically move onto new lines, if x2/y2 is specified, however the line spacing will probably not be correct.Additionally, calling drawString with only a string argument will automaticallydraw that string below the previously drawn string (or 0,0 if no stringshave been drawn yet
--- @function gr.drawStringResized(ResizeMode: enumeration, Message: string | boolean, X1: number, Y1: number, X2: number, Y2: number): number
--- @param ResizeMode enumeration 
--- @param Message string | boolean 
--- @param X1 number? 
--- @param Y1 number? 
--- @param X2 number? 
--- @param Y2 number? 
--- @return number # Number of lines drawn, or 0 on failure
function gr.drawStringResized(ResizeMode, Message, X1, Y1, X2, Y2)end

--Calls gr_set_screen_scale with the specified parameters.  This is useful for adjusting the drawing of graphics or text to be the same apparent size regardless of resolution.
--- @function gr.setScreenScale(width: number, height: number, zoom_x: number, zoom_y: number, max_x: number, max_y: number, center_x: number, center_y: number, force_stretch: boolean): nothing
--- @param width number 
--- @param height number 
--- @param zoom_x number? 
--- @param zoom_y number? 
--- @param max_x number? 
--- @param max_y number? 
--- @param center_x number? 
--- @param center_y number? 
--- @param force_stretch boolean? 
--- @return nil
function gr.setScreenScale(width, height, zoom_x, zoom_y, max_x, max_y, center_x, center_y, force_stretch)end

--Rolls back the most recent call to setScreenScale.
--- @function gr.resetScreenScale(): nothing
--- @return nil
function gr.resetScreenScale()end

--Gets string width
--- @function gr.getStringWidth(String: string): number
--- @param String string 
--- @return number # String width, or 0 on failure
function gr.getStringWidth(String)end

--Gets string height
--- @function gr.getStringHeight(String: string): number
--- @param String string 
--- @return number # String height, or 0 on failure
function gr.getStringHeight(String)end

--Gets string width and height
--- @function gr.getStringSize(String: string): number, number
--- @param String string 
--- @return number, number # String width and height, or 0, 0 on failure
function gr.getStringSize(String)end

--Plays a streaming animation, returning its handle. The optional booleans (except cache and grayscale) can also be set via the handle's virtvars<br>cache is best set to false when loading animations that are only intended to play once, e.g. headz<br>Remember to call the unload() function when you're finished using the animation to free up memory.
--- @function gr.loadStreamingAnim(Filename: string, loop: boolean, reverse: boolean, pause: boolean, cache: boolean, grayscale: boolean): streaminganim
--- @param Filename string 
--- @param loop boolean? 
--- @param reverse boolean? 
--- @param pause boolean? 
--- @param cache boolean? 
--- @param grayscale boolean? 
--- @return streaminganim # Streaming animation handle, or invalid handle if animation couldn't be loaded
function gr.loadStreamingAnim(Filename, loop, reverse, pause, cache, grayscale)end

--Creates a texture for rendering to.Types are TEXTURE_STATIC - for infrequent rendering - and TEXTURE_DYNAMIC - for frequent rendering.
--- @function gr.createTexture(Width: number, Height: number, Type: enumeration): texture
--- @param Width number? 
--- @param Height number? 
--- @param Type enumeration? 
--- @return texture # New texture handle, or invalid texture handle if texture couldn't be created
function gr.createTexture(Width, Height, Type)end

--Gets a handle to a texture. If second argument is set to true, animations will also be loaded.If third argument is set to true, every other animation frame will not be loaded if system has less than 48 MB memory.<br><strong>IMPORTANT:</strong> Textures will not be unload themselves unless you explicitly tell them to do so.When you are done with a texture, call the unload() function to free up memory.
--- @function gr.loadTexture(Filename: string, LoadIfAnimation: boolean, NoDropFrames: boolean): texture
--- @param Filename string 
--- @param LoadIfAnimation boolean? 
--- @param NoDropFrames boolean? 
--- @return texture # Texture handle, or invalid texture handle if texture couldn't be loaded
function gr.loadTexture(Filename, LoadIfAnimation, NoDropFrames)end

--Draws an image file or texture. Any image extension passed will be ignored.The UV variables specify the UV value for each corner of the image. In UV coordinates, (0,0) is the top left of the image; (1,1) is the lower right. If aaImage is true, image needs to be monochrome and will be drawn tinted with the currently active color.The angle variable can be used to rotate the image in radians.
--- @function gr.drawImage(fileNameOrTexture: string | texture, X1: number, Y1: number, X2: number, Y2: number, UVX1: number, UVY1: number, UVX2: number, UVY2: number, alpha: number, aaImage: boolean, angle: number): boolean
--- @param fileNameOrTexture string | texture 
--- @param X1 number? 
--- @param Y1 number? 
--- @param X2 number? 
--- @param Y2 number? 
--- @param UVX1 number? 
--- @param UVY1 number? 
--- @param UVX2 number? 
--- @param UVY2 number? 
--- @param alpha number? 
--- @param aaImage boolean? 
--- @param angle number? 
--- @return boolean # Whether image was drawn
function gr.drawImage(fileNameOrTexture, X1, Y1, X2, Y2, UVX1, UVY1, UVX2, UVY2, alpha, aaImage, angle)end

--Draws an image file or texture centered on the X,Y position. Any image extension passed will be ignored.The UV variables specify the UV value for each corner of the image. In UV coordinates, (0,0) is the top left of the image; (1,1) is the lower right. If aaImage is true, image needs to be monochrome and will be drawn tinted with the currently active color.The angle variable can be used to rotate the image in radians.
--- @function gr.drawImageCentered(fileNameOrTexture: string | texture, X: number, Y: number, W: number, H: number, UVX1: number, UVY1: number, UVX2: number, UVY2: number, alpha: number, aaImage: boolean, angle: number): boolean
--- @param fileNameOrTexture string | texture 
--- @param X number? 
--- @param Y number? 
--- @param W number? 
--- @param H number? 
--- @param UVX1 number? 
--- @param UVY1 number? 
--- @param UVX2 number? 
--- @param UVY2 number? 
--- @param alpha number? 
--- @param aaImage boolean? 
--- @param angle number? 
--- @return boolean # Whether image was drawn
function gr.drawImageCentered(fileNameOrTexture, X, Y, W, H, UVX1, UVY1, UVX2, UVY2, alpha, aaImage, angle)end

--Draws a monochrome image from a texture or file using the current color
--- @function gr.drawMonochromeImage(fileNameOrTexture: string | texture, X1: number, Y1: number, X2: number, Y2: number, alpha: number): boolean
--- @param fileNameOrTexture string | texture 
--- @param X1 number 
--- @param Y1 number 
--- @param X2 number? 
--- @param Y2 number? 
--- @param alpha number? 
--- @return boolean # Whether image was drawn
function gr.drawMonochromeImage(fileNameOrTexture, X1, Y1, X2, Y2, alpha)end

--Gets image width
--- @function gr.getImageWidth(Filename: string): number
--- @param Filename string 
--- @return number # Image width, or 0 if filename is invalid
function gr.getImageWidth(Filename)end

--Gets image height
--- @function gr.getImageHeight(name: string): number
--- @param name string 
--- @return number # Image height, or 0 if filename is invalid
function gr.getImageHeight(name)end

--Flashes the screen
--- @function gr.flashScreen(param1: number | color, Green: number, Blue: number): nothing
--- @param param1 number | color red value or color object
--- @param Green number 
--- @param Blue number 
--- @return nil
function gr.flashScreen(param1, Green, Blue)end

--Loads the model - will not setup subsystem data, DO NOT USE FOR LOADING SHIP MODELS
--- @function gr.loadModel(Filename: string): model
--- @param Filename string 
--- @return model # Handle to a model
function gr.loadModel(Filename)end

--Specifies if the current viemode has the specified flag, see VM_* enumeration
--- @function gr.hasViewmode(param1: enumeration): boolean
--- @param param1 enumeration 
--- @return boolean # true if flag is present, false otherwise
function gr.hasViewmode(param1)end

--Sets the clipping region to the specified rectangle. Most drawing functions are able to handle the offset.
--- @function gr.setClip(x: number, y: number, width: number, height: number, ResizeMode: enumeration): boolean
--- @param x number 
--- @param y number 
--- @param width number 
--- @param height number 
--- @param ResizeMode enumeration? 
--- @return boolean # true if successful, false otherwise
function gr.setClip(x, y, width, height, ResizeMode)end

--Resets the clipping region that might have been set
--- @function gr.resetClip(): boolean
--- @return boolean # true if successful, false otherwise
function gr.resetClip()end

--Opens the movie with the specified name. If the name has an extension it will be removed. This function will try all movie formats supported by the engine and use the first that is found.
--- @function gr.openMovie(name: string, looping: boolean): movie_player
--- @param name string 
--- @param looping boolean? 
--- @return movie_player # The cutscene player handle or invalid handle if cutscene could not be opened.
function gr.openMovie(name, looping)end

--Creates a persistent particle. Persistent variables are handled specially by the engine so that this function can return a handle to the caller. Only use this if you absolutely need it. Use createParticle if the returned handle is not required. Use PARTICLE_* enumerations for type.Reverse reverse animation, if one is specifiedAttached object specifies object that Position will be (and always be) relative to.
--- @function gr.createPersistentParticle(Position: vector, Velocity: vector, Lifetime: number, Radius: number, Type: enumeration, TracerLength: number, Reverse: boolean, Texture: texture, AttachedObject: object): particle
--- @param Position vector 
--- @param Velocity vector 
--- @param Lifetime number 
--- @param Radius number 
--- @param Type enumeration? 
--- @param TracerLength number? 
--- @param Reverse boolean? 
--- @param Texture texture? 
--- @param AttachedObject object? 
--- @return particle # Handle to the created particle
function gr.createPersistentParticle(Position, Velocity, Lifetime, Radius, Type, TracerLength, Reverse, Texture, AttachedObject)end

--Creates a non-persistent particle. Use PARTICLE_* enumerations for type.Reverse reverse animation, if one is specifiedAttached object specifies object that Position will be (and always be) relative to.
--- @function gr.createParticle(Position: vector, Velocity: vector, Lifetime: number, Radius: number, Type: enumeration, TracerLength: number, Reverse: boolean, Texture: texture, AttachedObject: object): boolean
--- @param Position vector 
--- @param Velocity vector 
--- @param Lifetime number 
--- @param Radius number 
--- @param Type enumeration? 
--- @param TracerLength number? 
--- @param Reverse boolean? 
--- @param Texture texture? 
--- @param AttachedObject object? 
--- @return boolean # true if particle was created, false otherwise
function gr.createParticle(Position, Velocity, Lifetime, Radius, Type, TracerLength, Reverse, Texture, AttachedObject)end

--Clears all particles from a mission
--- @function gr.killAllParticles(): nothing
--- @return nil
function gr.killAllParticles()end

--Captures the current render target and encodes it into a blob-PNG
--- @function gr.screenToBlob(): string
--- @return string # The png blob string
function gr.screenToBlob()end

--Releases all loaded models and frees the memory. Intended for use in UI situations and not within missions. Do not use after mission parse. Use at your own risk!
--- @function gr.freeAllModels(): nothing
--- @return nil
function gr.freeAllModels()end

--Creates a color object. Values are capped 0-255. Alpha defaults to 255.
--- @function gr.createColor(Red: number, Green: number, Blue: number, Alpha: number): color
--- @param Red number 
--- @param Green number 
--- @param Blue number 
--- @param Alpha number? 
--- @return color # The color
function gr.createColor(Red, Green, Blue, Alpha)end

--Queries whether or not FSO is currently trying to render to a head-mounted VR display.
--- @function gr.isVR(): boolean
--- @return boolean # true if FSO is currently outputting frames to a VR headset.
function gr.isVR()end

-- HookVariables: Hook variables repository
hv = {}
--- @class HookVariables
--Retrieves a hook variable value
--- @function hv.__indexer(variableName: string): any
--- @param variableName string 
--- @return any # The hook variable value or nil if hook variable is not defined
function hv.__indexer(variableName)end

-- HUD: HUD library
hu = {}
--- @class HUD
--- @field hu.HUDDrawn boolean Whether the HUD is toggled on, i.e. is the HUD enabled.  See also hu.isOnHudDrawCalled() Whether the HUD can be drawn
--- @field hu.HUDHighContrast boolean Gets or sets whether the HUD is currently high-contrast Whether the HUD is high-contrast
--- @field hu.HUDDisabledExceptMessages boolean Specifies if only the messages gauges of the hud are drawn true if only the message gauges are drawn, false otherwise
--- @field hu.HUDDefaultGaugeCount number Specifies the number of HUD gauges defined by FSO.  Note that for historical reasons, HUD scripting functions use a zero-based index (0 to n-1) for gauges. The number of FSO HUD gauges
--- @field hu.toggleCockpits boolean Gets or sets whether the the cockpit model will be rendered. true if being rendered, false otherwise
--- @field hu.toggleCockpitSway boolean Gets or sets whether the the cockpit model will sway due to ship acceleration. true if using 'sway', false otherwise
--Gets the HUD configuration show status for the specified default HUD gauge.
--- @function hu.getHUDConfigShowStatus(gaugeNameOrIndex: number | string): boolean
--- @param gaugeNameOrIndex number | string 
--- @return boolean # Returns show status or nil if gauge invalid
function hu.getHUDConfigShowStatus(gaugeNameOrIndex)end

--Modifies color used to draw the gauge in the pilot config
--- @function hu.setHUDGaugeColor(gaugeNameOrIndex: number | string, param2: number | color, green: number, blue: number, alpha: number): boolean
--- @param gaugeNameOrIndex number | string 
--- @param param2 number | color? red value or color object
--- @param green number? 
--- @param blue number? 
--- @param alpha number? 
--- @return boolean # If the operation was successful
function hu.setHUDGaugeColor(gaugeNameOrIndex, param2, green, blue, alpha)end

--Color specified in the config to draw the gauge. False to return raw rgba, true to return color object. Defaults to false.
--- @function hu.getHUDGaugeColor(gaugeNameOrIndex: number | string, ReturnType: boolean): number, number, number, number, color
--- @param gaugeNameOrIndex number | string 
--- @param ReturnType boolean? 
--- @return number, number, number, number, color # Red, green, blue, and alpha of the gauge
function hu.getHUDGaugeColor(gaugeNameOrIndex, ReturnType)end

--Set color currently used to draw the gauge
--- @function hu.setHUDGaugeColorInMission(gaugeNameOrIndex: number | string, param2: number | color, green: number, blue: number, alpha: number): boolean
--- @param gaugeNameOrIndex number | string 
--- @param param2 number | color? red value or color object
--- @param green number? 
--- @param blue number? 
--- @param alpha number? 
--- @return boolean # If the operation was successful
function hu.setHUDGaugeColorInMission(gaugeNameOrIndex, param2, green, blue, alpha)end

--Color currently used to draw the gauge. False returns raw rgb, true returns color object. Defaults to false.
--- @function hu.getHUDGaugeColorInMission(gaugeNameOrIndex: number | string, ReturnType: boolean): number, number, number, number, color
--- @param gaugeNameOrIndex number | string 
--- @param ReturnType boolean? 
--- @return number, number, number, number, color # Red, green, blue, and alpha of the gauge
function hu.getHUDGaugeColorInMission(gaugeNameOrIndex, ReturnType)end

--Returns a handle to a specified HUD gauge
--- @function hu.getHUDGaugeHandle(Name: string): HudGauge
--- @param Name string 
--- @return HudGauge # HUD Gauge handle, or nil if invalid
function hu.getHUDGaugeHandle(Name)end

--Flashes a section of the target box with a default duration of 1400 milliseconds
--- @function hu.flashTargetBox(section: enumeration, duration_in_milliseconds: number): nothing
--- @param section enumeration 
--- @param duration_in_milliseconds number? 
--- @return nil
function hu.flashTargetBox(section, duration_in_milliseconds)end

--Returns the distance as displayed on the HUD, that is, the distance from a position to the bounding box of a target.  If targeter_position is nil, the function will use the player's position.
--- @function hu.getTargetDistance(targetee: object, targeter_position: vector): number
--- @param targetee object 
--- @param targeter_position vector? 
--- @return number # The distance, or nil if invalid
function hu.getTargetDistance(targetee, targeter_position)end

--Returns the number of lines displayed by the currently active directives
--- @function hu.getDirectiveLines(): number
--- @return number # The number of lines
function hu.getDirectiveLines()end

--Returns whether the HUD comm menu is currently being displayed
--- @function hu.isCommMenuOpen(): boolean
--- @return boolean # Whether the comm menu is open
function hu.isCommMenuOpen()end

--Returns whether the On Hud Draw hook is called this frame.  This is useful for scripting logic that is relevant to HUD drawing but is not part of the On Hud Draw hook
--- @function hu.isOnHudDrawCalled(): boolean
--- @return boolean # Whether the On Hud Draw hook is called this frame
function hu.isOnHudDrawCalled()end

-- Mission: Mission library
mn = {}
--- @class Mission
--- @field mn.MissionHUDTimerPadding number Gets or sets padding currently applied to the HUD mission timer. the padding in seconds
--- @field mn.ShudderPerpetual boolean Gets or sets whether the shudder is perpetual, i.e. with a constant intensity that does not decay. the shudder perpetual flag
--- @field mn.ShudderEverywhere boolean Gets or sets whether the shudder is applied everywhere regardless of camera view. the shudder everywhere flag
--- @field mn.ShudderTimeLeft number Gets or sets the number of seconds until the shudder stops.  This is independent of the decay time. the shudder time left variable
--- @field mn.ShudderDecayTime number Gets or sets the shudder decay time in seconds.  This can be zero in which case the shudder will not decay. the shudder decay time variable
--- @field mn.ShudderIntensity number Gets or sets the shudder intensity variable.  For comparison, the Maxim has a value of 1440. the shudder intensity variable
--- @field mn.Gravity vector Gravity acceleration vector in meters / second^2 gravity vector
--- @field mn.CustomData table Gets the custom data table for this mission The mission's custom data table
--- @field mn.CustomStrings table Gets the indexed custom data table for this mission. Each item in the table is a table with the following values: Name - the name of the custom string, Value - the value associated with the custom string, String - the custom string itself. The mission's custom data table
--- @field mn.NebulaSensorRange number Gets or sets the Neb2_awacs variable.  This is multiplied by a species-specific factor to get the "scan range".  Within the scan range, a ship is at least partially targetable (fuzzy blip); within half the scan range, a ship is fully targetable.  Beyond the scan range, a ship is not targetable. the Neb2_awacs variable
--- @field mn.NebulaNearMult number Gets or sets the multiplier of the near plane of the current nebula. The multiplier of the near plane.
--- @field mn.NebulaFarMult number Gets or sets the multiplier of the far plane of the current nebula. The multiplier of the far plane.
--- @field mn.SkyboxOrientation orientation Sets or returns the current skybox orientation the orientation
--- @field mn.SkyboxAlpha number Sets or returns the current skybox alpha the alpha
--- @field mn.Skybox model Sets or returns the current skybox model The skybox model
--Gets a handle of an object from its signature
--- @function mn.getObjectFromSignature(Signature: number): object
--- @param Signature number 
--- @return object # Handle of object with signaure, invalid handle if signature is not in use
function mn.getObjectFromSignature(Signature)end

--Runs the defined SEXP script, and returns the result as a boolean
--- @function mn.evaluateSEXP(param1: string): boolean
--- @param param1 string 
--- @return boolean # true if the SEXP returned SEXP_TRUE or SEXP_KNOWN_TRUE; false if the SEXP returned anything else (even a number)
function mn.evaluateSEXP(param1)end

--Runs the defined SEXP script, and returns the result as a number
--- @function mn.evaluateNumericSEXP(param1: string): number
--- @param param1 string 
--- @return number # the value of the SEXP result (or NaN if the SEXP returned SEXP_NAN or SEXP_NAN_FOREVER)
function mn.evaluateNumericSEXP(param1)end

--Runs the defined SEXP script within a `when` operator
--- @function mn.runSEXP(param1: string): boolean
--- @param param1 string 
--- @return boolean # if the operation was successful
function mn.runSEXP(param1)end

--Adds a message
--- @function mn.addMessage(name: string, text: string, persona: persona): message
--- @param name string 
--- @param text string 
--- @param persona persona? 
--- @return message # The new message or invalid handle on error
function mn.addMessage(name, text, persona)end

--Sends a message from the given source or ship with the given priority, or optionally sends it from the mission's command source.<br>If delay is specified, the message will be delayed by the specified time in seconds.<br>If sender is <i>nil</i> the message will not have a sender.  If sender is a ship object the message will be sent from the ship; if sender is a string the message will have a non-ship source even if the string is a ship name.
--- @function mn.sendMessage(sender: string | ship, message: message, delay: number, priority: enumeration, fromCommand: boolean): boolean
--- @param sender string | ship 
--- @param message message 
--- @param delay number? 
--- @param priority enumeration? 
--- @param fromCommand boolean? 
--- @return boolean # true if successful, false otherwise
function mn.sendMessage(sender, message, delay, priority, fromCommand)end

--Sends a training message to the player. <i>time</i> is the amount in seconds to display the message, only whole seconds are used!
--- @function mn.sendTrainingMessage(message: message, time: number, delay: number): boolean
--- @param message message 
--- @param time number 
--- @param delay number? 
--- @return boolean # true if successful, false otherwise
function mn.sendTrainingMessage(message, time, delay)end

--Sends a plain text message without it being present in the mission message list
--- @function mn.sendPlainMessage(message: string): boolean
--- @param message string 
--- @return boolean # true if successful false otherwise
function mn.sendPlainMessage(message)end

--Adds a string to the message log scrollback without sending it as a message first. Source should be either the team handle or one of the SCROLLBACK_SOURCE enumerations.
--- @function mn.addMessageToScrollback(message: string, source: team | enumeration): boolean
--- @param message string 
--- @param source team | enumeration? 
--- @return boolean # true if successful, false otherwise
function mn.addMessageToScrollback(message, source)end

--Creates a ship and returns a handle to it using the specified name, class, world orientation, and world position; and logs it in the mission log unless specified otherwise
--- @function mn.createShip(Name: string, Class: shipclass, Orientation: orientation, Position: vector, Team: team, ShowInMissionLog: boolean): ship
--- @param Name string? 
--- @param Class shipclass? First ship class by default
--- @param Orientation orientation? 
--- @param Position vector? null vector by default
--- @param Team team? 
--- @param ShowInMissionLog boolean? true by default
--- @return ship # Ship handle, or invalid ship handle if ship couldn't be created
function mn.createShip(Name, Class, Orientation, Position, Team, ShowInMissionLog)end

--Creates a chunk or shard of debris with the specified parameters.  Vectors are in world coordinates.  Any parameter can be nil or negative to specify defaults.  A nil source will create generic or vaporized debris; submodel_index_or_name will be disregarded if source is submodel and can be nil to spawn random generic or vaporized debris; position defaults to 0,0,0; orientation defaults to the source orientation or a random orientation for non-ship sources or for generic/vaporized debris; create_flags can be any combination of DC_IS_HULL, DC_VAPORIZE, DC_SET_VELOCITY, or DC_FIRE_HOOK; hitpoints defaults to 1/8 source ship hitpoints or 10 hitpoints if there is no source ship; explosion_center and explosion_force_multiplier are only applicable for DC_SET_VELOCITY
--- @function mn.createDebris(source: ship | shipclass | model | submodel | nil, submodel_index_or_name: string | nil, position: vector, param4: orientation, create_flags: enumeration, hitpoints: number, spark_timeout_seconds: number, param8: team, explosion_center: vector, explosion_force_multiplier: number): debris
--- @param source ship | shipclass | model | submodel | nil? 
--- @param submodel_index_or_name string | nil? 
--- @param position vector? 
--- @param param4 orientation? 
--- @param create_flags enumeration? 
--- @param hitpoints number? 
--- @param spark_timeout_seconds number? 
--- @param param8 team? 
--- @param explosion_center vector? 
--- @param explosion_force_multiplier number? 
--- @return debris # Debris handle, or invalid handle if the debris couldn't be created
function mn.createDebris(source, submodel_index_or_name, position, param4, create_flags, hitpoints, spark_timeout_seconds, param8, explosion_center, explosion_force_multiplier)end

--Creates a waypoint
--- @function mn.createWaypoint(Position: vector, List: waypointlist): waypoint
--- @param Position vector? 
--- @param List waypointlist? 
--- @return waypoint # Waypoint handle, or invalid waypoint handle if waypoint couldn't be created
function mn.createWaypoint(Position, List)end

--Creates a weapon and returns a handle to it. 'Group' is used for lighting grouping purposes; for example, quad lasers would only need to act as one light source.  Use generateWeaponGroupId() if you need a group.
--- @function mn.createWeapon(Class: weaponclass, Orientation: orientation, WorldPosition: vector, Parent: object, GroupId: number): weapon
--- @param Class weaponclass? first weapon in table by default
--- @param Orientation orientation? 
--- @param WorldPosition vector? null vector by default
--- @param Parent object? 
--- @param GroupId number? 
--- @return weapon # Weapon handle, or invalid weapon handle if weapon couldn't be created.
function mn.createWeapon(Class, Orientation, WorldPosition, Parent, GroupId)end

--Generates a weapon group ID to be used with createWeapon.  This is only needed for weapons that should share a light source, such as quad lasers.  Group IDs may be reused by the engine.
--- @function mn.generateWeaponGroupId(): number
--- @return number # the group ID
function mn.generateWeaponGroupId()end

--Creates a warp-effect fireball and returns a handle to it.
--- @function mn.createWarpeffect(WorldPosition: vector, PointTo: vector, radius: number, duration: number, Class: fireballclass, WarpOpenSound: soundentry, WarpCloseSound: soundentry, WarpOpenDuration: number, WarpCloseDuration: number, Velocity: vector, Use3DModel: boolean): fireball
--- @param WorldPosition vector 
--- @param PointTo vector 
--- @param radius number 
--- @param duration number Must be >= 4
--- @param Class fireballclass 
--- @param WarpOpenSound soundentry 
--- @param WarpCloseSound soundentry 
--- @param WarpOpenDuration number? 
--- @param WarpCloseDuration number? 
--- @param Velocity vector? null vector by default
--- @param Use3DModel boolean? 
--- @return fireball # Fireball handle, or invalid fireball handle if fireball couldn't be created.
function mn.createWarpeffect(WorldPosition, PointTo, radius, duration, Class, WarpOpenSound, WarpCloseSound, WarpOpenDuration, WarpCloseDuration, Velocity, Use3DModel)end

--Creates an explosion-effect fireball and returns a handle to it.
--- @function mn.createExplosion(WorldPosition: vector, radius: number, Class: fireballclass, LargeExplosion: boolean, Velocity: vector, parent: object): fireball
--- @param WorldPosition vector 
--- @param radius number 
--- @param Class fireballclass 
--- @param LargeExplosion boolean? 
--- @param Velocity vector? null vector by default
--- @param parent object? 
--- @return fireball # Fireball handle, or invalid fireball handle if fireball couldn't be created.
function mn.createExplosion(WorldPosition, radius, Class, LargeExplosion, Velocity, parent)end

--Creates a lightning bolt between the origin and target vectors. BoltName is name of a bolt from lightning.tbl
--- @function mn.createBolt(BoltName: string, Origin: vector, Target: vector, PlaySound: boolean): boolean
--- @param BoltName string 
--- @param Origin vector 
--- @param Target vector 
--- @param PlaySound boolean? 
--- @return boolean # True if successful, false if the bolt couldn't be created.
function mn.createBolt(BoltName, Origin, Target, PlaySound)end

--Get whether or not the player's call for support will be successful. If simple check is false, the code will do a much more expensive, but accurate check.
--- @function mn.getSupportAllowed(SimpleCheck: boolean): boolean
--- @param SimpleCheck boolean? 
--- @return boolean # true if support can be called, false if not or not in a mission
function mn.getSupportAllowed(SimpleCheck)end

--Gets mission filename
--- @function mn.getMissionFilename(): string
--- @return string # Mission filename, or empty string if game is not in a mission
function mn.getMissionFilename()end

--Starts the defined mission
--- @function mn.startMission(mission: string | enumeration, Briefing: boolean): boolean
--- @param mission string | enumeration Filename or MISSION_* enumeration
--- @param Briefing boolean? 
--- @return boolean # True, or false if the function fails
function mn.startMission(mission, Briefing)end

--Game time in seconds since the mission was started; is affected by time compression
--- @function mn.getMissionTime(): number
--- @return number # Mission time (seconds) of the current or most recently played mission.
function mn.getMissionTime()end

--Loads a mission
--- @function mn.loadMission(missionName: string): boolean
--- @param missionName string 
--- @return boolean # True if mission was loaded, otherwise false
function mn.loadMission(missionName)end

--Stops the current mission and unloads it. If forceUnload is true then the mission unload logic will run regardless of if a mission is loaded or not. Use with caution.
--- @function mn.unloadMission(forceUnload: boolean): nothing
--- @param forceUnload boolean? 
--- @return nil
function mn.unloadMission(forceUnload)end

--Simulates mission frame
--- @function mn.simulateFrame(): nothing
--- @return nil
function mn.simulateFrame()end

--Renders mission frame, but does not move anything
--- @function mn.renderFrame(): nothing
--- @return nil
function mn.renderFrame()end

--Applies a shudder effect to the camera. Time is in seconds. Intensity specifies the shudder effect strength; the Maxim has a value of 1440. If perpetual is true, the shudder does not decay. If everywhere is true, the shudder is applied regardless of view.
--- @function mn.applyShudder(time: number, intensity: number, perpetual: boolean, everywhere: boolean): boolean
--- @param time number 
--- @param intensity number 
--- @param perpetual boolean? 
--- @param everywhere boolean? 
--- @return boolean # true if successful, false otherwise
function mn.applyShudder(time, intensity, perpetual, everywhere)end

--Detects whether the mission has any custom data
--- @function mn.hasCustomData(): boolean
--- @return boolean # true if the mission's custom_data is not empty, false otherwise
function mn.hasCustomData()end

--Adds a custom data pair with the given key if it's unique. Only works in FRED! The description will be displayed in the FRED custom data editor.
--- @function mn.addDefaultCustomData(key: string, value: string, description: string): boolean
--- @param key string 
--- @param value string 
--- @param description string 
--- @return boolean # returns true if sucessful, false otherwise. Returns nil if not running in FRED.
function mn.addDefaultCustomData(key, value, description)end

--Detects whether the mission has any custom strings
--- @function mn.hasCustomStrings(): boolean
--- @return boolean # true if the mission's custom_strings is not empty, false otherwise
function mn.hasCustomStrings()end

--get whether or not a mission is currently being played
--- @function mn.isInMission(): boolean
--- @return boolean # true if in mission, false otherwise
function mn.isInMission()end

--get whether the mission is currently in the pre-player-entry state
--- @function mn.isPrePlayerEntry(): boolean
--- @return boolean # true if in pre-player-entry, false otherwise
function mn.isPrePlayerEntry()end

--Get whether or not the current mission being played in a campaign (as opposed to the tech room's simulator)
--- @function mn.isInCampaign(): boolean
--- @return boolean # true if in campaign, false if not
function mn.isInCampaign()end

--Get whether or not the current mission being played is a loop mission in the context of a campaign
--- @function mn.isInCampaignLoop(): boolean
--- @return boolean # true if in loop and campaign, false if not
function mn.isInCampaignLoop()end

--Get whether or not the current mission being played is a training mission
--- @function mn.isTraining(): boolean
--- @return boolean # true if in training, false if not
function mn.isTraining()end

--Get whether or not the current mission being played is a scramble mission
--- @function mn.isScramble(): boolean
--- @return boolean # true if scramble, false if not
function mn.isScramble()end

--Get whether or not the player has reached the failure limit
--- @function mn.isMissionSkipAllowed(): boolean
--- @return boolean # true if limit reached, false if not
function mn.isMissionSkipAllowed()end

--Get whether or not the mission is set to skip the briefing
--- @function mn.hasNoBriefing(): boolean
--- @return boolean # true if it should be skipped, false if not
function mn.hasNoBriefing()end

--Get whether or not the current mission being played is set in a nebula
--- @function mn.isNebula(): boolean
--- @return boolean # true if in nebula, false if not
function mn.isNebula()end

--Get whether or not the current mission being played contains a volumetric nebula
--- @function mn.hasVolumetricNebula(): boolean
--- @return boolean # true if has a volumetric nebula, false if not
function mn.hasVolumetricNebula()end

--Get whether or not the current mission being played is set in subspace
--- @function mn.isSubspace(): boolean
--- @return boolean # true if in subspace, false if not
function mn.isSubspace()end

--Get the title of the current mission
--- @function mn.getMissionTitle(): string
--- @return string # The mission title or an empty string if currently not in mission
function mn.getMissionTitle()end

--Get the modified date of the current mission
--- @function mn.getMissionModifiedDate(): string
--- @return string # The mission modified date or an empty string if currently not in mission
function mn.getMissionModifiedDate()end

--Adds a background bitmap to the mission with the specified parameters, but using the old incorrectly-calculated angle math.
--- @function mn.addBackgroundBitmap(name: string, orientation: orientation, scaleX: number, scale_y: number, div_x: number, div_y: number): background_element
--- @param name string 
--- @param orientation orientation? 
--- @param scaleX number? 
--- @param scale_y number? 
--- @param div_x number? 
--- @param div_y number? 
--- @return background_element # A handle to the background element, or invalid handle if the function failed.
function mn.addBackgroundBitmap(name, orientation, scaleX, scale_y, div_x, div_y)end

--Adds a background bitmap to the mission with the specified parameters, treating the angles as correctly calculated.
--- @function mn.addBackgroundBitmapNew(name: string, orientation: orientation, scaleX: number, scale_y: number, div_x: number, div_y: number): background_element
--- @param name string 
--- @param orientation orientation? 
--- @param scaleX number? 
--- @param scale_y number? 
--- @param div_x number? 
--- @param div_y number? 
--- @return background_element # A handle to the background element, or invalid handle if the function failed.
function mn.addBackgroundBitmapNew(name, orientation, scaleX, scale_y, div_x, div_y)end

--Adds a sun bitmap to the mission with the specified parameters, but using the old incorrectly-calculated angle math.
--- @function mn.addSunBitmap(name: string, orientation: orientation, scaleX: number, scale_y: number): background_element
--- @param name string 
--- @param orientation orientation? 
--- @param scaleX number? 
--- @param scale_y number? 
--- @return background_element # A handle to the background element, or invalid handle if the function failed.
function mn.addSunBitmap(name, orientation, scaleX, scale_y)end

--Adds a sun bitmap to the mission with the specified parameters, treating the angles as correctly calculated.
--- @function mn.addSunBitmapNew(name: string, orientation: orientation, scaleX: number, scale_y: number): background_element
--- @param name string 
--- @param orientation orientation? 
--- @param scaleX number? 
--- @param scale_y number? 
--- @return background_element # A handle to the background element, or invalid handle if the function failed.
function mn.addSunBitmapNew(name, orientation, scaleX, scale_y)end

--Removes the background element specified by the handle. The handle must have been returned by either addBackgroundBitmap or addBackgroundSun. This handle will be invalidated by this function.
--- @function mn.removeBackgroundElement(el: background_element): boolean
--- @param el background_element 
--- @return boolean # true if successful
function mn.removeBackgroundElement(el)end

--Returns the current skybox model instance
--- @function mn.getSkyboxInstance(): model_instance
--- @return model_instance # The skybox model instance
function mn.getSkyboxInstance()end

--Determines if the current mission is a red alert mission
--- @function mn.isRedAlertMission(): boolean
--- @return boolean # true if red alert mission, false otherwise.
function mn.isRedAlertMission()end

--Determines if the current mission has a command briefing
--- @function mn.hasCommandBriefing(): boolean
--- @return boolean # true if command briefing, false otherwise.
function mn.hasCommandBriefing()end

--Determines if the current mission will show a Goals briefing stage
--- @function mn.hasGoalsStage(): boolean
--- @return boolean # true if stage is active, false otherwise.
function mn.hasGoalsStage()end

--Determines if the current mission has a debriefing
--- @function mn.hasDebriefing(): boolean
--- @return boolean # true if debriefing, false otherwise.
function mn.hasDebriefing()end

--Returns the music.tbl entry name for the specified mission music score
--- @function mn.getMusicScore(score: enumeration): string
--- @param score enumeration 
--- @return string # The name, or nil if the score is invalid
function mn.getMusicScore(score)end

--Sets the music.tbl entry for the specified mission music score
--- @function mn.setMusicScore(score: enumeration, name: string): nothing
--- @param score enumeration 
--- @param name string 
--- @return nil
function mn.setMusicScore(score, name)end

--Checks whether the to-position is in line of sight from the from-position, disregarding specific excluded objects and objects with a radius of less then threshold.
--- @function mn.hasLineOfSight(from: vector, to: vector, excludedObjects: table, testForShields: boolean, testForHull: boolean, threshold: number): boolean
--- @param from vector 
--- @param to vector 
--- @param excludedObjects table? expects list of objects, empty by default
--- @param testForShields boolean? 
--- @param testForHull boolean? 
--- @param threshold number? 
--- @return boolean # true if there is line of sight, false otherwise.
function mn.hasLineOfSight(from, to, excludedObjects, testForShields, testForHull, threshold)end

--Checks whether the to-position is in line of sight from the from-position and returns the distance and intersecting object to the first interruption of the line of sight, disregarding specific excluded objects and objects with a radius of less then threshold.
--- @function mn.getLineOfSightFirstIntersect(from: vector, to: vector, excludedObjects: table, testForShields: boolean, testForHull: boolean, threshold: number): boolean, number, object
--- @param from vector 
--- @param to vector 
--- @param excludedObjects table? expects list of objects, empty by default
--- @param testForShields boolean? 
--- @param testForHull boolean? 
--- @param threshold number? 
--- @return boolean, number, object # true and zero and nil if there is line of sight, false and the distance and intersecting object otherwise.
function mn.getLineOfSightFirstIntersect(from, to, excludedObjects, testForShields, testForHull, threshold)end

--Gets an animation handle. Target is the object that should be animated (one of "cockpit", "skybox"), type is the string name of the animation type, triggeredBy is a closer specification which animation should trigger. See *-anim.tbm specifications. 
--- @function mn.getSpecialSubmodelAnimation(target: string, type: string, triggeredBy: string): animation_handle
--- @param target string 
--- @param type string 
--- @param triggeredBy string 
--- @return animation_handle # The animation handle for the specified animation, nil if invalid arguments.
function mn.getSpecialSubmodelAnimation(target, type, triggeredBy)end

--Updates a moveable animation. Name is the name of the moveable. For what values needs to contain, please refer to the table below, depending on the type of the moveable:Orientation:  	Three numbers, x, y, z rotation respectively, in degrees  Rotation:  	Three numbers, x, y, z rotation respectively, in degrees  Axis Rotation:  	One number, rotation angle in degrees  Inverse Kinematics:  	Three required numbers: x, y, z position target relative to base, in 1/100th meters  	Three optional numbers: x, y, z rotation target relative to base, in degrees  
--- @function mn.updateSpecialSubmodelMoveable(target: string, name: string, values: table): boolean
--- @param target string 
--- @param name string 
--- @param values table 
--- @return boolean # True if successful, false or nil otherwise
function mn.updateSpecialSubmodelMoveable(target, name, values)end

--Adds an enum with the given name if it's unique.
--- @function mn.addLuaEnum(name: string): LuaEnum
--- @param name string 
--- @return LuaEnum # Returns the enum handle or an invalid handle if the name was not unique.
function mn.addLuaEnum(name)end

--Get the list of yet to arrive ships for this mission
--- @function mn.getArrivalList(): parse_object[]
--- @return parse_object[] # An iterator across all the yet to arrive ships. Can be used in a for .. in loop. Is not valid for more than one frame.
function mn.getArrivalList()end

--Get an iterator to the list of ships in this mission
--- @function mn.getShipList(): ship[]
--- @return ship[] # An iterator across all ships in the mission. Can be used in a for .. in loop. Is not valid for more than one frame.
function mn.getShipList()end

--Get an iterator to the list of missiles in this mission
--- @function mn.getMissileList(): weapon[]
--- @return weapon[] # An iterator across all missiles in the mission. Can be used in a for .. in loop. Is not valid for more than one frame.
function mn.getMissileList()end

--Performs an asynchronous wait until the specified amount of mission time has passed.
--- @function mn.waitAsync(seconds: number): promise
--- @param seconds number 
--- @return promise # A promise with no return value that resolves when the specified time has passed
function mn.waitAsync(seconds)end

-- Multi: Functions for scripting for and in multiplayer environments.
multi = {}
--- @class Multi
--Prints a string
--- @function multi.isServer(): boolean
--- @return boolean # true if the script is running on the server, false if it is running on a client or in singleplayer.
function multi.isServer()end

--Adds a remote procedure call. This call must run on all clients / the server where the RPC is expected to be able to execute. The given RPC name must be unique. For advanced users: It is possible have different clients / servers add different RPC methods with the same name. In this case, each client will run their registered method when a different client calls the RPC with the corresponding name. Passing nil as the execution function means that the RPC can be called from this client, but not on this client. The mode is used to determine how the data is transmitted. RPC_RELIABLE means that data is guaranteed to arrive, and to be in order. RPC_ORDERED is a faster variant that guarantees that calls from the same caller to the same functions will always be in order, but can drop. Calls to clients are expected to drop slightly more often than calls to servers in this mode. RPC_UNRELIABLE is the fastest mode, but has no guarantees about ordering of calls, and does not guarantee arrival (but will be slightly better than RPC_ORDERED). The recipient will be used as the default recipient for this RPC, but can be overridden on a per-call basis. Valid are: RPC_SERVER, RPC_CLIENTS, RPC_BOTH
--- @function multi.addRPC(name: string, rpc_body: function(any), mode: enumeration, recipient: enumeration): rpc
--- @param name string 
--- @param rpc_body function(any) 
--- @param mode enumeration? 
--- @param recipient enumeration? 
--- @return rpc # An RPC object, or an invalid RPC object on failure.
function multi.addRPC(name, rpc_body, mode, recipient)end

-- Options: Options library
opt = {}
--- @class Options
--- @field opt.Options option The available options. A table of all the options.
--- @field opt.MultiLogin string The multiplayer PXO login name The login name
--- @field opt.MultiPassword boolean The multiplayer PXO login password True if a password is set, false otherwise
--- @field opt.MultiSquad string The multiplayer PXO squad name The squad name
--Persist any changes made to the options system. Options can be incapable of applying changes immediately in which case they are returned here.
--- @function opt.persistChanges(): option
--- @return option # The options that did not support changing their value
function opt.persistChanges()end

--Discard any changes made to the options system.
--- @function opt.discardChanges(): boolean
--- @return boolean # True on success, false otherwise
function opt.discardChanges()end

--Gets the current multiplayer IP Address list as a table
--- @function opt.readIPAddressTable(): table
--- @return table # The IP Address table
function opt.readIPAddressTable()end

--Saves the table to the multiplayer IP Address list
--- @function opt.writeIPAddressTable(param1: table): boolean
--- @param param1 table 
--- @return boolean # True if successful, false otherwise
function opt.writeIPAddressTable(param1)end

--Verifies if a string is a valid IP address
--- @function opt.verifyIPAddress(param1: string): boolean
--- @param param1 string 
--- @return boolean # True if valid, false otherwise
function opt.verifyIPAddress(param1)end

-- Parsing: Engine parsing library
parse = {}
--- @class Parsing
--Reads the text of the given file into the parsing system. If a directory is given then the file is read from that location.
--- @function parse.readFileText(file: string, directory: string): boolean
--- @param file string 
--- @param directory string? by default searches everywhere
--- @return boolean # true if the operation was successful, false otherwise
function parse.readFileText(file, directory)end

--Stops parsing and frees any allocated resources.
--- @function parse.stop(): boolean
--- @return boolean # true if the operation was successful, false otherwise
function parse.stop()end

--Displays a message dialog which includes the current file name and line number. If <i>error</i> is set the message will be displayed as an error.
--- @function parse.displayMessage(message: string, error: boolean): boolean
--- @param message string 
--- @param error boolean? 
--- @return boolean # true if the operation was successful, false otherwise
function parse.displayMessage(message, error)end

--Search for specified string, skipping everything up to that point.
--- @function parse.skipToString(token: string): boolean
--- @param token string 
--- @return boolean # true if the operation was successful, false otherwise
function parse.skipToString(token)end

--Require that a string appears at the current position.
--- @function parse.requiredString(token: string): boolean
--- @param token string 
--- @return boolean # true if the operation was successful, false otherwise
function parse.requiredString(token)end

--Check if the string appears at the current position in the file.
--- @function parse.optionalString(token: string): boolean
--- @param token string 
--- @return boolean # true if the token is present, false otherwise
function parse.optionalString(token)end

--Gets a single line of text from the file
--- @function parse.getString(): string
--- @return string # Text or nil on error
function parse.getString()end

--Gets a floating point number from the file
--- @function parse.getFloat(): string
--- @return string # number or nil on error
function parse.getFloat()end

--Gets an integer number from the file
--- @function parse.getInt(): string
--- @return string # number or nil on error
function parse.getInt()end

--Gets a boolean value from the file
--- @function parse.getBoolean(): boolean
--- @return boolean # boolean value or nil on error
function parse.getBoolean()end

-- Tables: Tables library
tb = {}
--- @class Tables
--- @field tb.DecalOptionActive boolean Gets or sets whether the decal option is active (note, decals will only work if the decal system is able to work on the current machine) true if active, false if inactive
--Returns whether the decal system is able to work on the current machine
--- @function tb.isDecalSystemActive(): boolean
--- @return boolean # true if active, false if inactive
function tb.isDecalSystemActive()end

-- Testing: Experimental or testing stuff
ts = {}
--- @class Testing
--Opens an audio stream of the specified in-memory file contents and type.
--- @function ts.openAudioStreamMem(snddata: string, stream_type: enumeration): audio_stream
--- @param snddata string 
--- @param stream_type enumeration AUDIOSTREAM_* values
--- @return audio_stream # A handle to the opened stream or invalid on error
function ts.openAudioStreamMem(snddata, stream_type)end

--Test the AVD Physics code
--- @function ts.avdTest(): nothing
--- @return nil
function ts.avdTest()end

--Creates a particle. Use PARTICLE_* enumerations for type.Reverse reverse animation, if one is specifiedAttached object specifies object that Position will be (and always be) relative to.
--- @function ts.createParticle(Position: vector, Velocity: vector, Lifetime: number, Radius: number, Type: enumeration, TracerLength: number, Reverse: boolean, Texture: texture, AttachedObject: object): particle
--- @param Position vector 
--- @param Velocity vector 
--- @param Lifetime number 
--- @param Radius number 
--- @param Type enumeration 
--- @param TracerLength number? 
--- @param Reverse boolean? 
--- @param Texture texture? 
--- @param AttachedObject object? 
--- @return particle # Handle to the created particle
function ts.createParticle(Position, Velocity, Lifetime, Radius, Type, TracerLength, Reverse, Texture, AttachedObject)end

--Generates an ADE stackdump
--- @function ts.getStack(): string
--- @return string # Current Lua stack
function ts.getStack()end

--Returns whether current player is a multiplayer pilot or not.
--- @function ts.isCurrentPlayerMulti(): boolean
--- @return boolean # Whether current player is a multiplayer pilot or not
function ts.isCurrentPlayerMulti()end

--Returns whether PXO is currently enabled in the configuration.
--- @function ts.isPXOEnabled(): boolean
--- @return boolean # Whether PXO is enabled or not
function ts.isPXOEnabled()end

--Forces a cutscene by the specified filename string to play. Should really only be used in a non-gameplay state (i.e. start of GS_STATE_BRIEFING) otherwise odd side effects may occur. Highly Experimental.
--- @function ts.playCutscene(): string
--- @return string
function ts.playCutscene()end

-- Time: Real-Time library
time = {}
--- @class Time
--Gets the current real-time timestamp, i.e. the actual elapsed time, regardless of whether the game has changed time compression or been paused.
--- @function time.getCurrentTime(): timestamp
--- @return timestamp # The current time
function time.getCurrentTime()end

--Gets the current mission-time timestamp, which can be affected by time compression and paused.
--- @function time.getCurrentMissionTime(): timestamp
--- @return timestamp # The current mission time
function time.getCurrentMissionTime()end

-- Unicode: Functions for handling UTF-8 encoded unicode strings
utf8 = {}
--- @class Unicode
--This function is similar to the standard library string.sub but this can operate on UTF-8 encoded unicode strings. This function will respect the unicode mode setting of the current mod so you can use it even if you don't use Unicode strings.
--- @function utf8.sub(arg: string, start: number, endVal: number): string
--- @param arg string 
--- @param start number 
--- @param endVal number? 
--- @return string # The requestd substring
function utf8.sub(arg, start, endVal)end

--Determines the number of codepoints in the given string. This respects the unicode mode setting of the mod.
--- @function utf8.len(arg: string): number
--- @param arg string 
--- @return number # The number of code points in the string.
function utf8.len(arg)end

-- UserInterface: Functions for managing the "SCPUI" user interface system.
ui = {}
--- @class UserInterface
--- @field ui.ColorTags table<string, color> The available tagged colors A mapping from tag string to color value
--Sets the offset from the top left corner at which <b>all</b> rocket contexts will be rendered
--- @function ui.setOffset(x: number, y: number): boolean
--- @param x number 
--- @param y number 
--- @return boolean # true if the operation was successful, false otherwise
function ui.setOffset(x, y)end

--Enables input for the specified libRocket context
--- @function ui.enableInput(context: any): boolean
--- @param context any A libRocket Context value
--- @return boolean # true if successful
function ui.enableInput(context)end

--Disables UI input
--- @function ui.disableInput(): boolean
--- @return boolean # true if successful
function ui.disableInput()end

--Gets the default color tag string for the specified state. 1 for Briefing, 2 for CBriefing, 3 for Debriefing, 4 for Fiction Viewer, 5 for Red Alert, 6 for Loop Briefing, 7 for Recommendation text. Defaults to 1. Index into ColorTags.
--- @function ui.DefaultTextColorTag(UiScreen: number): string
--- @param UiScreen number 
--- @return string # The default color tag
function ui.DefaultTextColorTag(UiScreen)end

--Plays an element specific sound with an optional state for differentiating different UI states.
--- @function ui.playElementSound(element: any, event: string, state: string): boolean
--- @param element any A libRocket element
--- @param event string 
--- @param state string? 
--- @return boolean # true if a sound was played, false otherwise
function ui.playElementSound(element, event, state)end

--Plays a cutscene, if one exists, for the appropriate state transition.  If RestartMusic is true, then the music score at ScoreIndex will be started after the cutscene plays.
--- @function ui.maybePlayCutscene(MovieType: enumeration, RestartMusic: boolean, ScoreIndex: number): nothing
--- @param MovieType enumeration 
--- @param RestartMusic boolean 
--- @param ScoreIndex number 
--- @return nil # Returns nothing
function ui.maybePlayCutscene(MovieType, RestartMusic, ScoreIndex)end

--Plays a cutscene.  If RestartMusic is true, then the music score at ScoreIndex will be started after the cutscene plays.
--- @function ui.playCutscene(Filename: string, RestartMusic: boolean, ScoreIndex: number): nothing
--- @param Filename string 
--- @param RestartMusic boolean 
--- @param ScoreIndex number 
--- @return nil # Returns nothing
function ui.playCutscene(Filename, RestartMusic, ScoreIndex)end

--Checks if a cutscene is playing.
--- @function ui.isCutscenePlaying(): boolean
--- @return boolean # Returns true if cutscene is playing, false otherwise
function ui.isCutscenePlaying()end

--Launches the given URL in a web browser
--- @function ui.launchURL(url: string): nothing
--- @param url string 
--- @return nil
function ui.launchURL(url)end

--Links a texture directly to librocket.
--- @function ui.linkTexture(texture: texture): string
--- @param texture texture 
--- @return string # The url string for librocket, or an empty string if invalid.
function ui.linkTexture(texture)end

--
--
-- Enumerations
--- @const ALPHABLEND_FILTER # values shown here are dummy values
ALPHABLEND_FILTER = 0
--- @const ALPHABLEND_NONE # values shown here are dummy values
ALPHABLEND_NONE = 1
--- @const CFILE_TYPE_NORMAL # values shown here are dummy values
CFILE_TYPE_NORMAL = 2
--- @const CFILE_TYPE_MEMORY_MAPPED # values shown here are dummy values
CFILE_TYPE_MEMORY_MAPPED = 3
--- @const MOUSE_LEFT_BUTTON # values shown here are dummy values
MOUSE_LEFT_BUTTON = 4
--- @const MOUSE_RIGHT_BUTTON # values shown here are dummy values
MOUSE_RIGHT_BUTTON = 5
--- @const MOUSE_MIDDLE_BUTTON # values shown here are dummy values
MOUSE_MIDDLE_BUTTON = 6
--- @const MOUSE_X1_BUTTON # values shown here are dummy values
MOUSE_X1_BUTTON = 7
--- @const MOUSE_X2_BUTTON # values shown here are dummy values
MOUSE_X2_BUTTON = 8
--- @const FLIGHTMODE_FLIGHTCURSOR # values shown here are dummy values
FLIGHTMODE_FLIGHTCURSOR = 9
--- @const FLIGHTMODE_SHIPLOCKED # values shown here are dummy values
FLIGHTMODE_SHIPLOCKED = 10
--- @const ORDER_ATTACK # values shown here are dummy values
ORDER_ATTACK = 11
--- @const ORDER_ATTACK_ANY # values shown here are dummy values
ORDER_ATTACK_ANY = 12
--- @const ORDER_DEPART # values shown here are dummy values
ORDER_DEPART = 13
--- @const ORDER_DISABLE # values shown here are dummy values
ORDER_DISABLE = 14
--- @const ORDER_DISABLE_TACTICAL # values shown here are dummy values
ORDER_DISABLE_TACTICAL = 15
--- @const ORDER_DISARM # values shown here are dummy values
ORDER_DISARM = 16
--- @const ORDER_DISARM_TACTICAL # values shown here are dummy values
ORDER_DISARM_TACTICAL = 17
--- @const ORDER_DOCK # values shown here are dummy values
ORDER_DOCK = 18
--- @const ORDER_EVADE # values shown here are dummy values
ORDER_EVADE = 19
--- @const ORDER_FLY_TO # values shown here are dummy values
ORDER_FLY_TO = 20
--- @const ORDER_FORM_ON_WING # values shown here are dummy values
ORDER_FORM_ON_WING = 21
--- @const ORDER_GUARD # values shown here are dummy values
ORDER_GUARD = 22
--- @const ORDER_IGNORE_SHIP # values shown here are dummy values
ORDER_IGNORE_SHIP = 23
--- @const ORDER_IGNORE_SHIP_NEW # values shown here are dummy values
ORDER_IGNORE_SHIP_NEW = 24
--- @const ORDER_KEEP_SAFE_DISTANCE # values shown here are dummy values
ORDER_KEEP_SAFE_DISTANCE = 25
--- @const ORDER_PLAY_DEAD # values shown here are dummy values
ORDER_PLAY_DEAD = 26
--- @const ORDER_PLAY_DEAD_PERSISTENT # values shown here are dummy values
ORDER_PLAY_DEAD_PERSISTENT = 27
--- @const ORDER_REARM # values shown here are dummy values
ORDER_REARM = 28
--- @const ORDER_STAY_NEAR # values shown here are dummy values
ORDER_STAY_NEAR = 29
--- @const ORDER_STAY_STILL # values shown here are dummy values
ORDER_STAY_STILL = 30
--- @const ORDER_UNDOCK # values shown here are dummy values
ORDER_UNDOCK = 31
--- @const ORDER_WAYPOINTS # values shown here are dummy values
ORDER_WAYPOINTS = 32
--- @const ORDER_WAYPOINTS_ONCE # values shown here are dummy values
ORDER_WAYPOINTS_ONCE = 33
--- @const ORDER_ATTACK_WING # values shown here are dummy values
ORDER_ATTACK_WING = 34
--- @const ORDER_GUARD_WING # values shown here are dummy values
ORDER_GUARD_WING = 35
--- @const ORDER_ATTACK_SHIP_CLASS # values shown here are dummy values
ORDER_ATTACK_SHIP_CLASS = 36
--- @const PARTICLE_DEBUG # values shown here are dummy values
PARTICLE_DEBUG = 37
--- @const PARTICLE_BITMAP # values shown here are dummy values
PARTICLE_BITMAP = 38
--- @const PARTICLE_FIRE # values shown here are dummy values
PARTICLE_FIRE = 39
--- @const PARTICLE_SMOKE # values shown here are dummy values
PARTICLE_SMOKE = 40
--- @const PARTICLE_SMOKE2 # values shown here are dummy values
PARTICLE_SMOKE2 = 41
--- @const PARTICLE_PERSISTENT_BITMAP # values shown here are dummy values
PARTICLE_PERSISTENT_BITMAP = 42
--- @const SEXPVAR_CAMPAIGN_PERSISTENT # values shown here are dummy values
SEXPVAR_CAMPAIGN_PERSISTENT = 43
--- @const SEXPVAR_NOT_PERSISTENT # values shown here are dummy values
SEXPVAR_NOT_PERSISTENT = 44
--- @const SEXPVAR_PLAYER_PERSISTENT # values shown here are dummy values
SEXPVAR_PLAYER_PERSISTENT = 45
--- @const SEXPVAR_TYPE_NUMBER # values shown here are dummy values
SEXPVAR_TYPE_NUMBER = 46
--- @const SEXPVAR_TYPE_STRING # values shown here are dummy values
SEXPVAR_TYPE_STRING = 47
--- @const TEXTURE_STATIC # values shown here are dummy values
TEXTURE_STATIC = 48
--- @const TEXTURE_DYNAMIC # values shown here are dummy values
TEXTURE_DYNAMIC = 49
--- @const LOCK # values shown here are dummy values
LOCK = 50
--- @const UNLOCK # values shown here are dummy values
UNLOCK = 51
--- @const NONE # values shown here are dummy values
NONE = 52
--- @const SHIELD_FRONT # values shown here are dummy values
SHIELD_FRONT = 53
--- @const SHIELD_LEFT # values shown here are dummy values
SHIELD_LEFT = 54
--- @const SHIELD_RIGHT # values shown here are dummy values
SHIELD_RIGHT = 55
--- @const SHIELD_BACK # values shown here are dummy values
SHIELD_BACK = 56
--- @const MISSION_REPEAT # values shown here are dummy values
MISSION_REPEAT = 57
--- @const NORMAL_CONTROLS # values shown here are dummy values
NORMAL_CONTROLS = 58
--- @const LUA_STEERING_CONTROLS # values shown here are dummy values
LUA_STEERING_CONTROLS = 59
--- @const LUA_FULL_CONTROLS # values shown here are dummy values
LUA_FULL_CONTROLS = 60
--- @const NORMAL_BUTTON_CONTROLS # values shown here are dummy values
NORMAL_BUTTON_CONTROLS = 61
--- @const LUA_ADDITIVE_BUTTON_CONTROL # values shown here are dummy values
LUA_ADDITIVE_BUTTON_CONTROL = 62
--- @const LUA_OVERRIDE_BUTTON_CONTROL # values shown here are dummy values
LUA_OVERRIDE_BUTTON_CONTROL = 63
--- @const VM_INTERNAL # values shown here are dummy values
VM_INTERNAL = 64
--- @const VM_EXTERNAL # values shown here are dummy values
VM_EXTERNAL = 65
--- @const VM_TRACK # values shown here are dummy values
VM_TRACK = 66
--- @const VM_DEAD_VIEW # values shown here are dummy values
VM_DEAD_VIEW = 67
--- @const VM_CHASE # values shown here are dummy values
VM_CHASE = 68
--- @const VM_OTHER_SHIP # values shown here are dummy values
VM_OTHER_SHIP = 69
--- @const VM_CAMERA_LOCKED # values shown here are dummy values
VM_CAMERA_LOCKED = 70
--- @const VM_WARP_CHASE # values shown here are dummy values
VM_WARP_CHASE = 71
--- @const VM_PADLOCK_UP # values shown here are dummy values
VM_PADLOCK_UP = 72
--- @const VM_PADLOCK_REAR # values shown here are dummy values
VM_PADLOCK_REAR = 73
--- @const VM_PADLOCK_LEFT # values shown here are dummy values
VM_PADLOCK_LEFT = 74
--- @const VM_PADLOCK_RIGHT # values shown here are dummy values
VM_PADLOCK_RIGHT = 75
--- @const VM_WARPIN_ANCHOR # values shown here are dummy values
VM_WARPIN_ANCHOR = 76
--- @const VM_TOPDOWN # values shown here are dummy values
VM_TOPDOWN = 77
--- @const VM_FREECAMERA # values shown here are dummy values
VM_FREECAMERA = 78
--- @const VM_CENTERING # values shown here are dummy values
VM_CENTERING = 79
--- @const MESSAGE_PRIORITY_LOW # values shown here are dummy values
MESSAGE_PRIORITY_LOW = 80
--- @const MESSAGE_PRIORITY_NORMAL # values shown here are dummy values
MESSAGE_PRIORITY_NORMAL = 81
--- @const MESSAGE_PRIORITY_HIGH # values shown here are dummy values
MESSAGE_PRIORITY_HIGH = 82
--- @const OPTION_TYPE_SELECTION # values shown here are dummy values
OPTION_TYPE_SELECTION = 83
--- @const OPTION_TYPE_RANGE # values shown here are dummy values
OPTION_TYPE_RANGE = 84
--- @const AUDIOSTREAM_EVENTMUSIC # values shown here are dummy values
AUDIOSTREAM_EVENTMUSIC = 85
--- @const AUDIOSTREAM_MENUMUSIC # values shown here are dummy values
AUDIOSTREAM_MENUMUSIC = 86
--- @const AUDIOSTREAM_VOICE # values shown here are dummy values
AUDIOSTREAM_VOICE = 87
--- @const CONTEXT_VALID # values shown here are dummy values
CONTEXT_VALID = 88
--- @const CONTEXT_SUSPENDED # values shown here are dummy values
CONTEXT_SUSPENDED = 89
--- @const CONTEXT_INVALID # values shown here are dummy values
CONTEXT_INVALID = 90
--- @const FIREBALL_MEDIUM_EXPLOSION # values shown here are dummy values
FIREBALL_MEDIUM_EXPLOSION = 91
--- @const FIREBALL_LARGE_EXPLOSION # values shown here are dummy values
FIREBALL_LARGE_EXPLOSION = 92
--- @const FIREBALL_WARP_EFFECT # values shown here are dummy values
FIREBALL_WARP_EFFECT = 93
--- @const GR_RESIZE_NONE # values shown here are dummy values
GR_RESIZE_NONE = 94
--- @const GR_RESIZE_FULL # values shown here are dummy values
GR_RESIZE_FULL = 95
--- @const GR_RESIZE_FULL_CENTER # values shown here are dummy values
GR_RESIZE_FULL_CENTER = 96
--- @const GR_RESIZE_MENU # values shown here are dummy values
GR_RESIZE_MENU = 97
--- @const GR_RESIZE_MENU_ZOOMED # values shown here are dummy values
GR_RESIZE_MENU_ZOOMED = 98
--- @const GR_RESIZE_MENU_NO_OFFSET # values shown here are dummy values
GR_RESIZE_MENU_NO_OFFSET = 99
--- @const OS_NONE # values shown here are dummy values
OS_NONE = 100
--- @const OS_MAIN # values shown here are dummy values
OS_MAIN = 101
--- @const OS_ENGINE # values shown here are dummy values
OS_ENGINE = 102
--- @const OS_TURRET_BASE_ROTATION # values shown here are dummy values
OS_TURRET_BASE_ROTATION = 103
--- @const OS_TURRET_GUN_ROTATION # values shown here are dummy values
OS_TURRET_GUN_ROTATION = 104
--- @const OS_SUBSYS_ALIVE # values shown here are dummy values
OS_SUBSYS_ALIVE = 105
--- @const OS_SUBSYS_DEAD # values shown here are dummy values
OS_SUBSYS_DEAD = 106
--- @const OS_SUBSYS_DAMAGED # values shown here are dummy values
OS_SUBSYS_DAMAGED = 107
--- @const OS_SUBSYS_ROTATION # values shown here are dummy values
OS_SUBSYS_ROTATION = 108
--- @const OS_PLAY_ON_PLAYER # values shown here are dummy values
OS_PLAY_ON_PLAYER = 109
--- @const OS_LOOPING_DISABLED # values shown here are dummy values
OS_LOOPING_DISABLED = 110
--- @const MOVIE_PRE_FICTION # values shown here are dummy values
MOVIE_PRE_FICTION = 111
--- @const MOVIE_PRE_CMD_BRIEF # values shown here are dummy values
MOVIE_PRE_CMD_BRIEF = 112
--- @const MOVIE_PRE_BRIEF # values shown here are dummy values
MOVIE_PRE_BRIEF = 113
--- @const MOVIE_PRE_GAME # values shown here are dummy values
MOVIE_PRE_GAME = 114
--- @const MOVIE_PRE_DEBRIEF # values shown here are dummy values
MOVIE_PRE_DEBRIEF = 115
--- @const MOVIE_POST_DEBRIEF # values shown here are dummy values
MOVIE_POST_DEBRIEF = 116
--- @const MOVIE_END_CAMPAIGN # values shown here are dummy values
MOVIE_END_CAMPAIGN = 117
--- @const TBOX_FLASH_NAME # values shown here are dummy values
TBOX_FLASH_NAME = 118
--- @const TBOX_FLASH_CARGO # values shown here are dummy values
TBOX_FLASH_CARGO = 119
--- @const TBOX_FLASH_HULL # values shown here are dummy values
TBOX_FLASH_HULL = 120
--- @const TBOX_FLASH_STATUS # values shown here are dummy values
TBOX_FLASH_STATUS = 121
--- @const TBOX_FLASH_SUBSYS # values shown here are dummy values
TBOX_FLASH_SUBSYS = 122
--- @const LUAAI_ACHIEVABLE # values shown here are dummy values
LUAAI_ACHIEVABLE = 123
--- @const LUAAI_NOT_YET_ACHIEVABLE # values shown here are dummy values
LUAAI_NOT_YET_ACHIEVABLE = 124
--- @const LUAAI_UNACHIEVABLE # values shown here are dummy values
LUAAI_UNACHIEVABLE = 125
--- @const SCORE_BRIEFING # values shown here are dummy values
SCORE_BRIEFING = 126
--- @const SCORE_DEBRIEFING_SUCCESS # values shown here are dummy values
SCORE_DEBRIEFING_SUCCESS = 127
--- @const SCORE_DEBRIEFING_AVERAGE # values shown here are dummy values
SCORE_DEBRIEFING_AVERAGE = 128
--- @const SCORE_DEBRIEFING_FAILURE # values shown here are dummy values
SCORE_DEBRIEFING_FAILURE = 129
--- @const SCORE_FICTION_VIEWER # values shown here are dummy values
SCORE_FICTION_VIEWER = 130
--- @const INVALID # values shown here are dummy values
INVALID = 131
--- @const NOT_YET_PRESENT # values shown here are dummy values
NOT_YET_PRESENT = 132
--- @const PRESENT # values shown here are dummy values
PRESENT = 133
--- @const DEATH_ROLL # values shown here are dummy values
DEATH_ROLL = 134
--- @const EXITED # values shown here are dummy values
EXITED = 135
--- @const DC_IS_HULL # values shown here are dummy values
DC_IS_HULL = 136
--- @const DC_VAPORIZE # values shown here are dummy values
DC_VAPORIZE = 137
--- @const DC_SET_VELOCITY # values shown here are dummy values
DC_SET_VELOCITY = 138
--- @const DC_FIRE_HOOK # values shown here are dummy values
DC_FIRE_HOOK = 139
--- @const RPC_SERVER # values shown here are dummy values
RPC_SERVER = 140
--- @const RPC_CLIENTS # values shown here are dummy values
RPC_CLIENTS = 141
--- @const RPC_BOTH # values shown here are dummy values
RPC_BOTH = 142
--- @const RPC_RELIABLE # values shown here are dummy values
RPC_RELIABLE = 143
--- @const RPC_ORDERED # values shown here are dummy values
RPC_ORDERED = 144
--- @const RPC_UNRELIABLE # values shown here are dummy values
RPC_UNRELIABLE = 145
--- @const HOTKEY_LINE_NONE # values shown here are dummy values
HOTKEY_LINE_NONE = 146
--- @const HOTKEY_LINE_HEADING # values shown here are dummy values
HOTKEY_LINE_HEADING = 147
--- @const HOTKEY_LINE_WING # values shown here are dummy values
HOTKEY_LINE_WING = 148
--- @const HOTKEY_LINE_SHIP # values shown here are dummy values
HOTKEY_LINE_SHIP = 149
--- @const HOTKEY_LINE_SUBSHIP # values shown here are dummy values
HOTKEY_LINE_SUBSHIP = 150
--- @const SCROLLBACK_SOURCE_COMPUTER # values shown here are dummy values
SCROLLBACK_SOURCE_COMPUTER = 151
--- @const SCROLLBACK_SOURCE_TRAINING # values shown here are dummy values
SCROLLBACK_SOURCE_TRAINING = 152
--- @const SCROLLBACK_SOURCE_HIDDEN # values shown here are dummy values
SCROLLBACK_SOURCE_HIDDEN = 153
--- @const SCROLLBACK_SOURCE_IMPORTANT # values shown here are dummy values
SCROLLBACK_SOURCE_IMPORTANT = 154
--- @const SCROLLBACK_SOURCE_FAILED # values shown here are dummy values
SCROLLBACK_SOURCE_FAILED = 155
--- @const SCROLLBACK_SOURCE_SATISFIED # values shown here are dummy values
SCROLLBACK_SOURCE_SATISFIED = 156
--- @const SCROLLBACK_SOURCE_COMMAND # values shown here are dummy values
SCROLLBACK_SOURCE_COMMAND = 157
--- @const SCROLLBACK_SOURCE_NETPLAYER # values shown here are dummy values
SCROLLBACK_SOURCE_NETPLAYER = 158
--- @const MULTI_TYPE_COOP # values shown here are dummy values
MULTI_TYPE_COOP = 159
--- @const MULTI_TYPE_TEAM # values shown here are dummy values
MULTI_TYPE_TEAM = 160
--- @const MULTI_TYPE_DOGFIGHT # values shown here are dummy values
MULTI_TYPE_DOGFIGHT = 161
--- @const MULTI_TYPE_SQUADWAR # values shown here are dummy values
MULTI_TYPE_SQUADWAR = 162
--- @const MULTI_OPTION_RANK # values shown here are dummy values
MULTI_OPTION_RANK = 163
--- @const MULTI_OPTION_LEAD # values shown here are dummy values
MULTI_OPTION_LEAD = 164
--- @const MULTI_OPTION_ANY # values shown here are dummy values
MULTI_OPTION_ANY = 165
--- @const MULTI_OPTION_HOST # values shown here are dummy values
MULTI_OPTION_HOST = 166
--- @const MULTI_GAME_TYPE_OPEN # values shown here are dummy values
MULTI_GAME_TYPE_OPEN = 167
--- @const MULTI_GAME_TYPE_PASSWORD # values shown here are dummy values
MULTI_GAME_TYPE_PASSWORD = 168
--- @const MULTI_GAME_TYPE_RANK_ABOVE # values shown here are dummy values
MULTI_GAME_TYPE_RANK_ABOVE = 169
--- @const MULTI_GAME_TYPE_RANK_BELOW # values shown here are dummy values
MULTI_GAME_TYPE_RANK_BELOW = 170
--- @const SEXP_TRUE # values shown here are dummy values
SEXP_TRUE = 171
--- @const SEXP_FALSE # values shown here are dummy values
SEXP_FALSE = 172
--- @const SEXP_KNOWN_FALSE # values shown here are dummy values
SEXP_KNOWN_FALSE = 173
--- @const SEXP_KNOWN_TRUE # values shown here are dummy values
SEXP_KNOWN_TRUE = 174
--- @const SEXP_UNKNOWN # values shown here are dummy values
SEXP_UNKNOWN = 175
--- @const SEXP_NAN # values shown here are dummy values
SEXP_NAN = 176
--- @const SEXP_NAN_FOREVER # values shown here are dummy values
SEXP_NAN_FOREVER = 177
--- @const SEXP_CANT_EVAL # values shown here are dummy values
SEXP_CANT_EVAL = 178
--- @const COMMIT_SUCCESS # values shown here are dummy values
COMMIT_SUCCESS = 179
--- @const COMMIT_FAIL # values shown here are dummy values
COMMIT_FAIL = 180
--- @const COMMIT_PLAYER_NO_WEAPONS # values shown here are dummy values
COMMIT_PLAYER_NO_WEAPONS = 181
--- @const COMMIT_NO_REQUIRED_WEAPON # values shown here are dummy values
COMMIT_NO_REQUIRED_WEAPON = 182
--- @const COMMIT_NO_REQUIRED_WEAPON_MULTIPLE # values shown here are dummy values
COMMIT_NO_REQUIRED_WEAPON_MULTIPLE = 183
--- @const COMMIT_BANK_GAP_ERROR # values shown here are dummy values
COMMIT_BANK_GAP_ERROR = 184
--- @const COMMIT_PLAYER_NO_SLOT # values shown here are dummy values
COMMIT_PLAYER_NO_SLOT = 185
--- @const COMMIT_MULTI_PLAYERS_NO_SHIPS # values shown here are dummy values
COMMIT_MULTI_PLAYERS_NO_SHIPS = 186
--- @const COMMIT_MULTI_NOT_ALL_ASSIGNED # values shown here are dummy values
COMMIT_MULTI_NOT_ALL_ASSIGNED = 187
--- @const COMMIT_MULTI_NO_PRIMARY # values shown here are dummy values
COMMIT_MULTI_NO_PRIMARY = 188
--- @const COMMIT_MULTI_NO_SECONDARY # values shown here are dummy values
COMMIT_MULTI_NO_SECONDARY = 189
--
