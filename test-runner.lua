#!/usr/bin/env lua

-- Simple test runner for MythicDungeonPortals
-- Run this script directly: lua test-runner.lua

print("🧪 MythicDungeonPortals Test Runner")
print("=" .. string.rep("=", 50))

-- Load the test framework
local TestFramework = require("tests.test-framework")

-- Load test suites
local testSuites = {
    require("tests.test-constants")
}

-- Run all test suites
local totalPassed = 0
local totalFailed = 0

for i, testSuite in ipairs(testSuites) do
    -- Validate that we got a proper test suite
    if type(testSuite) ~= "table" then
        print("❌ Test suite " .. i .. " is not a table (got " .. type(testSuite) .. ")")
        totalFailed = totalFailed + 1
    elseif not testSuite.name or not testSuite.tests then
        print("❌ Test suite " .. i .. " is missing required fields")
        totalFailed = totalFailed + 1
    else
        local passed, failed = TestFramework.runTests(testSuite)
        totalPassed = totalPassed + passed
        totalFailed = totalFailed + failed
    end
    print("")
end

print("=" .. string.rep("=", 50))
print(string.format("📊 Final Results: %d passed, %d failed", totalPassed, totalFailed))

if totalFailed == 0 then
    print("🎉 All tests passed!")
    os.exit(0)
else
    print("⚠️  Some tests failed. Please review the output above.")
    os.exit(1)
end
