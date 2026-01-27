MC = {}

MC.mainFrame = CreateFrame("Frame", "MasterCollectorMain", UIParent, "BackdropTemplate")
MC.mainFrame:SetSize(305, 200)
MC.mainFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 0, 1000)

MC.txtFrameTitle = MC.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
MC.txtFrameTitle:SetPoint("TOP", MC.mainFrame, "TOP", 0, -10)

MC.mainFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MC.mainFrame:RegisterEvent("UPDATE_INSTANCE_INFO")
MC.mainFrame:RegisterEvent("ENCOUNTER_END")
MC.mainFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
MC.mainFrame:RegisterEvent("ADDON_LOADED")
MC.mainFrame:RegisterEvent("COVENANT_CHOSEN")
MC.mainFrame:RegisterEvent("CINEMATIC_START")
MC.mainFrame:RegisterEvent("PLAY_MOVIE")
MC.mainFrame:RegisterEvent("ZONE_CHANGED_NEW_AREA")

MC.defaultValues = {
    fontSize = 12.00,
    hideBossesWithMountsObtained = true,
    showBossesWithNoLockout = true,
    islocked = false,
    bossFilter = "",
    greenFontColor = { 0, 1, 0 },
    redFontColor = { 1, 0, 0 },
    goldFontColor = { 1, 0.82, 0 },
    blueFontColor = { 0, 0.6666667, 1 },
    backdropAlpha = 0.4,
    lastActiveTab = "Weekly\nLockouts",
    hideMinimapIcon = false,
    frameVisible = true,
    showBackdropBorder = true,
    showRarityDetail = true,
    showMountName = true,
    hideWeeklyTab = false,
    hideDailyTab = false,
    hideDailyRepTab = false,
    hideGrindMountsTab = true,
    hideEventTab = false,
    showGarrisonInvasions = true,
    showTWWDungeons = true,
    showDFDungeons = true,
    showSLWeeklyDungeons = true,
    showLegionDungeons = true,
    showBFADungeons = true,
    showSLRaids = true,
    showBFARaids = true,
    showLegionRaids = true,
    showWoDRaids = true,
    showPandariaRaids = true,
    showCataRaids = true,
    showWOTLKRaids = true,
    showBCRaids = true,
    showBFAWorldBosses = true,
    showWoDWorldBosses = true,
    showPandariaWorldBosses = true,
    showTBCDungeons = true,
    showWOTLKDungeons = true,
    showCataDungeons = true,
    showTanaanRares = true,
    showArgusRares = true,
    showArathiRares = true,
    showDarkshoreRares = true,
    showMechagonRares = true,
    showNazRares = true,
    showUldumRares = true,
    showValeRares = true,
    showSLRares = true,
    showCovenantRares = true,
    showCallings = true,
    showTWWRares = true,
    showClassicDailies = true,
    showBfaDailies = true,
    showSLDailies = true,
    showTBCReps = true,
    showWOTLKReps = true,
    showCataReps = true,
    showPandariaReps = true,
    showWoDReps = true,
    showLegionReps = true,
    showBfAReps = true,
    showSLReps = true,
    showSLCovenants = true,
    showDFRenownReps = true,
    showFFAWQTimer = true,
    showLegionInvasionTimer = true,
    showArathiWFTimer = true,
    showDarkshoreWFTimer = true,
    showBfaAssaultTimer = true,
    showSummonDepthsTimer = true,
    showMawAssaultTimer = true,
    showBeastwarrensHuntTimer = true,
    showTormentorsTimer = true,
    showTimeRiftsTimer = true,
    showStormsFuryTimer = true,
    showDragonbaneKeepTimer = true,
    showFeastTimer = true,
    showHuntsTimer = true,
    showDreamsurgesTimer = true,
    showSuffusionCampTimer = true,
    showElementalStormsTimer = true,
    showFroststoneStormTimer = true,
    showLegendaryAlbumTimer = true,
    showResearchersUnderFireTimer = true,
    showSuperbloomTimer = true,
    showBigDigTimer = true,
    showBeledarShiftTimer = true,
    showDFWeeklies = true,
    showDFRaids = true,
    showDFDailies = true,
    cinematicSkip = false,
    showZCZones = true,
    showDFOtherReps = true,
    showArgentDailies = true,
    showBrunnhildarDailies = true,
    showWoDDailies = true,
    showNzothAssaults = true,
    showTWWRaids = true,
    showTWWRenownReps = true,
    showTWWOtherReps = true,
}

