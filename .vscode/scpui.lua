--- SCPUI Meta File
--- Comprehensive Definitions for Lua Integration
---@meta

--- Preload Coroutine
--- @class preload_coroutine
--- @field Priority number 1 to run this coroutine during splash 1 and 2 for splash 2
--- @field DebugMessage string The string message to print to the debug log when this coroutine rus
--- @field DebugString string The string message to display on the splash screen when this coroutine runs
--- @field FunctionString string the function to run with lua's loadstring method

--- SCPUI Medal Info
--- @class medal_info
--- @field AltBitmap? string the alternate bitmap filename
--- @field AltDebriefBitmap? string the alternate debrief bitmap filename
--- @field X? number the x position of the medal
--- @field Y? number the y position of the medal
--- @field W? number the width of the medal

--- SCPUI RGB Color
--- @class scpui_color
--- @field R number The red value of the color
--- @field G number The green value of the color
--- @field B number The blue value of the color

--- SCPUI Ribbon Stripe
--- @class scpui_ribbon_stripe
--- @field R number The red value of the color
--- @field G number The green value of the color
--- @field B number The blue value of the color
--- @field P number The position of the stripe

--- SCPUI Ribbon Info
--- @class ribbon_info
--- @field Name string The name of the ribbon
--- @field Description string The description of the ribbon
--- @field Source string The source of the ribbon
--- @field Border scpui_color The border color of the ribbon
--- @field Stripes_List scpui_ribbon_stripe[] The stripe colors of the ribbon

--- SCPUI UI Replacements
--- @class ui_replacement
--- @field Markup string The document to use to load
--- @field Document? Document The document object to use for this replacement

--- SCPUI State Init Values
--- @class state_init_values
--- @field Debrief boolean
--- @field Select boolean
--- @field LoadScreen boolean
--- @field PreLoad boolean

--- SCPUI Ship Icon Size
--- @class ship_icon_size
--- @field Width number the width of the ship icon
--- @field Height number the height of the ship icon

--- SCPUI Weapon Icon Size
--- @class weapon_icon_size
--- @field Width number the width of the weapon icon
--- @field Height number the height of the weapon icon

---- SCPUI Icon Dimensions
--- @class icon_dimensions
--- @field ship ship_icon_size the size of the ship icon
--- @field weapon weapon_icon_size the size of the weapon icon

--- SCPUI Dialog Abort method
--- @class dialog_abort
--- @field Abort? function The abort function for the dialog

--- SCPUI Dialog Methods
--- @class dialog_method
--- @field Abort? dialog_abort A callback function for if the dialog is aborted
--- @field Submit? number|string A callback function that should be called if the popup resolves. Should be string only if it is an input popup. Pass nil to abort.

--- SCPUI.tbl values
--- @class table_values
--- @field DisableInMulti boolean True if SCPUI should render in multiplayer, false otherwise
--- @field HideMulti boolean True if SCPUI should hide multiplayer menus and options, false otherwise
--- @field DataSaverMultiplier integer A numeric multiplier used to generate SCPUI's save data hash. Generally this is not needed but can be useful if there are conflicts between mods.
--- @field DatabaseShowNew boolean True if SCPUI should show the "NEW!" text in the database, false otherwise
--- @field IconDimensions icon_dimensions The dimensions of the icons used in ship and weapon select

--- SCPUI Loadout Icon
--- @class loadout_icon
--- @field Width number The width of the icon
--- @field Height number The height of the icon
--- @field Icon string[] The icon png blob array. Index is the frame number. 1 is plain, 2 full color mouseover, 3 full color highlighted, 4 orange dragged, 5 grey locked, 6 highlighted locked

