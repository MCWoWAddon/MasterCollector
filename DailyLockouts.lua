function MC.dailiesDisplay()
    if MC.currentTab ~= "Daily\nLockouts" then
        return
    end

    MC.InitializeColors()

    local fontSize = MasterCollectorSV.fontSize

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont(font, fontSize, flags)
    end

    local lockouts = {
        ["Shadowlands Dungeons"] = {
            [1182] = { -- The Necrotic Wake
                {2396, {1406}, 23,"Marrowfang's Reins", 100} -- Nalthor the Rimebinder (Mythic)
            },
        },
        ["Burning Crusade Dungeons"] = {
            [252] = { -- Sethekk Halls
                {542, {185}, 2, "Reins of the Raven Lord", 67} -- Anzu (Heroic)
            },
            [249] = { -- Magister's Terrace
                {533, {213}, 2, "Swift White Hawkstrider", 33} -- 	Kael'thas Sunstrider (Heroic)
            }
        },
        ["Wrath of Lich King Dungeons"] = {
            [286] = { -- Utgarde Pinnacle
                {643, {264}, 2, "Reins of the Blue Proto-Drake", 77} -- Skadi the Ruthless (Heroic)
            }
        },
        ["Cataclysm Dungeons"] = {
            [76] = { -- Zul'Gurub
                {181, {411}, 2, "Swift Zulian Panther", 100}, -- High Priestess Kilnara (Heroic)
                {176, {410}, 2, "Armored Razzashi Raptor", 100} -- Bloodlord Mandokir (Heroic)
            }
        }
    }
    
    local rares = {
        ["WoD Tanaan Jungle Rares"] = {
            {{39287, 39288, 39289, 39290}, {643}, "Armored Razorback", 30, "Deathtalon/Terrorfist/Doomroller/Vengeance"},
            {{39287, 39288, 39289, 39290}, {622}, "Warsong Direfang", 30, "Deathtalon/Terrorfist/Doomroller/Vengeance"},
            {{39287, 39288, 39289, 39290}, {611}, "Tundra Icehoof", 30, "Deathtalon/Terrorfist/Doomroller/Vengeance"}
        },          
        ["Legion Argus Rares"] = {
            {{48705}, {973}, "Lambent Mana Ray", 30, "Venomtail Skyfin"},
            {{48821}, {955}, "Vile Fiend", 30, "Houndmaster Kerrax"},
            {{49183}, {979}, "Crimson Slavermaw", 30, "Blistermaw"},
            {{48810,48809}, {981}, "Biletooth Gnasher", 30, "Vrax'thul/Puscilla"},
            {{48721}, {980}, "Acid Belcher", 30, "Skreeg"},
            {{48695}, {970}, "Maddened Chaosrunner", 30, "Wrangler Kravos"},
            {{48712, 48667, 48812}, {974}, "Fel-Spotted Egg", 16, "Sabuul/Naroua/Varga"},
            {{48712, 48667, 48812}, {975}, "Fel-Spotted Egg", 16, "Sabuul/Naroua/Varga"},
            {{48712, 48667, 48812}, {976}, "Fel-Spotted Egg", 16, "Sabuul/Naroua/Varga"},
            {{48712, 48667, 48812}, {906}, "Fel-Spotted Egg", 16, "Sabuul/Naroua/Varga"}
        },
        ["BfA Arathi Highlands Rares"] = {
            {{53091,53517}, {1185}, "Witherbark Direwing", 33, "Nimar the Slayer"},
            {{53014,53518}, {1182}, "Lil' Donkey", 33, "Overseer Krix"},
            {{53022,53526}, {1183}, "Skullripper", 33, "Skullripper"},
            {{53083,53504}, {1180}, "Swift Albino Raptor", 33, "Beastrider Kama"},
            {{53085}, {1174}, "Highland Mustang", 33, "Doomrider Helgrim", "Alliance Only",},
            {{53088}, {1173}, "Broken Highland Mustang", 33, "Knight-Captain Aldrin", "Horde Only"}
        },
        ["BfA Darkshore Rares"] = {
            {{54695,54696}, {1200}, "Ashenvale Chimaera", 20, "Alash'anir"},
            {{54883}, {1199}, "Caged Bear", 20, "Agathe Wyrmwood", "Alliance Only"},
            {{54890}, {1199}, "Blackpaw", 20, "Blackpaw", "Horde Only"},
            {{54886}, {1205}, "Captured Kaldorei Nightsaber", 20, "Croz Bloodrage", "Alliance Only"},
            {{54892}, {1205}, "Kaldorei Nightsaber", 20, "Shadowclaw", "Horde Only"},
            {{54431}, {1203}, "Umber Nightsaber", 20, "Athil Dewfire", "Horde Only"},
            {{54277}, {1203}, "Captured Umber Nightsaber", 20, "Moxo the Beheader", "Alliance Only"}
        },
        ["BfA Mechagon Rares"] = {
            {{55811}, {1248}, "Rusted Keys to the Junkheap Drifter", 200, "Rustfeather"},
            {{55512}, {1229}, "Rusty Mechanocrawler", 333, "Arachnoid Harvester"}
        },
        ["BfA Nazjatar Rares"] = {
            {{56298}, {1257}, "Silent Glider", 200, "Soundless"}
        },
        ["BfA Uldum Rares"] = {
            {{57259}, {1314}, "Reins of the Drake of the Four Winds", 100, "Ishak of the Four Winds"},
            {{58696}, {1319}, "Malevolent Drone", 100, "Corpse Eater"},
            {{57273}, {1317}, "Waste Marauder", 33, "Rotfeaster"}
        },
        ["BfA Vale of Eternal Blossoms Rares"] = {
            {{57363}, {1328}, "Xinlao", 33, "Xinlao"},
            {{57344}, {1297}, "Clutch of Ha-Li", 33, "Ha-Li"},
            {{57345}, {1327}, "Ren's Stalwart Hound", 33, "Houndlord Ren"},
            {{57346}, {1313}, "Pristine Cloud Serpent Scale", 50, "Rei Lun"}
        },
        ["SL Rares (non-Covenant Specific)"] = {
            {{59869}, {1379}, "Endmire Flyer Tether", 100, "Famu the Infinite"},
            {{61720}, {1410}, "Slime-Covered Reins of the Hulking Deathroc", 33, "Violet Mistake"},
            {{58851}, {1373}, "Gorespine", 50, "Nerissa Heartless"},
            {{58889}, {1372}, "Blisterback Bloodtusk", 33, "Warbringer Mal'Korak"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{62786}, {1437}, "Gnawed Reins of the Battle-Bound Warhound", 100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver"},
            {{58259}, {1391}, "Impressionable Gorger Spawn", 100, "Worldedge Gorger"},
            {{60933}, {1426}, "Ascended Skymane", 20, "Cache of the Ascended"},
            {{64246}, {1514}, "Rampaging Mauler", 50, "Konthrogz the Obliterator"},
            {{64455}, {1509}, "Garnet Razorwing", 100, "Reliwik the Defiant"},
            {{64233}, {1506}, "Crimson Shardhide", 100, "Malbog"},
            {{64164}, {1502}, "Fallen Charger's Reins", 100, "Fallen Charger"},
            {{65585}, {1584}, "Iska's Mawrat Leash", 100, "Rhuv, Gorger of Ruin"}
        }
    }
    
    local lockoutOrder = {
        "Burning Crusade Dungeons",
        "Wrath of Lich King Dungeons",
        "Cataclysm Dungeons",
        "Shadowlands Dungeons",
    }
    
    local rareOrder = {
        "WoD Tanaan Jungle Rares",
        "Legion Argus Rares",
        "BfA Arathi Highlands Rares",
        "BfA Darkshore Rares",
        "BfA Mechagon Rares",
        "BfA Nazjatar Rares",
        "BfA Uldum Rares",
        "BfA Vale of Eternal Blossoms Rares",
        "SL Rares (non-Covenant Specific)"
    }
    
    local dailySLActivities = {
            {{61839, 61840, 61842, 61844, 62045, 62046}, {1391}, "Loyal Gorger", 6, "Loyal Gorger Quest"},
            {{62038, 62042, 62047, 62049, 62048, 62050}, {1414}, "Blanchy's Reins", 6, "Dead Blanchy Quest"},
            {{64292, 64298}, {1511}, "Reins of the Wanderer", 6, "Find Maelie, The Wanderer"},
            {{64274}, {1510}, "Dusklight Razorwing", 10, "Deliver an Egg to Razorwing Nest"},
            {{64376}, {1507}, "Darkmaul", 10, "Deliver a Tasty Mawshroom to Darkmaul"}
    }

    local dailyBfaActivities = {
        {{50393, 50394, 50402, 52305, 50395, 50401, 50412, 52447, 50396, 50886, 50887, 50900, 52748, 50397, 50940, 50942, 50943, 50944}, {1043}, 30, "Kua'fon Quest", {50801, 50796, 50791, 50798, 50839, 51146, 50838, 50838, 52317, 50842, 50930, 50860, 50841, 51146}},
        {{55608, 54086, 54929, 55373, 55697, 54922, 56168, 54083, 56175, 55696, 55753, 55622}, {1253}, 12, "Scrapforged Mechaspider Quest"},
        {{55254, 55252, 55253, 55258, 55462, 55503, 55504, 55506, 55505, 55507, 55247, 55795, 55796, 55797, 55798}, {1249}, 15, "Child of Torcali"},
        {{58887, 58879}, {1329}, 7, "Feed Gersahl Greens to Friendly Alpaca"},
        {{58802, 58803, 58804, 58806, 58805, 58805, 58808, 58805, 58805, 58805, 58805, 58805, 58809, 58810, 58811, 58812, 58813, 58817, 58858, 58858, 58818, 58825, 58858, 58858, 58829, 58830, 58861, 58831, 58862, 58859, 58831, 58863, 58865, 58866}, {1320}, 30, "Shadowbarb Drone Quest"},
    }

    local dailyClassicActivities = {
        {{13850, 13887, 13906}, {311}, 20, "Venomhide Ravasaur Quest", {13915, 13903, 13904, 13905}, "Horde Only"},
        {{29032, 29034}, {55}, 20, "Winterspring Frostsaber Quest", {29038, 29037, 29040, 29035}, "Alliance Only"}
    }

    local covRares = {
        [1] = {{1493, "Intact Aquilon Core", "Wild Worldcracker"}}, -- Kyrian
        [2] = { -- Venthyr
            {1310, "Horrid Dredwing", "Harika the Horrid", 59612, 100},
            {1298, "Hopecrusher Gargon", "Hopecrusher", 59900, 100},
            {803, "Mastercraft Gravewing", "Stygian Stonecrusher"}
        }, 
        [3] = {  -- Night Fae
            {1487, "Summer Wilderling", "Escaped Wilderling"},
            {1393, "Wild Glimmerfur Prowler", "Valfir the Unrelenting", 61632, 100},
        },
        [4] = {   -- Necrolord
            {1411, "Predatory Plagueroc", "Gieger", 58872, 33},
            {1370, "Armored Bonehoof Tauralus", "Sabriel the Bonecleaver", 58784, 100},
            {1366, "Bonehoof Tauralus", "Tahonta", 58783, 100},
            {1449, "Lord of the Corpseflies", "Fleshwing"}
        }
    }

    local function covenantRareMounts()
        local function GetCharacterKey()
            local name, realm = UnitName("player"), GetRealmName()
            return name .. "-" .. realm
        end

        local characterKey = GetCharacterKey()
        local activeCovenantID = C_Covenants.GetActiveCovenantID()
        local output = {}
        local hasAnyMountsToShow = false
        
        if MasterCollectorSV.showCovenantRares then
            for covenantID, mounts in pairs(covRares) do
                local covenantName = C_Covenants.GetCovenantData(covenantID) and C_Covenants.GetCovenantData(covenantID).name
                or MasterCollectorSV[characterKey].covenants[covenantID].name or "|cffff0000Error: Unable to Load Covenant/s, Switch Covenants at Oribos|r\n\n"

                local covenantOutput = {}
                local covenantHasMountsToShow = false
                
                for _, mountData in ipairs(mounts) do
                    local mountID, itemName, dropsFrom, questID, dropChanceDenominator = unpack(mountData)
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                    local hasCompletedQuest = questID and C_QuestLog.IsQuestFlaggedCompleted(questID) or false
                    local rarityAttemptsText = ""
                    local dropChanceText = ""

                    if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                        local chance = 1 / dropChanceDenominator
                        local attempts = GetRarityAttempts(itemName) or 0
                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                    end
            
                    local shouldShow = not (MasterCollectorSV.hideBossesWithMountsObtained and isCollected) and
                            (not isCollected or not (MasterCollectorSV.showBossesWithNoLockout and hasCompletedQuest))
            
                    if shouldShow then
                        covenantHasMountsToShow = true
                        hasAnyMountsToShow = true
                        local colorHex = hasCompletedQuest and MC.greenHex or MC.redHex
                        covenantOutput[#covenantOutput + 1] = string.format("%s        %s|r\n", colorHex, dropsFrom)
                        if MasterCollectorSV.showMountName then
                            covenantOutput[#covenantOutput + 1] = string.format("            Mount: %s %s%s\n", mountName, rarityAttemptsText, dropChanceText)
                        end
                    end
                end
                
                if covenantHasMountsToShow then
                    output[#output + 1] = string.format("%s    %s Only|r\n", MC.goldHex, covenantName)
                    for _, line in ipairs(covenantOutput) do
                        output[#output + 1] = line
                    end
                end
            end

            if hasAnyMountsToShow then
                table.insert(output, 1, MC.goldHex .. "SL Covenant Specific Rare Drops|r\n")
                return table.concat(output)
            else
                return nil
            end
        end
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
  
    local function isInstanceBossKilled(instanceID, bossID, difficultyID)
        local bossName = EJ_GetEncounterInfo(bossID)
        for i = 1, GetNumSavedInstances() do
            local _, _, _, savedDifficulty, locked = GetSavedInstanceInfo(i)
            if locked and tonumber(difficultyID) == tonumber(savedDifficulty) then
                    for j = 1, 20 do
                        local encounterName, _, isKilled = GetSavedInstanceEncounterInfo(i, j)
                        if encounterName == bossName then
                            return isKilled
                        end
                    end
                end
            end
        return false
    end
    
    local function GetItemData(itemName)
        for category, dungeons in pairs(lockouts) do
            for dungeonID, bosses in pairs(dungeons) do
                for _, bossData in ipairs(bosses) do
                    local _, _, _, itemNameInData, dropChanceDenominator = unpack(bossData)

                    if itemNameInData == itemName then
                        return {
                            dropChanceDenominator = dropChanceDenominator or 0
                        }
                    end
                end
            end
        end
        return nil
    end

    function GetRarityAttempts(itemName)
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
   
    local function GetDailyResetTime()
        local secondsUntilReset = C_DateAndTime.GetSecondsUntilDailyReset()
            
        if secondsUntilReset > 0 then
            local hours = math.floor(secondsUntilReset / 3600)
            local minutes = math.floor((secondsUntilReset % 3600) / 60)
    
            return string.format("%sTime until daily reset: |r%02d Hrs %02d Min\n", MC.goldHex, hours, minutes)
        end
    end
    
    local function displayLockouts()
        local lockoutText = ""
        local whiteColor = "|cffffffff"
    
        local difficulties = {
            [2] = "Heroic", [23] = "Mythic"
        }
   
        for _, expansion in ipairs(lockoutOrder) do
            local dungeons = lockouts[expansion]
            if dungeons then
                local shouldProcessExpansion = true
                if (expansion == "Shadowlands Dungeons" and not MasterCollectorSV.showSLDailyDungeons) or
                (expansion == "Burning Crusade Dungeons" and not MasterCollectorSV.showTBCDungeons) or
                (expansion == "Wrath of Lich King Dungeons" and not MasterCollectorSV.showWOTLKDungeons) or
                (expansion == "Cataclysm Dungeons" and not MasterCollectorSV.showCataDungeons) then
                    shouldProcessExpansion = false
                end
                
                if shouldProcessExpansion then
                local expansionText = ""
                    for dungeonID, bosses in pairs(dungeons) do
                        local dungeonName = EJ_GetInstanceInfo(dungeonID) or "Unknown Dungeon"
                        local dungeonText = ""
            
                        for _, bossData in ipairs(bosses) do
                            local bossID, mountIDs, difficultyID, itemName, dropChanceDenominator = unpack(bossData)
                            local isDefeated = isInstanceBossKilled(dungeonID, bossID, difficultyID)
            
                            if not isMountObtained(mountIDs) then
                                if not (MasterCollectorSV.showBossesWithNoLockout and isDefeated) then
                                    local bossName = EJ_GetEncounterInfo(bossID) or "Unknown Boss"
                                    local bossColor = isDefeated and MC.greenHex or MC.redHex
                                    local difficultiesText = ""
                                    local allDifficultiesKilled = true

                                    for _, difficulty in ipairs({difficultyID}) do
                                        local difficultyName = difficulties[difficulty] or "Unknown"
                                        local isDifficultyKilled = isInstanceBossKilled(dungeonID, bossID, difficulty)
                                        local color = isDifficultyKilled and MC.greenHex or MC.redHex
            
                                        difficultiesText = difficultiesText .. color .. "(" .. difficultyName .. ")" .. "|r"
                                        if not isDifficultyKilled then
                                            allDifficultiesKilled = false
                                        end
                                    end
            
                                    if not (MasterCollectorSV.showBossesWithNoLockout and allDifficultiesKilled) then
                                        dungeonText = dungeonText .. string.format("    - %s%s|r %s\n", bossColor, bossName, difficultiesText)
            
                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID) or "Unknown Mount"
                                            local itemData = GetItemData(itemName)
                                            local rarityAttemptsText = ""
                                            local dropChanceText = ""
                                            
                                            if MasterCollectorSV.showRarityDetail and itemData then
                                                dropChanceDenominator = itemData.dropChanceDenominator
                                                local attempts = GetRarityAttempts(itemName) or 0
                                                
                                                if dropChanceDenominator and dropChanceDenominator ~= 0 then
                                                    local chance = 1 / dropChanceDenominator
                                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                                    rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                                else
                                                    rarityAttemptsText = ""
                                                    dropChanceText = ""
                                                end
                                            else
                                                rarityAttemptsText = ""
                                                dropChanceText = ""
                                            end
                                            if MasterCollectorSV.showMountName then
                                                dungeonText = dungeonText .. string.format("      - %sMount: %s%s%s|r\n", whiteColor, mountName, rarityAttemptsText, dropChanceText)
                                            end
                                        end
                                    end
                                end
                            end
                        end
                        if dungeonText ~= "" then
                            expansionText = expansionText .. "\n    " .. MC.goldHex .. dungeonName .. "|r:\n" .. dungeonText
                        end
                    end
                    if expansionText ~= "" then
                        lockoutText = lockoutText .. "\n" .. MC.goldHex .. expansion .. "|r:" .. expansionText
                    end
                end
            end
        end
        local playerFaction = UnitFactionGroup("player")
        for _, expansion in ipairs(rareOrder) do
            local raresData = rares[expansion]
            if raresData then
                local expansionText = ""
                
                local shouldProcessExpansion = true
                if (expansion == "WoD Tanaan Jungle Rares" and not MasterCollectorSV.showTanaanRares) or
                (expansion == "Legion Argus Rares" and not MasterCollectorSV.showArgusRares) or
                (expansion == "BfA Arathi Highlands Rares" and not MasterCollectorSV.showArathiRares) or
                (expansion == "BfA Darkshore Rares" and not MasterCollectorSV.showDarkshoreRares) or
                (expansion == "BfA Mechagon Rares" and not MasterCollectorSV.showMechagonRares) or
                (expansion == "BfA Nazjatar Rares" and not MasterCollectorSV.showNazRares) or
                (expansion == "BfA Uldum Rares" and not MasterCollectorSV.showUldumRares) or
                (expansion == "BfA Vale of Eternal Blossoms Rares" and not MasterCollectorSV.showValeRares) or
                (expansion == "SL Rares (non-Covenant Specific)" and not MasterCollectorSV.showSLRares) then
                    shouldProcessExpansion = false
                end
                
                if shouldProcessExpansion then
                    for _, rareData in ipairs(raresData) do
                        local questIDs = rareData[1]
                        local mountIDs = rareData[2]
                        local itemName = rareData[3]
                        local dropChanceDenominator = rareData[4]
                        local rareName = rareData[5]
                        local factionRestriction = rareData[6]
                        local anyQuestsCompleted = false
                
                        if type(questIDs) ~= "table" then
                            questIDs = {questIDs}
                        end

                        for _, questID in ipairs(questIDs) do
                            if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                anyQuestsCompleted = true
                                break
                            end
                        end
                            
                        if type(mountIDs) ~= "table" then
                            mountIDs = {mountIDs}
                        end

                        for _, mountID in ipairs(mountIDs) do
                            local mountName, isCollected
                            local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
                            mountName = mountInfo[1] or "Unknown Mount"
                            isCollected = mountInfo[11]
                            
                            local shouldShow = true
                            
                            shouldShow = not (MasterCollectorSV.hideBossesWithMountsObtained and isCollected) and
                            (not isCollected or not (MasterCollectorSV.showBossesWithNoLockout and anyQuestsCompleted))

                            if shouldShow then
                                local attempts = GetRarityAttempts(itemName) or 0
                                local rarityAttemptsText = ""
                                local dropChanceText = ""

                                if MasterCollectorSV.showRarityDetail and dropChanceDenominator and dropChanceDenominator ~= 0 then
                                    local chance = 1 / dropChanceDenominator
                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                    rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                else
                                    rarityAttemptsText = ""
                                    dropChanceText = ""
                                end
                                
                                if not factionRestriction or (factionRestriction == playerFaction .. " Only") then
                                    expansionText = expansionText .. string.format("   - %s%s|r\n", MC.redHex, rareName)
                                    if MasterCollectorSV.showMountName then
                                        expansionText = expansionText .. string.format("      - %s Mount: %s%s%s|r\n", whiteColor, mountName, rarityAttemptsText, dropChanceText)
                                    end
                                end
                            end
                        end
                    end
                end
                if expansionText ~= "" then
                    lockoutText = lockoutText .. "\n" .. MC.goldHex .. expansion .. "|r:\n" .. expansionText
                end
            end
        end

        local QuestIDs = {
            -- Maldraxxus Callings (Necrolord)
            [60396] = "Aiding Maldraxxus",
            [60408] = "Training Our Forces",
            [60416] = "Rare Resources",
            [60429] = "Troubles at Home",
            [60445] = "Challenges in Maldraxxus",
            [60455] = "Storm the Maw",
            [60459] = "Anima Salvage",
            [62694] = "A Calling in Maldraxxus",
            -- Bastion Callings (Kyrian)
            [60395] = "Aiding Maldraxxus",
            [60407] = "Training in Maldraxxus",
            [60430] = "A Call to Maldraxxus",
            [60447] = "Challenges in Maldraxxus",
            -- Ardenweald Callings (Night Fae)
            [60383] = "Aiding Maldraxxus",
            [60386] = "Training in Maldraxxus",
            [60420] = "A Call to Maldraxxus",
            [60436] = "Challenges in Maldraxxus",
            -- Revendreth Callings (Venthyr)
            [60397] = "Aiding Maldraxxus",
            [60409] = "Training in Maldraxxus",
            [60431] = "A Call to Maldraxxus",
            [60446] = "Challenges in Maldraxxus"
        }
    
        function MC.DisplayCurrentCallings()
            if not C_CovenantCallings.AreCallingsUnlocked() then
                return "Callings are not unlocked yet.\n"
            end
    
            local output = string.format("%sCurrent Maldraxxus Calling Quests:|r\n", MC.goldHex)
            local foundActive = false
            local mountIDs = {1438, 1439, 1440}
            local mountsUnobtained = false
    
            if MasterCollectorSV.showCallings then
                for questID, questName in pairs(QuestIDs) do
                    local isQuestActive = C_TaskQuest.IsActive(questID)
                    if isQuestActive then
                        foundActive = true
                        output = output .. string.format("%s    %s is available today!|r\n", MC.goldHex, questName)
        
                        local mountInfo = ""
        
                        for _, mountID in ipairs(mountIDs) do
                            local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(mountID)
                            local rarityAttemptsText = ""
                            local dropChanceText = ""
                            local dropChanceDenominator = 50
            
                            if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                                local chance = 1 / dropChanceDenominator
                                local attempts = GetRarityAttempts("Necroray Egg") or 0
                                local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                rarityAttemptsText = string.format(" (Necroray Egg Attempts: %d/%s", attempts, dropChanceDenominator)
                                dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                            end       

                            mountInfo = mountInfo .. "      Mount: " .. mountName .. rarityAttemptsText .. dropChanceText .. "\n"
        
                            if not collected then
                                mountsUnobtained = true
                            end
                        end
        
                        mountInfo = mountInfo:match("^(.-),%s*$") or mountInfo
        
                        if MasterCollectorSV.showMountName then
                            output = output .. mountInfo
                        end
                    end
                end
        
                if not foundActive then
                    output = output .. "No current callings found.\n"
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local function QueryClassicDailyActivities()
            local output = {}
            local mountsUnobtained = false
            table.insert(output, MC.goldHex .. "Classic Daily Activities|r")
    
            if not dailyClassicActivities or #dailyClassicActivities == 0 then
                table.insert(output, MC.goldHex .. "No activities found.|r")
                return output
            end
    
            if MasterCollectorSV.showClassicDailies then
                for _, entry in ipairs(dailyClassicActivities) do
                    local questIDs = entry[1]
                    local mountID = entry[2][1]
                    local requiredDays = entry[3]
                    local objective = entry[4]
                    local dailiesQuestIDs = entry[5]
                    local factionRequired = entry[6]
                    local completedDays = 0
                    local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(mountID)
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        
                    if not factionRequired or (factionRequired == "Alliance Only" and playerFaction == "Alliance") or (factionRequired == "Horde Only" and playerFaction == "Horde") then
                        if not isCollected then
                            mountsUnobtained = true
                        end
        
                        if isCollected then
                            completedDays = requiredDays
                        else
                            for _, questID in pairs(questIDs) do
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    if #questIDs > 0 then
                                        local allButLastCompleted = true
                                        local completedQuestSet = {}
        
                                        for i = 1, #questIDs - 1 do
                                            local normalQuestID = questIDs[i]
                                            if not C_QuestLog.IsQuestFlaggedCompleted(normalQuestID) then
                                                allButLastCompleted = false
                                                break
                                            end
                                        end
                            
                                        if allButLastCompleted and not isCompleted then
                                            for _, dailyQuestID in ipairs(dailiesQuestIDs) do
                                                if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) and not completedQuestSet[dailyQuestID] then
                                                    completedDays = completedDays + 1
                                                    completedQuestSet[dailyQuestID] = true
                                                end
                                            end
                                        elseif isCompleted then
                                            completedDays = requiredDays
                                        end
                                    end
                                end
                            end
                        end
                    end
        
                    local entryOutput = {}
                    local colorHex = isCompleted and MC.greenHex or MC.redHex
                    table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")
                    table.insert(entryOutput, "         Mount: " .. (mountName or "Unknown Mount") .. " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")
        
                    for _, line in ipairs(entryOutput) do
                        table.insert(output, line)
                    end
                end
        
                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local function QueryBfADailyActivities()
            local output = {}
            local mountsUnobtained = false
            table.insert(output, MC.goldHex .. "BfA Daily Activities|r")
    
            if not dailyBfaActivities or #dailyBfaActivities == 0 then
                table.insert(output, MC.goldHex .. "No activities found.|r")
                return output
            end
    
            if MasterCollectorSV.showBfaDailies then
                for _, entry in ipairs(dailyBfaActivities) do
                    local questIDs = entry[1]
                    local mountID = entry[2][1]
                    local requiredDays = entry[3]
                    local objective = entry[4]
                    local kuafonQuestIDs = entry[5]
                    local completedDays = 0
                    local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(mountID)
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
        
                    if not isCollected then
                        mountsUnobtained = true
                    end
        
                    if isCollected then
                        completedDays = requiredDays
                    else
                        if #questIDs == 2 then
                            local dailyQuestID = questIDs[2]
                            if isCompleted then
                                completedDays = requiredDays
                            else
                                for _ = 1, requiredDays do
                                    if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                        completedDays = completedDays + 1
                                    end
                                end
                            end
                        elseif kuafonQuestIDs ~= nil and #kuafonQuestIDs > 0 then
                                if isCompleted then
                                    completedDays = requiredDays
                                else
                                        local completedQuestSet = {}
                                        for _, dailyQuestID in ipairs(kuafonQuestIDs) do
                                            if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) and not completedQuestSet[dailyQuestID] then
                                                completedDays = completedDays + 1
                                                completedQuestSet[dailyQuestID] = true
                                            end
                                        end
                                end
                                        
                        else
                            local dailyQuestID = questIDs[1]
                            for _ = 1, requiredDays do
                                if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                    completedDays = completedDays + 1
                                end
                            end
                        end
                    end
        
                    local entryOutput = {}
                    local colorHex = isCompleted and MC.greenHex or MC.redHex
                    table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")
                    table.insert(entryOutput, "         Mount: " .. (mountName or "Unknown Mount") .. " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")
        
                    for _, line in ipairs(entryOutput) do
                        table.insert(output, line)
                    end
                end
        
                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local function QuerySLDailyActivities()
            local output = {}
            local mountsUnobtained = false
            table.insert(output, MC.goldHex .. "SL Daily Activities|r")

            if not dailySLActivities or #dailySLActivities == 0 then
                table.insert(output, MC.goldHex .. "No activities found.|r")
                return output
            end

            if MasterCollectorSV.showSLDailies then
                for _, entry in ipairs(dailySLActivities) do
                    local questIDs = entry[1]
                    local mountID = entry[2][1]
                    local itemName = entry[3]
                    local requiredDays = entry[4]
                    local objective = entry[5]
                    local completedDays = 0
                    local isCompleted = C_QuestLog.IsQuestFlaggedCompleted(mountID)
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                    if not isCollected then
                        mountsUnobtained = true
                    end

                    if isCollected then
                        completedDays = requiredDays
                    else
                        if #questIDs > 1 then
                            for index, questID in ipairs(questIDs) do
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    completedDays = index
                                else
                                    break
                                end
                            end
                        elseif #questIDs == 2 then
                            local dailyQuestID = questIDs[2]
                            if isCompleted then
                                completedDays = requiredDays
                            else
                                for _ = 1, requiredDays do
                                    if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                        completedDays = completedDays + 1
                                    end
                                end
                            end
                        else
                            local dailyQuestID = questIDs[1]
                            for _ = 1, requiredDays do
                                if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                    completedDays = completedDays + 1
                                end
                            end
                        end
                    end

                    local entryOutput = {}
                    local colorHex = isCompleted and MC.greenHex or MC.redHex
                    table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")
                    table.insert(entryOutput, "         Mount: " .. (mountName or "Unknown Mount") .. " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")

                    for _, line in ipairs(entryOutput) do
                        table.insert(output, line)
                    end
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local covenantRares = covenantRareMounts()
        if covenantRares ~= nil then
            lockoutText = lockoutText .. "\n" .. covenantRares
        end

        local callingsUpdate = MC.DisplayCurrentCallings()
        if callingsUpdate ~= nil then
            lockoutText = lockoutText .. "\n" .. callingsUpdate
        end

        local ClassicDailyActivitiesProgress = QueryClassicDailyActivities()
        if ClassicDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(ClassicDailyActivitiesProgress, "\n") .. "\n"
        end

        local BfaDailyActivitiesProgress = QueryBfADailyActivities()
        if BfaDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(BfaDailyActivitiesProgress, "\n") .. "\n"
        end

        local dailyActivitiesProgress = QuerySLDailyActivities()
        if dailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(dailyActivitiesProgress, "\n") .. "\n"
        end

        if lockoutText == "" then
            lockoutText = GetDailyResetTime() .. MC.goldHex .. "\nWe are all done here.... FOR NOW!|r"
        else
            lockoutText = GetDailyResetTime() .. lockoutText
        end
        return lockoutText
    end

    if MC.mainFrame and MC.mainFrame.text then
        MC.mainFrame.text:SetText(displayLockouts())
    end
end