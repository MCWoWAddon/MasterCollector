function MC.repsDisplay()
    local fontSize = MasterCollectorSV.fontSize

    MC.InitializeColors()

    if MC.currentTab ~= "Daily Rep\nGrinds" then
        return
    end

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont(font, fontSize, flags)
    end

    local factionIDs = {
        ["The Burning Crusade"] = {
            { 1031 },                 -- Sha'tari Skyguard
            { 1015 },                 -- Netherwing
            { 978, "Alliance Only" }, -- Kurenai
            { 941, "Horde Only" },    -- The Mag'har
            { 942 },                  -- Cenarion Expedition
        },
        ["Wrath Of The Lich King"] = {
            { 1119 },                 -- The Sons of Hodir
            { 1091 },                 -- The Wyrmrest Accord
            { 1105 },                 -- The Oracles
            { 1124, "Horde Only" },   -- Sunreavers
            { 1094, "Alliance Only" } -- Silver Covenant
        },
        ["Cataclysm"] = {
            { 1177, "Alliance Only" }, -- Baradin's Wardens
            { 1178, "Horde Only" },    -- Hellscream's Reach
            { 1173 },                  -- Ramkahen
        },
        ["Mists of Pandaria"] = {
            { 1375, "Horde Only" },    -- Dominance Offensive
            { 1376, "Alliance Only" }, -- Operation: Shieldwall
            { 1387, "Alliance Only" }, -- Kirin Tor Offensive
            { 1388, "Horde Only" },    -- Sunreaver Onslaught
            { 1302 },                  -- The Anglers
            { 1341 },                  -- The August Celestials
            { 1337 },                  -- The Klaxxi
            { 1270 },                  -- Shado-Pan
            { 1272 },                  -- The Tillers
            { 1271 },                  -- Order of the Cloud Serpent
            { 1269 },                  -- Golden Lotus
        },
        ["Warlords of Draenor"] = {
            { 1848, "Horde Only" },    -- Vol'jin's Headhunters
            { 1847, "Alliance Only" }, -- Hand of the Prophet
            { 1849 },                  -- Order of the Awakened
        },
        ["Legion"] = {
            { 1828 }, -- Highmountain Tribe
            { 1883 }, -- Dreamweavers
            { 1900 }, -- Court of Farondis
            { 1859 }, -- The Nightfallen
            { 1948 }, -- Valarjar
            { 2170 }, -- Argussian Reach
            { 2165 }, -- Army of the Light
        },
        ["Battle for Azeroth"] = {
            { 2158, "Horde Only" },                 -- Voldunai
            { 2160, "Alliance Only" },              -- Proudmoore Admiralty
            { 2156, "Horde Only" },                 -- Talanji's Expedition
            { 2162, "Alliance Only" },              -- Storm's Wake
            { 2103, "Horde Only" },                 -- Zandalari Empire
            { 2161, "Alliance Only" },              -- Order of Embers
            { 2400, "Alliance Only" },              -- Ankoan
            { 2375, "Alliance Only", "Bodyguard" }, -- Akana (Bodyguard Naz Rep)
            { 2389, "Horde Only",    "Bodyguard" }, -- Neri (Bodyguard Naz Rep)
            { 2373, "Horde Only" },                 -- Unshackled
            { 2391 },                               -- Rustbolt Resistance
            { 2417 },                               -- Uldum Accord
        },
        ["Shadowlands"] = {
            { 2410 }, -- The Undying Army
            { 2465 }, -- The Wild Hunt
            { 2413 }, -- Court of Harvesters
            { 2407 }, -- The Ascended
            { 2464 }, -- Court of Night
            { 2470 }, -- Death's Advance
            { 2472 }, -- The Archivist's Codex
            { 2432 }, -- Ve'nari
            { 2463 }, -- Marasmius
            { 2478 }, -- The Enlightened
        },
        ["Dragonflight Renowns"] = {
            { 2503 }, -- Maruuk Centaur
            { 2510 }, -- Valdrakken Accord
            { 2507 }, -- Dragonscale Expedition
            { 2511 }, -- Iskaara Tuskarr
            { 2564 }, -- Loamm Niffen
            { 2574 }, -- Dream Wardens
        },
        ["Dragonflight Other Reps"] = {
            { 2568 }, -- Glimmerogg Racer
            { 2517 }, -- Wrathion
            { 2518 }, -- Sabellian
            { 2553 }, -- Soridormi
            { 2544 }, -- Artisan's Consortium
            { 2550 }, -- Cobalt Assembly
            { 2526 }, -- Winterpelt Furbolg Language
        }
    }

    local expansionOrder = {
        "The Burning Crusade",
        "Wrath Of The Lich King",
        "Cataclysm",
        "Mists of Pandaria",
        "Warlords of Draenor",
        "Legion",
        "Battle for Azeroth",
        "Shadowlands",
        "Dragonflight Renowns",
        "Dragonflight Other Reps"
    }

    local factionMounts = {
        [1031] = { 176, 177, 178, 179, 180 },                        -- all 200g
        [1015] = { 186, 187, 188, 189, 190, 191 },                   -- all 200g
        [978] = { 153, 154, 155, 156, 170, 172, 173, 174 },          -- first 4 70g, last 4 100g
        [941] = { 153, 154, 155, 156, 170, 172, 173, 174 },          -- first 4 70g, last 4 100g
        [942] = { 203 },                                             -- 2000g
        [1119] = { 258, 288 },                                       -- first mount needs 1000g, 2nd needs 10000g
        [1091] = { 249 },                                            -- 2000g
        [1105] = { 278 },                                            -- Revered - keep rolling eggs
        [1124] = { 332, 330 },                                       -- first mount needs 100 champion seals, 2nd needs 150
        [1094] = { 331, 329 },                                       -- first mount needs 100 champion seals, 2nd needs 150
        [1177] = { 394, 405 },                                       -- first mount needs 200 commendations, 2nd needs 165
        [1178] = { 394, 406 },                                       -- first mount needs 200 commendations, 2nd needs 165
        [1173] = { 398, 399 },                                       -- both 100g
        [1375] = { 527, 529 },                                       -- first mount needs 2000g
        [1376] = { 526, 528 },                                       -- first mount needs 2000g
        [1387] = { 545 },                                            -- 3000g
        [1388] = { 546 },                                            -- 3000g
        [1302] = { 449 },                                            -- 1000g
        [1341] = { 504 },                                            -- 10000g
        [1337] = { 463 },                                            -- 10000g
        [1270] = { 505, 506, 507, 471 },                             -- first 3 1500g, 500g, 2000g, last one requires exalted Order of the Cloud Serpent (1271)
        [1272] = { 508, 510, 511 },                                  -- 500g, 3250g, 1500g
        [1271] = { 448, 464, 465, 471 },                             -- first 3 750g, last one requires exalted Shado Pan (1270)
        [1269] = { 479, 480, 481 },                                  -- 500g, 2500g, 1500g
        [1848] = { 768 },                                            -- 2500g
        [1847] = { 768 },                                            -- 2500g
        [1849] = { 753 },                                            -- Friendly & 150k apexis crystals
        [1828] = { 941 },                                            -- paragon mount
        [1883] = { 942 },                                            -- paragon mount
        [1900] = { 943 },                                            -- paragon mount
        [1859] = { 905 },                                            -- paragon mount
        [1948] = { 944 },                                            -- paragon mount
        [2170] = { 939, 964, 965, 966, 967, 968 },                   -- mounts dont need paragon -- all 10000g
        [2165] = { 983, 984, 985, 932 },                             --mount id 932 does not need paragon -- 500000g
        [2158] = { 926, 1060 },                                      -- mounts dont need paragon -- 10000g & 90000g
        [2160] = { 1010, 1064 },                                     -- mounts dont need paragon -- 10000g & 90000g
        [2156] = { 1061, 1059 },                                     -- mounts dont need paragon -- 10000g & 90000g
        [2162] = { 1015, 1063 },                                     -- mounts dont need paragon -- 10000g & 90000g
        [2103] = { 1058, 958 },                                      -- mounts dont need paragon -- 10000g & 90000g
        [2161] = { 1016, 1062 },                                     -- mounts dont need paragon -- 10000g & 90000g
        [2400] = { 1231, 1237 },                                     -- 1st mount does not need paragon -- 250 prismatic manapearls
        [2375] = { 1255 },                                           -- mounts dont need exalted (rank 20)
        [2389] = { 1256 },                                           -- mounts dont need exalted (rank 20)
        [2373] = { 1230, 1237 },                                     -- 1st mount does not need paragon -- 250 prismatic manapearls
        [2391] = { 1254 },                                           -- mount dont need paragon -- 524288g
        [2417] = { 1318 },                                           -- mount dont need paragon -- 24000g
        [2410] = { 1350, 1375 },                                     -- 1st mount does not need paragon - 30000g
        [2465] = { 1361, 1428 },                                     -- 1st mount does not need paragon - 30000g
        [2413] = { 1421 },                                           -- 30000g
        [2407] = { 1425 },                                           -- 30000g
        [2464] = { 1420 },                                           -- 5000 Anima
        [2470] = { 1436, 1455, 1486, 1491, 1497, 1505, 1508, 2114 }, -- 1505 is 5000 Stygia, 1455 & 1505 are Paragon, rest except 2114 is 1000 Stygia
        [2472] = { 1450, 1454, 2114 },                               -- 1454 is paragon, 1450 is 5000 catalogued research
        [2432] = { 1501, 2114 },                                     -- 1501 paragon
        [2463] = { 2114 },
        [2478] = { 1522, 1529, 2114 },                               -- 5000 Anima each except 2114
        [2568] = { 1729 },
        [2553] = { 1825 },
        [2517] = { 1612, 1825 },
        [2518] = { 1612, 1825 },
        [2544] = { 1825 },
        [2550] = { 1825 },
        [2526] = { 1825 },
    }

    local function GetReputationColor(reaction)
        local colors = {
            [8] = { r = 0, g = 1, b = 0 },     -- Exalted: green
            [7] = { r = 0.6, g = 1, b = 0.6 }, -- Revered: mint green
            [6] = { r = 0, g = 0.8, b = 0 },   -- Honored: emerald green
            [5] = { r = 0, g = 1, b = 0 },     -- Friendly: neon green
            [4] = { r = 1, g = 1, b = 0 },     -- Neutral: yellow
            [3] = { r = 1, g = 0.65, b = 0 },  -- Unfriendly: orange
            [2] = { r = 1, g = 0.6, b = 0.6 }, -- Hostile: light red
            [1] = { r = 1, g = 0, b = 0 }      -- Hated: red
        }

        local color = colors[reaction]
        if color then
            return string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        else
            return "|cffffffff" -- Default color (white) if reaction is not in the list
        end
    end

    local function GetFriendshipColor(reaction)
        local colors = {
            ["Exalted"] = { r = 0, g = 1, b = 0 },       -- Exalted: green
            ["Revered"] = { r = 0.6, g = 1, b = 0.6 },   -- Revered: mint green
            ["Honored"] = { r = 0, g = 0.8, b = 0 },     -- Honored: emerald green
            ["Friendly"] = { r = 0, g = 1, b = 0 },      -- Friendly: neon green
            ["Neutral"] = { r = 1, g = 1, b = 0 },       -- Neutral: yellow
            ["Unfriendly"] = { r = 1, g = 0.65, b = 0 }, -- Unfriendly: orange
            ["Hostile"] = { r = 1, g = 0.6, b = 0.6 },   -- Hostile: light red
            ["Hated"] = { r = 1, g = 0, b = 0 }          -- Hated: red
        }

        local color = colors[reaction]
        if color then
            return string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        else
            return "|cffffffff" -- Default color (white) if reaction is not in the list
        end
    end

    local archivistsCodexRepRename = {
        [7] = { "Tier 6" },
        [6] = { "Tier 5" },
        [5] = { "Tier 4" },
        [4] = { "Tier 3" },
        [3] = { "Tier 2" },
        [2] = { "Tier 1" }
    }

    local venariRepRename = {
        [8] = { "Appreciative" },
        [7] = { "Cordial" },
        [6] = { "Ambivalent" },
        [5] = { "Tentative" },
        [4] = { "Apprehensive" },
        [3] = { "Dubious" }
    }

    local glimmerogRepRename = {
        [4] = { "Professional" },
        [3] = { "Skilled" },
        [2] = { "Competent" },
        [1] = { "Amateur" },
        [0] = { "Aspirational" }
    }

    local soridormiRepRename = {
        [8] = { "Legend" },
        [7] = { "Timewalker" },
        [6] = { "Rift-Mender" },
        [5] = { "Future Friend" },
        [4] = { "Anomaly" }
    }

    local blkDragonRepRename = {
        [8] = { "True Friend" },
        [7] = { "Friend" },
        [6] = { "Fang" },
        [5] = { "Ally" },
        [4] = { "Cohort" },
        [3] = { "Acquaintance" }
    }

    local artisansRepRename = {
        [6] = { "Esteemed" },
        [5] = { "Valued" },
        [4] = { "Respected" },
        [3] = { "Preferred" },
        [2] = { "Neutral" }
    }

    local cobaltRepRename = {
        [6] = { "Maximum" },
        [5] = { "High" },
        [4] = { "Medium" },
        [3] = { "Low" },
        [2] = { "Empty" }
    }

    local covRenownMounts = {
        [1] = { { 1398, 23, 5000 }, { 1399, 39, 0 }, { 1492, 45, 0 }, { 1494, 70, 0 } },    -- Kyrian
        [2] = { { 1384, 23, 5000 }, { 1388, 39, 0 }, { 1490, 45, 0 }, { 1489, 70, 0 } },    -- Venthyr
        [3] = { { 1354, 23, 5000 }, { 1357, 39, 0 }, { 1484, 45, 0 }, { 1485, 70, 7500 } }, -- Night Fae
        [4] = { { 1365, 23, 5000 }, { 1369, 39, 0 }, { 1495, 45, 0 }, { 1496, 70, 7500 } }  -- Necrolord
    }

    local DFRenownMountReq = {
        [2507] = { { 1615, 25, 750 }, { 1616, 25, 750 }, { 1825, 25 } },
        [2511] = { { 1657, 25, 750 }, { 1659, 25, 750 }, { 1653, 30, 1000 }, { 1655, 30, 1000 }, { 1825, 30 } },
        [2564] = { { 1738, 18, 800 }, { 1825, 20 } },
        [2574] = { { 1809, 17, 1200 }, { 1811, 17, 1200 }, { 1825, 20 } },
        [2503] = { { 1825, 25 } },
        [2510] = { { 1825, 30 } },
    }

    local function HandleBodyguardRep(factionID)
        local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendshipInfo and friendshipInfo.standing and friendshipInfo.maxRep then
            local name = friendshipInfo.name
            local standingLabel = friendshipInfo.reaction or "Unknown"
            local currentStanding = friendshipInfo.standing or 0
            local nextThreshold = friendshipInfo.maxRep
            local colorHex = GetReputationColor()

            return string.format("  - %s|r%s         %s   %d/ %d|r\n", name, colorHex, standingLabel, currentStanding,
                nextThreshold)
        end
        return ""
    end

    local function tableContains(t, value)
        for _, v in ipairs(t) do
            if v == value then
                return true
            end
        end
        return false
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

    local playerFaction = UnitFactionGroup("player")
    local displayText = ""

    local function GetCharacterKey()
        local name, realm = UnitName("player"), GetRealmName()
        return name .. "-" .. realm
    end

    local characterKey = GetCharacterKey()
    local function CalculateTotalAnima(characterKey)
        local totalAnima = 0
        local characterData = MasterCollectorSV[characterKey]

        if characterData and characterData.covenants then
            for _, covenant in ipairs(characterData.covenants) do
                totalAnima = totalAnima + (covenant.covenantAnima or 0)
            end
        end

        return totalAnima
    end

    local totalAnima = CalculateTotalAnima(characterKey)

    function MC.UpdateCovenantDisplay()
        local characterKey = GetCharacterKey()
        local activeCovenantID = C_Covenants.GetActiveCovenantID()
        local currentRenownLevel = C_CovenantSanctumUI.GetRenownLevel()
        local currentCovenantAnima = C_CurrencyInfo.GetCurrencyInfo(1813).quantity
        local iconCovenantAnima = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID
        local iconSize = CreateTextureMarkup(iconCovenantAnima, 32, 32, 16, 16, 0, 1, 0, 1)

        if not MasterCollectorSV[characterKey] then
            MasterCollectorSV[characterKey] = { covenants = {} }
        elseif not MasterCollectorSV[characterKey].covenants then
            MasterCollectorSV[characterKey].covenants = {}
        end

        MasterCollectorSV[characterKey].covenants[activeCovenantID] = {
            renownLevel = currentRenownLevel,
            maxRenownLevel = 80,
            covenantAnima = currentCovenantAnima
        }

        MC.covenantFactionMap = {
            [1] = "Kyrian",
            [2] = "Venthyr",
            [3] = "Night Fae",
            [4] = "Necrolord",
        }

        local covenantText = string.format(
            "%sCovenants \n   - %s|r: Renown %d / %d   %s Reservoir Anima: %d %s  (Current Covenant)|r\n",
            MC.goldHex,
            MC.covenantFactionMap[activeCovenantID] or "Unknown Covenant",
            MasterCollectorSV[characterKey].covenants[activeCovenantID].renownLevel,
            MasterCollectorSV[characterKey].covenants[activeCovenantID].maxRenownLevel,
            MC.goldHex,
            MasterCollectorSV[characterKey].covenants[activeCovenantID].covenantAnima,
            iconSize
        )

        local function GetCovenantMountsText(covenantID)
            local mountsText = MC.goldHex .. "      Renown Mounts:|r\n"
            for _, mountData in ipairs(covRenownMounts[covenantID] or {}) do
                local mountID, requiredRenownLevel, requiredAnima = mountData[1], mountData[2], mountData[3]
                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                if not isCollected and MasterCollectorSV.hideBossesWithMountsObtained then
                    if requiredAnima ~= 0 then
                        mountsText = mountsText ..
                            string.format("         - %s (Requires Renown %d)   %s%s Anima %s Required|r\n", mountName,
                                requiredRenownLevel, MC.goldHex, requiredAnima, iconSize)
                    else
                        mountsText = mountsText ..
                            string.format("         - %s (Requires Renown %d)\n", mountName, requiredRenownLevel)
                    end
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    if requiredAnima ~= 0 then
                        mountsText = mountsText ..
                            string.format("         - %s (Requires Renown %d)   %s%s Anima %s Required|r\n", mountName,
                                requiredRenownLevel, MC.goldHex, requiredAnima, iconSize)
                    else
                        mountsText = mountsText ..
                            string.format("         - %s (Requires Renown %d)\n", mountName, requiredRenownLevel)
                    end
                end
            end
            return mountsText
        end

        if MasterCollectorSV.showSLCovenants then
            if MasterCollectorSV.showMountName then
                covenantText = covenantText .. GetCovenantMountsText(activeCovenantID) .. "\n"
            end

            for covenantID, covenantName in pairs(MC.covenantFactionMap) do
                if covenantID ~= activeCovenantID then
                    local otherCovenantData = MasterCollectorSV[characterKey].covenants[covenantID] or
                        { renownLevel = 0, maxRenownLevel = 0, covenantAnima = 0, }
                    if otherCovenantData.renownLevel == 0 then
                        covenantText = covenantText .. string.format(
                            "%s   - %s|r: Switch Covenants to get Covenant Details\n",
                            MC.goldHex,
                            covenantName
                        )
                    else
                        covenantText = covenantText .. string.format(
                            "%s   - %s|r: Renown %d / %d   %sReservoir Anima: %d %s|r\n",
                            MC.goldHex,
                            covenantName,
                            otherCovenantData.renownLevel,
                            otherCovenantData.maxRenownLevel,
                            MC.goldHex,
                            otherCovenantData.covenantAnima,
                            iconSize
                        )

                        if MasterCollectorSV.showMountName then
                            covenantText = covenantText .. GetCovenantMountsText(covenantID) .. "\n"
                        end
                    end
                end
            end

            covenantText = covenantText ..
                MC.goldHex .. "Total Anima for " .. characterKey .. " is: " .. totalAnima .. " |r" .. iconSize .. "\n"

            local _, achieveName, _, achieved = GetAchievementInfo(15646)
            if not achieved and MasterCollectorSV.hideBossesWithMountsObtained then
                if not activeCovenantID or activeCovenantID == 0 then
                    displayText =
                    "|cffff0000Error: Unable to Load Covenant, Select a Covenant and/or Reload UI to get Covenant details|r\n\n"
                else
                    displayText = displayText ..
                        covenantText ..
                        "\n" ..
                        MC.goldHex ..
                        "All Covenants Required at Level 80 for " ..
                        achieveName .. " for Back from Beyond Meta Achievement|r\n\n"
                end
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                if not activeCovenantID or activeCovenantID == 0 then
                    displayText =
                    "|cffff0000Error: Unable to Load Covenant, Select a Covenant and/or Reload UI to get Covenant details|r\n\n"
                else
                    displayText = displayText ..
                        covenantText ..
                        "\n" ..
                        MC.goldHex ..
                        "All Covenants Required at Level 80 for " ..
                        achieveName .. " for Back from Beyond Meta Achievement|r\n\n"
                end
            end
        end
    end

    if MC.UpdateCovenantDisplay() ~= nil then
        MC.UpdateCovenantDisplay()
    end

    local playerMoney = GetMoney()
    local moneyString = C_CurrencyInfo.GetCoinTextureString(playerMoney)

    for _, expansion in pairs(expansionOrder) do
        local factions = factionIDs[expansion]
        local factionText = ""

        local shouldProcessExpansion = true
        if (expansion == "The Burning Crusade" and not MasterCollectorSV.showTBCReps) or
            (expansion == "Wrath Of The Lich King" and not MasterCollectorSV.showWOTLKReps) or
            (expansion == "Cataclysm" and not MasterCollectorSV.showCataReps) or
            (expansion == "Mists of Pandaria" and not MasterCollectorSV.showPandariaReps) or
            (expansion == "Warlords of Draenor" and not MasterCollectorSV.showWoDReps) or
            (expansion == "Legion" and not MasterCollectorSV.showLegionReps) or
            (expansion == "Battle for Azeroth" and not MasterCollectorSV.showBfAReps) or
            (expansion == "Shadowlands" and not MasterCollectorSV.showSLReps) or
            (expansion == "Dragonflight Renowns" and not MasterCollectorSV.showDFRenownReps) or
            (expansion == "Dragonflight Other Reps" and not MasterCollectorSV.showDFOtherReps) then
            shouldProcessExpansion = false
        end

        if shouldProcessExpansion then
            for _, factionData in ipairs(factions) do
                local factionID, factionType, specialCategory = unpack(factionData)
                local mountIDs = factionMounts[factionID]

                if expansion == "Dragonflight Renowns" then
                    local renownLevel = C_MajorFactions.GetCurrentRenownLevel(factionID)
                    local mountsText = ""
                    local factionName = C_Reputation.GetFactionDataByID(factionID).name
                    local uncollectedMounts = {}

                    if MasterCollectorSV.showMountName then
                        if DFRenownMountReq[factionID] then
                            if (factionID == 2503) or (factionID == 2510) then
                                mountsText = ""
                            else
                                mountsText = MC.goldHex .. "      Mounts:|r\n"
                            end

                            for _, mountInfo in ipairs(DFRenownMountReq[factionID]) do
                                local mountID, requiredRenownLevel, requiredCurrency = unpack(mountInfo)
                                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                                local currentDFSupplies = C_CurrencyInfo.GetCurrencyInfo(2003).quantity
                                local fileDFSupplies = C_CurrencyInfo.GetCurrencyInfo(2003).iconFileID
                                local iconDFSupplies = CreateTextureMarkup(fileDFSupplies,
                                        32, 32, 16, 16, 0, 1, 0, 1)
                                local buyorearntxt = ""

                                if mountID == 1825 then
                                    local _, achieveName = GetAchievementInfo(19466)
                                    mountsText = mountsText ..
                                        string.format(
                                            "\n         %s Renown %s Required for %s for A World Awoken Meta Achievement|r\n         Mount: %s\n\n",
                                            MC.goldHex, requiredRenownLevel, achieveName, mountName)
                                    if not isCollected then
                                        table.insert(uncollectedMounts, mountName)
                                    end
                                else
                                    if not isCollected then
                                        table.insert(uncollectedMounts, mountName)
                                    end

                                    local mountData = {
                                        [1615] = { pairID = 1616, questID = 70821, text = MC.goldHex .. "         1 mount is a quest reward; the other costs 5x Iridescent Plume, 20x Contoured Fowlfeather|r\n" },
                                        [1657] = { pairID = 1659, questID = 70972, text = MC.goldHex .. "         1 mount is a quest reward; the other costs 2x Mastodon Tusk, 2x Aquatic Maw|r\n" },
                                        [1653] = { pairID = 1655, questID = 72328, text = MC.goldHex .. "\n         1 mount is a quest reward; the other costs 5x Mastodon Tusk, 5x Aquatic Maw|r\n" }
                                    }

                                    local mountsInfo = mountData[mountID]
                                    if mountsInfo and C_QuestLog.IsQuestFlaggedCompleted(mountsInfo.questID) then
                                        buyorearntxt = mountsInfo.text
                                    end

                                    mountsText = mountsText .. string.format("%s         - %s (Requires Renown %d)\n", buyorearntxt, mountName, requiredRenownLevel) .. string.rep(" ", 6) .. MC.goldHex .. "   " ..
                                    currentDFSupplies .. " / " .. requiredCurrency .. " Dragon Isles Supplies " .. iconDFSupplies .. " Required|r\n"
                                end
                            end
                        end
                    end
                    if #uncollectedMounts > 0 and MasterCollectorSV.hideBossesWithMountsObtained then
                        factionText = factionText ..
                            string.format("  %s - %s|r: Renown %d \n  %s", MC.goldHex, factionName, renownLevel,
                                mountsText)
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        factionText = factionText ..
                            string.format("  %s - %s|r: Renown %d \n  %s", MC.goldHex, factionName, renownLevel,
                                mountsText)
                    end
                else
                    if not factionType or (factionType == "Alliance Only" and playerFaction == "Alliance") or
                        (factionType == "Horde Only" and playerFaction == "Horde") then
                        local colorHex
                        if specialCategory == "Bodyguard" then
                            local bodyguardRepText = HandleBodyguardRep(factionID)
                            local mountIDsArray = factionMounts[factionID]

                            local mountNames = {}
                            for _, mountID in ipairs(mountIDsArray) do
                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                if mountName then
                                    table.insert(mountNames, mountName)
                                end
                            end

                            local mountsText = ""
                            if #mountNames > 0 and MasterCollectorSV.showMountName then
                                mountsText = "         Rank 20 Mount: " .. table.concat(mountNames, ", ")
                            end

                            factionText = factionText .. MC.goldHex .. bodyguardRepText .. mountsText .. "\n"
                        elseif factionID == 2463 then
                            local friendFactionDetails = C_GossipInfo.GetFriendshipReputation(factionID)
                            local friendName = friendFactionDetails.name
                            local friendReaction = friendFactionDetails.reaction
                            colorHex = GetFriendshipColor(friendReaction)
                            local friendCurrentStanding = friendFactionDetails.standing or 0
                            local friendNextThreshold = friendFactionDetails.nextThreshold
                            local _, achieveName = GetAchievementInfo(14775)
                            local friendMount = C_MountJournal.GetMountInfoByID(2114)

                            factionText = factionText .. MC.goldHex .. "  - " .. friendName .. "|r"

                            if friendReaction == "Exalted" then
                                factionText = factionText .. colorHex .. string.rep(" ", 9) .. friendReaction .. "|r\n"
                                if MasterCollectorSV.showMountName then
                                    factionText = factionText ..
                                        MC.goldHex ..
                                        string.rep(" ", 9) ..
                                        "Required for " ..
                                        achieveName ..
                                        " for Back from Beyond Meta Achievement\r\n" ..
                                        string.rep(" ", 9) .. "Mount: " .. friendMount .. "\n"
                                end
                            else
                                factionText = factionText ..
                                    colorHex ..
                                    string.rep(" ", 9) ..
                                    friendCurrentStanding ..
                                    "/ " .. friendNextThreshold .. string.rep(" ", 9) .. friendReaction .. "|r\n"
                                if MasterCollectorSV.showMountName then
                                    factionText = factionText ..
                                        MC.goldHex ..
                                        string.rep(" ", 9) ..
                                        "Required for " ..
                                        achieveName ..
                                        " for Back from Beyond Meta Achievement|r\n" ..
                                        string.rep(" ", 9) .. "Mount: " .. friendMount .. "\n"
                                end
                            end
                        else
                            local factionDetails = C_Reputation.GetFactionDataByID(factionID)
                            if factionDetails then
                                local name = factionDetails.name
                                local reaction = factionDetails.reaction or 4
                                local currentStanding = factionDetails.currentStanding or 0
                                local nextThreshold = factionDetails.nextReactionThreshold

                                local mountInfo = {}
                                local mountNames = {}
                                local allMountsCollected = true

                                if #mountIDs > 0 then
                                    for _, mountID in ipairs(mountIDs) do
                                        local mName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal
                                            .GetMountInfoByID(mountID)
                                        if mName then
                                            mountInfo[mountID] = mName

                                            if not isCollected then
                                                allMountsCollected = false
                                            end

                                            if not MasterCollectorSV.hideBossesWithMountsObtained then
                                                table.insert(mountNames, mName)
                                            elseif not isCollected then
                                                table.insert(mountNames, mName)
                                            end
                                        end
                                    end
                                end

                                if MasterCollectorSV.hideBossesWithMountsObtained and allMountsCollected then
                                    break
                                end

                                if not MasterCollectorSV.showMountName then
                                    mountNames = {}
                                end

                                factionText = factionText .. MC.goldHex .. "  - " .. name .. "|r"
                                local standingLabel

                                if factionID == 2432 then
                                    standingLabel = venariRepRename[reaction] and venariRepRename[reaction][1] or
                                        "Unknown"
                                elseif factionID == 2472 then
                                    standingLabel = archivistsCodexRepRename[reaction] and
                                        archivistsCodexRepRename[reaction][1] or "Unknown"
                                elseif factionID == 2568 then
                                    standingLabel = glimmerogRepRename[reaction] and glimmerogRepRename[reaction][1] or
                                        "Unknown"
                                elseif factionID == 2553 then
                                    standingLabel = soridormiRepRename[reaction] and soridormiRepRename[reaction][1] or
                                        "Unknown"
                                elseif factionID == 2517 or factionID == 2518 then
                                    standingLabel = blkDragonRepRename[reaction] and blkDragonRepRename[reaction][1] or
                                        "Unknown"
                                elseif factionID == 2544 then
                                    standingLabel = artisansRepRename[reaction] and artisansRepRename[reaction][1] or
                                        "Unknown"
                                elseif factionID == 2550 then
                                    standingLabel = cobaltRepRename[reaction] and cobaltRepRename[reaction][1] or
                                        "Unknown"
                                else
                                    standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or "Unknown"
                                end

                                colorHex = GetReputationColor(reaction)

                                local currentParagonValue, paragonThreshold, _, hasRewardPending = C_Reputation
                                    .GetFactionParagonInfo(factionID)
                                local paragonTextAdded = false
                                local paragonHex = string.format("|cff%02x%02x%02x", 0, 1 * 255, 1 * 255)
                                local paragonRealValue = 0

                                local exaltedFactionText = colorHex .. string.rep(" ", 9) .. standingLabel .. "|r\n"
                                local notExaltedFactionText = colorHex ..
                                    string.rep(" ", 9) ..
                                    standingLabel ..
                                    string.rep(" ", 9) .. currentStanding .. "/ " .. nextThreshold .. "|r\n"

                                local function addParagonLevelText()
                                    if not paragonTextAdded then
                                        if paragonThreshold then
                                            local paragonLevel = math.floor(currentParagonValue / paragonThreshold) -
                                                (hasRewardPending and 1 or 0)
                                            paragonRealValue = tonumber(string.sub(currentParagonValue,
                                                string.len(paragonLevel) + 1))
                                            factionText = factionText ..
                                                paragonHex ..
                                                string.rep(" ", 9) ..
                                                paragonRealValue ..
                                                " / " ..
                                                paragonThreshold ..
                                                " (Paragon Chest Attempts: " .. paragonLevel .. ")|r\n"
                                            paragonTextAdded = true
                                        end
                                    end
                                end

                                if reaction ~= 8 then
                                    factionText = factionText .. notExaltedFactionText
                                else
                                    factionText = factionText .. exaltedFactionText
                                end

                                if factionID == 2165 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 932 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                local cost = C_CurrencyInfo.GetCoinTextureString(5000000000)
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Exalted Mount: " .. mountName .. "|r\n" ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 932 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2432 then
                                    local _, achieveName = GetAchievementInfo(14656)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 2114 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    "Appreciative Required for " ..
                                                    achieveName ..
                                                    " for Back from Beyond Meta Achievement|r\n" ..
                                                    string.rep(" ", 9) .. "Mount: " .. mountName .. "\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 2114 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2472 then
                                    local _, achieveName = GetAchievementInfo(15069)
                                    local currentCataloguedResearch = C_CurrencyInfo.GetCurrencyInfo(1931).quantity
                                    local fileCataloguedResearch = C_CurrencyInfo.GetCurrencyInfo(1931).iconFileID
                                    local iconCataloguedResearch = CreateTextureMarkup(fileCataloguedResearch,
                                        32, 32, 16, 16, 0, 1, 0, 1)

                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 1454 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                if mountID == 2114 then
                                                    factionText = factionText ..
                                                        MC.goldHex ..
                                                        string.rep(" ", 9) ..
                                                        "Tier 6 Required for " .. achieveName ..
                                                        " for Breaking the Chains Meta Achievement|r\n" ..
                                                        string.rep(" ", 9) .. "Mount: " .. mountName .. "\n\n"
                                                else
                                                    factionText = factionText ..
                                                        string.rep(" ", 9) ..
                                                        "Tier 6 Mount: " .. mountName .. "\n" ..
                                                        string.rep(" ", 6) .. MC.goldHex .. "   " ..
                                                        currentCataloguedResearch ..
                                                        " / 5,000 Catalogued Research " ..
                                                        iconCataloguedResearch .. " Required|r\n\n"
                                                end
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1454 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2410 or factionID == 2465 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1375 or mountID == 1361 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                local cost = C_CurrencyInfo.GetCoinTextureString(300000000)
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Exalted Mount: " .. mountName .. "|r\n" ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 1375 and mountID ~= 1361 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2470 then
                                    local _, achieveName = GetAchievementInfo(15035)
                                    local currentStygia = C_CurrencyInfo.GetCurrencyInfo(1767).quantity
                                    local iconStygia = C_CurrencyInfo.GetCurrencyInfo(1767).iconFileID
                                    local iconSizeStygia = CreateTextureMarkup(iconStygia, 32, 32, 16, 16, 0, 1, 0, 1)
                                    local achievementTextAdded = false

                                    local covenantRequirements = {
                                        [1436] = "Kyrian",
                                        [1486] = "Night Fae",
                                        [1491] = "Venthyr",
                                        [1497] = "Necrolord"
                                    }

                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1505 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Revered Mount: " .. mountName .. "\n" ..
                                                    string.rep(" ", 6) .. MC.goldHex .. "   " .. currentStygia ..
                                                    " / 5,000 Stygia " .. iconSizeStygia .. " Required|r\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 1455 and mountID ~= 1505 and mountID ~= 1508 and mountID ~= 2114 then
                                                local covenant = covenantRequirements[mountID] or "Unknown Covenant"
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                if not achievementTextAdded then
                                                    factionText = factionText ..
                                                        MC.goldHex .. string.rep(" ", 9) ..
                                                        "Exalted and " .. achieveName .. " Achievement Required|r\n"
                                                    achievementTextAdded = true
                                                end

                                                factionText = factionText ..
                                                    string.rep(" ", 9) ..
                                                    " - " .. covenant .. " Mount: " .. mountName .. "\n" ..
                                                    string.rep(" ", 9) .. MC.goldHex ..
                                                    "   " .. currentStygia .. " / 1,000 Stygia " .. iconSizeStygia ..
                                                    " Required|r\n"
                                            elseif mountID == 2114 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                factionText = factionText ..
                                                    "\n" .. MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    "Exalted Required for " .. achieveName ..
                                                    " for Breaking the Chains Meta Achievement|r\n" ..
                                                    string.rep(" ", 9) .. "Mount: " .. mountName .. "\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1455 and mountID == 1508 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2478 then
                                    local _, achieveName = GetAchievementInfo(15220)
                                    local fileAnima = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID
                                    local iconAnima = CreateTextureMarkup(fileAnima, 32, 32, 16, 16, 0, 1, 0,
                                        1)

                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1529 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                factionText = factionText ..
                                                    string.rep(" ", 9) .. "Revered Mount: " .. mountName .. "\n" ..
                                                    string.rep(" ", 6) .. MC.goldHex .. "   " ..
                                                    totalAnima .. " / 5,000 Anima " .. iconAnima .. " Required|r\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 1529 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                if mountID == 2114 then
                                                    factionText = factionText ..
                                                        MC.goldHex ..
                                                        string.rep(" ", 9) ..
                                                        "Exalted Required for " .. achieveName ..
                                                        " for Breaking the Chains Meta Achievement|r\n" ..
                                                        string.rep(" ", 9) .. "Mount: " .. mountName .. "\n"
                                                else
                                                    factionText = factionText ..
                                                        string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "\n" ..
                                                        string.rep(" ", 6) .. MC.goldHex .. "   " ..
                                                        totalAnima .. " / 5,000 Anima " .. iconAnima .. " Required|r\n\n"
                                                end
                                            end
                                        end
                                    end
                                elseif factionID == 2400 or factionID == 2373 then
                                    local playerManapearl = C_CurrencyInfo.GetCurrencyInfo(1721).quantity
                                    local fileManapearl = C_CurrencyInfo.GetCurrencyInfo(1721).iconFileID
                                    local iconManapearl = CreateTextureMarkup(fileManapearl, 32, 32, 16, 16, 0, 1, 0, 1)

                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID == 1231 or mountID == 1230 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                factionText = factionText ..
                                                    string.rep(" ", 9) ..
                                                    "Exalted Mount: " .. mountName .. "\n" ..
                                                    MC.goldHex .. string.rep(" ", 9) ..
                                                    playerManapearl ..
                                                    " / 250 Prismatic Manapearl " .. iconManapearl .. " Required|r\n\n"
                                            end
                                        end

                                        for _, mountID in ipairs(mountIDs) do
                                            if mountID ~= 1231 and mountID ~= 1230 then
                                                local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                                addParagonLevelText()
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Paragon Mount: " .. mountName .. "|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2158 or factionID == 2160 or factionID == 2156 or factionID == 2162
                                    or factionID == 2103 or factionID == 2161 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            if mountID == 926 or mountID == 1010 or mountID == 1061 or mountID == 1015
                                                or mountID == 1058 or mountID == 1016 then
                                                local cost = C_CurrencyInfo.GetCoinTextureString(100000000)
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Exalted Mount: " .. mountName .. "|r\n" ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n\n"
                                            else
                                                local cost = C_CurrencyInfo.GetCoinTextureString(900000000)
                                                factionText = factionText .. string.rep(" ", 9) ..
                                                    "Exalted Mount: " .. mountName .. "|r\n" ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 2413 or factionID == 2407 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = C_CurrencyInfo.GetCoinTextureString(300000000)
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) ..
                                                moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 2417 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = C_CurrencyInfo.GetCoinTextureString(240000000)
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) ..
                                                moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 2391 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = C_CurrencyInfo.GetCoinTextureString(5242880000)
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) ..
                                                moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1177 or factionID == 1178 then
                                    local playerTBCommendations = C_CurrencyInfo.GetCurrencyInfo(391).quantity
                                    local fileTBCommendations = C_CurrencyInfo.GetCurrencyInfo(391).iconFileID
                                    local iconTBCommendations = CreateTextureMarkup(fileTBCommendations, 32, 32, 16, 16,
                                        0, 1, 0, 1)
                                    for _, mountID in ipairs(mountIDs) do
                                        local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                        local requiredCommendations = (mountID == 405 or mountID == 406) and 165 or 200

                                        if MasterCollectorSV.showMountName then
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "\n" ..
                                                MC.goldHex .. string.rep(" ", 9) .. playerTBCommendations ..
                                                " / " ..
                                                requiredCommendations ..
                                                " Tol Barad Commendations " .. iconTBCommendations .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1124 or factionID == 1094 then
                                    local playerChampionSeals = C_CurrencyInfo.GetCurrencyInfo(241).quantity
                                    local fileChampionSeals = C_CurrencyInfo.GetCurrencyInfo(241).iconFileID
                                    local iconChampionSeals = CreateTextureMarkup(fileChampionSeals, 32, 32, 16, 16, 0, 1,
                                        0, 1)
                                    for _, mountID in ipairs(mountIDs) do
                                        local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                        local requiredSeals = (mountID == 332 or mountID == 331) and 100 or 150

                                        if MasterCollectorSV.showMountName then
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "\n" ..
                                                MC.goldHex .. string.rep(" ", 9) .. playerChampionSeals ..
                                                " / " ..
                                                requiredSeals ..
                                                " Total Champion Seals " .. iconChampionSeals .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1105 then
                                    if MasterCollectorSV.showMountName then
                                        local dropChanceDenominator = 20
                                        local attempts = GetRarityAttempts("Cracked Egg") or 0
                                        local rarityAttemptsText = ""
                                        local dropChanceText = ""

                                        if MasterCollectorSV.showRarityDetail then
                                            local chance = 1 / dropChanceDenominator
                                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                            rarityAttemptsText = string.format("\n         (Attempts: %d/%s", attempts,
                                                dropChanceDenominator)
                                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                        end

                                        if #mountNames > 0 then
                                            local prefix = string.rep(" ", 9) .. "Revered Mount: "
                                            local formattedMounts = table.concat(mountNames, "\n" .. prefix)
                                            factionText = factionText ..
                                                prefix .. formattedMounts .. rarityAttemptsText .. dropChanceText .. "\n"
                                        end
                                    end
                                elseif factionID == 1849 then
                                    local playerApexisCrystals = C_CurrencyInfo.GetCurrencyInfo(823).quantity
                                    local fileApexisCrystals = C_CurrencyInfo.GetCurrencyInfo(823).iconFileID
                                    local iconApexisCrystals = CreateTextureMarkup(fileApexisCrystals, 32, 32, 16, 16, 0,
                                        1, 0, 1)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9)
                                            .. "Friendly Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9)
                                                .. "Friendly Mount: ") .. "\n" .. MC.goldHex .. string.rep(" ", 9)
                                            .. playerApexisCrystals .. " / 150,000 Apexis Crystals "
                                            .. iconApexisCrystals .. " Required|r\n" or "")
                                elseif factionID == 1119 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = (mountID == 258) and
                                                C_CurrencyInfo.GetCoinTextureString(10000000) or
                                                C_CurrencyInfo.GetCoinTextureString(100000000)

                                            local rank = (mountID == 258) and "Revered Mount" or "Exalted Mount"

                                            factionText = factionText ..
                                                string.rep(" ", 9) .. rank .. ": |r" .. mountName .. "\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 2464 then
                                    local iconCovenantAnima = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID
                                    local iconSize = CreateTextureMarkup(iconCovenantAnima, 32, 32, 16, 16, 0, 1, 0, 1)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9)
                                            .. "Revered Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9)
                                                .. "Revered Mount: ") .. "\n" .. MC.goldHex .. string.rep(" ", 9) .. totalAnima
                                            .. " / 5,000 Anima " .. iconSize .. " Required|r\n\n" or "")
                                elseif factionID == 2568 then
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9)
                                            .. "Professional Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9)
                                                .. "Professional Mount: ") .. "\n" or "")
                                elseif factionID == 2517 or factionID == 2518 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        local _, achieveName = GetAchievementInfo(19466)
                                        local output = ""
                                        for _, mountName in ipairs(mountNames) do
                                            if mountName == "Taivan" then
                                                output = output ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    "True Friend Required for " ..
                                                    achieveName ..
                                                    " for A World Awoken Meta Achievement|r\n         Mount: " ..
                                                    mountName .. "\n"
                                            else
                                                output = output ..
                                                    string.rep(" ", 9) ..
                                                    "True Friend Items Purchasable for Mount: " .. mountName .. "\n"
                                            end
                                        end
                                        factionText = factionText .. output
                                    end
                                elseif factionID == 2553 then
                                    local _, achieveName = GetAchievementInfo(19466)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "\n"
                                            .. MC.goldHex .. string.rep(" ", 9) .. "Legend Required for " .. achieveName
                                            .. " for A World Awoken Meta Achievement|r\n         Mount: " ..
                                            table.concat(mountNames, "\n" .. string.rep(" ", 9) .. MC.goldHex .. string.rep(" ", 9)
                                                .. "Legend Required for " .. achieveName
                                                .. " for A World Awoken Meta Achievement|r\n         Mount: ") .. "\n\n" or "")
                                elseif factionID == 2544 then
                                    local _, achieveName = GetAchievementInfo(19466)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "\n"
                                            .. MC.goldHex .. string.rep(" ", 9) .. "Esteemed Required for " .. achieveName
                                            .. " for A World Awoken Meta Achievement|r\n         Mount: " ..
                                            table.concat(mountNames, "\n" .. string.rep(" ", 9) .. MC.goldHex .. string.rep(" ", 9)
                                                .. "Esteemed Required for " .. achieveName
                                                .. " for A World Awoken Meta Achievement|r\n         Mount: ") .. "\n\n" or "")
                                elseif factionID == 2550 then
                                    local _, achieveName = GetAchievementInfo(19466)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "\n"
                                            .. MC.goldHex .. string.rep(" ", 9) .. "Maximum Required for " .. achieveName
                                            .. " for A World Awoken Meta Achievement|r\n         Mount: " ..
                                            table.concat(mountNames, "\n" .. string.rep(" ", 9) .. MC.goldHex .. string.rep(" ", 9)
                                                .. "Maximum Required for " .. achieveName
                                                .. " for A World Awoken Meta Achievement|r\n         Mount: ") .. "\n\n" or "")
                                elseif factionID == 2526 then
                                    local _, achieveName = GetAchievementInfo(19466)
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "\n"
                                            .. MC.goldHex .. string.rep(" ", 9) .. "Exalted Required for " .. achieveName
                                            .. " for A World Awoken Meta Achievement|r\n         Mount: " ..
                                            table.concat(mountNames, "\n" .. string.rep(" ", 9) .. MC.goldHex .. string.rep(" ", 9)
                                                .. "Exalted Required for " .. achieveName
                                                .. " for A World Awoken Meta Achievement|r\n         Mount: ") .. "\n\n" or "")
                                elseif factionID == 1031 or factionID == 1015 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(2000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 978 or factionID == 941 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = (mountID == 153 or mountID == 154 or mountID == 155 or mountID == 156)
                                                and C_CurrencyInfo.GetCoinTextureString(700000)
                                                or C_CurrencyInfo.GetCoinTextureString(1000000)

                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 942 or factionID == 1091 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(20000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1173 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(1000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1375 or factionID == 1376 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(20000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "|r\n"

                                            if mountID == 526 or mountID == 527 then
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            end
                                        end
                                    end
                                elseif factionID == 1387 or factionID == 1388 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(30000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1302 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(10000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1341 or factionID == 1337 or factionID == 2170 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(100000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1270 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local costs = {
                                                [505] = C_CurrencyInfo.GetCoinTextureString(15000000),
                                                [506] = C_CurrencyInfo.GetCoinTextureString(5000000),
                                                [507] = C_CurrencyInfo.GetCoinTextureString(20000000)
                                            }

                                            local cost = costs[mountID] or nil
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "|r\n"

                                            if mountID == 471 then
                                                factionText = factionText ..
                                                    string.rep(" ", 9) ..
                                                    MC.goldHex .. "Requires Exalted with Order of the Cloud Serpent|r\n"
                                            end

                                            if cost then
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            else
                                                factionText = factionText .. "\n"
                                            end
                                        end
                                    end
                                elseif factionID == 1272 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local costs = {
                                                [508] = C_CurrencyInfo.GetCoinTextureString(5000000),
                                                [510] = C_CurrencyInfo.GetCoinTextureString(32500000),
                                                [511] = C_CurrencyInfo.GetCoinTextureString(15000000)
                                            }

                                            local cost = costs[mountID] or nil
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "|r\n"

                                            if cost then
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            else
                                                factionText = factionText .. "\n"
                                            end
                                        end
                                    end
                                elseif factionID == 1271 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local cost = (mountID ~= 471) and
                                                C_CurrencyInfo.GetCoinTextureString(25500000) or nil

                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "|r\n"

                                            if mountID == 471 then
                                                factionText = factionText ..
                                                    string.rep(" ", 9) ..
                                                    MC.goldHex .. "Requires Exalted with Order of the Cloud Serpent|r\n"
                                            end

                                            if cost then
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            else
                                                factionText = factionText .. "\n"
                                            end
                                        end
                                    end
                                elseif factionID == 1269 then
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID)
                                            local costs = {
                                                [479] = C_CurrencyInfo.GetCoinTextureString(5000000),
                                                [480] = C_CurrencyInfo.GetCoinTextureString(25000000),
                                                [481] = C_CurrencyInfo.GetCoinTextureString(15000000)
                                            }

                                            local cost = costs[mountID] or nil
                                            factionText = factionText ..
                                                string.rep(" ", 9) .. "Exalted Mount: " .. mountName .. "|r\n"

                                            if cost then
                                                factionText = factionText ..
                                                    MC.goldHex ..
                                                    string.rep(" ", 9) ..
                                                    moneyString .. " / " .. cost .. " Required|r\n"
                                            else
                                                factionText = factionText .. "\n"
                                            end
                                        end
                                    end
                                elseif factionID == 1848 or factionID == 1847 then
                                    local cost = C_CurrencyInfo.GetCoinTextureString(25000000)
                                    if MasterCollectorSV.showMountName and #mountNames > 0 then
                                        for _, mountName in ipairs(mountNames) do
                                            factionText = factionText .. string.rep(" ", 9) ..
                                                "Exalted Mount: " .. mountName .. "|r\n" ..
                                                MC.goldHex ..
                                                string.rep(" ", 9) .. moneyString .. " / " .. cost .. " Required|r\n"
                                        end
                                    end
                                elseif factionID == 1828 or factionID == 1883 or factionID == 1900 or factionID == 1859
                                    or factionID == 1948 then
                                    addParagonLevelText()
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) ..
                                            "Paragon Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) ..
                                                "Paragon Mount: ") .. "\n" or "")
                                elseif paragonThreshold then
                                    addParagonLevelText()
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) ..
                                            "Paragon Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) ..
                                                "Paragon Mount: ") .. "\n" or "")
                                else
                                    factionText = factionText ..
                                        (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) ..
                                            "Exalted Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) ..
                                                "Exalted Mount: ") .. "\n" or "")
                                end
                            end
                        end
                    end
                end
            end
        end
        if factionText ~= "" then
            displayText = displayText .. MC.goldHex .. expansion .. "|r\n"
            displayText = displayText .. factionText .. "\n"
        end
    end

    if displayText == "" then
        displayText = MC.goldHex .. "We are all done here.... FOR NOW!|r"
    end

    if MC.mainFrame and MC.mainFrame.text then
        MC.mainFrame.text:SetText(displayText)
    end
end
