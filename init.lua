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
MC.mainFrame:RegisterEvent("START_LOOT_ROLL")
MC.mainFrame:RegisterEvent("PLAYER_UPDATE_RESTING")
MC.mainFrame:RegisterEvent("CHAT_MSG_SYSTEM")
MC.mainFrame:RegisterEvent("QUEST_TURNED_IN")

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
    hideGrindMountsTab = false,
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
    lootRoller = false,
    graphicsConfig = {
        graphicsShadowQuality = { enabled = false, level = 1 },
        graphicsLiquidDetail = { enabled = false, level = 1 },
        graphicsParticleDensity = { enabled = false, level = 1 },
        graphicsSSAO = { enabled = false, level = 1 },
        graphicsDepthEffects = { enabled = false, level = 1 },
        graphicsComputeEffects = { enabled = false, level = 1 },
        graphicsOutlineMode = { enabled = false, level = 1 },
        graphicsTextureResolution = { enabled = false, level = 1 },
        graphicsSpellDensity = { enabled = false, level = 1 },
        graphicsProjectedTextures = { enabled = false, level = 1 },
        graphicsViewDistance = { enabled = false, level = 0 },
        graphicsEnvironmentDetail = { enabled = false, level = 0 },
        graphicsGroundClutter = { enabled = false, level = 0 },
    },
    graphicsCityOverride = false,
    graphicsInstanceOverride = false,
    autoLootCheck = true,
    showLockouts = true,
    showIslandExpeditions = true,
    showFishing = true,
    showNormalInstances = true,
    showAchievements = true,
    showPVP = true,
    showClassicPVP = true,
    showTBCPVP = true,
    showWOTLKPVP = true,
    showCataPVP = true,
    showMOPPVP = true,
    showWODPVP = true,
    showLegionPVP = true,
    showBFAPVP = true,
    showSLPVP = true,
    showDFPVP = true,
    showTWWPVP = true,
    showWOTLKAchieves = true,
    showCataAchieves = true,
    showMOPAchieves = true,
    showWODAchieves = true,
    showLegionAchieves = true,
    showBFAAchieves = true,
    showSLAchieves = true,
    showDFAchieves = true,
    showTWWAchieves = true,
    showLegionRemix = true,
    showProtoform = true
}

MasterCollectorSV = MasterCollectorSV or {}
MasterCollectorSV.realmLocks = MasterCollectorSV.realmLocks or {}
MC.DungeonEntranceCoords = MC.DungeonEntranceCoords or {}
MasterCollectorSV.SLRepeatCounts = MasterCollectorSV.SLRepeatCounts or {}

MC.graphicsUIElements = {}

if MasterCollectorSV.graphicsConfig == nil then
    MasterCollectorSV.graphicsConfig = {}
end

for key, defaultValue in pairs(MC.defaultValues.graphicsConfig) do
    if MasterCollectorSV.graphicsConfig[key] == nil then
        MasterCollectorSV.graphicsConfig[key] = CopyTable(defaultValue)
    end
end

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
    "lootRoller",
    "graphicsCityOverride",
    "graphicsInstanceOverride",
    "autoLootCheck",
    "showLockouts",
    "showIslandExpeditions",
    "showFishing",
    "showNormalInstances",
    "showAchievements",
    "showPVP",
    "showClassicPVP",
    "showTBCPVP",
    "showWOTLKPVP",
    "showCataPVP",
    "showMOPPVP",
    "showWODPVP",
    "showLegionPVP",
    "showBFAPVP",
    "showSLPVP",
    "showDFPVP",
    "showTWWPVP",
    "showWOTLKAchieves",
    "showCataAchieves",
    "showMOPAchieves",
    "showWODAchieves",
    "showLegionAchieves",
    "showBFAAchieves",
    "showSLAchieves",
    "showDFAchieves",
    "showTWWAchieves",
    "showLegionRemix",
    "showProtoform"
}