--- SCPUI Ship Loadout Info Struct
--- @class ship_loadout_info
--- @field Index integer The index of the ship in the ship in Ship Classes
--- @field Amount integer The amount of the ship available in the loadout
--- @field Icon string The icon filename for the ship class
--- @field Overhead string The overhead filename for the ship class
--- @field Anim string The animation filename for the ship class
--- @field Name string The name of the ship
--- @field Type string The name of the ship class
--- @field Length string The length of the ship as a string
--- @field AfterburnerVelocity string The afterburner velocity of the ship as a string
--- @field Maneuverability string The maneuverability of the ship as a string
--- @field Armor string The armor of the ship as a string
--- @field GunMounts string The gun mounts of the ship as a string
--- @field MissileBanks string The missile banks of the ship as a string
--- @field Manufacturer string The manufacturer of the ship as a string
--- @field Hitpoints number The hitpoints of the ship
--- @field ShieldHitpoints number The shield hitpoints of the ship
--- @field Key string The key for the ship in the ship pool
--- @field GeneratedWidth number The width of the ship icon
--- @field GeneratedHeight number The height of the ship icon
--- @field GeneratedIcon string[] The icon png blob array. Index is the frame number. 1 is plain, 2 full color mouseover, 3 full color highlighted, 4 orange dragged, 5 grey locked, 6 highlighted locked

--- SCPUI Weapon Loadout Info Struct
--- @class weapon_loadout_info
--- @field Index integer The index of the weapon in the weapon in Weapon Classes
--- @field Amount integer The amount of the weapon available in the loadout
--- @field Icon string The icon filename for the weapon class
--- @field Anim string The animation filename for the weapon class
--- @field Name string The name of the weapon
--- @field Title string The display name of the weapon class
--- @field Description string The description of the weapon class
--- @field FireWait number The fire wait of the weapon
--- @field Type string The type of the weapon, usually "primary" or "secondary"
--- @field Key string The key for the weapon in the weapon pool
--- @field GeneratedWidth number The width of the weapon icon
--- @field GeneratedHeight number The height of the weapon icon
--- @field GeneratedIcon string[] The icon png blob array. Index is the frame number. 1 is plain, 2 full color mouseover, 3 full color highlighted, 4 orange dragged, 5 grey locked, 6 highlighted locked

--- SCPUI Loadout Slot Struct
--- @class loadout_slot
--- @field Name string The name of the ship in the slot
--- @field DisplayName string The display name of the ship in the slot
--- @field ShipClassIndex integer The index of the ship class
--- @field Weapons_List integer[] The indices of the weapon classes
--- @field Amounts_List integer[] The amounts of the weapon classes
--- @field IsDisabled boolean True if the slot is disabled, false otherwise
--- @field IsFilled boolean True if the slot is filled, false otherwise
--- @field IsWeaponLocked boolean True if the slot is weapon locked, false otherwise
--- @field IsShipLocked boolean True if the slot is ship locked, false otherwise
--- @field WingSlot number The wing slot number
--- @field DisplayWingName string The display name of the wing slot
--- @field Wing number The wing number
--- @field IsPlayer boolean True if the slot is a player's ship, false otherwise
--- @field WingName string The name of the wing

--- SCPUI Saved Loadout Struct
--- @class saved_loadout
--- @field Version number The version of loadout handler that saved the loadout
--- @field DateTime string The date time of the mission the loadout is saved for
--- @field Ship_Pool integer[] The amount of ships available in the loadout. Index is the ship class index, value is the amount of ships available
--- @field Weapon_Pool integer[] The amount of weapons available in the loadout. Index is the weapon class index, value is the amount of weapons available
--- @field Loadout_Slots loadout_slot[] The slots for the loadout
--- @field NumShipClasses integer The number of ship classes in the game at the time the loadout was saved
--- @field NumWepClasses integer The number of weapon classes in the game at the time the loadout was saved

--- SCPUI Loadout information
--- @class loadout_info
--- @field Ship_Pool? integer[] The amount of ships available in the loadout. Index is the ship class index, value is the amount of ships available
--- @field Weapon_Pool? integer[] The amount of weapons available in the loadout. Index is the weapon class index, value is the amount of weapons available
--- @field Loadout_Slots? loadout_slot[] The slots for the loadout
--- @field Ship_Info? ship_loadout_info[] The ship information for the loadout
--- @field Primary_Info? weapon_loadout_info[] The primary weapon information for the loadout
--- @field Secondary_Info? weapon_loadout_info[] The secondary weapon information for the loadout
--- @field EmptySlotIcon? string[] The empty wing slot frame URLs for the loadout
--- @field WING_SIZE? number The max wing size
--- @field MAX_PRIMARIES? number The max number of primary weapons on a ship
--- @field MAX_SECONDARIES? number The max number of secondary weapons on a ship

