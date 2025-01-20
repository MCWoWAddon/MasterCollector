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
            [1182] = {                                            -- The Necrotic Wake
                { 2396, { 1406 }, 23, "Marrowfang's Reins", 100 } -- Nalthor the Rimebinder (Mythic)
            },
        },
        ["Burning Crusade Dungeons"] = {
            [252] = {                                              -- Sethekk Halls
                { 542, { 185 }, 2, "Reins of the Raven Lord", 67 } -- Anzu (Heroic)
            },
            [249] = {                                              -- Magister's Terrace
                { 533, { 213 }, 2, "Swift White Hawkstrider", 33 } -- 	Kael'thas Sunstrider (Heroic)
            }
        },
        ["Wrath of Lich King Dungeons"] = {
            [286] = {                                                    -- Utgarde Pinnacle
                { 643, { 264 }, 2, "Reins of the Blue Proto-Drake", 77 } -- Skadi the Ruthless (Heroic)
            }
        },
        ["Cataclysm Dungeons"] = {
            [76] = {                                                 -- Zul'Gurub
                { 181, { 411 }, 2, "Swift Zulian Panther",    100 }, -- High Priestess Kilnara (Heroic)
                { 176, { 410 }, 2, "Armored Razzashi Raptor", 100 }  -- Bloodlord Mandokir (Heroic)
            }
        }
    }

    local rares = {
        ["WoD Tanaan Jungle Rares"] = {
            { { 39287, 39288, 39289, 39290 }, { 643, 622, 611 }, "Armored Razorback/Warsong Direfang/Tundra Icehoof", 30, "Deathtalon/Terrorfist/Doomroller/Vengeance" },
        },
        ["Legion Argus Rares"] = {
            { { 48705 },               { 973 },                "Lambent Mana Ray",     30, "Venomtail Skyfin" },
            { { 48821 },               { 955 },                "Vile Fiend",           30, "Houndmaster Kerrax" },
            { { 49183 },               { 979 },                "Crimson Slavermaw",    30, "Blistermaw" },
            { { 48810, 48809 },        { 981 },                "Biletooth Gnasher",    30, "Vrax'thul/Puscilla" },
            { { 48721 },               { 980 },                "Acid Belcher",         30, "Skreeg" },
            { { 48695 },               { 970 },                "Maddened Chaosrunner", 30, "Wrangler Kravos" },
            { { 48712, 48667, 48812 }, { 974, 975, 976, 906 }, "Fel-Spotted Egg",      16, "Sabuul/Naroua/Varga" }
        },
        ["BfA Arathi Highlands Rares"] = {
            { { 53091, 53517 }, { 1185 }, "Witherbark Direwing",     33, "Nimar the Slayer" },
            { { 53014, 53518 }, { 1182 }, "Lil' Donkey",             33, "Overseer Krix" },
            { { 53022, 53526 }, { 1183 }, "Skullripper",             33, "Skullripper" },
            { { 53083, 53504 }, { 1180 }, "Swift Albino Raptor",     33, "Beastrider Kama" },
            { { 53085 },        { 1174 }, "Highland Mustang",        33, "Doomrider Helgrim",     "Alliance Only", },
            { { 53088 },        { 1173 }, "Broken Highland Mustang", 33, "Knight-Captain Aldrin", "Horde Only" }
        },
        ["BfA Darkshore Rares"] = {
            { { 54695, 54696 }, { 1200 }, "Ashenvale Chimaera",           20, "Alash'anir" },
            { { 54883 },        { 1199 }, "Caged Bear",                   20, "Agathe Wyrmwood",   "Alliance Only" },
            { { 54890 },        { 1199 }, "Blackpaw",                     20, "Blackpaw",          "Horde Only" },
            { { 54886 },        { 1205 }, "Captured Kaldorei Nightsaber", 20, "Croz Bloodrage",    "Alliance Only" },
            { { 54892 },        { 1205 }, "Kaldorei Nightsaber",          20, "Shadowclaw",        "Horde Only" },
            { { 54431 },        { 1203 }, "Umber Nightsaber",             20, "Athil Dewfire",     "Horde Only" },
            { { 54277 },        { 1203 }, "Captured Umber Nightsaber",    20, "Moxo the Beheader", "Alliance Only" }
        },
        ["BfA Mechagon Rares"] = {
            { { 55811 }, { 1248 }, "Rusted Keys to the Junkheap Drifter", 200, "Rustfeather" },
            { { 55512 }, { 1229 }, "Rusty Mechanocrawler",                333, "Arachnoid Harvester" }
        },
        ["BfA Nazjatar Rares"] = {
            { { 56298 }, { 1257 }, "Silent Glider", 200, "Soundless" }
        },
        ["BfA Uldum Rares"] = {
            { { 57259 }, { 1314 }, "Reins of the Drake of the Four Winds", 100, "Ishak of the Four Winds" },
            { { 58696 }, { 1319 }, "Malevolent Drone",                     100, "Corpse Eater" },
            { { 57273 }, { 1317 }, "Waste Marauder",                       33,  "Rotfeaster" }
        },
        ["BfA Vale of Eternal Blossoms Rares"] = {
            { { 57363 }, { 1328 }, "Xinlao",                       33, "Xinlao" },
            { { 57344 }, { 1297 }, "Clutch of Ha-Li",              33, "Ha-Li" },
            { { 57345 }, { 1327 }, "Ren's Stalwart Hound",         33, "Houndlord Ren" },
            { { 57346 }, { 1313 }, "Pristine Cloud Serpent Scale", 50, "Rei Lun" }
        },
        ["SL Rares (non-Covenant Specific)"] = {
            { { 59869 },                                           { 1379 }, "Endmire Flyer Tether",                        100, "Famu the Infinite" },
            { { 61720 },                                           { 1410 }, "Slime-Covered Reins of the Hulking Deathroc", 33,  "Violet Mistake" },
            { { 58851 },                                           { 1373 }, "Gorespine",                                   50,  "Nerissa Heartless" },
            { { 58889 },                                           { 1372 }, "Blisterback Bloodtusk",                       33,  "Warbringer Mal'Korak" },
            { { 62786, 62786, 62786, 62786, 62786, 62786, 62786 }, { 1437 }, "Gnawed Reins of the Battle-Bound Warhound",   100, "Azmogal/Unbreakable Urtz/Xantuth the Blighted/Mistress Dyrax/Devmorta/Ti'or/Sabriel the Bonecleaver" },
            { { 58259 },                                           { 1391 }, "Impressionable Gorger Spawn",                 100, "Worldedge Gorger" },
            { { 60933 },                                           { 1426 }, "Ascended Skymane",                            20,  "Cache of the Ascended" },
            { { 64246 },                                           { 1514 }, "Rampaging Mauler",                            50,  "Konthrogz the Obliterator" },
            { { 64455 },                                           { 1509 }, "Garnet Razorwing",                            100, "Reliwik the Defiant" },
            { { 64233 },                                           { 1506 }, "Crimson Shardhide",                           100, "Malbog" },
            { { 64164 },                                           { 1502 }, "Fallen Charger's Reins",                      100, "Fallen Charger" },
            { { 65585 },                                           { 1584 }, "Iska's Mawrat Leash",                         100, "Rhuv, Gorger of Ruin" }
        },
        ["DF Rares"] = {
            { 75333, 1732, "Cobalt Shalewing", 100, "Karokta" }
        }
    }

    local lockoutOrder = {
        "Shadowlands Dungeons",
        "Cataclysm Dungeons",
        "Wrath of Lich King Dungeons",
        "Burning Crusade Dungeons",
    }

    local rareOrder = {
        "DF Rares",
        "SL Rares (non-Covenant Specific)",
        "BfA Vale of Eternal Blossoms Rares",
        "BfA Uldum Rares",
        "BfA Nazjatar Rares",
        "BfA Mechagon Rares",
        "BfA Darkshore Rares",
        "BfA Arathi Highlands Rares",
        "Legion Argus Rares",
        "WoD Tanaan Jungle Rares",
    }

    local DFDreamInfusion = { -- Dream Infusion Daily - Trade 1x Dream Infusion
        { { 1657, 1653, 1546, 1658, 1654, 1656, 1659, 1655 }, 1837,
            [[
        Requires an Ottuk Mount Learnt.

        Obtained from|r:
        - Renown 25 with Iskaara
        - Otto Puzzle
        - Ring/Neck Collection from Raids/Dungeons
        ]]
        },
        { { 1736, 1735, 1732, 1730, 1738, 1737 }, 1939,
            [[
        Requires a Shalewing Mount Learnt.

        Obtained from|r:
        - Renown 18 with Loamm Niffen
        - Barter Bricks/Boulders Currency
        - Researchers Under Fire Rewards
        - Karokta Rare Drop
        ]]
        },
        { { 1612, 1644, 1645, 1603 }, 1938,
            [[
        Requires a Magmammoth Mount Learnt.

        Obtained from|r:
        - Dreamsurges
        - Researchers Under Fire Currency Reward
        - Glory of the Vault Raider Achievement
        - Obsidian Citadel Max Rep Items
        ]]
        },
        { { 1619, 1622 }, 1940,
            [[
        Requires a Salamanther Mount Learnt.

        Obtained from|r:
        - Elemental Storm Currency
        - Forbidden Reach Elites Rare Drop
        ]]
        },
        { { 1808, 1811, 1810, 1809 }, 1839,
            [[
        Requires a Dreamstag Mount Learnt.

        Obtained from|r:
        - Renown 17 with The Dream Wardens
        - Blooming Dreamseed Currency
        ]]
        },
        { { 1834, 1835, 1833 }, 1838,
            [[
        Requires a Dreamtalon Mount Learnt.

        Obtained from|r:
        - Emerald Dream Seedling 23 days Blooming
        - Blooming Dreamseed Currency
        ]]
        },
    }

    local dailyDFActivities = {
        { { { 65906, 65901, 65907, 65770, 65761, 65711, 66676, 71196 }, { 71197 }, { 71198 }, { 71199 }, { 71195 }, { 71209 } }, { 1639 }, 6,   "Lizi Quests", },
        { { 77677, 78398, 77697, 77711 },                                                                                        { 1834 }, 23,  "Emerald Dream Seedling" },
        { { 73553, 73552, 73551, 73548, 75015 },                                                                                 { 1736 }, nil, "Ritual Offerings & Waterlogged Bundle Looted" },
        { { 75466, 76076, 76244, 75971, 75991, 76246, 76269, 75989, 75657, 76162, 75970, 75988, 76251, 76266 },                  nil,      nil, "Eon's Fringe Daily" },
        { { { 72664, 72665, 72666, 72667, 72668, 73021, 72454, 72455 }, { 72457, 72458 }, { 72459 }, { 72460, 72461, 72989, 72990 }, { 72991, 72992 },
            { 72993 }, { 72994, 72995, 72996, 72997 }, { 72998, 72999 }, { 73000 }, { 73001, 73002, 73003, 73004 }, { 73005, 73006 }, { 73007 },
            { 73008, 73009, 73010, 73011 }, { 73012, 73013 }, { 73014 }, { 73015, 73016 } }, nil, 16,
            "Little Scales Daycare Quests" }
    }

    local dailyNFActivities = {
        { 14353, 1332, 5000 } -- Silky Shimmermoth (must have Anima Conductor & be NF Covenant)
    }

    local dailySLActivities = {
        { { 61839, 61840, 61842, 61844, 62045, 62046 },        { 1391 }, 6,  "Loyal Gorger Quest" },
        { { 62038, 62042, 62047, 62049, 62048, 62050 },        { 1414 }, 6,  "Dead Blanchy Quest" },
        { { 64292, 64298 },                                    { 1511 }, 6,  "Find Maelie, The Wanderer" },
        { { 64274 },                                           { 1510 }, 10, "Deliver an Egg to Razorwing Nest" },
        { { 64376 },                                           { 1507 }, 10, "Deliver a Tasty Mawshroom to Darkmaul" },
        { { 65727, 65725, 65726, 65728, 65729, 65730, 65731 }, { 1569 }, 7,  "Patient Bufonid Quest" }
    }

    local dailyBfaActivities = {
        { { 50393, 50394, 50402, 52305, 50395, 50401, 50412, 52447, 50396, 50886, 50887, 50900, 52748, 50397, 50940, 50942, 50943, 50944 }, { 1043 }, 30,
            "Kua'fon Quest",
            { 50801, 50796, 50791, 50798, 50839, 51146, 50838, 50838, 52317, 50842, 50930, 50860, 50841, 51146 } },
        { { 55608, 54086, 54929, 55373, 55697, 54922, 56168, 54083, 56175, 55696, 55753, 55622 },                      { 1253 }, 12, "Scrapforged Mechaspider Quest" },
        { { 55254, 55252, 55253, 55258, 55462, 55503, 55504, 55506, 55505, 55507, 55247, 55795, 55796, 55797, 55798 }, { 1249 }, 15, "Child of Torcali" },
        { { 58887, 58879 },                                                                                            { 1329 }, 7,  "Feed Gersahl Greens to Friendly Alpaca" },
        { { 58802, 58803, 58804, 58806, 58805, 58805, 58808, 58805, 58805, 58805, 58805, 58805, 58809, 58810, 58811, 58812, 58813, 58817,
            58858, 58858, 58818, 58825, 58858, 58858, 58829, 58830, 58861, 58831, 58862, 58859, 58831, 58863, 58865, 58866 }, { 1320 }, 30,
            "Shadowbarb Drone Quest" },
    }

    local dailyWODActivities = { -- Requires Level 1 Stables
        -- Talbruk
        { { 36911 }, { 637 }, "Alliance Only", { 36971, 36972, 36973, 36974, 36975, 36976, 36977, 36978, 36979, 36980, 36981 } },
        { { 36917 }, { 637 }, "Horde Only",    { 37093, 37094, 37095, 37096, 37097, 37098, 37099, 37100, 37101, 37102, 37103 } },
        -- Boar
        { { 36913 }, { 628 }, "Alliance Only", { 36995, 36996, 36997, 36998, 36999, 37000, 37001, 37002, 37003 } },
        { { 36944 }, { 628 }, "Horde Only",    { 37032, 37033, 37034, 37035, 37036, 37037, 37038, 37039, 37040 } },
        -- Wolf
        { { 36914 }, { 647 }, "Alliance Only", { 37022, 37023, 37024, 37025, 37026, 37027 } },
        { { 36950 }, { 647 }, "Horde Only",    { 37105, 37106, 37107, 37108, 37109 } },
        -- Elekk
        { { 36915 }, { 615 }, "Alliance Only", { 37015, 37016, 37017, 37018, 37019, 37020 } },
        { { 36946 }, { 615 }, "Horde Only",    { 37063, 37064, 37065, 37066, 37067, 37068 } },
        -- Clefthoof
        { { 36916 }, { 609 }, "Alliance Only", { 36983, 36984, 36985, 36986, 36987, 36988, 36989, 36990, 36991, 36992, 36993 } },
        { { 36912 }, { 609 }, "Horde Only",    { 37048, 37049, 37050, 37051, 37052, 37053, 37054, 37055, 37056, 37057, 37058 } },
        -- Riverbeast
        { { 36918 }, { 629 }, "Alliance Only", { 37005, 37006, 37007, 37008, 37009, 37010, 37011, 37012 } },
        { { 36945 }, { 629 }, "Horde Only",    { 37071, 37072, 37073, 37074, 37075, 37076, 37077, 37078 } },
    }

    local dailyBrunnhildar = {
        { { 12843, 12844, 12846, 12841, 12905, 12906, 12907, 12908, 12921, 12969, 12970, 12971, 12972, 12851, 12856, 13063, 12900, 12983, 12925, 12942,
            12968, 12989, 12996, 12997, 13061, 13062, 12886 },
            { 237 }, 33, "Reins of the White Polar Bear", "     Drops from Daily Quest/s Reward, Hyldnir Spoils",
            { 13425, 13422, 13423, 13424 } },
    }

    local dailyArgentTournament = {
        -- Argent Tournament Stage 1 - Aspirant
        { { 13667, 13828, 13835, 13837, 13672, 13679 }, { 13625, 13666, { 13669, 13670, 13671 } },                                                      "Alliance" },
        { { 13668, 13829, 13838, 13839, 13678, 13680 }, { 13673, 13674, { 13675, 13676, 13677 } },                                                      "Horde" },

        -- Argent Tournament Stage 2 - Player Specific Racial Valiant
        { { 13721, 13729, 13739 },                      { 13860, 13781, { 13780, 13779, 13778 } },                                                      "Horde",    { "Undead" } },
        { { 13697, 13726, 13736 },                      { 13856, 13765, { 13764, 13763, 13762 } },                                                      "Horde",    { "Orc", "Goblin", "Pandaren", "Vulpera", "Mag'har" } },
        { { 13722, 13731, 13740 },                      { 13859, 13786, { 13785, 13784, 13783 } },                                                      "Horde",    { "Blood Elf", "Nightborne" } },
        { { 13720, 13728, 13738 },                      { 13858, 13776, { 13775, 13774, 13773 } },                                                      "Horde",    { "Tauren", "Highmountain" } },
        { { 13719, 13727, 13737 },                      { 13857, 13771, { 13770, 13769, 13768 } },                                                      "Horde",    { "Troll", "Zandalari" } },
        { { 13718, 13699, 13702 },                      { 13847, 13592, { 13616, 13600, 13603 } },                                                      "Alliance", { "Human", "Worgen", "Pandaren", "Kul Tiran" } },
        { { 13714, 13713, 13732 },                      { 13851, 13744, { 13743, 13742, 13741 } },                                                      "Alliance", { "Dwarf", "Dark Iron" } },
        { { 13715, 13723, 13733 },                      { 13852, 13749, { 13748, 13747, 13746 } },                                                      "Alliance", { "Gnome", "Mechagnome" } },
        { { 13716, 13724, 13734 },                      { 13854, 13755, { 13754, 13753, 13752 } },                                                      "Alliance", { "Draenei", "Lightforged" } },
        { { 13717, 13725, 13735 },                      { 13855, 13760, { 13759, 13758, 13757 } },                                                      "Alliance", { "Night Elf", "Void Elf" } },

        -- Argent Tournament Stage 3 - Complete all Player Faction 5x Specific Racial Valiants Above (only 1 at a time) + Player Specific Racial Champion Below
        -- Seal Earning for Mounts starts with these Dailies
        { { 13664, 14016, 14017, 13795 },               { 13812, 13863, 13814, 13813, 14142, { 14092, 14141, 14145 }, { 14143, 14136, 14140, 14144 } }, "Horde",    { "Death Knight" } },
        { { 13664, 14016, 14017, 13794 },               { 13809, 13862, 13811, 13810, 14142, { 14092, 14141, 14145 }, { 14143, 14136, 14140, 14144 } }, "Horde" },
        { { 13664, 14016, 14017, 13795 },               { 13788, 13864, 13793, 13791, 14096, { 14076, 14090, 14112 }, { 14074, 14152, 14080, 14077 } }, "Alliance", { "Death Knight" } },
        { { 13664, 14016, 14017, 13794 },               { 13682, 13861, 13790, 13789, 14096, { 14076, 14090, 14112 }, { 14074, 14152, 14080, 14077 } }, "Alliance" },

        -- Argent Tournament Stage 4 - Champion of all Faction Cities - continue stage 3 dalies + below
        { { 14105, 14101, 14102, 14104 },               { { 14105, 14101, 14102, 14104 }, { 14107, 14108 } } },
    }

    local argentTournamentMounts = {
        -- Requires Exalted with all 5 Horde/Alliance Factions, Champion the 5 Cities & Exalted with Argent Crusade
        -- Argent Warhorse
        { 2816,                             341, "Horde",    100 },
        { 2817,                             341, "Alliance", 100 },
        -- Requires Exalted with a Horde/Alliance Faction and Champion of that City
        -- Argent Hippogryph
        { { 2765, 2766, 2767, 2768, 2769 }, 305, "Horde",    150 },
        { { 2764, 2760, 2761, 2762, 2763 }, 305, "Alliance", 150 },
        -- Exalted Champion Mounts (must be Exalted with Horde/Alliance Faction)
        -- Orc
        { 2765,                             327, "Horde",    5 },   -- Swift Burgundy Wolf (need 500g too)
        { 2765,                             300, "Horde",    100 }, -- Orgrimmar Wolf
        -- Troll
        { 2766,                             325, "Horde",    5 },   -- Swift Purple Raptor (need 500g too)
        { 2766,                             295, "Horde",    100 }, -- Darkspear Raptor
        -- Blood Elf
        { 2767,                             320, "Horde",    5 },   -- Swift Red Hawkstrider (need 500g too)
        { 2767,                             302, "Horde",    100 }, -- Silvermoon Hawkstrider
        -- Tauren
        { 2768,                             322, "Horde",    5 },   -- Great Golden Kodo (need 500g too)
        { 2768,                             301, "Horde",    100 }, -- Thunder Bluff Kodo
        -- Undead
        { 2769,                             326, "Horde",    5 },   -- White Skeletal Warhorse (need 500g too)
        { 2769,                             303, "Horde",    100 }, -- Forsaken Warhorse
        -- Human
        { 2764,                             321, "Alliance", 5 },   -- Swift Gray Steed (need 500g too)
        { 2764,                             294, "Alliance", 100 }, -- Stormwind Steed
        -- Night Elf
        { 2760,                             319, "Alliance", 5 },   -- Swift Moonsaber (need 500g too)
        { 2760,                             297, "Alliance", 100 }, -- Darnassian Nightsaber
        -- Draenei
        { 2761,                             318, "Alliance", 5 },   -- Great Red Elekk (need 500g too)
        { 2761,                             299, "Alliance", 100 }, -- Exodar Elekk
        -- Gnome
        { 2762,                             323, "Alliance", 5 },   -- Turbostrider (need 500g too)
        { 2762,                             298, "Alliance", 100 }, -- Gnomeregan Mechanostrider
        -- Dwarf
        { 2763,                             324, "Alliance", 5 },   -- Swift Violet Ram (need 500g too)
        { 2763,                             296, "Alliance", 100 }, -- Ironforge Ram
    }

    local dailyClassicActivities = {
        { { 13850, 13887, 13906 }, { 311 }, 20, "Venomhide Ravasaur Quest",      { 13915, 13903, 13904, 13905 }, "Horde Only" },
        { { 29032, 29034 },        { 55 },  20, "Winterspring Frostsaber Quest", { 29038, 29037, 29040, 29035 }, "Alliance Only" }
    }

    local covRares = {
        [1] = { { 1493, "Intact Aquilon Core", "Wild Worldcracker" } }, -- Kyrian
        [2] = {                                                         -- Venthyr
            { 1310, "Horrid Dredwing",       "Harika the Horrid",   59612, 100 },
            { 1298, "Hopecrusher Gargon",    "Hopecrusher",         59900, 100 },
            { 803,  "Mastercraft Gravewing", "Stygian Stonecrusher" }
        },
        [3] = { -- Night Fae
            { 1487, "Summer Wilderling",       "Escaped Wilderling" },
            { 1393, "Wild Glimmerfur Prowler", "Valfir the Unrelenting", 61632, 100 },
        },
        [4] = { -- Necrolord
            { 1411, "Predatory Plagueroc",       "Gieger",                  58872, 33 },
            { 1370, "Armored Bonehoof Tauralus", "Sabriel the Bonecleaver", 58784, 100 },
            { 1366, "Bonehoof Tauralus",         "Tahonta",                 58783, 100 },
            { 1449, "Lord of the Corpseflies",   "Fleshwing" }
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
                local covenantName = C_Covenants.GetCovenantData(covenantID) and
                    C_Covenants.GetCovenantData(covenantID).name
                    or MasterCollectorSV[characterKey].covenants[covenantID].name or
                    "|cffff0000Error: Unable to Load Covenant/s, Switch Covenants at Oribos|r\n\n"

                local covenantOutput = {}
                local covenantHasMountsToShow = false

                for _, mountData in ipairs(mounts) do
                    local mountID, itemName, dropsFrom, questID, dropChanceDenominator = unpack(mountData)
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                    local hasCompletedQuest = questID and C_QuestLog.IsQuestFlaggedCompleted(questID) or false
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

                    local shouldShow = not (MasterCollectorSV.hideBossesWithMountsObtained and isCollected) and
                        (not isCollected or not (MasterCollectorSV.showBossesWithNoLockout and hasCompletedQuest))

                    if shouldShow then
                        covenantHasMountsToShow = true
                        hasAnyMountsToShow = true
                        local colorHex = hasCompletedQuest and MC.greenHex or MC.redHex
                        covenantOutput[#covenantOutput + 1] = string.format("%s        %s|r\n", colorHex, dropsFrom)
                        if MasterCollectorSV.showMountName then
                            covenantOutput[#covenantOutput + 1] = string.format("            Mount: %s %s%s\n", mountName,
                                rarityAttemptsText, dropChanceText)
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

                                    for _, difficulty in ipairs({ difficultyID }) do
                                        local difficultyName = difficulties[difficulty] or "Unknown"
                                        local isDifficultyKilled = isInstanceBossKilled(dungeonID, bossID, difficulty)
                                        local color = isDifficultyKilled and MC.greenHex or MC.redHex

                                        difficultiesText = difficultiesText ..
                                            color .. "(" .. difficultyName .. ")" .. "|r"
                                        if not isDifficultyKilled then
                                            allDifficultiesKilled = false
                                        end
                                    end

                                    if not (MasterCollectorSV.showBossesWithNoLockout and allDifficultiesKilled) then
                                        dungeonText = dungeonText ..
                                            string.format("    - %s%s|r %s\n", bossColor, bossName, difficultiesText)

                                        for _, mountID in ipairs(mountIDs) do
                                            local mountName = C_MountJournal.GetMountInfoByID(mountID) or "Unknown Mount"
                                            local itemData = GetItemData(itemName)
                                            local rarityAttemptsText = ""
                                            local dropChanceText = ""

                                            if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                                if MasterCollectorSV.showRarityDetail and itemData then
                                                    dropChanceDenominator = itemData.dropChanceDenominator
                                                    local attempts = GetRarityAttempts(itemName) or 0

                                                    if dropChanceDenominator and dropChanceDenominator ~= 0 then
                                                        local chance = 1 / dropChanceDenominator
                                                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts,
                                                            dropChanceDenominator)
                                                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                                    else
                                                        rarityAttemptsText = ""
                                                        dropChanceText = ""
                                                    end
                                                else
                                                    rarityAttemptsText = ""
                                                    dropChanceText = ""
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
                            expansionText = expansionText ..
                                "\n    " .. MC.goldHex .. dungeonName .. "|r:\n" .. dungeonText
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
                local uncollectedMounts = {}

                local shouldProcessExpansion = true
                if (expansion == "WoD Tanaan Jungle Rares" and not MasterCollectorSV.showTanaanRares) or
                    (expansion == "Legion Argus Rares" and not MasterCollectorSV.showArgusRares) or
                    (expansion == "BfA Arathi Highlands Rares" and not MasterCollectorSV.showArathiRares) or
                    (expansion == "BfA Darkshore Rares" and not MasterCollectorSV.showDarkshoreRares) or
                    (expansion == "BfA Mechagon Rares" and not MasterCollectorSV.showMechagonRares) or
                    (expansion == "BfA Nazjatar Rares" and not MasterCollectorSV.showNazRares) or
                    (expansion == "BfA Uldum Rares" and not MasterCollectorSV.showUldumRares) or
                    (expansion == "BfA Vale of Eternal Blossoms Rares" and not MasterCollectorSV.showValeRares) or
                    (expansion == "SL Rares (non-Covenant Specific)" and not MasterCollectorSV.showSLRares) or
                    (expansion == "DF Rares" and not MasterCollectorSV.showDFRares) then
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
                        local allKilled = true
                        local individualRaresText = ""

                        if type(questIDs) ~= "table" then
                            questIDs = { questIDs }
                        end

                        local rareNames = { strsplit("/", rareName) }

                        for index, questID in ipairs(questIDs) do
                            local individualRareName = rareNames[index] or 0
                            local isKilled = C_QuestLog.IsQuestFlaggedCompleted(questID)
                            local rareNameColor = isKilled and "|cFF00FF00" or MC.redHex

                            if not isKilled then
                                allKilled = false
                            end

                            if individualRareName == 0 then
                                individualRareName = ""
                            end

                            individualRaresText = individualRaresText ..
                                string.format("   %s%s|r", rareNameColor, individualRareName)
                        end


                        if type(mountIDs) ~= "table" then
                            mountIDs = { mountIDs }
                        end

                        local mountTexts = {}
                        for _, mountID in ipairs(mountIDs) do
                            local mountName, isCollected
                            local mountInfo = { C_MountJournal.GetMountInfoByID(mountID) }
                            mountName = mountInfo[1] or "Unknown Mount"
                            isCollected = mountInfo[11]

                            local shouldShow = true

                            shouldShow = not (MasterCollectorSV.hideBossesWithMountsObtained and isCollected) and
                                (not isCollected or not (MasterCollectorSV.showBossesWithNoLockout and allKilled))

                            if not isCollected then
                                table.insert(uncollectedMounts, mountName)
                            end

                            if shouldShow then
                                local attempts = GetRarityAttempts(itemName) or 0
                                local rarityAttemptsText = ""
                                local dropChanceText = ""

                                if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                    if MasterCollectorSV.showRarityDetail and dropChanceDenominator and dropChanceDenominator ~= 0 then
                                        local chance = 1 / dropChanceDenominator
                                        local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                        rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts,
                                            dropChanceDenominator)
                                        dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                    else
                                        rarityAttemptsText = ""
                                        dropChanceText = ""
                                    end
                                end
                                table.insert(mountTexts,
                                    string.format("      - %s Mount: %s%s%s|r", whiteColor, mountName, rarityAttemptsText,
                                        dropChanceText))
                            end
                        end

                        if not (MasterCollectorSV.showBossesWithNoLockout and allKilled) then
                            if not factionRestriction or (factionRestriction == playerFaction .. " Only") then
                                expansionText = expansionText .. individualRaresText .. "\n"
                                if MasterCollectorSV.showMountName and #mountTexts > 0 then
                                    expansionText = expansionText .. table.concat(mountTexts, "\n") .. "\n"
                                end
                            end
                        end
                    end
                end

                if #uncollectedMounts > 0 and MasterCollectorSV.hideBossesWithMountsObtained then
                    if expansionText ~= "" then
                        lockoutText = lockoutText .. "\n" .. MC.goldHex .. expansion .. "|r:\n" .. expansionText
                    end
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    if expansionText ~= "" then
                        lockoutText = lockoutText .. "\n" .. MC.goldHex .. expansion .. "|r:\n" .. expansionText
                    end
                end
            end
        end

        function MC.DisplayCurrentCallings()
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

            local output = string.format("%sCurrent Maldraxxus Calling Quests:|r\n", MC.goldHex)
            local foundActive = false
            local mountIDs = { 1438, 1439, 1440 }
            local mountsUnobtained = false

            if MasterCollectorSV.showCallings then
                if not C_CovenantCallings.AreCallingsUnlocked() then
                    output = output .. "    Callings are not unlocked yet\n"
                end

                for questID, questName in pairs(QuestIDs) do
                    local isQuestActive = C_TaskQuest.IsActive(questID)
                    if isQuestActive then
                        foundActive = true
                        output = output .. string.format("%s    %s is available today!|r\n", MC.goldHex, questName)

                        local mountInfo = ""

                        for _, mountID in ipairs(mountIDs) do
                            local mountName, _, _, _, _, _, _, _, _, _, collected = C_MountJournal.GetMountInfoByID(
                                mountID)
                            local rarityAttemptsText = ""
                            local dropChanceText = ""
                            local dropChanceDenominator = 50

                            if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                                    local chance = 1 / dropChanceDenominator
                                    local attempts = GetRarityAttempts("Necroray Egg") or 0
                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                    rarityAttemptsText = string.format(" (Necroray Egg Attempts: %d/%s", attempts,
                                        dropChanceDenominator)
                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                end
                            end

                            mountInfo = mountInfo ..
                                "      Mount: " .. mountName .. rarityAttemptsText .. dropChanceText .. "\n"

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
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                    local isCompleted = false
                    for _, questID in ipairs(questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            isCompleted = true
                            break
                        end
                    end

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
                    table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")

                    if MasterCollectorSV.showMountName then
                        table.insert(entryOutput,
                            "         Mount: " ..
                            (mountName or "Unknown Mount") ..
                            " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")
                    else
                        table.insert(entryOutput,
                            "         Progress: " .. completedDays .. " / " .. requiredDays .. " Days")
                    end

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

        local function QueryArgentDailyActivities()
            if MasterCollectorSV.showArgentDailies then
                local progressOutput = MC.goldHex .. "WOTLK Argent Tournament Daily Activities|r\n"

                local function AreAllQuestsComplete(quests)
                    for _, questID in ipairs(quests) do
                        if not C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            return false
                        end
                    end
                    return true
                end

                local function CountCompletedDailies(dailies)
                    local total = 0
                    local completed = 0
                    for _, daily in ipairs(dailies) do
                        if type(daily) == "table" then
                            -- Daily is a group of quests, check if at least one is complete
                            total = total + 1
                            local groupCompleted = false
                            for _, questID in ipairs(daily) do
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    groupCompleted = true
                                    break
                                end
                            end
                            if groupCompleted then
                                completed = completed + 1
                            end
                        else
                            -- Daily is a single quest
                            total = total + 1
                            if C_QuestLog.IsQuestFlaggedCompleted(daily) then
                                completed = completed + 1
                            end
                        end
                    end
                    return completed, total
                end

                local function tableContains(tbl, value)
                    for _, v in ipairs(tbl) do
                        if v == value then
                            return true
                        end
                    end
                    return false
                end

                local function GetArgentTournamentProgress(playerFaction, playerRace, playerClass)
                    local function GetStage(stageIndex)
                        if stageIndex == 1 or stageIndex == 2 then
                            return 1 -- Stage 1
                        elseif stageIndex >= 3 and stageIndex <= 12 then
                            return 2 -- Stage 2
                        elseif stageIndex >= 13 and stageIndex <= 16 then
                            return 3 -- Stage 3
                        elseif stageIndex == 17 then
                            return 4 -- Stage 4
                        end
                        return nil
                    end

                    local function GetStageName(stage)
                        if stage == 1 then
                            return "Aspirant"
                        elseif stage == 2 then
                            return "Valiant"
                        elseif stage == 3 then
                            return "Champion"
                        elseif stage == 4 then
                            return "Champion of all Cities"
                        end
                        return "Unknown"
                    end

                    local racialValiantsProgress = {}
                    local playerRaceValiantComplete = false
                    local previousStageDailies = nil

                    for stageIndex, stageData in ipairs(dailyArgentTournament) do
                        local quests, dailies, faction, races, classes = unpack(stageData)

                        if not faction or faction == playerFaction then
                            if not races or tableContains(races, playerRace) then
                                if not classes or classes == playerClass then
                                    local allQuestsComplete = AreAllQuestsComplete(quests)
                                    local currentStage = GetStage(stageIndex)
                                    local completedDailies, stageTotalDailies = CountCompletedDailies(dailies)

                                    if previousStageDailies and currentStage ~= 2 then
                                        local prevCompleted, prevTotal = CountCompletedDailies(previousStageDailies)
                                        completedDailies = completedDailies + prevCompleted
                                        stageTotalDailies = stageTotalDailies + prevTotal
                                    end

                                    if currentStage == 4 then
                                        return string.format(
                                        "     %s Champion of all Cities!  (Completed %d / %d Dailies)\n", playerFaction,
                                            completedDailies, stageTotalDailies)
                                    end

                                    local nextStageName = GetStageName(currentStage + 1)

                                    if not allQuestsComplete then
                                        if currentStage == 1 then
                                            return string.format(
                                                "     %s Aspirant (Completed %d / %d Dailies)\n         Next Rank: %s\n",
                                                playerFaction,
                                                completedDailies,
                                                stageTotalDailies,
                                                nextStageName
                                            )
                                        elseif currentStage == 2 then
                                            return string.format(
                                                "     %s Valiant (Completed %d / %d Dailies)\n         Next Rank: %s\n",
                                                playerRace,
                                                completedDailies,
                                                stageTotalDailies,
                                                nextStageName
                                            )
                                        elseif currentStage == 3 then
                                            for _, race in ipairs(races) do
                                                if not racialValiantsProgress[race] then
                                                    racialValiantsProgress[race] = { unlocked = false, completedDailies = 0, totalDailies = 0 }
                                                end

                                                local racialProgress = racialValiantsProgress[race]

                                                -- Player's race valiant unlock check
                                                if race == playerRace then
                                                    racialProgress.unlocked = true
                                                    playerRaceValiantComplete = allQuestsComplete
                                                    local completed, total = CountCompletedDailies(dailies)
                                                    racialProgress.completedDailies = completed
                                                    racialProgress.totalDailies = total
                                                end

                                                -- Other racial valiants only unlock if the player's race valiant is complete
                                                if race ~= playerRace then
                                                    if playerRaceValiantComplete then
                                                        racialProgress.unlocked = true
                                                        local completed, total = CountCompletedDailies(dailies)
                                                        racialProgress.completedDailies = completed
                                                        racialProgress.totalDailies = total
                                                    else
                                                        racialProgress.unlocked = false
                                                    end
                                                end
                                            end

                                            return string.format(
                                                "     %s Champion (Completed %d / %d Dailies)\n         Next Rank: %s\n",
                                                playerRace,
                                                completedDailies,
                                                stageTotalDailies,
                                                nextStageName
                                            )
                                        end
                                    end
                                    previousStageDailies = dailies
                                end
                            end
                        end
                    end

                    if next(racialValiantsProgress) and playerRaceValiantComplete then
                        local racialOutput = "\n     Racial Valiant Progress:\n"
                        for race, progress in pairs(racialValiantsProgress) do
                            if progress.unlocked then
                                racialOutput = racialOutput .. string.format(
                                    "         - %s Valiant: (Completed %d / %d Dailies)\n",
                                    race, progress.completedDailies, progress.totalDailies
                                )
                            end
                        end
                        progressOutput = progressOutput .. racialOutput
                    end

                    return "Progress not found"
                end

                local playerFaction = UnitFactionGroup("player")
                local playerRace = UnitRace("player")
                local playerClass = UnitClass("player")
                progressOutput = progressOutput .. GetArgentTournamentProgress(playerFaction, playerRace, playerClass)
                local playerChampionSeals = C_CurrencyInfo.GetCurrencyInfo(241).quantity
                local iconChampionSeals = C_CurrencyInfo.GetCurrencyInfo(241).iconFileID
                local mountsUnobtained = false

                for _, mountData in ipairs(argentTournamentMounts) do
                    local achievementID = mountData[1]
                    local mountID = mountData[2]
                    local requiredFaction = mountData[3]
                    local sealsRequired = mountData[4]
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                    local achieveNames = {}

                    if requiredFaction == playerFaction then
                        local achievementComplete = false
                        if type(achievementID) == "table" then
                            for _, id in ipairs(achievementID) do
                                local achieveName = select(2, GetAchievementInfo(id))
                                if achieveName then
                                    table.insert(achieveNames, achieveName)
                                end

                                if select(4, GetAchievementInfo(id)) then
                                    achievementComplete = true
                                end
                            end
                        else
                            achievementComplete = select(4, GetAchievementInfo(achievementID))
                            local achieveName = select(2, GetAchievementInfo(achievementID))
                            if achieveName then
                                table.insert(achieveNames, achieveName)
                            end
                        end

                        local achievementNamesOutput = table.concat(achieveNames, "\n            ")

                        if not isCollected then
                            mountsUnobtained = true
                        end

                        if MasterCollectorSV.showMountName then
                            progressOutput = progressOutput .. (string.format("         Mount: %s\n", mountName))
                            progressOutput = progressOutput ..
                            (string.format("            %d / %d Champion Seals ", playerChampionSeals, sealsRequired)) ..
                            CreateTextureMarkup(iconChampionSeals, 32, 32, 16, 16, 0, 1, 0, 1)

                            local playerMoney = GetMoney()
                            local moneyString = C_CurrencyInfo.GetCoinTextureString(playerMoney)
                            local cost = C_CurrencyInfo.GetCoinTextureString(5000000)

                            if sealsRequired == 5 then
                                progressOutput = progressOutput .. "  & " .. moneyString .. " / " .. cost .. " Required\n"
                            else
                                progressOutput = progressOutput .. " Required\n"
                            end
                        end

                        if MasterCollectorSV.hideBossesWithMountsObtained and not achievementComplete then
                            if mountID == 305 then
                                progressOutput = progressOutput ..
                                (string.format("%s         Any of the Below Achievements Required:\n            %s|r\n\n", MC.goldHex, achievementNamesOutput))
                            else
                                progressOutput = progressOutput ..
                                (string.format("%s         Any of the BelowAchievements Yet to be Completed:\n            %s|r\n\n", MC.goldHex, achievementNamesOutput))
                            end
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            if mountID == 305 then
                                progressOutput = progressOutput ..
                                (string.format("%s         Any of the Below Achievements Required:\n            %s|r\n\n", MC.goldHex, achievementNamesOutput))
                            else
                                progressOutput = progressOutput ..
                                (string.format("%s         Achievement Required: %s|r\n\n", MC.goldHex, achievementNamesOutput))
                            end
                        end
                    end
                end

                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return progressOutput
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return progressOutput
                end
            end
        end

        local function QueryWOTLKBrunnhildarDailyActivities()
            if MasterCollectorSV.showBrunnhildarDailies then
                local output = MC.goldHex .. "WOTLK Brunnhildar Village Daily Activities|r\n"
                local mountsUnobtained = false
                local rarityAttemptsText = ""
                local dropChanceText = ""

                for _, entry in ipairs(dailyBrunnhildar) do
                    local unlockQuests = entry[1]
                    local mountIds = entry[2]
                    local dropChanceDenominator = entry[3]
                    local itemName = entry[4]
                    local header = entry[5]
                    local dailies = entry[6]

                    local isCompleted = false
                    for _, questID in ipairs(unlockQuests) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            isCompleted = true
                            break
                        end
                    end

                    output = output .. MC.goldHex .. header .. "|r\n"

                    if MasterCollectorSV.showMountName then
                        for _, mountId in ipairs(mountIds) do
                            local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountId)

                            if not isCollected then
                                mountsUnobtained = true
                            end

                            if RarityDB and RarityDB.profiles and RarityDB.profiles["Default"] then
                                if MasterCollectorSV.showRarityDetail and dropChanceDenominator then
                                    local chance = 1 / dropChanceDenominator
                                    local attempts = GetRarityAttempts(itemName) or 0
                                    local cumulativeChance = 100 * (1 - math.pow(1 - chance, attempts))
                                    rarityAttemptsText = string.format(" (Attempts: %d/%s", attempts, dropChanceDenominator)
                                    dropChanceText = string.format(" = %.2f%%)", cumulativeChance)
                                end
                            end

                            output = output ..
                            (string.format("         Mount: %s\n        %s%s\n", mountName, rarityAttemptsText, dropChanceText))
                        end
                    end
                end
                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local function QueryWoDDailyActivities()
            if MasterCollectorSV.showWoDDailies then
                local output = MC.goldHex .. "WoD Garrison Stables Daily Activities|r\n"
                local mountsUnobtained = false
                local questlineOutput = ""

                local function GetMountNameById(mountID)
                    local name = C_MountJournal.GetMountInfoByID(mountID)
                    return name or "Unknown Mount"
                end

                local function IsPlayerFaction(factionCheck)
                    local factionGroup = UnitFactionGroup("player")
                    return (factionCheck == "Alliance Only" and factionGroup == "Alliance") or
                        (factionCheck == "Horde Only" and factionGroup == "Horde")
                end

                for _, activity in ipairs(dailyWODActivities) do
                    local unlockQuest, mountID, factionCheck, questList = activity[1][1], activity[2][1], activity[3],
                        activity[4]
                    local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                    if not isCollected then
                        mountsUnobtained = true
                    end

                    if IsPlayerFaction(factionCheck) then
                        if C_QuestLog.IsQuestFlaggedCompleted(unlockQuest) then
                            local completedDays = 0
                            for _, questID in ipairs(questList) do
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    completedDays = completedDays + 1
                                end
                            end

                            local mountName = GetMountNameById(mountID)
                            local requiredDays = #questList

                            if MasterCollectorSV.showMountName then
                                output = output ..
                                (string.format("     Mount: %s  (Progress: %d / %d Days)\n", mountName, completedDays, requiredDays))
                            end
                        else
                            questlineOutput = "     Please start questline/s to unlock mount dailies\n"
                        end
                    end
                end

                if questlineOutput ~= "" then
                    output = output .. questlineOutput
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
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                    local isCompleted = false
                    for _, questID in ipairs(questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            isCompleted = true
                            break
                        end
                    end

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
                    table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")

                    if MasterCollectorSV.showMountName then
                        table.insert(entryOutput,
                            "         Mount: " ..
                            (mountName or "Unknown Mount") ..
                            " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")
                    else
                        table.insert(entryOutput,
                            "         Progress: " .. completedDays .. " / " .. requiredDays .. " Days")
                    end

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
                local NFprogressOutput = ""
                for _, value in ipairs(dailyNFActivities) do
                    local achievement = value[1]
                    local NFmountID = value[2]
                    local currency = value[3]
                    local NFmountName = C_MountJournal.GetMountInfoByID(NFmountID)
                    local achieveName = select(2, GetAchievementInfo(achievement))
                    local achievementComplete = select(4, GetAchievementInfo(achievement))
                    local iconCovenantAnima = C_CurrencyInfo.GetCurrencyInfo(1813).iconFileID
                    local iconSize = CreateTextureMarkup(iconCovenantAnima, 32, 32, 16, 16, 0, 1, 0, 1)

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

                    if MasterCollectorSV.hideBossesWithMountsObtained and not achievementComplete then
                        NFprogressOutput = NFprogressOutput .. MC.goldHex ..  "     Night Fae Covenant Star Lake Ampitheatre Daily\n         Achievement Required: " .. achieveName .. "|r\n"
                    elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                        NFprogressOutput = NFprogressOutput .. MC.goldHex ..  "     Night Fae Covenant Star Lake Ampitheatre Daily\n         Achievement Required: " .. achieveName .. "|r\n"
                    end

                    if MasterCollectorSV.showMountName then
                        NFprogressOutput = NFprogressOutput .. (string.format("         Mount: %s\n", NFmountName))
                        NFprogressOutput = NFprogressOutput .. MC.goldHex .. "         " ..
                        totalAnima .. " / " .. currency .. " Anima " .. iconSize .. " Required|r\n"
                    end
                end

                for _, entry in ipairs(dailySLActivities) do
                    local questIDs = entry[1]
                    local mountID = entry[2][1]
                    local requiredDays = entry[3]
                    local objective = entry[4]
                    local completedDays = 0
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)

                    local isCompleted = false
                    for _, questID in ipairs(questIDs) do
                        if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                            isCompleted = true
                            break
                        end
                    end

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
                    table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")

                    if MasterCollectorSV.showMountName then
                        table.insert(entryOutput,
                            "         Mount: " ..
                            (mountName or "Unknown Mount") ..
                            " (Progress: " .. completedDays .. " / " .. requiredDays .. " Days)")
                    else
                        table.insert(entryOutput,
                            "         Progress: " .. completedDays .. " / " .. requiredDays .. " Days")
                    end

                    for _, line in ipairs(entryOutput) do
                        table.insert(output, line)
                    end
                end

                table.insert(output, "" .. NFprogressOutput)

                if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                    return output
                elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                    return output
                end
            end
        end

        local function QueryDFDailyActivities()
            local output = {}
            local mountsUnobtained = false
            local hasValidEntries = false

            if not dailyDFActivities or #dailyDFActivities == 0 then
                table.insert(output, MC.goldHex .. "No activities found.|r")
                return output
            end

            if MasterCollectorSV.showDFDailies then
                for _, entry in ipairs(dailyDFActivities) do
                    local questIDs = entry[1]
                    local mountID = entry[2] and entry[2][1] or nil
                    local requiredDays = entry[3]
                    local objective = entry[4]
                    local mountName, _, _, _, _, _, _, _, _, _, isCollected
                    local completedDays = 0

                    if mountID then
                        mountName, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                    end

                    local colorHex
                    local entryOutput = {}

                    if not isCollected then
                        mountsUnobtained = true
                    end

                    if objective == "Lizi Quests" then
                        for _, dailyGroup in ipairs(questIDs) do
                            if type(dailyGroup) == "table" then
                                local allQuestsCompleted = true
                                for _, dailyQuestID in ipairs(dailyGroup) do
                                    if not C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                        allQuestsCompleted = false
                                        break
                                    end
                                end
                                if allQuestsCompleted then
                                    completedDays = completedDays + 1
                                else
                                    break
                                end
                            end
                        end

                        if not isCollected and MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")
                            if MasterCollectorSV.showMountName then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. completedDays .. " / " .. (requiredDays or "Unknown") .. " Days)")
                            else
                                table.insert(entryOutput,
                                    "         Progress: Day " ..
                                    completedDays .. " / " .. (requiredDays or "Unknown") .. " Days")
                            end
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")
                            if MasterCollectorSV.showMountName then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. completedDays .. " / " .. (requiredDays or "Unknown") .. " Days)")
                            else
                                table.insert(entryOutput,
                                    "         Progress: Day " ..
                                    completedDays .. " / " .. (requiredDays or "Unknown") .. " Days")
                            end
                        end
                    elseif objective == "Emerald Dream Seedling" then
                        local questDurations = { 5, 5, 5, 5 } -- Define durations for the 4 groups of quests

                        for i, questID in ipairs(questIDs) do
                            if type(questID) == "number" then
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    completedDays = completedDays + (questDurations[i] or 0)
                                end
                            end
                        end

                        if C_QuestLog.IsQuestFlaggedCompleted(77697) then
                            completedDays = completedDays + 3
                        end

                        local quest1Completed = C_QuestLog.IsQuestFlaggedCompleted(77697)
                        local quest2Completed = C_QuestLog.IsQuestFlaggedCompleted(77677)
                        local quest3Completed = C_QuestLog.IsQuestFlaggedCompleted(78398)

                        local itemInBags = false
                        for bag = 0, NUM_BAG_SLOTS do
                            for slot = 1, C_Container.GetContainerNumSlots(bag) do
                                local itemID = C_Container.GetContainerItemID(bag, slot)
                                if itemID == 208646 then
                                    itemInBags = true
                                    break
                                end
                            end
                            if itemInBags then break end
                        end

                        if not isCollected and MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")

                            if not itemInBags and quest2Completed and quest3Completed and not quest1Completed then
                                local npcCredit = false
                                local npcID = 209454
                                for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                                    local questInfo = C_QuestLog.GetInfo(i)
                                    if questInfo and questInfo.questID == 77697 then
                                        local objectives = questInfo.objectives
                                        for _, objective in ipairs(objectives) do
                                            if objective and objective.npcID == npcID then
                                                npcCredit = true
                                                break
                                            end
                                        end
                                    end
                                end

                                if not npcCredit then
                                    table.insert(entryOutput,
                                        "         You need to use the Emerald Dream Seedling (Item ID: 208646) to proceed.")
                                end
                            elseif itemInBags then
                                completedDays = completedDays + 3
                            end

                            if MasterCollectorSV.showMountName then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. (completedDays or 0) .. " / " .. (requiredDays or "Unknown") .. " Days)")
                            else
                                table.insert(entryOutput,
                                    "         Progress: " ..
                                    (completedDays or 0) .. " / " .. (requiredDays or "Unknown") .. " Days")
                            end
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")

                            if not itemInBags and quest2Completed and quest3Completed and not quest1Completed then
                                local npcCredit = false
                                local npcID = 209454
                                for i = 1, C_QuestLog.GetNumQuestLogEntries() do
                                    local questInfo = C_QuestLog.GetInfo(i)
                                    if questInfo and questInfo.questID == 77697 then
                                        local objectives = questInfo.objectives
                                        for _, objective in ipairs(objectives) do
                                            if objective and objective.npcID == npcID then
                                                npcCredit = true
                                                break
                                            end
                                        end
                                    end
                                end

                                if not npcCredit then
                                    table.insert(entryOutput,
                                        "         You need to use the Emerald Dream Seedling (Item ID: 208646) to proceed.")
                                end
                            elseif itemInBags then
                                completedDays = completedDays + 3
                            end

                            if MasterCollectorSV.showMountName then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. completedDays .. " / " .. (requiredDays or "Unknown") .. " Days)")
                            else
                                table.insert(entryOutput,
                                    "         Progress: " ..
                                    completedDays .. " / " .. (requiredDays or "Unknown") .. " Days")
                            end
                        end
                    elseif objective == "Little Scales Daycare Quests" then
                        local _, achieveName2, _, achieved2 = GetAchievementInfo(18383)
                        local _, achieveName3, _, achieved3 = GetAchievementInfo(18384)
                        for _, dailyGroup in ipairs(questIDs) do
                            if type(dailyGroup) == "table" then
                                local allQuestsCompleted = true
                                for _, dailyQuestID in ipairs(dailyGroup) do
                                    if not C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                        allQuestsCompleted = false
                                        break
                                    end
                                end
                                if allQuestsCompleted then
                                    completedDays = completedDays + 1
                                else
                                    break
                                end
                            end
                        end

                        if MasterCollectorSV.hideBossesWithMountsObtained and (not achieved2 or not achieved3) then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")
                            table.insert(entryOutput,
                                "         Progress: " .. completedDays .. " / " .. (requiredDays or "Unknown") .. " Days")

                            if not achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName2 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif not achieved3 and not achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName2 ..
                                    " and " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif not achieved3 and achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif achieved3 and achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         Required for: " ..
                                    achieveName2 .. " and " .. achieveName3 .. " for A World Awoken Meta Achievement|r\n")
                            else
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         Both " ..
                                    achieveName2 ..
                                    " and " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            end
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. MC.goldHex .. objective .. "|r")
                            table.insert(entryOutput,
                                "         Progress: " .. completedDays .. " / " .. (requiredDays or "Unknown") .. " Days")

                            if not achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName2 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif not achieved3 and not achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName2 ..
                                    " and " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif not achieved3 and achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            elseif achieved3 and achieved2 then
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         Required for: " ..
                                    achieveName2 .. " and " .. achieveName3 .. " for A World Awoken Meta Achievement|r\n")
                            else
                                table.insert(entryOutput,
                                    MC.goldHex ..
                                    "\n         Both " ..
                                    achieveName2 ..
                                    " and " ..
                                    achieveName3 .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                            end
                        end
                    elseif objective == "Eon's Fringe Daily" then
                        local anyQuestCompleted = false
                        local _, achieveName, _, achieved = GetAchievementInfo(19463)
                        for _, dailyQuestIDs in ipairs(questIDs) do
                            if type(dailyQuestIDs) == "table" then
                                for _, dailyQuestID in ipairs(dailyQuestIDs) do
                                    if C_QuestLog.IsQuestFlaggedCompleted(dailyQuestID) then
                                        anyQuestCompleted = true
                                    end
                                end
                            end
                        end
                        
                        colorHex = anyQuestCompleted and MC.greenHex or MC.redHex

                        if MasterCollectorSV.hideBossesWithMountsObtained and not achieved then
                            table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")
                            table.insert(entryOutput,
                                MC.goldHex ..
                                "         " ..
                                achieveName .. " yet to be Completed for A World Awoken Meta Achievement|r\n")
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")
                            table.insert(entryOutput,
                                MC.goldHex ..
                                "         Required for " .. achieveName .. " for A World Awoken Meta Achievement|r\n")
                        end
                    elseif objective == "Ritual Offerings & Waterlogged Bundle Looted" then
                        local ritualOfferingsCompleted = 0
                        local waterloggedBundleCompleted = false

                        for i = 1, 4 do
                            if type(questIDs[i]) == "table" then
                                for _, questID in ipairs(questIDs[i]) do
                                    if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                        ritualOfferingsCompleted = ritualOfferingsCompleted + 1
                                    end
                                end
                            end
                        end

                        if type(questIDs[5]) == "table" then
                            for _, questID in ipairs(questIDs[5]) do
                                if C_QuestLog.IsQuestFlaggedCompleted(questID) then
                                    waterloggedBundleCompleted = true
                                end
                            end
                        end

                        local allQuestsCompleted = (ritualOfferingsCompleted == 4 and waterloggedBundleCompleted)
                        colorHex = allQuestsCompleted and MC.greenHex or MC.redHex

                        if not isCollected and MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")

                            if MasterCollectorSV.showMountName and not allQuestsCompleted then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. ritualOfferingsCompleted .. "/4 Ritual Offerings, " ..
                                    (waterloggedBundleCompleted and "Waterlogged Bundle Completed)" or "Waterlogged Bundle Not Completed)"))
                            elseif MasterCollectorSV.showMountName then
                                table.insert(entryOutput, "         Mount: " .. (mountName or "Unknown Mount"))
                            elseif not allQuestsCompleted then
                                table.insert(entryOutput,
                                    "         Progress: " .. ritualOfferingsCompleted .. "/4 Ritual Offerings, " ..
                                    (waterloggedBundleCompleted and "Waterlogged Bundle Completed" or "Waterlogged Bundle Not Completed"))
                            end
                        elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                            table.insert(entryOutput, "     " .. colorHex .. objective .. "|r")

                            if MasterCollectorSV.showMountName and not allQuestsCompleted then
                                table.insert(entryOutput,
                                    "         Mount: " ..
                                    (mountName or "Unknown Mount") ..
                                    " (Progress: " .. ritualOfferingsCompleted .. "/4 Ritual Offerings, " ..
                                    (waterloggedBundleCompleted and "Waterlogged Bundle Completed)" or "Waterlogged Bundle Not Completed)"))
                            elseif MasterCollectorSV.showMountName then
                                table.insert(entryOutput, "         Mount: " .. (mountName or "Unknown Mount"))
                            elseif not allQuestsCompleted then
                                table.insert(entryOutput,
                                    "         Progress: " .. ritualOfferingsCompleted .. "/4 Ritual Offerings, " ..
                                    (waterloggedBundleCompleted and "Waterlogged Bundle Completed" or "Waterlogged Bundle Not Completed"))
                            end
                        end
                    end

                    if #entryOutput > 0 then
                        if not hasValidEntries then
                            table.insert(output, MC.goldHex .. "DF Daily Activities|r")
                            hasValidEntries = true
                        end

                        for _, line in ipairs(entryOutput) do
                            table.insert(output, line)
                        end
                    end
                end
                if not hasValidEntries then
                    output = nil
                end
            end

            if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                return output
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return output
            end
        end

        local function queryDFDreamInfusionMounts()
            local outputText = MC.goldHex .. "DF Dream Infusion Dailies|r\n"
            local mountsUnobtained = false

            if MasterCollectorSV.showDFDailies then
                local function PlayerHasMount(mountIDs)
                    for _, mountID in ipairs(mountIDs) do
                        local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(mountID)
                        if isCollected then
                            return true
                        end
                    end
                    return false
                end

                local function IsMountUnobtained(targetMountID)
                    local _, _, _, _, _, _, _, _, _, _, isCollected = C_MountJournal.GetMountInfoByID(targetMountID)
                    if not isCollected then
                        mountsUnobtained = true
                    end
                end

                local playerDreamInfusion = C_CurrencyInfo.GetCurrencyInfo(2777).quantity
                local fileDreamInfusion = C_CurrencyInfo.GetCurrencyInfo(2777).iconFileID
                local iconDreamInfusion = CreateTextureMarkup(fileDreamInfusion, 32, 32, 16, 16, 0, 1, 0, 1)
                for _, entry in ipairs(DFDreamInfusion) do
                    local mountIDs, targetMountID, description = unpack(entry)
                    local mountName = C_MountJournal.GetMountInfoByID(targetMountID)

                    if PlayerHasMount(mountIDs) then
                        if MasterCollectorSV.showMountName then
                            outputText = outputText .. "     Mount: " .. mountName .. "\n" .. "     " .. MC.goldHex ..
                            playerDreamInfusion .. " / 1 Dream Infusion " .. iconDreamInfusion .. " Required|r\n"
                        end
                        outputText = outputText .. MC.goldHex .. description .. "|r\n"
                    else
                        IsMountUnobtained(targetMountID)
                        if MasterCollectorSV.showMountName then
                            outputText = outputText .. "     Mount Available for Purchase: " .. mountName .. "|r\n" .. 
                            "     " .. MC.goldHex ..
                            playerDreamInfusion .. " / 1 Dream Infusion " .. iconDreamInfusion .. " Required|r\n"
                        end
                        outputText = outputText ..
                            MC.goldHex .. "         You have one of the required mounts already!|r\n"
                    end
                end
            end
            if MasterCollectorSV.hideBossesWithMountsObtained and mountsUnobtained then
                return outputText
            elseif not MasterCollectorSV.hideBossesWithMountsObtained then
                return outputText
            end
        end

        local DFdailyActivitiesProgress = QueryDFDailyActivities()
        if DFdailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(DFdailyActivitiesProgress, "\n")
        end

        local DFDreamInfusionMounts = queryDFDreamInfusionMounts()
        if DFDreamInfusionMounts ~= nil then
            lockoutText = lockoutText .. "\n" .. DFDreamInfusionMounts .. "\n"
        end

        local SLdailyActivitiesProgress = QuerySLDailyActivities()
        if SLdailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(SLdailyActivitiesProgress, "\n")
        end

        local covenantRares = covenantRareMounts()
        if covenantRares ~= nil then
            lockoutText = lockoutText .. "\n" .. covenantRares
        end

        local callingsUpdate = MC.DisplayCurrentCallings()
        if callingsUpdate ~= nil then
            lockoutText = lockoutText .. "\n" .. callingsUpdate
        end

        local BfaDailyActivitiesProgress = QueryBfADailyActivities()
        if BfaDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(BfaDailyActivitiesProgress, "\n")
        end

        local WoDDailyActivitiesProgress = QueryWoDDailyActivities()
        if WoDDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. WoDDailyActivitiesProgress
        end

        local ArgentDailyActivitiesProgress = QueryArgentDailyActivities()
        if ArgentDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. ArgentDailyActivitiesProgress
        end

        local BrunnhildarDailyActivitiesProgress = QueryWOTLKBrunnhildarDailyActivities()
        if BrunnhildarDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. BrunnhildarDailyActivitiesProgress
        end

        local ClassicDailyActivitiesProgress = QueryClassicDailyActivities()
        if ClassicDailyActivitiesProgress ~= nil then
            lockoutText = lockoutText .. "\n" .. table.concat(ClassicDailyActivitiesProgress, "\n") .. "\n"
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