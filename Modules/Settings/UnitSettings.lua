---@type string, Namespace
local _, ns = ...

---@type {[UnitType]: string}
local unitLabels = {
    player = "Player",
    party1 = "Party 1",
    party2 = "Party 2",
    party3 = "Party 3",
    party4 = "Party 4",
    arena1 = "Arena 1",
    arena2 = "Arena 2",
    arena3 = "Arena 3",
    arena4 = "Arena 4",
    arena5 = "Arena 5",
    target = "Target",
    focus = "Focus",
}

---@class UnitSettings
---@field enable boolean
---@field x number
---@field y number
---@field point Point
---@field text string
---@field direction Direction
---@field iconSize number Icon size
---@field iconsNumber number Unit frame width in icons number
local UnitSettings = {}
UnitSettings.__index = UnitSettings
ns.UnitSettings = UnitSettings

---@param unitType UnitType
function UnitSettings:New(unitType)
    ---@class UnitSettings
    local obj = setmetatable({}, UnitSettings)
    obj.text = unitLabels[unitType]
    obj.x = 0
    obj.y = 0
    obj.point = "CENTER"
    obj.enable = true
    obj.direction = "Left"
    obj.iconSize = 30
    obj.iconsNumber = 3
    return obj
end

function UnitSettings:GetSavedVariables()
    ---@type SavedVariablesUnitSettings
    local savedVariables = {}
    savedVariables.x = self.x
    savedVariables.y = self.y
    savedVariables.point = self.point
    savedVariables.enable = self.enable
    savedVariables.fade = self.direction
    savedVariables.size = self.iconSize
    savedVariables.width = self.iconsNumber
    return savedVariables
end

---@param savedVariables SavedVariablesUnitSettings
function UnitSettings:SetFromSavedVariables(savedVariables)
    if type(savedVariables.x) == "number" then
        self.x = savedVariables.x
    end
    if type(savedVariables.y) == "number" then
        self.y = savedVariables.y
    end
    if type(savedVariables.point) == "string" then
        self.point = savedVariables.point
    end
    if type(savedVariables.enable) == "boolean" then
        self.enable = savedVariables.enable
    end
    if type(savedVariables.fade) == "string" then
        self.direction = savedVariables.fade
    end
    if type(savedVariables.size) == "number" then
        self.iconSize = savedVariables.size
    end
    if type(savedVariables.width) == "number" then
        self.iconsNumber = savedVariables.width
    end
end