--- SCPUI Briefing Map Memory
--- @class briefing_map_memory
--- @field Texture? texture The texture to use for the briefing map
--- @field X1? number The x position of the first corner of the briefing map
--- @field Y1? number The y position of the first corner of the briefing map
--- @field X2? number The x position of the second corner of the briefing map
--- @field Y2? number The y position of the second corner of the briefing map
--- @field Url? string The string url of the texture that can be assigned to librocket element
--- @field Draw? boolean True if the briefing map should be drawn, false otherwise
--- @field RotationSpeed? number The rotation speed of the briefing map model
--- @field Goals? boolean True if the briefing has a goals stage, false otherwise
--- @field Bg? string The background image to use for the briefing map
--- @field Mx? number The x position of the mouse
--- @field My? number The y position of the mouse
--- @field Bx? number The x position of the model ship box
--- @field By? number The y position of the model ship box
--- @field Pof? string The pof file to render in the model ship box
--- @field CloseupZoom? number The zoom level for the model ship box
--- @field CloseupPos? vector The position of the model in the model ship box
--- @field Label? string The label to display in the model ship box
--- @field IconIdentifier? number The icon ID of the model ship box

--- SCPUI HUD Drawing Memory
--- @class hud_draw_memory
--- @field Draw? boolean True if the HUD should be drawn, false otherwise
--- @field Mx? number The x position of the mouse
--- @field My? number The y position of the mouse
--- @field Gauge? gauge_config The current gauge being hovered over

--- SCPUI Load Screen Memory
--- @class load_screen_memory
--- @field ImageTexture? texture The texture to use for the loading screen
--- @field Texture? texture The texture to use for the loading screen
--- @field Url? string The string url of the texture that can be assigned to librocket element
--- @field LastProgress? number The last progress value for the loading screen
--- @field LoadProgress? number The current loading progress value for the loading screen
--- @field LoopLoadBar? boolean True if the loading bar graphic should loop, false otherwise

--- SCPUI Medal Memory
--- @class medal_memory
--- @field Name string? The name of the medal
--- @field X number The x position of the text to draw
--- @field Y number The y position of the text to draw

--- SCPUI Multi Host Memory
--- @class multi_host_memory
--- @field MultiHostSetup? boolean True if the multi host setup is ready, false otherwise
--- @field HostFilter? enumeration The mission list filter type. One of the MUTLI_TYPE enumerations
--- @field HostList? string The mission list type

--- SCPUI Multi General Memory
--- @class multi_general_memory
--- @field DialogResponse? string The response from the dialog
--- @field DialogType? number The type of dialog that was shown. Should be one of the DIALOG_ enumerations
--- @field Context? any The context to use for running multiplayer network updates
--- @field RunNetwork? boolean True if the network should be run, false otherwise

--- SCPUI Control Config Memory
--- @class control_config_memory
--- @field Context? scpui_context The context for the control config
--- @field NextDialog? dialog_setup The next dialog to show
--- @field DialogResponse? number The response from the dialog

--- SCPUI Splash Screen Image
--- @class splash_image
--- @field A number The alpha value of the image
--- @field File string The filename of the image
--- @field H number The height of the image
--- @field W number The width of the image
--- @field X number The x position of the image
--- @field Y number The y position of the image

--- SCPUI Splash Screen Memory
--- @class splash_screen_memory
--- @field TD boolean True if the text should be drawn, false otherwise
--- @field Image_List? splash_image[] The images to display on the splash screen
--- @field Fade? number The fade time value for the splash screen
--- @field DebugString? string The debug string to display on the splash screen
--- @field Index integer The current splash index
--- @field Text string The text to display on the splash screen
--- @field TX number The x position of the text
--- @field TY number The y position of the text
--- @field TW number The width of the text
--- @field F number The font size of the text
--- @field DebugMessage? string The debug message to display on the splash screen

