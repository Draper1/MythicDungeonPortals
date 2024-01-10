-- MythicDungeonPortals.lua
local addonName, ns = ...

-- Global variables to keep track of tabs
local currentTab = nil
local totalTabs = 0

local myIdToExpansion = {
    [0] = "Cataclysm",
    [1] = "Mists of Pandaria",
    [2] = "Warlords of Draenor",
    [3] = "Legion",
    [4] = "Battle For Azeroth",
    [5] = "Shadowlands",
    [6] = "Dragonflight",
    [7] = "War Within"
}

local orderedExpansions = {
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
    [456] = 424142, -- THOT
    [463] = 424197, -- DOTI Fall
    [464] = 424197, -- DOTI Rise
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
}

local iconPath = "Interface\\Icons\\Achievement_ChallengeMode_Gold"

local frame = CreateFrame("Frame", "MDPPortalsFrame", UIParent, "BasicFrameTemplate")

frame:SetSize(350, 500)
frame:SetPoint("CENTER")
frame:SetMovable(true)
frame:EnableMouse(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.background = frame:CreateTexture(nil, "BACKGROUND")
frame.background:SetAllPoints(frame)
frame.background:Hide() -- Initially hide the background

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER")
frame.title:SetText("Mythic Dungeon Portals")
frame.TitleBg:SetColorTexture(0, 0, 0)  -- RGB for black

local contentFrames = {}

local function HasLearnedSpell(spellID)
    return IsSpellKnown(spellID)
end

local function AddSpellIcons(tabFrame, mapIDs)
    local buttonSize = 40 -- Size of each spell icon button
    local padding = 5    -- Padding between buttons
    local numColumns = 1 -- Number of buttons per row
    local topPadding = 35 -- the first buttons padding from top
    local leftPadding = 20 -- pad the buttons by a set 20px
    local textOffset = 5 -- Offset for the text from the button

    for index, mapID in ipairs(mapIDs) do
        local spellID = mapIDtoSpellID[mapID]
        local dungeonName = mapIDtoDungeonName[mapID]
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
            local spellTexture = GetSpellTexture(spellID)
            icon:SetTexture(spellTexture)

            -- Check if the spell is learned
            if not HasLearnedSpell(spellID) then
                icon:SetDesaturated(true) -- Grey out the icon
                button:Disable() -- Make the button unclickable
            else
                button:RegisterForClicks("LeftButtonUp", "LeftButtonDown")
                button:SetAttribute("type", "spell")
                button:SetAttribute("unit", "player")
                button:SetAttribute("spell", spellID)
            end

            -- Tooltip
            button:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:SetSpellByID(spellID)
                GameTooltip:Show()
            end)
            button:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
            end)

            -- Create and set dungeon name text
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

-- Function to Update Frame Background
local function UpdateFrameBackground(selectedTabName)
    local texturePath = mapExpansionToBackground[selectedTabName]
    if texturePath then
        frame.background:SetTexture(texturePath)
        frame.background:Show()
    else
        frame.background:Hide()
    end
end

-- Function to create tabs
local function CreateTab(expansionName, mapIDs)
    local topPadding = 30
    totalTabs = totalTabs + 1
    local tabButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")

    tabButton:SetSize(120, 30) -- Width, Height of the tab button
    tabButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -(topPadding + (totalTabs - 1) * 30)) -- Adjust this to position your tabs

    tabButton:SetText(expansionName) -- Set the text of the tab to the expansion name
    tabButton:SetNormalFontObject("GameFontNormal")
    tabButton:SetHighlightFontObject("GameFontHighlight")

    if expansionName == "War Within" then 
        tabButton:Disable()
    end

    local tabFrame = CreateFrame("Frame", nil, frame)
    tabFrame:SetAllPoints()
    tabFrame:Hide()

    contentFrames[expansionName] = tabFrame
    AddSpellIcons(tabFrame, mapIDs)

    -- Event handler for tab click
    tabButton:SetScript("OnClick", function()
        UpdateMDPTabs(expansionName)
        UpdateFrameBackground(expansionName)
    end)

    -- Initially show content of the first tab
    if totalTabs == 1 then
        UpdateMDPTabs(expansionName)
        UpdateFrameBackground(expansionName)
    end

    print("Tab created for " .. expansionName) 
