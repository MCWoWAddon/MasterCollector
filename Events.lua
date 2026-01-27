function MC.events()
    if MC.currentTab ~= "Event\nGrinds" then
        return
    end

    MC.InitializeColors()

    local fontSize = MasterCollectorSV.fontSize

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont(font, fontSize, flags)
    end

    function MC.RefreshMCEvents()
        if MasterCollectorSV.frameVisible and MasterCollectorSV.lastActiveTab == "Event\nGrinds" then
            MC.events() -- Call MC.events() to refresh the timer
            -- Schedule the next refresh after 60 seconds
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

        local _, achieveName = GetAchievementInfo(11474)
        local WQtext = string.format("%s%s Achievement WQ Active:|r\n", MC.goldHex, achieveName)
        local foundWQ = false
        local worldQuestsUnlocked = C_QuestLog.IsQuestFlaggedCompleted(45727)

        local faction = UnitFactionGroup("player")
        local mountID

        if faction == "Alliance" then
            mountID = 775 -- Alliance mount ID
        elseif faction == "Horde" then
            mountID = 784 -- Horde mount ID
        end

        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)

        if MasterCollectorSV.showFFAWQTimer then
            for questID, questName in pairs(ffaQuestIDs) do
                local mapID = ffaMapIDs[questID]
                local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)

                if taskInfo then
                    for _, info in ipairs(taskInfo) do
                        local questId = info and info.questID
                        if questID and HaveQuestData(questId) and QuestUtils_IsQuestWorldQuest(questId) then
                            if questId == questID then
                                local mapName = C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name or
                                    "Fetching Map Failed, Retrying in 60 Seconds."
                                local duration = C_TaskQuest.GetQuestTimeLeftSeconds(questId)

                                WQtext = WQtext ..
                                    "    " ..
                                    mapName ..
                                    ": " .. questName .. "\n    Time Remaining: " .. FormatTime(duration) .. "\n"
                                foundWQ = true

                                if MasterCollectorSV.showMountName then
                                    WQtext = WQtext .. string.format("    Mount: %s\n", mountName or "Unknown Mount")
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

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return WQtext
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
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
            ["Demon Hunter"] = { 868 },
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
        local _, achieveName, _, achieved = GetAchievementInfo(11546)

        local function getMountNamesByClass(class)
            local mountNames = {}
            local uncollectedMounts = {}
            local mountIDs = classMounts[class] or {}

            for _, mountID in ipairs(mountIDs) do
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                if mountName then
                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, mountName)
                    end
                    table.insert(mountNames, mountName)
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
                    invasionText = MC.goldHex ..
                        "Current Legion Invasion: |r" ..
                        currentMapName ..
                        " (" ..
                        FormatTime(timeLeft) .. " left)" .. "\n    Required for " .. achieveName .. " Achievement\n\n"

                    if MasterCollectorSV.showMountName then
                        invasionText = invasionText ..
                            "    Mounts for " .. className .. ": " .. mountNamesString .. "\n\n"
                    end

                    invasionText = invasionText ..
                        MC.goldHex ..
                        "Next Legion Invasion: |r" ..
                        (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") .. "\n"

                    if not achieved and MasterCollectorSV.hideBossesWithMountsObtained then
                        return invasionText
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        return invasionText
                    end
                end
            end

            if elapsedTime < duration then
                invasionText = MC.goldHex ..
                    "Legion Invasion Active: |r" ..
                    FormatTime(duration - elapsedTime) .. "\n    Required for " .. achieveName .. " Achievement\n\n"
            else
                local timeUntilNext = nextInvasionTime - realmTime
                local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                local _, nextMapName = GetInvasionInfo(mapIDs[nextMapIndex])
                invasionText = MC.goldHex ..
                    "Next Legion Invasion: |r" ..
                    (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") ..
                    " in " .. FormatTime(timeUntilNext) .. "\n"
            end

            if not achieved and MasterCollectorSV.hideBossesWithMountsObtained then
                return invasionText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
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
                    local line = mountName ..
                        " " ..
                        MC.goldHex ..
                        playerCurrency .. " / " .. cost .. " Service Medals " .. iconSize .. " Required|r\n"

                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, line)
                    end
                    table.insert(mountDetails, line)
                end
            end

            if not allCollected then
                return table.concat(uncollectedMounts, "    ")
            else
                return table.concat(mountDetails, "    ")
            end
        end

        if MasterCollectorSV.showBfaAssaultTimer then
            for _, mapID in ipairs(mapIDs) do
                timeLeft, currentMapName = GetAssaultInfo(mapID)
                if timeLeft and timeLeft > 0 then
                    local mountNamesString = getMountNamesByFaction(playerFaction)
                    assaultText = MC.goldHex ..
                        "Current Faction Assault: |r" .. currentMapName .. " (" .. FormatTime(timeLeft) .. " Remaining\n"

                    if MasterCollectorSV.showMountName then
                        assaultText = assaultText ..
                            "    Mounts for " .. playerFaction .. ": " .. mountNamesString
                    end

                    if MasterCollectorSV.hideBossesWithMountsObtained and not allCollected then
                        return assaultText
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        return assaultText
                    end
                end
            end

            if elapsedTime < duration then
                assaultText = MC.goldHex .. "Faction Assault Active: |r" .. FormatTime(duration - elapsedTime) .. "\n"
            else
                local timeUntilNext = nextAssaultTime - realmTime
                local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                local _, nextMapName = GetAssaultInfo(mapIDs[nextMapIndex])
                local mountNamesString = getMountNamesByFaction(playerFaction)
                assaultText = MC.goldHex ..
                    "Next Faction Assault: |r" ..
                    (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") ..
                    " in " .. FormatTime(timeUntilNext) .. "\n"

                if MasterCollectorSV.showMountName then
                    assaultText = assaultText .. "    Mounts for " .. playerFaction .. ": " .. mountNamesString
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not allCollected then
                return assaultText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return assaultText
            end
        end
    end

    local function GetBeastwarrensHuntStatus()
        local huntNames = {
            "Shadehounds",
            "Soul Eaters",
            "Death Elementals",
            "Winged Soul Eaters"
        }

        local baseTime = playerRegion == 1 and 1727794800 or (playerRegion == 3 and 1737514800)
        local fullRotationInterval = 1210000 -- 14 days in seconds
        local huntDuration = 302400          -- 3 days and 12 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % fullRotationInterval
        local currentHuntIndex = (math.floor(elapsedTimeInRotation / huntDuration) % #huntNames) + 1
        local elapsedTimeInHunt = elapsedTimeInRotation % huntDuration
        local timeRemainingInHunt = huntDuration - elapsedTimeInHunt
        local shadehoundsMountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1304)
        local achieveMountName = C_MountJournal.GetMountInfoByID(1504)
        local _, achieveName, _, achieved = GetAchievementInfo(14738)
        local dropChanceDenominator = 50
        local attempts = GetRarityAttempts(shadehoundsMountName) or 0
        local rarityAttemptsText = ""
        local dropChanceText = ""

        if MasterCollectorSV.showRarityDetail then
            local chance = 1 / dropChanceDenominator
            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
            rarityAttemptsText = string.format("\n     (Attempts: %d/%s", attempts, dropChanceDenominator)
            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
        end

        if MasterCollectorSV.showBeastwarrensHuntTimer then
            local huntText = ""
            if timeRemainingInHunt > 0 then
                huntText = MC.goldHex ..
                    "Current Maw Beastwarrens Hunt: |r" ..
                    huntNames[currentHuntIndex] ..
                    "\n" .. "     Time Remaining: " .. FormatTime(timeRemainingInHunt) .. "\n"

                if MasterCollectorSV.showMountName then
                    if huntNames[currentHuntIndex] == "Shadehounds" and (not MasterCollectorSV.hideBossesWithMountsObtained or not collected) then
                        huntText = huntText ..
                            "    " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
                    end

                    if not achieved then
                        huntText = huntText ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " yet to be Completed for Breaking the Chains Meta Achievement|r\n    Mount: " ..
                            achieveMountName .. "\n"
                    else
                        huntText = huntText ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " for Breaking the Chains Meta Achievement |r\n    Mount: " .. achieveMountName .. "\n"
                    end
                end
            end

            local nextHuntIndex = (currentHuntIndex % #huntNames) + 1
            huntText = huntText ..
                "\n" .. MC.goldHex .. "Next Maw Beastwarrens Hunt: |r" .. huntNames[nextHuntIndex] .. "\n"
            if MasterCollectorSV.showMountName then
                if huntNames[nextHuntIndex] == "Shadehounds" and not MasterCollectorSV.hideBossesWithMountsObtained then
                    huntText = huntText ..
                        "     Mount: " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
                elseif huntNames[nextHuntIndex] == "Shadehounds" and not collected then
                    huntText = huntText ..
                        "     Mount: " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
                end
            end
            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return huntText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return huntText
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
        local _, achieveName, _, achieved = GetAchievementInfo(15035)
        local achieve1MountName = C_MountJournal.GetMountInfoByID(1504)
        local achieve2MountName = C_MountJournal.GetMountInfoByID(2114)

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
                    if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                        if not questCompleted then
                            return MC.goldHex .. "Current Maw Assault: |r\n" ..
                                "    Please complete Chapter 2 of the Chains of Domination questline, Maw Walkers.\n"
                        else
                            return MC.goldHex .. "Fetching Maw Assault Status... Standby |r\n"
                        end
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        if not questCompleted then
                            return MC.goldHex .. "Current Maw Assault: |r\n" ..
                                "    Please complete Chapter 2 of the Chains of Domination questline, Maw Walkers.\n"
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
                local assaultDisplay = MC.goldHex ..
                    "Current Maw Assault: |r" ..
                    assaultName .. "\n" .. "    Time Remaining: " .. FormatTime(currentAssaultSecondsLeft) .. "\n"
                local attempts = GetRarityAttempts(mountName) or 0

                if MasterCollectorSV.showRarityDetail then
                    local chance = 1 / dropChanceDenominator
                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                    rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                end

                if MasterCollectorSV.showMountName then
                    assaultDisplay = assaultDisplay ..
                        "    Mount: |r" .. mountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                    if not achieved then
                        assaultDisplay = assaultDisplay ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " yet to be Completed for Breaking the Chains Meta Achievement|r\n     Mount: " ..
                            achieve1MountName .. "\n"
                        assaultDisplay = assaultDisplay ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " yet to be Completed for Back from the Beyond Meta Achievement|r\n     Mount: " ..
                            achieve2MountName .. "\n"
                    elseif achieved then
                        assaultDisplay = assaultDisplay ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " for Breaking the Chains Meta Achievement|r\n     Mount: " .. achieve1MountName .. "\n"
                        assaultDisplay = assaultDisplay ..
                            "\n    " ..
                            MC.goldHex ..
                            achieveName ..
                            " for Back from the Beyond Meta Achievement|r\n     Mount: " .. achieve2MountName .. "\n"
                    end
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                    return assaultDisplay
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return assaultDisplay
                end
            end
        else
            return nil
        end
    end

    local function GetSummonFromTheDepthsStatus()
        local baseTime = playerRegion == 1 and 1728255660 or
            (playerRegion == 3 and 1728255660) -- Replace with EU base time when known
        local eventInterval = 10800            -- 3 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1238)
        local _, achieveName = GetAchievementInfo(13638)

        if MasterCollectorSV.showSummonDepthsTimer then
            local eventText = MC.goldHex .. "Next Summon from the Depths: |r" .. FormatTime(timeUntilNextEvent) .. "\n"

            if MasterCollectorSV.showMountName then
                eventText = eventText ..
                    string.format("    %s Achievement Mount: %s\n", achieveName, mountName or "Unknown Mount")
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return eventText
            end
        end
    end

    local function TimeRiftsStatus()
        local baseTime = playerRegion == 1 and 1733025600 or (playerRegion == 3 and 1733025600)
        local eventInterval = 3600
        local activeDuration = 900 -- 15 minutes active in seconds
        local _, achieveName, _, earned = GetAchievementInfo(19485)
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration
        local playerParaflakes = C_CurrencyInfo.GetCurrencyInfo(2594).quantity
        local iconParaflakes = C_CurrencyInfo.GetCurrencyInfo(2594).iconFileID
        local iconSize = CreateTextureMarkup(iconParaflakes, 32, 32, 16, 16, 0, 1, 0, 1)

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
                eventText = MC.goldHex ..
                    "Time Rift Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex .. "Next Time Rift: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            local achieveText = string.format("\n%s    %s %s for A World Awoken Meta Achievement|r\n", MC.goldHex,
                achieveName, not earned and "yet to be Completed" or "")
            local uncollectedMounts = {}
            local mountOutput = ""
            local achieveMountOutput = ""
            local allMountsCollected = true

            for _, mountID in ipairs(mountIDs) do
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                if mountID == 1618 then
                    if MasterCollectorSV.showMountName and mountName then
                        local mountText = "    Mount: " .. mountName .. "\n"
                        achieveMountOutput = achieveText .. mountText
                    end
                else
                    if not collected then
                        allMountsCollected = false -- Found an uncollected mount
                        if MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(uncollectedMounts, mountID)
                        end
                    end
                    if MasterCollectorSV.showMountName and mountName then
                        if not MasterCollectorSV.hideBossesWithMountsObtained or not collected then
                            mountOutput = mountOutput ..
                                "    Mount: " ..
                                mountName ..
                                " " ..
                                MC.goldHex ..
                                playerParaflakes .. " / 3000 " .. " Paracausal Flakes " .. iconSize .. " Required|r\n"
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
        local eventText = string.format("%sActive %s Event:|r ", MC.goldHex, questName)
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1478)
        local playerEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).quantity
        local iconEleOverflow = C_CurrencyInfo.GetCurrencyInfo(2118).iconFileID
        local iconSize = CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1)

        if MasterCollectorSV.showStormsFuryTimer then
            if questID and HaveQuestData(questID) and QuestUtils_IsQuestWorldQuest(questID) then
                local duration = C_TaskQuest.GetQuestTimeLeftSeconds(questID)

                if duration then
                    eventText = eventText .. FormatTime(duration) .. " Remaining\n"
                else
                    local baseTime = playerRegion == 1 and 1733036400 or (playerRegion == 3 and 1733047200)
                    local eventInterval = 18000 -- 5 hours in seconds
                    local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
                    local timeUntilNextEvent = eventInterval - elapsedTimeInRotation

                    eventText = MC.goldHex .. "Next The Storm's Fury Event: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
                end

                if MasterCollectorSV.showMountName then
                    eventText = eventText ..
                        "    Mount: " ..
                        mountName ..
                        "\n    " ..
                        MC.goldHex ..
                        playerEleOverflow ..
                        " / 3000 " .. " Elemental Overflow " .. iconSize .. " & 150 Essence of the Storm Required|r\n"
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return eventText
            end
        end
    end

    local function DragonbaneKeepSiege()
        local baseTime = playerRegion == 1 and 1733029200 or (playerRegion == 3 and 1733040000)
        local eventInterval = 7200
        local activeDuration = 3600
        local _, achieveName, _, earned = GetAchievementInfo(19483)
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        if MasterCollectorSV.showDragonbaneKeepTimer then
            local eventText
            if eventIsActive then
                eventText = MC.goldHex ..
                    "Siege of Dragonbane Keep Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex .. "Next Siege of Dragonbane Keep: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                local mountName = C_MountJournal.GetMountInfoByID(1651)
                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, mountName)
                else
                    eventText = eventText ..
                        string.format("\n%s    %s for A World Awoken Meta Achievement|r\n    Mount: %s\n", MC.goldHex,
                            achieveName, mountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
                if not collected and not earned then
                    return eventText
                end
            else
                return eventText
            end
        end
    end

    local function IskaaraCommunityFeast()
        local baseTime = playerRegion == 1 and 1733043600 or (playerRegion == 3 and 1733041800)
        local eventInterval = 5400
        local activeDuration = 900
        local _, achieveName, _, earned = GetAchievementInfo(19482)
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent
        local eventIsActive = elapsedTimeInRotation < activeDuration

        if eventIsActive then
            timeUntilNextEvent = activeDuration - elapsedTimeInRotation
        else
            timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        end

        if MasterCollectorSV.showFeastTimer then
            local eventText
            if eventIsActive then
                eventText = MC.goldHex ..
                    "Iskaara Community Feast Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex .. "Next Iskaara Community Feast: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                local mountName = C_MountJournal.GetMountInfoByID(1633)
                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, mountName)
                else
                    eventText = eventText ..
                        string.format("\n%s    %s for A World Awoken Meta Achievement|r\n    Mount: %s\n", MC.goldHex,
                            achieveName, mountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
                if not collected and not earned then
                    return eventText
                end
            else
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
            local eventText = MC.goldHex .. "Zaralek Active Zones: |r" .. table.concat(activeZones, ", ") .. "\n"

            if inactiveZone ~= 2 then
                local mountName = C_MountJournal.GetMountInfoByID(1732)
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1732)
                local rarityAttemptsText = ""
                local dropChanceText = ""

                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if MasterCollectorSV.showRarityDetail then
                        local dropChanceDenominator = 100
                        local attempts = GetRarityAttempts("Cobalt Shalewing") or 0
                        local chance = 1 / dropChanceDenominator
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))

                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts,
                            dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)\n", cumulativeChance)
                    end
                end

                if MasterCollectorSV.showMountName then
                    eventText = eventText .. MC.goldHex .. "    Karokta is Active!\n    |rMount: " .. mountName .. rarityAttemptsText .. dropChanceText
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                    return eventText
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return eventText
                end

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
        local _, achieveName, _, earned = GetAchievementInfo(19481)

        if MasterCollectorSV.showHuntsTimer then
            local eventText
            local secondsLeftMessage = ""

            for poiID, mapID in pairs(grandHuntPOI) do
                local secondsLeft = C_AreaPoiInfo.GetAreaPOISecondsLeft(poiID)
                if secondsLeft then
                    local mapInfo = C_Map.GetMapInfo(mapID)
                    local mapName = mapInfo and mapInfo.name or "Unknown Map"
                    secondsLeftMessage = string.format("%s\n    Time Remaining: %s\n    ", mapName,
                        FormatTime(secondsLeft))
                end
            end

            if secondsLeftMessage ~= "" then
                if activeMapID then
                    eventText = MC.goldHex ..
                        "Grand Hunt Is Currently: |r" .. activeHuntName .. "\n    " .. secondsLeftMessage
                else
                    eventText = MC.goldHex ..
                        "Grand Hunt Is Currently: |r" ..
                        secondsLeftMessage ..
                        MC.redHex .. "\n    Please visit Active Hunt Zone to determine exact location.|r\n"
                end
            else
                eventText = MC.goldHex ..
                    "Grand Hunt Is Currently: |r" ..
                    MC.redHex ..
                    "Unable to determine Dragon Isles Grand Hunt location. Please visit a Dragon Isles zone.|r\n"
            end

            if MasterCollectorSV.showMountName then
                local mountName = C_MountJournal.GetMountInfoByID(1474)
                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, mountName)
                else
                    eventText = eventText ..
                        string.format("\n%s    %s for A World Awoken Meta Achievement|r\n    Mount: %s\n", MC.goldHex,
                            achieveName, mountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
                if not collected and not earned then
                    return eventText
                end
            else
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

        local mountIDs = {
            1614, -- Stormtouched Bruffalon
            1645, -- Renewed Magmammoth
            1671, -- Duskwing Ohuna
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

                        secondsLeftMessage = secondsLeftMessage ..
                            string.format("%s\n    Time Remaining: %s\n    ", mapName, FormatTime(secondsLeft))
                        break
                    end
                end
            end

            local _, achieveName, _, earned = GetAchievementInfo(19008)
            local eventText = MC.goldHex .. "Dreamsurge Is Currently: |r" .. secondsLeftMessage
            local timeToNext = CalculateNextPortalTime()
            local portalMessage = string.format("    Next Waking Dream Portal: |r%s", FormatTime(timeToNext))

            if MasterCollectorSV.showMountName then
                local currencyMountName, _, _, _, _, _, _, _, _, _, collected1 = C_MountJournal.GetMountInfoByID(1671)
                local wakingDreamMountName, _, _, _, _, _, _, _, _, _, collected2 = C_MountJournal.GetMountInfoByID(1645)
                local achieveMountName = C_MountJournal.GetMountInfoByID(1614)

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected1 then
                    eventText = eventText ..
                        "Mount: " ..
                        currencyMountName ..
                        "\n    (Requires 1000 Dreamsurge Coalescence)\n\n" .. MC.goldHex .. portalMessage .. "|r\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "Mount: " ..
                        currencyMountName ..
                        "\n    (Requires 1000 Dreamsurge Coalescence)\n\n" .. MC.goldHex .. portalMessage .. "|r\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected2 then
                    eventText = eventText ..
                        string.format("    Mount: %s\n    (combine 20 Elemental Remains)\n",
                            wakingDreamMountName or "Unknown Mount")
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        string.format("    Mount: %s\n    (combine 20 Elemental Remains)\n",
                            wakingDreamMountName or "Unknown Mount")
                end

                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                else
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, achieveMountName)
                end
            else
                eventText = eventText .. "\n" .. MC.goldHex .. portalMessage .. "|r\n"
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                for _, mountID in ipairs(mountIDs) do
                    local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                    if not collected then
                        return eventText
                    end
                end
            else
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

                        secondsLeftMessage = secondsLeftMessage ..
                            string.format("%s\n    Time Remaining: %s\n    ", mapName, FormatTime(secondsLeft))
                        break
                    end
                end
            end

            local _, achieveName, _, earned = GetAchievementInfo(18867)
            local eventText = MC.goldHex .. "Suffusion Camp Is Currently: |r" .. secondsLeftMessage

            if MasterCollectorSV.showMountName then
                local achieveMountName = C_MountJournal.GetMountInfoByID(1614)

                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                else
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, achieveMountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
                if not collected and not earned then
                    return eventText
                end
            else
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
                            table.insert(activeStorms, {
                                name = stormType,
                                map = mapName
                            })

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
                eventText = eventText .. MC.goldHex .. "Active Elemental Storms: |r"
                if timerDisplay then
                    eventText = eventText .. timerDisplay
                end
                for _, storm in ipairs(activeStorms) do
                    eventText = eventText .. string.format("\n    %s (%s)", storm.map, storm.name)
                end
                if #activeStorms < 2 then
                    eventText = eventText ..
                        "\n\n" ..
                        MC.redHex .. "Unable to determine Another Storm. Please visit a Dragon Isles Zone to verify.|r"
                end
            else
                eventText = eventText .. MC.goldHex .. "Next Elemental Storms: |r" .. FormatTime(timeUntilNextEvent)
            end

            local _, achieveName, _, earned = GetAchievementInfo(16492)
            if MasterCollectorSV.showMountName then
                local currencyMountName1, _, _, _, _, _, _, _, _, _, collected1 = C_MountJournal.GetMountInfoByID(1622)
                local currencyMountName2, _, _, _, _, _, _, _, _, _, collected2 = C_MountJournal.GetMountInfoByID(1467)
                local achieveMountName = C_MountJournal.GetMountInfoByID(1621)

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected1 then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName1 ..
                        MC.goldHex ..
                        "\n    " ..
                        playerEleOverflow ..
                        " / 2,000 Elemental Overflow " ..
                        CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName1 ..
                        MC.goldHex ..
                        "\n    " ..
                        playerEleOverflow ..
                        " / 2,000 Elemental Overflow " ..
                        CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected2 then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName2 ..
                        MC.goldHex ..
                        "\n    " ..
                        playerEleOverflow ..
                        " / 100,000 Elemental Overflow " ..
                        CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName2 ..
                        MC.goldHex ..
                        "\n    " ..
                        playerEleOverflow ..
                        " / 100,000 Elemental Overflow " ..
                        CreateTextureMarkup(iconEleOverflow, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                end

                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex,
                            achieveName, achieveMountName)
                else
                    eventText = eventText ..
                        string.format("\n%s    %s for A World Awoken Meta Achievement|r\n    Mount: %s\n", MC.goldHex,
                            achieveName, achieveMountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                for _, mountID in ipairs(mountIDs) do
                    local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                    if not collected then
                        return eventText
                    end
                end
            else
                return eventText
            end
        end
    end

    local function FroststoneVaultStorm()
        local baseTime = playerRegion == 1 and 1679576400 or (playerRegion == 3 and 1679572800)
        local eventInterval = 7200 -- 2 hours in seconds
        local elapsedTimeInRotation = (realmTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        local achieveMountName = C_MountJournal.GetMountInfoByID(1238)
        local _, achieveName, _, earned = GetAchievementInfo(17540)

        if MasterCollectorSV.showFroststoneStormTimer then
            local eventText = MC.goldHex ..
                "Next Froststone Vault Primal Storm: |r" .. FormatTime(timeUntilNextEvent) .. "\n"

            if MasterCollectorSV.showMountName then
                local currencyMountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1627)
                if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                    eventText = eventText ..
                        "    Mount: " .. currencyMountName .. "\n    (combine 50 Leftover Elemental Slime)\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "    Mount: " .. currencyMountName .. "\n    (combine 50 Leftover Elemental Slime)\n"
                end

                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for You Know How to Reach Me for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                else
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s for You Know How to Reach Me for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
                if not collected and not earned then
                    return eventText
                end
            else
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

        local _, achieveName, _, earned = GetAchievementInfo(16570)
        local WQtext = string.format("%s%s Achievement WQ/s Active:|r\n", MC.goldHex, achieveName)
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1669)
        local foundWQ = false

        if MasterCollectorSV.showLegendaryAlbumTimer then
            local allQuestNames = ""
            local overallDuration = nil
            for questID, questName in pairs(legendaryQuestIDs) do
                local mapID = legendaryMapIDs[questID]
                local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)

                if taskInfo then
                    for _, info in ipairs(taskInfo) do
                        local questId = info and info.questID
                        if questID and HaveQuestData(questId) and QuestUtils_IsQuestWorldQuest(questId) then
                            if questId == questID then
                                allQuestNames = allQuestNames .. "    " .. questName .. "\n"
                                overallDuration = C_TaskQuest.GetQuestTimeLeftSeconds(questId)
                            end
                        end
                    end
                end
            end
            if allQuestNames ~= "" and overallDuration then
                WQtext = WQtext .. "    Time Remaining: " .. FormatTime(overallDuration) .. "\n\n"
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
                if not earned then
                    WQtext = WQtext ..
                        string.format(
                            "%s    %s yet to be Completed for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, mountName)
                else
                    WQtext = WQtext ..
                        string.format(
                            "%s    %s for Across the Isles for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, mountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return WQtext
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
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


        local achieveMountName = C_MountJournal.GetMountInfoByID(1733)
        local _, achieveName, _, earned = GetAchievementInfo(17781)
        local dropMountName, _, _, _, _, _, _, _, _, _, collected3 = C_MountJournal.GetMountInfoByID(1735)
        local dropChanceDenominator = 33
        local rarityAttemptsText = ""
        local dropChanceText = ""
        local attempts = GetRarityAttempts("Flaming Shalewing Subject 01") or 0

        local mountIDs = {
            1603, -- Subterranean Magmammoth
            1730, -- Igneous Shalewing
            1735, -- Cataloged Shalewing
            1733, -- Calescent Shalewing
        }

        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
            if MasterCollectorSV.showRarityDetail then
                local chance = 1 / dropChanceDenominator
                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
            end
        end

        if MasterCollectorSV.showResearchersUnderFireTimer then
            local eventText
            if eventIsActive then
                eventText = MC.goldHex ..
                    "Researchers Under Fire Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex ..
                    "Next Researchers Under Fire Event: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                local currencyMountName1, _, _, _, _, _, _, _, _, _, collected1 = C_MountJournal.GetMountInfoByID(1603)
                local currencyMountName2, _, _, _, _, _, _, _, _, _, collected2 = C_MountJournal.GetMountInfoByID(1730)

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected1 then
                    eventText = eventText ..
                        "    Mount: " ..
                        currencyMountName1 ..
                        "\n    (Requires 100 Unearthed Fragrant Coin to trade for Coveted Baubles)\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "    Mount: " ..
                        currencyMountName1 ..
                        "\n    (Requires 100 Unearthed Fragrant Coin to trade for Coveted Baubles)\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected2 then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName2 ..
                        "\n    (Requires 400 Unearthed Fragrant Coin to trade for Coveted Baubles)\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "\n    Mount: " ..
                        currencyMountName2 ..
                        "\n    (Requires 400 Unearthed Fragrant Coin to trade for Coveted Baubles)\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected3 then
                    eventText = eventText ..
                        "\n    Mount: " .. dropMountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "\n    Mount: " .. dropMountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                end

                if not earned then
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s yet to be Completed for Que Zara(lek), Zara(lek) for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                else
                    eventText = eventText ..
                        string.format(
                            "\n%s    %s for Que Zara(lek), Zara(lek) for A World Awoken Meta Achievement|r\n    Mount: %s\n",
                            MC.goldHex, achieveName, achieveMountName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                for _, mountID in ipairs(mountIDs) do
                    local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                    if not collected then
                        return eventText
                    end
                end
            else
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

        local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1825)
        local _, achieveName, _, earned = GetAchievementInfo(19318)

        if MasterCollectorSV.showSuperbloomTimer then
            local eventText
            if eventIsActive then
                eventText = MC.goldHex ..
                    "Superbloom Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex .. "Next Superbloom: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                if not earned then
                    eventText = eventText ..
                        string.format("\n%s    %s yet to be Completed for A World Awoken Meta Achievement|r\n",
                            MC.goldHex,
                            achieveName)
                else
                    eventText = eventText ..
                        string.format("\n%s    %s for A World Awoken Meta Achievement|r\n", MC.goldHex, achieveName)
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and (not collected and not earned) then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
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

        local dropMountName, _, _, _, _, _, _, _, _, _, collected1 = C_MountJournal.GetMountInfoByID(2038)
        local currencyMountName, _, _, _, _, _, _, _, _, _, collected2 = C_MountJournal.GetMountInfoByID(1638)
        local dropChanceDenominator = 200
        local rarityAttemptsText = ""
        local dropChanceText = ""
        local attempts = GetRarityAttempts(dropMountName) or 0
        local playerMysteriousFragments = C_CurrencyInfo.GetCurrencyInfo(2657).quantity
        local iconMysteriousFragments = C_CurrencyInfo.GetCurrencyInfo(2657).iconFileID

        local mountIDs = {
            2038, -- Clayscale Hornstrider
            1638, -- Explorer's Stonehide Packbeast
        }

        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
            if MasterCollectorSV.showRarityDetail then
                local chance = 1 / dropChanceDenominator
                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
            end
        end

        if MasterCollectorSV.showBigDigTimer then
            local eventText
            if eventIsActive then
                eventText = MC.goldHex ..
                    "The Big Dig: Traitors Rest Event Active! Ends in: |r" ..
                    FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex ..
                    "Next The Big Dig: Traitors Rest Event: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                if MasterCollectorSV.hideBossesWithMountsObtained and not collected1 then
                    eventText = eventText ..
                        "    Mount: " ..
                        currencyMountName ..
                        MC.goldHex ..
                        "\n    " ..
                        playerMysteriousFragments ..
                        " / 20,000 Mysterious Fragments  " ..
                        CreateTextureMarkup(iconMysteriousFragments, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "    Mount: " ..
                        currencyMountName ..
                        MC.goldHex ..
                        "\n    " ..
                        playerMysteriousFragments ..
                        " / 20,000 Mysterious Fragments  " ..
                        CreateTextureMarkup(iconMysteriousFragments, 32, 32, 16, 16, 0, 1, 0, 1) .. " Required|r\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and not collected2 then
                    eventText = eventText ..
                        "\n    Mount: " .. dropMountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    eventText = eventText ..
                        "\n    Mount: " .. dropMountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained then
                for _, mountID in ipairs(mountIDs) do
                    local _, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                    if not collected then
                        return eventText
                    end
                end
            else
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


        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(2192)

        if MasterCollectorSV.showBeledarShiftTimer then
            local eventText

            if eventIsActive then
                eventText = MC.goldHex ..
                    "Beledar Dark Phase Active! Ends in: |r" .. FormatTime(timeUntilNextEvent) .. " Remaining\n"
            else
                eventText = MC.goldHex ..
                    "Next Beledar Shift to Dark Phase: |r" .. FormatTime(timeUntilNextEvent) .. "\n"
            end

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("    Mount: %s\n", mountName or "Unknown Mount")
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return eventText
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
        local eventText = MC.goldHex .. "Current Tormentor: |r" .. currentBoss .. "\n\n"

        local maxNameLength = 0
        for _, name in ipairs(tormentorRotation) do
            if #name > maxNameLength then
                maxNameLength = #name
            end
        end

        local fixedTimerColumn = maxNameLength + 10
        local mount1ID = 1475
        local mount2ID = 1504
        local mount1Text = ""
        local mount2Text = ""
        local mountName, collected = "", false

        if MasterCollectorSV.showTormentorsTimer then
            local function mountCheck(mountID)
                mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(63854)
                local _, achieveName, _, achieved = GetAchievementInfo(15054)

                local eventText = ""
                local mountText = string.format("    Mount: %s", mountName or "Unknown Mount")

                local dropChanceDenominator = 50
                local attempts = GetRarityAttempts("Chain of Bahmethra") or 0
                local rarityAttemptsText = ""
                local dropChanceText = ""

                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if MasterCollectorSV.showRarityDetail then
                        local chance = 1 / dropChanceDenominator
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                        rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                    end
                end

                if MasterCollectorSV.showMountName then
                    if mountID == 1475 then
                        if not questCompleted then
                            eventText = "    Tormentor's Cache Weekly to do! \n" ..
                                mountText .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n\n"
                        else
                            eventText = "    " .. mountText .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n\n"
                        end
                    end

                    if mountID == 1504 then
                        if not achieved then
                            eventText = eventText ..
                                "    " ..
                                MC.goldHex ..
                                achieveName ..
                                " yet to be Completed for Breaking the Chains Meta Achievement|r\n" ..
                                mountText .. "\n\n"
                        else
                            eventText = eventText ..
                                "    " ..
                                MC.goldHex ..
                                achieveName .. " for Breaking the Chains Meta Achievement|r\n" .. mountText .. "\n\n"
                        end
                    end
                end
                return eventText
            end

            mount1Text = mountCheck(mount1ID)
            mount2Text = mountCheck(mount2ID)
            eventText = eventText .. mount1Text .. mount2Text

            eventText = eventText .. MC.goldHex .. "Upcoming Tormentors:" .. "|r\n"

            for i = 1, rotationSize do
                local index = (currentRotationIndex + i - 1) % rotationSize + 1
                local timeUntilSpawn = (i - 1) * eventInterval + timeUntilNextSpawn
                local name = tormentorRotation[index]
                local padding = string.rep(" ", fixedTimerColumn - #name)

                eventText = eventText .. "    " .. name .. padding .. FormatTime(timeUntilSpawn) .. "\n"
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return eventText
            end
        end
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
                local timeRemainingText = timeRemaining and SecondsToTime(math.max(timeRemaining, 0)) or
                    "Awaiting Resources"
                local controlText

                if contributionState == 1 then
                    local oppositeFaction = (warfront.faction == "Horde") and "Alliance" or "Horde"
                    controlText = oppositeFaction .. " still in Control    " .. warfront.faction .. " Contributing"
                elseif contributionState == 2 then
                    controlText = warfront.faction .. " Controlling"
                elseif contributionState == 3 then
                    controlText = warfront.faction .. " Defending"
                else
                    controlText = "Unknown state"
                end

                activeWarfronts[warfront.name] = string.format(
                    "%s%s|r\n    %s\n    Time Left till Status Change: %s\n",
                    MC.goldHex, warfront.name, controlText, timeRemainingText
                )
            end
        end

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
                    local line = mountName ..
                        " " ..
                        MC.goldHex ..
                        playerCurrency .. " / " .. cost .. " Service Medals " .. iconSize .. " Required|r\n"

                    if not collected then
                        allCollected = false
                        table.insert(uncollectedMounts, line)
                    end
                    table.insert(mountDetails, line)
                end
            end

            if not allCollected then
                return table.concat(uncollectedMounts, "    ")
            else
                return table.concat(mountDetails, "    ")
            end
        end

        for warfrontName, warfrontText in pairs(activeWarfronts) do
            if (warfrontName == "Battle for Stromgarde (Arathi Highlands)" and MasterCollectorSV.showArathiWFTimer) or (warfrontName == "Battle for Darkshore" and MasterCollectorSV.showDarkshoreWFTimer) then
                local mountNamesString = getMountNamesByFaction(playerFaction)

                if warfrontText then
                    if MasterCollectorSV.showMountName then
                        table.insert(output,
                            warfrontText .. "    Mounts for " .. playerFaction .. ": " .. mountNamesString)
                    else
                        table.insert(output, warfrontText)
                    end
                else
                    table.insert(output, "No active Warfront found for " .. warfrontName .. ".")
                end
            end
        end

        if MasterCollectorSV.hideBossesWithMountsObtained and not allCollected then
            return table.concat(output, "\n")
        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
            return table.concat(output, "\n")
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
                            table.insert(majorMounts, { mountName, mountData[4], isCollected })
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
                            table.insert(minorMounts, { mountName, mountData[4], isCollected })
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

        local assaultDisplay = MC.goldHex .. "Current Nzoth Assaults:\n|r"
        local hasContent = false

        if showMajor then
            assaultDisplay = assaultDisplay .. "    Major: |r" .. detectedMajor .. "\n"
            hasContent = true
            if majorTimeLeft then
                assaultDisplay = assaultDisplay .. "    Time Remaining: " .. FormatTime(majorTimeLeft) .. "\n"
            end

            if #majorMounts > 0 then
                for _, mountData in ipairs(majorMounts) do
                    local mountName, dropChance, itemName = unpack(mountData)
                    local rarityAttemptsText = ""
                    local dropChanceText = ""

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
                        assaultDisplay = assaultDisplay .. "    Mount: |r" .. mountName .. rarityAttemptsText .. dropChanceText .. "\n"
                    end
                end
            end
        end

        if showMinor then
            assaultDisplay = assaultDisplay .. "\n" .. "    Minor: |r" .. detectedMinor .. "\n"
            hasContent = true
            if minorTimeLeft then
                assaultDisplay = assaultDisplay .. "    Time Remaining: " .. FormatTime(minorTimeLeft) .. "\n"
            end

            if #minorMounts > 0 then
                for _, mountData in ipairs(minorMounts) do
                    local mountName, dropChance, itemName = unpack(mountData)
                    local rarityAttemptsText = ""
                    local dropChanceText = ""

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
                        assaultDisplay = assaultDisplay .. "    Mount: |r" .. mountName .. rarityAttemptsText .. dropChanceText .. "\n"
                    end
                end
            end
        end
        if hasContent then
            return assaultDisplay
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
            [744] = "Sign of the Scourge",         -- Wrath of the Lich King
            [995] = "Sign of the Twisting Nether", -- Burning Crusade
            [1453] = "Sign of the Mists",          -- Mists of Pandaria
            [1971] = "Sign of Iron",               -- Warlords of Draenor
            [2274] = "Sign of the Legion",         -- Legion
        }

        local timewalkingEvents = {
            [744] = "Wrath of the Lich King Timewalking",
            [995] = "Burning Crusade Timewalking",
            [1453] = "Mists of Pandaria Timewalking",
            [1971] = "Warlords of Draenor Timewalking",
            [2274] = "Legion Timewalking",
        }

        for eventID, buffName in pairs(timewalkingBuffs) do
            if AuraUtil.FindAuraByName(buffName, "player") then
                return timewalkingEvents[eventID]
            end
        end
        return nil
    end

    local function EventsActive()
        local calendarEvents = {
            { "Brewfest",                           { 202, 226 },                    { "Swift Brewfest Ram", "Great Brewfest Kodo" },                                                                                   { 25, 25 } },
            { "Love is in the Air",                 { 352, 431, 1941 },              { "Big Love Rocket", "Swift Lovebird", "Heartseeker Mana Ray" },                                                                   { 3333, 0, 0 } },
            { "Hallow's End",                       { 219 },                         { "The Horseman's Reins" },                                                                                                        { 200 } },
            { "Noblegarden",                        { 430, 2023 },                   { "Swift Springstrider", "Noble Flying Carpet" },                                                                                  { 0, 100 } },
            { "Feast of Winter Veil",               { 769 },                         { "Minion of Grumpus" },                                                                                                           { 100 } },
            { "Darkmoon Faire",                     { 429, 434, 855, 962 },          { "Swift Forest Strider", "Darkmoon Dancing Bear", "Darkwater Skate", "Darkmoon Dirigible" },                                      { 0, 0, 0, 0 } },
            { "Classic Timewalking",                { 2224, 1737, 781 },             { "Reins of the Frayfeather Hippogryph", "Sandy Shalewing", "Reins of the Infinite Timereaver" },                                  { 0, 0, 4000 } },
            { "Burning Crusade Timewalking",        { 778, 2225, 1737, 781 },        { "Reins of the Eclipse Dragonhawk", "Reins of the Amani Hunting Bear", "Sandy Shalewing", "Reins of the Infinite Timereaver" },   { 0, 0, 0, 4000 } },
            { "Cataclysm Timewalking",              { 2473, 1737, 781 },             { "Broodling of Sinestra", "Sandy Shalewing", "Reins of the Infinite Timereaver" },                                                { 0, 0, 4000 } },
            { "Wrath of the Lich King Timewalking", { 552, 2317, 1737, 781 },        { "Bridle of the Ironbound Wraithcharger", "Enchanted Spellweave Carpet", "Sandy Shalewing", "Reins of the Infinite Timereaver" }, { 0, 0, 0, 4000 } },
            { "Mists of Pandaria Timewalking",      { 476, 2474, 1737, 781 },        { "Yu'lei, Daughter of Jade", "Copper-Maned Quilen Reins", "Sandy Shalewing", "Reins of the Infinite Timereaver" },                { 0, 0, 0, 4000 } },
            { "Warlords of Draenor Timewalking",    { 1242, 1243, 2470, 1737, 781 }, { "Beastlord's Irontusk", "Beastlord's Warwolf", "Nightfall Skyreaver", "Sandy Shalewing", "Reins of the Infinite Timereaver" },   { 0, 0, 0, 0, 4000 } },
            { "Legion Timewalking",                 { 1521, 2471, 1737, 781 },       { "Favor of the Val'sharah Hippogryph", "Ur'zul Fleshripper", "Sandy Shalewing", "Reins of the Infinite Timereaver" },             { 0, 0, 0, 4000 } },
            { "Spirit of Echero",                   { 779 },                         { "Spirit of Eche'ro" },                                                                                                           { 0 } },
            { "World Boss: Dunegorger Kraulok",     { 1250 },                        { "Slightly Damp Pile of Fur" },                                                                                                   { 100 } }
        }

        local oceRealms = {
            ["Aman'Thul"] = true,
            ["Barthilas"] = true,
            ["Caelestrasz"] = true,
            ["Dath'Remar"] = true,
            ["Dreadmaul"] = true,
            ["Frostmourne"] = true,
            ["Gundrak"] = true,
            ["Jubei'Thos"] = true,
            ["Khaz'goroth"] = true,
            ["Nagrand"] = true,
            ["Saurfang"] = true,
            ["Thaurissan"] = true
        }

        local realmName = GetRealmName()
        local isOCERealm = oceRealms[realmName]

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

        if isOCERealm then
            currentTime = currentTime - (18 * 60 * 60)
        end

        local activeEvents = {}
        local output = ""
        local activeTimewalkingEvent = GetActiveTimewalkingEvent()
        local playerTimewarpedBadges = C_CurrencyInfo.GetCurrencyInfo(1166).quantity
        local iconTimewarpedBadges = C_CurrencyInfo.GetCurrencyInfo(1166).iconFileID

        if activeTimewalkingEvent then
            for _, eventInfo in ipairs(calendarEvents) do
                local eventName = eventInfo[1]

                if eventName == activeTimewalkingEvent then
                    local mountsToShow = {}

                    for j, mountID in ipairs(eventInfo[2]) do
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(
                            mountID)

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
                                        rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts,
                                            dropChanceDenominator)
                                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                    end
                                end
                            else
                                if mountID ~= 781 then
                                    mountCurrency =
                                        (string.format("\n%s    %d / 5000 Timewarped Badges ", MC.goldHex, playerTimewarpedBadges)) ..
                                        CreateTextureMarkup(iconTimewarpedBadges, 32, 32, 16, 16, 0, 1, 0, 1) ..
                                        " Required|r\n"
                                end
                            end

                            if MasterCollectorSV.showMountName then
                                table.insert(mountsToShow,
                                    mountName .. mountCurrency .. rarityAttemptsText .. dropChanceText)
                            end
                        end
                    end

                    output = output .. MC.goldHex .. activeTimewalkingEvent .. " is active!|r\n"

                    if #mountsToShow > 0 then
                        output = output .. "    Mounts:\n"
                        for _, mount in ipairs(mountsToShow) do
                            output = output .. "    " .. mount .. "\n"
                        end
                    end
                end
            end
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

                                    local mountsToShow = {}
                                    for j, mountID in ipairs(eventInfo[2]) do
                                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                                        if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                            local rarityAttemptsText, dropChanceText = "", ""
                                            local attempts = GetRarityAttempts(eventInfo[3][j]) or 0
                                            local dropChanceDenominator = (eventInfo[4] and eventInfo[4][j]) or 1

                                            if dropChanceDenominator > 1 then
                                                if MasterCollectorSV.showRarityDetail then
                                                    local chance = 1 / dropChanceDenominator
                                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                                    rarityAttemptsText = string.format("  (Attempts: %d/%s", attempts,
                                                        dropChanceDenominator)
                                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                                end
                                            end

                                            if MasterCollectorSV.showMountName then
                                                table.insert(mountsToShow,
                                                    mountName .. rarityAttemptsText .. dropChanceText)
                                            end
                                        end
                                    end

                                    if #mountsToShow > 0 then
                                        output = output ..
                                            "\n" .. MC.goldHex .. eventName .. " is active!|r\n    Mounts:\n"
                                        for _, mount in ipairs(mountsToShow) do
                                            output = output .. "    " .. mount .. "\n"
                                        end
                                    else
                                        output = output .. MC.goldHex .. eventName .. " is active!|r\n"
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
    end
end