--- SCPUI Model Draw Memory
--- @class model_draw_memory
--- @field Start? boolean True to draw the model animation from the start
--- @field Class? integer The ship class index to draw
--- @field Element? Element The element to draw the model in
--- @field Section? string The type of model to draw in the tech room, usually "ship" or "weapon"
--- @field RotationSpeed? integer The rotation speed of the model
--- @field SavedIndex? integer A place to store the index of the model being rendered temporarily
--- @field Mx? integer The x position of the mouse
--- @field My? integer The y position of the mouse
--- @field Click? boolean True if the model has been clicked, false otherwise
--- @field Sx? integer The x position of the mouse when the model was clicked
--- @field Sy? integer The y position of the mouse when the model was clicked
--- @field Angle? number The angle of the model
--- @field Speed? number The speed multipler of the model rotation
--- @field ClickOrientation? orientation The orientation of the model when clicked
--- @field Weapons_List? integer[] The selected weapons table
--- @field Bank_Elements_List? Element[] The weapon bank elements
--- @field OverheadClass? integer The overhead class index
--- @field Hover? integer The current slot being hovered over with the mouse
--- @field OverheadElement? Element The overhead element
--- @field overheadEffect? number The overhead effect choice
--- @field OverheadSave? integer A place to store the index of the overhead model being rendered temporarily

--- SCPUI Global Memory
--- @class scpui_memory
--- @field Cutscene string The cutscene requested to be played by the tech room
--- @field CutscenePlayed? boolean? True if a cutscene has been played for the current game state, nil otherwise
--- @field MusicHandle? audio_stream? The handle for the current UI music, if any
--- @field CurrentMusicFile? string? The current music file being played, if any
--- @field LogSection integer The last mission log section the player viewed
--- @field MissionLoaded boolean True if a mission is loaded, false otherwise
--- @field MultiJoinReady boolean True if the multi join game is ready, false otherwise
--- @field MultiReady boolean True if the multi game is ready, false otherwise
--- @field AlertElement? Element The alert element to blink in the red alert screen
--- @field WarningCountShown boolean True if the warning count has been shown, false otherwise
--- @field briefing_map? briefing_map_memory The current briefing map memory for SCPUI
--- @field hud_config? hud_draw_memory The current HUD drawing memory for SCPUI
--- @field loading_bar? load_screen_memory The current loading screen memory for SCPUI
--- @field medal_text? medal_memory The current medal memory for SCPUI
--- @field splash_screen? splash_screen_memory The current splash screen memory for SCPUI
--- @field model_rendering? model_draw_memory The current model draw memory for SCPUI
--- @field multiplayer_host multi_host_memory The current multi host memory for SCPUI
--- @field control_config control_config_memory The current control config memory for SCPUI
--- @field multiplayer_general multi_general_memory The current multiplayer general memory for SCPUI

--- SCPUI Custom Options Data
--- @class custom_option_data
--- @field Brief_Render_Option? string The brief render option. "screen" to render directly to screen. "texture" to render to an intermediary texture and pass to librocket via url. Nil for default
--- @field Font_Adjustment? number The font adjustment value. 0.5 is default, 0 is smallest, 1 is largest. Nil for default
--- @field Database_Model_Angle? number The angle of the database model. 0.5 is default. Nil for default
--- @field Database_Model_Speed? number The speed of the database model rotation. 0.5 is default. Nil for default
--- @field Database_Sort_Method? string[] The sort type for the database; one for each of "ships", "weapons", and "intel".
--- @field Database_Category? string[] The category type for the database; one for each of "ships", "weapons", and "intel".
--- @field Sim_Room_Choice? integer The choice for the sim room. 1 = single, 2 = campaign in base SCPUI

