function MC.grinds()
    if MC.currentTab ~= "Anytime\nGrinds" then
        return
    end

    MC.InitializeColors()

    local grindsText = ""
    local fontSize = MasterCollectorSV.fontSize

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont(font, fontSize, flags)
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

    local dungeons = {
        [1292] = {                                                           -- Stratholme: Service Entrance
            { 456, { 69 }, 1, "Deathcharger's Reins", 100 }                  -- Lord Rivendare (Normal)
        },
        [744] = {                                                            -- Temple of Ahn'Qiraj
            { nil, { 117 }, 9, "Blue Qiraji Resonating Crystal",   10 },     -- Adds before first Boss (Normal)
            { nil, { 118 }, 9, "Red Qiraji Resonating Crystal",    100 },    -- Adds before first Boss (Normal)
            { nil, { 119 }, 9, "Green Qiraji Resonating Crystal",  10 },     -- Adds before first Boss (Normal)
            { nil, { 120 }, 9, "Yellow Qiraji Resonating Crystal", 10 }      -- Adds before first Boss (Normal)
        },
        [68] = {                                                             -- Vortex Pinnacle
            { 115, { 395 }, 1, "Reins of the Drake of the North Wind", 100 } -- Altarius (Normal)
        },
        [67] = {                                                             -- The Stonecore
            { 111, { 393 }, 1, "Reins of the Vitreous Stone Drake", 100 }    -- Slabhide (Normal)
        }
    }

    local fishingMounts = {
        { 125,  "Sea Turtle",                         200 }, -- Sea Turtle
        { 312,  "Riding Turtle",                      200 }, -- Riding Turtle
        { 488,  "Reins of the Crimson Water Strider", 100 }, -- Crimson Water Strider
        { 982,  "Pond Nettle",                        2000 }, -- Pond Nettle
        { 1166, "Great Sea Ray",                      10000 } -- BfA Great Sea Ray
    }

    local islandMounts = {
        { 1175, 100 }, -- Twilight Avenger
        { 1175, 100 }, -- Craghorn Chasm-Leaper
        { 1175, 100 }, -- Qinsho''s Eternal Hound
        { 1175, 100 }, -- Squawks
        { 1175, 100 }, -- Surf Jelly
        { 1175, 100 }, -- Risen Mare
        { 1175, 100 }, -- Island Thunderscale
        { 1175, 100 }, -- Bloodgorged Hunter
        { 1175, 100 }, -- Stonehide Elderhorn
    }

    MasterCollectorSV.Islands = MasterCollectorSV.Islands or { activeIslands = {}, resetTime = 0 }

    local lastRequestTime = 0
    local requestDelay = 60

    local lastWarningTime = 0
    function MC.CheckInstanceLimit()
        local liveLocks = #MasterCollectorSV.instanceLocks

        if liveLocks >= 9 then
            local now = time()
            if now - lastWarningTime > 60 then
                print(string.format(
                    "|cffffff00Warning:|r You've entered %d instances recently. You are nearing the 10-instance per hour limit.",
                    liveLocks
                ))
                lastWarningTime = now
            end
        end
    end

    function MC.UpdateSavedInstances()
        local currentTime = time()

        local function InstanceExists(instanceLocks, instanceName, character, difficulty)
            for _, lock in ipairs(instanceLocks) do
                if lock.name == instanceName and lock.character == character then
                    if (lock.difficulty == difficulty) or (difficulty == nil or difficulty == "") then
                        return true
                    end
                end
            end
            return false
        end

        local function CleanExpiredInstances(instanceLocks)
            for i = #instanceLocks, 1, -1 do
                if instanceLocks[i].reset <= currentTime then
                    table.remove(instanceLocks, i)
                end
            end
        end

        MasterCollectorSV.instanceLocks = MasterCollectorSV.instanceLocks or {}
        MasterCollectorSV.realmLocks = MasterCollectorSV.realmLocks or {}

        local playerName, playerRealm = UnitName("player"), GetRealmName()
        local uniqueCharacterID = playerName .. "-" .. playerRealm

        MasterCollectorSV.realmLocks[playerRealm] = MasterCollectorSV.realmLocks[playerRealm]

        if MasterCollectorSV.instanceLocks then
            CleanExpiredInstances(MasterCollectorSV.instanceLocks)
        end

        if MasterCollectorSV.realmLocks[playerRealm] then
            CleanExpiredInstances(MasterCollectorSV.realmLocks[playerRealm])
        end

        if currentTime - lastRequestTime >= requestDelay then
            RequestRaidInfo()
            RequestLFDPlayerLockInfo()
            lastRequestTime = currentTime
        end

        local updatedCharacterLocks = {}
        local updatedRealmLocks = {}

        local function UpdateInstanceLocks(lockList, storage, lockType, name, resetTime, difficulty, character)
            table.insert(lockList, { name = name, reset = resetTime, difficulty = difficulty, character = character })
        end

        for i = 1, GetNumSavedInstances() do
            local name, _, reset, difficultyId, locked, _, _, isRaid = GetSavedInstanceInfo(i)
            if name and locked and reset then
                if isRaid then
                    local difficultyName = GetDifficultyInfo(difficultyId)
                    UpdateInstanceLocks(updatedCharacterLocks, MasterCollectorSV.instanceLocks, "character", name, currentTime + reset, difficultyName, uniqueCharacterID)
                elseif not isRaid and reset < 86400 then
                    local difficultyName = GetDifficultyInfo(difficultyId)
                    UpdateInstanceLocks(updatedCharacterLocks, MasterCollectorSV.instanceLocks, "character", name, currentTime + reset, difficultyName, uniqueCharacterID)
                end
            end
        end

        local instanceName, instanceType, difficultyID, difficultyName = GetInstanceInfo()
        if instanceName and instanceType and instanceName ~= "" then
            local resetTime = currentTime + 3600
            if instanceType == "party" then
                UpdateInstanceLocks(updatedRealmLocks, MasterCollectorSV.realmLocks[playerRealm], "realm", instanceName, resetTime, difficultyName, uniqueCharacterID)
            elseif instanceType == "raid" then
                if difficultyName and difficultyName ~= "" then
                    UpdateInstanceLocks(updatedRealmLocks, MasterCollectorSV.realmLocks[playerRealm], "realm", instanceName, resetTime, difficultyName, uniqueCharacterID)
                end
                if resetTime > currentTime + 3600 then
                    UpdateInstanceLocks(updatedCharacterLocks, MasterCollectorSV.instanceLocks, "character", instanceName, resetTime, difficultyName)
                end
            end
        end

        for _, lock in ipairs(MasterCollectorSV.instanceLocks) do
            if lock.reset > currentTime and not InstanceExists(updatedCharacterLocks, lock.name, lock.character, lock.difficulty) then
                table.insert(updatedCharacterLocks, lock)
            end
        end

        for _, lock in ipairs(MasterCollectorSV.realmLocks[playerRealm] or {}) do
            if lock.reset > currentTime and not InstanceExists(updatedRealmLocks, lock.name, lock.character, lock.difficulty) then
                table.insert(updatedRealmLocks, lock)
            end
        end

        MasterCollectorSV.instanceLocks[uniqueCharacterID] = updatedCharacterLocks
        MasterCollectorSV.realmLocks[playerRealm] = updatedRealmLocks

        local instanceTextList = {}

        local function FormatTime(seconds)
            local days = math.floor(seconds / 86400) or 0 or nil
            local hours = math.floor((seconds % 86400) / 3600)
            local minutes = math.floor((seconds % 3600) / 60)

            if days == 0 and hours == 0 then
                return string.format("%02d Min", minutes)
            elseif days == 0 then
                return string.format("%02d Hrs %02d Min", hours, minutes)
            else
                return string.format("%d Days %02d Hrs %02d Min", days, hours, minutes)
            end
        end

        local function AddLockoutsToText(lockList, lockType)
            local lockCount = #lockList
            if lockCount > 0 then
                local minResetTime = lockList[1].reset
        
                for _, lock in ipairs(lockList) do
                    if lock.reset < minResetTime then
                        minResetTime = lock.reset
                    end
                end
                if lockType == "Realm"  then
                    table.insert(instanceTextList, string.format("%sRealm Lockouts:|r %d / %d (Less in %s)", MC.goldHex, lockCount, 10, FormatTime(minResetTime - currentTime)))
                    for _, lock in ipairs(lockList) do
                        table.insert(instanceTextList, string.format("    %s %s  (%s)", lock.name, lock.difficulty, lock.character))
                    end
                else
                    table.insert(instanceTextList, string.format("%s\nCharacter Lockouts:|r %d", MC.goldHex, lockCount))
                    for _, lock in ipairs(lockList) do
                        table.insert(instanceTextList, string.format("    %s %s (Reset in %s)", lock.name, lock.difficulty, FormatTime(lock.reset - currentTime)))
                    end
                end
            else
                if lockType == "Realm" then
                    table.insert(instanceTextList, string.format("%sRealm Lockouts:|r  No active lockouts.", MC.goldHex))
                else
                    table.insert(instanceTextList, string.format("%s\nCharacter Lockouts:|r  No active lockouts.", MC.goldHex))
                end
            end
        end

        AddLockoutsToText(updatedRealmLocks, "Realm")
        AddLockoutsToText(updatedCharacterLocks, "Character")
        MC.latestInstanceOutput = table.concat(instanceTextList, "\n")
        MC.CheckInstanceLimit()
    end

    local function GetNextWeeklyReset()
        local region = GetCVar("portal")               -- "US", "EU", etc.
        local resetDay = (region == "US") and 2 or 3   -- Tuesday for US, Wednesday for EU
        local resetHour = (region == "US") and 15 or 7 -- 15:00 UTC for US, 7:00 UTC for EU

        local realmTime = GetServerTime()
        local date = C_DateAndTime.GetCurrentCalendarTime()

        local weekStart = realmTime - ((date.weekday - 1) * 86400) - date.hour * 3600 - date.minute * 60
        local resetTime = weekStart + (resetDay - 1) * 86400 + resetHour * 3600

        if resetTime < realmTime then
            resetTime = resetTime + 7 * 86400 -- Add a week if we've passed this week's reset
        end

        return resetTime
    end

    function MC.ResetActiveIslands()
        MasterCollectorSV.Islands.activeIslands = {}
        MasterCollectorSV.Islands.resetTime = GetNextWeeklyReset()
        print("Island rotation has reset. Starting a new cycle of expeditions!")
    end

    function MC.UpdateActiveIslands()
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then
            return nil
        end
        
        local islandMapIDs = {
            [1036] = "The Dread Chain",
            [1035] = "Molten Cay",
            [1032] = "Skittering Hollow",
            [981] = "Un'gol Ruins",
            [1037] = "Whispering Reef",
            [1034] = "Verdant Wilds",
            [1033] = "Rotting Mire",
            [1502] = "Snowblossom Village",
            [1501] = "Crestfall",
            [1336] = "Havenswood",
            [1337] = "Jorundall"
        }

        if GetServerTime() >= MasterCollectorSV.Islands.resetTime then
            MC.ResetActiveIslands()
        end

        if islandMapIDs[mapID] then
            local islandName = islandMapIDs[mapID]
            if not MasterCollectorSV.Islands.activeIslands[islandName] then
                MasterCollectorSV.Islands.activeIslands[islandName] = true
                print("Added to Active Island Expeditions This Week: " .. islandName .. "\n")
                MC.GrindsUpdate()
            end
        end
    end

    local function GetActiveIslands()
        local output = MC.goldHex .. "Island Expeditions|r\n"
        local activeIslands = MasterCollectorSV.Islands.activeIslands
        local islandList = {}

        if next(activeIslands) then
            for islandName, _ in pairs(activeIslands) do
                table.insert(islandList, "    " .. islandName)
            end
            output = output .. table.concat(islandList, "\n")
        else
            output = output .. "    Visit each island this week to update the list.\n"
        end

        return output
    end

    local function displayDungeons()
        local lockoutText = MC.goldHex .. "Normal Instances|r"
        local whiteColor = "|cffffffff"
        local lockoutsAdded = false

        for dungeonID, bosses in pairs(dungeons) do
            local dungeonName = EJ_GetInstanceInfo(dungeonID)
            local dungeonText = ""

            for _, bossData in ipairs(bosses) do
                local bossID, mountIDs, difficultyID, itemName, dropChanceDenominator = unpack(bossData)

                local allMountsCollected = true
                if MasterCollectorSV.hideBossesWithMountsObtained and mountIDs then
                    for _, mountID in ipairs(mountIDs) do
                        local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                        if not isCollected then
                            allMountsCollected = false
                            break
                        end
                    end
                else
                    allMountsCollected = false
                end

                if not allMountsCollected then
                    local isDefeated = false
                    local difficultyName = GetDifficultyInfo(difficultyID)
                    local bossName = ""

                    if bossID ~= nil then
                        bossName = EJ_GetEncounterInfo(bossID)
                    else
                        bossName = "Mobs before first boss"
                    end

                    for i = 1, GetNumSavedInstances() do
                        local _, _, _, savedDifficulty, locked = GetSavedInstanceInfo(i)
                        if locked and tonumber(difficultyID) == tonumber(savedDifficulty) then
                            for j = 1, 20 do
                                local encounterName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                                if encounterName == bossName then
                                    isDefeated = isKilled
                                    break
                                end
                            end
                        end
                        if isDefeated then break end
                    end

                    if not (MasterCollectorSV.showBossesWithNoLockout and isDefeated) then
                        local bossColor = isDefeated and MC.greenHex or MC.redHex
                        local difficultiesText = string.format("%s(%s)|r", bossColor, difficultyName)

                        dungeonText = dungeonText .. string.format("    - %s%s|r %s\n", bossColor, bossName, difficultiesText)

                        if mountIDs then
                            for _, mountID in ipairs(mountIDs) do
                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                local rarityAttemptsText, dropChanceText = "", ""

                                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                    if MasterCollectorSV.showRarityDetail and itemName then
                                        local attempts = GetRarityAttempts(itemName) or 0

                                        if dropChanceDenominator and dropChanceDenominator ~= 0 then
                                            local chance = 1 / dropChanceDenominator
                                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts,
                                                dropChanceDenominator)
                                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                        end
                                    end
                                end
                                if MasterCollectorSV.showMountName then
                                    dungeonText = dungeonText ..
                                        string.format("      - %sMount: %s%s%s|r\n", whiteColor, mountName,
                                            rarityAttemptsText, dropChanceText)
                                end
                            end
                        end
                    end
                end
            end
            if dungeonText ~= "" then
                lockoutsAdded = true
                lockoutText = lockoutText .. "\n    " .. MC.goldHex .. dungeonName .. "|r:\n" .. dungeonText
            end
        end
        if lockoutsAdded then
            return lockoutText
        end
    end

    local function displayFishing()
        local output = MC.goldHex .. "Fishing Mounts|r\n"
        local outputModified = false

        for _, mountData in ipairs(fishingMounts) do
            local mountID, itemName, dropChanceDenominator = unpack(mountData)
            local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            local rarityAttemptsText = ""
            local dropChanceText = ""

            if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                    local chance = 1 / dropChanceDenominator
                    local attempts = GetRarityAttempts(itemName) or 0
                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                    rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                end
            end

            if not (isCollected and MasterCollectorSV.hideBossesWithMountsObtained) then
                if MasterCollectorSV.showMountName then
                    outputModified = true
                    output = output ..
                    string.format("    Mount: %s %s%s\n", mountName, rarityAttemptsText, dropChanceText)
                end
            end
        end
        if outputModified then
            return output
        end
    end

    function MC.ProcessActivities()
        local grindsText = grindsText
        local activities = {MC.UpdateSavedInstances, displayDungeons, displayFishing, GetActiveIslands}

        for _, activity in ipairs(activities) do
            activity()
            if activity == MC.UpdateSavedInstances then
                if MC.latestInstanceOutput and MC.latestInstanceOutput ~= "" then
                    grindsText = grindsText .. "\n" .. MC.latestInstanceOutput .. "\n"
                end
            else
                local result = activity()
                if result ~= nil then
                    grindsText = grindsText .. "\n" .. result
                end
            end
        end
        return grindsText
    end

    function MC.UpdateGrindsMainFrameText()
        if MC.mainFrame and MC.mainFrame.text then
            MC.mainFrame.text:SetText(MC.ProcessActivities())
        end
    end
    MC.UpdateGrindsMainFrameText()
end