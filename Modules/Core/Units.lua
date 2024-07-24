---@type string, Namespace
local _, ns = ...

local trinketIconAliance = "Interface\\Icons\\inv_jewelry_trinketpvp_01"
local trinketIconHorde = "Interface\\Icons\\inv_jewelry_trinketpvp_02"

-- TODO: remove outdated spells
-- list of instant spell buffs
local instantSpellBuffs = {
    -- Pyroblast! - Pyroblast
    [48108] = {11366},
    -- Shooting Stars - Starsurge
    [93400] = {78674},
    -- Predatory Swiftness - Entangling Roots, Cyclone, Healing Touch, Rebirth
    [69369] = {339, 33786, 5185, 20484},
    -- Glyph of Mind Spike - Mind Blast
    [81292] = {8092},
    -- Surge of Darkness - Mind Spike
    [87160] = {87160},
    -- Surge of Light - Flash Heal
    [114255] = {2061},
    -- Shadowy Insight - Mind Blast
    [124430] = {8092}
}

---@class Unit
local Unit = {}
Unit.__index = Unit

---@param unitType UnitType
function Unit:New(unitType)
    ---@class Unit
    local obj = setmetatable({}, Unit)
    obj.unitType = unitType

    ---@type number
    obj.stopMovingTime = GetTime()

    ---A previously canceled spell - used to remove a cross icon if the spell wasn't actually canceled.
    obj.canceledSpell = {
        id = 0,
        castId = "",
        iconIndex = 0,
    }

    ---A previous spell - used to check for supplementary spells that don't need to be displayed.
    obj.previousSpell = {
        id = 0,
        name = ""
    }

    ---A spell that is currently being casted.
    obj.currentlyCastedSpell = nil

    obj.iconQueue = ns.IconQueue:New(unitType)

    ---@type number | nil
    obj.instantSpellBuff = nil

    return obj
end

function Unit:Clear()
    self.currentlyCastedSpell = nil
    self.iconQueue:Clear()
end

---@param from Unit
function Unit:Copy(from)
    self.currentlyCastedSpell = nil
    if from.currentlyCastedSpell then
        self.currentlyCastedSpell = {
            id = from.currentlyCastedSpell.id,
            castId = from.currentlyCastedSpell.castId,
        }
    end
    self.stopMovingTime = from.stopMovingTime
    self.iconQueue:Copy(from.iconQueue)
    -- TODO: copy other fields as well
end

---@param unitType UnitType
---@param spellId number
---@param spellIcon number
---@return number | string
local function replaceToTrinketIfNeeded(unitType, spellId, spellIcon)
    if spellId == 42292 then
        if UnitFactionGroup(unitType) == "Horde" then
            return trinketIconHorde
        else
            return trinketIconAliance
        end
    end

    return spellIcon
end

---@param spellId number
local function checkBlocklist(spellId)
    for _, blockedSpellId in ipairs(ns.innerBlockList) do
        if blockedSpellId == spellId then
            return true
        end
    end

    for _, blockedSpellId in ipairs(ns.settings.activeProfile.blocklist) do
        if blockedSpellId == spellId then
            return true
        end
    end
end

