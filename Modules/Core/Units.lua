---@type string, Namespace
local _, ns = ...

local trinketIconAliance = "Interface\\Icons\\inv_jewelry_trinketpvp_01"
local trinketIconHorde = "Interface\\Icons\\inv_jewelry_trinketpvp_02"

---@class Unit
local Unit = {}
Unit.__index = Unit

---@class UnitParams
---@field unitType UnitType
---@field layoutType LayoutType

---@param params UnitParams
function Unit:New(params)
    ---@class Unit
    local obj = setmetatable({}, Unit)
    obj.unitType = params.unitType
    obj.layoutType = params.layoutType

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
    ---@type {id: number, castId: string, name: string} | nil
    obj.currentlyCastedSpell = nil

    obj.iconQueue = ns.IconQueue:New({
        unitType = obj.unitType,
        layoutType = obj.layoutType,
    })

    ---An array of last succeeded spells.
    ---Used to map castId (which is presented only in regular events)
    ---to destination GUID (which is presented in combat log event only).
    ---@type {castId: string, name: string}[]
    obj.lastSucceededSpells = {}

    ---Consists of found matches between castId and destination GUID.
    obj.destGuidToCastIdMap = ns.Cache:New(20)

    return obj
end

function Unit:Clear()
    self.currentlyCastedSpell = nil
    self.lastSucceededSpells = {}
    self.destGuidToCastIdMap:Clear()
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
    self.lastSucceededSpells = {}
    for _, spell in ipairs(from.lastSucceededSpells) do
        table.insert(self.lastSucceededSpells, {
            castId = spell.castId,
            name = spell.name,
        })
    end
    self.destGuidToCastIdMap:Copy(from.destGuidToCastIdMap)
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
    if ns.innerBlockList[spellId] then
        return true
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
    if not ns.settings.activeProfile.layoutSettings[self.layoutType].enable or checkBlocklist(spellId) then
        return
    end

    local spellName, _, spellIcon, castTime = ns.utils.getSpellInfo(spellId)
    local spellLink = ns.utils.getSpellLink(spellId)

    if not spellIcon or not spellLink or not spellName or ns.innerIconsBlocklist[spellIcon] then
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
        -- Ignore start of spells without castId - they are likely supplemental
        -- e.g. casts from druid forms create two start events (one without castId)
        if castId then
            self:AddSpell(unitType, spellId, spellIcon, spellName, castId)
            self.currentlyCastedSpell = {
                id = spellId,
                castId = castId,
                name = spellName,
            }
            self.stopMovingTime = GetTime()
        end
    elseif event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START" then
        -- Channeling and empower spells are different to regular cast spells:
        -- * they don't have castId
        -- * their castTime is 0
        -- * the succeeded event doesn't mean the channeling stopped

        self:AddSpell(unitType, spellId, spellIcon, spellName, "channel")
        self.currentlyCastedSpell = {
            id = spellId,
            castId = "channel",
            name = spellName,
        }
        self.stopMovingTime = GetTime()
    elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
        -- Update the array of last spells for castId <-> destination GUID mapping
        table.insert(self.lastSucceededSpells, {
            castId = castId,
            name = spellName,
        })
        if #self.lastSucceededSpells >= 5 then
            table.remove(self.lastSucceededSpells, 1)
        end

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
                self:AddSpell(unitType, spellId, spellIcon, spellName, castId --[[@as string]])
            end

        else
            -- If a unit is NOT casting, it is an instant spell or the one that became instant because of some buff.
            if castTime <= 0 then
                self:AddSpell(unitType, spellId, spellIcon, spellName, castId --[[@as string]])
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
---@param unitType UnitType
---@param id number
---@param icon number
---@param name string
---@param castId string
function Unit:AddSpell(unitType, id, icon, name, castId)
    self.iconQueue:AddSpell(id, name, castId, replaceToTrinketIfNeeded(unitType, id, icon))
    self.previousSpell.id = id
    self.previousSpell.name = name
end

---@param spellName string
---@param damage number
---@param isHeal boolean
---@param isCritical boolean
---@param destGuid string
function Unit:AddDamage(spellName, damage, isHeal, isCritical, destGuid)
    local currentlyCastedCastId = self.currentlyCastedSpell and self.currentlyCastedSpell.castId
    local possibleDamageSpellCastId = self.destGuidToCastIdMap:Get(destGuid .. spellName) --[[@as string | nil]]
    self.iconQueue:AddDamage(spellName, damage, isHeal, isCritical, currentlyCastedCastId, possibleDamageSpellCastId)
end

---@param spellName string
---@param destGuid string
function Unit:AttachDestGuidToSpell(spellName, destGuid)
    --If spell doesn't have target destination GUID is an empty string
    if #destGuid > 0 then
        for index, spell in ipairs(self.lastSucceededSpells) do
            if spell.name == spellName then
                self.destGuidToCastIdMap:Add(destGuid .. spell.name, spell.castId)
                table.remove(self.lastSucceededSpells, index)
                break
            end
        end
    end
end

---@type {[UnitType]: LayoutType}
local unitTypeToLayoutType = {
    player = "player",
    party1 = "party",
    party2 = "party",
    party3 = "party",
    party4 = "party",
    arena1 = "arena",
    arena2 = "arena",
    arena3 = "arena",
    target = "target",
    focus = "focus",
}

ns.units = {}
for unitType, layoutType in pairs(unitTypeToLayoutType) do
    ns.units[unitType] = Unit:New({
        unitType = unitType,
        layoutType = layoutType,
    })
end
