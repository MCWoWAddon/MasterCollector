function MC.grinds()
    if MC.currentTab ~= "Anytime\nGrinds" then
        return
    end

    MC.InitializeColors()
    local wowheadIcon = "Interface\\AddOns\\MasterCollector\\wowhead.png"

    local grindsText = ""
    local fontSize = MasterCollectorSV.fontSize
    local playerFaction = UnitFactionGroup("player")

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont("P", font, fontSize, flags)
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

    local achievementMounts = {
        ["Wrath of the Lich King"] = {
            { 262, {2136} }, -- Red Proto-Drake, Glory of the Hero
            { 268, {2143} }, -- Albino Drake, Leading the Cavalry (50 mounts usable)
            { 292, {2537} }, -- Red Dragonhawk, Mountain o' Mounts (100 mounts usable)
            -- { 263, 2138 }, -- Black Proto-Drake, Glory of the Raider (25 player)
            { 306, {12401} }, -- Ironbound Proto-Drake, Glory of the Ulduar Raider (formerly 25 player Ulduar)
            -- { 307, 2957 }, -- Ironbound Proto-Drake, Glory of the Ulduar Raider (formerly 10 player Ulduar)
            -- { 342, 3810, "Horde Only" } -- Swift Horde Wolf, A Tribute to Insanity (10 player, Trial of the Grand Crusader)
            -- { 343, 3810, "Alliance Only" } -- Swift Alliance Steed, A Tribute to Insanity (10 player, Trial of the Grand Crusader)
            -- { 344, 4156, "Alliance Only" } -- Crusader's White Warhouse, A Tribute to Immortality (Trial of the Crusader)
            -- { 345, 4079, "Horde Only" } -- Crusader's Black Warhouse, A Tribute to Immortality (Trial of the Crusader)
            { 365, {4602} }, -- Bloodbathed Frostbrood Vanquisher, Glory of the Icecrown Raider 10 player
            { 364, {4603} } -- Icebound Frostbrood Vanquisher, Glory of the Icecrown Raider 25 player
        },
        ["Cataclysm"] = {
            { 413, {5866} }, -- Flameward Hippogryph, The Molten Front Offensive
            { 391, {4845} }, -- Volcanic Stone Drake, Glory of the Cataclysm Hero
            { 392, {4853} }, -- Drake of the East Wind, Glory of the Cataclysm Raider
            { 417, {5828} }, -- Corrupted Egg of Millagazor, Glory of the Firelands Raider
            { 443, {6169} }  -- Twilight Harbinger, Glory of the Dragon Soul Raider
        },
        ["Mists of Pandaria"] = {
            { 292, {7860, 7862} }, -- Jade Pandaren Kite String, We're Going to Need More Saddles (150 mounts usable)
            { 450, {6827} }, -- Pandaren Kite String, Pandaren Ambassador
            { 472, {6927} }, -- Crimson Cloud Serpent, Glory of the Pandaria Hero
            { 474, {6932} }, -- Heavenly Crimson Cloud Serpent, Glory of the Pandaria Raider
            { 530, {8124} }, -- Armored Skyscreamer, Glory of the Thundering Raider
            { 548, {8302}, "Horde Only" }, -- Armored Red Dragonhawk, Mount Parade (200 mounts usable)
            { 549, {8304}, "Alliance Only" }, -- Armored Blue Dragonhawk, Mount Parade (200 mounts usable)
            { 557, {9598, 9599} }, -- Felfire Hawk, Mountacular (250 mounts usable)
            { 477, {10355, 10356} }, -- Heavenly Azure Cloud Serpent, Lord of the Reins (300 mounts usable)
            { 557, {8454} } -- Spawn of Galakras, Glory of the Orgrimmar Raider
            -- { 518, 6375 }, -- Ashen Pandaren Phoenix, Challenge Conqueror: Silver
            -- { 503, 6375 }, -- Crimson Pandaren Phoenix, Challenge Conqueror: Silver
            -- { 519, 6375 }, -- Emerald Pandaren Phoenix, Challenge Conqueror: Silver
            -- { 520, 6375 }, -- Violet Pandaren Phoenix, Challenge Conqueror: Silver
            -- { 654, 8898 }, -- Challenger's War Yeti, Challenge Warlord: Silver
            -- { 764, {8398, 8399} }, -- Kor'kron War Wolf, Ahead of the Curve: Garrosh Hellscream (25 player)
        },
        ["Warlords of Draenor"] = {
            { 664, {9713} }, -- Emerald Drake, Awake the Drakes
            { 678, {9909}, "Horde Only" }, -- Chauffeured Mechano-Hog, Heirloom Hoarder
            { 679, {9909}, "Alliance Only" }, -- Chauffeured Mekgineer's Chopper, Heirloom Hoarder
            { 772, {10018} }, -- Soaring Skyterror, Draenor Pathfinder
            { 623, {9396} }, -- Frostplains Battleboar, Glory of the Draenor Hero
            { 607, {8985} }, -- Gorestrider Gronnling, Glory of the Draenor Raider
            { 758, {10149} } -- Infernal Direwolf, Glory of the Hellfire Raider
            -- { 764, 10044 }, -- Grove Warden, Ahead of the Curve: The Black Gate
        },
        ["Legion"] = {
            { 1167, {12931, 12932} }, -- Frostshard Infernal, No Stable Big Enough (350 mounts usable)
            { 845, {11176} }, -- Mechanized Lumber Extractor, Remember to Share (350 toys)
            { 804, {11066} }, -- Ratstallion, Underbelly Tycoon
            { 986, {12103} }, -- Bleakhoof Ruinstrider, ...And Chew Mana Buns
            { 846, {11163} }, -- Leyfeather Hippogryph, Glory of the Legion Hero
            { 773, {11180} }, -- Grove Defiler, Glory of the Legion Raider
            { 972, {11987} }, -- Antoran Gloomhound, Glory of the Argus Raider
            { 1532, {15310} } -- Mage-Bound Spelltome, A Tour of Towers (Mage Tower)
            -- { 978, 12110 }, -- Violet Spellwing, Ahead of the Curve: Argus the Unmaker
        },
        ["Battle for Azeroth"] = {
            { 1191, {12933, 12934} }, -- Frenzied Feltalon, A Horde of Hoofbeats (400 mounts usable)
            { 1190, {12866} }, -- Pureheart Courser, 100 Exalted Reputations
            { 1245, {13517} }, -- Bloodflank Charger, Two Sides to Every Tale
            { 1224, {13250} }, -- Wonderwing 2.0, Battle for Azeroth Pathfinder, Part Two
            { 1238, {13638} }, -- Snapback Scuttler, Undersea Usurper
            { 1247, {13541} }, -- Mechacycle Model W, Mecha-Done
            { 1282, {13944, 41929} }, -- Black Serpent of N'Zoth, Through the Depths of Visions (Battle for Azeroth & The War Within)
            { 933, {12812} }, -- Obsidian Krolusk, Glory of the Wartorn Hero
            { 963, {12806} }, -- Bloodgorged Crawg, Glory of the Uldir Raider
            { 1218, {13315} }, -- Dazar'alor Windreaver, Glory of the Dazar'alor Raider
            { 1232, {13687} }, -- Azshari Bloatray, Glory of the Eternal Raider
            { 1322, {14146} }, -- Wriggling Parasite, Glory of the Ny'alotha Raider
            { 1277, {40956} }, -- Honeyback Hivemother, I'm On Island Time
            { 2339, {40953} } -- Jani's Trashpile, A Farewell to Arms
            -- { 1326, 14145 } -- Awakened Mindborer, Battle for Azeroth Keystone Master: Season Four
            -- { 1265, 14068 } -- Uncorrupted Voidwing, Ahead of the Curve: N'Zoth the Corruptor
        },
        ["Shadowlands"] = {
            { 1443, {14322} }, -- Voracious Gorger, Glory of the Shadowlands Hero
            { 1377, {14355} }, -- Rampart Screecher, Glory of the Nathria Raider
            { 1417, {15130} }, -- Hand of Hrestimorak, Glory of the Dominant Raider
            { 1549, {15491} }, -- Shimmering Aurelid, Glory of the Sepulcher Raider
            -- { 1576, 15681 }, -- Jigglesworth Sr., Fates of the Shadowlands Raids
            -- { 1419, 14532 }, -- Sintouched Deathwalker, Shadowlands Keystone Master: Season One
            -- { 1520, 15078 }, -- Soultwisted Deathwalker, Shadowlands Keystone Master: Season Two
            -- { 1544, 15499 }, -- Wastewarped Deathwalker, Shadowlands Keystone Master: Season Three
            -- { 1405, 15690 }, -- Restoration Deathwalker, Shadowlands Keystone Master: Season Four
            { 1551, {15336} }, -- Cryptic Aurelid, From A to Zereth
            { 1446, {15178} }, -- Tazavesh Gearglider, Fake It 'Til You Make It (Tazavesh Hard Mode)
            { 1504, {15064} }, -- Hand of of Salaranga, Breaking the Chains
            { 2114, {20501} } -- Zovaal's Soul Eater, Back from the Beyond
        },
        ["Dragonflight"] = {
            { 1654, {15833, 15834} }, -- Frenzied Feltalon, Thanks for the Carry! (500 mounts usable)
            { 1626, {16295} }, -- Shellack, Glory of the Dragonflight Hero
            { 1644, {16355} }, -- Raging Magmammoth, Glory of the Vault Raider
            { 1734, {18251} }, -- Shadowflame Shalewing, Glory of the Aberrus Raider
            { 1814, {19349} }, -- Shadow Dusk Dreamsaber, Glory of the Dream Raider
            { 1621, {16492} }, -- Coralscale Salamanther, Into the Storm
            { 1614, {19486} }, -- Stormtouched Bruffalon, Across the Isles
            { 1633, {19482} }, -- Bestowed Trawling Mammoth, Army of the Fed
            { 1618, {19485} }, -- Bestowed Sandskimmer, Closing Time
            { 1669, {19479} }, -- Bestowed Ohuna Spotter, Wake Me Up
            { 1474, {19481} }, -- Bestowed Thunderspine Packleader, Centaur of Attention
            { 1651, {19483} }, -- Bestowed Ottuk Vanguard, Flight Club
            { 1733, {17785} }, -- Calescent Shalewing, Que Zara(lek), Zara(lek)
            { 1825, {19458} } -- Calescent Shalewing, Que Zara(lek), Zara(lek)
            -- { 2091, 19574 }, -- Voyaging Wilderling, Awakening the Dragonflight Raids
            -- { 1681, 16649 }, -- Hailstorm Armoredon, Dragonflight Keystone Master: Season One
            -- { 1725, 17844 }, -- Inferno Armoredon, Dragonflight Keystone Master: Season Two
            -- { 1801, 19011 }, -- Verdant Armoredon, Dragonflight Keystone Master: Season Three
            -- { 2055, 19782 }, -- Infinite Armoredon, Dragonflight Keystone Master: Season Four
        },
        ["The War Within"] = {
            { 2180, {40232} }, -- Shadowed Swarmite, Glory of the Nerub-ar Raider
            { 2181, {40702} }, -- Swarmite Skyhunter, Khaz Algar Glyph Hunter
            { 2230, {40438} }, -- Ivory Goliathus, Glory of the Delver
            { 2332, {41133} }, -- The Breaker's Song, Isle Remember You
            { 2332, {41201} }, -- Shadow of Doubt, You Xal Not Pass
            { 2313, {41286} }, -- Junkmaestro's Magnetomech, Glory of the Liberation of Undermine Raider
            { 2500, {41966} }, -- Ny'alothan Shadow Worm, Mastering the Visions
            { 2511, {41980} }, -- Terror of the Night, Vigilante (Complete all Warrants Once K'aresh)
            { 2655, {61017} }, -- Phase-Lost Slateback, Phase-Lost-and-Found
            { 2549, {41597} }, -- Umbral K'arroc, Glory of the Omega Raider
            -- { 2244, 20525 }, -- Diamond Mechsuit, The War Within Keystone Master: Season One
            -- { 2480, 41533 }, -- Crimson Shreddertank, The War Within Keystone Master: Season Two
            -- { 2508, 40951 }, -- Enterprising Shreddertank, The War Within Keystone Legend: Season Two
            { 2606, {41624} }, -- Royal Voidwing, Ahead of the Curve: Dimensius, the All-Devouring
            -- { 2633, {41973} }, -- Azure Void Flyer, The War Within Keystone Master: Season Three
            -- { 2631, {42172} } -- Scarlet Void Flyer, The War Within Keystone Legend: Season Three
        }
    }

    local pvpMounts = {
        ["Classic"] = {
            { 108, 15 } -- Frostwolf Howler, 15 Marks of Honor
        },
        ["The Burning Crusade"] = {
            { 76, 15 }, -- Black War Kodo, 15 Marks of Honor
            { 79, 15 }, -- Black War Raptor, 15 Marks of Honor
            { 80, 15 }, -- Red Skeletal Warhorse, 15 Marks of Honor
            { 82, 15 }, -- Black War Wolf, 15 Marks of Honor
            { 162, 15 } -- Swift Warstrider, 15 Marks of Honor
            -- { 169, 0 }, -- Swift Nether Drake, Gladiator Season 1
            -- { 207, 0 }, -- Merciless Nether Drake, Gladiator Season 2
            -- { 223, 0 }, -- Vengeful Nether Drake, Gladiator Season 3
            -- { 241, 0 } -- Brutal Nether Drake, Gladiator Season 4
        },
        ["Wrath of the Lich King"] = {
            { 255, 15 }, -- Black War Mammoth, 15 Marks of Honor
            { 271, 614 }, -- Black War Bear, For The Alliance! (Slay the Horde Leaders)
            { 272, 619 } -- Black War Bear, For The Horde! (Slay the Alliance Leaders)
            -- { 313, 3096 }, -- Deadly Gladiator's Frost Wyrm, Gladiator Season 5
            -- { 317, 3756 }, -- Furious Gladiator's Frost Wyrm, Gladiator Season 6
            -- { 340, 3757 }, -- Relentless Gladiator's Frost Wyrm, Gladiator Season 7
            -- { 358, 4600 } -- Wrathful Gladiator's Frost Wyrm, Gladiator Season 8
        },
        ["Cataclysm"] = {
            { 422, 1, "Alliance Only" }, -- Vicious War Steed (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 423, 1, "Horde Only" } -- Vicious War Wolf (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 424, 6003 }, -- Vicious Gladiator's Twilight Drake, Gladiator Season 9
            -- { 428, 6322 }, -- Ruthless Gladiator's Twilight Drake, Gladiator Season 10
            -- { 467, 6741 } -- Cataclysmic Gladiator's Twilight Drake, Gladiator Season 11
        },
        ["Mists of Pandaria"] = {
            -- { 541, 8216 }, -- Malevolent Gladiator's Cloud Serpent, Gladiator Season 12
            { 554, 1, "Alliance Only" }, -- Vicious Kaldorei Warsaber (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 555, 1, "Horde Only" }, -- Vicious Skeletal Warhorse (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 560, 500 } -- Ashhide Mushan Beast, Bloody Coin PVP grind on Timeless Isle
            -- { 562, 8678 }, -- Tyrannical Gladiator's Cloud Serpent, Gladiator Season 13
            -- { 563, 8705 }, -- Grievous Gladiator's Cloud Serpent, Gladiator Season 14
            -- { 564, 8707 } -- Prideful Gladiator's Cloud Serpent, Gladiator Season 15
        },
        ["Warlords of Draenor"] = {
            { 640, 1, "Alliance Only" }, -- Vicious War Ram (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 641, 1, "Horde Only" }, -- Vicious War Raptor (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 755, 1, "Alliance Only" }, -- Vicious War Mechanostrider (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 756, 1, "Horde Only" } -- Vicious War Kodo (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 759, 9229 }, -- Primal Gladiator's Felblood Gronnling, Gladiator Warlords Season 1 (Season 16)
            -- { 760, 10137 }, -- Wild Gladiator's Felblood Gronnling, Gladiator Warlords Season 2 (Season 17)
            -- { 761, 10146 } -- Wild Gladiator's Felblood Gronnling, Gladiator Warlords Season 3 (Season 18)
        },
        ["Legion"] = {
            { 826, 12895 }, -- Prestigious Bronze Courser, Honor Level 15
            { 833, 12903 }, -- Prestigious Ivory Courser, Honor Level 40
            { 834, 12906 }, -- Prestigious Azure Courser, Honor Level 70
            { 832, 12910 }, -- Prestigious Forest Courser, Honor Level 125
            { 831, 12911 }, -- Prestigious Royal Courser, Honor Level 150
            { 836, 12914 }, -- Prestigious Midnight Courser, Honor Level 250
            { 841, 1, "Alliance Only" }, -- Vicious Gilnean Warhorse (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 842, 1, "Horde Only" }, -- Vicious War Trike (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 843, 1, "Horde Only" }, -- Vicious Warstrider (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 844, 1, "Alliance Only" }, -- Vicious War Elekk (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 848, 11011 }, -- Vindictive Gladiator's Storm Dragon, Gladiator Legion Season 1 (Season 19)
            -- { 849, 11013 }, -- Fearless Gladiator's Storm Dragon, Gladiator Legion Season 2 (Season 20)
            -- { 850, 11038 }, -- Cruel Gladiator's Storm Dragon, Gladiator Legion Season 3 (Season 21)
            -- { 851, 11061 }, -- Ferocious Gladiator's Storm Dragon, Gladiator Legion Season 4 (Season 22)
            -- { 852, 12045 }, -- Fierce Gladiator's Storm Dragon, Gladiator Legion Season 5 (Season 23)
            -- { 853, 12167 }, -- Dominant Gladiator's Storm Dragon, Gladiator Legion Season 6 (Season 24)
            { 873, 1, "Alliance Only" }, -- Vicious War Bear (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 874, 1, "Horde Only" }, -- Vicious War Bear (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 876, 1, "Alliance Only" }, -- Vicious War Lion (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 882, 1, "Horde Only" }, -- Vicious War Scorpion (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 900, 1, "Alliance Only" }, -- Vicious War Turtle (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 901, 1, "Horde Only" }, -- Vicious War Turtle (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 945, 1, "Alliance Only" }, -- Vicious War Fox (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 946, 1, "Horde Only" } -- Vicious War Fox (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 948, 12168 } -- Demonic Gladiator's Storm Dragon, Gladiator Legion Season 7 (Season 25)
        },
        ["Battle for Azeroth"] = {
            { 1192, 12917 }, -- Prestigious Bloodforged Courser, Honor Level 500
            { 1172, 12604, "Horde Only" }, -- Conqueror's Scythemaw, Conqueror of Azeroth
            { 1172, 12605, "Alliance Only" }, -- Conqueror's Scythemaw, Conqueror of Azeroth
            { 1045, 1, "Horde Only" }, -- Vicious War Clefthoof (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1050, 1, "Alliance Only" }, -- Vicious War Riverbeast (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1030, 12961 }, -- Dread Gladiator's Proto-Drake, Gladiator Battle for Azeroth Season 1 (Season 26)
            { 1195, 1, "Alliance Only" }, -- Vicious Black Warsaber (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1196, 1, "Horde Only" }, -- Vicious Black Bonesteed (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1031, 13212 }, -- Sinister Gladiator's Proto-Drake, Gladiator Battle for Azeroth Season 2 (Season 27)
            { 1026, 1, "Horde Only" }, -- Vicious War Basilisk (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1027, 1, "Alliance Only" }, -- Vicious War Basilisk (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1032, 13647 }, -- Notorious Gladiator's Proto-Drake, Gladiator Battle for Azeroth Season 3 (Season 28)
            { 1194, 1, "Alliance Only" }, -- Vicious White Warsaber (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1197, 1, "Horde Only" } -- Vicious White Bonesteed (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1035, 13967 } -- Corrupted Gladiator's Proto-Drake, Gladiator Battle for Azeroth Season 4 (Season 29)
        },
        ["Shadowlands"] = {
            { 1351, 1, "Alliance Only" }, -- Vicious War Spider (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1352, 1, "Horde Only" }, -- Vicious War Spider (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1363, 14689 }, -- Sinful Gladiator's Soul Eater, Gladiator Shadowlands Season 1 (Season 30)
            { 1459, 1, "Horde Only" }, -- Vicious War Grom (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1460, 1, "Alliance Only" }, -- Vicious War Gorm (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1480, 14972 }, -- Unchained Gladiator's Soul Eater, Gladiator Shadowlands Season 2 (Season 31)
            { 1451, 1, "Horde Only" }, -- Vicious War Croaker (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1452, 1, "Alliance Only" }, -- Vicious War Croaker (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1572, 15352 }, -- Cosmic Gladiator's Soul Eater, Gladiator Shadowlands Season 3 (Season 32)
            { 1465, 1, "Alliance Only" }, -- Vicious Warstalker (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1466, 1, "Horde Only" } -- Vicious Warstalker (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1599, 15605 }, -- Eternal Gladiator's Soul Eater, Gladiator Shadowlands Season 4 (Season 33)
        },
        ["Dragonflight"] = {
            { 1688, 1, "Alliance Only" }, -- Vicious Sabertooth (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1689, 1, "Horde Only" }, -- Vicious Sabertooth (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1660, 15957 }, -- Crimson Gladiator's Drake, Gladiator Dragonflight Season 1 (Season 34)
            { 1740, 1, "Alliance Only" }, -- Vicious War Snail (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1741, 1, "Horde Only" }, -- Vicious War Snail (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1739, 17740 }, -- Obsidian Gladiator's Slitherdrake, Gladiator Dragonflight Season 2 (Season 35)
            { 1819, 1, "Alliance Only" }, -- Vicious Moonbeast (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 1820, 1, "Horde Only" }, -- Vicious Moonbeast (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1739, 19091 }, -- Verdant Gladiator's Slitherdrake, Gladiator Dragonflight Season 3 (Season 36)
            { 2056, 1, "Alliance Only" }, -- Vicious Dreamtalon (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            { 2057, 1, "Horde Only" } -- Vicious Dreamtalon (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 1822, 19490 }, -- Draconic Gladiator's Drake, Gladiator Dragonflight Season 4 (Season 37)
        },
        ["The War Within"] = {
            { 2167, 40097 }, -- Raging Cinderbee, Ruffious's Bid
            -- { 2056, 40396, "Alliance Only" }, -- Vicious Skyflayer (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 2057, 40397, "Horde Only" }, -- Vicious Skyflayer (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 2218, 40393 }, -- Forged Gladiator's Fel Bat, Gladiator The War Within Season 1 (Season 38)
            -- { 2056, 41128, "Alliance Only" }, -- Vicious Electro Eel (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 2057, 41129, "Horde Only" }, -- Vicious Electro Eel (buy with Vicious Saddle - 100 Arena Wins after Earning Seasonal Mount)
            -- { 2298, 41032 }, -- Prized Gladiator's Fel Bat, Gladiator The War Within Season 2 (Season 39)
            -- { 2571, 42042, "Horde Only" }, -- Vicious Void Creeper The War Within Season 3 (100 Arena Wins after 1000 PVP Rating)
            -- { 2570, 42043, "Alliance Only" }, -- Vicious Void Creeper The War Within Season 3 (100 Arena Wins after 1000 PVP Rating)
            -- { 2326, 41049 } -- Astral Gladiator's Fel Bat, Gladiator The War Within Season 3 (Season 40)
        },
    }

    local expansionOrder = {
        "Classic",
        "The Burning Crusade",
        "Wrath of the Lich King",
        "Cataclysm",
        "Mists of Pandaria",
        "Warlords of Draenor",
        "Legion",
        "Battle for Azeroth",
        "Shadowlands",
        "Dragonflight",
        "The War Within"
    }

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
            { 111, { 397 }, 1, "Reins of the Vitreous Stone Drake", 100 }    -- Slabhide (Normal)
        }
    }

    local fishingMounts = {
        { 125,  "Sea Turtle",                         200 }, -- Sea Turtle
        { 312,  "Riding Turtle",                      200 }, -- Riding Turtle
        { 488,  "Reins of the Crimson Water Strider", 100 }, -- Crimson Water Strider
        { 982,  "Pond Nettle",                        2000 }, -- Pond Nettle
        { 1166, "Great Sea Ray",                      10000 } -- BfA Great Sea Ray
    }

    local protoformMounts = {
        {1525, 189478, {{188957, 450}, {189174, 1}, {189156, 1}}},                       -- Adorned Vombata
        {1538, 189642, {{188957, 400}, {189179, 1}, {189145, 1}}, {189462, 190610, 2, 20}}, -- Bronze Helicid
        {1535, 189473, {{188957, 350}, {189179, 1}, {189154, 1}}},                       -- Bronzewing Vespoid
        {1534, 189474, {{188957, 500}, {189176, 1}, {189154, 1}}, {189176, "Dominated Jiro", 1, 125}},-- Buzz
        {1523, 189476, {{188957, 400}, {189172, 1}, {189156, 1}}},                       -- Curious Crystalsniffer - in Halondrus room (any difficulty)
        {1524, 189477, {{188957, 450}, {189175, 1}, {189156, 1}}, {{189175, 187781, 2, 200}, {189175, "High Value Cache", 1, 1}}},  -- Darkened Vombata
        {1526, 189457, {{188957, 450}, {189178, 1}, {187635, 1}}, {189178, 2461, 3, 16}}, -- Deathrunner
        {1430, 189458, {{188957, 400}, {189180, 1}, {189150, 1}}, {189180, "Enhanced Avian", 1, 83}}, -- Desertwing Hunter
        {1533, 189475, {{188957, 450}, {189173, 1}, {189154, 1}}, {189173, "Discordant Sentry", 1, 83}}, -- Forged Spiteflyer
        {1541, 189465, {{188957, 400}, {189171, 1}, {189152, 1}}, {189171, 187781, 2, 166}},-- Genesis Crawler
        {1547, 189468, {{188957, 400}, {189171, 1}, {187633, 1}}, {{189468, "Accelerated Bufonid", 1, 33}, {189171, 187781, 2, 166}}}, -- Goldplate Bufonid
        {1580, 190585, {{188957, 500}, {189172, 1}, {190388, 1}}, {190585, "Maw-Frenzied Lupine", 1, 16}}, -- Heartbond Lupine
        {1543, 189467, {{188957, 500}, {189176, 1}, {189152, 1}}, {189176, "Dominated Jiro", 1, 125}},-- Ineffable Skitterer -- schematic must be ghost
        {1536, 189459, {{188957, 350}, {189175, 1}, {189150, 1}}, {{189459, "Mawsworn Hulk", 1, 66}, {189175, 187781, 2, 200}, {189175, "High Value Cache", 1, 1}}}, -- Mawdapted Raptora 
        {1431, 189455, {{188957, 400}, {189176, 1}, {187635, 1}}, {189176, "Dominated Jiro", 1, 125}},-- Pale Regal Cervid -- schematic 189455, achievement 15402
        {1570, 189469, {{188957, 350}, {189178, 1}, {187633, 1}}, {189178, 2461, 3, 16}}, -- Prototype Leaper
        {1537, 189460, {{188957, 450}, {189173, 1}, {189150, 1}}, {189173, "Discordant Sentry", 1, 83}}, -- Raptora Swooper
        {1571, 189471, {{188957, 350}, {189174, 1}, {187633, 1}}, {189471, 187780, 2, 13}}, -- Russet Bufonid
        {1540, 189464, {{188957, 350}, {189177, 1}, {189145, 1}}, {189177, "Protector of the First Ones", 1, 9}},  -- Scarlet Helicid
        {1448, 189461, {{188957, 500}, {189172, 1}, {189145, 1}}},                       -- Serenade - in First SoFo room (any difficulty)
        {1528, 189456, {{188957, 300}, {189175, 1}, {187635, 1}}, {{189175, 187781, 2, 200}, {189175, "High Value Cache", 1, 1}}}, -- Sundered Zerethsteed
        {1542, 189466, {{188957, 450}, {189177, 1}, {189152, 1}}, {189177, "Protector of the First Ones", 1, 9}},  -- Tarachnid Creeper
        {1539, 189463, {{188957, 300}, {189178, 1}, {189145, 1}}, {189178, 2461, 3, 16}}, -- Unsuccessful Prototype Fleetpod - in Camber Alcove Tele
        {1433, 189472, {{188957, 400}, {189180, 1}, {189154, 1}}, {189180, "Enhanced Avian", 1, 83}}  -- Vespoid Flutterer - in Lotus Shift Tele
    }

    local islandMounts = {
        { 1175, 100, {1501} }, -- Twilight Avenger
        { 1175, 100, {1036} }, -- Craghorn Chasm-Leaper
        { 1178, 100, {1502, 1036} }, -- Qinsho's Eternal Hound
        { 993, 100, {1501, 1033} }, -- Squawks
        { 1169, 100, {1037} }, -- Surf Jelly
        { 1213, 100, {1336} }, -- Risen Mare
        { 1212, 100, {1337} }, -- Island Thunderscale
        { 1211, 100 }, -- Bloodgorged Hunter
        { 1209, 100 } -- Stonehide Elderhorn
    }

    MC.islandMapIDs = {
        [1036] = "The Dread Chain",
        [1035] = "Molten Cay",
        [1032] = "Skittering Hollow",
        [981]  = "Un'gol Ruins",
        [1037] = "Whispering Reef",
        [1034] = "Verdant Wilds",
        [1033] = "Rotting Mire",
        [1502] = "Snowblossom Village",
        [1501] = "Crestfall",
        [1336] = "Havenswood",
        [1337] = "Jorundall"
    }

    local function BuildProtoformOutput()
        local outputModified = false
        local output = MC.goldHex .. "Protoform Synthesis Mounts|r\n"

        for _, entry in ipairs(protoformMounts) do
            local mountID = entry[1]
            local schematicID = entry[2]
            local craftList = entry[3]
            local rareData = entry[4]

            local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            local shouldShow = not (MasterCollectorSV.hideBossesWithMountsObtained and isCollected)
            if shouldShow then
                if MasterCollectorSV.showMountName then
                    output = output .. string.format("  Mount: |Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", mountID, MC.blueHex, mountName, mountID, wowheadIcon)
                end

                local craftStrings = {}

                for _, cData in ipairs(craftList) do
                    local itemID, count = cData[1], cData[2]
                    local data = MC.ItemDetails[itemID]
                    local itemName = data and data.name or "Unknown"
                    local itemHex  = data and data.hex or MC.goldHex
                    table.insert(craftStrings, string.format("%d x |Hitem:%d|h%s[%s]|r|h", count, itemID, itemHex, itemName))
                end

                outputModified = true
                output = output .. "  Crafting Requires: " .. table.concat(craftStrings, ", ") .. "\n"

                if rareData then
                    output = output .. "  Rare Drop Requirements:\n"

                    if type(rareData[1]) ~= "table" then
                        rareData = { rareData }
                    end

                    for _, r in ipairs(rareData) do
                        local rareItemID = r[1]
                        local sourceID   = r[2]
                        local sourceType = r[3]
                        local rateDenom  = r[4]

                        local data = MC.ItemDetails[rareItemID]
                        local rareName = data and data.name or "Unknown"
                        local rareHex  = data and data.hex or MC.goldHex
                        local sourceName

                        if sourceType == 1 then
                            if sourceID ~= "High Value Cache" then
                                sourceName = sourceName or ("NPC "..sourceID)
                            else
                                sourceName = sourceID
                            end
                        elseif sourceType == 3 then
                            local bossName = EJ_GetEncounterInfo(sourceID)
                            sourceName = string.format("%s|Hjournal:1:%d:0:0:0|h%s|h|r", MC.goldHex, sourceID, bossName)
                        else
                            local sd = MC.ItemDetails[sourceID]
                            sourceName = sd and sd.name or "Unknown"
                        end

                        local fraction = string.format("1/%d", rateDenom)
                        local percent = string.format("%.2f%%", (1 / rateDenom) * 100)
                        output = output .. string.format("    |Hitem:%d|h%s[%s]|r|h drops from %s with drop rate of %s = %s\n", rareItemID, rareHex, rareName, sourceName, fraction, percent)
                    end
                end
                output = output .. "\n"
            end
        end
        if MasterCollectorSV.showProtoform and outputModified then
            return output
        end
    end

    local function displayPVP()
        local output = MC.goldHex .. "PVP Mounts|r"

        local expansionToggleMap = {
            ["Classic"] = "showClassicPVP",
            ["The Burning Crusade"] = "showTBCPVP",
            ["Wrath of the Lich King"] = "showWOTLKPVP",
            ["Cataclysm"] = "showCataPVP",
            ["Mists of Pandaria"] = "showMOPPVP",
            ["Warlords of Draenor"] = "showWODPVP",
            ["Legion"] = "showLegionPVP",
            ["Battle for Azeroth"] = "showBFAPVP",
            ["Shadowlands"] = "showSLPVP",
            ["Dragonflight"] = "showDFPVP",
            ["The War Within"] = "showTWWPVP"
        }

        for _, expansion in ipairs(expansionOrder) do
            local toggleKey = expansionToggleMap[expansion]

            if MasterCollectorSV[toggleKey] then
                local mountList = pvpMounts[expansion]
                local expansionHeaderAdded = false

                for _, entry in pairs(mountList) do
                    local mountID = entry[1]
                    local requirement = entry[2]
                    local factionRequirement = entry[3]
                    local reqText

                    if not factionRequirement or (factionRequirement == "Alliance Only" and playerFaction == "Alliance") or (factionRequirement == "Horde Only" and playerFaction == "Horde") then
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                        if not (isCollected and MasterCollectorSV.hideBossesWithMountsObtained) then
                            if not expansionHeaderAdded then
                                output = output .. "\n" .. string.rep(" ", 3) .. MC.goldHex .. expansion .. "|r\n"
                                expansionHeaderAdded = true
                            end

                            local function BuildItemRequirement(itemID, itemRequirement)
                                local itemData = MC.ItemDetails[itemID]
                                local itemName = itemData and itemData.name or "Unknown"
                                local itemIcon = itemData and itemData.icon
                                local count = C_Item.GetItemCount(itemID, false, false) or ""
                                local texture = CreateTextureMarkup(itemIcon, 32, 32, 16, 16, 0, 1, 0, 1)
                                return string.format("%s%d / %d %s %s Required|r", MC.goldHex, count, itemRequirement, itemName, texture)
                            end

                            local function BuildCurrencyRequirement(currencyID, currencyRequirement)
                                local info = C_CurrencyInfo.GetCurrencyInfo(currencyID)
                                local texture = CreateTextureMarkup(info.iconFileID, 32, 32, 16, 16, 0, 1, 0, 1)
                                return string.format("%s%d / %d %s %s Required|r", MC.goldHex, info.quantity, currencyRequirement, info.name, texture)
                            end

                            if requirement == 1 then
                                reqText = BuildItemRequirement(103533, requirement) -- "Vicious Saddle", 236361
                            elseif requirement == 15 then
                                reqText = BuildItemRequirement(137642, requirement) -- "Mark of Honor", 1322720
                            elseif requirement == 500 then
                                reqText = BuildCurrencyRequirement(789, requirement)
                            else
                                local name = select(2, GetAchievementInfo(requirement))
                                if name then
                                    reqText = string.format("|Hachievement:%d|h%s[%s]|h|r", requirement, MC.goldHex, name)
                                end
                            end

                            output = output .. string.format("%s%s\n", string.rep(" ", 9), reqText)

                            if MasterCollectorSV.showMountName then
                                output = output .. string.format("%sMount: |Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 12), mountID, MC.blueHex, mountName, mountID, wowheadIcon)
                            end
                        end
                    end
                end
            end
        end
        if MasterCollectorSV.showPVP then
            return output
        end
    end

    local function displayAchievements()
        local output = MC.goldHex .. "Achievement Mounts|r"
        local outputModified = false

        local expansionToggleMap = {
            ["Wrath of the Lich King"] = "showWOTLKAchieves",
            ["Cataclysm"] = "showCataAchieves",
            ["Mists of Pandaria"] = "showMOPAchieves",
            ["Warlords of Draenor"] = "showWODAchieves",
            ["Legion"] = "showLegionAchieves",
            ["Battle for Azeroth"] = "showBFAAchieves",
            ["Shadowlands"] = "showSLAchieves",
            ["Dragonflight"] = "showDFAchieves",
            ["The War Within"] = "showTWWAchieves"
        }

        for _, expansion in ipairs(expansionOrder) do
            local toggleKey = expansionToggleMap[expansion]
            if MasterCollectorSV[toggleKey] then
                local mountList = achievementMounts[expansion]

                if mountList then
                    local expansionString = ""
                    local expansionHasVisibleMount = false
                    local expansionHeaderAdded = false

                    for _, entry in ipairs(mountList) do
                        local mountID = entry[1]
                        local achievementIDs = entry[2]
                        local factionRequirement = entry[3]
                        local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                        if not factionRequirement or (factionRequirement == "Alliance Only" and playerFaction == "Alliance") or (factionRequirement == "Horde Only" and playerFaction == "Horde") then
                            local outputAchieveID
                            local outputAchieveName

                            for _, achieveID in ipairs(achievementIDs) do
                                local _, achieveName = GetAchievementInfo(achieveID)
                                if achieveName then
                                    outputAchieveID = achieveID
                                    outputAchieveName = achieveName
                                    break
                                end
                            end

                            local mountString = ""
                            local achieveHasVisibleMount = false

                            local showMount = not (isCollected and MasterCollectorSV.hideBossesWithMountsObtained)

                            if showMount then
                                achieveHasVisibleMount = true
                                if MasterCollectorSV.showMountName then
                                    mountString = mountString .. string.format("%sMount: |Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h\n", string.rep(" ", 12), mountID, MC.blueHex, mountName, mountID, wowheadIcon)
                                end
                            end

                            if achieveHasVisibleMount then
                                if not expansionHeaderAdded then
                                    expansionString = expansionString .. string.format("\n%s%s%s|r\n", MC.goldHex, string.rep(" ", 4), expansion)
                                    expansionHeaderAdded = true
                                end

                                expansionString = expansionString .. string.format("%s|Hachievement:%d|h%s[%s]|h|r\n", string.rep(" ", 8), outputAchieveID, MC.goldHex, outputAchieveName)
                                expansionString = expansionString .. mountString
                                expansionHasVisibleMount = true
                            end
                        end
                    end

                    if expansionHasVisibleMount then
                        outputModified = true
                        output = output .. expansionString
                    end
                end
            end
        end

        if outputModified and MasterCollectorSV.showAchievements then
            return output
        end
    end


    local function displayFishing()
        local output = MC.goldHex .. "Fishing Mounts|r\n"
        local outputModified = false

        for _, mountData in ipairs(fishingMounts) do
            local mountID, itemName, dropChanceDenominator = unpack(mountData)
            local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
            local rarityAttemptsText, dropChanceText = "", ""

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
                    output = output .. string.format("%sMount: |r|Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s\n", string.rep(" ", 4), mountID, MC.blueHex, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                end
            end
        end
        if outputModified and MasterCollectorSV.showFishing then
            return output
        end
    end

    MasterCollectorSV.Islands = MasterCollectorSV.Islands or { activeIslands = {}, resetTime = 0 }

    local function GetNextWeeklyReset()
        local region = GetCVar("portal")               -- "US", "EU", etc.
        local resetDay = (region == "US") and 2 or 3   -- Tuesday for US, Wednesday for EU
        local resetHour = (region == "US") and 15 or 7 -- 15:00 UTC for US, 7:00 UTC for EU

        local realmTime = GetServerTime()
        local date = C_DateAndTime.GetCurrentCalendarTime()

        local weekStart = realmTime - ((date.weekday - 1) * 86400) - date.hour * 3600 - date.minute * 60
        local resetTime = weekStart + (resetDay - 1) * 86400 + resetHour * 3600

        if resetTime < realmTime then
            resetTime = resetTime + 7 * 86400
        end

        return resetTime
    end

    local function GetMountsForIsland(mapID)
        local list = {}

        for _, data in ipairs(islandMounts) do
            local mountID = data[1]
            local dropChanceDenominator = data[2]
            local maps = data[3]

            if not maps then
                table.insert(list, { mountID, dropChanceDenominator })
            else
                for _, allowedMapID in ipairs(maps) do
                    if allowedMapID == mapID then
                        table.insert(list, { mountID, dropChanceDenominator })
                        break
                    end
                end
            end
        end

        return list
    end

    function MC.ResetActiveIslands()
        MasterCollectorSV.Islands.activeIslands = {}
        MasterCollectorSV.Islands.resetTime = GetNextWeeklyReset()
        print("MasterCollector: Island rotation has reset. Starting a new cycle of expeditions!")
    end

    function MC.UpdateActiveIslands()
        local mapID = C_Map.GetBestMapForUnit("player")
        if not mapID then return nil end

        if GetServerTime() >= MasterCollectorSV.Islands.resetTime then
            MC.ResetActiveIslands()
        end

        local islandName = MC.islandMapIDs[mapID]
        if islandName then
            if not MasterCollectorSV.Islands.activeIslands[islandName] then
                MasterCollectorSV.Islands.activeIslands[islandName] = true
                print("MasterCollector: Added to Active Island Expeditions This Week: " .. islandName .. "\n")
            end
        end
    end

    local function GetActiveIslands()
        if not MasterCollectorSV.showIslandExpeditions then return nil end
        local output = MC.goldHex .. "Island Expeditions|r\n"
        local activeIslands = MasterCollectorSV.Islands.activeIslands
        local islandList = {}

        if next(activeIslands) then
            for islandName in pairs(activeIslands) do
                local mapID

                for id, name in pairs(MC.islandMapIDs) do
                    if name == islandName then
                        mapID = id
                        break
                    end
                end

                local mounts = GetMountsForIsland(mapID)
                local mountLines = {}
                local allCollected = true

                for _, data in ipairs(mounts) do
                    local mountID = data[1]
                    local dropChanceDenominator = data[2]
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                    local rarityAttemptsText, dropChanceText = "", ""

                    if not isCollected then
                        allCollected = false
                    end

                    if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                        if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                            local chance = 1 / dropChanceDenominator
                            local attempts = GetRarityAttempts(mountName) or 0
                            local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                        end
                    end

                    table.insert(mountLines, string.format("%sMount: |Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h %s%s", string.rep(" ", 8), mountID, MC.blueHex, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText))
                end

                if not (allCollected and MasterCollectorSV.hideBossesWithMountsObtained) then
                    if MasterCollectorSV.showMountName then
                        table.insert(islandList, "    " .. islandName .. "\n" .. table.concat(mountLines, "\n").. "\n")
                    else
                        table.insert(islandList, "    " .. islandName .. "\n")
                    end
                end
            end

            output = output .. table.concat(islandList, "\n")
        else
            output = output .. "    Visit each island this week to update the list.\n"
        end

        if #islandList ~= 0 then
            return output
        end
    end

    function MC.UpdateSavedInstances()
        if not MasterCollectorSV.showLockouts then return end
        local currentTime = time()
        local playerName, playerRealm = UnitName("player"), GetRealmName()
        local character = playerName .. "-" .. playerRealm


        MasterCollectorSV.instanceLocks = MasterCollectorSV.instanceLocks or {}
        MasterCollectorSV.realmLocks = MasterCollectorSV.realmLocks or {}
        MasterCollectorSV.realmLocks[playerRealm] = MasterCollectorSV.realmLocks[playerRealm] or {}
        MasterCollectorSV.instanceLocks[character] = MasterCollectorSV.instanceLocks[character] or {}

        local characterLocks = {}

        local function CleanExpired(lockList)
        if not lockList then return end
            for i = #lockList, 1, -1 do
                if lockList[i] and lockList[i].reset and lockList[i].reset <= currentTime then
                    table.remove(lockList, i)
                end
            end
        end

        local function FormatTime(seconds)
            local days = math.floor(seconds / 86400)
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

        CleanExpired(MasterCollectorSV.instanceLocks[character])
        CleanExpired(MasterCollectorSV.realmLocks[playerRealm])

        local lastRequestTime = 0
        local requestDelay = 60

        if currentTime - lastRequestTime >= requestDelay then
            RequestRaidInfo()
            RequestLFDPlayerLockInfo()
            lastRequestTime = currentTime
        end

        for i = 1, GetNumSavedInstances() do
            local name, _, reset, difficultyId, locked, _, _, _, _, _, _, _, _, instanceID = GetSavedInstanceInfo(i)
            if name and locked and reset then
                local difficultyName = GetDifficultyInfo(difficultyId)
                local resetTime = currentTime + reset

                table.insert(characterLocks, {name = name, reset = resetTime, difficulty = difficultyName, character = character, instanceID = instanceID})
            end
        end

        MasterCollectorSV.instanceLocks[character]= characterLocks

        local output = {}
        local realmLocks = MasterCollectorSV.realmLocks[playerRealm] or {}
        local charLocks = MasterCollectorSV.instanceLocks[character] or {}

        if #realmLocks > 0 then
            table.sort(realmLocks, function(a, b) return a.reset < b.reset end)

            local soonest = realmLocks[1].reset
            table.insert(output, string.format("%sRealm Lockouts:|r %d / 10 (Next expires in %s)", MC.goldHex, #realmLocks, FormatTime(soonest - currentTime)))

            for _, lock in ipairs(realmLocks) do
                local difficultyText = lock.difficulty and lock.difficulty ~= "" and (" (" .. lock.difficulty .. ")") or ""
                local characterText = lock.character or "Unknown"
                if lock.lfgID ~= nil then
                    local lfgName = GetLFGDungeonInfo(lock.lfgID)
                    table.insert(output, string.format("    %s - %s%s %s — Reset in %s", lfgName, lock.name, difficultyText, characterText, FormatTime(lock.reset - currentTime)))
                else
                    table.insert(output, string.format("    %s%s %s — Reset in %s", lock.name, difficultyText, characterText, FormatTime(lock.reset - currentTime)))
                end
            end
        else
            table.insert(output, string.format("%sRealm Lockouts:|r None", MC.goldHex))
        end

        if #charLocks > 0 then
            table.insert(output, string.format("%s\nCharacter Lockouts:|r %d", MC.goldHex, #charLocks))

            for _, lock in ipairs(charLocks) do
                table.insert(output, string.format("    %s %s — Reset in %s", lock.name, lock.difficulty, FormatTime(lock.reset - currentTime)))
            end
        else
            table.insert(output, string.format("%s\nCharacter Lockouts:|r None", MC.goldHex))
        end

        MC.latestInstanceOutput = table.concat(output, "\n")
    end

    local function displayDungeons()
        local lockoutText = MC.goldHex .. "Normal Instances|r"
        local lockoutsAdded = false

        for instanceID, bosses in pairs(dungeons) do
            local instanceName = EJ_GetInstanceInfo(instanceID)
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
                        local difficultiesText = string.format("%s|Hdifficulty:%d:%d|h%s|h|r", bossColor, instanceID, difficultyID, difficultyName)

                        dungeonText = dungeonText .. string.format("%s- %s|Hjournal:1:%d:0:0:0|h%s|h|r (%s)\n", string.rep(" ", 4), bossColor, bossID, bossName, difficultiesText)

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
                                            rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                                            dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                        end
                                    end
                                end
                                if MasterCollectorSV.showMountName then
                                    dungeonText = dungeonText .. string.format("%s- Mount:|r|Hmount:%d|h%s[%s]|h|r |Hwowhead:%d|h|T%s:16:16:0:0|t|h%s%s|r\n", string.rep(" ", 6), mountID, MC.blueHex, mountName, mountID, wowheadIcon, rarityAttemptsText, dropChanceText)
                                end
                            end
                        end
                    end
                end
            end
            if dungeonText ~= "" then
                local link = string.format("|Hinstance:%d|h%s[%s]|h|r", instanceID, MC.goldHex, instanceName)
                lockoutsAdded = true
                lockoutText = lockoutText .. "\n    " .. MC.goldHex .. link .. "|r:\n" .. dungeonText
            end
        end
        if lockoutsAdded and MasterCollectorSV.showNormalInstances then
            return lockoutText
        end
    end

    function MC.ProcessActivities()
        local grindsText = grindsText
        local activities = {MC.UpdateSavedInstances, displayDungeons, displayFishing, GetActiveIslands, displayAchievements, displayPVP, BuildProtoformOutput}

        for _, activity in ipairs(activities) do
            local result = activity()
            if activity == MC.UpdateSavedInstances then
                if MasterCollectorSV.showLockouts then
                    if MC.latestInstanceOutput and MC.latestInstanceOutput ~= "" then
                        grindsText = grindsText .. "\n" .. MC.latestInstanceOutput .. "\n"
                    end
                end
            else
                if result ~= nil and result ~= "" then
                    grindsText = grindsText .. "\n" .. result
                end
            end
        end

        if not grindsText or grindsText == "" then
            return MC.goldHex .. "We are all done here.... FOR NOW!|r"
        end

        return grindsText
    end

    function MC.UpdateGrindsMainFrameText()
        if MC.mainFrame and MC.mainFrame.text then
            MC.mainFrame.text:SetText(MC.ProcessActivities())
            MC.mainFrame.text:SetHeight(MC.mainFrame.text:GetContentHeight())
        end
    end
    MC.UpdateGrindsMainFrameText()
end