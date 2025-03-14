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
MDPFrame.background:SetTexture("Interface\\FrameGeneral\\UI-Background-Rock")

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

local function AddSpellIcons(tabFrame, mapIDs)
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
            local button = CreateFrame("Button", nil, tabFrame, "SecureActionButtonTemplate")
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

            -- Create cooldown frame
            local cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
            cooldown:SetAllPoints(button)

            -- Update the cooldown
            local function UpdateCooldown()
                local start, duration, enable = C_Spell.GetSpellCooldown(spellID)
                CooldownFrame_Set(cooldown, start, duration, enable)
            end

            -- Make the button movable
            button:SetMovable(true)

            -- Check if the spell is learned
            if not HasLearnedSpell(spellID) then
                icon:SetDesaturated(true)
                button:Disable()
            else
                button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
                button:RegisterForDrag("RightButton") -- todo: fix drag left button conflict
                button:SetAttribute("type", "spell")
                button:SetAttribute("unit", "player")
                button:SetAttribute("spell", spellID)
                UpdateCooldown() -- Update cooldown initially
            end

            button:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            button:SetScript("OnEvent", UpdateCooldown)

            -- Allow spell to be dragged to action bar
            button:SetScript("OnDragStart", function(self)
                if IsShiftKeyDown() then
                    C_Spell.PickupSpell(spellID)
                end
            end)
            button:SetScript("OnReceiveDrag", function(self)
                C_Spell.PlaceAction(self:GetID())
            end)

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
    AddSpellIcons(tabFrame, mapIDs)
    
    -- Event handler for tab click
    tabButton:SetScript("OnClick", function()
        UpdateMDPTabs(expansionName)
        UpdateTabButtonStates(expansionName)
    end)
    
    -- Initially show content of the first tab and mark its button active
    if totalTabs == 1 then
        UpdateMDPTabs(expansionName)
        UpdateTabButtonStates(expansionName)
    end
    if constants.debugMode == true then
        print("Tab created for " .. expansionName)
    end
end

local function InitializeTabs()
    if tabsCreated then
        if constants.debugMode == true then
            print("Tabs already created; skipping initialization.")
        end
        return
    end
    tabsCreated = true

    -- First check if character is Alliance or Horde
    local faction = UnitFactionGroup("player")
    if faction == "Alliance" then
        constants.mapIDtoSpellID[509] = 445418
    elseif faction == "Horde" then
        constants.mapIDtoSpellID[509] = 464256
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
    end
end

MDPFrame:SetScript("OnEvent", function(self, event, addonNameLoaded)
    if event == "ADDON_LOADED" and addonNameLoaded == addonName then
        MythicDungeonPortals:OnInitialize()
        MythicDungeonPortals:InitializeMinimap()
        MythicDungeonPortals:CreateSettingsFrame()
        if constants.debugMode == true then
            print("Mythic Dungeon Portals loaded. Waiting for player to enter the world...")
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        InitializeTabs()
        MDPFrame:Hide()
    end
end)

MDPFrame:RegisterEvent("ADDON_LOADED")
MDPFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

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