local function init()
    local utils = TrufiGCD:require('utils')
    local Unit = TrufiGCD:require('Unit')
    local savedVariables = TrufiGCD:require('savedVariables')

    local isEnable = true

    local playerLocation = 'world'

    local unitsNames = {
        'player',
        'party1', 'party2', 'party3', 'party4',
        'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        'target', 'focus'
    }

    -- create units
    local units = {}

    for i, el in pairs(unitsNames) do
        units[el] = Unit:new({typeName = el})
    end

    -- events
    local eventFrame = CreateFrame('Frame', nil, UIParent)

    eventFrame:RegisterEvent('UNIT_SPELLCAST_START')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_STOP')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')

    eventFrame:RegisterEvent('UNIT_AURA')

    local function eventHandler(self, event, unitType, _, _, _, spellId)
        if not isEnable then return end

        if not utils.contain(unitsNames, unitType) then return end

        units[unitType]:eventsHandler(event, spellId)
    end

    local minTimeInterval = 0.03
    local timeLastUpdate = GetTime()

    local function onUpdate()
        if not isEnable then return end

        local time = GetTime()
        local interval = time - timeLastUpdate

        if interval > minTimeInterval then
            for i, el in pairs(units) do
                el:update(interval)
            end

            timeLastUpdate = time
        end
    end

    eventFrame:SetScript('OnEvent', eventHandler)
    eventFrame:SetScript('OnUpdate', onUpdate)

    -- 
    local playerEventFrame = CreateFrame('Frame', nil, UIParent)
    --playerEventFrame:RegisterEvent('PLAYER_ENTERING_BATTLEGROUND')
    playerEventFrame:RegisterEvent('PLAYER_ENTERING_WORLD')
    playerEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
    playerEventFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')

    local function checkEquelsUnits(a, b)
        local nameA = UnitName(a)
        local nameB = UnitName(b)

        return nameA and nameB and nameA == nameB and UnitHealth(a) == UnitHealth(b)
    end

    local function unitFrameChangeOwner(typeName)
        local oldType = nil

        for i, el in pairs(unitsNames) do
            if el ~= typeName and checkEquelsUnits(typeName, el) then
                oldType = el
                break
            end
        end

        if not oldType then return end

        units[typeName]:setState(units[oldType]:getState())
    end

    local function playerEventHandler(self, event)
        if event == 'PLAYER_ENTERING_WORLD' then 
            playerLocation = select(2, IsInInstance())
        elseif event == 'PLAYER_TARGET_CHANGED' then
            unitFrameChangeOwner('target')
        elseif event == 'PLAYER_FOCUS_CHANGED' then
            unitFrameChangeOwner('focus')
        end
    end

    playerEventFrame:SetScript('OnEvent', playerEventHandler)
end

TrufiGCD:define('main', function()
    return init
end)
