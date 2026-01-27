function MC.repsDisplay()
    local fontSize = MasterCollectorSV.fontSize
    MC.InitializeColors()
    if MC.currentTab ~= "Reputations" then return end

    if MC.mainFrame and MC.mainFrame.text then
        local font, _, flags = GameFontNormal:GetFont()
        MC.mainFrame.text:SetFont("P", font, fontSize, flags)
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
        ["Dragonflight Other Reputations"] = {
            { 2568 }, -- Glimmerogg Racer
            { 2517 }, -- Wrathion
            { 2518 }, -- Sabellian
            { 2553 }, -- Soridormi
            { 2544 }, -- Artisan's Consortium
            { 2550 }, -- Cobalt Assembly
            { 2526 }, -- Winterpelt Furbolg Language
        },
        ["The War Within Renowns"] = {
            { 2590 }, -- Council of Dornogal
            { 2594 }, -- The Assembly of the Deeps
            { 2570 }, -- Hallowfall Arathi
            { 2600 }, -- The Severed Threads
            { 2653 }, -- The Cartels of Undermine
            { 2685 }, -- Gallagio Loyalty Rewards Club
            { 2688 }, -- Flame's Radiance
            { 2658 }, -- K'aresh Trust
            { 2736 }, -- Manaforge Vandals
        },
        ["The War Within Other Reputations"] = {
            { 2601 }, -- The Weaver
            { 2605 }, -- The General
            { 2607 }, -- The Vizier
            { 2673 }, -- Bilgewater Cartel
            { 2677 }, -- Steamwheedle Cartel
            { 2675 }, -- Blackwater Cartel
            { 2671 }, -- Venture Company Cartel
            { 2669 }, -- Darkfuse Cartel
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
        "Dragonflight Renowns",
        "Dragonflight Other Reputations",
        "The War Within Renowns",
        "The War Within Other Reputations"
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
        [2590] = { 2213, 2148 },                                    -- Council of Dornogal
        [2594] = { 2209, 2162 },                                    -- The Assembly of the Deeps
        [2570] = { 2193, 2191 },                                    -- Hallowfall Arathi
        [2600] = { 2184, 2177 },                                    -- The Severed Threads
        [2653] = { 2277, 2280 },                                    -- The Cartels of Undermine
        [2685] = { 2279, 2276, 2278 },                              -- Gallagio Loyalty Rewards Club
        [2688] = { 2519 },                                          -- Flame's Radiance
        [2658] = { 2556, 2510 },                                    -- K'aresh Trust
        [2736] = { 1483, 2555 },                                    -- Manaforge Vandals
        [2601] = { 2171 },                                          -- The Weaver
        [2605] = { 2172 },                                          -- The General
        [2607] = { 2174 },                                          -- The Vizier
        [2673] = { 2272, 2295 },                                    -- Bilgewater Cartel
        [2677] = { 2294, 2281 },                                    -- Steamwheedle Cartel
        [2675] = { 2286, 2274 },                                    -- Blackwater Cartel
        [2671] = { 2284, 2289 },                                    -- Venture Company Cartel
        [2669] = { 2287, 2334 },                                    -- Darkfuse Cartel
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

    local fileAnima = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID
    local iconAnima = CreateTextureMarkup(fileAnima, 32, 32, 16, 16, 0, 1, 0, 1)
    local fileDFSupplies = C_CurrencyInfo.GetCurrencyInfo(2003).iconFileID
    local currencyName = C_CurrencyInfo.GetCurrencyInfo(2003).name
    local iconDFSupplies = CreateTextureMarkup(fileDFSupplies, 32, 32, 16, 16, 0, 1, 0, 1)
    local currentCovenantAnima = C_CurrencyInfo.GetCurrencyInfo(1813).quantity

    local mountCosts = {
        [176] = {currencyID = 0, cost = 2000000},
        [177] = {currencyID = 0, cost = 2000000},
        [178] = {currencyID = 0, cost = 2000000},
        [179] = {currencyID = 0, cost = 2000000},
        [180] = {currencyID = 0, cost = 2000000},
        [186] = {currencyID = 0, cost = 2000000},
        [187] = {currencyID = 0, cost = 2000000},
        [188] = {currencyID = 0, cost = 2000000},
        [189] = {currencyID = 0, cost = 2000000},
        [190] = {currencyID = 0, cost = 2000000},
        [191] = {currencyID = 0, cost = 2000000},
        [153] = {currencyID = 0, cost = 700000},
        [154] = {currencyID = 0, cost = 700000},
        [155] = {currencyID = 0, cost = 700000},
        [156] = {currencyID = 0, cost = 700000},
        [170] = {currencyID = 0, cost = 1000000},
        [172] = {currencyID = 0, cost = 1000000},
        [173] = {currencyID = 0, cost = 1000000},
        [174] = {currencyID = 0, cost = 1000000},
        [203] = {currencyID = 0, cost = 20000000},
        [258] = {currencyID = 0, cost = 10000000},
        [288] = {currencyID = 0, cost = 100000000},
        [249] = {currencyID = 0, cost = 20000000},
        [332] = {currencyID = 241, cost = 100}, -- Champion Seals
        [331] = {currencyID = 241, cost = 100}, -- Champion Seals
        [330] = {currencyID = 241, cost = 150}, -- Champion Seals
        [329] = {currencyID = 241, cost = 150}, -- Champion Seals
        [394] = {currencyID = 391, cost = 200}, -- Tol Barad Commendations
        [405] = {currencyID = 391, cost = 150}, -- Tol Barad Commendations
        [406] = {currencyID = 391, cost = 150}, -- Tol Barad Commendations
        [398] = {currencyID = 0, cost = 1000000},
        [399] = {currencyID = 0, cost = 1000000},
        [526] = {currencyID = 0, cost = 20000000},
        [527] = {currencyID = 0, cost = 20000000},
        [545] = {currencyID = 0, cost = 30000000},
        [546] = {currencyID = 0, cost = 30000000},
        [449] = {currencyID = 0, cost = 10000000},
        [504] = {currencyID = 0, cost = 100000000},
        [463] = {currencyID = 0, cost = 100000000},
        [505] = {currencyID = 0, cost = 15000000},
        [506] = {currencyID = 0, cost = 5000000},
        [507] = {currencyID = 0, cost = 20000000},
        [508] = {currencyID = 0, cost = 5000000},
        [510] = {currencyID = 0, cost = 32500000},
        [511] = {currencyID = 0, cost = 15000000},
        [448] = {currencyID = 0, cost = 25500000},
        [464] = {currencyID = 0, cost = 25500000},
        [465] = {currencyID = 0, cost = 25500000},
        [479] = {currencyID = 0, cost = 5000000},
        [480] = {currencyID = 0, cost = 25000000},
        [481] = {currencyID = 0, cost = 15000000},
        [768] = {currencyID = 0, cost = 25000000},
        [753] = {currencyID = 823, cost = 150000}, -- Apexis Crystals
        [905]= { paragon = true }, [941] = { paragon = true }, [942]= { paragon = true }, [943]= { paragon = true }, [944]= { paragon = true },
        [939] = {currencyID = 0, cost = 100000000},
        [964] = {currencyID = 0, cost = 100000000},
        [965] = {currencyID = 0, cost = 100000000},
        [966] = {currencyID = 0, cost = 100000000},
        [967] = {currencyID = 0, cost = 100000000},
        [968] = {currencyID = 0, cost = 100000000},
        [983] = { paragon = true }, [984]= { paragon = true }, [985]= { paragon = true },
        [932] = {currencyID = 0, cost = 5000000000},
        [926] = {currencyID = 0, cost = 100000000},
        [1060] = {currencyID = 0, cost = 900000000},
        [1010] = {currencyID = 0, cost = 100000000},
        [1064] = {currencyID = 0, cost = 900000000},
        [1061] = {currencyID = 0, cost = 100000000},
        [1059] = {currencyID = 0, cost = 900000000},
        [1015] = {currencyID = 0, cost = 100000000},
        [1063] = {currencyID = 0, cost = 900000000},
        [1058] = {currencyID = 0, cost = 100000000},
        [958] = {currencyID = 0, cost = 900000000},
        [1016] = {currencyID = 0, cost = 100000000},
        [1062] = {currencyID = 0, cost = 900000000},
        [1231] = {currencyID = 1721, cost = 250}, -- Manapearl
        [1230] = {currencyID = 1721, cost = 250}, -- Manapearl
        [1237] = { paragon = true },
        [1254] = {currencyID = 0, cost = 5242880000},
        [1318] = {currencyID = 0, cost = 240000000},
        [1350] = {currencyID = 0, cost = 300000000},
        [1361] = {currencyID = 0, cost = 300000000},
        [1375] = { paragon = true }, [1428] = { paragon = true },
        [1421] = {currencyID = 0, cost = 300000000},
        [1425] = {currencyID = 0, cost = 300000000},
        [1420] = {currencyID = 1813, cost = 5000}, -- Anima
        [1436] = {currencyID = 1767, cost = 1000}, -- Stygia
        [1486] = {currencyID = 1767, cost = 1000}, -- Stygia
        [1491] = {currencyID = 1767, cost = 1000}, -- Stygia
        [1497] = {currencyID = 1767, cost = 1000}, -- Stygia
        [1505] = {currencyID = 1767, cost = 5000}, -- Stygia
        [1508] = { paragon = true }, [1455] = { paragon = true },
        [1450] = {currencyID = 1931, cost = 5000}, -- Catalogued Research
        [1454] = { paragon = true },
        [1501] = { paragon = true },
        [1522] = { paragon = true },
        [1529] = {currencyID = 1813, cost = 2020}, -- Anima
        [1825] = {byFaction = {
                    [2517] = { achievementID = 19466 },
                    [2518] = { achievementID = 19466 },
                    [2553] = { achievementID = 19466 },
                    [2544] = { achievementID = 19466 },
                    [2550] = { achievementID = 19466 },
                    [2526] = { achievementID = 19466 },
                }
            },
        [2114] = {byFaction = {
                    [2432] = { achievementID = 14656 },
                    [2472] = { achievementID = 15069 },
                    [2478] = { achievementID = 15220 },
                    [2470] = { achievementID = 15035 },
                    [2463] = { achievementID = 14775 },
                }
            },
        [2171] = {currencyID = 3056, cost = 2020}, -- Kej
        [2172] = {currencyID = 3056, cost = 2020}, -- Kej
        [2714] = {currencyID = 3056, cost = 2020}, -- Kej
        [2272] = {currencyID = 2815, cost = 8125}, -- Resonance Crystals
        [2294] = {currencyID = 2815, cost = 11375}, -- Resonance Crystals
        [2286] = {currencyID = 2815, cost = 8125}, -- Resonance Crystals
        [2284] = {currencyID = 2815, cost = 8125}, -- Resonance Crystals
        [2287] = {currencyID = 2815, cost = 8125}, -- Resonance Crystals
        [2295] = { paragon = true }, [2281] = { paragon = true }, [2274]= { paragon = true }, [2289] = { paragon = true }, [2334] = { paragon = true },
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

    local TWWRenownMountReq = {
        [2590] = { {2213, 18, 8125}, {2148, 23, 11375} },               -- Council of Dornogal
        [2594] = { {2209, 17, 8125}, {2162, 19, 11375} },               -- The Assembly of the Deeps
        [2570] = { {2193, 21, 8125}, {2191, 23, 11375} },               -- Hallowfall Arathi
        [2600] = { {2184, 22, 2815}, {2177, 23, 3940} },                -- The Severed Threads (bought with Kej)
        [2653] = { {2277, 15, 8125}, {2280, 19, 11375} },               -- The Cartels of Undermine
        [2685] = { {2279, 8, 500 }, {2276, 17, 500}, {2278, 20, 777} }, -- Gallagio Loyalty Rewards Club (bought with gold)
        [2688] = { {2519, 9, 8125} },                                   -- Flame's Radiance
        [2658] = { {2556, 15, 8125}, {2510, 19, 11375} },               -- K'aresh Trust
        [2736] = { {1483, 8, 0}, {2555, 14, 0} },                       -- Manaforge Vandals (auto reward?)
    }

    local function HandleBodyguardRep(factionID)
        local friendshipInfo = C_GossipInfo.GetFriendshipReputation(factionID)
        if friendshipInfo and friendshipInfo.standing and friendshipInfo.maxRep then
            local name = friendshipInfo.name
            local standingLabel = friendshipInfo.reaction or "Unknown"
            local currentStanding = friendshipInfo.standing or 0
            local nextThreshold = friendshipInfo.maxRep
            local colorHex = GetReputationColor()

            return string.format("  - %s|r%s%s%s   %d/ %d|r\n", name, colorHex, string.rep(" ", 9), standingLabel, currentStanding, nextThreshold)
        end
        return ""
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
            for _, covenant in pairs(characterData.covenants) do
                totalAnima = totalAnima + covenant.covenantAnima
            end
        end

        return totalAnima
    end

    local totalAnima = CalculateTotalAnima(characterKey)

    function MC.UpdateCovenantDisplay()
        local characterKey = GetCharacterKey()
        local activeCovenantID = C_Covenants.GetActiveCovenantID()
        local currentRenownLevel = C_CovenantSanctumUI.GetRenownLevel()

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
            iconAnima
        )

        local function GetCovenantMountsText(covenantID)
            local mountsText = string.format("%s%sRenown Mounts:|r\n", MC.goldHex, string.rep(" ", 6))
            for _, mountData in ipairs(covRenownMounts[covenantID] or {}) do
                local mountID, requiredRenownLevel, requiredAnima = mountData[1], mountData[2], mountData[3]
                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                    if requiredAnima ~= 0 then
                        mountsText = mountsText .. string.format("%s- %s|Hmount:%d|h[%s]|h|r (Requires Renown %d)   %s%s Anima %s Required|r\n", string.rep(" ", 9), MC.blueHex, mountID, mountName, requiredRenownLevel, MC.goldHex, requiredAnima, iconAnima)
                    else
                        mountsText = mountsText .. string.format("%s- %s|Hmount:%d|h[%s]|h|r (Requires Renown %d)\n", string.rep(" ", 9), MC.blueHex, mountID, mountName, requiredRenownLevel)
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
                        covenantText = covenantText .. string.format("%s   - %s|r: Switch Covenants to get Covenant Details\n", MC.goldHex, covenantName)
                    else
                        covenantText = covenantText .. string.format("%s   - %s|r: Renown %d / %d   %sReservoir Anima: %d %s|r\n", MC.goldHex, covenantName,
                            otherCovenantData.renownLevel,
                            otherCovenantData.maxRenownLevel,
                            MC.goldHex,
                            otherCovenantData.covenantAnima,
                            iconAnima)

                        if MasterCollectorSV.showMountName then
                            covenantText = covenantText .. GetCovenantMountsText(covenantID) .. "\n"
                        end
                    end
                end
            end

            covenantText = covenantText .. string.format("%sTotal Anima for %s is: %s|r %s\n", MC.goldHex, characterKey, totalAnima, iconAnima)

            local _, achieveName, _, achieved = GetAchievementInfo(15646)
            if not MasterCollectorSV.hideBossesWithMountsObtained or not achieved then
                if not activeCovenantID or activeCovenantID == 0 then
                    displayText = "|cffff0000Error: Unable to Load Covenant, Select a Covenant and/or Reload UI to get Covenant details|r\n\n"
                else
                    displayText = displayText .. string.format("%s\n%sAll Covenants Required at Level 80 for %s for Back from Beyond Meta Achievement|r\n\n", covenantText, MC.goldHex, achieveName)
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
            (expansion == "Dragonflight Other Reputations" and not MasterCollectorSV.showDFOtherReps) or
            (expansion == "The War Within Renowns" and not MasterCollectorSV.showTWWRenownReps) or
            (expansion == "The War Within Other Reputations" and not MasterCollectorSV.showTWWOtherReps) then
            shouldProcessExpansion = false
        end

        if shouldProcessExpansion then
            for _, factionData in ipairs(factions) do
                local factionID, factionType, specialCategory = unpack(factionData)
                local mountIDs = factionMounts[factionID]

                if expansion == "Dragonflight Renowns" then
                    local renownLevel = C_MajorFactions.GetCurrentRenownLevel(factionID)
                    local factionName = C_Reputation.GetFactionDataByID(factionID).name
                    local renownText = string.format("  %s - %s|r: Renown %d |r\n", MC.goldHex, factionName, renownLevel)
                    local mountsText, uncollectedMounts = "  ", {}

                    if DFRenownMountReq[factionID] then
                        if (factionID == 2503) or (factionID == 2510) then
                            mountsText = ""
                        else
                            mountsText = MC.goldHex .. string.rep(" ", 6) .. "Mounts:|r\n"

                            for _, mountInfo in ipairs(DFRenownMountReq[factionID]) do
                                local mountID, requiredRenownLevel, requiredCurrency = unpack(mountInfo)
                                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                                local buyorearntxt = ""

                                if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                    if mountID == 1825 then
                                        local _, achieveName, _, earned = GetAchievementInfo(19466)

                                        if not earned then
                                            mountsText = mountsText .. string.format("\n%sRenown %s Required for %s for A World Awoken Meta Achievement|r\n%sMount: %s|Hmount:%d|h[%s]|h|r\n\n", string.rep(" ", 9), MC.goldHex, requiredRenownLevel, achieveName, string.rep(" ", 9), MC.blueHex, mountID, mountName)
                                        end

                                    else
                                        local mountData = {
                                            [1615] = { pairID = 1616, questID = 70821, text = MC.goldHex .. string.rep(" ", 9) .. "1 mount is a quest reward; the other costs 5x Iridescent Plume, 20x Contoured Fowlfeather|r\n" },
                                            [1657] = { pairID = 1659, questID = 70972, text = MC.goldHex .. string.rep(" ", 9) .. "1 mount is a quest reward; the other costs 2x Mastodon Tusk, 2x Aquatic Maw|r\n" },
                                            [1653] = { pairID = 1655, questID = 72328, text = MC.goldHex .. string.rep(" ", 9) .. "\n1 mount is a quest reward; the other costs 5x Mastodon Tusk, 5x Aquatic Maw|r\n" }
                                        }

                                        local mountsInfo = mountData[mountID]
                                        if mountsInfo and C_QuestLog.IsQuestFlaggedCompleted(mountsInfo.questID) then
                                            buyorearntxt = mountsInfo.text
                                        end

                                        mountsText = mountsText .. string.format("%s%s- %s|Hmount:%d|h[%s]|h|r (Requires Renown %d)\n%s%s%s / %s %s %s Required|r\n", buyorearntxt, string.rep(" ", 9), MC.blueHex, mountID, mountName, requiredRenownLevel, string.rep(" ", 9), MC.goldHex, fileDFSupplies, requiredCurrency, currencyName, iconDFSupplies)
                                    end
                                end
                            end
                        end

                        if not MasterCollectorSV.hideBossesWithMountsObtained or #uncollectedMounts > 0 then
                            factionText = factionText .. renownText
                            if MasterCollectorSV.showMountName then
                                factionText = factionText .. mountsText
                            end
                        end
                    end
                elseif expansion == "The War Within Renowns" then
                    local TWWrenownLevel = C_MajorFactions.GetCurrentRenownLevel(factionID)
                    local TWWfactionName = C_Reputation.GetFactionDataByID(factionID).name
                    local TWWrenownText = string.format("  %s - %s|r: Renown %d |r\n", MC.goldHex, TWWfactionName, TWWrenownLevel)
                    local TWWmountsText, TWWuncollectedMounts = "  ", {}

                    if TWWRenownMountReq[factionID] then
                        TWWmountsText = MC.goldHex .. string.rep(" ", 6) .. "Mounts:|r\n"

                        for _, TWWmountInfo in ipairs(TWWRenownMountReq[factionID]) do
                            local mountID, TWWrequiredRenownLevel, TWWrequiredCurrency = unpack(TWWmountInfo)
                            local TWWmountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                            local currencyInfo
                            local showCurrencyLine = true

                            if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                if not isCollected then
                                    table.insert(TWWuncollectedMounts, TWWmountName)
                                end

                                if factionID == 2600 then
                                    currencyInfo = C_CurrencyInfo.GetCurrencyInfo(3056)
                                elseif factionID == 2685 then
                                    currencyInfo = { quantity = moneyString, iconFileID = C_CurrencyInfo.GetCoinTextureString(TWWrequiredCurrency*10000) }
                                else
                                    currencyInfo = C_CurrencyInfo.GetCurrencyInfo(2815)
                                    if TWWrequiredCurrency == 0 then
                                        showCurrencyLine = false
                                    end

                                    local currentTWWCurrency = currencyInfo.quantity
                                    local fileTWWCurrency = currencyInfo.iconFileID
                                    currencyName = currencyInfo.name
                                    local iconTWWCurrency = CreateTextureMarkup(fileTWWCurrency, 32, 32, 16, 16, 0, 1, 0, 1)
                                    local currencyText = string.format("%s%s%s / %s %s %s Required|r\n", string.rep(" ", 9), MC.goldHex, currentTWWCurrency, TWWrequiredCurrency, currencyName, iconTWWCurrency)

                                    TWWmountsText = TWWmountsText .. string.format("%s- %s|Hmount:%d|h[%s]|h|r (Requires Renown %d)\n%s", string.rep(" ", 9), MC.blueHex, mountID, TWWmountName, TWWrequiredRenownLevel, showCurrencyLine and currencyText or "")
                                end
                            end
                        end

                        if not MasterCollectorSV.hideBossesWithMountsObtained or #TWWuncollectedMounts > 0 then
                            factionText = factionText .. TWWrenownText
                            if MasterCollectorSV.showMountName then
                                factionText = factionText .. TWWmountsText
                            end
                        end
                    end
                else
                    if not factionType or (factionType == "Alliance Only" and playerFaction == "Alliance") or (factionType == "Horde Only" and playerFaction == "Horde") then
                        local colorHex
                        if specialCategory == "Bodyguard" then
                            local bodyguardRepText = HandleBodyguardRep(factionID)
                            local mountIDsArray = factionMounts[factionID]

                            local mountNames = {}
                            local anyMissing   = false
                            for _, mountID in ipairs(mountIDsArray) do
                                local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                                if mountName then
                                    table.insert(mountNames, {id = mountID, name = mountName})
                                end
                                if not isCollected then
                                    anyMissing = true
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
                                mountsText = string.format("%sRank 20 Mount: %s", string.rep(" ", 9), table.concat(linkedMounts, ", "))
                            end

                            if not MasterCollectorSV.hideBossesWithMountsObtained or anyMissing then
                                factionText = factionText .. string.format("%s%s%s%s|r\n", factionText, MC.goldHex, bodyguardRepText, mountsText)
                            end

                        elseif factionID == 2463 then
                            local friendFactionDetails = C_GossipInfo.GetFriendshipReputation(factionID)
                            local friendName = friendFactionDetails.name
                            local friendReaction = friendFactionDetails.reaction
                            colorHex = GetFriendshipColor(friendReaction)
                            local friendCurrentStanding = friendFactionDetails.standing or 0
                            local friendNextThreshold = friendFactionDetails.nextThreshold
                            local _, achieveName, _, earned = GetAchievementInfo(14775)
                            local friendMount, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(2114)

                            if not MasterCollectorSV.hideBossesWithMountsObtained or not isCollected then
                                factionText = factionText .. string.format("%s  - %s|r", MC.goldHex, friendName)

                                local function AddMountInfo()
                                    if not MasterCollectorSV.showMountName then return "" end
                                    local mountText = string.format("%sAchievement Mount: %s|Hmount:%d|h[%s]|h|r\n", string.rep(" ", 9), MC.blueHex, 2114, friendMount)
                                    local metaAchieve = " for Back from Beyond Meta Achievement"

                                    if not earned then
                                        return string.format("%s%s%sRequires %s%s|r\n", mountText, MC.goldHex, string.rep(" ", 9), achieveName, metaAchieve)
                                    else
                                        return string.format("%s%s%s%s%s Complete|r\n", mountText, MC.goldHex, string.rep(" ", 9), achieveName, metaAchieve)
                                    end
                                end

                                local reactionLine = (friendReaction == "Exalted") and (string.format("%s%s%s|r\n", colorHex, string.rep(" ", 9), friendReaction)) or (string.format("%s%s%s / %s%s%s|r\n", colorHex, string.rep(" ", 9), friendCurrentStanding, friendNextThreshold, string.rep(" ", 9), friendReaction))

                                factionText = factionText .. reactionLine .. AddMountInfo()
                            end
                        else
                            local textIndent = string.rep(" ", 9)

                            local factionHooks = {
                                [1105] = function(MasterCollectorSV)
                                    if not MasterCollectorSV.showMountName then return "" end
                                    if not MasterCollectorSV.showRarityDetail then return "" end
                                    local attempts = GetRarityAttempts("Cracked Egg") or 0
                                    local denom = 20
                                    local chance = 1 / denom
                                    local cumulative = 100 * (1 - math.pow(1 - chance, attempts))
                                    return string.format("%s%s(Attempts: %d/%d = %.2f%%)|r\n", MC.goldHex, textIndent, attempts, denom, cumulative)
                                end,
                            }

                            local function iconSize(fileID)
                                if not fileID then return "" end
                                return CreateTextureMarkup(fileID, 32, 32, 16, 16, 0, 1, 0, 1)
                            end

                            local function standingLabelFor(factionID, reaction)
                                local mapByFaction = {
                                    [2432] = venariRepRename,
                                    [2472] = archivistsCodexRepRename,
                                    [2568] = glimmerogRepRename,
                                    [2553] = soridormiRepRename,
                                    [2517] = blkDragonRepRename,
                                    [2518] = blkDragonRepRename,
                                    [2544] = artisansRepRename,
                                    [2550] = cobaltRepRename,
                                }

                                local m = mapByFaction[factionID]

                                if m and m[reaction] and m[reaction][1] then
                                    return m[reaction][1]
                                end

                                return _G["FACTION_STANDING_LABEL"..tostring(reaction)] or "Unknown"
                            end

                            local function coinString(amount)
                                return C_CurrencyInfo.GetCoinTextureString(amount or 0)
                            end

                            local function getParagonProgress(factionID)
                                local current, threshold, _, hasPending = C_Reputation.GetFactionParagonInfo(factionID)
                                if not current or not threshold then return nil end

                                local completed = math.floor(current / threshold)
                                if hasPending and completed > 0 then
                                    current = current - threshold
                                    completed = completed - 1
                                end

                                local remainder = current % threshold
                                local pct = (remainder / threshold) * 100
                                if completed < 0 then completed = 0 end

                                return { threshold = threshold, remainder = remainder, completed = completed, percent = pct }
                            end

                            local function renderMountLine(factionID, mountID, MasterCollectorSV, moneyString)
                                local rule = mountCosts[mountID] or {}
                                if rule.byFaction and rule.byFaction[factionID] then
                                    for k, v in pairs(rule.byFaction[factionID]) do rule[k] = v end
                                end

                                local label = rule.paragon and "Paragon Mount" or rule.achievementID and "Achievement Mount" or ((rule.standing and (rule.standing.." Mount")) or "Exalted Mount")

                                local mountName = MasterCollectorSV.showMountName and (C_MountJournal.GetMountInfoByID(mountID) or ("Mount "..mountID)) or ""

                                local text = textIndent .. label .. (mountName ~= "" and (": "..(string.format("%s|Hmount:%d|h[%s]|h|r", MC.blueHex, mountID, mountName))) or "") .. "\n"
                                local paragonHex = string.format("|cff%02x%02x%02x", 0, 1 * 255, 1 * 255)

                                if rule.achievementID then
                                    local _, achieveName, _, earned = GetAchievementInfo(rule.achievementID)
                                    local metaAchieve

                                    if mountID == 1825 then
                                        metaAchieve = " for A World Awoken Meta Achievement"
                                    else
                                        metaAchieve = " for Back from Beyond Meta Achievement"
                                    end

                                    if not earned then
                                        text = text .. string.format("%s%sRequires %s%s|r\n", MC.goldHex, string.rep(" ", 9), achieveName, metaAchieve)
                                    else
                                        text = text .. string.format("%s%s%s%s Complete|r\n", MC.goldHex, string.rep(" ", 9), achieveName, metaAchieve)
                                    end
                                end

                                if rule.paragon then
                                    local p = getParagonProgress(factionID)
                                    if p then
                                        text = text .. string.format("%s%s%d / %d (Paragon Chest Attempts: %d)|r\n", paragonHex, textIndent, p.remainder, p.threshold, p.completed)
                                    end
                                end

                                if rule.cost and rule.currencyID then
                                    if rule.currencyID == 0 then
                                        text = text .. string.format("%s%s%s / %s Required|r\n", MC.goldHex, textIndent, moneyString, coinString(rule.cost))
                                    else
                                        local ci = C_CurrencyInfo.GetCurrencyInfo(rule.currencyID) or {}
                                        local have = ci.quantity or 0
                                        text = text .. string.format("%s%s%s / %s %s Required|r\n", MC.goldHex, textIndent, have, rule.cost, iconSize(ci.iconFileID))
                                    end
                                end

                                return text
                            end

                            local function renderFactionBlock(factionID, mountIDs, MasterCollectorSV, moneyString)
                                local factionDetails = C_Reputation.GetFactionDataByID(factionID)
                                if not factionDetails then return "" end

                                local name            = factionDetails.name
                                local reaction        = factionDetails.reaction or 4
                                local currentStanding = factionDetails.currentStanding or 0
                                local nextThreshold   = factionDetails.nextReactionThreshold
                                colorHex        = GetReputationColor(reaction)
                                local allCollected = true
                                local anyMounts    = (#mountIDs > 0)

                                for _, mountID in ipairs(mountIDs) do
                                    local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                                    if not isCollected then allCollected = false end
                                end

                                if MasterCollectorSV.hideBossesWithMountsObtained and anyMounts and allCollected then return "" end
                                local out = string.format("%s  - %s|r", MC.goldHex, name)
                                local standingLabel = standingLabelFor(factionID, reaction)

                                if reaction ~= 8 then
                                    out = out .. string.format("%s\n%s%s%s%s / %s|r\n", colorHex, textIndent, standingLabel, textIndent, currentStanding, (nextThreshold or ""))
                                else
                                    out = out .. string.format("%s\n%s%s|r\n", colorHex, textIndent, standingLabel)
                                end

                                local hook = factionHooks[factionID]

                                if hook then out = out .. (hook(MasterCollectorSV) or "") end

                                if MasterCollectorSV.showMountName and anyMounts then
                                    for _, mountID in ipairs(mountIDs) do
                                        out = out .. renderMountLine(factionID, mountID, MasterCollectorSV, moneyString)
                                    end
                                end

                                return out
                            end

                            factionText = factionText .. renderFactionBlock(factionID, mountIDs, MasterCollectorSV, moneyString)
                        end
                    end
                end
            end
        end
        if factionText ~= "" then
            displayText = displayText .. string.format("%s%s|r\n", MC.goldHex, expansion)
            displayText = displayText .. string.format("%s\n", factionText)
        end
    end

    if displayText == "" then displayText = MC.goldHex .. "We are all done here.... FOR NOW!|r" end
    if MC.mainFrame and MC.mainFrame.text then MC.mainFrame.text:SetText(displayText) MC.mainFrame.text:SetHeight(MC.mainFrame.text:GetContentHeight()) end
end