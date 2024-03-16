---@type string, Namespace
local _, ns = ...

---@class Constants
local constants = {}
ns.constants = constants

---@type UnitType[]
constants.unitTypes = {
    "player", "party1", "party2", "party3", "party4",
    "arena1", "arena2", "arena3", "arena4", "arena5",
    "target", "focus"
}
