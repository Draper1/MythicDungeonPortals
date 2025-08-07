-- Test Runner for MythicDungeonPortals
-- Run this script to execute all tests

local TestFramework = require("tests.test-framework")

-- Import all test suites
local testSuites = {
    require("tests.test-constants")
}

-- Run all test suites
local totalPassed = 0
local totalFailed = 0

print("🚀 Starting MythicDungeonPortals Test Suite")
print("=" .. string.rep("=", 50))

for _, testSuite in ipairs(testSuites) do
    local passed, failed = TestFramework.runTests(testSuite)
    totalPassed = totalPassed + passed
    totalFailed = totalFailed + failed
    print("")
end

print("=" .. string.rep("=", 50))
print(string.format("📊 Final Results: %d passed, %d failed", totalPassed, totalFailed))

if totalFailed == 0 then
    print("🎉 All tests passed!")
else
    print("⚠️  Some tests failed. Please review the output above.")
end
