local _, addon = ...
local L = addon.L

local debugMode = false

local myIdToExpansion = {
    [0] = L["Cataclysm"],
    [1] = L["Mists of Pandaria"],
    [2] = L["Warlords of Draenor"],
    [3] = L["Legion"],
    [4] = L["Battle for Azeroth"],
    [5] = L["Shadowlands"],
    [6] = L["Dragonflight"],
    [7] = L["War Within"],
    [8] = L["Current Season"]
}

local orderedExpansions = {
    L["Current Season"],
    L["Cataclysm"],
    L["Mists of Pandaria"],
    L["Warlords of Draenor"],
    L["Legion"],
    L["Battle for Azeroth"],
    L["Shadowlands"],
    L["Dragonflight"],
    L["War Within"]
}

local mapExpansionToMapID = {
    [L["Current Season"]] = {244, 199, 198, 463, 168, 456, 248},
    [L["Cataclysm"]] = {438, 456},
    [L["Mists of Pandaria"]] = {2, 3, 4, 5, 6, 7, 8, 9, 10},
    [L["Warlords of Draenor"]] = {165, 168, 169, 170, 171, 172, 173, 174},
    [L["Legion"]] = {198, 199, 200, 206, 210, 211},
    [L["Battle For Azeroth"]] = {244, 245, 248, 251, 252},
    [L["Shadowlands"]] = {300, 301, 302, 303, 304, 305, 306, 307, 308},
    [L["Dragonflight"]] = {399, 400, 401, 402, 403, 404, 405, 406, 463},
    [L["War Within"]] = {} 
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
    [463] = 424197, -- Dawn of the Infinite
};

local mapIDtoDungeonName = {
    [2]   = L["DUNGEON_TEMPLE_OF_THE_JADE_SERPENT"],
    [3]   = L["DUNGEON_SIEGE_OF_NIUZAO"],
    [4]   = L["DUNGEON_SCHOLOMANCE"],
    [5]   = L["DUNGEON_SCARLET_MONASTERY"],
    [6]   = L["DUNGEON_SCARLET_HALLS"],
    [7]   = L["DUNGEON_GATE_OF_THE_SETTING_SUN"],
    [8]   = L["DUNGEON_MOGUSHAN_PALACE"],
    [9]   = L["DUNGEON_SHADO_PAN_MONASTERY"],
    [10]  = L["DUNGEON_STORMSTOUT_BREWERY"],
    [165] = L["DUNGEON_SHADOWMOON_BURIAL_GROUNDS"],
    [168] = L["DUNGEON_EVERBLOOM"],
    [169] = L["DUNGEON_BLOODMAUL_SLAG_MINES"],
    [170] = L["DUNGEON_AUCHINDOUN"],
    [171] = L["DUNGEON_SKYREACH"],
    [172] = L["DUNGEON_UPPER_BLACKROCK_SPIRE"],
    [173] = L["DUNGEON_GRIMRAIL_DEPOT"],
    [174] = L["DUNGEON_IRON_DOCKS"],
    [198] = L["DUNGEON_DARKHEART_THICKET"],
    [199] = L["DUNGEON_BLACK_ROOK_HOLD"],
    [200] = L["DUNGEON_HALLS_OF_VALOR"],
    [206] = L["DUNGEON_NELTHARIONS_LAIR"],
    [210] = L["DUNGEON_COURT_OF_STARS"],
    [211] = L["DUNGEON_KARAZHAN"],
    [244] = L["DUNGEON_ATALDAZAR"],
    [245] = L["DUNGEON_FREEHOLD"],
    [248] = L["DUNGEON_WAYCREST_MANOR"],
    [251] = L["DUNGEON_THE_UNDERROT"],
    [252] = L["DUNGEON_MECHAGON"],
    [300] = L["DUNGEON_THE_NECROTIC_WAKE"],
    [301] = L["DUNGEON_PLAGUEFALL"],
    [302] = L["DUNGEON_MISTS_OF_TIRNA_SCITHE"],
    [303] = L["DUNGEON_HALLS_OF_ATONEMENT"],
    [304] = L["DUNGEON_SPIRES_OF_ASCENSION"],
    [305] = L["DUNGEON_THEATRE_OF_PAIN"],
    [306] = L["DUNGEON_DE_OTHER_SIDE"],
    [307] = L["DUNGEON_SANGUINE_DEPTHS"],
    [308] = L["DUNGEON_TAZAVESH_THE_VEILED_MARKET"],
    [399] = L["DUNGEON_RUBY_LIFE_POOLS"],
    [400] = L["DUNGEON_NOKHUD_OFFENSIVE"],
    [401] = L["DUNGEON_AZURE_VAULT"],
    [402] = L["DUNGEON_ALGETHAR_ACADEMY"],
    [403] = L["DUNGEON_ULDAMAN"],
    [404] = L["DUNGEON_NELTHARUS"],
    [405] = L["DUNGEON_BRACKENHIDE_HOLLOW"],
    [406] = L["DUNGEON_HALLS_OF_INFUSION"],
    [438] = L["DUNGEON_VORTEX_PINNACLE"],
    [456] = L["DUNGEON_THRONE_OF_THE_TIDES"],
    [463] = L["DUNGEON_DAWN_OF_THE_INFINITE"],
}


local mapExpansionToBackground = {
    [L["Cataclysm"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Cata.tga",
    [L["Mists of Pandaria"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\MoP.tga",
    [L["Warlords of Draenor"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WoD.tga",
    [L["Legion"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Legion.tga",
    [L["Battle For Azeroth"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\BFA.tga",
    [L["Shadowlands"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Shadowlands.tga",
    [L["Dragonflight"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\Dragonflight.tga",
    [L["War Within"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WarWithin.tga",
    [L["Current Season"]] = "Interface\\AddOns\\MythicDungeonPortals\\Images\\WarWithin.tga",
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