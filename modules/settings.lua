TrufiGCD:define('settings', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local settings = EventEmitter:new()

    local profiles = savedVariables:getCommon('profiles') or {}

    local characterSaves = savedVariables:getCharacter('profiles') or {}

    local currentProfile = nil

    function saveSettings()
        savedVariables:setCommon('profiles', profiles)
    end

    settings:on('change', saveSettings)

    function getDefaultProfileData()
        local res = {
            tooltip = {
                enable = true,
                showInChatId = false,
                stopMove = false
            },
            typeMovingIcon = true,
            unitFrames = {}
        }

        for i, el in pairs(config.unitNames) do
            res.unitFrames[el] = {
                offset = {0, 0},
                point = 'CENTER',
                direction = 'Left',
                sizeIcons = 30,
                numberIcons = 4,
                enable = true,
                text = el
            }
        end

        return res
    end

    function settings:createProfile(name, data)
        local profile = {}

        profile.name = name

        profiles[name] = profile

        profiles[name].data = getDefaultProfileData()

        settings:setProfileData(name, data)

        if currentProfile and currentProfile.name == name then
            self:emit('change')
        else
            saveSettings()
        end
    end

    function settings:setProfileData(name, data)
        if not profiles[name] or type(data) ~= 'table' then return end

        utils.extend(profiles[name].data, data)

        if currentProfile.name == name then
            self:emit('change')
        end
    end

    function settings:setCurrentProfile(name)
        if not profiles[name] then return end

        currentProfile = profiles[name]

        self:emit('change')
    end

    function settings:get(settingsName)
        if settingsName then
            return currentProfile.data[settingsName]
        else
            return currentProfile.data
        end
    end

    function settings:set(settingsName, data)
        if data then
            utils.extend(currentProfile.data[settingsName], data)
        else
            utils.extend(currentProfile.data, settingsName)
        end

        self:emit('change')
    end

    -- if profiles list null create default profile
    if not next(profiles) then
        settings:createProfile(UnitName('player') .. ' - ' .. GetRealmName(), true)
    end

    -- set current profile from settings or some one from profiles
    if characterSaves.currentProfile and profiles[characterSaves.currentProfile] then
        currentProfile = characterSaves.currentProfile
    else
        local i, el = next(profiles)
        currentProfile = el
    end

    return settings
end)
