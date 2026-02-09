local mainPanel = CreateFrame("Frame", "MasterCollectorOptionsPanel", InterfaceOptionsFramePanelContainer)
mainPanel.name = "Master Collector"
MC.mainOptionsCategory = Settings.RegisterCanvasLayoutCategory(mainPanel, "Master Collector")
Settings.RegisterAddOnCategory(MC.mainOptionsCategory)

local weeklyPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel", InterfaceOptionsFramePanelContainer)
weeklyPanel.name = "Weekly Lockout Filters"
weeklyPanel.parent = mainPanel.name
MC.weeklySubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, weeklyPanel,
    "Weekly Lockout Filters")
Settings.RegisterAddOnCategory(MC.weeklySubCategory)

local dailyPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel2", InterfaceOptionsFramePanelContainer)
dailyPanel.name = "Daily Lockout Filters"
dailyPanel.parent = mainPanel.name
MC.dailySubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, dailyPanel,
    "Daily Lockout Filters")
Settings.RegisterAddOnCategory(MC.dailySubCategory)

local repPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel3", InterfaceOptionsFramePanelContainer)
repPanel.name = "Reputations Filters"
repPanel.parent = mainPanel.name
MC.repSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, repPanel, "Reputations Filters")
Settings.RegisterAddOnCategory(MC.repSubCategory)

local eventPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel4", InterfaceOptionsFramePanelContainer)
eventPanel.name = "Event Filters"
eventPanel.parent = mainPanel.name
MC.eventSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, eventPanel, "Event Filters")
Settings.RegisterAddOnCategory(MC.eventSubCategory)

local grindsPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel5", InterfaceOptionsFramePanelContainer)
grindsPanel.name = "Anytime Grinds Filters"
grindsPanel.parent = mainPanel.name
MC.grindsSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, grindsPanel, "Anytime Grinds Filters")
Settings.RegisterAddOnCategory(MC.grindsSubCategory)

local graphicPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel6", InterfaceOptionsFramePanelContainer)
graphicPanel.name = "Graphics Override"
graphicPanel.parent = mainPanel.name
MC.graphicSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, graphicPanel, "Graphics Override")
Settings.RegisterAddOnCategory(MC.graphicSubCategory)

mainPanel:RegisterEvent("ADDON_LOADED")

local mainTitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainTitle:SetPoint("TOPLEFT", 16, -16)
mainTitle:SetText("Master Collector V1.9.4")

local weeklyTitle = weeklyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
weeklyTitle:SetPoint("TOPLEFT", 16, -16)
weeklyTitle:SetText("Weekly Lockout Filters")

local dailyTitle = dailyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
dailyTitle:SetPoint("TOPLEFT", 16, -16)
dailyTitle:SetText("Daily Lockout Filters")

local repTitle = repPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
repTitle:SetPoint("TOPLEFT", 16, -16)
repTitle:SetText("Reputations")

local eventTitle = eventPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
eventTitle:SetPoint("TOPLEFT", 16, -16)
eventTitle:SetText("Event Filters")

local grindsTitle = grindsPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
grindsTitle:SetPoint("TOPLEFT", 16, -16)
grindsTitle:SetText("Anytime Grinds Filters")

local graphicTitle = graphicPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
graphicTitle:SetPoint("TOPLEFT", 16, -16)
graphicTitle:SetText("Graphics Settings Override")

function MC.UpdateMinimapButtonVisibility()
    if MasterCollectorSV.hideMinimapButton then
        if MC.minimapButton then
            MC.minimapButton:Hide()
        end
    else
        if MC.minimapButton then
            MC.minimapButton:Show()
        end
    end
end

function MC.UpdateBackdropBorder()
    if MasterCollectorSV.showBackdropBorder then
        MC.mainFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
            tile = true,
            tileEdge = true,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    else
        MC.mainFrame:SetBackdrop({
            bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background-Dark",
            edgeFile = nil,
            tile = true,
            tileEdge = false,
            tileSize = 8,
            edgeSize = 8,
            insets = { left = 1, right = 1, top = 1, bottom = 1 },
        })
    end
    MC.mainFrame:SetBackdropColor(1, 1, 1, MasterCollectorSV.backdropAlpha)
    MC.mainFrame:SetBackdropBorderColor(1, 1, 1, 1)
end

function MC.CreateDivider(parent, yOffset)
    local line = parent:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(1, 1, 1, 0.15)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    line:SetPoint("TOPRIGHT", parent, "TOPRIGHT", -10, yOffset)
    return line
end

-- Category header
function MC.CreateHeader(parent, text, yOffset)
    local header = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    header:SetPoint("TOPLEFT", parent, "TOPLEFT", 10, yOffset)
    header:SetText(text)
    return header
end

function MC.CreateCheckbox(name, variable, parent, tabButton, groupVars)
    local checkbox = CreateFrame("CheckButton", "MasterCollector" .. variable, parent, "InterfaceOptionsCheckButtonTemplate")

    checkbox.groupVars = groupVars

    checkbox.GetValue = function()
        return MasterCollectorSV[variable]
    end

    local function AnyGroupEnabled(list)
        for _, key in ipairs(list) do
            if MasterCollectorSV[key] then
                return true
            end
        end
        return false
    end

    -- Helper: update parent checkbox if this child changes
    local function UpdateParentCheckbox(self)
        if self.parentCheckbox then
            self.parentCheckbox:SetChecked(AnyGroupEnabled(self.parentCheckbox.groupVars))
        end
    end

    -- Helper: set all children on/off
    local function SetGroup(list, state)
        for _, key in ipairs(list) do
            MasterCollectorSV[key] = state
            -- update actual child checkboxes visually if they exist
            local cb = _G["MasterCollector" .. key]
            if cb then cb:SetChecked(state) end
        end
    end

    checkbox.SetValue = function(self)
        local checked = self:GetChecked()

        MasterCollectorSV[variable] = checked

        if self.groupVars then
            SetGroup(self.groupVars, checked)
        end

        -- NEW: If this is a child checkbox, update the parent checkbox
        UpdateParentCheckbox(self)

        if variable == "cinematicSkip" then
            if checked then
                MasterCollectorSV.cinematicSkip = true
                print("|cFF00FF00MasterCollector Cinematic Skip is ENABLED|r")
            else
                MasterCollectorSV.cinematicSkip = false
                print("|cFFFF0000MasterCollector Cinematic Skip is DISABLED|r")
            end
        end

        if variable == "autoLootCheck" then
            if checked then
                MasterCollectorSV.autoLootCheck = true
                SetCVar("autoLootDefault", "1")
                print("|cFF00FF00MasterCollector Auto Loot Override is ENABLED|r")
            else
                MasterCollectorSV.autoLootCheck = false
                SetCVar("autoLootDefault", "0")
                print("|cFFFF0000MasterCollector Auto Loot Override is DISABLED|r")
            end
        end

        if variable == "lootRoller" then
            if checked then
                MasterCollectorSV.lootRoller = true
                print("|cFF00FF00MasterCollector Loot Roller is ENABLED|r")
            else
                MasterCollectorSV.lootRoller = false
                print("|cFFFF0000MasterCollector Loot Roller is DISABLED|r")
            end
        end

        if tabButton then
            if self:GetChecked() then
                tabButton:Hide()
            else
                tabButton:Show()
            end
        end

        MC.weeklyDisplay()
        MC.dailiesDisplay()
        MC.repsDisplay()
        MC.events()
        MC.grinds()
        MC.UpdateBackdropBorder()
        MC.UpdateMinimapButtonVisibility()
        MC.UpdateTabPositions()
        MC.UpdateMainFrameSize()
    end

    checkbox:SetChecked(
        checkbox.groupVars and AnyGroupEnabled(checkbox.groupVars)
        or MasterCollectorSV[variable]
    )

    checkbox.label = _G[checkbox:GetName() .. "Text"]
    checkbox.label:SetText(name)
    checkbox:SetScript("OnClick", checkbox.SetValue)

    return checkbox
end

