local _, addon = ...

local myIdToExpansion = {
    [0] = "Cataclysm",
    [1] = "Mists of Pandaria",
    [2] = "Warlords of Draenor",
    [3] = "Legion",
    [4] = "Battle for Azeroth",
    [5] = "Shadowlands",
    [6] = "Dragonflight",
    [7] = "War Within",
    [8] = "Current Season"
}

local orderedExpansions = {
    "Current Season",
    "Cataclysm",
    "Mists of Pandaria",
    "Warlords of Draenor",
    "Legion",
    "Battle For Azeroth",
    "Shadowlands",
    "Dragonflight",
    "War Within"
}

local mapExpansionToMapID = {
    ["Current Season"] = {244, 199, 198, 463, 464, 168, 456, 248},
    ["Cataclysm"] = {438, 456},
    ["Mists of Pandaria"] = {2, 3, 4, 5, 6, 7, 8, 9, 10},
    ["Warlords of Draenor"] = {165, 168, 169, 170, 171, 172, 173, 174},
    ["Legion"] = {198, 199, 200, 206, 210, 211},
    ["Battle For Azeroth"] = {244, 245, 248, 251, 252},
    ["Shadowlands"] = {300, 301, 302, 303, 304, 305, 306, 307, 308},
    ["Dragonflight"] = {399, 400, 401, 402, 403, 404, 405, 406, 463, 464},
    ["War Within"] = {} 
}

local mapIDtoSpellID = {
    [2]   = 131204, -- Temple of the Jade Serpent
    [3]   = 131228, -- Siege of Niuzao
    [4]   = 131232, -- Scholomance
    [5]   = 131229, -- Scarlet Monastery
    [6]   = 131231, -- Scarlet Halls
    [7]   = 131225, -- Gate of the Setting Sun
    [8]   = 131222, -- Mogu'Shan Palance
    [9]   = 131206, -- Shado-Pan Monastery
    [10]  = 131205, -- Stormstout Brewery
    [165] = 159899, -- Shadowmoon Burial Ground
    [168] = 159901, -- Everbloom
    [169] = 159895, -- Bloodmaul Slag Mines
    [170] = 159897, -- Auchindoun
    [171] = 159898, -- Skyreach
    [172] = 159902, -- Upper Blackrock Spire
    [173] = 159900, -- Grimrail Depot
    [174] = 159896, -- Iron Docks
    [198] = 424163, -- Darkheart Thicket
    [199] = 424153, -- Black Rook Hold
    [200] = 393764, -- Halls of Valor
    [206] = 410078, -- Neltharions Lair
    [210] = 393766, -- Court of Starts
    [211] = 373262, -- Karazhan
    [244] = 424187, -- Atal'Dazar
    [245] = 410071, -- Freehold
    [248] = 424167, -- Waycrest
    [251] = 410074, -- Underrot
    [252] = 373274, -- Mechagon
    [300] = 354462, -- The Necrotic Wake
    [301] = 354463, -- Plaguefall
    [302] = 354464, -- Mists of Tirna Scithe
    [303] = 354465, -- Halls of Attonement
    [304] = 354466, -- Spires of Ascension 
    [305] = 354467, -- Theatre of Pain
    [306] = 354468, -- De Other Side
    [307] = 354469, -- Sanguine Depths
    [308] = 367416, -- Tazavesh, the Veiled Market
    [399] = 393256, -- Ruby Life Pools
    [400] = 393262, -- Nokhud Offensive
    [401] = 393279, -- Azure Vault
    [402] = 393273, -- Algethar Academy
    [403] = 393222, -- Uldaman
    [404] = 393276, -- Neltharus
    [405] = 393267, -- Brackenhide Hollow
    [406] = 393283, -- Halls of Infusion
    [438] = 410080, -- Vortex Pinnacle
    [456] = 424142, -- Throne of the Tides
    [463] = 424197, -- Dawn of the Infinite Fall
    [464] = 424197, -- Dawn of the Infinite Rise
};

local mapIDtoDungeonName = {
    [2]   = "Temple of the Jade Serpent",
    [3]   = "Siege of Niuzao",
    [4]   = "Scholomance",
    [5]   = "Scarlet Monastery",
    [6]   = "Scarlet Halls",
    [7]   = "Gate of the Setting Sun",
    [8]   = "Mogu'Shan Palance",
    [9]   = "Shado-Pan Monastery",
    [10]  = "Stormstout Brewery",
    [165] = "Shadowmoon Burial Ground",
    [168] = "Everbloom",
    [169] = "Bloodmaul Slag Mines",
    [170] = "Auchindoun",
    [171] = "Skyreach",
    [172] = "Upper Blackrock Spire",
    [173] = "Grimrail Depot",
    [174] = "Iron Docks",
    [198] = "Darkheart Thicket",
    [199] = "Black Rook Hold",
    [200] = "Halls of Valor",
    [206] = "Neltharion's Lair",
    [210] = "Court of Stars",
    [211] = "Karazhan",
    [244] = "Atal'Dazar",
    [245] = "Freehold",
    [248] = "Waycrest Manor",
    [251] = "The Underrot",
    [252] = "Mechagon",
    [300] = "The Necrotic Wake",
    [301] = "Plaguefall",
    [302] = "Mists of Tirna Scithe",
    [303] = "Halls of Atonement",
    [304] = "Spires of Ascension",
    [305] = "Theatre of Pain",
    [306] = "De Other Side",
    [307] = "Sanguine Depths",
    [308] = "Tazavesh, the Veiled Market",
    [399] = "Ruby Life Pools",
    [400] = "Nokhud Offensive",
    [401] = "Azure Vault",
    [402] = "Algethar Academy",
    [403] = "Uldaman: Legacy of Tyr",
    [404] = "Neltharus",
    [405] = "Brackenhide Hollow",
    [406] = "Halls of Infusion",
    [438] = "Vortex Pinnacle",
    [456] = "Throne of the Tides",
    [463] = "Dawn of the Infinite Fall",
    [464] = "Dawn of the Infinite Rise"
}

local mapExpansionToBackground = {
    ["Cataclysm"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Cata.tga",
    ["Mists of Pandaria"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\MoP.tga",
    ["Warlords of Draenor"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WoD.tga",
    ["Legion"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Legion.tga",
    ["Battle For Azeroth"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\BFA.tga",
    ["Shadowlands"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Shadowlands.tga",
    ["Dragonflight"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Dragonflight.tga",
    ["War Within"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WarWithin.tga",
    ["Current Season"] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WarWithin.tga",
}

local iconPath = "Interface\\Icons\\Achievement_ChallengeMode_Gold"

local constants = {
    myIdToExpansion = myIdToExpansion,
    orderedExpansions = orderedExpansions,
    mapExpansionToMapID = mapExpansionToMapID,
    mapIDtoSpellID = mapIDtoSpellID,
    mapIDtoDungeonName = mapIDtoDungeonName,
    mapExpansionToBackground = mapExpansionToBackground,
    iconPath = iconPath,
}

addon.constants = constants