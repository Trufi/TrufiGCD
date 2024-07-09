---@type string, Namespace
local _, ns = ...

---@class ProfileSettings
local ProfileSettings = {}
ProfileSettings.__index = ProfileSettings
ns.ProfileSettings = ProfileSettings

---@param savedVariables SavedVariablesV0 | SavedVariablesV1
function ProfileSettings:New(savedVariables)
    ---@class ProfileSettings
    local obj = setmetatable({}, ProfileSettings)

    obj.id = ns.utils.uuid()
    obj.name = ns.utils.defaultProfileName()

    obj.enabledIn = {
        enabled = true,
        party = true,
        arena = true,
        battleground = true,
        world = true,
        raid = true,
        combatOnly = false,
    }

    obj.iconsScroll = true
    obj.tooltipEnabled = true
    obj.tooltipPrintSpellId = false
    obj.tooltipStopScroll = true
    obj.iconClickAddsSpellToBlocklist = false

    ---@type number[]
    obj.blocklist = {
        6603, --Attack
        75, --Auto Shot
        7384, --Overpower
    }

    ---@type {[UnitType]: UnitSettings}
    obj.unitSettings = {}
    for _, unitType in ipairs(ns.constants.unitTypes) do
        obj.unitSettings[unitType] = ns.UnitSettings:New(unitType)
    end

    obj:SetFromSavedVariables(savedVariables)

    return obj
end

---@private
---@param savedVariables SavedVariablesV0 | SavedVariablesV1
function ProfileSettings:SetFromSavedVariables(savedVariables)
    if type(savedVariables.id) == "string" then
        self.id = savedVariables.id
    else
        self.id = ns.utils.uuid()
    end

    if type(savedVariables.name) == "string" then
        self.name = savedVariables.name
    else
        self.name = ns.utils.defaultProfileName()
    end

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
        if type(savedVariables.EnableIn["Combat only"]) == "boolean" then
            self.enabledIn.combatOnly = savedVariables.EnableIn["Combat only"]
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
    if type(savedVariables.iconClickAddsSpellToBlocklist) == "boolean" then
        self.iconClickAddsSpellToBlocklist = savedVariables.iconClickAddsSpellToBlocklist
    end

    if type(savedVariables.TrGCDQueueFr) == "table" then
        for unitIndex = 1, 12 do
            if type(savedVariables.TrGCDQueueFr[unitIndex]) == "table" then
                local unitType = ns.constants.unitTypes[unitIndex]
                self.unitSettings[unitType]:SetFromSavedVariables(savedVariables.TrGCDQueueFr[unitIndex])
            end
        end
    end

    self.blocklist = {}
    if type(savedVariables.TrGCDBL) == "table" then
        for i, v in ipairs(savedVariables.TrGCDBL) do
            if type(v) == "number" then
                self.blocklist[i] = v
            end
        end
    end
end

function ProfileSettings:GetSavedVariables()
    ---@type ProfileVariablesV1
    local savedVariables = {}

    savedVariables.id = self.id
    savedVariables.name = self.name
    savedVariables.EnableIn = {}
    savedVariables.EnableIn.Enable = self.enabledIn.enabled
    savedVariables.EnableIn.PvE = self.enabledIn.party
    savedVariables.EnableIn.Arena = self.enabledIn.arena
    savedVariables.EnableIn.Bg = self.enabledIn.battleground
    savedVariables.EnableIn.World = self.enabledIn.world
    savedVariables.EnableIn.Raid = self.enabledIn.raid
    savedVariables.EnableIn["Combat only"] = self.enabledIn.combatOnly
    savedVariables.ModScroll = self.iconsScroll
    savedVariables.TooltipEnable = self.tooltipEnabled
    savedVariables.TooltipSpellID = self.tooltipPrintSpellId
    savedVariables.TooltipStopMove = self.tooltipStopScroll
    savedVariables.iconClickAddsSpellToBlocklist = self.iconClickAddsSpellToBlocklist

    savedVariables.TrGCDQueueFr = {}
    for unitIndex = 1, 12 do
        local unitType = ns.constants.unitTypes[unitIndex]
        savedVariables.TrGCDQueueFr[unitIndex] = self.unitSettings[unitType]:GetSavedVariables()
    end

    savedVariables.TrGCDBL = {}
    for _, v in ipairs(self.blocklist) do
        table.insert(savedVariables.TrGCDBL, v)
    end

    return savedVariables
end
