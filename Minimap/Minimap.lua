local _, addon = ...
local constants = addon.constants

LibStub("AceAddon-3.0"):NewAddon(addon, "MythicDungeonPortals", "AceConsole-3.0")

local function ToggleFrame()
    if MDPFrame:IsShown() then
        MDPFrame:Hide()
    else
        MDPFrame:Show()
    end
end

local mythicDungeonPortalsLDB = LibStub("LibDataBroker-1.1"):NewDataObject("Mythic Dungeon Portals", {
	type = "data source",
	text = "MythicDungeonPortals",
	icon = constants.iconPath,
	OnClick = function(_, button)
		if button == 'LeftButton' then 
			ToggleFrame()
		elseif button == 'RightButton' then
			-- do nothing right now
		end  
	end,
	OnTooltipShow = function(tooltip)
		tooltip:AddLine("Mythic Dungeon Portals")
		tooltip:AddLine('Left click to open Portals')
	end,
})

addon.icon = LibStub("LibDBIcon-1.0")

function addon:OnInitialize()
	if not MythicDungeonPortalsSettings then
		MythicDungeonPortalsSettings = {}
	end
	self.db = LibStub("AceDB-3.0"):New("MythicDungeonPortalsMinimap", {
		profile = {
            		minimap = {
                		hide = not MythicDungeonPortalsSettings.isMinimapEnabled,
           		},
        	},
    	})
    	addon.icon:Register("MythicDungeonPortals", mythicDungeonPortalsLDB, self.db.profile.minimap)
end
