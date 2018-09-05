

pilot_select = {}

function pilot_select.initialize(document)
	pilot_select.document = document

	local pilot_ul = document:GetElementById("pilotlist_ul")
	local pilots = ui.PilotSelect.enumeratePilots()

	for _, v in ipairs(pilots) do
		local li_el = document:CreateElement("li")
		li_el.inner_rml = v
		li_el:SetClass("pilotlist_element", true)
		pilot_ul:AppendChild(li_el)
	end
end