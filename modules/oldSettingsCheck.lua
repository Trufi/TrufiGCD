TrufiGCD:define('oldSettingsCheck', function()
    local utils = TrufiGCD:require('utils')
    local settings = TrufiGCD:require('settings')
    local savedVariables = TrufiGCD:require('savedVariables')

    -- TrGCDQueueFr[num] to unitFrames[name]
    local unitNames = {
        'player',
        'party1', 'party2', 'party3', 'party4',
        'arena1', 'arena2', 'arena3', 'arena4', 'arena5',
        'target', 'focus'
    }

    local function unitFramesToNewSettings(unitFrames)
        local res = {}

        for i, el in pairs(unitFrames) do
            if unitNames[i] then
                res[unitNames[i]] = {
                    offset = {el.x, el.y},
                    point = el.point,
                    direction = el.fade,
                    sizeIcons = el.size,
                    numberIcons = el.width,
                    enable = el.enable,
                    text = unitNames[i]
                }
            end
        end

        return res
    end

    local oldSaves = savedVariables:getCharacter()

    -- convert old version character settings to settings profile Player name - Server name
    function oldCharacterSettingsToProfile()
        local newSaves = {
            blacklist = oldSaves['TrGCDBL'],
            tooltip = {
                enable = oldSaves['TooltipEnable'],
                showIdInChat = oldSaves['TooltipSpellID'],
                stopMove = oldSaves['TooltipStopMove']
            },
            unitFrames = unitFramesToNewSettings(oldSaves['TrGCDQueueFr']),
            typeMovingIcon = 0
        }

        if oldSaves['ModScroll'] == false then
            newSaves.typeMovingIcon = 1
        end

        settings:createProfile(UnitName('player') .. ' - ' .. GetRealmName(), newSaves)
        settings:save()

        savedVariables:setCharacter('TrGCDBL', nil)
        savedVariables:setCharacter('TooltipEnable', nil)
        savedVariables:setCharacter('TooltipSpellID', nil)
        savedVariables:setCharacter('TooltipStopMove', nil)
        savedVariables:setCharacter('TrGCDQueueFr', nil)
        savedVariables:setCharacter('ModScroll', nil)
        savedVariables:setCharacter('EnableIn', nil)
    end

    if oldSaves['TrGCDQueueFr'] ~= nil then
        oldCharacterSettingsToProfile()
    end
end)
