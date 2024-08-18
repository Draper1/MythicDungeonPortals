local _, addon = ...
local constants = addon.constants
local L = addon.L

function MythicDungeonPortals:CreateSettingsFrame()
    MDPSettingsFrame = CreateFrame("Frame", "MDPSettingsFrame", UIParent, "BasicFrameTemplate")
    MDPSettingsFrame:SetSize(225, 120)
    MDPSettingsFrame:SetPoint("CENTER")
    MDPSettingsFrame:SetMovable(true)
    MDPSettingsFrame:EnableMouse(true)
    MDPSettingsFrame:SetClampedToScreen(true)
    MDPSettingsFrame:RegisterForDrag("LeftButton")
    MDPSettingsFrame:SetScript("OnDragStart", MDPFrame.StartMoving)
    MDPSettingsFrame:SetScript("OnDragStop", MDPFrame.StopMovingOrSizing)
    MDPSettingsFrame.background = MDPSettingsFrame:CreateTexture(nil, "BACKGROUND")
    MDPSettingsFrame.background:SetAllPoints(MDPSettingsFrame)
    MDPSettingsFrame.background:Hide()

    MDPSettingsFrame.title = MDPSettingsFrame:CreateFontString(nil, "OVERLAY")
    MDPSettingsFrame.title:SetFontObject("GameFontHighlight")
    MDPSettingsFrame.title:SetPoint("CENTER", MDPSettingsFrame.TitleBg, "CENTER")
    MDPSettingsFrame.title:SetText(L["SETTINGS_TITLE"])
    MDPSettingsFrame.TitleBg:SetColorTexture(0, 0, 0)

    local bgCheckbox = CreateFrame("CheckButton", "BGCheckbox", MDPSettingsFrame, "UICheckButtonTemplate")
    bgCheckbox:SetPoint("TOPLEFT", 10, -30)
    bgCheckbox.text:SetText(L["SHOW_BACKGROUNDS"])
    bgCheckbox:SetChecked(MythicDungeonPortalsSettings.BackgroundVisible)
    bgCheckbox:SetScript("OnClick", function(self)
        MythicDungeonPortalsSettings.BackgroundVisible = self:GetChecked()
        MythicDungeonPortals:UpdateBackgroundVisibility()
        if constants.debugMode == true then
            print(MythicDungeonPortalsSettings.BackgroundVisible)
        end
    end)

    local minimapCheckbox = CreateFrame("CheckButton", "MinimapCheckbox", MDPSettingsFrame, "UICheckButtonTemplate")
    minimapCheckbox:SetPoint("TOPLEFT", 10, -60)
    minimapCheckbox.text:SetText(L["SHOW_MINIMAP"])
    minimapCheckbox:SetChecked(MythicDungeonPortalsSettings.MinimapIconVisible)
    minimapCheckbox:SetScript("OnClick", function(self)
        local isChecked = self:GetChecked()
        MythicDungeonPortalsSettings.MinimapIconVisible = isChecked
        MythicDungeonPortals:UpdateMinimapIconVisibility(isChecked)
        if constants.debugMode == true then
            print(MythicDungeonPortalsSettings.MinimapIconVisible)
        end
    end)
    MDPSettingsFrame:Hide()
end

function MythicDungeonPortals:GetSettingsFrame()
    return MDPSettingsFrame
end
