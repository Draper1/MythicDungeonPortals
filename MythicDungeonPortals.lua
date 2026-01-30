-- MythicDungeonPortals.lua
local addonName, addon = ...
local constants = addon.constants
local L = addon.L

local currentTab = nil
local totalTabs = 0
local tabsCreated = false  -- flag to check if tabs are already created

local MDPFrame = CreateFrame("Frame", "MDPFrame", UIParent, "BasicFrameTemplate")

MDPFrame:SetSize(400, 600)
MDPFrame:SetPoint("CENTER")
MDPFrame:SetMovable(true)
MDPFrame:EnableMouse(true)
MDPFrame:SetClampedToScreen(true)
MDPFrame:RegisterForDrag("LeftButton")
MDPFrame:SetScript("OnDragStart", MDPFrame.StartMoving)
MDPFrame:SetScript("OnDragStop", MDPFrame.StopMovingOrSizing)

MDPFrame.background = MDPFrame:CreateTexture(nil, "BACKGROUND")
MDPFrame.background:SetAllPoints(MDPFrame)

local function InitializeBackground()
    if MythicDungeonPortalsSettings and not MythicDungeonPortalsSettings.BackgroundVisible then
        MDPFrame.background:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")
    end
end

local function UpdateFrameBackground(selectedTabName)
    local texturePath = constants.mapExpansionToBackground[selectedTabName]
    if texturePath and MythicDungeonPortalsSettings.BackgroundVisible then
        MDPFrame.background:SetTexture(texturePath)
        MDPFrame.background:Show()
    else
        MDPFrame.background:Hide()
    end
end

function MythicDungeonPortals:UpdateBackgroundVisibility()
    UpdateFrameBackground(currentTab)
end

MDPFrame.title = MDPFrame:CreateFontString(nil, "OVERLAY")
MDPFrame.title:SetFontObject("GameFontHighlight")
MDPFrame.title:SetPoint("CENTER", MDPFrame.TitleBg, "CENTER")
MDPFrame.title:SetText(L["MDP_TITLE"])
MDPFrame.TitleBg:SetColorTexture(0, 0, 0)  -- RGB for black

local contentFrames = {}
local tabButtons = {}

local function UpdateTabButtonStates(selectedExpansion)
    for expansion, button in pairs(tabButtons) do
        if expansion == selectedExpansion then
            button:LockHighlight()  -- visually indicates active button
        else
            button:UnlockHighlight()
        end
    end
end

local function HasLearnedSpell(spellID)
    return IsSpellKnown(spellID)
end

local function UpdateButtonCooldown(button)
    if not button or not button.spellID or not button.cooldown then
        return
    end
    
    local startTime, duration
    
    -- Get cooldown info using C_Spell.GetSpellCooldown (modern API)
    if C_Spell and C_Spell.GetSpellCooldown then
        local cooldownInfo = C_Spell.GetSpellCooldown(button.spellID)
        if cooldownInfo then
            startTime = cooldownInfo.startTime
            duration = cooldownInfo.duration
        end
    end
    
    -- Update cooldown display if we have valid cooldown data
    -- Use SetCooldown method directly on the cooldown frame (standard WoW API)
    if startTime and duration and duration > 0 then
        button.cooldown:SetCooldown(startTime, duration)
    else
        -- Clear cooldown if spell is ready
        button.cooldown:SetCooldown(0, 0)
    end
end

local function UpdateAllCooldowns()
    -- Update cooldowns for all buttons across all tabs
    for expansion, tabFrame in pairs(contentFrames) do
        local mapIDs = constants.mapExpansionToMapID[expansion]
        if mapIDs then
            for index, mapID in ipairs(mapIDs) do
                local buttonName = "MDPSpellButton_" .. expansion .. "_" .. mapID
                local button = _G[buttonName]
                if button then
                    UpdateButtonCooldown(button)
                end
            end
        end
    end
end