function MC.CreateEditBox(text, variable, parent)
    local textbox = CreateFrame("EditBox", "MasterCollector" .. variable, parent, "InputBoxTemplate")
    textbox:SetSize(400, 60)
    textbox:SetAutoFocus(false)
    textbox:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
        MasterCollectorSV[variable] = self:GetText()
        MC.weeklyDisplay()
    end)
    textbox:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
        MasterCollectorSV[variable] = self:GetText()
        MC.weeklyDisplay()
    end)
    textbox:SetScript("OnTabPressed", function(self)
        self:ClearFocus()
    end)
    textbox:SetText(MasterCollectorSV[variable] or "")

    local textboxText = textbox:CreateFontString("$parentText", "BACKGROUND", "GameFontNormalSmall")
    textboxText:SetPoint("TOPLEFT", textbox, "TOPLEFT", -4, 6)
    textboxText:SetText(text or "Default Text")
    textbox:SetCursorPosition(0)
    return textbox
end

function MC.CreateSlider(name, variable, minValue, maxValue, step)
    local slider = CreateFrame("Slider", "MasterCollector" .. variable, mainPanel, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(step)

    local initialValue = MasterCollectorSV[variable]
    slider:SetValue(initialValue)

    slider:SetWidth(150)
    slider:SetHeight(15)
    slider.Low:SetText(minValue)
    slider.High:SetText(maxValue)
    slider.Text:SetText(name .. ": " .. string.format("%.2f", initialValue))
    return slider
end

function MC.CreateGraphicsCheckbox(label, key, parent)
    if not MasterCollectorSV.graphicsConfig[key] then
        MasterCollectorSV.graphicsConfig[key] = { enabled = false, level = 1 }
    end

    local checkbox = CreateFrame("CheckButton", "MasterCollector" .. key .. "Enabled", parent, "InterfaceOptionsCheckButtonTemplate")

    checkbox.key = key
    checkbox.label = _G[checkbox:GetName() .. "Text"]
    checkbox.label:SetText(label)

    checkbox:SetChecked(MasterCollectorSV.graphicsConfig[key].enabled)

    checkbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig[key].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({[key] = MasterCollectorSV.graphicsConfig[key]})
    end)

    MC.graphicsUIElements[key] = { type = "checkbox", widget = checkbox }

    return checkbox
end

function MC.CreateGraphicsSlider(name, variable, minValue, maxValue, step)
    minValue = math.max(1, minValue or 1)
    local slider = CreateFrame("Slider", "MasterCollector" .. variable, graphicPanel, "OptionsSliderTemplate")
    slider:SetMinMaxValues(minValue, maxValue)
    slider:SetValueStep(1)
    slider:SetObeyStepOnDrag(true)

    local sliderConfig = MasterCollectorSV.graphicsConfig[variable]
    if not sliderConfig then
        sliderConfig = { enabled = false, level = minValue }
        MasterCollectorSV.graphicsConfig[variable] = sliderConfig
    end

    local initialValue = math.max(minValue, math.floor(sliderConfig.level or minValue))
    slider:SetValue(initialValue)

    slider:SetWidth(150)
    slider:SetHeight(15)
    slider.Low:SetText(minValue)
    slider.High:SetText(maxValue)
    slider.Text:SetText(name .. ": " .. initialValue)

    slider:SetScript("OnValueChanged", function(self, value)
        value = math.floor(value + 0.5)
        self:SetValue(value)
        slider.Text:SetText(name .. ": " .. value)
        MasterCollectorSV.graphicsConfig[variable].level = value
        MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
    end)

    MC.graphicsUIElements[variable] = { type = "slider", widget = slider }

    return slider
end

function MC.CreateFontSizeSlider()
    local fontSizeSlider = MC.mainFrame.fontSizeSlider
    local initialValue = MasterCollectorSV.fontSize
    fontSizeSlider:SetValue(initialValue)
    fontSizeSlider.Text:SetText(string.format("Font Size: %d", initialValue))

    fontSizeSlider:SetScript("OnValueChanged", function(self, value)
        MasterCollectorSV.fontSize = value
        fontSizeSlider.Text:SetText(string.format("Font Size: %d", value))
        MC.weeklyDisplay()
        MC.repsDisplay()
        MC.dailiesDisplay()
        MC.events()
        MC.grinds()
    end)
end

function MC.CreateBackdropSlider()
    local backdropAlphaSlider = MC.mainFrame.backdropAlphaSlider
    local initialValue = MasterCollectorSV.backdropAlpha
    backdropAlphaSlider:SetValue(initialValue)
    backdropAlphaSlider.Text:SetText(string.format("Backdrop Opacity: %.2f", initialValue))
    MC.mainFrame:SetBackdropColor(1, 1, 1, initialValue)

    backdropAlphaSlider:SetScript("OnValueChanged", function(self, value)
        MasterCollectorSV.backdropAlpha = value
        backdropAlphaSlider.Text:SetText(string.format("Backdrop Opacity: %.2f", value))
        MC.mainFrame:SetBackdropColor(1, 1, 1, value)
        MC.UpdateBackdropBorder()
    end)
end

function MC.CreateColorPicker(name, variable)
    local colorPicker = CreateFrame("Button", "MasterCollector" .. variable, mainPanel)
    colorPicker:SetSize(24, 24)
    colorPicker:SetPoint("TOPLEFT", mainPanel, "TOPLEFT", 16, -300)
    colorPicker:SetNormalTexture("Interface/ChatFrame/ChatFrameColorSwatch")

    MC.mainFrame[variable] = colorPicker

    local function SetColor()
        local color = MasterCollectorSV[variable] or { 1, 1, 1 }
        color = type(color) == "table" and color or { 1, 1, 1 }
        colorPicker:GetNormalTexture():SetColorTexture(unpack(color))
    end

    local function OnColorSelect()
        local r, g, b = ColorPickerFrame:GetColorRGB()
        MasterCollectorSV[variable] = { r, g, b }

        local hexColor = MC.colorsToHex({ r, g, b })
        if variable == "greenFontColor" then
            MC.greenHex = hexColor
        elseif variable == "redFontColor" then
            MC.redHex = hexColor
        elseif variable == "goldFontColor" then
            MC.goldHex = hexColor
        end

        SetColor()
        MC.weeklyDisplay()
        MC.dailiesDisplay()
        MC.repsDisplay()
        MC.events()
        MC.grinds()
    end

    colorPicker:SetScript("OnClick", function()
        local color = MasterCollectorSV[variable]
        color = type(color) == "table" and color or { 1, 1, 1 }

        ColorPickerFrame:SetupColorPickerAndShow({
            r = color[1],
            g = color[2],
            b = color[3],
            swatchFunc = OnColorSelect,
            cancelFunc = function() end
        })
        ColorPickerFrame:Show()
    end)

    SetColor()

    local label = colorPicker:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("LEFT", colorPicker, "RIGHT", 5, 0)
    label:SetText(name)
    return colorPicker
end

function MC.UpdateColorPickers()
    for _, colorPickerName in ipairs({
        "greenFontColor",
        "redFontColor",
        "goldFontColor"
    }) do
        local colorPicker = MC.mainFrame[colorPickerName]
        if colorPicker and colorPicker.GetNormalTexture then
            local color = MasterCollectorSV[colorPickerName] or MC.defaultValues[colorPickerName]
            color = type(color) == "table" and color or { 1, 1, 1 }
            colorPicker:GetNormalTexture():SetColorTexture(unpack(color))
        end
    end
end

function MC.UpdateCheckboxes()
    local function AnyEnabled(list)
        for _, key in ipairs(list) do
            if MasterCollectorSV[key] then
                return true
            end
        end
        return false
    end

    local function UpdateCheckboxState(name)
        local checkbox = _G["MasterCollector" .. name]
        if not checkbox then return end

        if checkbox.groupVars then
            checkbox:SetChecked(AnyEnabled(checkbox.groupVars))
        else
            checkbox:SetChecked(MasterCollectorSV[name])
        end
    end

    for _, checkboxName in ipairs(MC.checkboxNames) do
        UpdateCheckboxState(checkboxName)
    end

    for _, parentName in ipairs(MC.parentCheckboxes) do
        UpdateCheckboxState(parentName)
    end

    MC.UpdateMainFrameSize()
end

