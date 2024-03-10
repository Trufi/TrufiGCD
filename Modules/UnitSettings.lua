local _, ns = ...

local unitLabels = {
    "Player", "Party 1", "Party 2", "Party 3", "Party 4",
    "Arena 1", "Arena 2", "Arena 3", "Arena 4", "Arena 5",
    "Target", "Focus"
}

---@alias Direction "Left" | "Right" | "Up" | "Down"
---@alias Point "TOPLEFT"| "TOPRIGHT"| "BOTTOMLEFT"| "BOTTOMRIGHT"| "TOP"| "BOTTOM"| "LEFT"| "RIGHT"| "CENTER"

---@class UnitSettings
---@field enable boolean
---@field x number
---@field y number
---@field point Point
---@field text string
---@field fade Direction
---@field size number Icon size
---@field width number Unit frame width in icon number
local UnitSettings = {}

UnitSettings.__index = UnitSettings
ns.UnitSettings = UnitSettings

---@param unitIndex number
function UnitSettings:New(unitIndex)
    ---@class UnitSettings
    local obj = setmetatable({}, UnitSettings)
    obj.x = 0
    obj.y = 0
    obj.point = "CENTER"
    obj.enable = true
    obj.fade = "Left"
    obj.size = 30
    obj.width = 3
    obj.text = unitLabels[unitIndex]
    return obj
end

---@param savedVariables table
function UnitSettings:CopyToSavedVariables(savedVariables)
    savedVariables["x"] = self.x
    savedVariables["y"] = self.y
    savedVariables["point"] = self.point
    savedVariables["enable"] = self.enable
    savedVariables["text"] = self.text
    savedVariables["fade"] = self.fade
    savedVariables["size"] = self.size
    savedVariables["width"] = self.width
end

---@param savedVariables table
function UnitSettings:SetFromSavedVariables(savedVariables)
    self.x = savedVariables["x"]
    self.y = savedVariables["y"]
    self.point = savedVariables["point"]
    self.enable = savedVariables["enable"]
    self.text = savedVariables["text"]
    self.fade = savedVariables["fade"]
    self.size = savedVariables["size"]
    self.width = savedVariables["width"]
end
