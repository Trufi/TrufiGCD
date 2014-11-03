TrufiGCD:define('Unit', function()
    local utils = TrufiGCD:require('utils')
    local UnitFrame = TrufiGCD:require('UnitFrame')
    local savedVariables = TrufiGCD:require('savedVariables')
    local blacklist = TrufiGCD:require('blacklist')

    local _idCounter = 0

    local getUniqId = function()
        _idCounter = _idCounter + 1
        return _idCounter
    end

    local unitsNames = {
        'player',
        -- 'party1', 'party2', 'party3', 'party4',
        -- 'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        -- 'target', 'focus'
    }

    local trinketIcon = 'Interface\\Icons\\inv_jewelry_trinketpvp_01'

    -- settings
    function loadSettings()
        settings = {}

        settings.unitFrames = {}
        table.foreach(savedVariables:getCharacter('unitFrame'), function(i, el)
            if unitsNames[i] then
                settings.unitFrames[unitsNames[i]] = {
                    offset = {el.x, el.y},
                    position = el.point,
                    direction = el.fade,
                    sizeIcons = el.size,
                    numberIcons = el.width,
                    enable = el.enable,
                    text = unitsNames[i]
                }
            end
        end)
    end

    loadSettings()
    savedVariables:on('change', loadSettings)

    -- list of buff of instance spells
    local instanceSpellsBuff = {
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

    local Unit = {}

    function Unit:new(options)
        local obj = {}
        obj.id = getUniqId()

        obj.typeName = options.typeName

        obj.unitFrame = UnitFrame:new(settings.unitFrames[obj.typeName])

        obj.isSpellCasting = false

        obj.canseledSpell = {
            id = 0,
            time = 0,
            iconId = 0
        }

        obj.enable = settings.unitFrames[obj.typeName].enable or true

        self.__index = self

        metatable = setmetatable(obj, self)

        return metatable
    end

    function Unit:eventsHandler(event, spellId)
        if not self.enable then return end

        if event == 'UNIT_SPELLCAST_START' then self:spellCastStart(spellId)
        elseif event == 'UNIT_SPELLCAST_SUCCEEDED' then self:spellCastSucceeded(spellId)
        elseif event == 'UNIT_SPELLCAST_STOP' then self:spellCastStop(spellId)
        elseif event == 'UNIT_SPELLCAST_CHANNEL_STOP' then self:spellCastChannelStop(spellId)
        elseif event == 'UNIT_AURA' then self:buffSucceeded() end
    end

    function Unit:spellCastStart(spellId)
        local spellInfo, _, spellIcon, spellCastTime = GetSpellInfo(spellId)
        local spellLink = GetSpellLink(spellId)

        if blacklist:has(spellId) or spellLink == nil or spellIcon == nil then return end

        self.isSpellCasting = true
        self.unitFrame:stopMoving()

        self.unitFrame:addSpell(spellId, spellIcon)
    end

    function Unit:spellCastSucceeded(spellId)
        local spellInfo, _, spellIcon, spellCastTime = GetSpellInfo(spellId)
        local spellLink = GetSpellLink(spellId)

        if blacklist:has(spellId) or spellLink == nil or spellIcon == nil then return end

        local isChannel = UnitChannelInfo(self.typeName)

        if self.isSpellCasting then
            if not isChannel then
                self.isSpellCasting = false
                self.unitFrame:startMoving()
            end
        else
            local spellFromBuff = self:checkForInstanceBuff(spellId)

            if isChannel then 
                self.isSpellCasting = true
                self.unitFrame:stopMoving()
            end

            if GetTime() - self.canseledSpell.time < 1 and self.canseledSpell.id == spellId then
                self.unitFrame:hideCansel(self.canseledSpell.iconId)
            end

            if spellCastTime <= 0 or spellFromBuff then
                self.unitFrame:addSpell(spellId, spellIcon)
            end
        end
    end

    function Unit:spellCastStop(spellId)
        if not self.isSpellCasting then return end

        if blacklist:has(spellId) then return end

        self.isSpellCasting = false
        self.unitFrame:startMoving()

        self.canseledSpell = {
            id = spellId,
            time = GetTime(),
            iconId = self.unitFrame:showCansel(spellId)
        }
    end

    function Unit:spellCastChannelStop(spellId)
        self.isSpellCasting = false
        self.unitFrame:startMoving()
    end

    function Unit:buffSucceeded()
        local i

        for i = 1, 20 do
            local buffId = select(11, UnitBuff(self.typeName, i))

            if instanceSpellsBuff[buffId] ~= nil then
                self.buffForInstanceSpell = buffId
                break
            end
        end
    end

    function Unit:checkForInstanceBuff(spellId)
        if self.buffForInstanceSpell ~= nil then
            return utils.contain(instanceSpellsBuff[self.buffForInstanceSpell], spellId)
        end
        return false
    end

    function Unit:update(time)
        if not self.enable then return end

        self.unitFrame:update(time)
    end

    return Unit
end)
