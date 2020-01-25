local function init()
    local profileSwitcher = TrufiGCD:require('profileSwitcher')
    local savedVariables = TrufiGCD:require('savedVariables')
    local settingsModule = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')

    local settings = nil

    local function loadSettings()
        settings = {
            enable = settingsModule:getGeneral('enable')
        }
    end

    loadSettings()
    settingsModule:on('change', loadSettings)

    local playerLocation = config.places['WORLD']
    local playerSpecialization = config.specs[GetSpecialization()]

    units.create()

    -- events
    local eventFrame = CreateFrame('Frame', nil, UIParent)

    eventFrame:RegisterEvent('UNIT_SPELLCAST_START')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_SUCCEEDED')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_STOP')
    eventFrame:RegisterEvent('UNIT_SPELLCAST_CHANNEL_STOP')

    eventFrame:RegisterEvent('UNIT_AURA')

    local function eventHandler(self, event, unitType, _, spellId)
        if not utils.contain(config.unitNames, unitType) then return end

        units.list[unitType]:eventsHandler(event, spellId)
    end

    local minTimeInterval = config.minTimeInterval
    local timeLastUpdate = GetTime()

    local function onUpdate()
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
    playerEventFrame:RegisterEvent('PLAYER_ENTERING_BATTLEGROUND')
    playerEventFrame:RegisterEvent('PLAYER_SPECIALIZATION_CHANGED')    
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

        for i, el in pairs(config.unitNames) do
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

    local function updatePlayerPlace()
        local _, instanceType = IsInInstance()

        if instanceType == 'pvp' then playerLocation = config.places['BATTLEGROUND']
        elseif instanceType == 'arena' then playerLocation = config.places['ARENA']
        elseif instanceType == 'raid' then playerLocation = config.places['RAID']
        elseif instanceType == 'party' then playerLocation = config.places['PARTY']
        else playerLocation = config.places['WORLD'] end

        profileSwitcher:updateCurrentSpecAndPlace(playerSpecialization, playerLocation)
    end

    local function updatePlayerSpec()
        playerSpecialization = config.specs[GetSpecialization()]
        profileSwitcher:updateCurrentSpecAndPlace(playerSpecialization, playerLocation)
    end

    local function playerEventHandler(self, event)
        if event == 'PLAYER_ENTERING_WORLD' or event == 'PLAYER_ENTERING_BATTLEGROUND' then
            updatePlayerPlace()

            -- after first PLAYER_ENTERING_WORLD events needs to update spec
            updatePlayerSpec()
        elseif event == 'PLAYER_TARGET_CHANGED' then
            unitFrameChangeOwner('target')
        elseif event == 'PLAYER_FOCUS_CHANGED' then
            unitFrameChangeOwner('focus')
        elseif event == 'PLAYER_SPECIALIZATION_CHANGED' then
            updatePlayerSpec()
        end
    end

    playerEventFrame:SetScript('OnEvent', playerEventHandler)
end

TrufiGCD:define('main', function()
    return init
end)
