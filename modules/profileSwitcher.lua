TrufiGCD:define('profileSwitcher', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')

    local SPECS = {
        [1] = '1',
        [2] = '2',
        [3] = '3',
        [4] = '4'
    }

    local PLACES = {
        WORLD = 'WORLD',
        PARTY = 'PARTY',
        RAID = 'RAID',
        ARENA = 'ARENA',
        BATTLEGROUND = 'BATTLEGROUND'
    }

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

    local Rule = {}

    function Rule:new(id)
        local obj = {}

        obj.id = id
        obj.placeConditions = {}
        obj.specConditions = {}

        -- TODO: а что если профиль переименуют?
        obj.profileName = '123'

        self.__index = self

        metatable = setmetatable(obj, self)

        return metatable
    end

    function Rule:enableEverywhere()
        self.placeConditions[PLACES.WORLD] = true
        self.placeConditions[PLACES.PARTY] = true
        self.placeConditions[PLACES.RAID] = true
        self.placeConditions[PLACES.ARENA] = true
        self.placeConditions[PLACES.BATTLEGROUND] = true

        self.specConditions[SPECS[1]] = true
        self.specConditions[SPECS[2]] = true
        self.specConditions[SPECS[3]] = true
        self.specConditions[SPECS[4]] = true
    end

    function Rule:getData()
        return {
            placeConditions = self.placeConditions,
            specConditions = self.specConditions,
            profileName = self.profileName
        }
    end

    function Rule:setData(data)
        self.placeConditions = data.placeConditions
        self.specConditions = data.specConditions
        self.profileName = data.profileName
    end

    function Rule:getProfileName()
        return self.profileName
    end

    local rules = {}

    local function initRules()
        local list = savedVariables:getCharacter('profilesRules')

        if list == nil then
            list = {}
            local tempRule = Rule:new(1)
            tempRule:enableEverywhere()
            list[1] = tempRule:getData()
            savedVariables:setCharacter('profilesRules', list)
        end

        for id, data in pairs(list) do
            local rule = Rule:new(id)
            rules[id] = rule
            rule:setData(data)
        end
    end

    initRules()

    local function saveRules()
        local list = {}

        for id, rule in pairs(rules) do
            list[id] = rule:getData()
        end

        -- savedVariables:setCharacter('profilesRules', list)
    end

    function profileSwitcher:createRule(id)
        local rule = Rule:new(id)

        rules[id] = rule

        return rule
    end

    function profileSwitcher:getRules()
        return rules
    end

    return profileSwitcher
end)
