TrufiGCD:define('profileSwitcher', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')

    local currentProfileName = nil
    local profilesList = nil

    local profileSwitcher = EventEmitter:new()

    local function getDataFromSettings()
        profilesList = settings:getProfilesList()
        profileSwitcher:emit('change')
    end

    currentProfileName = settings:getName()
    profilesList = settings:getProfilesList()
    settings:on('change', getDataFromSettings)

    function profileSwitcher:set(type, name)
    end

    function profileSwitcher:get(type)
    end

end)