function MC.CreateDropdown(labelText, dropdownName, values, parent)
    local label = parent:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    label:SetText(labelText)

    local dropdown = CreateFrame("Frame", "MasterCollector_" .. dropdownName, parent, "UIDropDownMenuTemplate")

    local function OnSelect(self, value)
        UIDropDownMenu_SetSelectedID(dropdown, self:GetID())
        if MasterCollectorSV and MasterCollectorSV.graphicsConfig and MasterCollectorSV.graphicsConfig[dropdownName] then
            for i, v in ipairs(values) do
                if v == value then
                    MasterCollectorSV.graphicsConfig[dropdownName].level = i
                    break
                end
            end
        end
        if dropdown.onSelect then
            dropdown.onSelect(value)
        end
    end

    UIDropDownMenu_Initialize(dropdown, function(self, level, menuList)
        for i, value in ipairs(values) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = value
            info.arg1 = value
            info.func = OnSelect
            UIDropDownMenu_AddButton(info)
        end
    end)

    UIDropDownMenu_SetWidth(dropdown, 150)
    UIDropDownMenu_SetButtonWidth(dropdown, 124)
    UIDropDownMenu_JustifyText(dropdown, "LEFT")

    local defaultIndex = 1
    if MasterCollectorSV 
       and MasterCollectorSV.graphicsConfig 
       and MasterCollectorSV.graphicsConfig[dropdownName] 
       and MasterCollectorSV.graphicsConfig[dropdownName].level then
        defaultIndex = MasterCollectorSV.graphicsConfig[dropdownName].level
        MC.ApplyDynamicGraphics({ [dropdownName] = MasterCollectorSV.graphicsConfig[dropdownName] })
    end
    UIDropDownMenu_SetSelectedID(dropdown, defaultIndex)
    label:SetPoint("BOTTOMLEFT", dropdown, "TOPLEFT", 20, 5)

    MC.graphicsUIElements[dropdownName] = { type = "dropdown", widget = dropdown }

    return dropdown, label
end

function MC.ResetGraphicsToDefaults()
    MasterCollectorSV.graphicsConfig = CopyTable(MC.defaultValues.graphicsConfig)

    for key, info in pairs(MC.graphicsUIElements) do
        local data = MasterCollectorSV.graphicsConfig[key]

        if info.type == "checkbox" then
            info.widget:SetChecked(data.enabled)

        elseif info.type == "slider" then
            info.widget:SetValue(data.level)

        elseif info.type == "dropdown" then
            UIDropDownMenu_SetSelectedID(info.widget, data.level)
        end
    end

    MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
end

function MC.ResetToDefaults()
    MasterCollectorSV = {}
    for key, value in pairs(MC.defaultValues) do
        if key ~= "graphicsConfig" then
            MasterCollectorSV[key] = value
        end
    end

    MasterCollectorSV.graphicsConfig = {}
    for key, defaultValue in pairs(MC.defaultValues.graphicsConfig) do
        MasterCollectorSV.graphicsConfig[key] = CopyTable(defaultValue)
    end

    MC.InitializeColors()
    MC.UpdateColorPickers()

    if MC.mainFrame.backdropAlphaSlider then
        local backdropAlphaSlider = MC.mainFrame.backdropAlphaSlider
        backdropAlphaSlider:SetValue(MC.defaultValues.backdropAlpha)
        backdropAlphaSlider.Text:SetText(string.format("Backdrop Opacity: %.2f", MC.defaultValues.backdropAlpha))
        MC.mainFrame:SetBackdropColor(1, 1, 1, MC.defaultValues.backdropAlpha)
    end

    if MC.mainFrame.fontSizeSlider then
        local fontSizeSlider = MC.mainFrame.fontSizeSlider
        fontSizeSlider:SetValue(MC.defaultValues.fontSize)
        fontSizeSlider.Text:SetText(string.format("Font Size: %d", MC.defaultValues.fontSize))
    end

    for _, checkboxName in ipairs(MC.checkboxNames) do
        local checkbox = MC.mainFrame[checkboxName]
        if checkbox then
            checkbox:SetValue()
        end
    end

    if MC.graphicsUIElements then
        for key, info in pairs(MC.graphicsUIElements) do
            local cfg = MasterCollectorSV.graphicsConfig[key]
            if cfg then
                if info.type == "checkbox" then
                    info.widget:SetChecked(cfg.enabled)

                elseif info.type == "slider" then
                    info.widget:SetValue(cfg.level)
                    if info.widget.Text then
                        info.widget.Text:SetText(key .. ": " .. cfg.level)
                    end

                elseif info.type == "dropdown" then
                    UIDropDownMenu_SetSelectedID(info.widget, cfg.level)
                end
            end
        end
    end

    MC.RestoreGraphics()
    MC.UpdateBackdropBorder()
    MC.UpdateMinimapButtonVisibility()
    C_Timer.After(0, MC.UpdateCheckboxes)
    MC.weeklyDisplay()
    MC.dailiesDisplay()
    MC.repsDisplay()
    MC.events()
    MC.grinds()
end

function MC.CreateResetButton()
    local resetButton = CreateFrame("Button", "MasterCollectorResetButton", mainPanel, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 30)
    resetButton:SetPoint("BOTTOMRIGHT", mainPanel, "BOTTOMRIGHT", -200, 70)
    resetButton:SetText("Reset to Defaults")
    resetButton:SetScript("OnClick", MC.ResetToDefaults)
end

function MC.CreateBanner(panel)
    local banner = panel:CreateTexture(nil, "BACKGROUND")
    banner:SetSize(230, 115)
    banner:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 50, 16)
    banner:SetTexture("Interface\\AddOns\\MasterCollector\\LOGO.PNG")
    banner:SetTexCoord(0, 1, 0, 1)
end

function MC.CreateSocialLinks(panel)
    local function CreateLinkButton(parent, text, url, yOffset)
        local linkButton = CreateFrame("Button", nil, parent)
        linkButton:SetSize(300, 20)
        linkButton:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 16, yOffset)
        linkButton:SetNormalFontObject("GameFontNormal")
        linkButton:SetHighlightFontObject("GameFontHighlight")
        linkButton:SetText(text)

        linkButton:SetScript("OnClick", function()
            local popoutPanel = CreateFrame("Frame", nil, UIParent, "BasicFrameTemplate")
            popoutPanel:SetSize(300, 150)
            popoutPanel:SetPoint("CENTER")
            popoutPanel:SetFrameStrata("DIALOG")
            popoutPanel:EnableMouse(true)
            popoutPanel:SetMovable(true)
            popoutPanel:RegisterForDrag("LeftButton")
            popoutPanel:SetScript("OnDragStart", popoutPanel.StartMoving)
            popoutPanel:SetScript("OnDragStop", popoutPanel.StopMovingOrSizing)

            local text = popoutPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            text:SetPoint("TOPLEFT", popoutPanel, "TOPLEFT", 10, -2)
            text:SetText("Copy this link:")

            local editBox = CreateFrame("EditBox", nil, popoutPanel, "InputBoxTemplate")
            editBox:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -10)
            editBox:SetSize(280, 80)
            editBox:SetText(url)
            editBox:SetMultiLine(true)
            editBox:SetAutoFocus(false)
            editBox:EnableMouse(true)
            editBox:SetScript("OnMouseDown", function(self)
                self:HighlightText()
            end)

            local closeButton = CreateFrame("Button", nil, popoutPanel, "UIPanelButtonTemplate")
            closeButton:SetSize(80, 22)
            closeButton:SetPoint("BOTTOMRIGHT", popoutPanel, "BOTTOMRIGHT", -10, 10)
            closeButton:SetText("Close")
            closeButton:SetScript("OnClick", function() popoutPanel:Hide() end)

            popoutPanel:Show()
        end)
    end
    local mainPrompt = panel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    mainPrompt:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 100, 55)
    mainPrompt:SetText("Support the Developer!")

    CreateLinkButton(panel, "Watch me on Twitch! [https://www.twitch.tv/divinekate]", "https://www.twitch.tv/divinekate",24)
    CreateLinkButton(panel, "Follow me on Socials! [https://beacons.ai/divinekate]", "https://beacons.ai/divinekate", 8)
end

