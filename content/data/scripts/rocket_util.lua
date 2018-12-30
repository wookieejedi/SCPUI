local module = {}

function module.instantiate_template(document, template_id, element_id, template_classes)
    local template = document:GetElementById(template_id)

    local actual_el = template:Clone()
    actual_el.id = element_id or "" -- Reset the ID so that there are no duplicate IDs

    local template_els = {}
    for _, v in ipairs(template_classes) do
        table.insert(template_els, actual_el:GetElementsByClassName(v)[1])
    end

    return actual_el, unpack(template_els)
end

return module
