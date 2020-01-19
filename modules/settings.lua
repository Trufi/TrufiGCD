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
            showIdInChat = false,
            stopMove = false
        },
        latestProfileId = nil
    }

    -- get general setting from character own settings
    local characterSaves = savedVariables:getCharacter('profiles') or {}
    if characterSaves then
        utils.extend(generalSettings, characterSaves)
    end

    local function getlatestProfileIdId()
        if generalSettings.latestProfileId and profiles[generalSettings.latestProfileId] then
            return generalSettings.latestProfileId
        end
        return next(profiles)
    end

    local settings = EventEmitter:new()

    function settings:createProfile(name, data)
        local profile = {}
        profile.name = name
        profile.id = utils.uuid()
        profile.typeMovingIcon = data.typeMovingIcon or 0;
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

        if data.unitFrames then
            utils.extend(profile.unitFrames, data.unitFrames)
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
        settings:setCurrentProfile(getlatestProfileIdId())
    end

    function settings:getCurrentProfileData()
        return currentProfile
    end

    -- changing current profile (not saving)
    function settings:setCurrentProfile(id)
        if not profiles[id] then return end
        currentProfile = profiles[id]
        generalSettings.latestProfileId = id
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
            utils.extend(generalSettings[settingsName], value)
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
        self:createProfile(UnitName('player') .. ' - ' .. GetRealmName(), {})
    end

    -- if profiles list null create default profile
    if not next(profiles) then
        settings:default()
    end

    settings:setCurrentProfile(getlatestProfileIdId())

    return settings
end)