local function UpdateSpellStates(tabFrame, mapIDs, expansionName)
    -- Find all spell buttons in the tab and update their states
    for index, mapID in ipairs(mapIDs) do
        local spellID = constants.mapIDtoSpellID[mapID]
        local buttonName = "MDPSpellButton_" .. expansionName .. "_" .. mapID
        local button = _G[buttonName]
        
        if button and spellID then
            local icon = button.icon
            if not HasLearnedSpell(spellID) then
                icon:SetDesaturated(true)
                button:Disable()
            else
                icon:SetDesaturated(false)
                button:Enable()
                -- Update the click/drag handlers only if they haven't been set
                if not button.handlersSet then
                    button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
                    button:RegisterForDrag("RightButton")
                    button:SetAttribute("type", "spell")
                    button:SetAttribute("unit", "player")
                    button:SetAttribute("spell", spellID)
                    button.handlersSet = true
                end
            end
            -- Update cooldown display
            UpdateButtonCooldown(button)
        end
    end
end

local function AddSpellIcons(tabFrame, mapIDs, expansionName)
    local buttonSize = 40 -- Size of each spell icon button
    local padding = 5    -- Padding between buttons
    local numColumns = 1 -- Number of buttons per row
    local topPadding = 35 -- the first button's padding from the top
    local leftPadding = 20 -- pad the buttons by a set 20px
    local textOffset = 5 -- Offset for the text from the button

    for index, mapID in ipairs(mapIDs) do
        local spellID = constants.mapIDtoSpellID[mapID]
        local dungeonName = constants.mapIDtoDungeonName[mapID]
        if spellID then
            -- Create button with a unique name that includes the expansion
            local button = CreateFrame("Button", "MDPSpellButton_" .. expansionName .. "_" .. mapID, tabFrame, "SecureActionButtonTemplate")
            button:SetSize(buttonSize, buttonSize)

            -- Calculate position
            local row = math.floor((index - 1) / numColumns)
            local col = (index - 1) % numColumns
            button:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", col * (buttonSize + padding) + leftPadding, -row * (buttonSize + padding) - topPadding)

            -- Create and set icon texture
            local icon = button:CreateTexture(nil, "ARTWORK")
            icon:SetAllPoints(button)
            local spellTexture = C_Spell.GetSpellTexture(spellID)
            icon:SetTexture(spellTexture)

            -- Store icon reference on the button
            button.icon = icon

            -- Create cooldown and other visual elements without checking spell state
            local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            cooldown:SetAllPoints(button)
            
            -- Store references for cooldown updates
            button.cooldown = cooldown
            button.spellID = spellID
            
            -- Set up periodic cooldown updates using OnUpdate
            -- This ensures cooldowns are updated even if events don't fire
            -- Only update when the parent frame is visible to save performance
            local lastUpdate = 0
            button:SetScript("OnUpdate", function(self, elapsed)
                -- Only update if the frame is visible
                if not MDPFrame:IsVisible() then
                    return
                end
                lastUpdate = lastUpdate + elapsed
                if lastUpdate >= 0.5 then  -- Update every 0.5 seconds
                    lastUpdate = 0
                    UpdateButtonCooldown(button)
                end
            end)

            -- Move all spell-specific logic to UpdateSpellStates
            button:SetMovable(true)
            
            -- Keep the tooltip and cooldown functionality
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(spellID)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            local dungeonText = tabFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
            dungeonText:SetPoint("LEFT", button, "RIGHT", textOffset, 0)
            dungeonText:SetText(dungeonName)
        end
    end
end

local function UpdateMDPTabs(selectedTabName)
    for name, tabFrame in pairs(contentFrames) do
        if name == selectedTabName then
            tabFrame:Show()
        else
            tabFrame:Hide()
        end
    end
    currentTab = selectedTabName
    UpdateAllCooldowns()  -- Update cooldowns when switching tabs
end

