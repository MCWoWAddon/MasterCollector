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
repPanel.name = "Daily Rep Filters"
repPanel.parent = mainPanel.name
MC.repSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, repPanel, "Daily Rep Filters")
Settings.RegisterAddOnCategory(MC.repSubCategory)

local eventPanel = CreateFrame("Frame", "MasterCollectorSubOptionsPanel4", InterfaceOptionsFramePanelContainer)
eventPanel.name = "Event Filters"
eventPanel.parent = mainPanel.name
MC.eventSubCategory = Settings.RegisterCanvasLayoutSubcategory(MC.mainOptionsCategory, eventPanel, "Event Filters")
Settings.RegisterAddOnCategory(MC.eventSubCategory)

mainPanel:RegisterEvent("ADDON_LOADED")

local mainTitle = mainPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
mainTitle:SetPoint("TOPLEFT", 16, -16)
mainTitle:SetText("Master Collector V1.6.3")

local weeklyTitle = weeklyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
weeklyTitle:SetPoint("TOPLEFT", 16, -16)
weeklyTitle:SetText("Weekly Lockout Filters")

local dailyTitle = dailyPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
dailyTitle:SetPoint("TOPLEFT", 16, -16)
dailyTitle:SetText("Daily Lockout Filters")

local repTitle = repPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
repTitle:SetPoint("TOPLEFT", 16, -16)
repTitle:SetText("Daily Rep Filters")

local eventTitle = eventPanel:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
eventTitle:SetPoint("TOPLEFT", 16, -16)
eventTitle:SetText("Event Filters")

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

function MC.CreateCheckbox(name, variable, parent, tabButton)
    local checkbox = CreateFrame("CheckButton", "MasterCollector" .. variable, parent,
        "InterfaceOptionsCheckButtonTemplate")
    checkbox.GetValue = function()
        return MasterCollectorSV[variable]
    end

    checkbox.SetValue = function(self)
        local checked = self:GetChecked()
        MasterCollectorSV[variable] = checked

        if variable == "cinematicSkip" then
            if checked then
                MasterCollectorSV.cinematicSkip = true
                print("|cFF00FF00MasterCollector Cinematic Skip is ENABLED|r")
            else
                MasterCollectorSV.cinematicSkip = false
                print("|cFFFF0000MasterCollector Cinematic Skip is DISABLED|r")
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
    checkbox:SetChecked(MasterCollectorSV[variable])
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
    for _, checkboxName in ipairs(MC.checkboxNames) do
        local checkbox = MC.mainFrame[checkboxName]
        if checkbox then
            checkbox:SetChecked(MasterCollectorSV[checkboxName])
            MC.UpdateMainFrameSize()
        end
    end
end

function MC.ResetToDefaults()
    MasterCollectorSV = {}
    for key, value in pairs(MC.defaultValues) do
        MasterCollectorSV[key] = value
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
            checkbox:SetChecked(MasterCollectorSV[checkboxName] == true)
        end
    end
    MC.UpdateBackdropBorder()
    MC.UpdateMinimapButtonVisibility()
    MC.UpdateCheckboxes()
    MC.weeklyDisplay()
    MC.dailiesDisplay()
    MC.repsDisplay()
    MC.events()
    MC.grinds()
end

function MC.CreateResetButton()
    local resetButton = CreateFrame("Button", "MasterCollectorResetButton", mainPanel, "UIPanelButtonTemplate")
    resetButton:SetSize(120, 30)
    resetButton:SetPoint("TOPRIGHT", mainPanel, "TOPRIGHT", -70, -170)
    resetButton:SetText("Reset to Defaults")
    resetButton:SetScript("OnClick", MC.ResetToDefaults)
end

function MC.CreateBanner(panel)
    local banner = panel:CreateTexture(nil, "BACKGROUND")
    banner:SetSize(230, 115)
    banner:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", 30, 16)
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
    mainPrompt:SetPoint("TOPLEFT", panel, "BOTTOMLEFT", 100, 70)
    mainPrompt:SetText("Click the below links:")

    CreateLinkButton(panel, "Watch me on Twitch! [https://www.twitch.tv/divinekate]", "https://www.twitch.tv/divinekate",
        32)
    CreateLinkButton(panel, "Follow me on Socials! [https://beacons.ai/divinekate]", "https://beacons.ai/divinekate", 16)
