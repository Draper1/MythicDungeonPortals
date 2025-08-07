-- Test Framework for MythicDungeonPortals
-- This file provides mocks for WoW API functions to enable unit testing

local TestFramework = {}

-- Mock WoW API functions
local WoWAPI = {
    -- Frame creation
    CreateFrame = function(frameType, name, parent, template)
        return {
            SetSize = function() end,
            SetPoint = function() end,
            SetMovable = function() end,
            EnableMouse = function() end,
            SetClampedToScreen = function() end,
            RegisterForDrag = function() end,
            SetScript = function() end,
            CreateTexture = function()
                return {
                    SetAllPoints = function() end,
                    SetTexture = function() end,
                    Show = function() end,
                    Hide = function() end,
                    SetDesaturated = function() end
                }
            end,
            CreateFontString = function()
                return {
                    SetFontObject = function() end,
                    SetPoint = function() end,
                    SetText = function() end
                }
            end,
            RegisterForClicks = function() end,
            SetAttribute = function() end,
            LockHighlight = function() end,
            UnlockHighlight = function() end,
            Enable = function() end,
            Disable = function() end
        }
    end,
    
    -- Spell functions
    IsSpellKnown = function(spellID)
        -- Mock implementation - return true for testing
        return true
    end,
    
    -- Global variables
    UIParent = {},
    GameFontHighlight = {},
    
    -- Global functions
    _G = {}
}

-- Inject mocks into global environment
for name, func in pairs(WoWAPI) do
    _G[name] = func
end

-- Test utilities
function TestFramework.assert(condition, message)
    if not condition then
        error("Test failed: " .. (message or "Unknown error"))
    end
end

function TestFramework.assertEquals(expected, actual, message)
    if expected ~= actual then
        error(string.format("Test failed: Expected %s, got %s. %s", 
            tostring(expected), tostring(actual), message or ""))
    end
end

function TestFramework.assertTableEquals(expected, actual, message)
    if type(expected) ~= type(actual) then
        error(string.format("Test failed: Expected type %s, got %s. %s", 
            type(expected), type(actual), message or ""))
    end
    
    if type(expected) == "table" then
        for k, v in pairs(expected) do
            if actual[k] ~= v then
                error(string.format("Test failed: Key %s expected %s, got %s. %s", 
                    tostring(k), tostring(v), tostring(actual[k]), message or ""))
            end
        end
    end
end

-- Test runner
function TestFramework.runTests(testSuite)
    -- Validate testSuite is a table
    if type(testSuite) ~= "table" then
        error("TestFramework.runTests: Expected table, got " .. type(testSuite))
    end
    
    -- Validate testSuite has required fields
    if not testSuite.name then
        error("TestFramework.runTests: testSuite missing 'name' field")
    end
    
    if not testSuite.tests or type(testSuite.tests) ~= "table" then
        error("TestFramework.runTests: testSuite missing 'tests' table")
    end
    
    local passed = 0
    local failed = 0
    
    print("🧪 Running tests for " .. testSuite.name)
    
    for testName, testFunc in pairs(testSuite.tests) do
        if type(testFunc) ~= "function" then
            print("  ❌ " .. testName .. ": Not a function")
            failed = failed + 1
        else
            local success, error = pcall(testFunc)
            if success then
                print("  ✅ " .. testName)
                passed = passed + 1
            else
                print("  ❌ " .. testName .. ": " .. error)
                failed = failed + 1
            end
        end
    end
    
    print(string.format("📊 Results: %d passed, %d failed", passed, failed))
    return passed, failed
end

return TestFramework
