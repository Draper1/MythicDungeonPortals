local _, addon = ...
MythicDungeonPortals = MythicDungeonPortals or {}

function MythicDungeonPortals:OnInitialize()
    if not MythicDungeonPortalsSettings then
        MythicDungeonPortalsSettings = {
            isMinimapEnabled = true
        }
    end
end