function MC.CreateOptions()
    local tbcVars = {"showBCRaids", "showTBCDungeons", "showTBCReps", "showTBCPVP"}
    local wotlkVars = {
        "showWOTLKRaids",
        "showWOTLKDungeons",
        "showWOTLKReps",
        "showArgentDailies",
        "showBrunnhildarDailies",
        "showWOTLKPVP",
        "showWOTLKAchieves"
    }
    local cataVars = {"showCataRaids", "showCataDungeons", "showCataReps", "showCataPVP", "showCataAchieves"}
    local pandaVars = {"showPandariaRaids", "showPandariaWorldBosses", "showPandariaReps", "showMOPPVP", "showMOPAchieves"}
    local wodVars = {
        "showGarrisonInvasions",
        "showWoDRaids",
        "showWoDWorldBosses",
        "showTanaanRares",
        "showWoDReps",
        "showWoDDailies",
        "showWODPVP",
        "showWODAchieves"
    }
    local legionVars = {
        "showLegionDungeons",
        "showLegionRaids",
        "showArgusRares",
        "showLegionReps",
        "showFFAWQTimer",
        "showLegionInvasionTimer",
        "showLegionPVP",
        "showLegionAchieves"
    }
    local bfaVars = {
        "showBFADungeons",
        "showBFARaids",
        "showBFAWorldBosses",
        "showMechagonRares",
        "showNazRares",
        "showBfaDailies",
        "showBfAReps",
        "showArathiWFTimer",
        "showDarkshoreWFTimer",
        "showBfaAssaultTimer",
        "showSummonDepthsTimer",
        "showNzothAssaults",
        "showIslandExpeditions",
        "showBFAPVP",
        "showBFAAchieves"
    }
    local slVars = {
        "showSLWeeklyDungeons",
        "showSLRaids",
        "showSLRares",
        "showCovenantRares",
        "showCallings",
        "showSLDailies",
        "showSLReps",
        "showSLCovenants",
        "showMawAssaultTimer",
        "showBeastwarrensHuntTimer",
        "showTormentorsTimer",
        "showSLPVP",
        "showSLAchieves",
        "showProtoform"
    }
    local dfVars = {
        "showDFDungeons",
        "showDFRenownReps",
        "showTimeRiftsTimer",
        "showStormsFuryTimer",
        "showDragonbaneKeepTimer",
        "showFeastTimer",
        "showHuntsTimer",
        "showDreamsurgesTimer",
        "showSuffusionCampTimer",
        "showElementalStormsTimer",
        "showFroststoneStormTimer",
        "showLegendaryAlbumTimer",
        "showResearchersUnderFireTimer",
        "showSuperbloomTimer",
        "showBigDigTimer",
        "showDFWeeklies",
        "showDFRaids",
        "showDFDailies",
        "showZCZones",
        "showDFOtherReps",
        "showDFPVP",
        "showDFAchieves"
    }
    local twwVars = {
        "showTWWDungeons",
        "showTWWRares",
        "showBeledarShiftTimer",
        "showTWWRenownReps",
        "showTWWOtherReps",
        "showTWWRaids",
        "showTWWPVP",
        "showTWWAchieves",
        "showTWWWeeklies"
    }
    local main = {
        options = {
            {"Hide Obtained Mounts", "hideBossesWithMountsObtained"},
            {"Show Instances with No Lockout", "showBossesWithNoLockout"},
            {"Show Mount Names", "showMountName"},
            {"Show Rarity Attempts (must have mount names enabled)", "showRarityDetail"}
        },
        divider = "Filter by Expansion",
        expansionFilter = {
            {"Show The Burning Crusade", "showTBCExpansion", tbcVars},
            {"Show Wrath of Lich King", "showWOTLKExpansion", wotlkVars},
            {"Show Cataclysm", "showCataExpansion", cataVars},
            {"Show Pandaria", "showPandaExpansion", pandaVars},
            {"Show Warlords of Draenor", "showWodExpansion", wodVars},
            {"Show Legion", "showLegionExpansion", legionVars},
            {"Show Battle for Azeroth", "showBFAExpansion", bfaVars},
            {"Show Shadowlands", "showSLExpansion", slVars},
            {"Show Dragonflight", "showDFExpansion", dfVars},
            {"Show The War Within", "showTWWExpansion", twwVars}
        },
        divider2 = "Quality of Life",
        qolSettings = {
            {"Show Backdrop Border", "showBackdropBorder"},
            {"Hide Minimap Button", "hideMinimapButton"},
            {"Toggle Auto-Skipping Cinematics", "cinematicSkip"},
            {"Toggle Auto-Loot Character Override", "autoLootCheck"},
            {"Toggle Auto-Rolling Loot", "lootRoller"}
        }
    }

    local mainControls = {}
    mainControls.title = mainTitle
    for _, row in ipairs(main) do
        if type(row) == "table" and row[1] then
            mainControls[row[2]] = MC.CreateCheckbox(row[1], row[2], mainPanel)
        end
    end

    for _, row in ipairs(main.options) do
        mainControls[row[2]] = MC.CreateCheckbox(row[1], row[2], mainPanel)
    end

    mainControls.mainExpDivider = MC.CreateDivider(mainPanel)
    mainControls.mainExpHeader = MC.CreateHeader(mainPanel, main.divider)
    for _, row in ipairs(main.expansionFilter) do
        mainControls[row[2]] = MC.CreateCheckbox(row[1], row[2], mainPanel, nil, row[3])
    end

    mainControls.mainQOLDivider = MC.CreateDivider(mainPanel)
    mainControls.mainQOLHeader = MC.CreateHeader(mainPanel, main.divider)
    for _, row in ipairs(main.qolSettings) do
        mainControls[row[2]] = MC.CreateCheckbox(row[1], row[2], mainPanel)
    end

    local function AutoLayoutMain()
        local last = mainControls.options
        for _, row in ipairs(main) do
            if type(row) == "table" and row[1] then
                local widget = mainControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = mainControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        last = LayoutTwoColumn(main.options, mainControls.title)

        mainControls.mainExpDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -300, -5)
        mainControls.mainExpHeader:SetPoint("TOPLEFT", mainControls.mainExpDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(main.expansionFilter, mainControls.mainExpHeader)

        mainControls.mainQOLDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -300, -5)
        mainControls.mainQOLHeader:SetPoint("TOPLEFT", mainControls.mainQOLDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(main.qolSettings, mainControls.mainQOLHeader)

        local backdropAlphaSlider = MC.CreateSlider("Backdrop Opacity", "backdropAlpha", 0, 1, 0.05)
        local greenColorPicker = MC.CreateColorPicker("Killed Boss Color", "greenFontColor")
        local redColorPicker = MC.CreateColorPicker("Not Killed Boss Color", "redFontColor")
        local goldColorPicker = MC.CreateColorPicker("Heading Color", "goldFontColor")
        local fontSizeSlider = MC.CreateSlider("Font Size", "fontSize", 8, 30, 1)
        greenColorPicker:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 10, -15)
        redColorPicker:SetPoint("TOPLEFT", greenColorPicker, "BOTTOMLEFT", 0, -20)
        goldColorPicker:SetPoint("TOPLEFT", redColorPicker, "BOTTOMLEFT", 0, -20)
        fontSizeSlider:SetPoint("TOPLEFT", greenColorPicker, "TOPRIGHT", 270, 10)
        MC.mainFrame.fontSizeSlider = fontSizeSlider
        backdropAlphaSlider:SetPoint("TOPLEFT", fontSizeSlider, "TOPLEFT", 0, -60)
        MC.mainFrame.backdropAlphaSlider = backdropAlphaSlider
    end
    AutoLayoutMain()

    local hideWeeklyTab = MC.CreateCheckbox("Hide Weekly Tab", "hideWeeklyTab", weeklyPanel, MC.weeklyTab)
    hideWeeklyTab:SetPoint("TOPLEFT", weeklyTitle, "BOTTOMLEFT", 0, -10)
    local weekly = {
        {"Show Garrison Invasions", "showGarrisonInvasions"},
        {"Show Dragonflight Weekly Activities", "showDFWeeklies"},
        {"Show The War Within Weekly Activities", "showTWWWeeklies"},
        divider = "Dungeons",
        dungeons = {
            {"Show Legion Mythics", "showLegionDungeons"},
            {"Show Battle of Azeroth Mythics", "showBFADungeons"},
            {"Show Shadowlands Mythics", "showSLWeeklyDungeons"},
            {"Show Dragonflight Mythics", "showDFDungeons"},
            -- {"Show The War Within Mythics", "showTWWDungeons"}
        },
        divider2 = "Raids",
        raids = {
            {"Show The War Within Raids", "showTWWRaids"},
            {"Show Dragonflight Raids", "showDFRaids"},
            {"Show Shadowlands Raids", "showSLRaids"},
            {"Show Battle of Azeroth Raids", "showBFARaids"},
            {"Show Legion Raids", "showLegionRaids"},
            {"Show Warlords of Draenor Raids", "showWoDRaids"},
            {"Show Pandaria Raids", "showPandariaRaids"},
            {"Show Cataclysm Raids", "showCataRaids"},
            {"Show Wrath of Lich King Raids", "showWOTLKRaids"}
        },
        divider3 = "World Bosses",
        worldBosses = {
            {"Show Battle of Azeroth World Bosses", "showBFAWorldBosses"},
            {"Show Warlords of Draenor World Bosses", "showWoDWorldBosses"},
            {"Show Pandaria World Bosses", "showPandariaWorldBosses"}
        }
    }

    local weeklyControls = {}
    weeklyControls.title = hideWeeklyTab
    for _, row in ipairs(weekly) do
        if type(row) == "table" and row[1] then
            weeklyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], weeklyPanel)
        end
    end

    weeklyControls.dWeeklyDivider = MC.CreateDivider(weeklyPanel)
    weeklyControls.dWeeklyHeader = MC.CreateHeader(weeklyPanel, weekly.divider)
    for _, row in ipairs(weekly.dungeons) do
        weeklyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], weeklyPanel)
    end

    weeklyControls.rWeeklyDivider = MC.CreateDivider(weeklyPanel)
    weeklyControls.rWeeklyHeader = MC.CreateHeader(weeklyPanel, weekly.divider2)
    for _, row in ipairs(weekly.raids) do
        weeklyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], weeklyPanel)
    end

    weeklyControls.wbWeeklyDivider = MC.CreateDivider(weeklyPanel)
    weeklyControls.wbWeeklyHeader = MC.CreateHeader(weeklyPanel, weekly.divider3)
    for _, row in ipairs(weekly.worldBosses) do
        weeklyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], weeklyPanel)
    end

    weeklyControls.bossFilter = MC.CreateEditBox("Filter Bosses Manually", "bossFilter", weeklyPanel)
    local function AutoLayoutWeekly()
        local last = weeklyControls.title
        for _, row in ipairs(weekly) do
            if type(row) == "table" and row[1] then
                local widget = weeklyControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = weeklyControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        weeklyControls.dWeeklyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        weeklyControls.dWeeklyHeader:SetPoint("TOPLEFT", weeklyControls.dWeeklyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(weekly.dungeons, weeklyControls.dWeeklyHeader)

        weeklyControls.rWeeklyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -300, -5)
        weeklyControls.rWeeklyHeader:SetPoint("TOPLEFT", weeklyControls.rWeeklyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(weekly.raids, weeklyControls.rWeeklyHeader)

        weeklyControls.wbWeeklyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        weeklyControls.wbWeeklyHeader:SetPoint("TOPLEFT", weeklyControls.wbWeeklyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(weekly.worldBosses, weeklyControls.wbWeeklyHeader)

        weeklyControls.bossFilter:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -20)
    end
    AutoLayoutWeekly()

    local hideDailyTab = MC.CreateCheckbox("Hide Daily Tab", "hideDailyTab", dailyPanel, MC.dailyTab)
    hideDailyTab:SetPoint("TOPLEFT", dailyTitle, "BOTTOMLEFT", 0, -10)
    local daily = {
        divider = "Dungeons",
        dungeons = {
            {"Show Burning Crusade Dungeons", "showTBCDungeons"},
            {"Show Wrath of Lich King Dungeons", "showWOTLKDungeons"},
            {"Show Cataclysm Dungeons", "showCataDungeons"},
            {"Show The War Within Mythics", "showTWWDungeons"}
        },
        divider2 = "Rares",
        rares = {
            {"Show Warlords of Draenor Tanaan Jungle", "showTanaanRares"},
            {"Show Legion Argus Rares", "showArgusRares"},
            {"Show Battle of Azeroth Mechagon Rares", "showMechagonRares"},
            {"Show Battle of Azeroth Nazjatar Rares", "showNazRares"},
            {"Show Shadowlands Non-Covenant Specific Rares", "showSLRares"},
            {"Show Shadowlands Covenant Specific Rares", "showCovenantRares"},
            {"Show The War Within Rares", "showTWWRares"}
        },
        divider3 = "Daily Activities",
        activities = {
            {"Show Classic Daily Activities", "showClassicDailies"},
            {"Show Argent Tournament Daily Activities", "showArgentDailies"},
            {"Show Brunnhildar Village Daily Activities", "showBrunnhildarDailies"},
            {"Show Warlords of Draenor Daily Activities", "showWoDDailies"},
            {"Show Battle of Azeroth Daily Activities", "showBfaDailies"},
            {"Show Shadowlands Daily Activities", "showSLDailies"},
            {"Show Current Maldraxxus Calling Quests", "showCallings"},
            {"Show Dragonflight Daily Activities", "showDFDailies"}
        }
    }

    local dailyControls = {}
    dailyControls.title = hideDailyTab
    for _, row in ipairs(daily) do
        if type(row) == "table" and row[1] then
            dailyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], dailyPanel)
        end
    end

    dailyControls.ddailyDivider = MC.CreateDivider(dailyPanel)
    dailyControls.ddailyHeader = MC.CreateHeader(dailyPanel, daily.divider)
    for _, row in ipairs(daily.dungeons) do
        dailyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], dailyPanel)
    end

    dailyControls.rdailyDivider = MC.CreateDivider(dailyPanel)
    dailyControls.rdailyHeader = MC.CreateHeader(dailyPanel, daily.divider2)
    for _, row in ipairs(daily.rares) do
        dailyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], dailyPanel)
    end

    dailyControls.adailyDivider = MC.CreateDivider(dailyPanel)
    dailyControls.adailyHeader = MC.CreateHeader(dailyPanel, daily.divider3)
    for _, row in ipairs(daily.activities) do
        dailyControls[row[2]] = MC.CreateCheckbox(row[1], row[2], dailyPanel)
    end

    local function AutoLayoutDaily()
        local last = dailyControls.title
        for _, row in ipairs(daily) do
            if type(row) == "table" and row[1] then
                local widget = dailyControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = dailyControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        dailyControls.ddailyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        dailyControls.ddailyHeader:SetPoint("TOPLEFT", dailyControls.ddailyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(daily.dungeons, dailyControls.ddailyHeader)

        dailyControls.rdailyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -300, -5)
        dailyControls.rdailyHeader:SetPoint("TOPLEFT", dailyControls.rdailyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(daily.rares, dailyControls.rdailyHeader)

        dailyControls.adailyDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        dailyControls.adailyHeader:SetPoint("TOPLEFT", dailyControls.adailyDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(daily.activities, dailyControls.adailyHeader)
    end
    AutoLayoutDaily()

    local hideDailyRepTab = MC.CreateCheckbox("Hide Reputations Tab", "hideDailyRepTab", repPanel, MC.dailyrepTab)
    hideDailyRepTab:SetPoint("TOPLEFT", repTitle, "BOTTOMLEFT", 0, -10)
    local reputations = {
        divider = "Standard Reputations",
        reputations = {
            {"Show Burning Crusade Reputations", "showTBCReps"},
            {"Show Wrath of Lich King Reputations", "showWOTLKReps"},
            {"Show Cataclysm Reputations", "showCataReps"},
            {"Show Pandaria Reputations", "showPandariaReps"},
            {"Show Warlords of Draenor Reputations", "showWoDReps"},
            {"Show Legion Reputations", "showLegionReps"},
            {"Show Battle for Azeroth Reputations", "showBfAReps"},
            {"Show Shadowlands Reputations", "showSLReps"},
            {"Show Dragonflight Other Reputations", "showDFOtherReps"},
            {"Show The War Within Other Reputations", "showTWWOtherReps"}
        },
        divider2 = "Renown Reputations",
        renowns = {
            {"Show Shadowlands Covenants", "showSLCovenants"},
            {"Show Dragonflight Renowns", "showDFRenownReps"},
            {"Show The War Within Renowns", "showTWWRenownReps"}
        }
    }

    local repControls = {}
    repControls.title = hideDailyRepTab
    for _, row in ipairs(reputations) do
        if type(row) == "table" and row[1] then
            repControls[row[2]] = MC.CreateCheckbox(row[1], row[2], repPanel)
        end
    end

    repControls.repDivider = MC.CreateDivider(repPanel)
    repControls.repHeader = MC.CreateHeader(repPanel, reputations.divider)
    for _, row in ipairs(reputations.reputations) do
        repControls[row[2]] = MC.CreateCheckbox(row[1], row[2], repPanel)
    end

    repControls.renownDivider = MC.CreateDivider(repPanel)
    repControls.renownHeader = MC.CreateHeader(repPanel, reputations.divider2)
    for _, row in ipairs(reputations.renowns) do
        repControls[row[2]] = MC.CreateCheckbox(row[1], row[2], repPanel)
    end

    local function AutoLayoutReps()
        local last = repControls.title
        for _, row in ipairs(reputations) do
            if type(row) == "table" and row[1] then
                local widget = repControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = repControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        repControls.repDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        repControls.repHeader:SetPoint("TOPLEFT", repControls.repDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(reputations.reputations, repControls.repHeader)

        repControls.renownDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", -300, -5)
        repControls.renownHeader:SetPoint("TOPLEFT", repControls.renownDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(reputations.renowns, repControls.renownHeader)
    end
    AutoLayoutReps()

    local hideEventTab = MC.CreateCheckbox("Hide Event Tab", "hideEventTab", eventPanel, MC.eventTab)
    hideEventTab:SetPoint("TOPLEFT", eventTitle, "BOTTOMLEFT", 0, -10)
    local events = {
        {"Show The War Within: Beledar Dark Shift Timer", "showBeledarShiftTimer"},
        divider = "Legion Event Timers",
        legionEvents = {
            {"Show Legion Remix Mounts", "showLegionRemix"},
            {"Show Legion Free For All World Quests", "showFFAWQTimer"},
            {"Show Legion Invasions", "showLegionInvasionTimer"}
        },
        divider2 = "Battle for Azeroth Event Timers",
        bfaEvents = {
            {"Show Arathi Highlands Warfront", "showArathiWFTimer"},
            {"Show Darkshore Warfront", "showDarkshoreWFTimer"},
            {"Show Faction Assaults", "showBfaAssaultTimer"},
            {"Show N'Zoth Assaults", "showNzothAssaults"},
            {"Show Nazjatar Summon from the Depths", "showSummonDepthsTimer"}
        },
        divider3 = "Shadowlands Event Timers",
        slEvents = {
            {"Show The Maw: Covenant Assaults", "showMawAssaultTimer"},
            {"Show The Maw: Beastwarrens Hunt", "showBeastwarrensHuntTimer"},
            {"Show The Maw: Tormentors of Torghast", "showTormentorsTimer"}
        },
        divider4 = "Dragonflight Event Timers",
        dfEvents = {
            {"Show Time Rifts", "showTimeRiftsTimer"},
            {"Show The Storm's Fury", "showStormsFuryTimer"},
            {"Show Siege of Dragonbane Keep", "showDragonbaneKeepTimer"},
            {"Show Iskaara Community Feast", "showFeastTimer"},
            {"Show Grand Hunts", "showHuntsTimer"},
            {"Show Zaralek Cavern Zone Rotation", "showZCZones"},
            {"Show Dreamsurges", "showDreamsurgesTimer"},
            {"Show Suffusion Camp", "showSuffusionCampTimer"},
            {"Show Elemental Storms", "showElementalStormsTimer"},
            {"Show Froststone Vault Primal Storm", "showFroststoneStormTimer"},
            {"Show Legendary Album World Quests", "showLegendaryAlbumTimer"},
            {"Show Researchers Under Fire", "showResearchersUnderFireTimer"},
            {"Show Superbloom", "showSuperbloomTimer"},
            {"Show The Big Dig: Traitor's Rest", "showBigDigTimer"}
        },
    }

    local eventControls = {}
    eventControls.title = hideEventTab
    for _, row in ipairs(events) do
        if type(row) == "table" and row[1] then
            eventControls[row[2]] = MC.CreateCheckbox(row[1], row[2], eventPanel)
        end
    end

    eventControls.legionEventDivider = MC.CreateDivider(eventPanel)
    eventControls.legionEventHeader = MC.CreateHeader(eventPanel, events.divider)
    for _, row in ipairs(events.legionEvents) do
        eventControls[row[2]] = MC.CreateCheckbox(row[1], row[2], eventPanel)
    end

    eventControls.bfaEventDivider = MC.CreateDivider(eventPanel)
    eventControls.bfaEventHeader = MC.CreateHeader(eventPanel, events.divider2)
    for _, row in ipairs(events.bfaEvents) do
        eventControls[row[2]] = MC.CreateCheckbox(row[1], row[2], eventPanel)
    end

    eventControls.slEventDivider = MC.CreateDivider(eventPanel)
    eventControls.slEventHeader = MC.CreateHeader(eventPanel, events.divider3)
    for _, row in ipairs(events.slEvents) do
        eventControls[row[2]] = MC.CreateCheckbox(row[1], row[2], eventPanel)
    end

    eventControls.dfEventDivider = MC.CreateDivider(eventPanel)
    eventControls.dfEventHeader = MC.CreateHeader(eventPanel, events.divider4)
    for _, row in ipairs(events.dfEvents) do
        eventControls[row[2]] = MC.CreateCheckbox(row[1], row[2], eventPanel)
    end

    local function AutoLayoutEvents()
        local last = eventControls.title
        for _, row in ipairs(events) do
            if type(row) == "table" and row[1] then
                local widget = eventControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = eventControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        eventControls.legionEventDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        eventControls.legionEventHeader:SetPoint("TOPLEFT", eventControls.legionEventDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(events.legionEvents, eventControls.legionEventHeader)

        eventControls.bfaEventDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        eventControls.bfaEventHeader:SetPoint("TOPLEFT", eventControls.bfaEventDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(events.bfaEvents, eventControls.bfaEventHeader)

        eventControls.slEventDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        eventControls.slEventHeader:SetPoint("TOPLEFT", eventControls.slEventDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(events.slEvents, eventControls.slEventHeader)

        eventControls.dfEventDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        eventControls.dfEventHeader:SetPoint("TOPLEFT", eventControls.dfEventDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(events.dfEvents, eventControls.dfEventHeader)
    end
    AutoLayoutEvents()

    local hideGrindMountsTab = MC.CreateCheckbox("Hide Anytime Grinds Tab", "hideGrindMountsTab", grindsPanel, MC.grindMountsTab)
    hideGrindMountsTab:SetPoint("TOPLEFT", grindsTitle, "BOTTOMLEFT", 0, -10)
    local grinds = {
        options = {
            {"Show Instance and Raid Lockouts", "showLockouts"},
            {"Show Island Expeditions", "showIslandExpeditions"},
            {"Show Fishing", "showFishing"},
            {"Show Normal Instance", "showNormalInstances"},
            {"Show Achievements", "showAchievements"},
            {"Show PVP", "showPVP"},
            {"Show Protoform Synthesis Mounts", "showProtoform"}
        },
        divider = "Achievements",
        achievements = {
            {"Show Wrath of Lich King Achievements", "showWOTLKAchieves"},
            {"Show Cataclysm Achievements", "showCataAchieves"},
            {"Show Pandaria Achievements", "showMOPAchieves"},
            {"Show Warlords of Draenor Achievements", "showWODAchieves"},
            {"Show Legion Achievements", "showLegionAchieves"},
            {"Show Battle for Azeroth Achievements", "showBFAAchieves"},
            {"Show Shadowlands Achievements", "showSLAchieves"},
            {"Show Dragonflight Achievements", "showDFAchieves"},
            {"Show The War Within Achievements", "showTWWAchieves"}
        },
        divider2 = "PVP",
        pvp = {
            {"Show Classic PVP", "showClassicPVP"},
            {"Show Burning Crusade PVP", "showTBCPVP"},
            {"Show Wrath of Lich King PVP", "showWOTLKPVP"},
            {"Show Cataclysm PVP", "showCataPVP"},
            {"Show Pandaria PVP", "showMOPPVP"},
            {"Show Warlords of Draenor PVP", "showWODPVP"},
            {"Show Legion PVP", "showLegionPVP"},
            {"Show Battle for Azeroth PVP", "showBFAPVP"},
            {"Show Shadowlands PVP", "showSLPVP"},
            {"Show Dragonflight PVP", "showDFPVP"},
            {"Show The War Within PVP", "showTWWPVP"}
        }
    }

    local grindsControls = {}
    grindsControls.title = hideGrindMountsTab
    for _, row in ipairs(grinds) do
        if type(row) == "table" and row[1] then
            grindsControls[row[2]] = MC.CreateCheckbox(row[1], row[2], grindsPanel)
        end
    end

    for _, row in ipairs(grinds.options) do
        grindsControls[row[2]] = MC.CreateCheckbox(row[1], row[2], grindsPanel)
    end

    grindsControls.achieveDivider = MC.CreateDivider(grindsPanel)
    grindsControls.achieveHeader = MC.CreateHeader(grindsPanel, grinds.divider)
    for _, row in ipairs(grinds.achievements) do
        grindsControls[row[2]] = MC.CreateCheckbox(row[1], row[2], grindsPanel)
    end

    grindsControls.pvpDivider = MC.CreateDivider(grindsPanel)
    grindsControls.pvpHeader = MC.CreateHeader(grindsPanel, grinds.divider2)
    for _, row in ipairs(grinds.pvp) do
        grindsControls[row[2]] = MC.CreateCheckbox(row[1], row[2], grindsPanel)
    end

    local function AutoLayoutGrinds()
        local last = grindsControls.options
        for _, row in ipairs(grinds) do
            if type(row) == "table" and row[1] then
                local widget = grindsControls[row[2]]
                widget:SetPoint("TOPLEFT", last, "BOTTOMLEFT")
                last = widget
            end
        end

        local function LayoutTwoColumn(list, header)
            local left = header
            local right = nil
            for index, row in ipairs(list) do
                local widget = grindsControls[row[2]]
                widget:ClearAllPoints()

                if index % 2 == 1 then
                    widget:SetPoint("TOPLEFT", left, "BOTTOMLEFT")
                    left = widget
                else
                    if not right then
                        widget:SetPoint("TOPLEFT", left, "TOPLEFT", 300, 0)
                        right = widget
                    else
                        widget:SetPoint("TOPLEFT", right, "BOTTOMLEFT")
                        right = widget
                    end
                end
            end
         if #list % 2 == 0 then
                return right
            else
                return left
            end
        end

        last = LayoutTwoColumn(grinds.options, grindsControls.title)

        grindsControls.achieveDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        grindsControls.achieveHeader:SetPoint("TOPLEFT", grindsControls.achieveDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(grinds.achievements, grindsControls.achieveHeader)

        grindsControls.pvpDivider:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -5)
        grindsControls.pvpHeader:SetPoint("TOPLEFT", grindsControls.pvpDivider, "BOTTOMLEFT", 0, -10)
        last = LayoutTwoColumn(grinds.pvp, grindsControls.pvpHeader)
    end
    AutoLayoutGrinds()

    local graphicsCityOverride = MC.CreateCheckbox("Apply Graphics Override in Cities", "graphicsCityOverride", graphicPanel)
    graphicsCityOverride:SetPoint("TOPLEFT", graphicTitle, "BOTTOMLEFT", 350, -30)
    graphicsCityOverride:SetScript("OnClick", function(self)
        if not self:GetChecked() then
            MasterCollectorSV.graphicsCityOverride = false
            MC.RestoreGraphics()
            print("|cFFFF0000MasterCollector Graphics City Override is DISABLED|r")
        else
            MasterCollectorSV.graphicsCityOverride = true
            MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
            print("|cFF00FF00MasterCollector Graphics City Override is ENABLED|r")
        end
    end)

    local graphicsInstanceOverride = MC.CreateCheckbox("Apply Graphics Override in Instances", "graphicsInstanceOverride", graphicPanel)
    graphicsInstanceOverride:SetPoint("TOPLEFT", graphicsCityOverride, "BOTTOMLEFT", 0, -30)
    graphicsInstanceOverride:SetScript("OnClick", function(self)
        if not self:GetChecked() then
            MasterCollectorSV.graphicsInstanceOverride = false
            MC.RestoreGraphics()
            print("|cFFFF0000MasterCollector Graphics Instance Override is DISABLED|r")
        else
            MasterCollectorSV.graphicsInstanceOverride = true
            MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
            print("|cFF00FF00MasterCollector Graphics Instance Override is ENABLED|r")
        end
    end)

    local graphicsShadowQuality = MC.CreateDropdown("Shadow Quality", "graphicsShadowQuality", {"Low", "Fair", "Good", "High", "Ultra", "Ultra High"}, graphicPanel)
    graphicsShadowQuality:SetPoint("TOPLEFT", graphicTitle, "BOTTOMLEFT", 0, -30)
    local graphicsShadowQualityCheckbox = MC.CreateGraphicsCheckbox("", "graphicsShadowQuality", graphicPanel)
    graphicsShadowQualityCheckbox:SetPoint("LEFT", graphicsShadowQuality, "RIGHT", 10, 0)
    graphicsShadowQualityCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsShadowQuality"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsShadowQuality"] = MasterCollectorSV.graphicsConfig["graphicsShadowQuality"] })
    end)

    local graphicsLiquidDetail = MC.CreateDropdown("Liquid Detail", "graphicsLiquidDetail", {"Low", "Fair", "Good", "High"}, graphicPanel)
    graphicsLiquidDetail:SetPoint("TOPLEFT", graphicsShadowQuality, "BOTTOMLEFT", 0, -22)
    local graphicsLiquidDetailCheckbox = MC.CreateGraphicsCheckbox("", "graphicsLiquidDetail", graphicPanel)
    graphicsLiquidDetailCheckbox:SetPoint("LEFT", graphicsLiquidDetail, "RIGHT", 10, 0)
    graphicsLiquidDetailCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsLiquidDetail"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsLiquidDetail"] = MasterCollectorSV.graphicsConfig["graphicsLiquidDetail"] })
    end)

    local graphicsParticleDensity = MC.CreateDropdown("Particle Density Quality", "graphicsParticleDensity", {"Disabled", "Low", "Fair", "Good", "High", "Ultra"}, graphicPanel)
    graphicsParticleDensity:SetPoint("TOPLEFT", graphicsLiquidDetail, "BOTTOMLEFT", 0, -22)
    local graphicsParticleDensityCheckbox = MC.CreateGraphicsCheckbox("", "graphicsParticleDensity", graphicPanel)
    graphicsParticleDensityCheckbox:SetPoint("LEFT", graphicsParticleDensity, "RIGHT", 10, 0)
    graphicsParticleDensityCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsParticleDensity"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsParticleDensity"] = MasterCollectorSV.graphicsConfig["graphicsParticleDensity"] })
    end)

    local graphicsSSAO = MC.CreateDropdown("SSAO Quality", "graphicsSSAO", {"Disabled", "Low", "Fair", "Good", "High", "Ultra"}, graphicPanel)
    graphicsSSAO:SetPoint("TOPLEFT", graphicsParticleDensity, "BOTTOMLEFT", 0, -22)
    local graphicsSSAOCheckbox = MC.CreateGraphicsCheckbox("", "graphicsSSAO", graphicPanel)
    graphicsSSAOCheckbox:SetPoint("LEFT", graphicsSSAO, "RIGHT", 10, 0)
    graphicsSSAOCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsSSAO"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsSSAO"] = MasterCollectorSV.graphicsConfig["graphicsSSAO"] })
    end)

    local graphicsDepthEffects = MC.CreateDropdown("Depth Effects", "graphicsDepthEffects", {"Disabled", "Low", "Good", "High"}, graphicPanel)
    graphicsDepthEffects:SetPoint("TOPLEFT", graphicsSSAO, "BOTTOMLEFT", 0, -22)
    local graphicsDepthEffectsCheckbox = MC.CreateGraphicsCheckbox("", "graphicsDepthEffects", graphicPanel)
    graphicsDepthEffectsCheckbox:SetPoint("LEFT", graphicsDepthEffects, "RIGHT", 10, 0)
    graphicsDepthEffectsCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsDepthEffects"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsDepthEffects"] = MasterCollectorSV.graphicsConfig["graphicsDepthEffects"] })
    end)

    local graphicsComputeEffects = MC.CreateDropdown("Compute Effects", "graphicsComputeEffects", {"Disabled", "Low", "Good", "High", "Ultra"}, graphicPanel)
    graphicsComputeEffects:SetPoint("TOPLEFT", graphicsDepthEffects, "BOTTOMLEFT", 0, -22)
    local graphicsComputeEffectsCheckbox = MC.CreateGraphicsCheckbox("", "graphicsComputeEffects", graphicPanel)
    graphicsComputeEffectsCheckbox:SetPoint("LEFT", graphicsComputeEffects, "RIGHT", 10, 0)
    graphicsComputeEffectsCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsComputeEffects"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsComputeEffects"] = MasterCollectorSV.graphicsConfig["graphicsComputeEffects"] })
    end)

    local graphicsOutlineMode = MC.CreateDropdown("Outline Mode", "graphicsOutlineMode", {"Disabled", "Good", "High"}, graphicPanel)
    graphicsOutlineMode:SetPoint("TOPLEFT", graphicsComputeEffects, "BOTTOMLEFT", 0, -22)
    local graphicsOutlineModeCheckbox = MC.CreateGraphicsCheckbox("", "graphicsOutlineMode", graphicPanel)
    graphicsOutlineModeCheckbox:SetPoint("LEFT", graphicsOutlineMode, "RIGHT", 10, 0)
    graphicsOutlineModeCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsOutlineMode"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsOutlineMode"] = MasterCollectorSV.graphicsConfig["graphicsOutlineMode"] })
    end)

    local graphicsTextureResolution = MC.CreateDropdown("Texture Resolution", "graphicsTextureResolution", {"Low", "Fair", "High"}, graphicPanel)
    graphicsTextureResolution:SetPoint("TOPLEFT", graphicsOutlineMode, "BOTTOMLEFT", 0, -22)
    local graphicsTextureResolutionCheckbox = MC.CreateGraphicsCheckbox("", "graphicsTextureResolution", graphicPanel)
    graphicsTextureResolutionCheckbox:SetPoint("LEFT", graphicsTextureResolution, "RIGHT", 10, 0)
    graphicsTextureResolutionCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsTextureResolution"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsTextureResolution"] = MasterCollectorSV.graphicsConfig["graphicsTextureResolution"] })
    end)

    local graphicsSpellDensity = MC.CreateDropdown("Spell Density", "graphicsSpellDensity", {"Essential", "Reduced", "Everything"}, graphicPanel)
    graphicsSpellDensity:SetPoint("TOPLEFT", graphicsTextureResolution, "BOTTOMLEFT", 0, -22)
    local graphicsSpellDensityCheckbox = MC.CreateGraphicsCheckbox("", "graphicsSpellDensity", graphicPanel)
    graphicsSpellDensityCheckbox:SetPoint("LEFT", graphicsSpellDensity, "RIGHT", 10, 0)
    graphicsSpellDensityCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsSpellDensity"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsSpellDensity"] = MasterCollectorSV.graphicsConfig["graphicsSpellDensity"] })
    end)

    local graphicsProjectedTextures = MC.CreateDropdown("Projected Textures", "graphicsProjectedTextures", {"Disabled", "Enabled"}, graphicPanel)
    graphicsProjectedTextures:SetPoint("TOPLEFT", graphicsSpellDensity, "BOTTOMLEFT", 0, -22)
    local graphicsProjectedTexturesCheckbox = MC.CreateGraphicsCheckbox("WARNING: May Require a Loadtime between areas", "graphicsProjectedTextures", graphicPanel)
    graphicsProjectedTexturesCheckbox:SetPoint("LEFT", graphicsProjectedTextures, "RIGHT", 10, 0)
    graphicsTextureResolutionCheckbox.label:ClearAllPoints()
    graphicsProjectedTexturesCheckbox.label:SetPoint("LEFT", graphicsTextureResolutionCheckbox, "RIGHT", 4, 0)
    graphicsProjectedTexturesCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsProjectedTextures"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsProjectedTextures"] = MasterCollectorSV.graphicsConfig["graphicsProjectedTextures"] })
    end)

    local graphicsViewDistanceSlider = MC.CreateGraphicsSlider("View Distance", "graphicsViewDistance", 1, 10, 1)
    graphicsViewDistanceSlider:SetPoint("LEFT", graphicsParticleDensityCheckbox, "RIGHT", 150, 0)
    local graphicsViewDistanceCheckbox = MC.CreateGraphicsCheckbox("", "graphicsViewDistance", graphicPanel)
    graphicsViewDistanceCheckbox:SetPoint("LEFT", graphicsViewDistanceSlider, "RIGHT", 10, 0)
    graphicsViewDistanceCheckbox:SetScript("OnClick", function(self, value)
        MasterCollectorSV.graphicsConfig["graphicsViewDistance"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsViewDistance"] = MasterCollectorSV.graphicsConfig["graphicsViewDistance"] })
    end)

    local graphicsEnvironmentDetailSlider = MC.CreateGraphicsSlider("Environment Detail", "graphicsEnvironmentDetail", 1, 10, 1)
    graphicsEnvironmentDetailSlider:SetPoint("LEFT", graphicsDepthEffectsCheckbox, "RIGHT", 150, 0)
    local graphicsEnvironmentDetailCheckbox = MC.CreateGraphicsCheckbox("", "graphicsEnvironmentDetail", graphicPanel)
    graphicsEnvironmentDetailCheckbox:SetPoint("LEFT", graphicsEnvironmentDetailSlider, "RIGHT", 10, 0)
    graphicsEnvironmentDetailCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsEnvironmentDetail"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsEnvironmentDetail"] = MasterCollectorSV.graphicsConfig["graphicsEnvironmentDetail"] })
    end)

    local graphicsGroundClutterSlider = MC.CreateGraphicsSlider("Ground Clutter", "graphicsGroundClutter", 1, 10, 1)
    graphicsGroundClutterSlider:SetPoint("LEFT", graphicsOutlineModeCheckbox, "RIGHT", 150, 0)
    local graphicsGroundClutterCheckbox = MC.CreateGraphicsCheckbox("", "graphicsGroundClutter", graphicPanel)
    graphicsGroundClutterCheckbox:SetPoint("LEFT", graphicsGroundClutterSlider, "RIGHT", 10, 0)
    graphicsGroundClutterCheckbox:SetScript("OnClick", function(self)
        MasterCollectorSV.graphicsConfig["graphicsGroundClutter"].enabled = self:GetChecked()
        MC.ApplyDynamicGraphics({ ["graphicsGroundClutter"] = MasterCollectorSV.graphicsConfig["graphicsGroundClutter"] })
    end)

    local panels = { mainPanel, dailyPanel, repPanel, weeklyPanel, eventPanel }
    for _, panel in ipairs(panels) do
        MC.CreateBanner(panel)
    end

    MC.UpdateMainFrameSize()
    MC.UpdateCheckboxes()
    MC.SetActiveTab()
    MC.CheckFrameVisibility()
    MC.UpdateBackdropBorder()
    MC.CreateFontSizeSlider()
    MC.CreateBackdropSlider()
    MC.CreateSocialLinks(mainPanel)
    MC.CreateResetButton()
    MC.UpdateColorPickers()
end