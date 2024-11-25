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
            {1031}, -- Sha'tari Skyguard
            {1015}, -- Netherwing
            {978, "Alliance Only"}, -- Kurenai
            {941, "Horde Only"}, -- The Mag'har
            {942}, -- Cenarion Expedition
        },
        ["Wrath Of The Lich King"] = {
            {1119}, -- The Sons of Hodir
            {1091}, -- The Wyrmrest Accord
            {1105}, -- The Oracles
        },
        ["Cataclysm"] = {
            {1177, "Alliance Only"}, -- Baradin's Wardens
            {1178, "Horde Only"}, -- Hellscream's Reach
            {1173}, -- Ramkahen
        },
        ["Mists of Pandaria"] = {
            {1375, "Horde Only"}, -- Dominance Offensive
            {1376, "Alliance Only"}, -- Operation: Shieldwall
            {1387, "Alliance Only"}, -- Kirin Tor Offensive
            {1388, "Horde Only"}, -- Sunreaver Onslaught
            {1302}, -- The Anglers
            {1341}, -- The August Celestials
            {1337}, -- The Klaxxi
            {1270}, -- Shado-Pan
            {1272}, -- The Tillers
            {1271}, -- Order of the Cloud Serpent
            {1269}, -- Golden Lotus
        },
        ["Warlords of Draenor"] = {
            {1848, "Horde Only"}, -- Vol'jin's Headhunters
            {1847, "Alliance Only"}, -- Hand of the Prophet
            {1849}, -- Order of the Awakened
        },
        ["Legion"] = {
            {1828}, -- Highmountain Tribe
            {1883}, -- Dreamweavers
            {1900}, -- Court of Farondis
            {1859}, -- The Nightfallen
            {1948}, -- Valarjar
            {2170}, -- Argussian Reach
            {2165}, -- Army of the Light
        },
        ["Battle for Azeroth"] = {
            {2158, "Horde Only"}, -- Voldunai
            {2160, "Alliance Only"}, -- Proudmoore Admiralty
            {2156, "Horde Only"}, -- Talanji's Expedition
            {2162, "Alliance Only"}, -- Storm's Wake
            {2103, "Horde Only"}, -- Zandalari Empire
            {2161, "Alliance Only"}, -- Order of Embers
            {2400, "Alliance Only"}, -- Ankoan
            {2375, "Alliance Only", "Bodyguard"}, -- Akana (Bodyguard Naz Rep)
            {2389, "Horde Only", "Bodyguard"}, -- Neri (Bodyguard Naz Rep)
            {2373, "Horde Only"}, -- Unshackled
            {2391}, -- Rustbolt Resistance
            {2417}, -- Uldum Accord
        },
        ["Shadowlands"] = {
            {2410}, -- The Undying Army
            {2465}, -- The Wild Hunt
            {2413}, -- Court of Harvesters
            {2407}, -- The Ascended
            {2464}, -- Court of Night
            {2470}, -- Death's Advance
            {2472}, -- The Archivist's Codex
            {2432}, -- Ve'nari
            {2463}, -- Marasmius
            {2478}, -- The Enlightened
        },
        ["Dragonflight"] = {
            {2503}, -- Maruuk Centaur
            {2510}, -- Valdrakken Accord
            {2507}, -- Dragonscale Expedition
            {2511}, -- Iskaara Tuskarr
        },
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
        "Dragonflight"
    }

    local factionMounts = {
        [1031] = {176, 177, 178, 179, 180},
        [1015] = {186, 187, 188, 189, 190, 191},
        [978] = {153, 154, 155, 156, 170, 172, 173, 174},
        [941] = {153, 154, 155, 156, 170, 172, 173, 174},
        [942] = {203},
        [1119] = {258, 288}, -- 1st at Revered, 2nd Exalted
        [1091] = {249},
        [1105] = {278}, -- Revered - keep rolling eggs
        [1177] = {394, 405}, -- first mount needs 200 commendations, 2nd needs 165
        [1178] = {394, 406}, -- first mount needs 200 commendations, 2nd needs 165
        [1173] = {398, 399},
        [1375] = {527, 529},
        [1376] = {526, 528},
        [1387] = {545},
        [1388] = {546},
        [1302] = {449},
        [1341] = {504},
        [1337] = {463},
        [1270] = {505, 506, 507, 471},
        [1272] = {508, 510, 511},
        [1271] = {448, 464, 465},
        [1269] = {479, 480, 481},
        [1848] = {768},
        [1847] = {768},
        [1849] = {753}, -- Friendly & 150k apexis crystals
        [1828] = {941},
        [1883] = {942},
        [1900] = {943},
        [1859] = {905},
        [1948] = {944},
        [2170] = {939, 964, 965, 966, 967, 968}, -- mounts dont need paragon
        [2165] = {983, 984, 985, 932}, --mount id 932 does not need paragon
        [2158] = {926, 1060}, -- mounts dont need paragon
        [2160] = {1010, 1064}, -- mounts dont need paragon
        [2156] = {1061, 1059}, -- mounts dont need paragon
        [2162] = {1015, 1063}, -- mounts dont need paragon
        [2103] = {958, 1058}, -- mounts dont need paragon
        [2161] = {1016, 1062}, -- mounts dont need paragon
        [2400] = {1230, 1237}, -- mounts dont need paragon
        [2375] = {1255}, -- mounts dont need exalted (rank 20)
        [2389] = {1256}, -- mounts dont need exalted (rank 20)
        [2373] = {1231, 1237}, -- mounts dont need paragon
        [2391] = {1254},
        [2417] = {1318},
        [2410] = {1350, 1375},
        [2465] = {1361, 1428},
        [2413] = {1421},
        [2407] = {1425},
        [2464] = {1420},
        [2470] = {1436, 1455, 1486, 1491, 1497, 1505, 1508, 2114},
        [2472] = {1450, 1454, 2114},
        [2432] = {1501, 2114},
        [2463] = {2114},
        [2478] = {1522, 1529, 2114},
    }

    local function GetReputationColor(reaction)
        local colors = {
            [8] = {r = 0, g = 1, b = 0},        -- Exalted: green
            [7] = {r = 0.6, g = 1, b = 0.6},    -- Revered: mint green
            [6] = {r = 0, g = 0.8, b = 0},      -- Honored: emerald green
            [5] = {r = 0, g = 1, b = 0},        -- Friendly: neon green
            [4] = {r = 1, g = 1, b = 0},        -- Neutral: yellow
            [3] = {r = 1, g = 0.65, b = 0},     -- Unfriendly: orange
            [2] = {r = 1, g = 0.6, b = 0.6},    -- Hostile: light red
            [1] = {r = 1, g = 0, b = 0}         -- Hated: red
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
            ["Exalted"] = {r = 0, g = 1, b = 0},        -- Exalted: green
            ["Revered"] = {r = 0.6, g = 1, b = 0.6},    -- Revered: mint green
            ["Honored"] = {r = 0, g = 0.8, b = 0},      -- Honored: emerald green
            ["Friendly"] = {r = 0, g = 1, b = 0},        -- Friendly: neon green
            ["Neutral"] = {r = 1, g = 1, b = 0},        -- Neutral: yellow
            ["Unfriendly"] = {r = 1, g = 0.65, b = 0},     -- Unfriendly: orange
            ["Hostile"] = {r = 1, g = 0.6, b = 0.6},    -- Hostile: light red
            ["Hated"] = {r = 1, g = 0, b = 0}         -- Hated: red
        }
        
        local color = colors[reaction]
        if color then
            return string.format("|cff%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
        else
            return "|cffffffff" -- Default color (white) if reaction is not in the list
        end
    end

    local archivistsCodexRepRename = {
        [7] = {"Tier 6"},
        [6] = {"Tier 5"},
        [5] = {"Tier 4"},
        [4] = {"Tier 3"},
        [3] = {"Tier 2"},
        [2] = {"Tier 1"}
    }

    local venariRepRename = {
        [8] = {"Appreciative"},
        [7] = {"Cordial"},
        [6] = {"Ambivalent"},
        [5] = {"Tentative"},
        [4] = {"Apprehensive"},
        [3] = {"Dubious"}
    }

    local covRenownMounts = {
        [1] = { {1398, 23}, {1399, 39}, {1492, 45}, {1494, 70} }, -- Kyrian
        [2] = { {1384, 23}, {1388, 39}, {1490, 45}, {1489, 70} }, -- Venthyr
        [3] = { {1354, 23}, {1357, 39}, {1484, 45}, {1485, 70} }, -- Night Fae
        [4] = { {1365, 23}, {1369, 39}, {1495, 45}, {1496, 70} }  -- Necrolord
    }

    local function HandleBodyguardRep(factionID)
        local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendshipInfo and friendshipInfo.standing and friendshipInfo.maxRep then
            local name = friendshipInfo.name
            local standingLabel = friendshipInfo.reaction or "Unknown"
            local currentStanding = friendshipInfo.standing or 0
            local nextThreshold = friendshipInfo.maxRep
            local colorHex = GetReputationColor()

            return string.format("  - %s|r%s         %s   %d/ %d|r\n", name, colorHex, standingLabel, currentStanding, nextThreshold)
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

    function MC.UpdateCovenantDisplay()
        local characterKey = GetCharacterKey()
        local activeCovenantID = C_Covenants.GetActiveCovenantID()
            
        if not activeCovenantID or activeCovenantID == 0 then
            displayText = "|cffff0000Error: Unable to Load Covenant, Select a Covenant and/or Reload UI to get Covenant details|r\n\n"
            return
        end
    
        local currentRenownLevel = C_CovenantSanctumUI.GetRenownLevel()
    
        if not MasterCollectorSV[characterKey] then
            MasterCollectorSV[characterKey] = { covenants = {} }
        elseif not MasterCollectorSV[characterKey].covenants then
            MasterCollectorSV[characterKey].covenants = {}
        end
    
        MasterCollectorSV[characterKey].covenants[activeCovenantID] = {
            renownLevel = currentRenownLevel,
            maxRenownLevel = 80
        }
    
        MC.covenantFactionMap = {
            [1] = "Kyrian",
            [2] = "Venthyr",
            [3] = "Night Fae",
            [4] = "Necrolord",
        }

        local covenantText = string.format(
            "%sCovenants \n   - %s|r: Renown %d / %d  (Current Covenant)\n",
            MC.goldHex,
            MC.covenantFactionMap[activeCovenantID] or "Unknown Covenant",
            MasterCollectorSV[characterKey].covenants[activeCovenantID].renownLevel,
            MasterCollectorSV[characterKey].covenants[activeCovenantID].maxRenownLevel
        )

        local function GetCovenantMountsText(covenantID)
            local mountsText = MC.goldHex .. "      Renown Mounts:|r\n"
            for _, mountData in ipairs(covRenownMounts[covenantID] or {}) do
                local mountID, requiredRenownLevel = mountData[1], mountData[2]
                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                
                if not isCollected and MasterCollectorSV.hideBossesWithMountsObtained then
                    mountsText = mountsText .. string.format("         - %s (Requires Renown %d)\n", mountName, requiredRenownLevel)
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    mountsText = mountsText .. string.format("         - %s (Requires Renown %d)\n", mountName, requiredRenownLevel)
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
                    local otherCovenantData = MasterCollectorSV[characterKey].covenants[covenantID] or { renownLevel = 0, maxRenownLevel = 0 }
                    if otherCovenantData.renownLevel == 0 then
                        covenantText = covenantText .. string.format(
                            "%s   - %s|r: Switch Covenants to get Covenant Details\n",
                            MC.goldHex,
                            covenantName
                        )
                    else
                        covenantText = covenantText .. string.format(
                            "%s   - %s|r: Renown %d / %d\n",
                            MC.goldHex,
                            covenantName,
                            otherCovenantData.renownLevel,
                            otherCovenantData.maxRenownLevel
                        )
                        
                        if MasterCollectorSV.showMountName then
                            covenantText = covenantText .. GetCovenantMountsText(covenantID) .. "\n"
                        end
                    end
                end
            end

            local _, achieveName, _, achieved = GetAchievementInfo(15646)
            if not achieved and MasterCollectorSV.hideBossesWithMountsObtained then
                displayText = displayText .. covenantText .. "\n" .. MC.goldHex .. "All Covenants Required at Level 80 for " .. achieveName .. " for Back from Beyond Meta Achievement|r\n\n"
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                displayText = displayText .. covenantText .. "\n" .. MC.goldHex .. "All Covenants Required at Level 80 for " .. achieveName .. " for Back from Beyond Meta Achievement|r\n\n"
            end
        end
    end

    if MC.UpdateCovenantDisplay() ~= nil then
        MC.UpdateCovenantDisplay()
    end

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
        (expansion == "Shadowlands" and not MasterCollectorSV.showSLReps) then
            shouldProcessExpansion = false
        end

        if shouldProcessExpansion then
            for _, factionData in ipairs(factions) do
                local factionID, factionType, specialCategory = unpack(factionData)
                local mountIDs = factionMounts[factionID]

                if expansion == "Dragonflight" then
                    local renownLevel = C_MajorFactions.GetCurrentRenownLevel(factionID)
                    if renownLevel then
                        local factionName = C_Reputation.GetFactionDataByID(factionID).name
                        if MasterCollectorSV.showDFRenownReps then
                            factionText = factionText .. string.format(
                                "  - %s%s|r: Renown %d \n",
                                MC.goldHex,
                                factionName,
                                renownLevel
                            )
                        else
                            break
                        end
                    end
                else
                    if not factionType or (factionType == "Alliance Only" and playerFaction == "Alliance") or (factionType == "Horde Only" and playerFaction == "Horde") then
                        local colorHex
                        if specialCategory == "Bodyguard" then
                            local bodyguardRepText = HandleBodyguardRep(factionID)
                            local mountIDsArray = factionMounts[factionID]
                            
                            local mountNames = {}
                            for _, mountID in ipairs(mountIDsArray) do
                                local mountName, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
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
                                    factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Required for "  .. achieveName .. " for Back from Beyond Meta Achievement\r\n" .. string.rep(" ", 9) .. "Mount: " .. friendMount.. "\n"
                                end
                            else
                                factionText = factionText .. colorHex .. string.rep(" ", 9) .. friendCurrentStanding .. "/ " .. friendNextThreshold .. string.rep(" ", 9) .. friendReaction .. "|r\n"
                                if MasterCollectorSV.showMountName then
                                    factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Required for "  .. achieveName .. " for Back from Beyond Meta Achievement|r\n" .. string.rep(" ", 9) .. "Mount: " .. friendMount.. "\n"
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
                                        local mName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
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
                                    standingLabel = venariRepRename[reaction] and venariRepRename[reaction][1] or "Unknown"
                                elseif factionID == 2472 then
                                    standingLabel = archivistsCodexRepRename[reaction] and archivistsCodexRepRename[reaction][1] or "Unknown"
                                else
                                    standingLabel = _G["FACTION_STANDING_LABEL" .. reaction] or "Unknown"
                                end

                                colorHex = GetReputationColor(reaction)

                                local currentParagonValue, paragonThreshold, _, hasRewardPending = C_Reputation.GetFactionParagonInfo(factionID)
                                local paragonTextAdded = false
                                local paragonHex = string.format("|cff%02x%02x%02x", 0, 1 * 255, 1 * 255)
                                local paragonRealValue = 0

                                local exaltedFactionText = colorHex .. string.rep(" ", 9) .. standingLabel .. "|r\n"
                                local notExaltedFactionText = colorHex ..string.rep(" ", 9) .. standingLabel ..string.rep(" ", 9) .. currentStanding .. "/ " .. nextThreshold .. "|r\n"

                                local function addParagonLevelText()
                                    if not paragonTextAdded then
                                        if paragonThreshold then
                                            local paragonLevel = math.floor(currentParagonValue / paragonThreshold) - (hasRewardPending and 1 or 0)
                                            paragonRealValue = tonumber(string.sub(currentParagonValue, string.len(paragonLevel) + 1))
                                            factionText = factionText .. paragonHex .. string.rep(" ", 9) .. paragonRealValue .. " / " .. paragonThreshold .. " (Paragon Chest Attempts: " .. paragonLevel .. ")|r\n"
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
                                    local exaltedMountID = 932
                                    local paragonMountIDs = {983, 984, 985}

                                    if tableContains(mountIDs, exaltedMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(exaltedMountID)) then
                                        local exaltedMountName = mountInfo[exaltedMountID]
                                        if exaltedMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. string.rep(" ", 9) .. "Exalted Mount: " .. exaltedMountName .. "|r\n" .. MC.goldHex .. string.rep(" ", 9) .. "(Mount can be purchased if you have the gold!)|r\n\n"
                                        end
                                    end

                                    addParagonLevelText()

                                    for _, mountID in ipairs(paragonMountIDs) do
                                        if tableContains(mountIDs, mountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(mountID)) then
                                            local paragonMountName = mountInfo[mountID]
                                            if paragonMountName then
                                                if MasterCollectorSV.showMountName then
                                                    factionText = factionText .. string.rep(" ", 9) .. "Paragon Mount: " .. paragonMountName .. "|r\n"
                                                end
                                            end
                                        end
                                    end

                                elseif factionID == 2432 then
                                    local exaltedMountID = 2114
                                    local paragonMountID = 1501
                                    local _, achieveName = GetAchievementInfo(14656)

                                    if tableContains(mountIDs, exaltedMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(exaltedMountID)) then
                                        local exaltedMountName = mountInfo[exaltedMountID]
                                        if exaltedMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Appreciative Required for "  .. achieveName .. " for Back from Beyond Meta Achievement|r\n" .. string.rep(" ", 9) .. "Mount: " .. exaltedMountName .. "\n\n"
                                        end
                                    end

                                    addParagonLevelText()

                                    if tableContains(mountIDs, paragonMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(paragonMountID)) then
                                        local paragonMountName = mountInfo[paragonMountID]
                                        if paragonMountName then
                                            if MasterCollectorSV.showMountName then
                                                factionText = factionText .. string.rep(" ", 9) .. "Paragon Mount: " .. paragonMountName .. "\n"
                                            end
                                        end
                                    end

                                elseif factionID == 2472 then
                                    local exaltedMountIDs = {1450, 2114}
                                    local paragonMountID = 1454
                                    local _, achieveName = GetAchievementInfo(15069)

                                    for _, mountID in ipairs(exaltedMountIDs) do
                                        if tableContains(mountIDs, mountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(mountID)) then
                                            local exaltedMountName = mountInfo[mountID]
                                            if exaltedMountName and MasterCollectorSV.showMountName then
                                                if mountID == 2114 then
                                                    factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Tier 6 Required for "  .. achieveName .. " for Breaking the Chains Meta Achievement|r\n" .. string.rep(" ", 9) .. "Mount: " .. exaltedMountName .. "\n\n"
                                                else
                                                    factionText = factionText .. string.rep(" ", 9) .. "Tier 6 Mount: " .. exaltedMountName .. "\n\n"
                                                end
                                            end
                                        end
                                    end

                                    addParagonLevelText()

                                    if tableContains(mountIDs, paragonMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(paragonMountID)) then
                                        local paragonMountName = mountInfo[paragonMountID]
                                        if paragonMountName then
                                            if MasterCollectorSV.showMountName then
                                                factionText = factionText .. string.rep(" ", 9) .. "Paragon Mount: " .. paragonMountName .. "\n"
                                            end
                                        end
                                    end

                                elseif factionID == 2410 then
                                    local exaltedMountID = 1375
                                    local paragonMountID = 1350

                                    if tableContains(mountIDs, exaltedMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(exaltedMountID)) then
                                        local exaltedMountName = mountInfo[exaltedMountID]
                                        if exaltedMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. string.rep(" ", 9) .. "Exalted Mount: " .. exaltedMountName .. "\n"
                                        end
                                    end

                                    addParagonLevelText()

                                    if tableContains(mountIDs, paragonMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(paragonMountID)) then
                                        local paragonMountName = mountInfo[paragonMountID]
                                        if paragonMountName then
                                            if MasterCollectorSV.showMountName then
                                                factionText = factionText .. string.rep(" ", 9) .. "Paragon Mount: " .. paragonMountName .. "\n"
                                            end
                                        end
                                    end

                                elseif factionID == 2465 then
                                    local exaltedMountID = 1361
                                    local paragonMountID = 1428

                                    if tableContains(mountIDs, exaltedMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(exaltedMountID)) then
                                        local exaltedMountName = mountInfo[exaltedMountID]
                                        if exaltedMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. string.rep(" ", 9) .. "Exalted Mount: " .. exaltedMountName .. "\n"
                                        end
                                    end

                                    addParagonLevelText()

                                    if tableContains(mountIDs, paragonMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(paragonMountID)) then
                                        local paragonMountName = mountInfo[paragonMountID]
                                        if paragonMountName then
                                            if MasterCollectorSV.showMountName then
                                                factionText = factionText .. string.rep(" ", 9) .. "Paragon Mount: " .. paragonMountName .. "\n"
                                            end
                                        end
                                    end

                                elseif factionID == 2470 then
                                    local reveredMountID = 1505
                                    local exaltedMountIDs = {1436, 1486, 1491, 1497, 2114}
                                    local paragonMountIDs = {1455, 1508}
                                    local _, achieveName = GetAchievementInfo(15035)

                                    local covenantRequirements = {
                                        [1436] = "Kyrian",
                                        [1486] = "Night Fae",
                                        [1491] = "Venthyr",
                                        [1497] = "Necrolord"
                                    }

                                    if tableContains(mountIDs, reveredMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(reveredMountID)) then
                                        local reveredMountName = mountInfo[reveredMountID]
                                        if reveredMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. string.rep(" ", 9) .. "Revered Mount: " .. reveredMountName .. "\n\n"
                                        end
                                    end

                                    local achievementTextAdded = false

                                    for _, mountID in ipairs(exaltedMountIDs) do
                                        if tableContains(mountIDs, mountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(mountID)) then
                                            local exaltedMountName = mountInfo[mountID]
                                            if exaltedMountName and MasterCollectorSV.showMountName then
                                                if not achievementTextAdded and mountID ~= 2114 then
                                                    factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Exalted and " .. achieveName .. " Achievement Required|r\n"
                                                    achievementTextAdded = true
                                                end

                                                if mountID ~= 2114 then
                                                    local covenant = covenantRequirements[mountID] or "Unknown Covenant"
                                                    factionText = factionText .. string.rep(" ", 9) .. " - " .. covenant .. " Mount: " .. exaltedMountName .. "\n"
                                                else
                                                    factionText = factionText .. "\n" .. MC.goldHex .. string.rep(" ", 9) .. "Exalted Required for "  .. achieveName .. " for Breaking the Chains Meta Achievement|r\n" .. string.rep(" ", 9) .. "Mount: " .. exaltedMountName .. "\n\n"
                                                end
                                            end
                                        end
                                    end

                                    addParagonLevelText()

                                    for _, mountID in ipairs(paragonMountIDs) do
                                        if tableContains(mountIDs, mountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(mountID)) then
                                            local paragonMountName = mountInfo[mountID]
                                            if paragonMountName then
                                                if MasterCollectorSV.showMountName then
                                                    factionText = factionText .. string.rep(" ", 9) .. " - Paragon Mount: " .. paragonMountName .. "|r\n"
                                                end
                                            end
                                        end
                                    end

                                elseif factionID == 2478 then
                                    local _, achieveName = GetAchievementInfo(15220)
                                    local reveredMountID = 1529
                                    local exaltedMountIDs = {1522, 2114}

                                    if tableContains(mountIDs, reveredMountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(reveredMountID)) then
                                        local reveredMountName = mountInfo[reveredMountID]
                                        if reveredMountName and MasterCollectorSV.showMountName then
                                            factionText = factionText .. string.rep(" ", 9) .. "Revered Mount: " .. reveredMountName .. "\n\n"
                                        end
                                    end

                                    for _, mountID in ipairs(exaltedMountIDs) do
                                        if tableContains(mountIDs, mountID) and not (MasterCollectorSV.hideBossesWithMountsObtained and C_MountJournal.GetMountInfoByID(mountID)) then
                                            local exaltedMountName = mountInfo[mountID]
                                            if exaltedMountName and MasterCollectorSV.showMountName then
                                                if mountID == 2114 then
                                                    factionText = factionText .. MC.goldHex .. string.rep(" ", 9) .. "Exalted Required for "  .. achieveName .. " for Breaking the Chains Meta Achievement|r\n" .. string.rep(" ", 9) .. "Mount: " .. exaltedMountName .. "\n"
                                                else
                                                    factionText = factionText .. string.rep(" ", 9) .. "Exalted Mount: " .. exaltedMountName .. "\n\n"
                                                end
                                            end
                                        end
                                    end

                                elseif factionID == 2170 or factionID == 2158 or factionID == 2160 or factionID == 2156 or factionID == 2162 or factionID == 2103 or factionID == 2161 or factionID == 2400 or factionID == 2373 or factionID == 2413 or factionID == 2407 then
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Exalted Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Exalted Mount: ") .. "\n" or "")

                                elseif factionID == 1177 or factionID == 1178 then
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Exalted Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Exalted Mount: ") .. "\n" .. MC.goldHex .. string.rep(" ", 9) .. "(Requires 365 Total Commendations)|r\n" or "")

                                elseif factionID == 1105 then
                                    if MasterCollectorSV.showMountName then
                                        local dropChanceDenominator = 20
                                        local attempts = GetRarityAttempts("Cracked Egg") or 0
                                        local rarityAttemptsText = ""
                                        local dropChanceText = ""

                                        if MasterCollectorSV.showRarityDetail then
                                            local chance = 1 / dropChanceDenominator
                                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                        end

                                        factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Revered Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Revered Mount: ".. rarityAttemptsText .. dropChanceText) or "")
                                    end
                                elseif factionID == 1849 then
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Friendly Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Friendly Mount: ") .. "\n" .. MC.goldHex .. string.rep(" ", 9) .. "(Requires 150k Apexis Crystals)|r\n" or "")
                                elseif factionID == 1119 then
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Revered Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Exalted Mount: ") .. "\n" or "")
                                elseif factionID == 2464 then
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Revered Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Revered Mount: ") .. "\n" or "")
                                elseif paragonThreshold then
                                    addParagonLevelText()
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Paragon Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Paragon Mount: ") .. "\n" or "")
                                else
                                    factionText = factionText .. (MasterCollectorSV.showMountName and #mountNames > 0 and string.rep(" ", 9) .. "Exalted Mount: " .. table.concat(mountNames, "\n" .. string.rep(" ", 9) .. "Exalted Mount: ") .. "\n" or "")
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