---@type string, Namespace
local _, ns = ...

---@class LayoutSettings
---@field enable boolean
---@field direction Direction
---@field iconSize number Icon size
---@field iconsNumber number Unit frame width in icons number
local LayoutSettings = {}
LayoutSettings.__index = LayoutSettings
ns.LayoutSettings = LayoutSettings

function LayoutSettings:New()
    ---@class LayoutSettings
    local obj = setmetatable({}, LayoutSettings)
    obj.enable = false
    obj.direction = "Left"
    obj.iconSize = 30
    obj.iconsNumber = 3

    obj.labels = {
        enable = false,

        ---@type "TOP" | "BOTTOM" | "CENTER"
        position = "BOTTOM",

        ---@type Color
        damageColor = {r = 1.0, g = 1.0, b = 1.0, a = 1.0},

        ---@type Color
        healColor = {r = 0.3, g = 1.0, b = 0.3, a = 1.0},

        ---@type Color
        critColor = {r = 1.0, g = 1.0, b = 0.0, a = 1.0}
    }

    return obj
end

function LayoutSettings:GetSavedVariables()
    ---@type LayoutVariablesV2
    local layoutSaves = {}
    layoutSaves.enable = self.enable
    layoutSaves.direction = self.direction
    layoutSaves.iconSize = self.iconSize
    layoutSaves.iconsNumber = self.iconsNumber

    layoutSaves.labels = {}
    layoutSaves.labels.enable = self.labels.enable
    layoutSaves.labels.position = self.labels.position
    layoutSaves.labels.critColor = {
        r = self.labels.critColor.r,
        g = self.labels.critColor.g,
        b = self.labels.critColor.b,
        a = self.labels.critColor.a,
    }
    layoutSaves.labels.damageColor = {
        r = self.labels.damageColor.r,
        g = self.labels.damageColor.g,
        b = self.labels.damageColor.b,
        a = self.labels.damageColor.a,
    }
    layoutSaves.labels.healColor = {
        r = self.labels.healColor.r,
        g = self.labels.healColor.g,
        b = self.labels.healColor.b,
        a = self.labels.healColor.a,
    }

    return layoutSaves
end

---@param color SavedColor
---@return Color
local function parseColor(color)
    if
        type(color) == "table" and
        type(color.r) == "number" and
        type(color.g) == "number" and
        type(color.b) == "number" and
        type(color.a) == "number"
    then
        return {r = color.r, g = color.g, b = color.b, a = color.a}
    end

    return {r = 1, g = 1, b = 1, a = 1}
end

---@param savedVariables UnitVariablesV1 | LayoutVariablesV2
function LayoutSettings:SetFromSavedVariables(savedVariables)
    if type(savedVariables.enable) == "boolean" then
        self.enable = savedVariables.enable
    end
    if type(savedVariables.direction) == "string" then
        self.direction = savedVariables.direction
    end
    if type(savedVariables.iconSize) == "number" then
        self.iconSize = savedVariables.iconSize
    end
    if type(savedVariables.iconsNumber) == "number" then
        self.iconsNumber = savedVariables.iconsNumber
    end

    -- Suppoort for V1 variables
    if type(savedVariables.fade) == "string" then
        self.direction = savedVariables.fade
    end
    if type(savedVariables.size) == "number" then
        self.iconSize = savedVariables.size
    end
    if type(savedVariables.width) == "number" then
        self.iconsNumber = savedVariables.width
    end

    if type(savedVariables.labels) == "table" then
        if type(savedVariables.labels.enable) == "boolean" then
            self.labels.enable = savedVariables.labels.enable
        end
        if type(savedVariables.labels.position) == "string" then
            self.labels.position = savedVariables.labels.position
        end

        self.labels.critColor = parseColor(savedVariables.labels.critColor)
        self.labels.damageColor = parseColor(savedVariables.labels.damageColor)
        self.labels.healColor = parseColor(savedVariables.labels.healColor)
    end
end
