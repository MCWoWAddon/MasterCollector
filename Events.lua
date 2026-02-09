function MC.events()
    if MC.currentTab ~= "Event\nGrinds" then
        return
    end

    MC.InitializeColors()
    local wowheadIcon = "Interface\\AddOns\\MasterCollector\\wowhead.png"

    local fontSize = MasterCollectorSV.fontSize

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont("P", font, fontSize, flags)
    end

    function MC.RefreshMCEvents()
        if MasterCollectorSV.frameVisible and MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
            MC.events()
            C_Timer.After(60, MC.RefreshMCEvents)
        end
    end

    local function GetRarityAttempts(itemName)
        if not RarityDB or not RarityDB.profiles or not RarityDB.profiles["Default"] then
            return nil
        end

        local profile = RarityDB.profiles["Default"]
        if not profile.groups then
            return nil
        end

        for groupType, groupData in pairs(profile.groups) do
            for name, itemData in pairs(groupData) do
                if name == itemName then
                    return itemData.attempts or 0
                end
            end
        end
        return 0
    end

    local playerRegion = GetCurrentRegion()
    local realmTime = GetServerTime()

    local function FormatTime(seconds)
        if not seconds then
            return ""
        end

        local days = math.floor(seconds / 86400) or 0 or nil
        local hours = math.floor((seconds % 86400) / 3600)
        local minutes = math.floor((seconds % 3600) / 60)

        if days == 0 and hours == 0 then
            return string.format("%02d Min", minutes)
        elseif days == 0 then
            return string.format("%02d Hrs %02d Min", hours, minutes)
        else
            return string.format("%02d Days %02d Hrs %02d Min", days, hours, minutes)
        end
    end

    local function ffaAchieveWQs()
        local ffaQuestIDs = {
            [42023] = "Black Rook Rumble",        -- Val'sharah
            [42025] = "Bareback Brawl",           -- Stormheim
            [41896] = "Operation Murloc Freedom", -- Azsuna
            [41013] = "Darkbrul Arena",           -- Highmountain
        }

        local ffaMapIDs = {
            [42023] = 641, -- Val'sharah
            [42025] = 634, -- Stormheim
            [41896] = 630, -- Azsuna
            [41013] = 650, -- Highmountain
        }

        local achieveID, achieveName = GetAchievementInfo(11474)
        local WQtext = string.format("%s|Hachievement:%d|h[%s]|h Achievement WQ Active:|r\n", MC.goldHex, achieveID, achieveName)
        local foundWQ = false
        local worldQuestsUnlocked = C_QuestLog.IsQuestFlaggedCompleted(45727)

        local faction = UnitFactionGroup("player")
        local mountID

        if faction == "Alliance" then
            mountID = 775
        elseif faction == "Horde" then
            mountID = 784
        end

        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)

        if MasterCollectorSV.showFFAWQTimer then
            for questID, questName in pairs(ffaQuestIDs) do
                local mapID = ffaMapIDs[questID]
                local taskInfo = C_TaskQuest.GetQuestsOnMap(mapID)

                if taskInfo then
                    for _, info in ipairs(taskInfo) do
                        local questId = info and info.questID
                        if questID and HaveQuestData(questId) and QuestUtils_IsQuestWorldQuest(questId) then
                            if questId == questID then
                                local mapName = C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name or "Fetching Map Failed, Retrying in 60 Seconds."
                                local duration = C_TaskQuest.GetQuestTimeLeftSeconds(questId)

                                WQtext = WQtext .. string.format("%s%s: %s\n%sTime Remaining: %s\n", string.rep(" ", 4), mapName, questName, string.rep(" ", 4), FormatTime(duration))
                                foundWQ = true

                                if MasterCollectorSV.showMountName then
                                    WQtext = WQtext .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon)
                                end
                            end
                        end
                    end
                end
            end

            if not foundWQ then
                if not worldQuestsUnlocked then
                    WQtext = WQtext .. "   Uniting the Isles not yet completed - please complete.\n"
                else
                    WQtext = WQtext .. "   No active World Quests available.\n"
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return WQtext
            end
        end
    end

    local function GetLegionInvasionStatus()
        local mapToInvasionIDs = {
            [630] = 5175, -- Azsuna
            [641] = 5210, -- Val'sharah
            [650] = 5177, -- Highmountain
            [634] = 5178  -- Stormheim
        }

        local classMounts = {
            ["Death Knight"] = { 866 },
            ["Paladin"] = { 885, 892, 893, 894 },
            ["Rogue"] = { 884, 889, 890, 891 },
            ["Monk"] = { 864 },
            ["Warrior"] = { 867 },
            ["Shaman"] = { 888 },
            ["Hunter"] = { 865, 870, 872 },
            ["Warlock"] = { 898, 930, 931 },
            ["Priest"] = { 861 },
            ["Mage"] = { 860 },
            ["Demon Hunter"] = { 868 }
        }

        local allCollected = true
        local mapIDs = { 630, 641, 650, 634 }
        local baseTime = playerRegion == 1 and 1727901000 or (playerRegion == 3 and 1729870200)
        local interval = 66600 -- 18.5 hrs in seconds
        local duration = 21600 -- 6 hrs in seconds
        local elapsedTime = (realmTime - baseTime) % interval
        local nextInvasionTime = realmTime - elapsedTime + interval
        local currentMapIndex = math.floor((realmTime - baseTime) / interval) % #mapIDs + 1
        local className = UnitClass("player")
        local invasionText = ""
        local timeLeft, currentMapName
        local achieveID, achieveName, _, achieved = GetAchievementInfo(11546)

        local function getMountNamesByClass(class)
            local mountNames = {}
            local uncollectedMounts = {}
            local mountIDs = classMounts[class] or {}

            for _, mountID in ipairs(mountIDs) do
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                if mountName then
                    local link = string.format("%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h", MC.blueHex, mountID, mountName, mountID, wowheadIcon)
                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, link)
                    end
                    table.insert(mountNames, link)
                end
            end

            if not allCollected then
                return table.concat(uncollectedMounts, ", ")
            else
                return table.concat(mountNames, ", ")
            end
        end

        local mountNamesString = getMountNamesByClass(className)

        local function GetInvasionInfo(mapID)
            local mapInvasionID = mapToInvasionIDs[mapID]
            if not mapInvasionID then return nil, "Fetching Map Failed, Retrying in 60 Seconds." end
            local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapInvasionID)
            local mapInfo = C_Map.GetMapInfo(mapID)
            return seconds, mapInfo and mapInfo.name or "Fetching Map Failed, Retrying in 60 Seconds."
        end

        if MasterCollectorSV.showLegionInvasionTimer then
            for _, mapID in ipairs(mapIDs) do
                timeLeft, currentMapName = GetInvasionInfo(mapID)
                if timeLeft and timeLeft > 0 then
                    local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                    local _, nextMapName = GetInvasionInfo(mapIDs[nextMapIndex])
                    invasionText = string.format("%sCurrent Legion Invasion: |r%s (%s Remaining)\n%sRequired for |Hachievement:%d|h[%s]|h Achievement\n\n", MC.goldHex, currentMapName, FormatTime(timeLeft), string.rep(" ", 4), achieveID, achieveName)

                    if MasterCollectorSV.showMountName then
                        invasionText = invasionText .. string.format("%sClass Mounts (%s): %s\n\n", string.rep(" ", 4), className, mountNamesString)
                    end

                    invasionText = invasionText .. string.format("%sNext Legion Invasion: |r%s\n", MC.goldHex, (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds."))
                    break
                end
            end

            if not invasionText then
                if elapsedTime < duration then
                    invasionText = string.format("%sLegion Invasion Active: |r%s\n%sRequired for |Hachievement:%d|h[%s]|h Achievement\n\n", MC.goldHex, FormatTime(duration - elapsedTime), string.rep(" ", 4), achieveID, achieveName)
                else
                    local timeUntilNext = nextInvasionTime - realmTime
                    local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                    local _, nextMapName = GetInvasionInfo(mapIDs[nextMapIndex])
                    invasionText = string.format("%sNext Legion Invasion: |r%s in %s\n", MC.goldHex, (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds."), FormatTime(timeUntilNext))
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not achieved then
                return invasionText
            end
        end
    end

    local function IsSpiritOfEcheroActive()
        local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()
        local year = currentCalendarTime.year
        local month = currentCalendarTime.month
        local day = currentCalendarTime.monthDay
        local startDates = {
            [2017] = { { 16, 8 } },
            [2018] = { { 14, 2 }, { 15, 8 } },
            [2019] = { { 13, 2 }, { 14, 8 } },
            [2020] = { { 12, 2 }, { 12, 8 } },
            [2021] = { { 10, 2 }, { 11, 8 } },
            [2022] = { { 9, 2 }, { 10, 8 } },
            [2023] = { { 8, 2 }, { 9, 8 } },
            [2024] = { { 7, 2 }, { 7, 8 } },
            [2025] = { { 5, 2 }, { 6, 8 } },
            [2026] = { { 4, 2 }, { 5, 8 } },
            [2027] = { { 3, 2 }, { 4, 8 } },
        }

        local eventDates = startDates[year]
        if not eventDates then
            return false
        end

        for _, date in ipairs(eventDates) do
            local startDay, eventMonth = date[1], date[2]
            local endDay = startDay + 13

            if month == eventMonth and day >= startDay and day <= endDay then
                return true
            end
        end

        return false
    end

    local function BuildRareMountText(expansionName, raresData)
        local playerFaction = UnitFactionGroup("player")
        local expansionText = ""
        local uncollectedMounts = {}

        for _, rareData in ipairs(raresData) do
            local questIDs = rareData[1]
            local mountIDs = rareData[2]
            local itemName = rareData[3]
            local dropChanceDenominator = rareData[4]
            local rareName = rareData[5]
            local factionRestriction = rareData[6]

            local allKilled = true
            local individualRaresText = ""
            local hasUncollectedMounts = false

            if type(questIDs) ~= "table" then
                questIDs = { questIDs }
            end

            local rareNames = { strsplit("/", rareName) }

            if #questIDs == #rareNames then
                for index, questID in ipairs(questIDs) do
                    local name = strtrim(rareNames[index])
                    local isKilled = C_QuestLog.IsQuestFlaggedCompleted(questID)
                    local color = isKilled and MC.greenHex or MC.redHex

                    if not isKilled then
                        allKilled = false
                    end

                    individualRaresText = individualRaresText .. string.format("%s%s%s|r", string.rep(" ", 4), color, name)
                end
            else
                local isKilled = false
                for _, questID in ipairs(questIDs) do
                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                        isKilled = true
                        break
                    end
                end

                if not isKilled then
                    allKilled = false
                end

                local color = isKilled and MC.greenHex or MC.redHex
                individualRaresText = individualRaresText .. string.format("%s%s%s|r", string.rep(" ", 4), color, rareName)
            end

            if type(mountIDs) ~= "table" then
                mountIDs = { mountIDs }
            end

            local mountTexts = {}

            for _, mountID in ipairs(mountIDs) do
                local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
                local mountName = mountInfo[1] or "Unknown Mount"
                local isCollected = mountInfo[11]

                local shouldShow = not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected

                if MasterCollectorSV.showBossesWithNoLockout and allKilled then
                    shouldShow = false
                end

                if not isCollected then
                    hasUncollectedMounts = true
                    table.insert(uncollectedMounts, mountName)
                end

                if shouldShow then
                    local attempts = GetRarityAttempts(itemName) or 0
                    local rarityAttemptsText, dropChanceText = "", ""

                    if MasterCollectorSV.showRarityDetail and dropChanceDenominator and dropChanceDenominator ~= 0 then
                        local chance = 1 / dropChanceDenominator
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                        rarityAttemptsText = string.format(" (Attempts: %d/%s)", attempts, dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                    end

                    table.insert(mountTexts, string.format("%s|r- Mount: |r%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s|r",
                        string.rep(" ", 6), MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText))
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or hasUncollectedMounts then
                if not (MasterCollectorSV.showBossesWithNoLockout and allKilled) then
                    if not factionRestriction or factionRestriction == playerFaction .. " Only" then
                        expansionText = expansionText .. individualRaresText .. "\n"
                        if MasterCollectorSV.showMountName and #mountTexts > 0 then
                            expansionText = expansionText .. table.concat(mountTexts, "\n") .. "\n"
                        end
                    end
                end
            end
        end

        return expansionText, uncollectedMounts
    end

    local function GetActiveWarfrontStatus()
        local warfrontIDs = {
            { id = 11,  name = "Battle for Stromgarde (Arathi Highlands)", faction = "Horde" },
            { id = 116, name = "Battle for Stromgarde (Arathi Highlands)", faction = "Alliance" },
            { id = 117, name = "Battle for Darkshore",                     faction = "Alliance" },
            { id = 118, name = "Battle for Darkshore",                     faction = "Horde" }
        }

        local activeWarfronts = { ["Battle for Stromgarde (Arathi Highlands)"] = nil, ["Battle for Darkshore"] = nil }
        local output = {}
        local playerFaction = UnitFactionGroup("player")

        if not MasterCollectorSV.showArathiWFTimer and not MasterCollectorSV.showDarkshoreWFTimer then
            return nil
        end

        for _, warfront in ipairs(warfrontIDs) do
            local contributionState, _, timeOfNextStateChange = C_ContributionCollector.GetState(warfront.id)

            if warfront.name == "Battle for Stromgarde (Arathi Highlands)" and not MasterCollectorSV.showArathiWFTimer then
                activeWarfronts["Battle for Stromgarde (Arathi Highlands)"] = nil
            end

            if warfront.name == "Battle for Darkshore" and not MasterCollectorSV.showDarkshoreWFTimer then
                activeWarfronts["Battle for Darkshore"] = nil
            end

            if contributionState and contributionState ~= 4 then
                local timeRemaining = timeOfNextStateChange and (timeOfNextStateChange - realmTime) or nil
                local timeRemainingText = timeRemaining and SecondsToTime(math.max(timeRemaining, 0)) or "Awaiting Resources"
                local controlText

                if contributionState == 1 then
                    local oppositeFaction = (warfront.faction == "Horde") and "Alliance" or "Horde"
                    controlText = oppositeFaction .. string.format(" still in Control%s%s Contributing", string.rep(" ", 4), warfront.faction)
                elseif contributionState == 2 then
                    controlText = warfront.faction .. " Controlling"
                elseif contributionState == 3 then
                    controlText = warfront.faction .. " Defending"
                else
                    controlText = "Unknown state"
                end

                activeWarfronts[warfront.name] = string.format("%s%s|r\n%s%s\nTime Left till Status Change: %s\n", MC.goldHex, warfront.name, string.rep(" ", 4), controlText, string.rep(" ", 4), timeRemainingText)
            end
        end

        local playerHordeServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1716).quantity
        local iconHordeServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1716).iconFileID
        local playerAllianceServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1717).quantity
        local iconAllianceServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1717).iconFileID

        local factionMounts = {
            ["Alliance"] = { { 1204, 350 }, { 1216, 750 }, { 1214, 200 } },
            ["Horde"] = { { 1204, 350 }, { 1210, 750 }, { 1215, 200 } },
        }

        local warfrontMounts = {
            ["Arathi Highlands Rares"] = {
                { { 53091, 53517 }, { 1185 }, "Witherbark Direwing",     33, "Nimar the Slayer" },
                { { 53014, 53518 }, { 1182 }, "Lil' Donkey",             33, "Overseer Krix" },
                { { 53022, 53526 }, { 1183 }, "Skullripper",             33, "Skullripper" },
                { { 53083, 53504 }, { 1180 }, "Swift Albino Raptor",     33, "Beastrider Kama" },
                { { 53085 },        { 1174 }, "Highland Mustang",        33, "Doomrider Helgrim",     "Alliance Only", },
                { { 53088 },        { 1173 }, "Broken Highland Mustang", 33, "Knight-Captain Aldrin", "Horde Only" }
            },
            ["Darkshore Rares"] = {
                { { 54695, 54696 }, { 1200 }, "Ashenvale Chimaera",           20, "Alash'anir" },
                { { 54883 },        { 1199 }, "Caged Bear",                   20, "Agathe Wyrmwood",   "Alliance Only" },
                { { 54890 },        { 1199 }, "Blackpaw",                     20, "Blackpaw",          "Horde Only" },
                { { 54886 },        { 1205 }, "Captured Kaldorei Nightsaber", 20, "Croz Bloodrage",    "Alliance Only" },
                { { 54892 },        { 1205 }, "Kaldorei Nightsaber",          20, "Shadowclaw",        "Horde Only" },
                { { 54431 },        { 1203 }, "Umber Nightsaber",             20, "Athil Dewfire",     "Horde Only" },
                { { 54277 },        { 1203 }, "Captured Umber Nightsaber",    20, "Moxo the Beheader", "Alliance Only" }
            },
        }

        local allCollected = true
        local function getMountNamesByFaction(faction)
            local mountDetails = {}
            local uncollectedMounts = {}
            local mountData = factionMounts[faction] or {}

            local playerCurrency, iconCurrency
            if faction == "Alliance" then
                playerCurrency = playerAllianceServiceMedals
                iconCurrency = iconAllianceServiceMedals
            elseif faction == "Horde" then
                playerCurrency = playerHordeServiceMedals
                iconCurrency = iconHordeServiceMedals
            else
                return "Invalid faction."
            end

            local iconSize = CreateTextureMarkup(iconCurrency, 32, 32, 16, 16, 0, 1, 0, 1)

            for _, mount in ipairs(mountData) do
                local mountID = mount[1]
                local cost = mount[2]
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)

                if mountName then
                    local line = string.format("%s%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h %s%s / %s Service Medals %s Required|r\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, MC.goldHex, playerCurrency, cost, iconSize)

                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, line)
                    end
                    table.insert(mountDetails, line)
                end
            end

            if not allCollected then
                return table.concat(uncollectedMounts, string.rep(" ", 4))
            else
                return table.concat(mountDetails, string.rep(" ", 4))
            end
        end

        for warfrontName, warfrontText in pairs(activeWarfronts) do
            if (warfrontName == "Battle for Stromgarde (Arathi Highlands)" and MasterCollectorSV.showArathiWFTimer) or (warfrontName == "Battle for Darkshore" and MasterCollectorSV.showDarkshoreWFTimer) then
                local mountNamesString = getMountNamesByFaction(playerFaction)

                if warfrontText then
                    local warfrontExpansion
                    if warfrontName == "Battle for Stromgarde (Arathi Highlands)" then
                        warfrontExpansion = "Arathi Highlands Rares"
                    elseif warfrontName == "Battle for Darkshore" then
                        warfrontExpansion = "Darkshore Rares"
                    end

                    if warfrontExpansion and warfrontMounts[warfrontExpansion] then
                        local rareText = BuildRareMountText(warfrontExpansion, warfrontMounts[warfrontExpansion])
                        if rareText ~= "" then
                            warfrontText = warfrontText .. string.format("\n%s%s%s|r:\n%s", MC.goldHex, string.rep(" ", 3), warfrontExpansion, rareText)
                        end
                    end

                    if MasterCollectorSV.showMountName then
                        table.insert(output, warfrontText .. string.format("\n%s%sCurrency Mounts for %s: |r\n%s%s", MC.goldHex, string.rep(" ", 4), playerFaction, string.rep(" ", 4), mountNamesString))
                    else
                        table.insert(output, warfrontText)
                    end
                else
                    table.insert(output, string.format("No active Warfront found for %s.", warfrontName))
                end
            end
        end

        if not MasterCollectorSV.hideBossesWithMountsObtained or not allCollected then
            return table.concat(output, "\n")
        end
    end

    local function GetFactionAssaultStatus()
        local mapToAssaultIDs = {
            [942] = 5966, -- Stormsong Valley
            [864] = 5970, -- Vol'dun
            [896] = 5964, -- Drustvar
            [862] = 5973, -- Zuldazar
            [895] = 5896, -- Tiragarde Sound
            [863] = 5969  -- Nazmir
        }

        local mapIDs = { 942, 864, 896, 862, 895, 863 }
        local baseTime = playerRegion == 1 and 1728061200 or (playerRegion == 3 and 1728439200)
        local interval = 68400 -- 19 hrs in seconds
        local duration = 25200 -- 7 hrs in seconds
        local elapsedTime = (realmTime - baseTime) % interval
        local nextAssaultTime = realmTime - elapsedTime + interval
        local cyclesPassed = math.floor((realmTime - baseTime) / interval)
        local currentMapIndex = (cyclesPassed % #mapIDs) + 1
        local playerFaction = UnitFactionGroup("player")

        local function GetAssaultInfo(mapID)
            local mapAssaultID = mapToAssaultIDs[mapID]
            if not mapAssaultID then return nil, "Fetching Map Failed, Retrying in 60 Seconds." end
            local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapAssaultID)
            local mapInfo = C_Map.GetMapInfo(mapID)
            return seconds, mapInfo and mapInfo.name or "Fetching Map Failed, Retrying in 60 Seconds."
        end

        local assaultText = ""
        local timeLeft, currentMapName
        local playerHordeServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1716).quantity
        local iconHordeServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1716).iconFileID
        local playerAllianceServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1717).quantity
        local iconAllianceServiceMedals = C_CurrencyInfo.GetCurrencyInfo(1717).iconFileID

        local factionMounts = {
            ["Alliance"] = { { 1204, 350 }, { 1214, 750 }, { 1216, 200 } },
            ["Horde"] = { { 1204, 350 }, { 1210, 750 }, { 1215, 200 } },
        }

        local allCollected = true
        local function getMountNamesByFaction(faction)
            local mountDetails = {}
            local uncollectedMounts = {}
            local mountData = factionMounts[faction] or {}

            local playerCurrency, iconCurrency
            if faction == "Alliance" then
                playerCurrency = playerAllianceServiceMedals
                iconCurrency = iconAllianceServiceMedals
            elseif faction == "Horde" then
                playerCurrency = playerHordeServiceMedals
                iconCurrency = iconHordeServiceMedals
            else
                return "Invalid faction."
            end

            local iconSize = CreateTextureMarkup(iconCurrency, 32, 32, 16, 16, 0, 1, 0, 1)

            for _, mount in ipairs(mountData) do
                local mountID = mount[1]
                local cost = mount[2]
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)

                if mountName then
                    local line = string.format("%s%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h %s%s / %s Service Medals %s Required|r\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, MC.goldHex, playerCurrency, cost, iconSize)

                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, line)
                    end
                    table.insert(mountDetails, line)
                end
            end

            if not allCollected then
                return table.concat(uncollectedMounts, string.rep(" ", 4))
            else
                return table.concat(mountDetails, string.rep(" ", 4))
            end
        end

        if MasterCollectorSV.showBfaAssaultTimer then
            for _, mapID in ipairs(mapIDs) do
                timeLeft, currentMapName = GetAssaultInfo(mapID)
                if timeLeft and timeLeft > 0 then
                    local mountNamesString = getMountNamesByFaction(playerFaction)
                    assaultText = string.format("%sCurrent Faction Assault: |r%s (%s Remaining)\n", MC.goldHex, currentMapName, FormatTime(timeLeft))

                    if MasterCollectorSV.showMountName then
                        assaultText = assaultText .. string.format("%sMounts for %s:\n%s%s", string.rep(" ", 4), playerFaction, string.rep(" ", 4), mountNamesString)
                    end

                    if not MasterCollectorSV.hideBossesWithMountsObtained or not allCollected then
                        return assaultText
                    end
                end
            end

            if elapsedTime < duration then
                assaultText = string.format("%sFaction Assault Active: |r%s\n", MC.goldHex, FormatTime(duration - elapsedTime))
            else
                local timeUntilNext = nextAssaultTime - realmTime
                local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                local _, nextMapName = GetAssaultInfo(mapIDs[nextMapIndex])
                local mountNamesString = getMountNamesByFaction(playerFaction)
                assaultText = string.format("%sNext Faction Assault: |r%s in %s\n", MC.goldHex, (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds."), FormatTime(timeUntilNext))

                if MasterCollectorSV.showMountName then
                    assaultText = assaultText .. string.format("%sMounts for %s: \n%s%s", string.rep(" ", 4), playerFaction, string.rep(" ", 4), mountNamesString)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not allCollected then
                return assaultText
            end
        end
    end

    local function GetActiveNzothAssaults()
        local majorAssaults = {
            [57157] = "Uldum, The Black Empire Assault",
            [56064] = "Vale of Eternal Blossoms, The Black Empire Assault"
        }

        local minorAssaults = {
            [55350] = "Amathet Advance - Uldum",
            [56308] = "Aqir Unearthed - Uldum",
            [57008] = "Mogu, The Warring Clans - Vale",
            [57728] = "Mantid, The Endless Swarm - Vale"
        }

        local assaultMounts = {
            { { 57363 }, { 1328 }, "Xinlao",                           33,  "Xinlao",                  57008 },
            { { 57344 }, { 1297 }, "Clutch of Ha-Li",                  33,  "Ha-Li",                   57008 },
            { { 57345 }, { 1327 }, "Ren's Stalwart Hound",             33,  "Houndlord Ren",           57008 },
            { { 57346 }, { 1313 }, "Pristine Cloud Serpent Scale",     50,  "Rei Lun",                 57008 },
            { { 57259 }, { 1314 }, "Reins of the Drake of the Four Winds", 100, "Ishak of the Four Winds", 57157 },
            { { 58696 }, { 1319 }, "Malevolent Drone",                 100, "Corpse Eater",            56308 },
            { { 57273 }, { 1317 }, "Waste Marauder",                   33,  "Rotfeaster",              55350 }
        }

        local detectedMajor = "Unknown Major Assault"
        local detectedMinor = "Unknown Minor Assault"
        local majorTimeLeft = nil
        local minorTimeLeft = nil
        local majorMounts = {}
        local minorMounts = {}

        for questID, assaultName in pairs(majorAssaults) do
            if C_TaskQuest.IsActive(questID) then
                detectedMajor = assaultName
                majorTimeLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID)

                for _, mountData in ipairs(assaultMounts) do
                    if mountData[6] == questID then
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountData[2][1])

                        if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                            table.insert(majorMounts, { mountData[2][1], mountName, mountData[4], isCollected })
                        end
                    end
                end

                break
            end
        end

        for questID, assaultName in pairs(minorAssaults) do
            if C_TaskQuest.IsActive(questID) then
                detectedMinor = assaultName
                minorTimeLeft = C_TaskQuest.GetQuestTimeLeftSeconds(questID)

                for _, mountData in ipairs(assaultMounts) do
                    if mountData[6] == questID then
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountData[2][1])

                        if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                            table.insert(minorMounts, { mountData[2][1], mountName, mountData[4], isCollected })
                        end
                    end
                end
                break
            end
        end

        local showMajor = not MasterCollectorSV.hideBossesWithMountsObtained or #majorMounts > 0
        local showMinor = not MasterCollectorSV.hideBossesWithMountsObtained or #minorMounts > 0

        if not MasterCollectorSV.showNzothAssaults or (showMajor and not showMinor) then
            return
        end

        local assaultDisplay = MC.goldHex .. "Current Nzoth Assaults:|r"
        local hasContent = false

        if showMajor then
            assaultDisplay = assaultDisplay .. string.format("\n%sMajor: |r%s\n", string.rep(" ", 4), detectedMajor)
            hasContent = true
            if majorTimeLeft then
                assaultDisplay = assaultDisplay .. string.format("%sTime Remaining: %s\n", string.rep(" ", 4), FormatTime(majorTimeLeft))
            end

            if #majorMounts > 0 then
                for _, mountData in ipairs(majorMounts) do
                    local mountID, mountName, dropChance, itemName = unpack(mountData)
                    local rarityAttemptsText, dropChanceText = "", ""

                    if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                        if MasterCollectorSV.showRarityDetail and dropChance then
                            local chance = 1 / dropChance
                            local attempts = GetRarityAttempts(itemName) or 0
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts, dropChance)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end
                    if MasterCollectorSV.showMountName then
                        assaultDisplay = assaultDisplay .. string.format("%sMount: |r%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                    end
                end
            end
        end

        if showMinor then
            assaultDisplay = assaultDisplay .. string.format("\n%sMinor: |r%s\n", string.rep(" ", 4), detectedMinor)
            hasContent = true
            if minorTimeLeft then
                assaultDisplay = assaultDisplay .. string.format("%sTime Remaining: %s\n", string.rep(" ", 4), FormatTime(minorTimeLeft))
            end

            if #minorMounts > 0 then
                for _, mountData in ipairs(minorMounts) do
                    local mountID, mountName, dropChance, itemName = unpack(mountData)
                    local rarityAttemptsText, dropChanceText  = "", ""

                    if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                        if MasterCollectorSV.showRarityDetail and dropChance then
                            local chance = 1 / dropChance
                            local attempts = GetRarityAttempts(itemName) or 0
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 4), attempts, dropChance)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end
                    if MasterCollectorSV.showMountName then
                        assaultDisplay = assaultDisplay .. string.format("%sMount: |r%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                    end
                end
            end
        end
        if hasContent then
            return assaultDisplay
        end
    end

    local function GetSummonFromTheDepthsStatus()
        local baseTime = playerRegion == 1 and 1728255660 or
            (playerRegion == 3 and 1728255660) -- Replace with EU base time when known
        local eventInterval = 10800            -- 3 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        local mountName, _, _, _, _, _, _, _, _, _, collected, depthsMountID = C_MountJournal.GetMountInfoByID(1238)
        local achieveID, achieveName = GetAchievementInfo(13638)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        if MasterCollectorSV.showSummonDepthsTimer then
            local eventText = string.format("%sNext Summon from the Depths: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("%sAchievement Mount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%sRequired for %s Achievement|r\n", string.rep(" ", 4), MC.blueHex, depthsMountID, mountName, depthsMountID, wowheadIcon, string.rep(" ", 4), achieveString)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

        local function GetCovenantAssaultStatus()
        local assaultIDs = {
            [6989] = "Necrolord Assault",
            [6990] = "Venthyr Assault",
            [6991] = "Kyrian Assault",
            [6992] = "Night Fae Assault"
        }

        local mountIDs = {
            [6989] = 1477, -- Undying Darkhound's Harness
            [6990] = 1378, -- Harvester's Dredwing Saddle
            [6992] = 1476  -- Legsplitter War Harness
        }

        local currentAssaultID
        local currentAssaultSecondsLeft
        local achieveID, achieveName, _, achieved = GetAchievementInfo(15035)
        local breakingMountName, _, _, _, _, _, _, _, _, _, _, breakingMountID = C_MountJournal.GetMountInfoByID(1504)
        local beyondMountName, _, _, _, _, _, _, _, _, _, _, beyondDMountID = C_MountJournal.GetMountInfoByID(2114)
        local breakingachieveID, breakingachieveName = GetAchievementInfo(15064)
        local beyondachieveID, beyondachieveName = GetAchievementInfo(20501)

        local part1 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)
        local part2 = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, breakingachieveID, breakingachieveName)
        local part3 = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, beyondachieveID, beyondachieveName)
        local breakingachieveStatus = achieved and " for " .. part2 .. " Complete|r\n" or " yet to be Completed for " .. part2 .. "|r\n"
        local beyondachieveStatus = achieved and " for " .. part3 .. " Complete|r\n" or " yet to be Completed for " .. part3 .. "|r\n"

        local breakingmountStatus = string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), MC.blueHex, breakingMountID, breakingMountName, breakingMountID, wowheadIcon)
        local beyondmountStatus = string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h", string.rep(" ", 4), MC.blueHex, beyondDMountID, beyondMountName, beyondDMountID, wowheadIcon)

        for assaultID in pairs(assaultIDs) do
            local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(assaultID)
            if secondsLeft and secondsLeft > 0 then
                currentAssaultID = assaultID
                currentAssaultSecondsLeft = secondsLeft
                break
            end
        end

        local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(64106)

        if MasterCollectorSV.showMawAssaultTimer then
            if not currentAssaultID then
                local mountID = mountIDs[currentAssaultID]
                if mountID then
                    local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                    if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                        if not questCompleted then
                            return string.format("%sCurrent Maw Assault: |r\n%sPlease complete Chapter 2 of the Chains of Domination questline, Maw Walkers.\n", MC.goldHex, string.rep(" ", 4))
                        else
                            return MC.goldHex .. "Fetching Maw Assault Status... Standby |r\n"
                        end
                    end
                end
            end

            local assaultName = assaultIDs[currentAssaultID]
            local dropChanceDenominator = 25
            local rarityAttemptsText = ""
            local dropChanceText = ""

            local mountID = mountIDs[currentAssaultID]
            if mountID then
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                local assaultDisplay = string.format("%sCurrent Maw Assault: |r%s%s\nTime Remaining: %s\n", MC.goldHex, assaultName, string.rep(" ", 4), FormatTime(currentAssaultSecondsLeft))
                local attempts = GetRarityAttempts(mountName) or 0

                if dropChanceDenominator > 1 then
                    if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                        if MasterCollectorSV.showRarityDetail then
                            local chance = 1 / dropChanceDenominator
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 5), attempts, dropChanceDenominator)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end
                end

                if MasterCollectorSV.showMountName then
                    assaultDisplay = assaultDisplay .. string.format("%sMount: |r%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s%s\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText)

                    assaultDisplay = assaultDisplay .. string.format("\n%s%s%s%s\n%s%s%s%s\n", string.rep(" ", 4), part1, breakingachieveStatus, breakingmountStatus, string.rep(" ", 4), part1, beyondachieveStatus, beyondmountStatus)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                    return assaultDisplay
                end
            end
        end
    end

    local function GetBeastwarrensHuntStatus()
        local huntNames = {"Shadehounds", "Soul Eaters", "Death Elementals", "Winged Soul Eaters"}
        local baseTime = playerRegion == 1 and 1727794800 or (playerRegion == 3 and 1737514800)
        local fullRotationInterval = 1210000 -- 14 days in seconds
        local huntDuration = 302400          -- 3 days and 12 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % fullRotationInterval
        local currentHuntIndex = (math.floor(elapsedTimeInRotation / huntDuration) % #huntNames) + 1
        local elapsedTimeInHunt = elapsedTimeInRotation % huntDuration
        local timeRemainingInHunt = huntDuration - elapsedTimeInHunt
        local shadehoundsMountName, _, _, _, _, _, _, _, _, _, collected, shadehoundsMountID = C_MountJournal.GetMountInfoByID(1304)
        local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1504)
        local achieveID, achieveName, _, achieved = GetAchievementInfo(14738)
        local metaachieveID, metaachieveName = GetAchievementInfo(15064)
        local part1 = string.format("|Hachievement:%d|h[%s]|h|r", achieveID, achieveName)
        local part2 = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        local dropChanceDenominator = 50
        local attempts = GetRarityAttempts(shadehoundsMountName) or 0
        local rarityAttemptsText, dropChanceText = "", ""

        if MasterCollectorSV.showRarityDetail then
            local chance = 1 / dropChanceDenominator
            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
            rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 4), attempts, dropChanceDenominator)
            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
        end

        if MasterCollectorSV.showBeastwarrensHuntTimer then
            local huntText = ""

            if timeRemainingInHunt > 0 then
                huntText = string.format("%sCurrent Maw Beastwarrens Hunt: |r%s\n%sTime Remaining: %s\n", MC.goldHex, huntNames[currentHuntIndex], string.rep(" ", 5), FormatTime(timeRemainingInHunt))

                if MasterCollectorSV.showMountName then
                    if huntNames[currentHuntIndex] == "Shadehounds" and (not MasterCollectorSV.hideBossesWithMountsObtained or not collected) then
                        huntText = huntText .. string.format("%s%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 4), MC.blueHex, shadehoundsMountID, shadehoundsMountName, shadehoundsMountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                    end

                    huntText = huntText .. string.format("\n%s%s%s%s%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), MC.goldHex, part1, (achieved and " for " .. part2 .. " Complete|r\n" or " yet to be Completed for " .. part2 .. "|r\n"), string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
                end
            end

            local nextHuntIndex = (currentHuntIndex % #huntNames) + 1
            huntText = huntText .. string.format("%s\nNext Maw Beastwarrens Hunt: |r%s\n", MC.goldHex, huntNames[nextHuntIndex])

            if MasterCollectorSV.showMountName and huntNames[nextHuntIndex] == "Shadehounds" then
                huntText = huntText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 5), MC.blueHex, shadehoundsMountID, shadehoundsMountName, shadehoundsMountID, wowheadIcon, rarityAttemptsText, dropChanceText)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return huntText
            end
        end
    end

    local function GetTormentorsOfTorghastStatus()
        local tormentorRotation = {
            "Algel the Haunter",
            "Malleus Grakizz",
            "Gralebboih",
            "The Mass of Souls",
            "Manifestation of Pain",
            "Versya the Damned",
            "Zul'gath the Flayer",
            "Golmak The Monstrosity",
            "Sentinel Pyrophus",
            "Mugrem the Soul Devourer",
            "Kazj The Sentinel",
            "Promathiz",
            "Sentinel Shakorzeth",
            "Intercessor Razzra",
            "Gruukuuek the Elder"
        }

        local baseTimeNA = 1728263160 -- NA Base time for index 4
        local baseTimeEU = 1729908000 -- EU Base time for index 13
        local baseTime, rotationIndex

        -- Determine base time and rotation index based on the region
        if playerRegion == 1 then
            baseTime = baseTimeNA
            rotationIndex = 4 -- Index of "The Mass of Souls" for NA
        else
            baseTime = baseTimeEU
            rotationIndex = 13 -- Index of "Sentinel Shakorzeth" for EU
        end

        local eventInterval = 7200
        local elapsedTime = (realmTime - baseTime)
        local rotationSize = #tormentorRotation
        local currentRotationIndex = ((rotationIndex - 1 + math.floor(elapsedTime / eventInterval)) % rotationSize) + 1

        if elapsedTime < eventInterval then
            currentRotationIndex = ((currentRotationIndex - 1) % rotationSize) + 1
        end

        local elapsedTimeInRotation = elapsedTime % eventInterval
        local timeUntilNextSpawn = eventInterval - elapsedTimeInRotation
        local currentBoss = tormentorRotation[currentRotationIndex]
        local eventText = MC.goldHex .. "Current Tormentor: |r" .. currentBoss .. "\n"

        local maxNameLength = 0
        for _, name in ipairs(tormentorRotation) do
            if #name > maxNameLength then
                maxNameLength = #name
            end
        end

        local fixedTimerColumn = maxNameLength + 10
        local mount1ID = 1475
        local mount2ID = 1504
        local mount1Text, mount2Text = "", ""
        local mountName, collected = "", false

        if MasterCollectorSV.showTormentorsTimer then
            local function mountCheck(mountID)
                mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(63854)
                local mountText = string.format("Mount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h", MC.blueHex, mountID, mountName, mountID, wowheadIcon)
                local currentText = ""

                local achieveID, achieveName, _, achieved = GetAchievementInfo(15054)
                local achieveString = string.format("|Hachievement:%d|h[%s]|h|r", achieveID, achieveName)
                local metaachieveID, metaachieveName = GetAchievementInfo(15064)
                local metaStatus = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

                local dropChanceDenominator = 50
                local attempts = GetRarityAttempts("Chain of Bahmethra") or 0
                local rarityAttemptsText, dropChanceText = "", ""

                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if MasterCollectorSV.showRarityDetail then
                        local chance = 1 / dropChanceDenominator
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                        rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 4), attempts, dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                    end
                end

                if MasterCollectorSV.showMountName then
                    if mountID == 1475 then
                        if not questCompleted then
                            currentText = string.format("%sTormentor's Cache Weekly to do!\n%s%s%s%s\n\n", string.rep(" ", 4), string.rep(" ", 4), mountText, rarityAttemptsText, dropChanceText)
                        else
                            currentText = string.format("%s%s%s%s\n\n", string.rep(" ", 4), mountText, rarityAttemptsText, dropChanceText)
                        end
                    end

                    if mountID == 1504 then
                        currentText = currentText .. string.format("%s%s%s%s%s%s\n", string.rep(" ", 4), MC.goldHex, achieveString, (achieved and " for " .. metaStatus .. " Complete|r\n" or " yet to be Completed for " .. metaStatus .. "|r\n"), string.rep(" ", 4), mountText)
                    end
                end
                return currentText
            end

            mount1Text = mountCheck(mount1ID)
            mount2Text = mountCheck(mount2ID)
            eventText = eventText .. mount1Text .. mount2Text
            eventText = eventText .. string.format("\n%s%sUpcoming Tormentors:|r\n", MC.goldHex, string.rep(" ", 4))

            for i = 1, rotationSize do
                local index = (currentRotationIndex + i - 1) % rotationSize + 1
                local timeUntilSpawn = (i - 1) * eventInterval + timeUntilNextSpawn
                local name = tormentorRotation[index]
                local padding = string.rep(" ", fixedTimerColumn - #name)

                eventText = string.format("%s%s%s%s%s\n", eventText, string.rep(" ", 4), name, padding, FormatTime(timeUntilSpawn))
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function TimeRiftsStatus()
        local baseTime = playerRegion == 1 and 1733025600 or (playerRegion == 3 and 1733025600)
        local eventInterval = 3600
        local activeDuration = 900 -- 15 minutes active in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration
        local playerParaflakes = C_CurrencyInfo.GetCurrencyInfo(2594).quantity
        local iconParaflakes = C_CurrencyInfo.GetCurrencyInfo(2594).iconFileID
        local iconSize = CreateTextureMarkup(iconParaflakes, 32, 32, 16, 16, 0, 1, 0, 1)

        local achieveID, achieveName, _, earned = GetAchievementInfo(19485)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        local mountIDs = {
            1779, -- Felstorm Dragon
            1782, -- Perfected Juggernaut
            1778, -- Gold-Toed Albatross
            1783, -- Scourgebound Vanquisher
            1781, -- Sulfur Hound
            1777, -- Ravenous Black Gryphon
            1776, -- White War Wolf
            1618, -- Bestowed Sandskimmer
        }

        if MasterCollectorSV.showTimeRiftsTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sTime Rift Active! |r%s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Time Rift: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            local achieveText = string.format("\n%s%s%s", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete|r\n" or " yet to be Completed for " .. metaachieveString .. "|r\n"))
            local uncollectedMounts = {}
            local mountOutput = ""
            local achieveMountOutput = ""
            local allMountsCollected = true

            for _, mountID in ipairs(mountIDs) do
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                if mountID == 1618 then
                    if MasterCollectorSV.showMountName and mountName then
                        local mountText =  string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon)
                        achieveMountOutput = achieveText .. mountText
                    end
                else
                    if not collected then
                        allMountsCollected = false
                        if MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(uncollectedMounts, mountID)
                        end
                    end
                    if MasterCollectorSV.showMountName and mountName then
                        if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                            mountOutput = mountOutput .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h %s%s / 3000 Paracausal Flakes %s Required|r\n", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, MC.goldHex, playerParaflakes, iconSize)
                        end
                    end
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and allMountsCollected then
                return nil
            end

            eventText = eventText .. mountOutput
            eventText = eventText .. achieveMountOutput

            return eventText
        end
    end

    local function TheStormsFuryEvent()
        local questID = 74378
        local questName = C_TaskQuest.GetQuestInfoByQuestID(questID)
        local eventText = string.format("%s%s Event Active!|r ", MC.goldHex, questName)
        local mountName, _, _, _, _, _, _, _, _, _, collected, stormsfuryMountID = C_MountJournal.GetMountInfoByID(1478)
        local playerEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).quantity
        local iconEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).iconFileID
        local iconSize = CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1)
        local baseTime = playerRegion == 1 and 1733036400 or (playerRegion == 3 and 1733047200)
        local eventInterval = 18000 -- 5 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation

        if MasterCollectorSV.showStormsFuryTimer then
            if questID and HaveQuestData(questID) and QuestUtils_IsQuestWorldQuest(questID) then
                local duration = C_TaskQuest.GetQuestTimeLeftSeconds(questID)

                if duration then
                    eventText = eventText .. FormatTime(duration) .. " Remaining\n"
                else
                    eventText = string.format("%sNext The Storm's Fury Event: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
                end

                if MasterCollectorSV.showMountName then
                    eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s%s%s / 3000 Elemental Overflow %s & 150 Essence of the Storm Required|r\n", string.rep(" ", 4), MC.blueHex, stormsfuryMountID, mountName, stormsfuryMountID, wowheadIcon, string.rep(" ", 4), MC.goldHex, playerEleOverflow, iconSize)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function DragonbaneKeepSiege()
        local baseTime = playerRegion == 1 and 1733029200 or (playerRegion == 3 and 1733040000)
        local eventInterval = 7200
        local activeDuration = 3600
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration
        local mountName, _, _, _, _, _, _, _, _, _, collected, siegeMountID = C_MountJournal.GetMountInfoByID(1651)

        local achieveID, achieveName, _, earned = GetAchievementInfo(19483)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)


        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        if MasterCollectorSV.showDragonbaneKeepTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sSiege of Dragonbane Keep Active!|r %s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Siege of Dragonbane Keep: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("\n%s%s%s%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete|r\n" or " yet to be Completed for " .. metaachieveString .. "|r\n"),
                string.rep(" ", 4), MC.blueHex, siegeMountID, mountName, siegeMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function IskaaraCommunityFeast()
        local baseTime = playerRegion == 1 and 1733043600 or (playerRegion == 3 and 1733041800)
        local eventInterval = 5400
        local activeDuration = 900
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration
        local mountName, _, _, _, _, _, _, _, _, _, collected, feastMountID = C_MountJournal.GetMountInfoByID(1633)

        local achieveID, achieveName, _, earned = GetAchievementInfo(19482)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        if MasterCollectorSV.showFeastTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sIskaara Community Feast Active!|r %s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Iskaara Community Feast: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("\n%s%s%s%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete|r\n" or " yet to be Completed for " .. metaachieveString .. "|r\n"),
                string.rep(" ", 4), MC.blueHex, feastMountID, mountName, feastMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function GrandHunts()
        local grandHuntPOI = {
            [7342] = 2023, -- Ohn'ahran Plains
            [7343] = 2022, -- The Waking Shores
            [7344] = 2025, -- Thaldraszus
            [7345] = 2024  -- The Azure Span
        }

        local subHuntPOI = {
            [7053] = { 2023, "Northern Ohn'ahran Plains Hunt" },
            [7089] = { 2023, "Western Ohn'ahran Plains Hunt" },
            [7090] = { 2023, "Eastern Ohn'ahran Plains Hunt" },
            [7091] = { 2022, "Southern Waking Shores Hunt" },
            [7092] = { 2022, "Eastern Waking Shores Hunt" },
            [7093] = { 2022, "Northern Waking Shores Hunt" },
            [7094] = { 2024, "Western Azure Span Hunt" },
            [7095] = { 2024, "Eastern Azure Span Hunt" },
            [7096] = { 2024, "Southern Azure Span Hunt" },
            [7097] = { 2025, "Southern Thaldraszus Hunt" },
            [7098] = { 2025, "Northern Thaldraszus Hunt" }
        }

        local function GetActiveHunt()
            for poiID, huntData in pairs(subHuntPOI) do
                local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(huntData[1], poiID)
                if poiInfo then
                    return huntData[1], poiID, huntData[2]
                end
            end
            return nil, nil, nil
        end

        local activeMapID, _, activeHuntName = GetActiveHunt()
        local mountName, _, _, _, _, _, _, _, _, _, collected, huntMountID = C_MountJournal.GetMountInfoByID(1474)

        local achieveID, achieveName, _, earned = GetAchievementInfo(19481)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if MasterCollectorSV.showHuntsTimer then
            local eventText
            local secondsLeftMessage = ""

            for poiID, mapID in pairs(grandHuntPOI) do
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)
                if secondsLeft then
                    local mapInfo = C_Map.GetMapInfo(mapID)
                    local mapName = mapInfo and mapInfo.name or "Unknown Map"
                    secondsLeftMessage = string.format("%s\n%sTime Remaining: %s\n%s", mapName, string.rep(" ", 4), FormatTime(secondsLeft), string.rep(" ", 4))
                end
            end

            if secondsLeftMessage ~= "" then
                if activeMapID then
                    eventText = string.format("%sGrand Hunt Is Currently: |r%s\n%s%s", MC.goldHex, activeHuntName, string.rep(" ", 4), secondsLeftMessage)
                else
                    eventText = string.format("%sGrand Hunt Is Currently: |r%s\n%sPlease visit Active Hunt Zone to determine exact location.|r\n", MC.goldHex, secondsLeftMessage, MC.redHex, string.rep(" ", 4))
                end
            else
                eventText = string.format("%sGrand Hunt Is Currently: |r%sUnable to determine Dragon Isles Grand Hunt location. Please visit a Dragon Isles zone.|r\n", MC.goldHex, MC.redHex)
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("\n%s%s%s%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete|r\n" or " yet to be Completed for " .. metaachieveString .. "|r\n"),
                string.rep(" ", 4), MC.blueHex, huntMountID, mountName, huntMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function ZaralekZones()
        local zones = {
            "Caldera",        -- Zone 1 (Always active)
            "Glimmerogg",     -- Zone 2
            "Nal Ks'Kol",     -- Zone 3
            "Loamm",          -- Zone 4
            "Aberrus"         -- Zone 5
        }

        local inactiveRotation = {3, 4, 5, 2}  -- Zone 1 is always active
        local daysSinceBase = (date("*t").yday - 1) % #inactiveRotation
        local inactiveZone = inactiveRotation[daysSinceBase + 1]
        local activeZones = {}

        for i, zone in ipairs(zones) do
            if i ~= inactiveZone then
                table.insert(activeZones, zone)
            end
        end

        if MasterCollectorSV.showZCZones then
            local eventText = string.format("%sZaralek Active Zones: %s|r\n", MC.goldHex, table.concat(activeZones, ", "))
            local mountName, _, _, _, _, _, _, _, _, _, collected, zaralekMountID = C_MountJournal.GetMountInfoByID(1732)

            if inactiveZone ~= 2 then
                local rarityAttemptsText, dropChanceText = "", ""

                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if MasterCollectorSV.showRarityDetail then
                        local dropChanceDenominator = 100
                        local attempts = GetRarityAttempts("Cobalt Shalewing") or 0
                        local chance = 1 / dropChanceDenominator
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))

                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)\n", cumulativeChance)
                    end
                end

                if MasterCollectorSV.showMountName then
                    eventText = eventText .. string.format("%s%sKarokta is Active!|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s", MC.goldHex, string.rep(" ", 4), string.rep(" ", 4), MC.blueHex, zaralekMountID, mountName, zaralekMountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                end
            else
                eventText = eventText .. string.format("%s%sKarokta is Not Active Today|r\n", MC.goldHex, string.rep(" ", 4))
            end
            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function Dreamsurges()
        local DreamsurgesPOI = {
            [2023] = { 7555, 7604 }, -- Ohn'ahran Plains
            [2022] = { 7556, 7603 }, -- The Waking Shores
            [2025] = { 7553, 7602 }, -- Thaldraszus
            [2024] = { 7554, 7605 }  -- The Azure Span
        }

        local function CalculateNextPortalTime()
            local currentTime = date("*t")
            local minutes = currentTime.min
            local seconds = currentTime.sec

            if minutes < 30 then
                return (30 - minutes) * 60 - seconds
            else
                return (60 - minutes) * 60 - seconds
            end
        end

        if MasterCollectorSV.showDreamsurgesTimer then
            local secondsLeftMessage = ""
            for mapID, poiIDs in pairs(DreamsurgesPOI) do
                for _, poiID in ipairs(poiIDs) do
                    local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)
                    if secondsLeft then
                        local mapInfo = C_Map.GetMapInfo(mapID)
                        local mapName = mapInfo and mapInfo.name or "Unknown Map"

                        secondsLeftMessage = secondsLeftMessage .. string.format("%s\n%sTime Remaining: %s\n", mapName, string.rep(" ", 4), FormatTime(secondsLeft))
                        break
                    end
                end
            end

            local achieveID, achieveName, _, earned = GetAchievementInfo(19008)
            local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

            local achieveID2, achieveName2 = GetAchievementInfo(19486)
            local achieveString2 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID2, achieveName2)

            local metaachieveID, metaachieveName = GetAchievementInfo(19458)
            local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

            local eventText = MC.goldHex .. "Dreamsurge Is Currently: |r" .. secondsLeftMessage
            local timeToNext = CalculateNextPortalTime()
            local portalMessage = string.format("%sNext Waking Dream Portal: |r%s", string.rep(" ", 4), FormatTime(timeToNext))
            local currencyMountName, _, _, _, _, _, _, _, _, _, collected1, currencyMountID = C_MountJournal.GetMountInfoByID(1671)
            local wakingDreamMountName, _, _, _, _, _, _, _, _, _, collected2, wakingDreamMountID = C_MountJournal.GetMountInfoByID(1645)
            local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1614)

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 then
                    eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s(Requires 1000 Dreamsurge Coalescence)\n\n%s%s|r\n", string.rep(" ", 4), MC.blueHex, currencyMountID, currencyMountName, currencyMountID, wowheadIcon, string.rep(" ", 4), MC.goldHex, portalMessage)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected2 then
                    eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s(combine 20 Elemental Remains)\n", string.rep(" ", 4), MC.blueHex, wakingDreamMountID, wakingDreamMountName, wakingDreamMountID, wowheadIcon, string.rep(" ", 4))
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                    eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. achieveString2 .. " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. achieveString2 .. " for " .. metaachieveString),
                    string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
                end
            end
            eventText = eventText .. string.format("\n%s%s|r\n", MC.goldHex, portalMessage)

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 or not collected2 or not earned then
                return eventText
            end
        end
    end

    local function SuffusionCamp()
        local SuffusionCampPOI = {
            [2023] = { 7429, 7471, 7473, 7486, 7487 }, -- Ohn'ahran Plains
            [2024] = { 7432, 7433, 7434, 7435, 7488 }  -- The Azure Span
        }

        if MasterCollectorSV.showSuffusionCampTimer then
            local secondsLeftMessage = ""
            for mapID, poiIDs in pairs(SuffusionCampPOI) do
                for _, poiID in ipairs(poiIDs) do
                    local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)
                    if secondsLeft then
                        local mapInfo = C_Map.GetMapInfo(mapID)
                        local mapName = mapInfo and mapInfo.name or "Unknown Map"

                        secondsLeftMessage = secondsLeftMessage .. string.format("%s\n%sTime Remaining: %s\n", mapName, string.rep(" ", 4), FormatTime(secondsLeft))
                        break
                    end
                end
            end

            local achieveID, achieveName, _, earned = GetAchievementInfo(18867)
            local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)
            local achieveMountName, _, _, _, _, _, _, _, _, _, collected, achieveMountID = C_MountJournal.GetMountInfoByID(1614)

            local achieveID2, achieveName2 = GetAchievementInfo(19486)
            local achieveString2 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID2, achieveName2)

            local metaachieveID, metaachieveName = GetAchievementInfo(19458)
            local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

            local eventText = MC.goldHex .. "Suffusion Camp Is Currently: |r" .. secondsLeftMessage

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. achieveString2 .. " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. achieveString2 .. " for " .. metaachieveString),
                string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function ElementalStorms()
        local elementalStormsPOI = {
            ["Thunderstorms"] = {
                [2023] = { 7221, 7225 },       -- Ohn'ahran Plains (Nokhudon Hold, Ohn'iri Springs)
                [2024] = { 7229, 7232, 7237 }, -- The Azure Span (Brackenhide Hollow, Cobalt Assembly, Imbu)
                [2025] = { 7245 },             -- Thaldraszus (Tyrhold)
                [2022] = { 7249, 7253, 7257 }  -- The Waking Shores (Dragonbane Keep, Slagmire, Scalecracker Keep)
            },
            ["Sandstorms"] = {
                [2023] = { 7222, 7226 },       -- Ohn'ahran Plains (Nokhudon Hold, Ohn'iri Springs)
                [2024] = { 7230, 7234, 7238 }, -- The Azure Span (Brackenhide Hollow, Cobalt Assembly, Imbu)
                [2025] = { 7246 },             -- Thaldraszus (Tyrhold)
                [2022] = { 7250, 7254, 7258 }  -- The Waking Shores (Dragonbane Keep, Slagmire, Scalecracker Keep)
            },
            ["Firestorms"] = {
                [2023] = { 7223, 7227 },       -- Ohn'ahran Plains (Nokhudon Hold, Ohn'iri Springs)
                [2024] = { 7231, 7235, 7239 }, -- The Azure Span (Brackenhide Hollow, Cobalt Assembly, Imbu)
                [2025] = { 7247 },             -- Thaldraszus (Tyrhold)
                [2022] = { 7251, 7255, 7259 }  -- The Waking Shores (Dragonbane Keep, Slagmire, Scalecracker Keep)
            },
            ["Snowstorms"] = {
                [2023] = { 7224, 7228 },       -- Ohn'ahran Plains (Nokhudon Hold, Ohn'iri Springs)
                [2024] = { 7232, 7236, 7240 }, -- The Azure Span (Brackenhide Hollow, Cobalt Assembly, Imbu)
                [2025] = { 7248 },             -- Thaldraszus (Tyrhold)
                [2022] = { 7252, 7256, 7260 }  -- The Waking Shores (Dragonbane Keep, Slagmire, Scalecracker Keep)
            }
        }

        local mountIDs = {
            1622, -- Stormhide Salamanther
            1467, -- Noble Bruffalon
            1621, -- Coralscale Salamanther
        }

        if MasterCollectorSV.showElementalStormsTimer then
            local activeStorms = {}
            local timerDisplay = nil
            local eventText = ""
            local baseTime = playerRegion == 1 and 1733205600 or (playerRegion == 3 and 1733209200)
            local eventInterval = 1800
            local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
            local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
            local playerEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).quantity
            local iconEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).iconFileID

            for stormType, mapData in pairs(elementalStormsPOI) do
                for mapID, poiIDs in pairs(mapData) do
                    for _, poiID in ipairs(poiIDs) do
                        local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)
                        local poiInfo = C_AreaPoiInfo.GetAreaPOIInfo(mapID, poiID)
                        if poiInfo then
                            local mapInfo = C_Map.GetMapInfo(mapID)
                            local mapName = mapInfo and mapInfo.name or "Unknown Map"
                            table.insert(activeStorms, {name = stormType, map = mapName})

                            -- Set timer display to the first valid timer
                            if not timerDisplay and secondsLeft then
                                timerDisplay = FormatTime(secondsLeft)
                            end

                            -- Stop if we have 2 active storms
                            if #activeStorms == 2 then
                                break
                            end
                        end
                    end
                    if #activeStorms == 2 then
                        break
                    end
                end
                if #activeStorms == 2 then
                    break
                end
            end

            if #activeStorms ~= 0 then
                eventText = eventText .. string.format("%sActive Elemental Storms: |r", MC.goldHex)
                if timerDisplay then
                    eventText = eventText .. timerDisplay
                end
                for _, storm in ipairs(activeStorms) do
                    eventText = eventText .. string.format("\n%s%s (%s)", string.rep(" ", 4), storm.map, storm.name)
                end
                if #activeStorms < 2 then
                    eventText = eventText .. string.format("\n\n%sUnable to determine Another Storm. Please visit a Dragon Isles Zone to verify.|r", MC.redHex)
                end
            else
                eventText = eventText .. MC.goldHex .. "Next Elemental Storms: |r" .. FormatTime(timeUntilNextEvent)
            end

            local achieveID, achieveName, _, earned = GetAchievementInfo(16492)
            local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

            local metaachieveID, metaachieveName = GetAchievementInfo(19458)
            local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

            local currencyMountName1, _, _, _, _, _, _, _, _, _, collected1, currencyMountID1 = C_MountJournal.GetMountInfoByID(1622)
            local currencyMountName2, _, _, _, _, _, _, _, _, _, collected2, currencyMountID2 = C_MountJournal.GetMountInfoByID(1467)
            local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1621)
            local overflowTexture = CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1)

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s%s%s / 2,000 Elemental Overflow %s Required|r\n", string.rep(" ", 4), MC.blueHex, currencyMountID1, currencyMountName1, currencyMountID1, wowheadIcon, MC.goldHex, string.rep(" ", 4), playerEleOverflow, overflowTexture)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected2 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s%s%s / 100,000 Elemental Overflow %s Required|r\n", string.rep(" ", 4), MC.blueHex, currencyMountID2, currencyMountName2, currencyMountID2, wowheadIcon, MC.goldHex, string.rep(" ", 4), playerEleOverflow, overflowTexture)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                    eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: |r%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. metaachieveString),
                    string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 or not collected2 or not earned then
                return eventText
            end
        end
    end

    local function FroststoneVaultStorm()
        local baseTime = playerRegion == 1 and 1679576400 or (playerRegion == 3 and 1679572800)
        local eventInterval = 7200 -- 2 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1825)
        local currencyMountName, _, _, _, _, _, _, _, _, _, collected, currencyMountID = C_MountJournal.GetMountInfoByID(1627)

        local achieveID, achieveName, _, earned = GetAchievementInfo(17540)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local achieveID2, achieveName2 = GetAchievementInfo(17543)
        local achieveString2 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID2, achieveName2)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if MasterCollectorSV.showFroststoneStormTimer then
            local eventText = string.format("%sNext Froststone Vault Primal Storm: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                    eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s(combine 50 Leftover Elemental Slime)\n", string.rep(" ", 4), MC.blueHex, currencyMountID, currencyMountName, currencyMountID, wowheadIcon, string.rep(" ", 4))
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                    eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. achieveString2 .. " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. achieveString2 .. " for " .. metaachieveString),
                    string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected or not earned then
                return eventText
            end
        end
    end

    local function LegendaryAlbumWQs()
        local legendaryQuestIDs = {
            [70632] = "Chen Stormstout - Cataloging the Waking Shores",
            [70075] = "Abu'Gar - Cataloging the Waking Shores",
            [70659] = "Elder Clearwater - Cataloging the Ohn'ahran Plains",
            [70079] = "Nat Pagle - Cataloging the Ohn'ahran Plains",
            [70100] = "Chief Telemancer Oculeth - Cataloging the Azure Span",
            [70699] = "Wrathion - Cataloging Thaldraszus",
            [70110] = "Time-Warped Mysterious Fisher - Cataloging Thaldraszus"
        }

        local legendaryMapIDs = {
            [70632] = 2022, -- Waking Shores
            [70075] = 2022, -- Waking Shores
            [70659] = 2023, -- Ohn'ahran Plains
            [70079] = 2023, -- Ohn'ahran Plains
            [70100] = 2024, -- Azure Span
            [70699] = 2025, -- Thaldraszus
            [70110] = 2025  -- Thaldraszus
        }

        local achieveID, achieveName, _, earned = GetAchievementInfo(16570)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local achieveID2, achieveName2 = GetAchievementInfo(19486)
        local achieveString2 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID2, achieveName2)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        local WQtext = string.format("%s%s Achievement WQ/s Active:|r\n", MC.goldHex, achieveName)
        local mountName, _, _, _, _, _, _, _, _, _, collected, albumMountID = C_MountJournal.GetMountInfoByID(1669)
        local foundWQ = false

        if MasterCollectorSV.showLegendaryAlbumTimer then
            local allQuestNames = ""
            local overallDuration = nil
            for questID, questName in pairs(legendaryQuestIDs) do
                local mapID = legendaryMapIDs[questID]
                local taskInfo = C_TaskQuest.GetQuestsOnMap(mapID)

                if taskInfo then
                    for _, info in ipairs(taskInfo) do
                        local questId = info and info.questID
                        if questID and HaveQuestData(questId) and QuestUtils_IsQuestWorldQuest(questId) then
                            if questId == questID then
                                allQuestNames = string.format("%s%s%s\n", allQuestNames, string.rep(" ", 4), questName)
                                overallDuration = C_TaskQuest.GetQuestTimeLeftSeconds(questId)
                            end
                        end
                    end
                end
            end
            if allQuestNames ~= "" and overallDuration then
                WQtext = WQtext .. string.format("%sTime Remaining: %s\n\n", string.rep(" ", 4), FormatTime(overallDuration))
                WQtext = WQtext .. allQuestNames .. "\n"
                foundWQ = true
            end

            local _, _, _, achieved = GetAchievementInfo(16363)
            if not foundWQ then
                if not achieved then
                    WQtext = WQtext .. "   Dragon Isles Storyline not yet completed - please complete.\n"
                else
                    WQtext = WQtext .. "   No active World Quests available.\n"
                end
            end

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                    WQtext = WQtext .. string.format("%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. achieveString2 .. " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. achieveString2 .. " for " .. metaachieveString),
                    string.rep(" ", 4), MC.blueHex, albumMountID, mountName, albumMountID, wowheadIcon)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected or not earned then
                return WQtext
            end
        end
    end

    local function ResearchersUnderFire()
        local baseTime = playerRegion == 1 and 1733265000 or (playerRegion == 3 and 1733265000)
        local eventInterval = 3600 -- 1 hour in seconds
        local activeDuration = 1500
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        local dropChanceDenominator = 33
        local rarityAttemptsText, dropChanceText = "", ""
        local attempts = GetRarityAttempts("Flaming Shalewing Subject 01") or 0

        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
            if MasterCollectorSV.showRarityDetail then
                local chance = 1 / dropChanceDenominator
                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 5), attempts, dropChanceDenominator)
                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
            end
        end

        local currencyMountName1, _, _, _, _, _, _, _, _, _, collected1, currencyMountID1 = C_MountJournal.GetMountInfoByID(1603)
        local currencyMountName2, _, _, _, _, _, _, _, _, _, collected2, currencyMountID2 = C_MountJournal.GetMountInfoByID(1730)
        local dropMountName, _, _, _, _, _, _, _, _, _, collected3, dropMountID = C_MountJournal.GetMountInfoByID(1735)
        local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1733)

        local achieveID, achieveName, _, earned = GetAchievementInfo(17781)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local achieveID2, achieveName2 = GetAchievementInfo(17785)
        local achieveString2 = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID2, achieveName2)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if MasterCollectorSV.showResearchersUnderFireTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sResearchers Under Fire Active! |r%s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Researchers Under Fire Event: |r", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s(Requires 100 Unearthed Fragrant Coin to trade for Coveted Baubles)\n", string.rep(" ", 4), MC.blueHex, currencyMountID1, currencyMountName1, currencyMountID1, wowheadIcon, string.rep(" ", 4))
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected2 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s(Requires 400 Unearthed Fragrant Coin to trade for Coveted Baubles)\n", string.rep(" ", 4), MC.blueHex, currencyMountID2, currencyMountName2, currencyMountID2, wowheadIcon, string.rep(" ", 4))
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected3 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 4), MC.blueHex, dropMountID, dropMountName, dropMountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                    eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString,
                    (earned and " for " .. achieveString2 .. " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. achieveString2 .. " for " .. metaachieveString),
                    string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 or not collected2 or not collected3 or not earned then
                return eventText
            end
        end
    end

    local function Superbloom()
        local baseTime = playerRegion == 1 and 1733263200 or (playerRegion == 3 and 1733263200)
        local eventInterval = 3600 -- 1 hour in seconds
        local activeDuration = 900
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        local achieveMountName, _, _, _, _, _, _, _, _, _, _, achieveMountID = C_MountJournal.GetMountInfoByID(1825)
        local achieveID, achieveName, _, earned = GetAchievementInfo(19318)
        local achieveString = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, achieveID, achieveName)

        local metaachieveID, metaachieveName = GetAchievementInfo(19458)
        local metaachieveString = string.format("%s|Hachievement:%d|h[%s]|h|r Meta", MC.goldHex, metaachieveID, metaachieveName)

        if MasterCollectorSV.showSuperbloomTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sSuperbloom Active! %s|r Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Superbloom: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("\n%s%s%s|r\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 4), achieveString, (earned and " for " .. metaachieveString .. " Complete" or " yet to be Completed for " .. metaachieveString),
                string.rep(" ", 4), MC.blueHex, achieveMountID, achieveMountName, achieveMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not earned then
                return eventText
            end
        end
    end

    local function TheBigDig()
        local baseTime = playerRegion == 1 and 1733265000 or
            (playerRegion == 3 and 1733265000) -- Replace with EU base time when known
        local eventInterval = 3600             -- 1 hour in seconds
        local activeDuration = 600
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        local currencyMountID = 1638
        local dropMountID = 2038
        local currencyMountName, _, _, _, _, _, _, _, _, _, collected1 = C_MountJournal.GetMountInfoByID(currencyMountID)
        local dropMountName, _, _, _, _, _, _, _, _, _, collected2 = C_MountJournal.GetMountInfoByID(dropMountID)
        local dropChanceDenominator = 200
        local rarityAttemptsText, dropChanceText = "", ""
        local attempts = GetRarityAttempts(dropMountName) or 0
        local playerMysteriousFragments = C_CurrencyInfo.GetCurrencyInfo(2657).quantity
        local iconMysteriousFragments = C_CurrencyInfo.GetCurrencyInfo(2657).iconFileID
        local fragmentTexture = CreateTextureMarkup(iconMysteriousFragments, 32, 32, 16, 16, 0, 1, 0, 1)

        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
            if MasterCollectorSV.showRarityDetail then
                local chance = 1 / dropChanceDenominator
                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                rarityAttemptsText = string.format("%s(Attempts: %d/%s", string.rep(" ", 5), attempts, dropChanceDenominator)
                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
            end
        end

        if MasterCollectorSV.showBigDigTimer then
            local eventText
            if eventIsActive then
                eventText = string.format("%sThe Big Dig: Traitors Rest Event Active! |r%s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext The Big Dig: Traitors Rest Event: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 then
                    eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n%s%s%s / 20,000 Mysterious Fragments %s Required|r\n", string.rep(" ", 5), MC.blueHex, currencyMountID, currencyMountName, currencyMountID, wowheadIcon, MC.goldHex, string.rep(" ", 5), playerMysteriousFragments, fragmentTexture)
                end

                if not MasterCollectorSV.hideBossesWithMountsObtained or not collected2 then
                    eventText = eventText .. string.format("\n%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 5), MC.blueHex, dropMountID, dropMountName, dropMountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                end
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected1 or not collected2 then
                return eventText
            end
        end
    end

    local function TWWBeledarShift()
        local baseTime = playerRegion == 1 and 1733392800 or
            (playerRegion == 3 and 1728255660) -- Replace with EU base time when known
        local eventInterval = 10800            -- 3 hours in seconds
        local activeDuration = 1800
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        local beledarMountID = 2192
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(beledarMountID)

        if MasterCollectorSV.showBeledarShiftTimer then
            local eventText

            if eventIsActive then
                eventText = string.format("%sBeledar Dark Phase Active! |r%s Remaining\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            else
                eventText = string.format("%sNext Beledar Shift to Dark Phase: |r%s\n", MC.goldHex, FormatTime(timeUntilNextEvent))
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("%sMount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 5), MC.blueHex, beledarMountID, mountName, beledarMountID, wowheadIcon)
            end

            if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                return eventText
            end
        end
    end

    local function legionRemix()
        local remixMounts = {
            {2673, 10000},
            {2662, 10000},
            {2670, 10000},
            {2544, 10000},
            {2542, 10000},
            {2672, 10000},
            {2681, 10000}, 
            {2683, 10000},
            {2682, 10000},
            {2679, 10000},
            {2706, 10000},
            {2705, 10000},
            {2671, 10000},
            {2661, 10000},
            {2688, 10000},
            {2653, 10000},
            {2678, 10000},
            {2676, 10000},
            {2665, 10000},
            {2664, 10000},
            {2663, 10000},
            {2660, 10000},
            {2690, 10000},
            {2691, 10000},
            {2689, 10000},
            {2686, 10000},
            {2674, 10000},
            {2593, 10000},
            {2574, 10000},
            {2666, 10000},
            {2677, 10000},
            {2675, 10000},
            {2546, 10000},
        }
        local purchasableMounts = {
            {941, 20000, "Normally Paragon Chest Mount"},
            {942, 20000, "Normally Paragon Chest Mount"},
            {943, 20000, "Normally Paragon Chest Mount"},
            {905, 20000, "Normally Paragon Chest Mount"},
            {944, 20000, "Normally Paragon Chest Mount"},
            {983, 20000, "Normally Paragon Chest Mount"},
            {984, 20000, "Normally Paragon Chest Mount"},
            {985, 20000, "Normally Paragon Chest Mount"},
            {974, 40000, "Normally Fel-Spotted Egg Rare Farm"},
            {975, 40000, "Normally Fel-Spotted Egg Rare Farm"},
            {976, 40000, "Normally Fel-Spotted Egg Rare Farm"},
            {906, 40000, "Normally Fel-Spotted Egg Rare Farm"},
            {981, 40000, "Normally Rare Farm"},
            {955, 40000, "Normally Rare Farm"},
            {979, 40000, "Normally Rare Farm"},
            {970, 40000, "Normally Rare Farm"},
            {980, 40000, "Normally Rare Farm"},
            {973, 40000, "Normally Rare Farm"},
            {899, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {971, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {954, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {791, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {633, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {875, 100000, "Normally Mythic Dungeon 1/100 Drop Chance Farm"},
            {633, 100000, "Normally Raid 1/100 Drop Chance Farm"},
            {779, 40000, "Normally Archaelogy Quest only up twice a year"},
            {802, 20000, "Normally Puzzle Collect Crystals Mount"},
            {838, 20000, "Normally Puzzle Mount"},
            {656, 40000, "Normally Rare Quest Drop Mount"},
            {847, 100000, "Normally Farm Currency Mount"},
        }
        local achievementMounts = {
            {2726, 20000, 42504},
            {2720, 20000, 42685},
            {2721, 20000, 61087},
            {nil, 20000, 61086}, -- druid travel form
            {2723, 20000, 42687},
            {2724, 20000, 61089},
            {2725, 20000, 61085},
            {2727, 20000, 61088},
            {2728, 20000, 61084},
            {2729, 20000, 42686},
            {2730, 20000, 61090},
            {2731, 20000, 42684},
            {978, nil, 12110}
        }

        local lines = {}
        local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2778)
        local have = currencyInfo.quantity or 0
        local icon = currencyInfo.iconFileID
        local texture = CreateTextureMarkup(icon, 32, 32, 16, 16, 0, 1, 0, 1)
        local SCORNWING_QUEST_ID = 92638
        local SCORNWING_SPELL_ID = 1255451

        local function AddMountLine(mountID, cost, commentOrAchID)
            local mountName = mountID and C_MountJournal.GetMountInfoByID(mountID)
            local isCollected = false
            local comment = commentOrAchID

            if mountID then
                isCollected = select(11, C_MountJournal.GetMountInfoByID(mountID))
                local showMount = not (isCollected and MasterCollectorSV.hideBossesWithMountsObtained)
                if not showMount then return end
            else
                isCollected = C_QuestLog.IsQuestFlaggedCompleted(SCORNWING_QUEST_ID)
                local showMount = not (isCollected and MasterCollectorSV.hideBossesWithMountsObtained)
                if not showMount then return end
            end

            if type(commentOrAchID) == "number" then
                local achName = select(2,GetAchievementInfo(commentOrAchID))
                comment = string.format("%s|Hachievement:%d|h[%s]|h|r", MC.goldHex, commentOrAchID, achName)
            end

            if MasterCollectorSV.showMountName then
                if mountID ~= nil then
                    table.insert(lines, string.format("\n    Mount: %s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", MC.blueHex, mountID, mountName, mountID, wowheadIcon))
                else
                    local spellInfo = C_Spell.GetSpellInfo(SCORNWING_SPELL_ID)
                    table.insert(lines, string.format("\n    Travel Form: %s|Hspell:%d|h[%s]|h|r\n", MC.blueHex, SCORNWING_SPELL_ID, spellInfo.name))
                end
                if cost ~= nil then
                    table.insert(lines, string.format("%s    %s / %s %s %s Required|r", MC.goldHex, have, cost or "", currencyInfo.name, texture))
                    if comment == nil then
                        table.insert(lines,"\n")
                    end
                else
                    table.insert(lines, string.format("     %s\n", comment))
                end
                if comment ~= nil and mountID ~= 978 then
                    table.insert(lines, string.format(" or %s\n", comment))
                end
            end
        end

        for _, entry in ipairs(remixMounts) do
            AddMountLine(entry[1], entry[2])
        end
        for _, entry in ipairs(purchasableMounts) do
            AddMountLine(entry[1], entry[2], entry[3])
        end
        for _, entry in ipairs(achievementMounts) do
            AddMountLine(entry[1], entry[2], entry[3])
        end

        local output = ""
        if #lines > 0 then
            output = MC.goldHex .. "Remix Mounts|r" .. table.concat(lines)
        end

        if MasterCollectorSV.showLegionRemix then
            return output
        end
    end

    local function isDunegorgerAvailable()
        local nextReset = tostring(date("%d-%m-%Y %H:%M", realmTime + GetQuestResetTime()))
        local resetHour = tonumber(string.sub(nextReset, 12, 13))
        local resetMinute = tonumber(string.sub(nextReset, 15, 16))
        local startDate = { year = 2024, month = 7, day = 23, hour = resetHour, minute = resetMinute }

        -- Check if realm time is a day ahead for NA-OCE players
        local dayAhead = false
        if resetHour < 7 then
            dayAhead = true
        end

        local function getWeekNumberSince(startTime)
            local secondsInWeek = 7 * 24 * 60 * 60

            -- Set start time 1 day ahead if on NA-OCE
            if dayAhead then
                startTime = startTime + 86400
            end

            return math.floor((realmTime - startTime) / secondsInWeek)
        end

        local function isDunegorgerKraulokUp()
            local startTime = time(startDate)
            local weeksSinceStart = getWeekNumberSince(startTime)
            local rotationPeriod = 6 -- Dunegorger Kraulok's rotation period in weeks

            return weeksSinceStart % rotationPeriod == 0
        end

        return isDunegorgerKraulokUp()
    end

    local function GetActiveTimewalkingEvent()
        local timewalkingBuffs = {
            [995] = 335148,                        -- Burning Crusade
            [1045] = 335149,                        -- Wrath of the Lich King
            [1453] = 335151,                       -- Mists of Pandaria
            [1500] = 335150,                       -- Cataclysm (generic number - will change in future)
            [1971] = 335152,                       -- Warlords of Draenor
            [2274] = 359082,                       -- Legion
            [2500] = 452307,                       -- Classic (generic number - will change in future)
            [2700] = 1223878,                      -- Battle for Azeroth (generic number - will change in future)
            [2800] = 1256081,                      -- Shadowlands (generic number - will change in future)
        }

        local timewalkingEvents = {
            [995] = "Burning Crusade Timewalking",
            [1045] = "Wrath of the Lich King Timewalking", -- (generic number - will change in future)
            [1453] = "Mists of Pandaria Timewalking",
            [1500] = "Cataclysm Timewalking",              -- (generic number - will change in future)
            [1971] = "Warlords of Draenor Timewalking",
            [2274] = "Legion Timewalking",
            [2500] = "Classic Timewalking",                -- (generic number - will change in future)
            [2700] = "Battle for Azeroth Timewalking",     -- (generic number - will change in future)
            [2800] = "Shadowlands Timewalking"             -- (generic number - will change in future)
        }

        for eventID, spellId in pairs(timewalkingBuffs) do
            if C_UnitAuras.GetPlayerAuraBySpellID(spellId) then
                return timewalkingEvents[eventID]
            end
        end
        return nil
    end

    local function EventsActive()
        local calendarEvents = {
            { "Brewfest",                           { 202, 226, 2640 },              { "Swift Brewfest Ram", "Great Brewfest Kodo", "Brewfest Bomber" },                                                                { 25, 25, 25 } },
            { "Love is in the Air",                 { 352, 431, 1941, 2328 },        { "Big Love Rocket", "Swift Lovebird", "Heartseeker Mana Ray", "Love Witch's Sweeper" },                                           { 3333, 0, 0, 666 } },
            { "Hallow's End",                       { 219, 2623 },                   { "The Horseman's Reins", "The Headless Horseman's Ghoulish Charger" },                                                            { 200, 25 } },
            { "Noblegarden",                        { 430, 2023 },                   { "Swift Springstrider", "Noble Flying Carpet" },                                                                                  { 0, 100 } },
            { "Feast of Winter Veil",               { 769 },                         { "Minion of Grumpus" },                                                                                                           { 100 } },
            { "Lunar Festival",                     { 2327 },                        { "Lunar Launcher" },                                                                                                              { 0 } },
            { "Turbulent Timeways",                 { 2518, 2796, 2797, 2795, 2798 },{ "Chrono Corsair", "Bronze Aquilon Harness", "Bronze Corpsefly Harness", "Bronze Wilderling Harness", "Bronze Gravewing Harness" }, { 0, 0, 0, 0, 0 } },
            { "WoW's 20th Anniversary",             { 2261, 1285, 1292, 293, 1798 }, { "Coldflame Tempest", "Frostwolf Snarler", "Stormpike Battle Ram", "Illidari Doomhawk", "Azure Worldchiller" },                   { 0, 0, 0, 9, 100 } },
            { "WoW's 21st Anniversary",             { 1285, 1292, 293, 1798 },       { "Frostwolf Snarler", "Stormpike Battle Ram", "Illidari Doomhawk", "Azure Worldchiller" },                                        { 0, 0, 9, 100 } },
            { "Darkmoon Faire",                     { 429, 434, 962, 855 },          { "Swift Forest Strider", "Darkmoon Dancing Bear", "Darkmoon Dirigible", "Darkwater Skate" },                                      { 0, 0, 0, 0 } },
            { "Classic Timewalking",                { 2224, 1737, 2321, 781 },             { "Reins of the Frayfeather Hippogryph", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },                                  { 0, 0, 0, 4000 } },
            { "Burning Crusade Timewalking",        { 778, 2225, 1737, 2321, 781 },        { "Reins of the Eclipse Dragonhawk", "Reins of the Amani Hunting Bear", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },   { 0, 0, 0, 0, 4000 } },
            { "Cataclysm Timewalking",              { 2473, 1737, 2321, 781 },             { "Broodling of Sinestra", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },                                                { 0, 0, 0, 4000 } },
            { "Wrath of the Lich King Timewalking", { 552, 2317, 1737, 2321, 781 },        { "Bridle of the Ironbound Wraithcharger", "Enchanted Spellweave Carpet", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" }, { 0, 0, 0, 0, 4000 } },
            { "Mists of Pandaria Timewalking",      { 476, 2474, 1737, 2321, 781 },        { "Yu'lei, Daughter of Jade", "Copper-Maned Quilen Reins", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },                { 0, 0, 0, 0, 4000 } },
            { "Warlords of Draenor Timewalking",    { 1242, 1243, 2470, 1737, 2321, 781 }, { "Beastlord's Irontusk", "Beastlord's Warwolf", "Nightfall Skyreaver", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },   { 0, 0, 0, 0, 0, 4000 } },
            { "Legion Timewalking",                 { 1521, 2471, 1737, 2321, 781 },       { "Favor of the Val'sharah Hippogryph", "Ur'zul Fleshripper", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },             { 0, 0, 0, 0, 4000 } },
            { "Battle for Azeroth Timewalking",     { 2587, 2586, 1737, 2321, 781 },       { "Reins of the Ivory Savagemane", "Reins of the Moonlit Nightsaber", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },     { 0, 0, 0, 0, 4000 } },
            { "Shadowlands Timewalking",            { 2804, 2815, 1737, 2321, 781 }, { "Crimson Lupine", "Snowpaw Glimmerfur Prowler", "Sandy Shalewing", "Timely Buzzbee", "Reins of the Infinite Timereaver" },       { 0, 0, 0, 0, 0, 4000 } },
            { "Spirit of Echero",                   { 779 },                         { "Spirit of Eche'ro" },                                                                                                           { 0 } },
            { "World Boss: Dunegorger Kraulok",     { 1250 },                        { "Slightly Damp Pile of Fur" },                                                                                                   { 100 } },
            { "PvP Brawl: Classic Ashran",          { 638, 639 },                    { "Breezestrider Stallion", "Pale Thorngrazer"},                                                                                   { 0, 0 } },
            { "PvP Brawl: Comp Stomp",              { 108, 76, 79, 80, 82, 162, 255, 826, 833, 834, 832, 831, 836, 1192 },
                { "Frostwolf Howler", "Black War Kodo", "Black War Raptor", "Red Skeletal Warhorse", "Black War Wolf", "Swift Warstrider", "Black War Mammoth",
                "Prestigious Bronze Courser", "Prestigious Ivory Courser", "Prestigious Azure Courser", "Prestigious Forest Courser", "Prestigious Royal Courser", "Prestigious Midnight Courser",
                "Prestigious Bloodforged Courser" }, { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 } },
        }

        local cacheData = {
            [1] = {
                event = "Burning Crusade Timewalking",
                itemID = 208091,
                questID = 47523,
                drops = {
                    {183, 100},   -- mountID, chance
                    {781, 4000},
                },
            },
            [2] = {
                event = "Wrath of the Lich King Timewalking",
                itemID = 208094,
                questID = 50316,
                drops = {
                    {363, 100},
                    {304, 100},
                    {781, 4000},
                },
            },
            [3] = {
                event = "Cataclysm Timewalking",
                itemID = 208095,
                questID = 57637,
                drops = {
                    {415, 100},
                    {425, 100},
                    {442, 100},
                    {444, 100},
                    {445, 100},
                    {781, 4000},
                },
            },
        }

        local function GetCacheIndexByEvent(eventName)
            for index, data in pairs(cacheData) do
                if data.event == eventName then
                    return index
                end
            end
            return nil
        end

        local function GetCacheNames(cacheIndex)
            local data = cacheData[cacheIndex]
            if not data then return nil, nil end

            local itemData = MC.ItemDetails[data.itemID]
            local itemName = itemData and itemData.name
            local questName = C_QuestLog.GetTitleForQuestID(data.questID)

            return itemName, questName or "Timewalking Weekly Quest"
        end

        local calendarBagCurrency = {
            {431, 270, 49927}, -- Love Tokens in Bags
            {1941, 270, 49927}, -- Love Tokens in Bags
            {430, 500, 44791}, -- Noblegarden Chocolate in Bags
            {2327, 75, 21100} -- Coin of Ancestry in Bags
        }

        local calendarCurrency = {
            {429, 180, 515}, -- DMF Token Currency
            {434, 180, 515}, -- DMF Token Currency
            {638, 5000, 823}, -- Apexis Crystals
            {639, 5000, 823}, -- Apexis Crystals
            {962, 1000, 515} -- DMF Token Currency
        }

        local eventmetaAchieves = {
            {913, "Lunar Festival"},
            {1038, "Midsummer Fire Festival"},
            {1039, "Midsummer Fire Festival"},
            {1656, "Hallow's End"},
            {1683, "Brewfest"},
            {1691, "Feast of Winter Veil"},
            {1693, "Love is in the Air"},
            {1793, "Children's Week"},
            {2798, "Noblegarden"}
        }

        local monthInfo = C_Calendar.GetMonthInfo(0)
        local dayCount = monthInfo.numDays
        local currentCalendarTime = C_DateAndTime.GetCurrentCalendarTime()

        local currentTimeTable = {
            year = currentCalendarTime.year,
            month = currentCalendarTime.month,
            day = currentCalendarTime.monthDay,
            hour = currentCalendarTime.hour,
            min = currentCalendarTime.minute,
            sec = 0
        }

        local currentTime = time(currentTimeTable)
        local timezoneOffsetSeconds = C_DateAndTime.GetServerTimeLocal() - GetServerTime()
        currentTime = currentTime - timezoneOffsetSeconds

        local activeEvents = {}
        local output = ""
        local activeTimewalkingEvent = GetActiveTimewalkingEvent()
        local playerTimewarpedBadges = C_CurrencyInfo.GetCurrencyInfo(1166).quantity
        local iconTimewarpedBadges = C_CurrencyInfo.GetCurrencyInfo(1166).iconFileID
        local badgesTexture = CreateTextureMarkup(iconTimewarpedBadges, 32, 32, 16, 16, 0, 1, 0, 1) 

        if activeTimewalkingEvent then
            for _, eventInfo in ipairs(calendarEvents) do
                local eventName = eventInfo[1]

                if eventName == activeTimewalkingEvent then
                    local mountsToShow = {}

                    for j, mountID in ipairs(eventInfo[2]) do
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                        if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                            local rarityAttemptsText, dropChanceText = "", ""
                            local attempts = GetRarityAttempts(eventInfo[3][j]) or 0
                            local dropChanceDenominator = (eventInfo[4] and eventInfo[4][j]) or 1
                            local mountCurrency = ""

                            if dropChanceDenominator > 1 then
                                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                    if MasterCollectorSV.showRarityDetail then
                                        local chance = 1 / dropChanceDenominator
                                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                        rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts, dropChanceDenominator)
                                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                    end
                                end
                            else
                                if mountID ~= 781 then
                                    mountCurrency = string.format("\n%s%s%d / 5000 Timewarped Badges %s Required|r\n", MC.goldHex, string.rep(" ", 4), playerTimewarpedBadges, badgesTexture)
                                end
                            end

                            if MasterCollectorSV.showMountName then
                                table.insert(mountsToShow, string.format("%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s%s", MC.blueHex, mountID, mountName, mountID, wowheadIcon, mountCurrency, rarityAttemptsText, dropChanceText))
                            end
                        end
                    end

                    local cacheIndex = GetCacheIndexByEvent(eventName)
                    if cacheIndex and cacheData[cacheIndex] then
                        local cacheItemName, cacheQuestName = GetCacheNames(cacheIndex)

                        if #mountsToShow > 0 then
                            table.insert(mountsToShow, string.format("\n%s%sExtra Mount Attempt from %s (%s):|r", MC.goldHex, string.rep(" ", 4), cacheItemName, cacheQuestName))

                            for _, entry in ipairs(cacheData[cacheIndex].drops) do
                                local mountID = entry[1]
                                local dropChanceDenominator = entry[2]

                                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                                if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                    local attempts = GetRarityAttempts(mountID) or 0
                                    local rarityAttemptsText, dropChanceText = "", ""

                                    if dropChanceDenominator > 1 then
                                        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                            if MasterCollectorSV.showRarityDetail then
                                                local chance = 1 / dropChanceDenominator
                                                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))

                                                rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts, dropChanceDenominator)
                                                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                            end
                                        end
                                    end

                                    table.insert(mountsToShow, string.format("%s%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s", string.rep(" ", 4), MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText))
                                end
                            end
                        end
                    end

                    output = output .. string.format("%s%s is active!|r\n", MC.goldHex, activeTimewalkingEvent)

                    if #mountsToShow > 0 then
                        output = output .. string.format("%sMounts:\n", string.rep(" ", 4))
                        for _, mount in ipairs(mountsToShow) do
                            output = output .. string.format("%s%s\n", string.rep(" ", 4), mount)
                        end
                    end
                end
            end
        end

        local function getCurrencyInfoForMount(mountID)
            for _, entry in ipairs(calendarBagCurrency) do
                if entry[1] == mountID then
                    local amount = entry[2]
                    local itemID = entry[3]
                    local itemData = MC.ItemDetails[itemID]
                    local itemName = itemData and itemData.name or "Unknown"
                    return amount, itemName, "item", itemID
                end
            end
            for _, entry in ipairs(calendarCurrency) do
                if entry[1] == mountID then
                    local amount = entry[2]
                    local currencyID = entry[3]
                    local currencyName = C_CurrencyInfo.GetCurrencyInfo(currencyID) and C_CurrencyInfo.GetCurrencyInfo(currencyID).name or ("CurrencyID: " .. currencyID)
                    return amount, currencyName, "currency", currencyID
                end
            end
            return nil
        end

        local function GetEventAchievement(eventName)
            for _, entry in ipairs(eventmetaAchieves) do
                local achieveID, achieveEvent = entry[1], entry[2]
                if achieveEvent == eventName then
                    return achieveID
                end
            end
            return nil
        end

        for day = 1, dayCount do
            local dayEventCount = C_Calendar.GetNumDayEvents(0, day)

            for i = 1, dayEventCount do
                local event = C_Calendar.GetDayEvent(0, day, i)
                if event then
                    local normalizedEventName = event.title:match("^%s*(.-)%s*$") -- Trim spaces

                    for _, eventInfo in ipairs(calendarEvents) do
                        local eventName = eventInfo[1]

                        if normalizedEventName == eventName or (eventName == "Spirit of Echero" and IsSpiritOfEcheroActive()) or (eventName == "World Boss: Dunegorger Kraulok" and isDunegorgerAvailable()) then
                            local startTimeTable = {
                                year = event.startTime.year,
                                month = event.startTime.month,
                                day = event.startTime.monthDay,
                                hour = event.startTime.hour,
                                min = event.startTime.minute,
                                sec = 0
                            }

                            local endTimeTable = {
                                year = event.endTime.year,
                                month = event.endTime.month,
                                day = event.endTime.monthDay,
                                hour = event.endTime.hour,
                                min = event.endTime.minute,
                                sec = 0
                            }

                            local startTime = time(startTimeTable)
                            local endTime = time(endTimeTable)

                            if currentTime >= startTime and currentTime <= endTime then
                                if not activeEvents[eventName] then
                                    activeEvents[eventName] = true

                                    local achieveID = GetEventAchievement(eventName)
                                    if achieveID then
                                        local _, achievementName, _, isCompleted = GetAchievementInfo(achieveID)
                                        local _, achievementName2 = GetAchievementInfo(2144)
                                        local achievemountID = 267
                                        local achievemountName = C_MountJournal.GetMountInfoByID(achievemountID)
                                        if achievementName and not isCompleted then
                                            output = output .. string.format("%sAchievement Required: |r%s|cffffff00 - Not Yet Completed for %s!|r\n%s|Hmount:%d|h[%s]|h|r", MC.goldHex, achievementName, achievementName2, string.rep(" ", 4), MC.blueHex, achievemountID, achievemountName)
                                        end
                                    end

                                    local mountsToShow = {}
                                    for j, mountID in ipairs(eventInfo[2]) do
                                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                                        if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                            local rarityAttemptsText, dropChanceText, currencyText  = "", "", ""
                                            local amount, currencyName, currencyType, currencyID = getCurrencyInfoForMount(mountID)
                                            local attempts = GetRarityAttempts(eventInfo[3][j]) or 0
                                            local dropChanceDenominator = (eventInfo[4] and eventInfo[4][j]) or 1

                                            if dropChanceDenominator > 1 then
                                                if MasterCollectorSV.showRarityDetail then
                                                    local chance = 1 / dropChanceDenominator
                                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                                    rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts, dropChanceDenominator)
                                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                                end
                                            end

                                            if amount and currencyName then
                                                if currencyType == "currency" and currencyID then
                                                    local currencyInfo = C_CurrencyInfo.GetCurrencyInfo(currencyID)
                                                    local owned = currencyInfo.quantity
                                                    local icon = currencyInfo.iconFileID
                                                    local currencyTexture = CreateTextureMarkup(icon, 32, 32, 16, 16, 0, 1, 0, 1)
                                                    currencyText = string.format("\n%s%s%d / %d %s %s Required|r\n", MC.goldHex, string.rep(" ", 4), owned, amount, currencyName, currencyTexture)
                                                elseif currencyType == "item" and currencyID then
                                                    local itemData = MC.ItemDetails[currencyID]
                                                    local itemName = itemData and itemData.name or "Unknown"
                                                    local icon = itemData and itemData.icon
                                                    local count = C_Item.GetItemCount(currencyID, false, false)
                                                    local currencyTexture = CreateTextureMarkup(icon, 32, 32, 16, 16, 0, 1, 0, 1)
                                                    currencyText = string.format("\n%s%s%d / %d %s %s Required|r", MC.goldHex, string.rep(" ", 4), count, amount, itemName, currencyTexture)
                                                end
                                            end

                                            if MasterCollectorSV.showMountName then
                                                table.insert(mountsToShow, string.format("%s|Hmount:%d|h[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s%s", MC.blueHex, mountID, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText, currencyText))
                                            end
                                        end
                                    end

                                    if #mountsToShow > 0 then
                                        output = output .. string.format("\n%s%s is active!|r\n%sMounts:\n", MC.goldHex, eventName, string.rep(" ", 4))

                                        for _, mount in ipairs(mountsToShow) do
                                            output = output .. string.format("%s%s\n", string.rep(" ", 4), mount)
                                        end
                                    else
                                        output = output .. string.format("\n%s%s is active!|r\n", MC.goldHex, eventName)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
        if output ~= "" then
            return output
        end
    end

    local displayText = ""
    local hasNonNilStatus = (displayText ~= "")

    local function appendIfNotNil(statusFunction)
        local status = statusFunction()
        if status and status ~= "" then
            displayText = displayText .. "\n" .. status
            hasNonNilStatus = true
        end
    end

    local statusFunctions = {
        EventsActive,
        legionRemix,
        ffaAchieveWQs,
        GetLegionInvasionStatus,
        GetActiveWarfrontStatus,
        GetFactionAssaultStatus,
        GetActiveNzothAssaults,
        GetSummonFromTheDepthsStatus,
        GetCovenantAssaultStatus,
        GetBeastwarrensHuntStatus,
        GetTormentorsOfTorghastStatus,
        TimeRiftsStatus,
        TheStormsFuryEvent,
        DragonbaneKeepSiege,
        IskaaraCommunityFeast,
        GrandHunts,
        ZaralekZones,
        Dreamsurges,
        SuffusionCamp,
        ElementalStorms,
        FroststoneVaultStorm,
        LegendaryAlbumWQs,
        ResearchersUnderFire,
        Superbloom,
        TheBigDig,
        TWWBeledarShift
    }

    for _, statusFunction in ipairs(statusFunctions) do
        appendIfNotNil(statusFunction)
    end

    if not hasNonNilStatus then
        displayText = MC.goldHex .. "We are all done here.... FOR NOW!|r"
    end

    if MC.mainFrame and MC.mainFrame.text then
        MC.mainFrame.text:SetText(displayText)
        MC.mainFrame.text:SetHeight(MC.mainFrame.text:GetContentHeight())
    end
end
