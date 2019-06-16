local rkt_util              = require("rocket_util")

local module                = {}

-- The type of a dialog
module.TYPE_SIMPLE          = 1

-- The various button
module.BUTTON_TYPE_POSITIVE = 1
module.BUTTON_TYPE_NEGATIVE = 2

module.BUTTON_MAPPING       = {
    [module.BUTTON_TYPE_POSITIVE] = "button_positive",
    [module.BUTTON_TYPE_NEGATIVE] = "button_negative"
}

local function initialize_buttons(document, properties, finish_func)
    local button_container = document:GetElementById("button_container")

    for _, v in ipairs(properties.buttons) do
        local actual_el, text_el, image_container, image_el = rkt_util.instantiate_template(document, "button_template",
                                                                                            nil, {
                                                                                                "button_text_id",
                                                                                                "button_image_container",
                                                                                                "button_image_id"
                                                                                            })
        button_container:AppendChild(actual_el)

        actual_el.id = "" -- Reset the ID so that there are no duplicate IDs
        actual_el:SetClass(module.BUTTON_MAPPING[v.type], true)

        text_el.inner_rml = v.text

        local style       = image_container.style
        for i, v in pairs(style) do
            -- This is pretty ugly but somehow the __index function is broken
            if i == "background-image" then
                image_el:SetAttribute("src", v)
                break
            end
        end

        actual_el:AddEventListener("click", function(_, _, _)
            if finish_func then
                finish_func(v.value)
            end
            document:Close()
        end)
    end
end

local function show_dialog(context, properties, finish_func)
    local dialog_doc                                       = context:LoadDocument("data/interface/markup/dialog.rml")

    dialog_doc:GetElementById("title_container").inner_rml = properties.title_string
    dialog_doc:GetElementById("text_container").inner_rml  = properties.text_string

    if #properties.buttons > 0 then
        initialize_buttons(dialog_doc, properties, finish_func)
    end

    dialog_doc:Show(DocumentFocus.FOCUS) -- MODAL would be better than FOCUS but then the debugger cannot be used anymore
end

-- Metatable for factory instances
local factory_mt   = {}

factory_mt.__index = factory_mt

function factory_mt:type(type)
    self.type_val = type
    return self
end

function factory_mt:title(title)
    self.title_string = title
    return self
end

function factory_mt:text(text)
    self.text_string = text
    return self
end

function factory_mt:button(type, text, value)
    if value == nil then
        value = #self.buttons + 1
    end

    table.insert(self.buttons, {
        type  = type,
        text  = text,
        value = value
    })
    return self
end

function factory_mt:show(context, finish_func)
    show_dialog(context, self, finish_func)
end

function module.new()
    local factory = {
        type_val     = module.TYPE_SIMPLE,
        buttons      = {},
        title_string = "",
        text_string  = ""
    }
    setmetatable(factory, factory_mt)
    return factory
end

return module