--- SCPUI Global Documentation
--- @class scpui_data
--- @field Context? Context? The current context for SCPUI. Do Not Modify!
--- @field CurrentDoc ui_replacement? The currently loaded document, if any
--- @field LoadDoc ui_replacement? The document to to use during the loading screen, if any
--- @field Active boolean Whether or not SCPUI is active at all
--- @field NumFontSizes integer The number of font sizes available in the SCPUI system. Do Not Modify!
--- @field Replacements_List ui_replacement[] Table of Game states and their corresponding SCPUI documents. Key is the game state, value is a table with [markup] as the document name. This allows setting the current document to the value of the table which immediately sets the correct document to the current game state.
--- @field Backgrounds_List table<string, string> Table of campaign background replacement rcss classes. Key is the campaign filename, value is the rcss class name.
--- @field Brief_Backgrounds_List table<string, table<string, string>> This table is used to determine which background image to display during mission briefings. The structure: Outer keys: mission names (strings), Inner keys: either "default" (string) for the default background or a tring representation of a briefing stage number (e.g., "1", "2"), Values: filenames (strings).
--- @field Preload_Coroutines preload_coroutine[] The preload coroutines to run during SCPUI's splash screen startup.
--- @field Medal_Info medal_info[] The medal information for SCPUI to use when displaying medals.
--- @field CurrentState? gamestate The current game state SCPUI is in
--- @field LastState? gamestate The previous game state SCPUI was in
--- @field Substate string The current scripting substate. "none" if not in a scripting substate
--- @field OldSubstate string The previous scripting substate. "none" if not in a scripting substate
--- @field table_flags table_values The table values for SCPUI as defined in the scpui.tbl
--- @field state_init_status state_init_values SCPUI's array of state init values
--- @field memory scpui_memory The global memory for SCPUI. Often used to pass data between game states
--- @field Render boolean Whether or not SCPUI should render
--- @field DialogDoc? Document? The current dialog box document, if any
--- @field Tooltip_Timers table<string, number> The timers for the tooltips. Key is the tooltip name, value is the timer
--- @field DeathDialog? dialog_method The submit and abort functions for the death dialog
--- @field Dialog? dialog_method The submit and abort functions for the dialog
--- @field Loadout? loadout_info The loadout information for SCPUI
--- @field BackupLoadout? loadout_info The backup loadout information for SCPUI
--- @field Saved_Loadouts? saved_loadout[] The saved loadouts for SCPUI
--- @field Custom_Options? table The custom options for values
--- @field Player_Ribbons? ribbon_info[] The player ribbons for SCPUI
--- @field Generated_Icons? loadout_icon[] The rocket UI icons for SCPUI loadout screens
--- @field ScpuiOptionValues custom_option_data The values for the built-in SCPUI options
--- @field Reset? boolean True if SCPUI should regen the icons, false otherwise

--- SCPUI Dialog Button
--- @class dialog_button
--- @field Type integer The type of button to display, one of the dialog.BUTTON_TYPEs
--- @field Text string The text to display on the button
--- @field Value any The value to return when the button is clicked
--- @field Keypress? string The keypress to use for the button

--- SCPUI Dialog Factory
--- @class dialog_factory
--- @field TypeVal integer The type of dialog to create
--- @field Buttons_List dialog_button[] The buttons to display on the dialog
--- @field TitleString string The title of the dialog
--- @field TextString string The text of the dialog
--- @field InputChoice boolean True if the dialog should have an input choice, false otherwise
--- @field EscapeValue boolean? True if the dialog should have an escape value, false otherwise
--- @field ClickEscape boolean? True if the dialog should have a click escape, false otherwise
--- @field StyleValue? integer 1 for regular dialog, 2 for death dialog
--- @field BackgroundColor? string The background color of the dialog
--- @field type? fun(self: self, type: integer): self Sets the TypeVal
--- @field title? fun(self: self, title: string): self Sets the TitleString
--- @field text? fun(self: self, text: string): self Sets the TextString
--- @field button? fun(self: self, type: integer, text: string, value: any, keypress?: string): self Adds a button to the dialog
--- @field input? fun(self: self, input: boolean): self Sets the InputChoice
--- @field escape? fun(self: self, escape: any): self Sets the EscapeValue
--- @field clickescape? fun(self: self, clickEscape: boolean): self Sets the ClickEscape
--- @field style? fun(self: self, style: integer): self Sets the StyleValue
--- @field background? fun(self: self, color: string): self Sets the BackgroundColor
--- @field show? fun(self: self, context: Context, abortTable?: dialog_abort): promise The function to show the dialog
--- @field __index? dialog_factory The metatable for the dialog factory

