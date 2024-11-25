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

    local calendarEvents = {
        {"Brewfest", {202, 226}, {"Swift Brewfest Ram", "Great Brewfest Kodo"}, {25, 25}},
        {"Love is in the Air", {352, 431, 1941}, {"Big Love Rocket", "Swift Lovebird", "Heartseeker Mana Ray"}, {3333, 0, 0}},
        {"Hallow's End", {219}, {"The Horseman's Reins"}, {200}},
        {"Noblegarden", {430, 2023}, {"Swift Springstrider", "Noble Flying Carpet"}, {0, 100}},
        {"Winter Veil", {769}, {"Minion of Grumpus"}, {100}},
        {"Darkmoon Faire", {429, 434, 855, 962}, {"Swift Forest Strider", "Darkmoon Dancing Bear", "Darkwater Skate", "Darkmoon Dirigible"}, {0, 0, 0, 0}},
        {"Burning Crusade Timewalking", {778, 781}, {"Reins of the Eclipse Dragonhawk", "Reins of the Infinite Timereaver"}, {0, 4000}},
        {"Wrath of the Lich King Timewalking", {552, 781}, {"Bridle of the Ironbound Wraithcharger", "Reins of the Infinite Timereaver"}, {0, 4000}},
        {"Mists of Pandaria Timewalking", {476, 781}, {"Yu'lei, Daughter of Jade", "Reins of the Infinite Timereaver"}, {0, 4000}},
        {"Warlords of Draenor Timewalking", {1242, 1243, 781}, {"Beastlord's Irontusk", "Beastlord's Warwolf", "Reins of the Infinite Timereaver"}, {0, 0, 4000}},
        {"Legion Timewalking", {1521, 781}, {"Favor of the Val'sharah Hippogryph", "Reins of the Infinite Timereaver"}, {0, 4000}},
        {"Spirit of Echero", {779}, {"Spirit of Eche'ro"}, {0}},
        {"World Boss: Dunegorger Kraulok", {1250}, {"Slightly Damp Pile of Fur"}, {100}}
    }

    local wqQuestIDs = {
        [42023] = "Black Rook Rumble",        -- Val'sharah
        [42025] = "Bareback Brawl",           -- Stormheim
        [41896] = "Operation Murloc Freedom", -- Azsuna
        [41013] = "Darkbrul Arena",           -- Highmountain
    }

    local mapIDs = {
        [42023] = 641,  -- Val'sharah
        [42025] = 634,  -- Stormheim
        [41896] = 630,  -- Azsuna
        [41013] = 650,  -- Highmountain
    }

    local function GetMapName(mapID)
        return C_Map.GetMapInfo(mapID) and C_Map.GetMapInfo(mapID).name or "Fetching Map Failed, Retrying in 60 Seconds."
    end

    local function GetQuestDuration(questID)
        local timeLeft = C_TaskQuest.GetQuestTimeLeftMinutes(questID)
        if timeLeft then
            local hours = math.floor(timeLeft / 60)
            local minutes = timeLeft % 60
            return string.format("%d hour%s and %d minute%s", hours, hours == 1 and "" or "s", minutes, minutes == 1 and "" or "s")
        else
            return "Fetching Duration, Standby...."
        end
    end

    local function AreWorldQuestsUnlocked()
        return C_QuestLog.IsQuestFlaggedCompleted(45727)
    end

    local function CheckWorldQuests()
        local WQtext = string.format("%sFree for All, Not for Me Achievement WQ Active:|r\n", MC.goldHex)
        local foundWQ = false
        local worldQuestsUnlocked = AreWorldQuestsUnlocked()

        local faction = UnitFactionGroup("player")
        local mountID

        if faction == "Alliance" then
            mountID = 775 -- Alliance mount ID
        elseif faction == "Horde" then
            mountID = 784 -- Horde mount ID
        end

        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)

        if MasterCollectorSV.showFFAWQTimer then
            for questID, questName in pairs(wqQuestIDs) do
                local mapID = mapIDs[questID]
                local taskInfo = C_TaskQuest.GetQuestsForPlayerByMapID(mapID)

                if taskInfo then
                    for _, info in ipairs(taskInfo) do
                        local questId = info and info.questID
                        if questID and HaveQuestData(questId) and QuestUtils_IsQuestWorldQuest(questId) then
                            if questId == questID then
                                local mapName = GetMapName(mapID)
                                local duration = GetQuestDuration(questId)
                                WQtext = WQtext .. string.format("    %s: %s\n    (%s left)\n", mapName, questName, duration)
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
            [630] = 5175,  -- Azsuna
            [641] = 5210,  -- Val'sharah
            [650] = 5177,  -- Highmountain
            [634] = 5178   -- Stormheim
        }

        local classMounts = {
            ["Death Knight"] = {866},
            ["Paladin"] = {885, 892, 893, 894},
            ["Rogue"] = {884, 889, 890, 891},
            ["Monk"] = {864},
            ["Warrior"] = {867},
            ["Shaman"] = {888},
            ["Hunter"] = {865, 870, 872},
            ["Warlock"] = {898, 930, 931},
            ["Priest"] = {861},
            ["Mage"] = {860},
            ["Demon Hunter"] = {868},
        }

        local allCollected = true
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

        local mapIDs = {630, 641, 650, 634}
        local playerRegion = GetCurrentRegion()
        local baseTime = playerRegion == 1 and 1727901000 or (playerRegion == 3 and 1729870200)
        local interval = 66600 -- 18.5 hrs in seconds
        local duration = 21600 -- 6 hrs in seconds
        local currentTime = GetServerTime()
        local elapsedTime = (currentTime - baseTime) % interval
        local nextInvasionTime = currentTime - elapsedTime + interval
        local currentMapIndex = math.floor((currentTime - baseTime) / interval) % #mapIDs + 1
        local className = UnitClass("player")

        local function FormatTime(seconds)
            return string.format("%02d Hrs %02d Min", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
        end

        local function GetInvasionInfo(mapID)
            local mapInvasionID = mapToInvasionIDs[mapID]
            if not mapInvasionID then return nil, "Fetching Map Failed, Retrying in 60 Seconds." end
            local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapInvasionID)
            local mapInfo = C_Map.GetMapInfo(mapID)
            return seconds, mapInfo and mapInfo.name or "Fetching Map Failed, Retrying in 60 Seconds."
        end

        local invasionText = ""
        local timeLeft, currentMapName
        local _, achieveName, _, achieved = GetAchievementInfo(11546)
        local mountNamesString = getMountNamesByClass(className)

        if MasterCollectorSV.showLegionInvasionTimer then
            for _, mapID in ipairs(mapIDs) do
                timeLeft, currentMapName = GetInvasionInfo(mapID)
                if timeLeft and timeLeft > 0 then
                    local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                    local _, nextMapName = GetInvasionInfo(mapIDs[nextMapIndex])
                    invasionText = MC.goldHex .. "Current Legion Invasion: |r" .. currentMapName .. " (" .. FormatTime(timeLeft) .. " left)" .. "\n    Required for "  .. achieveName .. " Achievement\n\n"

                    if MasterCollectorSV.showMountName then
                        invasionText = invasionText .. "    Mounts for " .. className .. ": " .. mountNamesString .. "\n\n"
                    end

                    invasionText = invasionText.. MC.goldHex .. "Next Legion Invasion: |r" .. (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") .. "\n"

                    if not achieved and MasterCollectorSV.hideBossesWithMountsObtained then
                        return invasionText
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        return invasionText
                    end
                end
            end

            if elapsedTime < duration then
                invasionText = MC.goldHex .. "Legion Invasion Active: |r" .. FormatTime(duration - elapsedTime) .. "\n    Required for "  .. achieveName .. " Achievement\n\n"
            else
                local timeUntilNext = nextInvasionTime - currentTime
                local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                local _, nextMapName = GetInvasionInfo(mapIDs[nextMapIndex])
                invasionText = MC.goldHex .. "Next Legion Invasion: |r" .. (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") .. " in " .. FormatTime(timeUntilNext) .. "\n"
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
            [2017] = {16, 8}, [2018] = {14, 2}, [2018] = {15, 8},
            [2019] = {13, 2}, [2019] = {14, 8}, [2020] = {12, 2}, 
            [2020] = {12, 8}, [2021] = {10, 2}, [2021] = {11, 8},
            [2022] = {9, 2},  [2022] = {10, 8}, [2023] = {8, 2}, 
            [2023] = {9, 8},  [2024] = {7, 2},  [2024] = {7, 8},
            [2025] = {5, 2},  [2025] = {6, 8},  [2026] = {4, 2}, 
            [2026] = {5, 8},  [2027] = {3, 2},  [2027] = {4, 8}
        }

        local startDay, eventMonth = startDates[year][1], startDates[year][2]
        local endDay = startDay + 13

        if month == eventMonth and day >= startDay and day <= endDay then
            return true
        end
        return false
    end

    local function GetFactionAssaultStatus()
        local mapToAssaultIDs = {
            [942] = 5966,  -- Stormsong Valley
            [864] = 5970,  -- Vol'dun
            [896] = 5964,  -- Drustvar
            [862] = 5973,  -- Zuldazar
            [895] = 5896,  -- Tiragarde Sound
            [863] = 5969   -- Nazmir
        }
    
        local mapIDs = {942, 864, 896, 862, 895, 863}
        local playerRegion = GetCurrentRegion()
        local baseTime = playerRegion == 1 and 1728061200 or (playerRegion == 3 and 1728439200)
        local interval = 68400 -- 19 hrs in seconds
        local duration = 25200 -- 7 hrs in seconds
        local currentTime = GetServerTime()
        local elapsedTime = (currentTime - baseTime) % interval
        local nextAssaultTime = currentTime - elapsedTime + interval
        local cyclesPassed = math.floor((currentTime - baseTime) / interval)
        local currentMapIndex = (cyclesPassed % #mapIDs) + 1
        local playerFaction = UnitFactionGroup("player")
    
        local function FormatTime(seconds)
            return string.format("%02d Hrs %02d Min", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
        end
    
        local function GetAssaultInfo(mapID)
            local mapAssaultID = mapToAssaultIDs[mapID]
            if not mapAssaultID then return nil, "Fetching Map Failed, Retrying in 60 Seconds." end
            local seconds = C_AreaPoiInfo.GetAreaPOISecondsLeft(mapAssaultID)
            local mapInfo = C_Map.GetMapInfo(mapID)
            return seconds, mapInfo and mapInfo.name or "Fetching Map Failed, Retrying in 60 Seconds."
        end
    
        local assaultText = ""
        local timeLeft, currentMapName
    
        local factionMounts = {
            ["Alliance"] = {1204, 1214, 1216},
            ["Horde"] = {1204, 1210, 1215},
        }

        local allCollected = true
        local function getMountNamesByFaction(faction)
            local mountNames = {}
            local uncollectedMounts = {}
            local mountIDs = factionMounts[faction] or {}
        
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

        if MasterCollectorSV.showBfaAssaultTimer then
            for _, mapID in ipairs(mapIDs) do
                timeLeft, currentMapName = GetAssaultInfo(mapID)
                if timeLeft and timeLeft > 0 then
                    local mountNamesString = getMountNamesByFaction(playerFaction)
                    assaultText = MC.goldHex .. "Current Faction Assault: |r" .. currentMapName .. " (" .. FormatTime(timeLeft) .. " left)" .. "\n"
                    
                    if MasterCollectorSV.showMountName then
                        assaultText = assaultText .. "    Mounts for " .. playerFaction .. ": " .. mountNamesString .. "\n"
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
                local timeUntilNext = nextAssaultTime - currentTime
                local nextMapIndex = (currentMapIndex % #mapIDs) + 1
                local _, nextMapName = GetAssaultInfo(mapIDs[nextMapIndex])
                local mountNamesString = getMountNamesByFaction(playerFaction)
                assaultText = MC.goldHex .. "Next Faction Assault: |r" .. (nextMapName or "Fetching Map Failed, Retrying in 60 Seconds.") .. " in " .. FormatTime(timeUntilNext) .. "\n"
                
                if MasterCollectorSV.showMountName then
                    assaultText = assaultText .. "    Mounts for " .. playerFaction .. ": " .. mountNamesString .. "\n"
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
        
        local playerRegion = GetCurrentRegion()
        local baseTime = playerRegion == 1 and 1727794800 or (playerRegion == 3 and 1727838000)
        local fullRotationInterval = 1296000 -- 15 days in seconds
        local huntDuration = 302400 -- 3 days and 12 hours in seconds
        local currentTime = GetServerTime()
        local elapsedTimeInRotation = (currentTime - baseTime) % fullRotationInterval
        local currentHuntIndex = (math.floor(elapsedTimeInRotation / huntDuration) % #huntNames) + 1
        local elapsedTimeInHunt = elapsedTimeInRotation % huntDuration
        local timeRemainingInHunt = huntDuration - elapsedTimeInHunt
        
        local function FormatTime(seconds)
            local days = math.floor(seconds / 86400)
            local hours = math.floor((seconds % 86400) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
        
            if days > 0 then
                return string.format("%d Days %02d Hrs %02d Min", days, hours, minutes)
            else
                return string.format("%02d Hrs %02d Min", hours, minutes)
            end
        end
        
        local shadehoundsMountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1304)
        local achieveMountName = C_MountJournal.GetMountInfoByID(1504)
        local _, achieveName, _, achieved = GetAchievementInfo(14738)
        local dropChanceDenominator = 50
        local attempts = GetRarityAttempts("Mawsworn Soulhunter") or 0
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
                huntText = MC.goldHex .. "Current Maw Beastwarrens Hunt: |r" .. huntNames[currentHuntIndex] .. "\n" .. "     (" .. FormatTime(timeRemainingInHunt) .. " left)\n"
                
                if MasterCollectorSV.showMountName then
                    if not achieved then
                        huntText = huntText .. "\n    " .. MC.goldHex .. achieveName .. " yet to be Completed for Breaking the Chains Meta Achievement|r\n    Mount: " .. achieveMountName .. "\n"
                    else
                        huntText = huntText .. "\n    " .. MC.goldHex .. achieveName .. " for Breaking the Chains Meta Achievement |r\n    Mount: " .. achieveMountName .. "\n"
                    end

                    if huntNames[currentHuntIndex] == "Shadehounds" and (not MasterCollectorSV.hideBossesWithMountsObtained or not collected) then
                        huntText = huntText .. "    " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
                    end
                end
            end

            local nextHuntIndex = (currentHuntIndex % #huntNames) + 1
            huntText = huntText .. "\n" .. MC.goldHex .. "Next Maw Beastwarrens Hunt: |r" .. huntNames[nextHuntIndex] .. "\n"
            if MasterCollectorSV.showMountName then
                if huntNames[nextHuntIndex] == "Shadehounds" and not MasterCollectorSV.hideBossesWithMountsObtained then
                    huntText = huntText .. "     Mount: " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
                elseif huntNames[nextHuntIndex] == "Shadehounds" and not collected then
                    huntText = huntText .. "     Mount: " .. shadehoundsMountName .. rarityAttemptsText .. dropChanceText .. "\n"
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
            [6989] = 1477,
            [6990] = 1378,
            [6992] = 1476
        }

        local mountItems = {
            [1477] = "Undying Darkhound's Harness",
            [1378] = "Harvester's Dredwing Saddle",
            [1476] = "Legsplitter War Harness"
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
    
        local function FormatTime(seconds)
            local days = math.floor(seconds / 86400)
            local hours = math.floor((seconds % 86400) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
    
            if days > 0 then
                return string.format("%d Days %02d Hrs %02d Min", days, hours, minutes)
            else
                return string.format("%02d Hrs %02d Min", hours, minutes)
            end
        end
    
        local questCompleted = C_QuestLog.IsQuestFlaggedCompleted(64106)

        if MasterCollectorSV.showMawAssaultTimer then
            if not currentAssaultID then
                if not questCompleted then
                    return MC.goldHex .. "Current Maw Assault: |r\n" .. 
                        "    Please complete Chapter 2 of the Chains of Domination questline, Maw Walkers.\n"
                else
                    return MC.goldHex .. "Fetching Maw Assault Status... Standby |r\n"
                end
            end

            local assaultName = assaultIDs[currentAssaultID]
            local dropChanceDenominator = 25
            local rarityAttemptsText = ""
            local dropChanceText = ""

            for _, mountID in pairs(mountIDs) do
                local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                local assaultDisplay = MC.goldHex .. "Current Maw Assault: |r" .. assaultName .. "\n" .. "    (" .. FormatTime(currentAssaultSecondsLeft) .. " left)\n"
                local attempts = GetRarityAttempts(mountID) or 0

                if MasterCollectorSV.showRarityDetail then
                    local chance = 1 / dropChanceDenominator
                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                    rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                end

                if MasterCollectorSV.showMountName then
                    assaultDisplay = assaultDisplay .. "    Mount: |r" .. mountName .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n"
                    if not achieved then
                        assaultDisplay = assaultDisplay .. "\n    " .. MC.goldHex .. achieveName .. " yet to be Completed for Breaking the Chains Meta Achievement|r\n     Mount: " .. achieve1MountName .. "\n"
                        assaultDisplay = assaultDisplay .. "\n    " .. MC.goldHex .. achieveName .. " yet to be Completed for Back from the Beyond Meta Achievement|r\n     Mount: " .. achieve2MountName .. "\n"
                    elseif achieved then
                        assaultDisplay = assaultDisplay .. "\n    " .. MC.goldHex .. achieveName .. " for Breaking the Chains Meta Achievement|r\n     Mount: " .. achieve1MountName .. "\n"
                        assaultDisplay = assaultDisplay .. "\n    " .. MC.goldHex .. achieveName .. " for Back from the Beyond Meta Achievement|r\n     Mount: " .. achieve2MountName .. "\n"
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
        local playerRegion = GetCurrentRegion()
        local baseTime = playerRegion == 1 and 1728255660 or (playerRegion == 3 and 1728255660) -- Replace with EU base time when known
        local eventInterval = 10800 -- 3 hours in seconds
        local currentTime = GetServerTime()
        local elapsedTimeInRotation = (currentTime - baseTime) % eventInterval
        local timeUntilNextEvent = eventInterval - elapsedTimeInRotation
        local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(1238)
        local _, achieveName = GetAchievementInfo(13638)

        local function FormatTime(seconds)
            local hours = math.floor(seconds / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
            return string.format("%02d Hrs %02d Min", hours, minutes)
        end

        if MasterCollectorSV.showSummonDepthsTimer then
            local eventText = MC.goldHex .. "Next Summon from the Depths: |r" .. FormatTime(timeUntilNextEvent) .. "\n"

            if MasterCollectorSV.showMountName then
                eventText = eventText .. string.format("    %s Achievement Mount: %s\n", achieveName, mountName or "Unknown Mount")
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and not collected then
                return eventText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return eventText
            end
        end
    end

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
    
    local function GetTormentorsOfTorghastStatus()
        local playerRegion = GetCurrentRegion()
        local baseTimeNA = 1728263160 -- NA Base time for index 4
        local baseTimeEU = 1729908000 -- EU Base time for index 13
        local baseTime, rotationIndex
    
        -- Determine base time and rotation index based on the region
        if playerRegion == 1 then
            baseTime = baseTimeNA
            rotationIndex = 4  -- Index of "The Mass of Souls" for NA
        else
            baseTime = baseTimeEU
            rotationIndex = 13  -- Index of "Sentinel Shakorzeth" for EU
        end

        local eventInterval = 7200
        local currentTime = GetServerTime()
        local elapsedTime = (currentTime - baseTime)
        local rotationSize = #tormentorRotation
        local currentRotationIndex = ((rotationIndex - 1 + math.floor(elapsedTime / eventInterval)) % rotationSize) + 1

        if elapsedTime < eventInterval then
            currentRotationIndex = ((currentRotationIndex - 1) % rotationSize) + 1
        end
        
        local elapsedTimeInRotation = elapsedTime % eventInterval
        local timeUntilNextSpawn = eventInterval - elapsedTimeInRotation

        local function FormatTime(seconds)
            local days = math.floor(seconds / 86400)
            local hours = math.floor((seconds % 86400) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)
    
            if days > 0 then
                return string.format("%d Days %02d Hrs %02d Min", days, hours, minutes)
            else
                return string.format("%02d Hrs %02d Min", hours, minutes)
            end
        end

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

                if MasterCollectorSV.showRarityDetail then
                    local chance = 1 / dropChanceDenominator
                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                    rarityAttemptsText = string.format("     (Attempts: %d/%s", attempts, dropChanceDenominator)
                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                end

                if MasterCollectorSV.showMountName then
                    if mountID == 1475 then
                        if not questCompleted then
                            eventText = "    Tormentor's Cache Weekly to do! \n" .. mountText .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n\n"
                        else
                            eventText = "    " .. mountText .. "\n" .. rarityAttemptsText .. dropChanceText .. "\n\n"
                        end
                    end
                    
                    if mountID == 1504 then
                        if not achieved then
                            eventText = eventText .. "    " .. MC.goldHex .. achieveName .. " yet to be Completed for Breaking the Chains Meta Achievement|r\n" .. mountText .. "\n\n" 
                        else
                            eventText = eventText .. "    " .. MC.goldHex .. achieveName .. " for Breaking the Chains Meta Achievement|r\n" .. mountText .. "\n\n"
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

    local warfrontIDs = { 
        { id = 11, name = "Battle for Stromgarde (Arathi Highlands)", faction = "Horde" },
        { id = 116, name = "Battle for Stromgarde (Arathi Highlands)", faction = "Alliance" },
        { id = 117, name = "Battle for Darkshore", faction = "Alliance" },
        { id = 118, name = "Battle for Darkshore", faction = "Horde" }
    }

    local function GetActiveWarfrontStatus()
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
                local timeRemaining = timeOfNextStateChange and (timeOfNextStateChange - GetServerTime()) or nil
                local timeRemainingText = timeRemaining and SecondsToTime(math.max(timeRemaining, 0)) or "Awaiting Resources"
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

        local factionMounts = {
            ["Alliance"] = {1204, 1214, 1216},
            ["Horde"] = {1204, 1210, 1215},
        }

        local allCollected = true
        local function getMountNamesByFaction(faction)
            local mountNames = {}
            local uncollectedMounts = {}
            local mountIDs = factionMounts[faction] or {}

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

        for warfrontName, warfrontText in pairs(activeWarfronts) do
            if (warfrontName == "Battle for Stromgarde (Arathi Highlands)" and MasterCollectorSV.showArathiWFTimer) or (warfrontName == "Battle for Darkshore" and MasterCollectorSV.showDarkshoreWFTimer) then

                local mountNamesString = getMountNamesByFaction(playerFaction)

                if warfrontText then
                    if MasterCollectorSV.showMountName then
                        table.insert(output, warfrontText .. "    Mounts for " .. playerFaction .. ": " .. mountNamesString .. "\n")
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

    local function isDunegorgerAvailable(bossID)
        local serverTime = GetServerTime()
        local nextReset = date("%d-%m-%Y %H:%M", serverTime + GetQuestResetTime())
        local resetHour = tonumber(string.sub(nextReset, 12, 13))
        local resetMinute = tonumber(string.sub(nextReset, 15, 16))
        local startDate = { year = 2024, month = 7, day = 23, hour = resetHour, minute = resetMinute }

        -- Check if server time is a day ahead for NA-OCE players
        local dayAhead = false
        if resetHour < 7 then
            dayAhead = true
        end

        local function getWeekNumberSince(startTime)
            local currentServerTime = GetServerTime() -- Get server time as Unix timestamp
            local secondsInWeek = 7 * 24 * 60 * 60

            -- Set start time 1 day ahead if on NA-OCE
            if dayAhead then
                startTime = startTime + 86400
            end

            return math.floor((currentServerTime - startTime) / secondsInWeek)
        end

        local function isDunegorgerKraulokUp()
            local startTime = time(startDate)
            local weeksSinceStart = getWeekNumberSince(startTime)
            local rotationPeriod = 6 -- Dunegorger Kraulok's rotation period in weeks

            return weeksSinceStart % rotationPeriod == 0
        end

        return isDunegorgerKraulokUp()
    end

    local function EventsActive()
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
        local activeEvents = {}
        local output = ""

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
                                if not activeEvents[eventInfo[1]] then
                                    activeEvents[eventInfo[1]] = true

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
                                                    rarityAttemptsText = string.format("\n    (Attempts: %d/%s", attempts, dropChanceDenominator)
                                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                                end
                                            end

                                            if MasterCollectorSV.showMountName then
                                                table.insert(mountsToShow, mountName .. rarityAttemptsText .. dropChanceText)
                                            end
                                        end
                                    end

                                    if #mountsToShow > 0 then
                                        output = output .. MC.goldHex .. eventName ..  " is active!|r\n    Mounts:\n"
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
    end

    local displayText = EventsActive() or ""
    local hasNonNilStatus = (displayText ~= "")

    local function appendIfNotNil(statusFunction)
        local status = statusFunction()
        if status and status ~= "" then
            displayText = displayText .. "\n" .. status
            hasNonNilStatus = true
        end
    end

    local statusFunctions = {
        CheckWorldQuests,
        GetLegionInvasionStatus,
        GetActiveWarfrontStatus,
        GetFactionAssaultStatus,
        GetSummonFromTheDepthsStatus,
        GetCovenantAssaultStatus,
        GetBeastwarrensHuntStatus,
        GetTormentorsOfTorghastStatus
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