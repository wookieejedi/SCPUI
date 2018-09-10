local module = {}

-- The type of a dialog
module.TYPE_SIMPLE = 1

-- The various button
module.BUTTON_TYPE_POSITIVE = 1
module.BUTTON_TYPE_NEGATIVE = 2

module.BUTTON_MAPPING = {
    [module.BUTTON_TYPE_POSITIVE] = {
        class = "button_positive",
        image = "up-arrow.png",
    },
    [module.BUTTON_TYPE_NEGATIVE] = {
        class = "button_negative",
        image = "down-arrow.png",
    }
}

local function initialize_buttons(document, properties, finish_func)
    local button_template = document:GetElementById("button_template")
    local button_container = document:GetElementById("button_container")

    for _, v in ipairs(properties.buttons) do
        local actual_el = button_template:Clone()
        button_container:AppendChild(actual_el)

        local text_el = actual_el:GetElementById("button_text")
        text_el.inner_rml = v.text

        local image_vals = module.BUTTON_MAPPING[v.type]

        if image_vals ~= nil then
            local image_el = actual_el:GetElementById("button_image")
            image_el:SetAttribute("src", image_vals.image)
            image_el:SetClass(image_vals.class, true)
        end

        actual_el:AddEventListener("click", function(_, _, _)
            finish_func(v.value)
            document:Close()
        end)
    end
end

local function show_dialog(context, properties, finish_func)
    local dialog_doc = TestContext:LoadDocument("data/interface/markup/button_dialog.rml")

    dialog_doc:GetElementById("title_container").inner_rml = properties.title
    dialog_doc:GetElementById("text_container").inner_rml = properties.text

    if #properties.buttons > 0 then
        initialize_buttons(dialog_doc, properties, finish_func)
    end

    dialog_doc:Show(DocumentFocus.FOCUS) -- MODAL would be better than FOCUS but then the debugger cannot be used anymore
end

-- Metatable for factory instances
local factory_mt = {}

factory_mt.__index = factory_mt

function factory_mt:type(type)
    self.type = type
    return self
end

function factory_mt:title(title)
    self.title = title
    return self
end

function factory_mt:text(text)
    self.text = text
    return self
end

function factory_mt:button(type, text, value)
    table.insert(self.buttons, {
        type = type,
        text = text,
        value = value or #self.buttons + 1
    })
    return self
end

function factory_mt:show(context, finish_func)
    show_dialog(context, self, finish_func)
end

function module.new()
    local factory = {
        type = module.TYPE_SIMPLE,
        buttons = {},
    }
    setmetatable(factory, factory_mt)
    return factory
end

return module