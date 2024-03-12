---@type string, Namespace
local _, ns = ...

---@class Settings
local Settings = {}
Settings.__index = Settings

function Settings:New()
    ---@class Settings
    local obj = setmetatable({}, Settings)

    ---@type {[number]: UnitSettings}
    self.unitSettings = {}
    for unitIndex = 1, 12 do
        self.unitSettings[unitIndex] = ns.UnitSettings:New(unitIndex)
    end

    obj:SetToDefaults()
    obj:SetBlocklistToDefaults()
    return obj
end

function Settings:SetToDefaults()
    self.enabledIn = {
        enabled = true,
        party = true,
        arena = true,
        battleground = true,
        world = true,
        raid = true,
        combatOnly = false,
    }

    self.iconsScroll = true
    self.tooltipEnabled = true
    self.tooltipPrintSpellId = false
    self.tooltipStopScroll = true

    for _, unitSettings in ipairs(self.unitSettings) do
        unitSettings:SetToDefaults()
    end
end

function Settings:SetBlocklistToDefaults()
    ---@type number[]
    self.blocklist = {
        6603, --Attack
        75, --Auto Shot
        7384, --Overpower
    }
end

function Settings:LoadFromCharacterSavedVariables()
    TrufiGCDChSave = TrufiGCDChSave or {}
    self:SetFromSavedVariables(TrufiGCDChSave)
end
function Settings:LoadBlocklistFromCharacterSavedVariables()
    TrufiGCDChSave = TrufiGCDChSave or {}
    self:SetBlocklistFromSavedVariables(TrufiGCDChSave)
end

function Settings:LoadFromGlobalSavedVariables()
    TrufiGCDGlSave = TrufiGCDGlSave or {}
    self:SetFromSavedVariables(TrufiGCDGlSave)
end
function Settings:LoadBlocklistFromGlobalSavedVariables()
    TrufiGCDGlSave = TrufiGCDGlSave or {}
    self:SetBlocklistFromSavedVariables(TrufiGCDGlSave)
end

function Settings:SaveToCharacterSavedVariables()
    TrufiGCDChSave = TrufiGCDChSave or {}
    self:CopyToSavedVariables(TrufiGCDChSave)
end
function Settings:SaveBlocklistToCharacterSavedVariables()
    TrufiGCDChSave = TrufiGCDChSave or {}
    self:CopyBlocklistToSavedVariables(TrufiGCDChSave)
end

function Settings:SaveToGlobalSavedVariables()
    TrufiGCDGlSave = TrufiGCDGlSave or {}
    self:CopyToSavedVariables(TrufiGCDGlSave)
end
function Settings:SaveBlocklistToGlobalSavedVariables()
    TrufiGCDGlSave = TrufiGCDGlSave or {}
    self:CopyBlocklistToSavedVariables(TrufiGCDGlSave)
end


---@private
---@param savedVariables table
function Settings:SetFromSavedVariables(savedVariables)
    self:SetToDefaults()

    if type(savedVariables.EnableIn) == "table" then
        if type(savedVariables.EnableIn.Enable) == "boolean" then
            self.enabledIn.enabled = savedVariables.EnableIn.Enable
        end
        if type(savedVariables.EnableIn.PvE) == "boolean" then
            self.enabledIn.party = savedVariables.EnableIn.PvE
        end
        if type(savedVariables.EnableIn.Arena) == "boolean" then
            self.enabledIn.arena = savedVariables.EnableIn.Arena
        end
        if type(savedVariables.EnableIn.Bg) == "boolean" then
            self.enabledIn.battleground = savedVariables.EnableIn.Bg
        end
        if type(savedVariables.EnableIn.World) == "boolean" then
            self.enabledIn.world = savedVariables.EnableIn.World
        end
        if type(savedVariables.EnableIn.Raid) == "boolean" then
            self.enabledIn.raid = savedVariables.EnableIn.Raid
        end
        if type(savedVariables.EnableIn.combatOnly) == "boolean" then
            self.enabledIn.combatOnly = savedVariables.EnableIn.combatOnly
        end
    end

    if type(savedVariables.ModScroll) == "boolean" then
        self.iconsScroll = savedVariables.ModScroll
    end
    if type(savedVariables.TooltipEnable) == "boolean" then
        self.tooltipEnabled = savedVariables.TooltipEnable
    end
    if type(savedVariables.TooltipSpellID) == "boolean" then
        self.tooltipPrintSpellId = savedVariables.TooltipSpellID
    end
    if type(savedVariables.TooltipStopMove) == "boolean" then
        self.tooltipStopScroll = savedVariables.TooltipStopMove
    end

    if type(savedVariables.TrGCDQueueFr) == "table" then
        for unitIndex = 1, 12 do
            if type(savedVariables.TrGCDQueueFr[unitIndex]) == "table" then
                self.unitSettings[unitIndex]:SetFromSavedVariables(savedVariables.TrGCDQueueFr[unitIndex])
            end
        end
    end
end

---@private
---@param savedVariables table
function Settings:SetBlocklistFromSavedVariables(savedVariables)
    self.blocklist = {}
    if type(savedVariables.TrGCDBL) == "table" then
        for i, v in ipairs(savedVariables.TrGCDBL) do
            if type(v) == "number" then
                self.blocklist[i] = v
            end
        end
    end
end

---@private
---@param savedVariables table
function Settings:CopyToSavedVariables(savedVariables)
    savedVariables.EnableIn = {}
    savedVariables.EnableIn.Enable = self.enabledIn.enabled
    savedVariables.EnableIn.PvE = self.enabledIn.party
    savedVariables.EnableIn.Arena = self.enabledIn.arena
    savedVariables.EnableIn.Bg = self.enabledIn.battleground
    savedVariables.EnableIn.World = self.enabledIn.world
    savedVariables.EnableIn.Raid = self.enabledIn.raid
    savedVariables.EnableIn.combatOnly = self.enabledIn.combatOnly
    savedVariables.ModScroll = self.iconsScroll
    savedVariables.TooltipEnable = self.tooltipEnabled
    savedVariables.TooltipSpellID = self.tooltipPrintSpellId
    savedVariables.TooltipStopMove = self.tooltipStopScroll

    savedVariables.TrGCDQueueFr = {}
    for unitIndex = 1, 12 do
        savedVariables.TrGCDQueueFr[unitIndex] = {}
        self.unitSettings[unitIndex]:CopyToSavedVariables(savedVariables.TrGCDQueueFr[unitIndex])
    end
end

---@private
---@param savedVariables table
function Settings:CopyBlocklistToSavedVariables(savedVariables)
    savedVariables.TrGCDBL = {}
    for i, v in ipairs(self.blocklist) do
        savedVariables.TrGCDBL[i] = v
    end
end

ns.settings = Settings:New()