--- SCPUI Dialog Setup
--- @class dialog_setup
--- @field Type? integer The type of dialog to create. Always 1
--- @field Buttons_List dialog_button[] The buttons to display on the dialog
--- @field Title string The title of the dialog
--- @field Text string The text of the dialog
--- @field Input boolean True if the dialog should have an input box, false otherwise
--- @field EscapeValue boolean? True if the dialog should have an escape value, false otherwise
--- @field ClickEscape boolean? True if the dialog should have a click escape, false otherwise
--- @field Style? integer 1 for regular dialog, 2 for death dialog
--- @field BackgroundColor? string The background color of the dialog

--- SCPUI Keywords table
--- @class scpui_keywords
--- @field Prefixes string[] The prefixes for the keywords
--- @field Suffixes string[] The suffixes for the keywords

--- SCPUI UI Context
--- @class scpui_context
--- @field Document Document The document for the context

--- SCPUI Briefing Element List
--- @class scpui_brief_element_list
--- @field PauseBtn string | nil The name of the pause button element
--- @field LastBtn string | nil The name of the last button element
--- @field NextBtn string | nil The name of the next button element
--- @field PrevBtn string | nil The name of the previous button element
--- @field FirstBtn string | nil The name of the first button element
--- @field TextEl string | nil The name of the text element
--- @field StageTextEl string | nil The name of the stage text element

--- SCPUI Campaign List
--- @class scpui_campaign
--- @field Name string The name of the campaign
--- @field Filename string The filename of the campaign
--- @field Description string The description of the campaign
--- @field Element Element | nil the element for the campaign list item

--- SCPUI Game Help Section
--- @class game_help_section : help_section
--- @field Subtitle string The subtitle of the section

--- SCPUI Hotkey Setting
--- @class scpui_hotkey_setting
--- @field Heading string The heading of the hotkey setting
--- @field Ships_List scpui_hotkey_ship_setting[] The ships hotkey settings

--- SCPUI Hotkey Ship Setting
--- @class scpui_hotkey_ship_setting
--- @field Text string The text of the hotkey setting
--- @field Type enumeration The type of hotkey setting, one of the HOTKEY_TYPE enumerations
--- @field Keys_List string[] The list of keys for the ship
--- @field Index integer The index of the hotkey into the hotkey list

--- SCPUI HUD Config Color
--- @class scpui_hud_config_color
--- @field Name string The name of the color
--- @field R integer The red value of the color
--- @field G integer The green value of the color
--- @field B integer The blue value of the color
--- @field A integer The alpha value of the color

--- SCPUI Multi Setup Player
--- @class scpui_multi_setup_player
--- @field Name string The name of the player
--- @field Team number The team of the player
--- @field Host boolean True if the player is the host, false otherwise
--- @field Observer boolean True if the player is an observer, false otherwise
--- @field Captain boolean True if the player is the captain, false otherwise
--- @field InternalId string The internal ID of the player for the UI
--- @field Index number The index of the player in the NetPlayers list
--- @field Entry net_player The net player entry for the player
--- @field State? string The current state of the player
--- @field Key? string The player element id

--- SCPUI Multi Setup Player
--- @class scpui_multi_setup_mission
--- @field Name string The name of the player
--- @field Filename string The filename of the mission
--- @field Players number The max number of players in the mission
--- @field Respawn number The respawn count limit
--- @field Tracker boolean The mission handle validity tracker
--- @field Type enumeration The mission type. One of the MULTI_TYPE enumerations
--- @field Builtin boolean True if the mission is a built-in Volition mission
--- @field InternalId string The internal ID of the mission for the UI
--- @field Index number The index of the mission in the network mission list
--- @field Entry net_campaign | net_mission The netgame info entry for the mission or campaign
--- @field Key? string The player element id

