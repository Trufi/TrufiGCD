---@type string, Namespace
local _, ns = ...

---@class Constants
local constants = {}
ns.constants = constants

local interfaceVersion = select(4, GetBuildInfo())
local isForever = interfaceVersion >= 16000 and interfaceVersion < 17000
constants.usesRestrictedCastData = interfaceVersion >= 120000 or isForever

-- Keep inactive settings portable between clients. This order also matches V1 saves.
---@type UnitType[]
constants.allUnitTypes = {
    "player", "party1", "party2", "party3", "party4",
    "arena1", "arena2", "arena3", "arena4", "arena5", "target", "focus",
}

---@type LayoutType[]
constants.allLayoutTypes = { "player", "party", "arena", "target", "focus" }

---@type UnitType[]
constants.unitTypes = { "player" }

---@type LayoutType[]
constants.layoutTypes = { "player" }

if not constants.usesRestrictedCastData then
    for _, unitType in ipairs(constants.allUnitTypes) do
        if unitType ~= "player" and unitType ~= "arena4" and unitType ~= "arena5" then
            table.insert(constants.unitTypes, unitType)
        end
    end
    constants.layoutTypes = constants.allLayoutTypes
end
