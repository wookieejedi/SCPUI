--- Create the local JournalUi object
local JournalUi = {}

JournalUi.SectionEnum = nil --- @type LuaEnum the enum for a journal sections in the sexp operators
JournalUi.Enum_Lists = {} --- @type LuaEnum[] the enums for the journal entries in the sexp operators

--- Get the index for a specific section in a list of sections
--- @param section_name string the name of the section to find
--- @param sections scpui_journal_section the list of sections to search
--- @return number? index the index of the section in the list
function JournalUi:getGroupIndex(section_name, sections)

	section_name = string.lower(section_name)

	for i, v in ipairs(sections) do
		if string.lower(v.Name) == section_name then
			return i
		end
	end

	ba.error("Journal: Undefined group defined! Could not find " .. section_name .. " group! Add or check spelling!")

	return nil

end

--- Parse a journal table file
--- @param file string the file to parse
--- @param entriesonly? boolean whether to only parse the entries
--- @return scpui_journal_data data the parsed journal data
function JournalUi:parseJournalTable(file, entriesonly)

	---@type scpui_journal_data
	local newdata = {
		Visible_List = {},
		Section_List = {},
		Entry_List = {},
		Title = ba.XSTR("Journal", 888550),
	}

	if not parse.readFileText(file, "data/tables") then
		return newdata
	end

	if (not entriesonly) and parse.optionalString("#Journal Options") then
		if parse.optionalString("$Title:") then
			newdata.Title = parse.getString()
		end
		parse.requiredString("#End")
	end

	 if (not entriesonly) and parse.optionalString("#Journal Sections") then

		while parse.optionalString("$Name:") and (#newdata.Section_List < 3) do

			local t = {}

			t.Name = parse.getString()

			if parse.requiredString("$XSTR:") then
				t.Display = ba.XSTR(t.Name, parse.getInt())
			end

		newdata.Section_List[#newdata.Section_List+1] = t

		end

		parse.requiredString("#End")

	end

	if parse.optionalString("#Journal Entries") then

		while parse.optionalString("$Name:") do

			---@type scpui_journal_entry
			local t = {}
			local new_index

			t.Name = parse.getString()

			if parse.requiredString("$XSTR:") then
				t.Display = ba.XSTR(t.Name, parse.getInt())
			end

			if parse.requiredString("$Group:") then
				t.Group = parse.getString()
				t.GroupIndex = self:getGroupIndex(t.Group, newdata.Section_List)
			end

			if parse.optionalString("$Visible by Default:") then
				t.InitialVis = parse.getBoolean()
			else
				t.InitialVis = false
			end

			if parse.optionalString("$Short Title:") then
				t.Key = parse.getString()
			else
				t.Key = new_index
			end

			if parse.requiredString("$File:") then
				t.File = self:checkLanguage(parse.getString())
			end

			if parse.optionalString("$Image:") then
				t.Image = parse.getString()
			end

			if parse.optionalString("$Caption:") then
				local caption = parse.getString()
				if parse.requiredString("$Caption XSTR:") then
					t.Caption = ba.XSTR(caption, parse.getInt())
				end
			end

			if not newdata.Entry_List[t.GroupIndex] then newdata.Entry_List[t.GroupIndex] = {} end

			new_index = #newdata.Entry_List[t.GroupIndex] + 1

			--t.Name = newIndex .. " - " .. t.GroupIndex .. " - " .. t.Name

			newdata.Entry_List[t.GroupIndex][new_index] = t

		end

		parse.requiredString("#End")

	end

	parse.stop()

	return newdata

end

--- Check for a language specific file
--- @param filename string the file to check
--- @return string filename the filename to use
function JournalUi:checkLanguage(filename)

	local language = ba.getCurrentLanguageExtension()
	if language ~= "" then
		local langfile = filename:gsub(".txt", "") .. "-" .. language .. ".txt"
		if cf.fileExists(langfile, "data/fiction", true) then
			filename = langfile
		end
	end
	return filename

end

--These are only needed for FS2 and not FRED?

--- Load the journal data for the current player
--- @return scpui_journal_data? data the loaded journal data
function JournalUi:loadData()

	local player = ba.getCurrentPlayer()
	local campaign_filename = player:getCampaignFilename()

	self.Data = self:parseJournalTable(campaign_filename .. "-journal.tbl")

	if self.Data then
		self.SaveData = self:loadDataFromFile()
	end

end

--- Unload the journal data
--- @return nil
function JournalUi:unloadData()
	self.Data = nil
	self.SaveData = nil
end

--- Check if the journal table exists
--- @return boolean exists whether the journal table exists
function JournalUi:doesConfigExist()

	local player = ba.getCurrentPlayer()
	local campaign_filename = player:getCampaignFilename()

	if cf.fileExists(campaign_filename .. "-journal.tbl", "data/tables", true) then
		return true
	else
		return false
	end

end

--- Load the journal data from a file
--- @return table<number, scpui_journal_save_data[]> config the loaded journal data
function JournalUi:loadDataFromFile()

	local save_location = "journal_" .. ba.getCurrentPlayer():getCampaignFilename()
	local Datasaver = require("lib_data_saver")
	local config = Datasaver:loadDataFromFile(save_location, true)

	if config == nil then
		config = self:createSaveData()
		self:saveDataToFile(config)
	end

	return config

end

--- Clear the new flag for all entries and save it
--- @return nil
function JournalUi:clearNew()

	local t = {}

	local save_location = "journal_" .. ba.getCurrentPlayer():getCampaignFilename()
	local Datasaver = require("lib_data_saver")
	Datasaver:saveDataToFile(save_location, t, true)

end

--- Check if there are any new entries
--- @return boolean new whether there are new entries
function JournalUi:checkNew()
	local t = {}

	local config = self:loadDataFromFile()

	if config ~= nil then
		t = config
	else
		self:loadData()
		if self.Data then
			return true
		else
			return false
		end
	end

	for i = 1, #t do
		for j, v in ipairs(t[i]) do
			local item = t[i][j]
			if item and item.Visible == true and item.Unread == true then
				return true
			end
		end
	end

	return false

end

--- Create the journal save data
--- @return table<number, scpui_journal_save_data[]> t the created save data
function JournalUi:createSaveData()

	local t = {}

	if not self.Data then
		self:loadData()
	end

	for i, section in ipairs(self.Data.Entry_List) do

		if not t[i] then t[i] = {} end
		local save_section = t[i]

		for j, entry in ipairs(section) do

			if not save_section[j] then

				local t = {}
				t.Key = string.lower(entry.Key)
				t.Unread = true
				t.Visible = entry.InitialVis

				save_section[j] = t

			end

		end
	end

	ba.print("Journal UI: Initial save data created!")

	return t

end

--- Save the journal data to disk
--- @param t table<number, scpui_journal_save_data[]> the data to save
--- @return nil
function JournalUi:saveDataToFile(t)

	local save_location = "journal_" .. ba.getCurrentPlayer():getCampaignFilename()
	local Datasaver = require("lib_data_saver")
	Datasaver:saveDataToFile(save_location, t, true)

end

--- Lock a journal entry
--- @param section string the section to lock the entry in
--- @vararg string[] the key(s) of the entry to lock
--- @return nil
function JournalUi:lockEntry(section, ...)

	--load data
	self:loadData()
	--get section
	local section = self:getGroupIndex(section, self.Data.Section_List)
	--get key(s)
	for _, v in ipairs(arg) do
		for _, entry in ipairs(self.SaveData[section] or {}) do
			if string.lower(v[1] or v) == entry.Key then
				entry.Visible = false
				break
			end
		end
	end
	--save
	self:saveDataToFile(self.SaveData)
	--unload
	self:unloadData()

end

--- Unlock a journal entry
--- @param section string the section to unlock the entry in
--- @vararg string[] the key(s) of the entry to unlock
--- @return boolean unlocked whether the entry was unlocked
function JournalUi:unlockEntry(section, ...)
  local unlocked = false
	--load data
	self:loadData()
	--get section
	local section = self:getGroupIndex(section, self.Data.Section_List)
	--get key(s)
	for _, v in ipairs(arg) do
		for _, entry in ipairs(self.SaveData[section] or {}) do
			if string.lower(v[1] or v) == entry.Key then
        unlocked = not entry.Visible
				entry.Visible = true
				break
			end
		end
	end
	--save
	self:saveDataToFile(self.SaveData)
	--unload
	self:unloadData()
  return unlocked
end

--- Get the title of the journal UI
--- @return string title the title of the journal UI
function JournalUi:getTitle()
	local player = ba.getCurrentPlayer()
	local campaignfilename = player:getCampaignFilename()
	local data = self:parseJournalTable(campaignfilename .. "-journal.tbl")
	return data.Title
end

--- Clear all journal data and reset to default
--- @return nil
function JournalUi:clearAll()
	local config = self:createSaveData()
	self:saveDataToFile(config)
end

--- Now that we have the JournalUi object, we can add it to the ScpuiSystem
ScpuiSystem.extensions.JournalUi = JournalUi

mn.LuaSEXPs["lua-journal-unlock-article"].Action = function(section, ...)

	--Remove the first part of the parent enum name so we can unlock using the actual section name
	local function removeJournalPrefix(inputString)
		local prefix = "Journal "
		if string.sub(inputString, 1, #prefix) == prefix then
			return string.sub(inputString, #prefix + 1)
		else
			return inputString
		end
	end

	if mn.isInCampaign() then
		ScpuiSystem.extensions.JournalUi:unlockEntry(removeJournalPrefix(section), ...)
	end
end

--- If we're in FRED then create all the enums
if ba.inMissionEditor() then
    local journal_files = cf.listFiles("data/tables", "*journal.tbl")

    for _, v in pairs(journal_files) do
        local data = ScpuiSystem.extensions.JournalUi:parseJournalTable(v)

        if #data.Section_List > 0 then
            local name = "Journal Sections"
            ScpuiSystem.extensions.JournalUi.SectionEnum = mn.LuaEnums[name]
            ScpuiSystem.extensions.JournalUi.SectionEnum:removeEnumItem("<none>")
        end
        for i = 1, #data.Section_List do
            local name = "Journal " .. data.Section_List[i].Display
            mn.addLuaEnum(name)
            ScpuiSystem.extensions.JournalUi.SectionEnum:addEnumItem(name)
            ScpuiSystem.extensions.JournalUi.Enum_Lists[i] = mn.LuaEnums[name]
        end

        for i = 1, #data.Entry_List do
            for _, entry in ipairs(data.Entry_List[i]) do
                ScpuiSystem.extensions.JournalUi.Enum_Lists[i]:addEnumItem(entry.Key)
            end
        end
    end

	--- We don't need the hook below in FRED
	return
end

--- On campaign begin, clear the journal data
ScpuiSystem:addHook("On Campaign Begin", function()
	ScpuiSystem.extensions.JournalUi:clearAll()
end)