end

local function InitializeTabs()
    for _, expansion in ipairs(orderedExpansions) do
        local mapIDs = mapExpansionToMapID[expansion]
        if mapIDs then
            CreateTab(expansion, mapIDs)
        end
    end
end

local function ToggleFrame()
    if frame:IsShown() then
        frame:Hide()
    else
        frame:Show()
    end
end

local function SlashCmdHandler(msg, editbox)
    ToggleFrame()
end

local function UpdateMinimapButtonPosition()
    local angle = math.rad(MDPMinimapButton.db.angle)
    local x, y = math.cos(angle), math.sin(angle)
    MDPMinimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (x * 80), (y * 80) - 52)
end

local function MinimapButtonOnDragStart(self)
    self:StartMoving()
    self.isMoving = true
end

local function MinimapButtonOnDragStop(self)
    self:StopMovingOrSizing()
    self.isMoving = false
    -- Save the new angle
    local cursorX, cursorY = GetCursorPosition()
    local minimapX, minimapY = Minimap:GetCenter()
    minimapX, minimapY = minimapX * Minimap:GetEffectiveScale(), minimapY * Minimap:GetEffectiveScale()
    local angle = math.deg(math.atan2(cursorY - minimapY, cursorX - minimapX)) % 360
    MDPMinimapButton.db.angle = angle
    UpdateMinimapButtonPosition()
end

-- Create the Minimap Button
local minimapButton = CreateFrame("Button", "MDPMinimapButton", Minimap)
minimapButton:SetSize(24, 24)
minimapButton:SetFrameStrata("MEDIUM")
minimapButton:SetFrameLevel(8)

-- Set the icon texture
local icon = minimapButton:CreateTexture(nil, "ARTWORK")
icon:SetAllPoints(minimapButton)
icon:SetTexture(iconPath) -- Your icon path
icon:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")

minimapButton:SetNormalTexture(icon)

-- Add a border texture
local border = minimapButton:CreateTexture(nil, "OVERLAY")
border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
border:SetPoint("TOPLEFT", minimapButton, "TOPLEFT", -5, 5)
border:SetPoint("BOTTOMRIGHT", minimapButton, "BOTTOMRIGHT", 5, -5)

-- Set the highlight texture
minimapButton:SetHighlightTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")

-- Position the button around the minimap
local angle = 45
local x, y = math.cos(angle), math.sin(angle)
minimapButton:SetPoint("TOPLEFT", Minimap, "TOPLEFT", 52 - (x * 80), (y * 80) - 52)

-- Set up the click handler
minimapButton:SetScript("OnClick", function()
    ToggleFrame()
end)

-- Optional: Add a tooltip
minimapButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("MythicDungeonPortals", 1, 1, 1)
    GameTooltip:AddLine("Click to Open/Close.", nil, nil, nil, true)
    GameTooltip:Show()
end)
minimapButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide()
end)

frame:SetScript("OnEvent", function(self, event, addonNameLoaded)
    if event == "ADDON_LOADED" and addonNameLoaded == addonName then
        print("Mythic Dungeon Portals loaded. Waiting for player to enter the world...")
    elseif event == "PLAYER_ENTERING_WORLD" then
        print("Initializing Mythic Dungeon Portals")
        InitializeTabs()
        frame:Hide()
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")  -- Unregister the event as it's no longer needed after initialization
    end
end)

-- Register the necessary events
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

-- Register slash command
SLASH_MDP1 = "/mdp"
SlashCmdList["MDP"] = SlashCmdHandler