MasterCollectorSV = MasterCollectorSV or {}

MC.checkboxNames = {
    "hideBossesWithMountsObtained",
    "showBossesWithNoLockout",
    "hideMinimapButton",
    "showBackdropBorder",
    "showRarityDetail",
    "showMountName",
    "hideWeeklyTab",
    "hideDailyTab",
    "hideDailyRepTab",
    "hideGrindMountsTab",
    "hideEventTab",
    "showGarrisonInvasions",
    "showTWWDungeons",
    "showDFDungeons",
    "showSLWeeklyDungeons",
    "showLegionDungeons",
    "showBFADungeons",
    "showSLRaids",
    "showBFARaids",
    "showLegionRaids",
    "showWoDRaids",
    "showPandariaRaids",
    "showCataRaids",
    "showWOTLKRaids",
    "showBCRaids",
    "showBFAWorldBosses",
    "showWoDWorldBosses",
    "showPandariaWorldBosses",
    "showTBCDungeons",
    "showWOTLKDungeons",
    "showCataDungeons",
    "showTanaanRares",
    "showArgusRares",
    "showArathiRares",
    "showDarkshoreRares",
    "showMechagonRares",
    "showNazRares",
    "showUldumRares",
    "showValeRares",
    "showSLRares",
    "showCovenantRares",
    "showCallings",
    "showTWWRares",
    "showClassicDailies",
    "showBfaDailies",
    "showSLDailies",
    "showTBCReps",
    "showWOTLKReps",
    "showCataReps",
    "showPandariaReps",
    "showWoDReps",
    "showLegionReps",
    "showBfAReps",
    "showSLReps",
    "showSLCovenants",
    "showDFRenownReps",
    "showFFAWQTimer",
    "showLegionInvasionTimer",
    "showArathiWFTimer",
    "showDarkshoreWFTimer",
    "showBfaAssaultTimer",
    "showSummonDepthsTimer",
    "showMawAssaultTimer",
    "showBeastwarrensHuntTimer",
    "showTormentorsTimer",
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
    "showBeledarShiftTimer",
    "showDFWeeklies",
    "showDFRaids",
    "showDFDailies",
    "cinematicSkip",
    "showZCZones",
    "showDFOtherReps",
    "showTWWRenownReps",
    "showTWWOtherReps",
    "showArgentDailies",
    "showBrunnhildarDailies",
    "showWoDDailies",
    "showNzothAssaults",
    "showTWWRaids",
}

function MC.colorsToHex(color)
    if not color or type(color) ~= "table" or #color ~= 3 then
        return "|cffffffff"
    end
    return string.format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
end

local ADDON_NAME = ...

AddonCompartmentFrame:RegisterAddon({
    text = C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"),
    icon = C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture"),
    registerForAnyClick = true,
    notCheckable = true,
    func = function(_, inputData)
        if inputData.buttonName == "RightButton" then
            Settings.OpenToCategory(MC.mainOptionsCategory:GetID())
        else
            if MC.mainFrame:IsVisible() then
                MC.mainFrame:Hide()
                MasterCollectorSV.frameVisible = false
            else
                MC.mainFrame:Show()
                MasterCollectorSV.frameVisible = true
                if MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
                    MC.RefreshMCEvents()
                end
            end
        end
    end,
    funcOnEnter = function(menuItem)
        GameTooltip:SetOwner(menuItem, "ANCHOR_CURSOR")
        GameTooltip:SetText("|T" .. C_AddOns.GetAddOnMetadata(ADDON_NAME, "IconTexture") .. ":0|t " .. C_AddOns.GetAddOnMetadata(ADDON_NAME, "Title"))
        GameTooltip:AddLine("Left Click: Show/Hide Master Collector", nil, nil, nil, true)
        GameTooltip:AddLine("Right Click: Open Options", nil, nil, nil, true)
        GameTooltip:Show()
    end,
    funcOnLeave = function()
        GameTooltip:Hide()
    end,
})

