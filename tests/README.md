# 🧪 Testing Guide for MythicDungeonPortals

This directory contains the testing framework and unit tests for the MythicDungeonPortals addon.

## 📁 File Structure

```
tests/
├── README.md              # This file
├── test-framework.lua     # Core testing framework with WoW API mocks
├── test-constants.lua     # Tests for Constants.lua
├── test-localization.lua  # Tests for localization files
└── run-tests.lua         # Test runner script
```

## 🚀 Getting Started

### Prerequisites

1. **Lua Interpreter**: Make sure you have Lua installed on your system
2. **Node.js**: For running npm scripts (optional but recommended)

### Running Tests

#### Option 1: Direct Lua execution
```bash
lua tests/run-tests.lua
```

#### Option 2: Using npm scripts
```bash
npm test                    # Run tests once
npm run test:watch         # Run tests in watch mode
npm run test:coverage      # Run tests with coverage (if implemented)
```

## 🧩 Testing Framework

The testing framework provides:

### Mock WoW API Functions
- `CreateFrame()` - Mocked frame creation
- `IsSpellKnown()` - Mocked spell checking
- `UIParent`, `GameFontHighlight` - Mocked global variables

### Assertion Functions
- `TestFramework.assert(condition, message)` - Basic assertion
- `TestFramework.assertEquals(expected, actual, message)` - Value equality
- `TestFramework.assertTableEquals(expected, actual, message)` - Table equality

### Test Runner
- `TestFramework.runTests(testSuite)` - Runs a test suite and reports results

## 📝 Writing Tests

### Basic Test Structure

```lua
local testSuite = {
    name = "My Test Suite",
    tests = {
        ["Test Name"] = function()
            -- Test code here
            TestFramework.assertEquals(expected, actual, "Description")
        end,
        
        ["Another Test"] = function()
            -- More test code
            TestFramework.assert(condition, "Description")
        end
    }
}

TestFramework.runTests(testSuite)
```

### Example Test

```lua
["Test spell ID mapping"] = function()
    local spellID = constants.mapIDtoSpellID[2]
    TestFramework.assertEquals(131204, spellID, "Temple of the Jade Serpent spell ID")
end
```

## 🎯 What to Test

### 1. **Constants and Data Structures**
- ✅ Map ID to Spell ID mappings
- ✅ Expansion to Map ID groupings
- ✅ Background texture mappings
- ✅ Data consistency and completeness

### 2. **Localization**
- ✅ All required keys are present
- ✅ No missing translations
- ✅ Proper formatting

### 3. **Business Logic** (when extracted)
- ✅ Spell availability checking
- ✅ Tab creation logic
- ✅ Background switching logic

### 4. **Edge Cases**
- ✅ Invalid map IDs
- ✅ Missing spell IDs
- ✅ Empty expansion lists

## 🔧 Adding New Tests

### Step 1: Create Test File
Create a new file in the `tests/` directory:
```lua
-- tests/test-your-feature.lua
local TestFramework = require("tests.test-framework")

local testSuite = {
    name = "Your Feature Tests",
    tests = {
        -- Your tests here
    }
}

TestFramework.runTests(testSuite)
```

### Step 2: Add to Test Runner
Update `tests/run-tests.lua`:
```lua
local testSuites = {
    require("tests.test-constants"),
    require("tests.test-your-feature")  -- Add this line
}
```

### Step 3: Run Tests
Ensure node and lua are installed
```bash
npm test
```

## 🐛 Debugging Tests

### Enable Debug Mode
Add debug output to your tests:
```lua
["Debug Test"] = function()
    print("Debug: Testing value:", someValue)
    TestFramework.assertEquals(expected, someValue)
end
```

### Mock WoW API Behavior
Modify the mock functions in `test-framework.lua`:
```lua
IsSpellKnown = function(spellID)
    -- Return different values for testing
    if spellID == 131204 then
        return true
    else
        return false
    end
end
```

## 📊 Test Coverage

### Current Coverage
- ✅ Constants.lua - Data structure validation
- ✅ Map ID mappings
- ✅ Expansion groupings
- ✅ Background mappings

### Planned Coverage
- 🔄 Localization files
- 🔄 UI component logic
- 🔄 Settings functionality
- 🔄 Minimap integration

## 🚨 Best Practices

1. **Test One Thing**: Each test should verify one specific behavior
2. **Descriptive Names**: Use clear, descriptive test names
3. **Mock Dependencies**: Always mock WoW API calls
4. **Edge Cases**: Test boundary conditions and error cases
5. **Data Validation**: Verify data structure integrity
6. **Fast Execution**: Keep tests quick to run

## 🔄 Continuous Integration

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Lua
        uses: leafo/setup-lua@v1
        with:
          lua-version: 5.4
      - name: Run Tests
        run: lua tests/run-tests.lua
```

## 📚 Additional Resources

- [Lua Testing Best Practices](https://lua-users.org/wiki/UnitTesting)
- [WoW API Documentation](https://wowpedia.fandom.com/wiki/World_of_Warcraft_API)
- [Addon Development Guide](https://wowpedia.fandom.com/wiki/AddOn_development)

---

*Happy testing! 🎉*
