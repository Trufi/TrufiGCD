TrufiGCD:define('settings', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local settings = EventEmitter:new()

    local profiles = savedVariables:getCommon('profiles') or {}

    local characterSaves = savedVariables:getCharacter('profiles') or {}

    local currentProfile = nil

    local function getDefaultProfileData()
        local res = {
            tooltip = {
                enable = true,
                showInChatId = false,
                stopMove = false
            },
            typeMovingIcon = true,
            unitFrames = {},
            enable = true
        }

        for i, el in pairs(config.unitNames) do
            res.unitFrames[el] = {
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

        return res
    end

    local function setProfileData(name, data)
        if not profiles[name] or type(data) ~= 'table' then return end

        utils.extend(profiles[name].data, data)
    end

    function settings:createProfile(name, data)
        local profile = {}
        profile.name = name
        profile.uuid = utils.uuid()
        profile.data = getDefaultProfileData()
        profiles[name] = profile

        setProfileData(name, data)

        if currentProfile and currentProfile.name == name then
            self:emit('change')
        end
    end

    function settings:save()
        savedVariables:setCommon('profiles', profiles)
    end

    function settings:load()
        profiles = savedVariables:getCommon('profiles') or {}

        -- TODO: choose profile from place manager
        -- set current profile from settings or some one from profiles
        if characterSaves.currentProfile and profiles[characterSaves.currentProfile] then
            settings:setCurrentProfile(profiles[characterSaves.currentProfile])
        else
            settings:setCurrentProfile(next(profiles))
        end
        --

        self:emit('change')
    end

    function settings:setCurrentProfile(name)
        if not profiles[name] then return end

        currentProfile = profiles[name]

        self:emit('change')
    end

    function settings:getCurrentProfile()
        return currentProfile
    end

    function settings:getName()
        return currentProfile.name
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

    function settings:getProfilesList()
        local list = {}

        for i, el in pairs(profiles) do
            table.insert(list, el.name)
        end

        return list
    end

    function settings:deleteProfile(name)
        if profiles[name] == currentProfile then
            profiles[name] = nil
            settings:setCurrentProfile(next(profiles))
        else
            profiles[name] = nil
            self:emit('change')
        end
    end

    function settings:rename(newName)
        profiles[currentProfile.name] = nil
        currentProfile.name = newName
        profiles[newName] = currentProfile

        self:emit('change')
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

    -- set current profile from settings or some one from profiles
    if characterSaves.currentProfile and profiles[characterSaves.currentProfile] then
        settings:setCurrentProfile(profiles[characterSaves.currentProfile])
    else
        settings:setCurrentProfile(next(profiles))
        settings:save()
    end

    return settings
end)

-- profiles -- [ world, bg, pve, arena ]
