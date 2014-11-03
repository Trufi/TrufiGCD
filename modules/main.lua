function init()
    local utils = TrufiGCD:require('utils')
    local Unit = TrufiGCD:require('Unit')
    local savedVariables = TrufiGCD:require('savedVariables')

    local isEnable = true

    local unitsNames = {
        'player',
        -- 'party1', 'party2', 'party3', 'party4',
        -- 'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        -- 'target', 'focus'
    }

    -- create units
    local units = {}

    table.foreach(unitsNames, function(i, el)
        units[el] = Unit:new({typeName = el})
    end)

    -- events
    local eventFrame = CreateFrame('Frame', nil, UIParent)

    eventFrame:RegisterEvent('UNIT_SPELLCAST_START')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_STOP')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')

    eventFrame:RegisterEvent('UNIT_AURA')

    function eventHandler(self, event, unitType, _, _, _, spellId)
        if not isEnable then return end

        if not utils.contain(unitsNames, unitType) then return end

        units[unitType]:eventsHandler(event, spellId)
    end

    local minTimeInterval = 0.03
    local timeLastUpdate = GetTime()

    function onUpdate()
        if not isEnable then return end

        local time = GetTime()
        local interval = time - timeLastUpdate

        if interval > minTimeInterval then
            table.foreach(units, function(i, el)
                el:update(interval)
            end)

            timeLastUpdate = time
        end
    end

    eventFrame:SetScript('OnEvent', eventHandler)
    eventFrame:SetScript('OnUpdate', onUpdate)
end

TrufiGCD:define('main', function()
    return init
end)
