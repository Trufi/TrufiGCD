TrufiGCD:define('settings', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local profiles = savedVariables:getCommon('profiles') or {}

    local currentProfile = nil

    -- general settings keeps values which won't be shared between profiles
    local generalSettings = {
        tooltip = {
            enable = true,
            showInChatId = false,
            stopMove = false
        },
        typeMovingIcon = true,
        enable = true
    }

    -- get general setting from character own settings
    local characterSaves = savedVariables:getCharacter('profiles') or {}
    if characterSaves.generalSettings then
        utils.extend(generalSettings, characterSaves.generalSettings)
    end

    local settings = EventEmitter:new()

    function settings:createProfile(name, unitFrames)
        local profile = {}
        profile.name = name
        profile.id = utils.uuid()
        profile.unitFrames = {}

        for i, el in pairs(config.unitNames) do
            profile.unitFrames[el] = {
                offset = {0, 0},
                point = 'CENTER',
                direction = 'Left',
                sizeIcons = 30,
                numberIcons = 4,
                enable = true,
                transparencyIcons = 1,
                text = el
            }
        end

        if unitFrames then
            utils.extend(profile.unitFrames, unitFrames)
        end

        profiles[profile.id] = profile

        return profile
    end

    function settings:save()
        savedVariables:setCommon('profiles', profiles)
        savedVariables:setCharacter('profiles', generalSettings)
    end

    function settings:load()
        profiles = savedVariables:getCommon('profiles') or {}

        -- TODO: choose profile from place manager
        settings:setCurrentProfile(next(profiles))
    end

    function settings:getCurrentProfile()
        return currentProfile
    end

    -- смена профиля на выбранный (не сохранение)
    function settings:setCurrentProfile(id)
        if not profiles[id] then return end
        currentProfile = profiles[id]
        self:emit('change')
    end

    function settings:deleteCurrentProfile()
        if utils.size(profiles) <= 1 then return end

        profiles[currentProfile.id] = nil
        settings:setCurrentProfile(next(profiles))
    end

    function settings:getGeneral(settingsName)
        return generalSettings[settingsName]
    end

    function settings:setGeneral(settingsName, value)
        if type(value) == 'table' then
            utils.extemd(generalSettings[settingsName], value)
        else
            generalSettings[settingsName] = value
        end
        self:emit('change')
    end

    function settings:getProfileName()
        return currentProfile.name
    end

    function settings:setProfileName(newName)
        currentProfile.name = newName
        self:emit('change')
    end

    function settings:getProfileUnitFrames()
        return currentProfile.unitFrames
    end

    function settings:setProfileUnitFrames(unitFrames)
        utils.extend(currentProfile.unitFrames, unitFrames)
        self:emit('change')
    end

    function settings:getProfilesList()
        return profiles
    end

    function settings:default()
        profiles = {}
        self:createProfile(UnitName('player') .. ' - ' .. GetRealmName(), true)
    end

    -- if profiles list null create default profile
    if not next(profiles) then
        settings:default()
    end

    -- TODO: choose profile from place manager
    settings:setCurrentProfile(next(profiles))

    return settings
end)