MC.parentCheckboxes = {
    "showTBCExpansion",
    "showWOTLKExpansion",
    "showCataExpansion",
    "showPandaExpansion",
    "showWoDExpansion",
    "showLegionExpansion",
    "showBFAExpansion",
    "showSLExpansion",
    "showDFExpansion",
    "showTWWExpansion"
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

MC.wasInInstance = false
MC.lastSaveTime = 0
MC.Reset = MC.Reset or {}

function MC.CheckInstanceLimit()
    local playerRealm = GetRealmName()
    local liveLocks = #MasterCollectorSV.realmLocks[playerRealm]
    local lastWarningTime = 0

    if liveLocks >= 8 then
        local now = time()
        if now - lastWarningTime > 60 then
            print(string.format("MasterCollector |cffffff00Warning:|r You've entered %d instances recently. You are nearing the Realm 10 x instances per hour limit.", liveLocks))
            lastWarningTime = now
        end
    end
end

function MC.OnInstanceCheck()
    local inInstance, instanceType = IsInInstance()
    local playerName, playerRealm = UnitName("player"), GetRealmName()
    local character = playerName .. "-" .. playerRealm

    MasterCollectorSV.realmLocks = MasterCollectorSV.realmLocks or {}
    MasterCollectorSV.realmLocks[playerRealm] = MasterCollectorSV.realmLocks[playerRealm] or {}

    if inInstance and (instanceType == "party" or instanceType == "raid") then
        local name, _, difficultyID, difficultyName, _, _, _, _, _, LfgDungeonID = GetInstanceInfo()

        MC.currentInstance = {
            name = name,
            difficultyNumber = difficultyID,
            difficulty = difficultyName,
            lfgID = LfgDungeonID,
            character = character,
            reset = time() + 3600,
            timestamp = time()
        }

    elseif not inInstance and MC.wasInInstance then
        MC.SaveRealmLockout()
        MC.CheckInstanceLimit()
        MC.currentInstance = nil
        MC.wasInInstance = false
    end

    MC.wasInInstance = inInstance
end

function MC.SaveRealmLockout()
    if not MC.currentInstance then return end

    local inst = MC.currentInstance
    local playerName, playerRealm = UnitName("player"), GetRealmName()
    local character = playerName .. "-" .. playerRealm
    local allowDuplicates = MC.Reset[inst.name] or false
    local isLFR = inst.difficultyNumber == 7 or inst.difficultyNumber == 17

    if time() - MC.lastSaveTime < 2 then return end
    MC.lastSaveTime = time()

    if not isLFR and not allowDuplicates then
        for _, entry in ipairs(MasterCollectorSV.realmLocks[playerRealm]) do
            if entry.name == inst.name and entry.difficulty == inst.difficulty and entry.character == character then
                return
            end
        end
    end

    table.insert(MasterCollectorSV.realmLocks[playerRealm], {
        name = inst.name,
        difficultyID = inst.difficultyNumber,
        difficulty = inst.difficulty,
        lfgID = inst.lfgID,
        character = character,
        reset = time() + 3600,
        timestamp = time()
    })

    if not isLFR then
        MC.Reset[inst.name] = nil
    end
end

function MC.CheckInstanceResetMessage(msg)
    if not msg then return end

    local pattern = INSTANCE_RESET_SUCCESS:gsub("%%s", "(.+)")
    local instName = msg:match(pattern)
    if not instName then return end

    MC.Reset[instName] = true
end

MC.lastInstanceOverrideState = nil
local cinematicHandled = false
local function InitializeSavedVariables()
    for key, value in pairs(MC.defaultValues) do
        if MasterCollectorSV[key] == nil then
            MasterCollectorSV[key] = value
        end
    end
end

local function InitializeAddon()
    InitializeSavedVariables()

    MC.InitializeFramePosition()
    MC.CreateOptions()
    MC.CreateMinimapButton()
    MC.InitializeLockState()
    MC.UpdateTabVisibility()
    MC.UpdateTabPositions()
    MC.UpdateMainFrameSize()
    MC.InitializeColors()

    print(string.format(
        "|cffffff00MasterCollector Loaded.|r Cinematic skipping is %s. Use |cffffff00/mc|r for commands.",
        MasterCollectorSV.cinematicSkip and "|cff00ff00enabled|r" or "|cffff0000disabled|r"
    ))
end

local function HandleWorldUpdates()
    MC.InitializeColors()
    MC.weeklyDisplay()
    MC.repsDisplay()
    MC.dailiesDisplay()
    handleGrindsUpdate()
    RefreshMCInstances()

    if MC.UpdateActiveIslands then
        MC.UpdateActiveIslands()
    end
end

local function HandleInstanceGraphics()
    if not MasterCollectorSV.graphicsInstanceOverride then return end

    local inInstance, instanceType = IsInInstance()
    local shouldEnable = inInstance and (instanceType == "party" or instanceType == "raid")

    if MC.lastInstanceOverrideState == shouldEnable then return end
    MC.lastInstanceOverrideState = shouldEnable

    if shouldEnable then
        MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
        print("|cFF00FF00MasterCollector Graphics Instance Override is ENABLED|r")
    else
        MC.RestoreGraphics()
        print("|cFFFF0000MasterCollector Graphics Instance Override is DISABLED|r")
    end
end

local function HandleCityGraphics()
    if not MasterCollectorSV.graphicsCityOverride then return end

    if IsResting() then
        MC.ApplyDynamicGraphics(MasterCollectorSV.graphicsConfig)
        print("|cFF00FF00MasterCollector Graphics City Override is ENABLED|r")
    else
        MC.RestoreGraphics()
        print("|cFFFF0000MasterCollector Graphics City Override is DISABLED|r")
    end
end

local function HandleAutoLoot()
    SetCVar("autoLootDefault", MasterCollectorSV.autoLootCheck and "1" or "0")
end

local function HandleLootRoll(rollID)
    if not MasterCollectorSV.lootRoller then return end

    local _, _, _, _, _, canNeed, canGreed = GetLootRollItemInfo(rollID)
    local itemLink = GetLootRollItemLink(rollID)
    if not itemLink then return end

    local _, _, _, _, _, itemType = C_Item.GetItemInfo(itemLink)
    local isGear = itemType == "Weapon" or itemType == "Armor"
    local isTransmogUnknown = false

    if C_TransmogCollection and C_TransmogCollection.PlayerCanCollectSource then
        local _, sourceID = C_TransmogCollection.GetItemInfo(itemLink)
        if sourceID then
            isTransmogUnknown = not C_TransmogCollection.PlayerHasTransmogItemModifiedAppearance(sourceID)
        end
    end

    if canNeed and (not isGear or isTransmogUnknown) then
        RollOnLoot(rollID, 1) -- NEED
    elseif canGreed then
        RollOnLoot(rollID, 2) -- GREED
    else
        RollOnLoot(rollID, 4) -- PASS
    end
end

local function HandleCinematic(event)
    if not MasterCollectorSV.cinematicSkip then return end
    if cinematicHandled then return end

    cinematicHandled = true

    for i = 1, 5 do
        C_Timer.After(1.5 * i, function()
            if event == "CINEMATIC_START" then
                if CinematicFrame and CinematicFrame:IsShown() then
                    CinematicFrame_CancelCinematic()
                    print("|cffffff00MasterCollector|r: Skipping cinematic")
                    cinematicHandled = false
                end
            elseif event == "PLAY_MOVIE" then
                if MovieFrame and MovieFrame:IsShown() then
                    MovieFrame:Hide()
                    print("|cffffff00MasterCollector|r: Skipping cinematic")
                    cinematicHandled = false
                end
            end
        end)
    end
end

local function HandleQuestTurnedIn(questID)
    if not MC.dailySLActivities then return end

    for _, entry in ipairs(MC.dailySLActivities) do
        local mode      = entry[1]
        local questData = entry[2]

        -- Only handle repeat-style entries
        if mode == "SEQUENTIAL_REPEAT" then
            for _, step in ipairs(questData) do
                local stepQuestID = step[1]

                if questID == stepQuestID then
                    MasterCollectorSV.SLRepeatCounts[stepQuestID] =
                        (MasterCollectorSV.SLRepeatCounts[stepQuestID] or 0) + 1
                    return
                end
            end
        end
    end
end

local EVENT_HANDLERS = {}
EVENT_HANDLERS.ADDON_LOADED = function(addonName)
    if addonName == "MasterCollector" then
        InitializeAddon()
    end
end

EVENT_HANDLERS.CHAT_MSG_SYSTEM = function(msg)
    MC.CheckInstanceResetMessage(msg)
end

EVENT_HANDLERS.START_LOOT_ROLL = function(rollID)
    HandleLootRoll(rollID)
end

EVENT_HANDLERS.CINEMATIC_START = function()
    HandleCinematic("CINEMATIC_START")
end

EVENT_HANDLERS.PLAY_MOVIE = function()
    HandleCinematic("PLAY_MOVIE")
end

EVENT_HANDLERS.QUEST_TURNED_IN = function(questID)
    HandleQuestTurnedIn(questID)
end

local WORLD_EVENTS = {
    PLAYER_ENTERING_WORLD = true,
    UPDATE_INSTANCE_INFO  = true,
    ENCOUNTER_END         = true,
    PLAYER_REGEN_ENABLED  = true,
    ZONE_CHANGED_NEW_AREA = true,
    COVENANT_CHOSEN       = true,
}

local INSTANCE_EVENTS = {
    PLAYER_ENTERING_WORLD = true,
    UPDATE_INSTANCE_INFO  = true,
}

local CITY_EVENTS = {
    PLAYER_UPDATE_RESTING = true,
    PLAYER_ENTERING_WORLD = true,
}

MC.mainFrame:SetScript("OnEvent", function(self, event, ...)
    if EVENT_HANDLERS[event] then
        EVENT_HANDLERS[event](...)
    end

    if WORLD_EVENTS[event] then
        HandleWorldUpdates()
    end

    if INSTANCE_EVENTS[event] then
        MC.OnInstanceCheck()
        HandleInstanceGraphics()
        HandleAutoLoot()
    end

    if CITY_EVENTS[event] then
        HandleCityGraphics()
    end
end)