function MC.OnSlashCommand(msg)
msg = string.lower(strtrim(msg or ""))

    if msg == "options" then
        if MC.mainOptionsCategory and Settings then
            Settings.OpenToCategory(MC.mainOptionsCategory:GetID())
        else
            print("|cffff0000MasterCollector Error:|r Options not loaded yet. Please try again after the addon has fully initialized.")
        end

    elseif msg == "toggle" then
        if MC.mainFrame:IsVisible() then
            MC.mainFrame:Hide()
            MasterCollectorSV.frameVisible = false
        else
            MC.mainFrame:Show()
            MasterCollectorSV.frameVisible = true
            if MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
                MC.RefreshMCEvents()
            end
        end

    else
        print("Usage:")
        print("|cffffff00/mc options|r - Open the MasterCollector options panel")
        print("|cffffff00/mc toggle|r - Show or hide the MasterCollector main window")
    end
end

SLASH_MASTERCOLLECTOR1 = "/mc"
SlashCmdList["MASTERCOLLECTOR"] = MC.OnSlashCommand

function MC.InitializeColors()
    -- Initialize the hex values from saved variables
    local goldColor = MasterCollectorSV["goldFontColor"] or { 1, 1, 1 }
    local greenColor = MasterCollectorSV["greenFontColor"] or { 1, 1, 1 }
    local redColor = MasterCollectorSV["redFontColor"] or { 1, 1, 1 }
    local blueColor = MasterCollectorSV["blueFontColor"] or { 1, 1, 1 }

    MC.goldHex = MC.colorsToHex(goldColor)
    MC.greenHex = MC.colorsToHex(greenColor)
    MC.redHex = MC.colorsToHex(redColor)
    MC.blueHex = MC.colorsToHex(blueColor)
end

local function handleGrindsUpdate()
    if MasterCollectorSV.frameVisible then
        if MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
            MC.RefreshMCEvents()
        end
    end
end

local function RefreshMCInstances()
    if MasterCollectorSV.frameVisible then
        if MasterCollectorSV.lastActiveTab == "Anytime\nGrinds" then
            C_Timer.After(60, MC.grinds)
        end
    end
end

local cinematicHandled = false
MC.mainFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" and ... == "MasterCollector" then
        for key, value in pairs(MC.defaultValues) do
            if MasterCollectorSV[key] == nil then
                MasterCollectorSV[key] = value
            end
        end

        MC.InitializeFramePosition()
        MC.CreateOptions()
        MC.CreateMinimapButton()
        MC.InitializeLockState()
        MC.UpdateTabVisibility()
        MC.UpdateTabPositions()
        MC.UpdateMainFrameSize()
        MC.InitializeColors()

        print(string.format("|cffffff00MasterCollector Loaded. |rCinematic skipping is %s. Use |cffffff00/mc|r for commands.", MasterCollectorSV.cinematicSkip and "|cff00ff00enabled|r" or "|cffff0000disabled|r"))
    end

    if event == "PLAYER_ENTERING_WORLD" or event == "UPDATE_INSTANCE_INFO" or event == "ENCOUNTER_END" or event == "PLAYER_REGEN_ENABLED" or event == "ZONE_CHANGED_NEW_AREA" or event == "COVENANT_CHOSEN" then
        MC.InitializeColors()
        MC.weeklyDisplay()
        MC.repsDisplay()
        MC.dailiesDisplay()
        handleGrindsUpdate()
        RefreshMCInstances()
    end

    if event == "CINEMATIC_START" or event == "PLAY_MOVIE" then
        if MasterCollectorSV.cinematicSkip and not cinematicHandled then
            cinematicHandled = true
            C_Timer.After(1.5, function()
                if event == "CINEMATIC_START" then
                    if CinematicFrame and CinematicFrame:IsShown() then
                        CinematicFrame_CancelCinematic()
                        print("|cffffff00MasterCollector|r: Skipping cinematic")
                    end
                elseif event == "PLAY_MOVIE" then
                    if MovieFrame and MovieFrame:IsShown() then
                        MovieFrame:Hide()
                        print("|cffffff00MasterCollector|r: Skipping cinematic")
                    end
                end
                cinematicHandled = false
            end)
        end
    end
end)

CinematicFrame:HookScript("OnShow", function()
    if MasterCollectorSV.cinematicSkip then
        C_Timer.After(1, function()
            if CinematicFrame:IsShown() then
                cinematicHandled = true
                CinematicFrame_CancelCinematic()
                print("|cffffff00MasterCollector|r: Skipping cinematic")
                cinematicHandled = false
            end
        end)
    end
end)