end

function MC.CreateOptions()
    local hideBossesWithMountsObtained = MC.CreateCheckbox("Hide Obtained Mounts", "hideBossesWithMountsObtained",
        mainPanel)
    local showBossesWithNoLockout = MC.CreateCheckbox("Show Instances with No Lockout", "showBossesWithNoLockout",
        mainPanel)
    local hideMinimapButton = MC.CreateCheckbox("Hide Minimap Button", "hideMinimapButton", mainPanel)
    local showBackdropBorder = MC.CreateCheckbox("Show Backdrop Border", "showBackdropBorder", mainPanel)
    local backdropAlphaSlider = MC.CreateSlider("Backdrop Opacity", "backdropAlpha", 0, 1, 0.05)
    local showMountName = MC.CreateCheckbox("Show Mount Names", "showMountName", mainPanel)
    local showRarityDetail = MC.CreateCheckbox("Show Rarity Attempts (must have mount names enabled)", "showRarityDetail",
        mainPanel)
    local cinematicSkip = MC.CreateCheckbox("Toggle Auto-Skipping Cinematics", "cinematicSkip", mainPanel)
    local showDFWeeklies = MC.CreateCheckbox("Show DragonFlight Weekly Quests", "showDFWeeklies", weeklyPanel)
    local showGarrisonInvasions = MC.CreateCheckbox("Show Garrison Invasions", "showGarrisonInvasions", weeklyPanel)
    local showDFDungeons = MC.CreateCheckbox("Show DragonFlight Mythic Dungeons", "showDFDungeons", weeklyPanel)
    local showSLWeeklyDungeons = MC.CreateCheckbox("Show Shadowlands Mythic Dungeons", "showSLWeeklyDungeons",
        weeklyPanel)
    local showLegionDungeons = MC.CreateCheckbox("Show Legion Mythic Dungeons", "showLegionDungeons", weeklyPanel)
    local showBFADungeons = MC.CreateCheckbox("Show Battle of Azeroth Mythic Dungeons", "showBFADungeons", weeklyPanel)
    local showDFRaids = MC.CreateCheckbox("Show Dragonflight Raids", "showDFRaids", weeklyPanel)
    local showSLRaids = MC.CreateCheckbox("Show Shadowlands Raids", "showSLRaids", weeklyPanel)
    local showBFARaids = MC.CreateCheckbox("Show Battle of Azeroth Raids", "showBFARaids", weeklyPanel)
    local showLegionRaids = MC.CreateCheckbox("Show Legion Raids", "showLegionRaids", weeklyPanel)
    local showWoDRaids = MC.CreateCheckbox("Show Warlords of Draenor Raids", "showWoDRaids", weeklyPanel)
    local showPandariaRaids = MC.CreateCheckbox("Show Pandaria Raids", "showPandariaRaids", weeklyPanel)
    local showCataRaids = MC.CreateCheckbox("Show Cataclysm Raids", "showCataRaids", weeklyPanel)
    local showWOTLKRaids = MC.CreateCheckbox("Show Wrath of Lich King Raids", "showWOTLKRaids", weeklyPanel)
    local showBCRaids = MC.CreateCheckbox("Show Burning Crusade Raids", "showBCRaids", weeklyPanel)
    local showBFAWorldBosses = MC.CreateCheckbox("Show Battle of Azeroth World Bosses", "showBFAWorldBosses", weeklyPanel)
    local showWoDWorldBosses = MC.CreateCheckbox("Show Warlords of Draenor World Bosses", "showWoDWorldBosses",
        weeklyPanel)
    local showPandariaWorldBosses = MC.CreateCheckbox("Show Pandaria World Bosses", "showPandariaWorldBosses",
        weeklyPanel)
    local bossFilter = MC.CreateEditBox("Filter Bosses Manually", "bossFilter", weeklyPanel)
    local greenColorPicker = MC.CreateColorPicker("Killed Boss Color", "greenFontColor")
    local redColorPicker = MC.CreateColorPicker("Not Killed Boss Color", "redFontColor")
    local goldColorPicker = MC.CreateColorPicker("Heading Color", "goldFontColor")
    local fontSizeSlider = MC.CreateSlider("Font Size", "fontSize", 8, 30, 1)

    local showSLDailyDungeons = MC.CreateCheckbox("Show Shadowlands Mythic Daily Dungeons", "showSLDailyDungeons",
        dailyPanel)
    local showTBCDungeons = MC.CreateCheckbox("Show Burning Crusade Dungeons", "showTBCDungeons", dailyPanel)
    local showWOTLKDungeons = MC.CreateCheckbox("Show Wrath of Lich King Dungeons", "showWOTLKDungeons", dailyPanel)
    local showCataDungeons = MC.CreateCheckbox("Show Cataclysm Dungeons", "showCataDungeons", dailyPanel)
    local showTanaanRares = MC.CreateCheckbox("Show WoD Tanaan Jungle Rares", "showTanaanRares", dailyPanel)
    local showArgusRares = MC.CreateCheckbox("Show Legion Argus Rares", "showArgusRares", dailyPanel)
    local showArathiRares = MC.CreateCheckbox("Show BfA Arathi Highlands Rares", "showArathiRares", dailyPanel)
    local showDarkshoreRares = MC.CreateCheckbox("Show BfA Darkshore Rares", "showDarkshoreRares", dailyPanel)
    local showMechagonRares = MC.CreateCheckbox("Show BfA Mechagon Rares", "showMechagonRares", dailyPanel)
    local showNazRares = MC.CreateCheckbox("Show BfA Nazjatar Rares", "showNazRares", dailyPanel)
    local showUldumRares = MC.CreateCheckbox("Show BfA Uldum Rares", "showUldumRares", dailyPanel)
    local showValeRares = MC.CreateCheckbox("Show BfA Vale of Eternal Blossom Rares", "showValeRares", dailyPanel)
    local showSLRares = MC.CreateCheckbox("Show SL Non-Covenant Specific Rares", "showSLRares", dailyPanel)
    local showCovenantRares = MC.CreateCheckbox("Show SL Covenant Specific Rares", "showCovenantRares", dailyPanel)
    local showCallings = MC.CreateCheckbox("Show Current Maldraxxus Calling Quests", "showCallings", dailyPanel)
    local showClassicDailies = MC.CreateCheckbox("Show Classic Daily Activities", "showClassicDailies", dailyPanel)
    local showArgentDailies = MC.CreateCheckbox("Show Argent Tournament Daily Activities", "showArgentDailies", dailyPanel)
    local showBrunnhildarDailies = MC.CreateCheckbox("Show Brunnhildar Village Daily Activities", "showBrunnhildarDailies", dailyPanel)
    local showWoDDailies = MC.CreateCheckbox("Show WoD Daily Activities", "showWoDDailies", dailyPanel)
    local showBfaDailies = MC.CreateCheckbox("Show BfA Daily Activities", "showBfaDailies", dailyPanel)
    local showSLDailies = MC.CreateCheckbox("Show SL Daily Activities", "showSLDailies", dailyPanel)
    local showDFDailies = MC.CreateCheckbox("Show DF Daily Activities", "showDFDailies", dailyPanel)
    local showTBCReps = MC.CreateCheckbox("Show Burning Crusade Reps", "showTBCReps", repPanel)
    local showWOTLKReps = MC.CreateCheckbox("Show Wrath of Lich King Reps", "showWOTLKReps", repPanel)
    local showCataReps = MC.CreateCheckbox("Show Cataclysm Reps", "showCataReps", repPanel)
    local showPandariaReps = MC.CreateCheckbox("Show Pandaria Reps", "showPandariaReps", repPanel)
    local showWoDReps = MC.CreateCheckbox("Show Warlords of Draenor Reps", "showWoDReps", repPanel)
    local showLegionReps = MC.CreateCheckbox("Show Legion Reps", "showLegionReps", repPanel)
    local showBfAReps = MC.CreateCheckbox("Show Battle for Azeroth Reps", "showBfAReps", repPanel)
    local showSLReps = MC.CreateCheckbox("Show Shadowlands Reps", "showSLReps", repPanel)
    local showSLCovenants = MC.CreateCheckbox("Show Shadowlands Covenants", "showSLCovenants", repPanel)
    local showDFRenownReps = MC.CreateCheckbox("Show Dragonflight Renown Reps", "showDFRenownReps", repPanel)
    local showDFOtherReps = MC.CreateCheckbox("Show Dragonflight Other Reps", "showDFOtherReps", repPanel)
    local hideWeeklyTab = MC.CreateCheckbox("Hide Weekly Tab", "hideWeeklyTab", weeklyPanel, MC.weeklyTab)
    local hideDailyTab = MC.CreateCheckbox("Hide Daily Tab", "hideDailyTab", dailyPanel, MC.dailyTab)
    local hideDailyRepTab = MC.CreateCheckbox("Hide Daily Rep Tab", "hideDailyRepTab", repPanel, MC.dailyrepTab)
    local hideGrindMountsTab = MC.CreateCheckbox("Hide Anytime Grinds Tab", "hideGrindMountsTab", mainPanel,
        MC.grindMountsTab)
    local hideEventTab = MC.CreateCheckbox("Hide Event Tab", "hideEventTab", eventPanel, MC.eventTab)
    local showFFAWQTimer = MC.CreateCheckbox("Show Legion Free For All World Quest Timer", "showFFAWQTimer", eventPanel)
    local showLegionInvasionTimer = MC.CreateCheckbox("Show Legion Invasion Timer", "showLegionInvasionTimer", eventPanel)
    local showArathiWFTimer = MC.CreateCheckbox("Show Arathi Highlands Warfront Timer", "showArathiWFTimer", eventPanel)
    local showDarkshoreWFTimer = MC.CreateCheckbox("Show Darkshore Warfront Timer", "showDarkshoreWFTimer", eventPanel)
    local showBfaAssaultTimer = MC.CreateCheckbox("Show BfA Faction Assault Timer", "showBfaAssaultTimer", eventPanel)
    local showNzothAssaults = MC.CreateCheckbox("Show BfA N'Zoth Assault Timer", "showNzothAssaults", eventPanel)
    local showSummonDepthsTimer = MC.CreateCheckbox("Show Nazjatar Summon from the Depths Timer", "showSummonDepthsTimer",
        eventPanel)
    local showMawAssaultTimer = MC.CreateCheckbox("Show SL The Maw Assault Timer", "showMawAssaultTimer", eventPanel)
    local showBeastwarrensHuntTimer = MC.CreateCheckbox("Show SL The Maw Beastwarrens Hunt Timer",
        "showBeastwarrensHuntTimer", eventPanel)
    local showTormentorsTimer = MC.CreateCheckbox("Show SL The Maw Tormentors of Torghast Timer", "showTormentorsTimer",
        eventPanel)
    local showTimeRiftsTimer = MC.CreateCheckbox("Show DF Time Rifts Timer", "showTimeRiftsTimer", eventPanel)
    local showStormsFuryTimer = MC.CreateCheckbox("Show DF The Storm's Fury Timer", "showStormsFuryTimer", eventPanel)
    local showDragonbaneKeepTimer = MC.CreateCheckbox("Show DF Siege of Dragonbane Keep Timer", "showDragonbaneKeepTimer",
        eventPanel)
    local showFeastTimer = MC.CreateCheckbox("Show DF Iskaara Community Feast Timer", "showFeastTimer", eventPanel)
    local showHuntsTimer = MC.CreateCheckbox("Show DF Grand Hunts Timer", "showHuntsTimer", eventPanel)
    local showZCZones = MC.CreateCheckbox("Show Zaralek Cavern Zone Rotation", "showZCZones", eventPanel)
    local showDreamsurgesTimer = MC.CreateCheckbox("Show DF Dreamsurges Timer", "showDreamsurgesTimer", eventPanel)
    local showSuffusionCampTimer = MC.CreateCheckbox("Show DF Suffusion Camp Timer", "showSuffusionCampTimer", eventPanel)
    local showElementalStormsTimer = MC.CreateCheckbox("Show DF Elemental Storms Timer", "showElementalStormsTimer",
        eventPanel)
    local showFroststoneStormTimer = MC.CreateCheckbox("Show DF Froststone Vault Primal Storm Timer",
        "showFroststoneStormTimer", eventPanel)
    local showLegendaryAlbumTimer = MC.CreateCheckbox("Show DF Legendary Album WQ Timer/s",
        "showLegendaryAlbumTimer", eventPanel)
    local showResearchersUnderFireTimer = MC.CreateCheckbox("Show DF Researchers Under Fire Timer",
        "showResearchersUnderFireTimer", eventPanel)
    local showSuperbloomTimer = MC.CreateCheckbox("Show DF Superbloom Timer", "showSuperbloomTimer", eventPanel)
    local showBigDigTimer = MC.CreateCheckbox("Show DF The Big Dig: Traitor's Rest Timer", "showBigDigTimer", eventPanel)
    local showBeledarShiftTimer = MC.CreateCheckbox("Show TWW Beledar Dark Shift Timer", "showBeledarShiftTimer",
        eventPanel)

    hideGrindMountsTab:SetPoint("TOPLEFT", cinematicSkip, "BOTTOMLEFT")

    hideBossesWithMountsObtained:SetPoint("TOPLEFT", mainTitle, "BOTTOMLEFT", 0, -10)
    showBossesWithNoLockout:SetPoint("TOPLEFT", hideBossesWithMountsObtained, "BOTTOMLEFT")
    showBackdropBorder:SetPoint("TOPLEFT", showBossesWithNoLockout, "BOTTOMLEFT")
    showMountName:SetPoint("TOPLEFT", showBackdropBorder, "BOTTOMLEFT")
    showRarityDetail:SetPoint("TOPLEFT", showMountName, "BOTTOMLEFT")
    hideMinimapButton:SetPoint("TOPLEFT", showRarityDetail, "BOTTOMLEFT")
    cinematicSkip:SetPoint("TOPLEFT", hideMinimapButton, "BOTTOMLEFT")

    greenColorPicker:SetPoint("TOPLEFT", hideGrindMountsTab, "BOTTOMLEFT", 10, -30)
    redColorPicker:SetPoint("TOPLEFT", greenColorPicker, "BOTTOMLEFT", 0, -20)
    goldColorPicker:SetPoint("TOPLEFT", redColorPicker, "BOTTOMLEFT", 0, -20)

    fontSizeSlider:SetPoint("TOPLEFT", hideBossesWithMountsObtained, "RIGHT", 425, 0)
    MC.mainFrame.fontSizeSlider = fontSizeSlider
    backdropAlphaSlider:SetPoint("TOPLEFT", fontSizeSlider, "TOPLEFT", 0, -60)
    MC.mainFrame.backdropAlphaSlider = backdropAlphaSlider

    hideWeeklyTab:SetPoint("TOPLEFT", weeklyTitle, "BOTTOMLEFT", 0, -10)
    showDFWeeklies:SetPoint("TOPLEFT", hideWeeklyTab, "BOTTOMLEFT")
    showGarrisonInvasions:SetPoint("TOPLEFT", showDFWeeklies, "BOTTOMLEFT")
    showDFDungeons:SetPoint("TOPLEFT", showGarrisonInvasions, "BOTTOMLEFT")
    showSLWeeklyDungeons:SetPoint("TOPLEFT", showDFDungeons, "BOTTOMLEFT")
    showLegionDungeons:SetPoint("TOPLEFT", showSLWeeklyDungeons, "BOTTOMLEFT")
    showBFADungeons:SetPoint("TOPLEFT", showLegionDungeons, "BOTTOMLEFT")
    showDFRaids:SetPoint("TOPLEFT", showBFADungeons, "BOTTOMLEFT")
    showSLRaids:SetPoint("TOPLEFT", showDFRaids, "BOTTOMLEFT")
    showBFARaids:SetPoint("TOPLEFT", showSLRaids, "BOTTOMLEFT")
    showLegionRaids:SetPoint("TOPLEFT", showBFARaids, "BOTTOMLEFT")
    showWoDRaids:SetPoint("TOPLEFT", showLegionRaids, "BOTTOMLEFT")
    showPandariaRaids:SetPoint("TOPLEFT", showWoDRaids, "BOTTOMLEFT")
    showCataRaids:SetPoint("TOPLEFT", showPandariaRaids, "BOTTOMLEFT")
    showWOTLKRaids:SetPoint("TOPLEFT", showCataRaids, "BOTTOMLEFT")
    showBCRaids:SetPoint("TOPLEFT", showWOTLKRaids, "BOTTOMLEFT")
    showBFAWorldBosses:SetPoint("TOPLEFT", showBCRaids, "BOTTOMLEFT")
    showWoDWorldBosses:SetPoint("TOPLEFT", showBFAWorldBosses, "BOTTOMLEFT")
    showPandariaWorldBosses:SetPoint("TOPLEFT", showWoDWorldBosses, "BOTTOMLEFT")
    bossFilter:SetPoint("TOPLEFT", showPandariaWorldBosses, "BOTTOMLEFT", 0, -20)

    hideDailyTab:SetPoint("TOPLEFT", dailyTitle, "BOTTOMLEFT", 0, -10)
    showSLDailyDungeons:SetPoint("TOPLEFT", hideDailyTab, "BOTTOMLEFT")
    showTBCDungeons:SetPoint("TOPLEFT", showSLDailyDungeons, "BOTTOMLEFT")
    showWOTLKDungeons:SetPoint("TOPLEFT", showTBCDungeons, "BOTTOMLEFT")
    showCataDungeons:SetPoint("TOPLEFT", showWOTLKDungeons, "BOTTOMLEFT")
    showTanaanRares:SetPoint("TOPLEFT", showCataDungeons, "BOTTOMLEFT")
    showArgusRares:SetPoint("TOPLEFT", showTanaanRares, "BOTTOMLEFT")
    showArathiRares:SetPoint("TOPLEFT", showArgusRares, "BOTTOMLEFT")
    showDarkshoreRares:SetPoint("TOPLEFT", showArathiRares, "BOTTOMLEFT")
    showMechagonRares:SetPoint("TOPLEFT", showDarkshoreRares, "BOTTOMLEFT")
    showNazRares:SetPoint("TOPLEFT", showMechagonRares, "BOTTOMLEFT")
    showUldumRares:SetPoint("TOPLEFT", showNazRares, "BOTTOMLEFT")
    showValeRares:SetPoint("TOPLEFT", showUldumRares, "BOTTOMLEFT")
    showSLRares:SetPoint("TOPLEFT", showValeRares, "BOTTOMLEFT")
    showCovenantRares:SetPoint("TOPLEFT", showSLRares, "BOTTOMLEFT")
    showCallings:SetPoint("TOPLEFT", showCovenantRares, "BOTTOMLEFT")

    showClassicDailies:SetPoint("TOPLEFT", dailyTitle, "BOTTOMLEFT", 400, -10)
    showArgentDailies:SetPoint("TOPLEFT", showClassicDailies, "BOTTOMLEFT")
    showBrunnhildarDailies:SetPoint("TOPLEFT", showArgentDailies, "BOTTOMLEFT")
    showBfaDailies:SetPoint("TOPLEFT", showBrunnhildarDailies, "BOTTOMLEFT")
    showWoDDailies:SetPoint("TOPLEFT", showBfaDailies, "BOTTOMLEFT")
    showSLDailies:SetPoint("TOPLEFT", showWoDDailies, "BOTTOMLEFT")
    showDFDailies:SetPoint("TOPLEFT", showSLDailies, "BOTTOMLEFT")

    hideDailyRepTab:SetPoint("TOPLEFT", repTitle, "BOTTOMLEFT", 0, -10)
    showTBCReps:SetPoint("TOPLEFT", hideDailyRepTab, "BOTTOMLEFT")
    showWOTLKReps:SetPoint("TOPLEFT", showTBCReps, "BOTTOMLEFT")
    showCataReps:SetPoint("TOPLEFT", showWOTLKReps, "BOTTOMLEFT")
    showPandariaReps:SetPoint("TOPLEFT", showCataReps, "BOTTOMLEFT")
    showWoDReps:SetPoint("TOPLEFT", showPandariaReps, "BOTTOMLEFT")
    showLegionReps:SetPoint("TOPLEFT", showWoDReps, "BOTTOMLEFT")
    showBfAReps:SetPoint("TOPLEFT", showLegionReps, "BOTTOMLEFT")
    showSLReps:SetPoint("TOPLEFT", showBfAReps, "BOTTOMLEFT")
    showSLCovenants:SetPoint("TOPLEFT", showSLReps, "BOTTOMLEFT")
    showDFRenownReps:SetPoint("TOPLEFT", showSLCovenants, "BOTTOMLEFT")
    showDFOtherReps:SetPoint("TOPLEFT", showDFRenownReps, "BOTTOMLEFT")

    hideEventTab:SetPoint("TOPLEFT", eventTitle, "BOTTOMLEFT", 0, -10)
    showFFAWQTimer:SetPoint("TOPLEFT", hideEventTab, "BOTTOMLEFT")
    showLegionInvasionTimer:SetPoint("TOPLEFT", showFFAWQTimer, "BOTTOMLEFT")
    showArathiWFTimer:SetPoint("TOPLEFT", showLegionInvasionTimer, "BOTTOMLEFT")
    showDarkshoreWFTimer:SetPoint("TOPLEFT", showArathiWFTimer, "BOTTOMLEFT")
    showBfaAssaultTimer:SetPoint("TOPLEFT", showDarkshoreWFTimer, "BOTTOMLEFT")
    showNzothAssaults:SetPoint("TOPLEFT", showBfaAssaultTimer, "BOTTOMLEFT")
    showSummonDepthsTimer:SetPoint("TOPLEFT", showNzothAssaults, "BOTTOMLEFT")
    showMawAssaultTimer:SetPoint("TOPLEFT", showSummonDepthsTimer, "BOTTOMLEFT")
    showBeastwarrensHuntTimer:SetPoint("TOPLEFT", showMawAssaultTimer, "BOTTOMLEFT")
    showTormentorsTimer:SetPoint("TOPLEFT", showBeastwarrensHuntTimer, "BOTTOMLEFT")
    showTimeRiftsTimer:SetPoint("TOPLEFT", showTormentorsTimer, "BOTTOMLEFT")
    showStormsFuryTimer:SetPoint("TOPLEFT", showTimeRiftsTimer, "BOTTOMLEFT")
    showDragonbaneKeepTimer:SetPoint("TOPLEFT", showStormsFuryTimer, "BOTTOMLEFT")
    showFeastTimer:SetPoint("TOPLEFT", showDragonbaneKeepTimer, "BOTTOMLEFT")
    showHuntsTimer:SetPoint("TOPLEFT", showFeastTimer, "BOTTOMLEFT")
    showZCZones:SetPoint("TOPLEFT", showHuntsTimer, "BOTTOMLEFT")
    showDreamsurgesTimer:SetPoint("TOPLEFT", showZCZones, "BOTTOMLEFT")
    showSuffusionCampTimer:SetPoint("TOPLEFT", showDreamsurgesTimer, "BOTTOMLEFT")
    showElementalStormsTimer:SetPoint("TOPLEFT", showSuffusionCampTimer, "BOTTOMLEFT")
    showFroststoneStormTimer:SetPoint("TOPLEFT", showElementalStormsTimer, "BOTTOMLEFT")

    showLegendaryAlbumTimer:SetPoint("TOPLEFT", eventTitle, "BOTTOMLEFT", 400, -10)
    showResearchersUnderFireTimer:SetPoint("TOPLEFT", showLegendaryAlbumTimer, "BOTTOMLEFT")
    showSuperbloomTimer:SetPoint("TOPLEFT", showResearchersUnderFireTimer, "BOTTOMLEFT")
    showBigDigTimer:SetPoint("TOPLEFT", showSuperbloomTimer, "BOTTOMLEFT")
    showBeledarShiftTimer:SetPoint("TOPLEFT", showBigDigTimer, "BOTTOMLEFT")

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