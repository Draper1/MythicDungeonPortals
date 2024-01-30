local _, addon = ...
local constants = addon.constants

LibStub("AceAddon-3.0"):NewAddon(addon, "MythicDungeonPortals", "AceConsole-3.0")

local function ToggleMDPFrame()
    if MDPFrame:IsShown() then
        MDPFrame:Hide()
    else
        MDPFrame:Show()
    end
end

local function ToggleSettingsFrame()
    local settingsFrame = MythicDungeonPortals:GetSettingsFrame()
    if settingsFrame and settingsFrame:IsShown() then
        settingsFrame:Hide()
    else
        settingsFrame:Show()
    end
end

local settingsFrame = MythicDungeonPortals:GetSettingsFrame()

local mythicDungeonPortalsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Mythic Dungeon Portals", {
	type = "data source",
	text = "MythicDungeonPortals",
	icon = constants.iconPath,
	OnClick = function(_, button)
		if button == 'LeftButton' then 
			ToggleMDPFrame()
		elseif button == 'RightButton' then
			ToggleSettingsFrame()
		end  
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Mythic Dungeon Portals")
		tooltip:AddLine("Left click to open Portals")
		tooltip:AddLine("Right click to open settings")
	end,
})

addon.icon = LibStub("LibDBIcon-1.0")

function MythicDungeonPortals:UpdateMinimapIconVisibility(isVisible)
    if isVisible then
        addon.icon:Show("MythicDungeonPortals")
    else
        addon.icon:Hide("MythicDungeonPortals")
    end
end

function MythicDungeonPortals:InitializeMinimap()
	self.db = LibStub("AceDB-3.0"):New("MythicDungeonPortalsMinimap", {
		profile = {
			minimap = {
				hide = not MythicDungeonPortalsSettings.isMinimapEnabled,
			},
		},
	})
	addon.icon:Register("MythicDungeonPortals", mythicDungeonPortalsLDB, self.db.profile.minimap)
end