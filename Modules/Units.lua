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

---@param unitIndex number
function Unit:New(unitIndex)
    ---@class Unit
    local obj = setmetatable({}, Unit)
    obj.unitIndex = unitIndex
    obj.isCasting = false

    ---@type number
    obj.castStoppedTime = GetTime()

    obj.canceledSpell = {
        id = 0,

        ---@type number
        time = GetTime(),

        iconIndex = 0,
    }

    obj.iconQueue = ns.IconQueue:New(unitIndex)

    ---@type number | nil
    obj.instantSpellBuff = nil

    return obj
end

function Unit:Clear()
    self.isCasting = false
    self.iconQueue:Clear()
end

---@param from Unit
function Unit:Copy(from)
    self.isCasting = from.isCasting
    self.castStoppedTime = from.castStoppedTime
    self.iconQueue:Copy(from.iconQueue)
    -- TODO: copy other fields as well
end

---@param unitId number
---@param spellId number
---@param spellIcon string
---@return string
local function replaceToTrinketIfNeeded(unitId, spellId, spellIcon)
    if spellId == 42292 then
        if UnitFactionGroup(unitId) == "Horde" then
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

    for _, blockedSpellId in ipairs(ns.settings.blocklist) do
        if blockedSpellId == spellId then
            return true
        end
    end
end

---@param unitId number
---@return boolean
local function unitIsChanneling(unitId)
    local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

    if not isClassic then
      return UnitChannelInfo(unitId) ~= nil
    elseif UnitIsUnit(unitId, "player") then
      return ChannelInfo() ~= nil
    else
      return false
    end
end

function Unit:OnEvent(event, spellId, unitId)
    if not ns.settings.unitSettings[self.unitIndex].enable or checkBlocklist(spellId) then
        return
    end

    ---@type unknown, unknown, string | nil, number
    local _, _, spellIcon, castTime = GetSpellInfo(spellId)
    local spellLink = GetSpellLink(spellId)

    if not spellIcon or not spellLink then
        return
    end

    if event == "UNIT_SPELLCAST_START" then
        self.iconQueue:AddSpell(spellId, spellIcon)
        self.isCasting = true
        self.castStoppedTime = GetTime()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        if self.isCasting then
            if unitIsChanneling(unitId) then
                -- show instant spells while channeling, e.g. for monk mist spells
                self.iconQueue:AddSpell(spellId, replaceToTrinketIfNeeded(unitId, spellId, spellIcon))
            else
                self.isCasting = false
            end
        else
            local isSpellFromBuff = self:CheckForInstantSpellBuff(spellId)

            self.castStoppedTime = GetTime()
            if unitIsChanneling(unitId) then
                self.isCasting = true
            end

            if GetTime() - self.castStoppedTime < 1 and self.canceledSpell.id == spellId and isSpellFromBuff == false then
                self.iconQueue:HideCancel(self.canceledSpell.iconIndex)
            end

            if castTime <= 0 or isSpellFromBuff then
                self.iconQueue:AddSpell(spellId, replaceToTrinketIfNeeded(unitId, spellId, spellIcon))
            end
        end
    elseif event == "UNIT_SPELLCAST_STOP" then
        if not self.isCasting then
            return
        end

        self.isCasting = false

        self.canceledSpell = {
            id = spellId,
            time = GetTime(),

            -- TODO: in refactor branch there is a spell ID passed to ShowCancel
            iconIndex = self.iconQueue:ShowCancel()
        }
    elseif event == "UNIT_SPELLCAST_CHANNEL_STOP" then
        self.isCasting = false
    elseif event == "UNIT_AURA" then
        for i = 1, 20 do
            local buffId = select(11, UnitBuff(unitId, i))

            if instantSpellBuffs[buffId] then
                self.instantSpellBuff = buffId
                return
            end
        end
    end
end

---@param time number
---@param interval number
function Unit:Update(time, interval)
    -- fix for stale icons
    if time - self.castStoppedTime > 10 then
        self.isCasting = false
    end

    self.iconQueue:Update(interval, self.isCasting)
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

ns.units = {}
for unitIndex = 1, 12 do
    ns.units[unitIndex] = Unit:New(unitIndex)
end