--- SCPUI Multi Active Game
--- @class scpui_multi_active_game
--- @field Status string The status of the game
--- @field Type string The type of the game
--- @field Speed string The speed of the game
--- @field Standalone boolean True if the game is standalone, false otherwise
--- @field Campaign boolean True if the game is a campaign, false otherwise
--- @field Server string The server of the game
--- @field Mission string The mission of the game
--- @field Ping number The ping of the game
--- @field Players number The number of players in the game
--- @field InternalId string The internal ID of the game for the UI
--- @field Index number The index of the game in the active games list
--- @field Key? string The game element id

--- SCPUI PXO Channel
--- @class scpui_pxo_channel
--- @field Name string The name of the channel
--- @field NumPlayers number The number of players in the channel
--- @field NumGames number The number of games in the channel
--- @field IsCurrent boolean True if the channel is the current channel, false otherwise
--- @field Key? string The channel element id

--- SCPUI PXO Chat Player
--- @class scpui_pxo_chat_player
--- @field Name string The name of the player
--- @field Key? string The player element id

--- SCPUI Custom Option
--- @class scpui_option : option
--- @field ValidValues? any[] The valid values for the option. Available for Custom Options only
--- @field DisplayNames? table<string, string> The display names for the option. Available for Custom Options only
--- @field HasDefault? boolean True if the option has no default, false otherwise. Available for Custom Options only
--- @field Value ValueDescription | string | number The value of the option. If the option is an FSO option this will be a ValueDescription else this will be a string or number.
--- @field Type enumeration | string The type of the option. If the option is an FSO option this will be an enumeration else this will be a string.
--- @field Max? number The maximum value of the option. Available for Custom Options only
--- @field Min? number The minimum value of the option. Available for Custom Options only
--- @field ForceSelector? boolean True if the option should force a selector, false otherwise. Available for Custom Options only

--- SCPUI Custom Option Control
--- @class scpui_option_control
--- @field Key string The key of the custom option
--- @field Type string The type of the custom option
--- @field DefaultValue any The default value of the custom option
--- @field CurrentValue any The current value of the custom option
--- @field SavedValue any The saved value of the custom option
--- @field IncrementValue any The increment value of the custom option
--- @field ParentEl Element The parent element of the custom option
--- @field Buttons? Element[] The button elements for the custom option
--- @field NumPoints? number The number of points for the custom option
--- @field Strings? string[] The display strings for the custom option
--- @field Range? number The range of the custom option
--- @field ValueEl? Element The value element of the custom option
--- @field SelectEl? ElementFormControlDataSelect The select element of the custom option
--- @field RangeEl? ElementFormControlInput The range element of the custom option
--- @field MaxValue? number The maximum value of the custom option
--- @field HasDefault boolean True if the custom option has no default, false otherwise
--- @field ValidValues? any[] The valid values for the option
--- @field DisplayNames? table<string, string> The display names for the option

--- SCPUI Graphics Option Control
--- @class scpui_graphics_option_control
--- @field Key string The key of the graphics option
--- @field Title? string The title of the graphics option
--- @field Type string The type of the graphics option
--- @field Option? option The option object for the graphics option
--- @field CurrentValue any The current value of the graphics option
--- @field SavedValue any The saved value of the graphics option
--- @field ValidValues any[] The valid values for the graphics option
--- @field ParentEl Element The parent ID of the graphics option
--- @field SelectEl? ElementFormControlDataSelect The select element of the custom option

--- SCPUI Option Data Source Wrapper
--- @class scpui_option_data_source
--- @field Option scpui_option The custom option for the data source
--- @field Values any[] The values of the custom option
--- @field Source DataSource The data source for the custom option
--- @field updateValues fun(self: self): nil The function to update the values of the custom option