
local utils = require("utils")
local tblUtil = utils.table

local VALID_MODES = { "single", "multi" }

pilot_select = {
	selection = nil,
	elements = {}
}

function pilot_select:initialize(document)
	self.document = document

	local pilot_ul = document:GetElementById("pilotlist_ul")
	local pilots = ui.PilotSelect.enumeratePilots()

	local last = ui.PilotSelect.getLastPilot()
	if last ~= nil then
		-- Make sure that the last pilot appears at the top of the list
		local index = tblUtil.ifind(pilots, last.callsign)
		if index >= 0 then
			table.remove(pilots, index)
			table.insert(pilots, 1, last.callsign)
		end

		if last.is_multi then
			self:set_player_mode("multi")
		else
			self:set_player_mode("single")
		end
	end

	for i=1, 20 do
		table.insert(pilots, "test " .. tostring(i))
	end

	for _, v in ipairs(pilots) do
		local li_el = document:CreateElement("li")

		li_el.inner_rml = v
		li_el:SetClass("pilotlist_element", true)
		li_el:AddEventListener("click", function(_, _, _) self:selectPilot(v) end)

		self.elements[v] = li_el

		pilot_ul:AppendChild(li_el)
	end

	document:GetElementById("fso_version_info").inner_rml = ba.getVersionString()
	if last ~= nil then
		self:selectPilot(last.callsign)
	end
end

function pilot_select:selectPilot(pilot)
	if self.selection ~= nil and self.elements[self.selection] ~= nil then
		self.elements[self.selection]:SetPseudoClass("checked", false)
	end

	self.selection = pilot

	if self.selection ~= nil and self.elements[self.selection] ~= nil then
		self.elements[pilot]:SetPseudoClass("checked", true)
	end
end

function pilot_select:commit_pressed()
	if self.selection ~= nil then
		ui.PilotSelect.selectPilot(self.selection, self.current_mode == "multi")
	end
end

function pilot_select:set_player_mode(mode)
	assert(tblUtil.contains(VALID_MODES, mode), "Mode " .. tostring(mode) .. " is not valid!")

	local elements = {
		{
			multi = "multiplayer_btn",
			single = "singleplayer_btn"
		},
		{
			multi = "multiplayer_text",
			single = "singleplayer_text"
		},
	}

	local is_single = mode == "single"
	self.current_mode = mode

	for _, v in ipairs(elements) do
		local multi_el = self.document:GetElementById(v.multi)
		local single_el = self.document:GetElementById(v.single)
	
		multi_el:SetPseudoClass("checked", not is_single)
		single_el:SetPseudoClass("checked", is_single)
	end
end

function pilot_select:create_player()
end

function pilot_select:clone_player()
end

function pilot_select:delete_player()
	if self.selection == nil then
		return
	end
	
	if self.current_mode == "multi" then
		-- TODO: Add code for displaying a popup to let the player know that deleting only works in single player mode
		return
	end

	-- ui.PilotSelect.deletePilot(self.selection)

	-- Remove the element from the list
	local removed_el = self.elements[self.selection]
	removed_el.parent_node:RemoveChild(removed_el)
	self.elements[self.selection] = nil

	self:selectPilot(nil)
end
