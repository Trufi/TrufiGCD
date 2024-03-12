---@type string, Namespace
local _, ns = ...

local unitLabels = {
    "Player", "Party 1", "Party 2", "Party 3", "Party 4",
    "Arena 1", "Arena 2", "Arena 3", "Arena 4", "Arena 5",
    "Target", "Focus"
}

---@class UnitSettings
---@field enable boolean
---@field x number
---@field y number
---@field point Point
---@field text string
---@field direction Direction
---@field iconSize number Icon size
---@field iconsNumber number Unit frame width in icon number
local UnitSettings = {}
UnitSettings.__index = UnitSettings
ns.UnitSettings = UnitSettings

---@param unitIndex number
function UnitSettings:New(unitIndex)
    ---@class UnitSettings
    local obj = setmetatable({}, UnitSettings)
    obj.text = unitLabels[unitIndex]
    obj:SetToDefaults()
    return obj
end

function UnitSettings:SetToDefaults()
    self.x = 0
    self.y = 0
    self.point = "CENTER"
    self.enable = true
    self.direction = "Left"
    self.iconSize = 30
    self.iconsNumber = 3
end

---@param savedVariables table
function UnitSettings:CopyToSavedVariables(savedVariables)
    savedVariables.x = self.x
    savedVariables.y = self.y
    savedVariables.point = self.point
    savedVariables.enable = self.enable
    savedVariables.fade = self.direction
    savedVariables.size = self.iconSize
    savedVariables.width = self.iconsNumber
end

---@param savedVariables table
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