-- Function to create tabs
local function CreateTab(expansionName, mapIDs)
    local topPadding = 30
    totalTabs = totalTabs + 1
    local tabButton = CreateFrame("Button", nil, MDPFrame, "UIPanelButtonTemplate")
    
    tabButton:SetSize(120, 30)
    tabButton:SetPoint("TOPRIGHT", MDPFrame, "TOPRIGHT", -20, -(topPadding + (totalTabs - 1) * 30))
    tabButton:SetText(expansionName)
    tabButton:SetNormalFontObject("GameFontNormal")
    tabButton:SetHighlightFontObject("GameFontHighlight")
    
    tabButtons[expansionName] = tabButton

    local tabFrame = CreateFrame("Frame", nil, MDPFrame)
    tabFrame:SetAllPoints()
    tabFrame:Hide()
    
    contentFrames[expansionName] = tabFrame
    AddSpellIcons(tabFrame, mapIDs, expansionName)
    
    -- Event handler for tab click
    tabButton:SetScript("OnClick", function()
        UpdateMDPTabs(expansionName)
        UpdateTabButtonStates(expansionName)
        UpdateFrameBackground(expansionName)
    end)
    
    -- Initially show content of the first tab and mark its button active
    if totalTabs == 1 then
        UpdateMDPTabs(expansionName)
        UpdateTabButtonStates(expansionName)
        UpdateFrameBackground(expansionName)
    end
    if constants.debugMode == true then
        print("Tab created for " .. expansionName)
    end
end

local function InitializeTabs()
    tabsCreated = true
    -- First check if character is Alliance or Horde
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        constants.mapIDtoSpellID[509] = 445418 -- Siege of Boralus
        constants.mapIDtoSpellID[510] = 467553 -- Motherlode
    elseif faction == "Horde" then
        constants.mapIDtoSpellID[509] = 464256 -- Siege of Boralus
        constants.mapIDtoSpellID[510] = 467555 -- Motherlode
    end

    for _, expansion in ipairs(constants.orderedExpansions) do
        local mapIDs = constants.mapExpansionToMapID[expansion]
        if mapIDs then
            CreateTab(expansion, mapIDs)
        end
    end
end

local function ToggleFrame()
    if MDPFrame:IsShown() then
        MDPFrame:Hide()
    else
        MDPFrame:Show()
        UpdateAllCooldowns()  -- Update cooldowns when frame is shown
    end
end

local function BeginPlayerEnteringWorld()
    if not tabsCreated then
        InitializeTabs()
    end
    
    -- Update spell states for all tabs
    for expansion, tabFrame in pairs(contentFrames) do
        local mapIDs = constants.mapExpansionToMapID[expansion]
        if mapIDs then
            UpdateSpellStates(tabFrame, mapIDs, expansion)
        end
    end
    
    MDPFrame:Hide()
end

MDPFrame:SetScript("OnEvent", function(self, event, addonNameLoaded, ...)
    if event == "ADDON_LOADED" and addonNameLoaded == addonName then
        MythicDungeonPortals:OnInitialize()
        MythicDungeonPortals:InitializeMinimap()
        MythicDungeonPortals:CreateSettingsFrame()
        InitializeBackground()  -- Initialize background after settings are loaded
        if constants.debugMode == true then
            print("Mythic Dungeon Portals loaded. Waiting for player to enter the world...")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        BeginPlayerEnteringWorld()
    elseif event == "SPELL_UPDATE_COOLDOWN" or event == "ACTIONBAR_UPDATE_COOLDOWN" then
        UpdateAllCooldowns()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        local unit = ...
        if unit and UnitIsUnit(unit, "player") then
            UpdateAllCooldowns()
        end
    end
end)

MDPFrame:RegisterEvent("ADDON_LOADED")
MDPFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
MDPFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
MDPFrame:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
MDPFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")

local function SlashCmdHandler(msg, editbox)
    local command, rest = msg:match("^(%S*)%s*(.-)$")
    command = command:lower()
    if command == "settings" then
        local settingsFrame = MythicDungeonPortals:GetSettingsFrame()
        if settingsFrame then
            settingsFrame:SetShown(not settingsFrame:IsShown())
        end
    else
        ToggleFrame()
    end
end

SLASH_MDP1 = "/mdp"
SlashCmdList["MDP"] = SlashCmdHandler