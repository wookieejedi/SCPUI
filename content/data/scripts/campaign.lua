local dialogs = require("dialogs")
local class = require("class")
local topics = require("ui_topics")

local CampaignController = class()

function CampaignController:init()
end

function CampaignController:initialize(document)
    self.document = document
    self.elements = {}
    self.selection = nil

	---Load background choice
	self.document:GetElementById("main_background"):SetClass(ScpuiSystem:getBackgroundClass(), true)
	
	---Load the desired font size from the save file
	self.document:GetElementById("main_background"):SetClass(("base_font" .. ScpuiSystem:getFontPixelSize()), true)

    ui.CampaignMenu.loadCampaignList();

    local names, fileNames, descriptions = ui.CampaignMenu.getCampaignList()

    local currentCampaignFile = ba.getCurrentPlayer():getCampaignFilename()
    local selectedCampaign = nil

    self.names = names
    self.descriptions = {}
    self.fileNames = {}
    for i, v in ipairs(names) do
        self.descriptions[v] = descriptions[i]
        self.fileNames[v] = fileNames[i]

        if fileNames[i] == currentCampaignFile then
            selectedCampaign = v
        end
    end
	
	topics.campaign.initialize:send(self)

    self:init_campaign_list()

    -- Initialize selection
    self:selectCampaign(selectedCampaign)
end

function CampaignController:global_keydown(element, event)
    if event.parameters.key_identifier == rocket.key_identifier.ESCAPE then
        event:StopPropagation()

        ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
    end
end

function CampaignController:selectCampaign(campaign)
    if self.selection == campaign then
        -- No changes
        return
    end

    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[self.selection]:SetPseudoClass("checked", false)
    end

    self.selection = campaign

    local desc_el = self.document:GetElementById("desc_text")
    if self.selection ~= nil then
        desc_el.inner_rml = self.descriptions[campaign]
    else
        desc_el.inner_rml = ""
    end

    if self.selection ~= nil and self.elements[self.selection] ~= nil then
        self.elements[self.selection]:SetPseudoClass("checked", true)
        self.elements[self.selection]:ScrollIntoView()
    end
end

function CampaignController:create_campaign_li(campaign)
    local li_el = self.document:CreateElement("li")
	
	local display = topics.campaign.listCampaign:send({campaign, self.fileNames[campaign]})

    li_el.inner_rml = display
    li_el:SetClass("campaignlist_element", true)
    li_el:AddEventListener("click", function(_, _, _)
        self:selectCampaign(campaign)
    end)

    self.elements[campaign] = li_el

    return li_el
end

function CampaignController:init_campaign_list()
    local campaign_list_el = self.document:GetElementById("campaignlist_ul")
    for _, v in ipairs(self.names) do
        -- Add all the elements
        campaign_list_el:AppendChild(self:create_campaign_li(v))
    end
end

function CampaignController:commit_pressed(element)
    if self.selection == nil then
        ui.playElementSound(element, "click", "error")
        return
    end
    assert(self.fileNames[self.selection] ~= nil)

    ui.CampaignMenu.selectCampaign(self.fileNames[self.selection])

    ui.playElementSound(element, "click", "success")
    ba.postGameEvent(ba.GameEvents["GS_EVENT_MAIN_MENU"])
end

function CampaignController:restart_pressed(element)
    if self.selection == nil then
        ui.playElementSound(element, "click", "error")
        return
    end
    assert(self.fileNames[self.selection] ~= nil)

    local builder = dialogs.new()
    builder:title(ba.XSTR("Warning", 888284));
    builder:text(ba.XSTR("This will cause all progress in your\nCurrent campaign to be lost", 888285))
	builder:escape(false)
    builder:button(dialogs.BUTTON_TYPE_POSITIVE, ba.XSTR("Ok", 888286), true, string.sub(ba.XSTR("Ok", 888286), 1, 1))
    builder:button(dialogs.BUTTON_TYPE_NEGATIVE, ba.XSTR("Cancel", 888091), false, string.sub(ba.XSTR("Cancel", 888091), 1, 1))
    builder:show(self.document.context):continueWith(function(accepted)
        if not accepted then
            ui.playElementSound(element, "click", "error")
            return
        end

        ui.CampaignMenu.resetCampaign(self.fileNames[self.selection])

        ba.savePlayer(ba.getCurrentPlayer())
        ui.playElementSound(element, "click", "success")
    end)
end

function CampaignController:unload()
	topics.campaign.unload:send(self)
end

return CampaignController
