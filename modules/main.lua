local function init()
    local savedVariables = TrufiGCD:require('savedVariables')
    local settingsModule = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')

    local settings = nil

    local function loadSettings()
        settings = settingsModule:get()
    end

    loadSettings()
    settingsModule:on('change', loadSettings)

    local playerLocation = 'world'

    units.create()

    -- events
    local eventFrame = CreateFrame('Frame', nil, UIParent)

    eventFrame:RegisterEvent('UNIT_SPELLCAST_START')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_STOP')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')

    eventFrame:RegisterEvent('UNIT_AURA')

    local function eventHandler(self, event, unitType, _, _, _, spellId)
        if not settings.enable then return end

        if not utils.contain(config.unitNames, unitType) then return end

        units.list[unitType]:eventsHandler(event, spellId)
    end

    local minTimeInterval = config.minTimeInterval
    local timeLastUpdate = GetTime()

    local function onUpdate()
        if not settings.enable then return end

        local time = GetTime()
        local interval = time - timeLastUpdate

        if interval > minTimeInterval then
            for i, el in pairs(units.list) do
                el:update(interval)
            end

            timeLastUpdate = time
        end
    end

    eventFrame:SetScript('OnEvent', eventHandler)
    eventFrame:SetScript('OnUpdate', onUpdate)

    -- player events
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

        for i, el in pairs(config.unitsNames) do
            if el ~= typeName and checkEquelsUnits(typeName, el) then
                oldType = el
                break
            end
        end

        if oldType then 
            units.list[typeName]:setState(units.list[oldType]:getState())
        else
            units.list[typeName]:clearFrame()
        end
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
