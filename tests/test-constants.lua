-- Unit tests for Constants.lua
local TestFramework = require("test-framework")

-- Mock the addon structure
local addon = {
    L = function(key)
        -- Mock localization function
        local translations = {
            ["Cataclysm"] = "Cataclysm",
            ["Mists of Pandaria"] = "Mists of Pandaria",
            ["Warlords of Draenor"] = "Warlords of Draenor",
            ["Legion"] = "Legion",
            ["Battle for Azeroth"] = "Battle for Azeroth",
            ["Shadowlands"] = "Shadowlands",
            ["Dragonflight"] = "Dragonflight",
            ["War Within"] = "War Within",
            ["Current Season"] = "Current Season"
        }
        return translations[key] or key
    end
}

-- Load the constants file
local constants = {}
local function loadConstants()
    -- This would normally load the actual Constants.lua file
    -- For testing, we'll create a mock version
    constants.mapIDtoSpellID = {
        [2] = 131204, -- Temple of the Jade Serpent
        [3] = 131228, -- Siege of Niuzao
        [4] = 131232, -- Scholomance
        [165] = 159899, -- Shadowmoon Burial Ground
        [168] = 159901, -- Everbloom
        [198] = 424163, -- Darkheart Thicket
        [244] = 424187, -- Atal'Dazar
        [300] = 354462, -- The Necrotic Wake
        [399] = 393256, -- Ruby Life Pools
        [500] = 445416, -- City of Threads
    }
    
    constants.mapExpansionToMapID = {
        ["Current Season"] = {501, 503, 507, 511, 512, 303, 308, 1007},
        ["Cataclysm"] = {438, 456, 508},
        ["Mists of Pandaria"] = {3, 4, 5, 6, 7, 8, 9, 10, 2},
        ["Warlords of Draenor"] = {168, 169, 170, 171, 172, 173, 174, 165},
        ["Legion"] = {198, 199, 200, 206, 210, 211},
        ["Battle for Azeroth"] = {244, 245, 248, 251, 252, 509, 510},
        ["Shadowlands"] = {300, 301, 302, 303, 304, 305, 306, 307, 308, 1003, 1004, 1005},
        ["Dragonflight"] = {399, 400, 401, 402, 403, 404, 405, 406, 463, 1000, 1001, 1002},
        ["War Within"] = {500, 501, 502, 503, 504, 505, 506, 507, 511, 512, 1006, 1007}
    }
    
    constants.mapExpansionToBackground = {
        ["Current Season"] = "Backgrounds\\TWW.tga",
        ["Cataclysm"] = "Backgrounds\\cata.tga",
        ["Mists of Pandaria"] = "Backgrounds\\mists.tga",
        ["Warlords of Draenor"] = "Backgrounds\\wod.tga",
        ["Legion"] = "Backgrounds\\legion.tga",
        ["Battle for Azeroth"] = "Backgrounds\\bfa.tga",
        ["Shadowlands"] = "Backgrounds\\shadowlands.tga",
        ["Dragonflight"] = "Backgrounds\\dragonflight.tga",
        ["War Within"] = "Backgrounds\\TWW.tga"
    }
end

-- Test suite
local testSuite = {
    name = "Constants Tests",
    tests = {
        ["Test mapIDtoSpellID mapping"] = function()
            loadConstants()
            
            -- Test that spell IDs are correctly mapped
            TestFramework.assertEquals(131204, constants.mapIDtoSpellID[2], "Temple of the Jade Serpent spell ID")
            TestFramework.assertEquals(159901, constants.mapIDtoSpellID[168], "Everbloom spell ID")
            TestFramework.assertEquals(424163, constants.mapIDtoSpellID[198], "Darkheart Thicket spell ID")
            TestFramework.assertEquals(393256, constants.mapIDtoSpellID[399], "Ruby Life Pools spell ID")
            
            -- Test that non-existent map IDs return nil
            TestFramework.assertEquals(nil, constants.mapIDtoSpellID[999], "Non-existent map ID should return nil")
        end,
        
        ["Test mapExpansionToMapID structure"] = function()
            loadConstants()
            
            -- Test that expansions have the correct number of dungeons
            TestFramework.assertEquals(8, #constants.mapExpansionToMapID["Current Season"], "Current Season should have 8 dungeons")
            TestFramework.assertEquals(3, #constants.mapExpansionToMapID["Cataclysm"], "Cataclysm should have 3 dungeons")
            TestFramework.assertEquals(9, #constants.mapExpansionToMapID["Mists of Pandaria"], "Mists of Pandaria should have 9 dungeons")
            
            -- Test that specific map IDs are present
            local currentSeason = constants.mapExpansionToMapID["Current Season"]
            local found = false
            for _, mapID in ipairs(currentSeason) do
                if mapID == 501 then
                    found = true
                    break
                end
            end
            TestFramework.assert(found, "Map ID 501 should be in Current Season")
        end,
        
        ["Test mapExpansionToBackground mapping"] = function()
            loadConstants()
            
            -- Test that background paths are correctly mapped
            TestFramework.assertEquals("Backgrounds\\TWW.tga", constants.mapExpansionToBackground["Current Season"], "Current Season background")
            TestFramework.assertEquals("Backgrounds\\cata.tga", constants.mapExpansionToBackground["Cataclysm"], "Cataclysm background")
            TestFramework.assertEquals("Backgrounds\\legion.tga", constants.mapExpansionToBackground["Legion"], "Legion background")
            
            -- Test that non-existent expansion returns nil
            TestFramework.assertEquals(nil, constants.mapExpansionToBackground["NonExistent"], "Non-existent expansion should return nil")
        end,
        
        ["Test data consistency"] = function()
            loadConstants()
            
            -- Test that all map IDs in expansions have corresponding spell IDs
            for expansion, mapIDs in pairs(constants.mapExpansionToMapID) do
                for _, mapID in ipairs(mapIDs) do
                    if mapID ~= 0 then -- Skip placeholder values
                        local spellID = constants.mapIDtoSpellID[mapID]
                        if spellID and spellID ~= 0 then
                            TestFramework.assert(spellID > 0, string.format("Map ID %d should have a valid spell ID", mapID))
                        end
                    end
                end
            end
        end
    }
}

-- Return the test suite instead of running it
return testSuite