---@param event string
---@param spellId number
---@param unitType UnitType
---@param castId string | nil The nil value appears for _CHANNEL_ events
function Unit:OnSpellEvent(event, spellId, unitType, castId)
    if not ns.settings.activeProfile.unitSettings[self.unitType].enable or checkBlocklist(spellId) then
        return
    end

    local spellName, _, spellIcon, castTime = ns.utils.getSpellInfo(spellId)
    local spellLink = ns.utils.getSpellLink(spellId)

    if not spellIcon or not spellLink or not spellName then
        return
    end

    -- If the current spell has the same name but a different ID as the previous one,
    -- it is probably a supplementary spell that doesn't need to be displayed.
    -- Sometimes, a supplementary spell can appear right before the main spell (e.g. rogue Shadow Dance),
    -- but it doesn't really matter in our case.
    if self.previousSpell.name == spellName and self.previousSpell.id ~= spellId then
        return
    end

    if event == "UNIT_SPELLCAST_START" then
        self:AddSpell(unitType, spellId, spellIcon, spellName)
        self.currentlyCastedSpell = {
            id = spellId,
            castId = castId,
            name = spellName,
        }
        self.stopMovingTime = GetTime()
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
        -- Channeling and empower spells are different to regular cast spells:
        -- * they don't have castId
        -- * their castTime is 0
        -- * the succeeded event doesn't mean the channeling stopped

        self:AddSpell(unitType, spellId, spellIcon, spellName)
        self.currentlyCastedSpell = {
            id = spellId,
            castId = "channel",
            name = spellName,
        }
        self.stopMovingTime = GetTime()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- If it is a previously canceled spell, just remove the cross icon
        if self.canceledSpell.castId == castId then
            self.iconQueue:HideCancel(self.canceledSpell.iconIndex)
            return
        end

        -- If a unit is casting, it is one of the following:
        -- 1. The end of the cast
        -- 2. An instant spell during the casting
        -- 3. A supplementary spell during the channeling, e.g. priest penance
        if self.currentlyCastedSpell then
            -- If it is the same spell that is being casted
            if self.currentlyCastedSpell.id == spellId then
                -- And if it is not a channelling
                if self.currentlyCastedSpell.castId ~= "channel" then
                    -- Finish the cast and start moving icons
                    self.currentlyCastedSpell = nil
                end

            -- If the spell has the same name with the one that is being casted (and a different spell ID),
            -- it is likely a supplementary spell that doesn't need to be displayed.
            elseif self.currentlyCastedSpell.name ~= spellName then
                -- Show instant spells, e.g. for monk mist spells or mage's Ice Floes
                self:AddSpell(unitType, spellId, spellIcon, spellName)
            end

        else
            -- If a unit is NOT casting, it is an instant spell or the one that became instant because of some buff.
            local isSpellFromBuff = self:CheckForInstantSpellBuff(spellId)
            if castTime <= 0 or isSpellFromBuff then
                self:AddSpell(unitType, spellId, spellIcon, spellName)
            end
        end
    elseif event == "UNIT_SPELLCAST_STOP" then
        if not self.currentlyCastedSpell then
            return
        end

        self.currentlyCastedSpell = nil

        self.canceledSpell = {
            id = spellId,
            castId = castId,

            -- TODO: in refactor branch there is a spell ID passed to ShowCancel
            iconIndex = self.iconQueue:ShowCancel()
        }
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP" then
        self.currentlyCastedSpell = nil
    end
end

---@param unitType UnitType
function Unit:OnAuraEvent(unitType)
    if not ns.settings.activeProfile.unitSettings[self.unitType].enable then
        return
    end

    for i = 1, 20 do
        local buffId = select(11, UnitBuff(unitType, i))

        if instantSpellBuffs[buffId] then
            self.instantSpellBuff = buffId
            return
        end
    end
end

---@param time number
---@param interval number
function Unit:Update(time, interval)
    -- fix for stale icons
    if time - self.stopMovingTime > 10 then
        self.currentlyCastedSpell = nil
    end

    self.iconQueue:Update(time, interval, self.currentlyCastedSpell ~= nil)
end

---@private
---@param spellId number
---@return boolean
function Unit:CheckForInstantSpellBuff(spellId)
    if self.instantSpellBuff and instantSpellBuffs[self.instantSpellBuff] then
        for _, buffSpell in ipairs(instantSpellBuffs[self.instantSpellBuff]) do
            if buffSpell == spellId then
                return true
            end
        end
    end

    return false
end

---@private
---@param unitType UnitType
---@param id number
---@param icon number
---@param name string
function Unit:AddSpell(unitType, id, icon, name)
    self.iconQueue:AddSpell(id, replaceToTrinketIfNeeded(unitType, id, icon))
    self.previousSpell.id = id
    self.previousSpell.name = name
end

ns.units = {}
for _, unitType in ipairs(ns.constants.unitTypes) do
    ns.units[unitType] = Unit:New(unitType)
end
