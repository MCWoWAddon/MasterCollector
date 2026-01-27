function MC.weeklyDisplay()
    local displayText = ""
    local fontSize = MasterCollectorSV.fontSize

    if MC.currentTab ~= "Weekly\nLockouts" then
        return
    end

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont("P", font, fontSize, flags)
    end

    local aura_env = {
        dungeonData = {
            ["Dungeon Mounts"] = {
                ["The War Within Mythic Dungeons"] = {
                    [1210] = {                                     -- Darkflame Cleft
                        { 2561, { 2204 }, { 23 }, "Wick's Lead", 100 } -- The Darkness (Mythic)
                    },
                },
                ["Dragonflight Mythic Dungeons"] = {
                    [1209] = {                                                                                                                   -- Dawn of the Infinite
                        { 2538, { 781, 264, 411, 395, 995, 397, 875, 1040, 1406, 410, 1252, 1481, 1053, 185, 69 }, { 23 }, "Reins of the Quantum Courser" } -- Chrono-Lord Deios (Mythic)
                    }
                },
                ["Shadowlands Mythic Dungeons"] = {
                    [1194] = {                                             -- Tazavesh, the Veiled Market
                        { 2455, { 1481 }, { 23 }, "Cartel Master's Gearglider", 50 } -- So'leah (Mythic)
                    },
                     [1182] = {                                            -- The Necrotic Wake
                        { 2396, { 1406 }, { 23 }, "Marrowfang's Reins", 100 } -- Nalthor the Rimebinder (Mythic)
                    }
                },
                ["Battle for Azeroth Mythic Dungeons"] = {
                    [1001] = {                                               -- Freehold
                        { 2095, { 995 }, { 23 }, "Sharkbait's Favorite Crackers", 200 } -- Harlan Sweete (Mythic)
                    },
                    [1041] = {                                               -- Kings' Rest
                        { 2172, { 1040 }, { 23 }, "Mummified Raptor Skull", 200 } -- Dazar, The First King (Mythic)
                    },
                    [1022] = {                                               -- The Underrot
                        { 2158, { 1053 }, { 23 }, "Underrot Crawg Harness", 200 } -- Unbound Abomination (Mythic)
                    },
                    [1178] = {                                               -- Operation: Mechagon
                        { 2355, { 1252 }, { 23 }, "Mechagon Peacekeeper", 200 } -- HK-8 Aerial Oppression Unit (Mythic)
                    }
                },
                ["Legion Mythic Dungeons"] = {
                    [860] = {                                            -- Return to Karazhan
                        { 1835, { 875 }, { 23 }, "Midnight's Eternal Reins", 100 }, -- Attumen the Huntsman (Mythic)
                        { nil,  { 883 }, { 23 }, "Smoldering Ember Wyrm", 5 }, -- Smoldering Ember Wyrm (Mythic)
                    }
                }

            },
            ["Raid Mounts"] = {
                ["The War Within Raids"] = {
                    [1296] = {                                                        -- Liberation of Undermine
                        { 2646, { 2507 }, { 17, 14, 15, 16 }, "Prototype A.S.M.R.", 100 } -- Chrome King Gallywix (LFR, Normal, Heroic, Mythic)
                        -- { 2646, { 2487 }, { 16 }, "The Big G", 100 } -- Chrome King Gallywix (Mythic)
                        },
                    [1273] = {                                                        -- Nerub'ar Palace
                        { 2602, { 2219 }, { 17, 14, 15, 16 }, "Reins of the Sureki Skyrazor", 100 } -- Queen Ansurek (LFR, Normal, Heroic, Mythic)
                        -- { 2602, { 2223 }, { 16 }, "Reins of the Ascended Skyrazor", 100 } -- Queen Ansurek (Mythic)
                        }
                    },
                ["Dragonflight Raids"] = {
                    [1207] = {                                                        -- Amirdrassil
                        { 2519, { 1818 }, { 16 }, "Reins of Anu'relos, Flame's Guidance.", 100 } -- Fyrakk (Mythic)
                    },
                    [1200] = {                                                        -- Vault of the Incarnates
                        { 2500, { 1546 }, { 14, 15, 16 }, "Terros's Captive Core",     4 }, -- Terros (LFR - to be added later, Normal, Heroic, Mythic)
                        { 2502, { 1546 }, { 14, 15, 16 }, "Eye of the Vengeful Hurricane", 4 }, -- Dathea, Ascended (LFR - to be added later Normal, Heroic, Mythic)
                    }
                },
                ["Shadowlands Raids"] = {
                    [1193] = {                                                            -- Sanctum of Domination
                        { 2439, { 1500 }, { 17, 14, 15, 16 }, "Sanctum Gloomcharger's Reins", 100 }, -- The Nine (LFR, Normal, Heroic, Mythic)
                        { 2441, { 1471 }, { 16 },         "Vengeance's Reins",            100 } -- Sylvanas Windrunner (Mythic)
                    },
                    [1195] = {                                                            -- Sepulcher of the First Ones
                        { 2464, { 1587 }, { 16 }, "Fractal Cypher of the Zereth Overseer", 100 } -- The Jailer (Mythic)
                    }
                },
                ["Battle for Azeroth Raids"] = {
                    [1176] = {                                    -- Battle of Dazar'alor
                        { 2334, { 1217 }, { 14, 15, 16 }, "G.M.O.D.",      100 }, -- Mekkatorque (Normal, Heroic, Mythic)
                        { 2343, { 1217 }, { 17 },     "G.M.O.D.",          100 }, -- Lady Jaina Proudmoore (LFR)
                        { 2343, { 1219 }, { 16 },     "Glacial Tidestorm", 100 } -- Lady Jaina Proudmoore (Mythic)
                    },
                    [1180] = {                                    -- Ny'alotha, the Waking City
                        { 2375, { 1293 }, { 16 }, "Ny'alotha Allseer", 100 } -- N'Zoth the Corruptor (Mythic)
                    }
                },
                ["Legion Raids"] = {
                    [875] = {                                                 -- Tomb of Sargeras
                        { 1861, { 899 }, { 17, 14, 15, 16 }, "Abyss Worm", 100 } -- Mistress Sassz'ine (LFR, Normal, Heroic, Mythic)
                    },
                    [946] = {                                                 -- Antorus, the Burning Throne
                        { 1987, { 971 }, { 17, 14, 15, 16 }, "Antoran Charhound", 100 }, -- Felhounds of Sargeras (LFR, Normal, Heroic, Mythic)
                        { 2031, { 954 }, { 16 },         "Shackled Ur'zul",   100 } -- Argus the Unmaker (Mythic)
                    },
                    [786] = {                                                 -- The Nighthold
                        { 1737, { 791 }, { 14, 15, 16 }, "Living Infernal Core", 100 }, -- Gul'dan (Normal, Heroic, Mythic)
                        { 1737, { 633 }, { 16 },     "Fiendish Hellfire Core", 100 } -- Gul'dan (Mythic)
                    }
                },
                ["Warlords of Draenor Raids"] = {
                    [669] = {                                       -- Hellfire Citadel
                        { 1438, { 751 }, { 16 }, "Felsteel Annihilator", 100 } -- Archimonde (Mythic)
                    },
                    [457] = {                                       -- Blackrock Foundry
                        { 959, { 613 }, { 16 }, "Ironhoof Destroyer", 100 } -- Blackhand (Mythic)
                    }
                },
                ["Mists of Pandaria Raids"] = {
                    [369] = {                                                           -- Siege of Orgrimmar
                        { 869, { 559 }, { 16 }, "Kor'kron Juggernaut", 100 }            -- Garrosh Hellscream (Mythic)
                    },
                    [362] = {                                                           -- Throne of Thunder
                        { 819, { 531 }, { 3, 5, 4, 6 }, "Spawn of Horridon", 66 },      -- Horridon (10P, 25P, 10P (H), 25P (H))
                        { 828, { 543 }, { 3, 5, 4, 6 }, "Clutch of Ji-Kun", 50 }        -- Ji-Kun (10P, 25P, 10P (H), 25P (H))
                    },
                    [317] = {                                                           -- Mogu'shan Vaults
                        { 726, { 478 }, { 3, 5, 4, 6 }, "Reins of the Astral Cloud Serpent", 100 } -- Elegon (10P, 25P, 10P (H), 25P (H))
                    }
                },
                ["Cataclysm Raids"] = {
                    [78] = {                                                               -- Firelands
                        { 194, { 425 }, { 14, 15 }, "Flametalon of Alysrazor",  100 },     -- Alysrazor (Normal, Heroic)
                        { 198, { 415 }, { 14, 15 }, "Smoldering Egg of Millagazor", 100 }  -- Ragnaros (Normal, Heroic)
                    },
                    [74] = {                                                               -- Throne of the Four Winds
                        { 155, { 396 }, { 3, 4, 5, 6 }, "Reins of the Drake of the South Wind", 100 } -- Al'Akir (10P, 25P, 10P (H), 25P (H))
                    },
                    [187] = {                                                              -- Dragon Soul
                        { 331, { 445 }, { 3, 4, 5, 6 }, "Experiment 12-B",        100 },   -- Ultraxion (10P, 25P, 10P (H), 25P (H))
                        { 333, { 442 }, { 3, 4, 5, 6 }, "Reins of the Blazing Drake", 100 }, -- Madness of Deathwing (10P, 25P, 10P (H), 25P (H))
                        { 333, { 444 }, { 5, 6 },   "Life-Binder's Handmaiden",   100 }    -- Madness of Deathwing (10P (H), 25P (H))
                    }
                },
                ["Wrath of the Lich King Raids"] = {
                    [758] = {                                                                                    -- Icecrown Citadel
                        { 1636, { 363 }, { 6 }, "Invincible's Reins", 100 }                                      -- The Lich King (25P (H))
                    },
                    [759] = {                                                                                    -- Ulduar
                        { 1649, { 304 }, { 14 }, "Mimiron's Head", 100 }                                         -- Yogg-Saron (N)
                    },
                    [753] = {                                                                                    -- Vault of Archavon
                        { 1597, { 287 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Horde", 100, "Horde Only" }, -- Archavon the Stone Watcher (10P, 25P)
                        { 1597, { 286 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Alliance", 100, "Alliance Only" }, -- Archavon the Stone Watcher (10P, 25P)
                        { 1598, { 287 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Horde", 100 }, "Horde Only", -- Emalon the Storm Watcher (10P, 25P)
                        { 1598, { 286 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Alliance", 100, "Alliance Only" }, -- Emalon the Storm Watcher (10P, 25P)
                        { 1599, { 287 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Horde", 100, "Horde Only" }, -- Koralon the Flame Watcher (10P, 25P)
                        { 1599, { 286 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Alliance", 100, "Alliance Only" }, -- Koralon the Flame Watcher (10P, 25P)
                        { 1600, { 287 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Horde", 100, "Horde Only" }, -- Toravon the Ice Watcher (10P, 25P)
                        { 1600, { 286 }, { 3, 4 }, "Reins of the Grand Black War Mammoth Alliance", 100, "Alliance Only" } -- Toravon the Ice Watcher (10P, 25P)
                    },
                    [760] = {                                                                                    -- Onyxia's Lair
                        { 1651, { 349 }, { 3, 4 }, "Reins of the Onyxian Drake", 100 }                           -- Onyxia (10P, 25P)
                    },
                    [756] = {                                                                                    -- Eye of Eternity
                        { 1617, { 246 }, { 3, 4 }, "Reins of the Azure Drake", 100 },                            -- Malygos (10P, 25P)
                        { 1617, { 247 }, { 3, 4 }, "Reins of the Blue Drake", 100 }                              -- Malygos (10P, 25P)
                    }
                },
                ["The Burning Crusade Raids"] = {
                    [745] = {                                        -- Karazhan
                        { 1553, { 168 }, { 3 }, "Fiery Warhorse's Reins", 100 } -- Attumen the Huntsman (10P)
                    },
                    [749] = {                                        -- Tempest Keep (The Eye)
                        { 533, { 183 }, { 4 }, "Ashes of Al'ar", 100 } -- Kae'lthas Sunstrider (25P)
                    }
                }
            },
            ["World Boss Mounts"] = {
                ["Battle for Azeroth World Bosses"] = {
                    { 2210, { 1250 }, "Slightly Damp Pile of Fur", 100 } -- Dunegorger Kraulok
                },
                ["Warlords of Draenor World Bosses"] = {
                    { 1262, { 634 }, "Solar Spirehawk", 100 } -- Rukhmar
                },
                ["Mists of Pandaria World Bosses"] = {
                    { 691, { 473 }, "Reins of the Heavenly Onyx Cloud Serpent",   100 }, -- Sha of Anger
                    { 814, { 542 }, "Reins of the Thundering Cobalt Cloud Serpent", 100 }, -- Nalak
                    { 826, { 533 }, "Reins of the Cobalt Primordial Direhorn",    100 }, -- Oondasta
                    { 725, { 515 }, "Son of Galleon's Saddle",                    100 } -- Galleon (Salyis's Warband)
                }
            }
        },
        allCategories = {
            { type = "dungeon",   key = "showTWWDungeons",         name = "The War Within Mythic Dungeons" },
            { type = "dungeon",   key = "showDFDungeons",          name = "Dragonflight Mythic Dungeons" },
            { type = "dungeon",   key = "showSLWeeklyDungeons",    name = "Shadowlands Mythic Dungeons" },
            { type = "dungeon",   key = "showLegionDungeons",      name = "Legion Mythic Dungeons" },
            { type = "dungeon",   key = "showBFADungeons",         name = "Battle for Azeroth Mythic Dungeons" },
            { type = "raid",      key = "showTWWRaids",            name = "The War Within Raids" },
            { type = "raid",      key = "showDFRaids",             name = "Dragonflight Raids" },
            { type = "raid",      key = "showSLRaids",             name = "Shadowlands Raids" },
            { type = "raid",      key = "showBFARaids",            name = "Battle for Azeroth Raids" },
            { type = "raid",      key = "showLegionRaids",         name = "Legion Raids" },
            { type = "raid",      key = "showWoDRaids",            name = "Warlords of Draenor Raids" },
            { type = "raid",      key = "showPandariaRaids",       name = "Mists of Pandaria Raids" },
            { type = "raid",      key = "showCataRaids",           name = "Cataclysm Raids" },
            { type = "raid",      key = "showWOTLKRaids",          name = "Wrath of the Lich King Raids" },
            { type = "raid",      key = "showBCRaids",             name = "The Burning Crusade Raids" },
            { type = "worldBoss", key = "showBFAWorldBosses",      name = "Battle for Azeroth World Bosses" },
            { type = "worldBoss", key = "showWoDWorldBosses",      name = "Warlords of Draenor World Bosses" },
            { type = "worldBoss", key = "showPandariaWorldBosses", name = "Mists of Pandaria World Bosses" }
        },
        raidsWithoutDifficultyCheck = {
            [362] = true, -- Throne of Thunder
            [317] = true, -- Mogu'shan Vaults
            [74] = true, -- Throne of the Four Winds
            [753] = true, -- Vault of Archavon
            [760] = true, -- Onyxia's Lair
            [756] = true, -- Eye of Eternity
            [187] = true, -- Dragon Soul
        },
    }

    local garrisonInvasionData = {
        { { 37640, 38482 }, { 616 }, "Shadowhide Pearltusk", 100 },
        { { 37640, 38482 }, { 626 }, "Giant Coldsnout",  100 },
        { { 37640, 38482 }, { 642 }, "Garn Steelmaw",    100 },
        { { 37640, 38482 }, { 649 }, "Smoky Direwolf",   100 }
    }

    local DFweeklies = {
        { { 70906, 70006 },                                                                                                 { 1635 },                            "Plainswalker Bearer",  33,  "First Grand Hunt of the Week" },
        { { 78821 },                                                                                                        { 1808, 1810, 1816, 1817, 1833, 1835 } }, -- Blooming Dreamseed Weekly
        { { 75125 },                                                                                                        { 1634 },                            "Waking Mammoth",       nil, "Open all Zskera Vault to search for items" },
        { { 75390, 75234, 75516, 75996, 76016, 75393, 76015, 76084, 76027, 75621, 75397, 75517, 75619, 76014, 75620, 76081 }, { 1736, 1733 },                    "Boulder Hauler Reins", nil, "Sniffenseeking Map" }
    }

    local function isBossFiltered(bossName, bossID)
        local filterString = MasterCollectorSV.bossFilter
        if type(filterString) ~= "string" then
            filterString = ""
        end

        local filters = {}
        for filter in filterString:gmatch("[^,]+") do
            filter = filter:match("^%s*(.-)%s*$") -- Trim spaces
            if filter ~= "" then
                filters[filter] = true
            end
        end
        return filters[bossName] or filters[tostring(bossID)] or false
    end

    local function getInstanceName(instanceID)
        return EJ_GetInstanceInfo(instanceID) or "Unknown Instance"
    end

    local function getBossName(bossID)
        if bossID == nil then
            return "Nightbane"
        end
        local name = EJ_GetEncounterInfo(bossID)
        return name or "Unknown Boss"
    end

    local function getLFRWingName(instanceID)
        local faction = UnitFactionGroup("player")
        local instanceIDToLFGDungeonID = {
            [1296] = 2783,                                -- Liberation of Undermine
            [1273] = 2651,                                -- Nerub'ar Place
            [1193] = 2221,                                -- Sanctum of Domination
            [875] = 1494,                                 -- Tomb of Sargeras
            [946] = 1610,                                 -- Antorus, the Burning Throne
            [1176] = faction == "Horde" and 1950 or 1947, -- Battle of Dazar'alor based on faction
        }
        local dungeonID = instanceIDToLFGDungeonID[instanceID]
        local info = dungeonID and C_LFGInfo.GetDungeonInfo(dungeonID)
        return info and info.name or "Unknown Wing"
    end

    local function isMountObtained(mountIDsArray)
        if not MasterCollectorSV.hideBossesWithMountsObtained or not mountIDsArray then
            return false
        end
        for _, mountID in ipairs(mountIDsArray) do
            local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            if not isCollected then
                return false
            end
        end
        return true
    end

    local function isDunegorgerAvailable(bossID)
        local realmTime = GetServerTime()
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
            local currentRealmTime = realmTime -- Get realm time as Unix timestamp
            local secondsInWeek = 7 * 24 * 60 * 60

            -- Set start time 1 day ahead if on NA-OCE
            if dayAhead then
                startTime = startTime + 86400
            end

            return math.floor((currentRealmTime - startTime) / secondsInWeek)
        end

        local function isDunegorgerKraulokUp()
            local startTime = time(startDate)
            local weeksSinceStart = getWeekNumberSince(startTime)
            local rotationPeriod = 6 -- Dunegorger Kraulok's rotation period in weeks

            return weeksSinceStart % rotationPeriod == 0
        end

        return isDunegorgerKraulokUp()
    end

    local function isWorldBossKilled(bossID)
        for i = 1, GetNumSavedWorldBosses() do
            if GetSavedWorldBossInfo(i) == getBossName(bossID) then
                return true
            end
        end
        return false
    end

    local function isActivityActive()
        return isDunegorgerAvailable()
    end

    local commonWordsMapping = {
        ["Harlan Sweete"] = "Harlan Sweete",
        ["Lord Harlan Sweete"] = "Harlan Sweete",
        ["Dazar"] = "Dazar",
        ["King Dazar"] = "Dazar",
        ["Mekkatorque"] = "Mekkatorque",
        ["High Tinker Mekkatorque"] = "Mekkatorque",
        ["Baleroc, the Gatekeeper"] = "Baleroc",
    }

    local function getBaseName(encounterName)
        if not encounterName then
            return nil
        end
        for key, value in pairs(commonWordsMapping) do
            if encounterName == key or encounterName:find(key) then
                return value
            end
        end
        return encounterName
    end

    local function isInstanceBossKilled(instanceID, bossID, difficultyID)
        local bossName = getBaseName(getBossName(bossID))
        for i = 1, GetNumSavedInstances() do
            local _, _, _, savedDifficulty, locked = GetSavedInstanceInfo(i)
            if locked and (aura_env.raidsWithoutDifficultyCheck[instanceID] or difficultyID == savedDifficulty) then
                for j = 1, 20 do
                    local encounterName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                    if encounterName and bossName == getBaseName(encounterName) then
                        return isKilled
                    end
                end
            end
        end
        return false
    end

    local function GetItemData(itemName)
        for categoryName, categoryData in pairs(aura_env.dungeonData) do
            for _, dungeonData in pairs(categoryData) do
                for _, encounterData in pairs(dungeonData) do
                    for _, itemInfo in ipairs(encounterData) do
                        if itemInfo[4] == itemName then
                            return { dropChanceDenominator = itemInfo[5] or "N/A" }
                        end
                    end
                end
            end
        end
        return nil
    end

    local function GetWeeklyResetTime()
        local secondsUntilWeeklyReset = C_DateAndTime.GetSecondsUntilWeeklyReset()

        if secondsUntilWeeklyReset > 0 then
            local days = math.floor(secondsUntilWeeklyReset / 86400)
            local hours = math.floor((secondsUntilWeeklyReset % 86400) / 3600)
            local minutes = math.floor((secondsUntilWeeklyReset % 3600) / 60)

            displayText = displayText .. string.format("%sTime until weekly reset: |r%02d Days %02d Hrs %02d Min\n\n", MC.goldHex, days, hours, minutes)
        end
    end

    function GetRarityAttempts(itemName)
        if not RarityDB or not RarityDB.profiles or not RarityDB.profiles["Default"] or not MasterCollectorSV.showRarityDetail then
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

    local function displayInstanceCategory(category)
        local subtitleText = ""
        local mountData = aura_env.dungeonData[category.type == "dungeon" and "Dungeon Mounts" or "Raid Mounts"]

        if mountData[category.name] and type(mountData[category.name]) == "table" then
            for instanceID, bosses in pairs(mountData[category.name]) do
                local instanceName = getInstanceName(instanceID)
                local instanceText = ""

                if type(bosses) == "table" then
                    for _, bossData in ipairs(bosses) do
                        if type(bossData) == "table" then
                            local bossID = bossData[1]
                            local bossName = getBossName(bossID)
                            local mountIDsArray = bossData[2]
                            local difficulties = bossData[3]
                            local itemName = bossData[4]
                            local factionRestriction = bossData[6]
                            local skipBoss = isMountObtained(mountIDsArray) or isBossFiltered(bossName)
                            local mountNames = {}

                            if factionRestriction then
                                if factionRestriction == "Horde Only" and UnitFactionGroup("player") ~= "Horde" then
                                    skipBoss = true
                                elseif factionRestriction == "Alliance Only" and UnitFactionGroup("player") ~= "Alliance" then
                                    skipBoss = true
                                end
                            end

                            if bossName == "Chrono-Lord Deios" then
                                mountNames = { "Quantum Corser - Multiple Mounts" }
                            else
                                mountNames = {}
                                for _, mountID in ipairs(mountIDsArray) do
                                    if not isMountObtained({ mountID }) then
                                        local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                        if mountName then
                                            local linkedMount = string.format("%s|Hmount:%d|h[%s]|h|r", MC.blueHex, mountID, mountName)
                                            if mountID == 1546 then
                                                table.insert(mountNames, itemName .. " for Mount: " .. linkedMount)
                                            else
                                                table.insert(mountNames, linkedMount)
                                            end
                                        end
                                    end
                                end
                            end

                            local rarityAttemptsText, dropChanceText = "", ""
                            if itemName then
                                local item = GetItemData(itemName)
                                if item then
                                    local attempts = tonumber(GetRarityAttempts(itemName)) or 0
                                    local denom = tonumber(item.dropChanceDenominator)

                                    if denom and denom > 0 and attempts > 0 then
                                        local chance = 1 / denom
                                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))

                                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, denom)
                                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                    end
                                end
                            end

                            local mountsText = ""
                            if #mountNames > 0 and MasterCollectorSV.showMountName then
                                if bossID == 2500 or bossID == 2502 then
                                    mountsText = string.format("\n%sItem: %s", string.rep(" ", 10), table.concat(mountNames, ", "))
                                else
                                    mountsText = string.format("\n%sMount: %s%s%s", string.rep(" ", 10), table.concat(mountNames, ", "), rarityAttemptsText, dropChanceText)
                                end
                            end
                            if not skipBoss then
                                if aura_env.raidsWithoutDifficultyCheck[instanceID] then
                                    local difficultiesText = ""
                                    local allDifficultiesKilled = true
                                    local difficultyOutputs = {}

                                    for _, difficulty in ipairs(difficulties) do
                                        local difficultyName = GetDifficultyInfo(difficulty)
                                        local isKilled = isInstanceBossKilled(instanceID, bossID, difficulty)
                                        local color = isKilled and MC.greenHex or MC.redHex

                                        table.insert(difficultyOutputs, string.format("%s|Hdifficulty:%d:%d|h%s|h|r", color, instanceID, difficulty, difficultyName))

                                        if not isKilled then
                                            allDifficultiesKilled = false
                                        end
                                    end

                                    difficultiesText = table.concat(difficultyOutputs, " / ")
                                    if not (MasterCollectorSV.showBossesWithNoLockout and allDifficultiesKilled) then
                                        local bossColor = allDifficultiesKilled and MC.greenHex or MC.redHex
                                        instanceText = instanceText .. string.format("%s- %s|Hjournal:1:%d:0:0:0|h%s|h|r (%s)|r%s\n", string.rep(" ", 6), bossColor, bossID, bossName, difficultiesText, mountsText)
                                    end
                                else
                                    local allDifficultiesKilled = true
                                    local difficultyOutputs = {}
                                    for _, difficulty in ipairs(difficulties) do
                                        local difficultyName = GetDifficultyInfo(difficulty)
                                        local isKilled = isInstanceBossKilled(instanceID, bossID, difficulty)
                                        local color = isKilled and MC.greenHex or MC.redHex

                                        if difficulty == 17 then
                                            local wingName = getLFRWingName(instanceID)
                                            wingName = wingName or "Unknown Wing"
                                            table.insert(difficultyOutputs, color .. difficultyName .. " - " .. wingName .. "|r")
                                        else
                                            table.insert(difficultyOutputs, string.format("%s|Hdifficulty:%d:%d|h%s|h|r", color, instanceID, difficulty, difficultyName))
                                        end

                                        if not isKilled then
                                            allDifficultiesKilled = false
                                        end
                                    end

                                    local difficultiesText = table.concat(difficultyOutputs, " / ")

                                    if not (MasterCollectorSV.showBossesWithNoLockout and allDifficultiesKilled) then
                                        local bossColor = allDifficultiesKilled and MC.greenHex or MC.redHex
                                        instanceText = instanceText .. string.format("%s- %s|Hjournal:1:%d:0:0:0|h%s|h|r (%s)|r%s\n", string.rep(" ", 6), bossColor, bossID, bossName, difficultiesText, mountsText)
                                    end
                                end
                            end
                        end
                    end
                end
                if instanceText ~= "" then
                    subtitleText = subtitleText .. string.format("%s- %s%s|r\n", string.rep(" ", 3), MC.goldHex, instanceName)
                    subtitleText = subtitleText .. instanceText
                end
            end
        end
        if subtitleText ~= "" then
            displayText = displayText .. string.format("%s%s|r\n", MC.goldHex, category.name)
            displayText = displayText .. subtitleText
        end
    end

    local function displayWorldBossCategory(category)
        local subtitleText = ""
        if aura_env.dungeonData["World Boss Mounts"][category.name] and type(aura_env.dungeonData["World Boss Mounts"][category.name]) == "table" then
            for _, bossData in ipairs(aura_env.dungeonData["World Boss Mounts"][category.name]) do
                if type(bossData) == "table" then
                    local bossID = bossData[1]
                    local bossName = getBossName(bossID)
                    local mountIDsArray = bossData[2]
                    local itemName = bossData[3]
                    local denom = bossData[4]
                    local skipBoss = isMountObtained(mountIDsArray) or isBossFiltered(bossName)
                    if not skipBoss then
                        local mountNames = {}
                        for _, mountID in ipairs(mountIDsArray) do
                            if not isMountObtained({ mountID }) then
                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                if mountName then
                                    table.insert(mountNames, {id = mountID, name = mountName})
                                end
                            end
                        end

                        local rarityAttemptsText, dropChanceText = "", ""
                        if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                            if itemName and MasterCollectorSV.showRarityDetail then
                                local attempts = GetRarityAttempts(itemName) or 0
                                local dropChance = Rarity.Statistics.GetRealDropPercentage(itemName) or 0
                                local cumulativeChance = 0

                                if dropChance and dropChance > 0 and attempts > 0 then
                                    denom = math.floor(1 / dropChance)
                                    cumulativeChance = 100 * (1 - math.pow(1 - dropChance, attempts))
                                end
                                rarityAttemptsText = string.format(" (Attempts: %s/%s", attempts, denom)
                                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                            end
                        end

                        local mountsText = ""
                        local linkedMounts = {}

                        for _, mountnameData in ipairs(mountNames) do
                            local id = mountnameData.id or 0
                            local name = mountnameData.name or "Unknown Mount"
                            local link = string.format("%s|Hmount:%d|h[%s]|h|r", MC.blueHex, id, name)
                            table.insert(linkedMounts, link)
                        end

                        if #mountNames > 0 and MasterCollectorSV.showMountName then
                            mountsText = string.format("\n%sMount: %s%s%s", string.rep(" ", 10), table.concat(linkedMounts, ", "), rarityAttemptsText, dropChanceText)
                        end
                        local isKilled
                        local showBoss = true
                        local color = MC.redHex
                        if bossID == 2210 then
                            showBoss = isActivityActive()
                            isKilled = C_QuestLog.IsQuestFlaggedCompleted(53000)
                        else
                            isKilled = isWorldBossKilled(bossID)
                        end
                        if showBoss then
                            if isKilled then
                                color = MC.greenHex
                            end
                            if not (MasterCollectorSV.showBossesWithNoLockout and isKilled) then
                                local bossLink = string.format("|Hjournal:1:%d:0:0:0|h%s|h", bossID, bossName)
                                subtitleText = subtitleText .. string.format("%s- %s%s|r%s\n", string.rep(" ", 6), color, bossLink, mountsText)
                            end
                        end
                    end
                end
            end
        end
        if subtitleText ~= "" then
            displayText = displayText .. string.format("%s%s|r\n", MC.goldHex, category.name)
            displayText = displayText .. subtitleText
        end
    end

    local function GarrisonInvasionMounts()
        if not MasterCollectorSV.showGarrisonInvasions then
            return
        end

        local subtitleText = ""
        for _, mountData in ipairs(garrisonInvasionData) do
            local questIDs = mountData[1]
            local mountIDsArray = mountData[2]
            local itemName = mountData[3]
            local dropChanceDenominator = mountData[4]
            local questCompleted = false
            for _, questID in ipairs(questIDs) do
                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                    questCompleted = true
                    break
                end
            end

            if not (MasterCollectorSV.showBossesWithNoLockout and questCompleted) then
                local mountNames = {}
                for _, mountID in ipairs(mountIDsArray) do
                    if type(mountID) == "number" and not isMountObtained({ mountID }) then
                        local mountName = C_MountJournal.GetMountInfoByID(mountID)
                        if mountName then
                            table.insert(mountNames, {id = mountID, name = mountName})
                        end
                    end
                end

                local rarityAttemptsText = ""
                local dropChanceText = ""

                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if itemName then
                        local attempts = GetRarityAttempts(itemName) or 0

                        if MasterCollectorSV.showRarityDetail then
                            local chance = 1 / dropChanceDenominator
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end
                end

                local mountsText = ""
                local linkedMounts = {}

                for _, mountnameData in ipairs(mountNames) do
                    local id = mountnameData.id or 0
                    local name = mountnameData.name or "Unknown Mount"
                    local link = string.format("%s|Hmount:%d|h[%s]|h|r", MC.blueHex, id, name)
                    table.insert(linkedMounts, link)
                end

                if #mountNames > 0 and MasterCollectorSV.showMountName then
                    mountsText = string.format("%sMount: %s%s%s\n", string.rep(" ", 10), table.concat(linkedMounts, ", "), rarityAttemptsText, dropChanceText)
                end
                if mountsText ~= "" then
                    subtitleText = subtitleText .. mountsText
                end
            end
        end

        if subtitleText ~= "" then
            displayText = displayText .. string.format("%sGarrison Invasion Mounts|r\n%s", MC.goldHex, subtitleText)
        end
    end

    local function DFWeeklyActivities()
        if not MasterCollectorSV.showDFWeeklies then return end

        local subtitleText = ""
        for _, mountData in ipairs(DFweeklies) do
            local questIDs = mountData[1]
            local mountIDsArray = mountData[2]
            local itemName = mountData[3]
            local dropChanceDenominator = mountData[4]
            local questCompleted = false
            for _, questID in ipairs(questIDs) do
                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                    questCompleted = true
                    break
                end
            end

            local questName
            local dreamseedsNote = 78821
            for _, questID in ipairs(questIDs) do
                questName = mountData[5] or C_QuestLog.GetTitleForQuestID(questID)
                if questName then
                    if questID == dreamseedsNote then
                        questName = questName .. string.format(" Quest\n%s(1 x Seedbloom awarded - Need The Dream Wardens Renown 18 to buy mounts)", string.rep(" ", 3))
                    end
                    break
                end
            end

            if not (MasterCollectorSV.showBossesWithNoLockout and questCompleted) then
                local mountNames = {}
                for _, mountID in ipairs(mountIDsArray) do
                    if type(mountID) == "number" and not isMountObtained({ mountID }) then
                        local mountName = C_MountJournal.GetMountInfoByID(mountID)
                        local renownLevel = C_MajorFactions.GetCurrentRenownLevel(2564)

                        if mountName then
                            if mountID == 1736 then
                                if questName == "Sniffenseeking Map" then
                                    questName = questName .. string.format("\n%s(for Barter Boulders/Bricks)", string.rep(" ", 6))
                                end

                                local extra

                                if renownLevel < 12 then
                                    extra = "(Requires 170 Barter Bricks)"
                                else
                                    extra = "(Requires 85 Barter Boulders)"
                                end

                                table.insert(mountNames, {id = mountID, name = mountName, extra = extra})

                            elseif mountID == 1733 then
                                local _, achieveName1 = GetAchievementInfo(17832)
                                local _, achieveName2 = GetAchievementInfo(17785)
                                local extra = string.format("%s\n%s%s for %s for A World Awoken Meta Achievement|r", MC.goldHex, string.rep(" ", 6), achieveName1, achieveName2)
                                table.insert(mountNames, {id = mountID, name = mountName, extra = extra})

                            else
                                table.insert(mountNames, {id = mountID, name = mountName})
                            end
                        end
                    end
                end

                local rarityAttemptsText, dropChanceText = "", ""
                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                    if itemName and dropChanceDenominator then
                        local attempts = GetRarityAttempts(itemName) or 0

                        if MasterCollectorSV.showRarityDetail then
                            local chance = 1 / dropChanceDenominator
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end
                end

                local mountsText = ""
                local linkedMounts = {}
                for _, mountData in ipairs(mountNames) do
                    local id = mountData.id or 0
                    local name = mountData.name or "Unknown Mount"
                    local link = string.format("%s|Hmount:%d|h[%s]|h|r", MC.blueHex, id, name)

                    if mountData.extra then
                        link = link .. string.format(" %s", mountData.extra)
                    end

                    table.insert(linkedMounts, string.format("%sMount: %s", string.rep(" ", 10), link))
                end

                if #mountNames > 0 and MasterCollectorSV.showMountName then
                    mountsText = table.concat(linkedMounts, "\n") .. rarityAttemptsText .. dropChanceText
                end
                if mountsText ~= "" then
                    subtitleText = subtitleText .. string.format("%s%s- %s|r\n%s\n", MC.goldHex, string.rep(" ", 3), questName, mountsText)
                end
            end
        end

        if subtitleText ~= "" then
            displayText = displayText .. string.format("%sDragonflight Weekly Activities|r\n%s",MC.goldHex, subtitleText)
        end
    end

    local function displayCategories()
        GetWeeklyResetTime()

        local previousLength = #displayText

        GarrisonInvasionMounts()
        DFWeeklyActivities()

        local contentAdded = #displayText > previousLength

        for _, category in ipairs(aura_env.allCategories) do
            if MasterCollectorSV[category.key] then
                local previousLength = #displayText
                if category.type == "worldBoss" then
                    displayWorldBossCategory(category)
                else
                    displayInstanceCategory(category)
                end
                if #displayText > previousLength then
                    contentAdded = true
                end
            end
        end

        if not contentAdded then
            displayText = displayText .. string.format("%sWe are all done here.... FOR NOW!|r", MC.goldHex)
        end
    end

    if MC.mainFrame and MC.mainFrame.text then
        displayCategories()
        MC.mainFrame.text:SetText(displayText)
        MC.mainFrame.text:SetHeight(MC.mainFrame.text:GetContentHeight())
    end
end