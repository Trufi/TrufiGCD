TrufiGCD:define('profileSwitcher', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local places = config.places
    local specs = config.specs

    local currentProfileName = nil
    local profilesList = nil

    local Rule = EventEmitter:new()

    function Rule:new(id)
        local obj = EventEmitter:new()

        obj.id = id
        obj.placeConditions = {}
        obj.specConditions = {}

        -- TODO: нужно брать первый из списка профилей
        obj.profileName = currentProfileName

        self.__index = self

        metatable = setmetatable(obj, self)

        return metatable
    end

    function Rule:enableEverywhere()
        self.placeConditions[places.WORLD] = true
        self.placeConditions[places.PARTY] = true
        self.placeConditions[places.RAID] = true
        self.placeConditions[places.ARENA] = true
        self.placeConditions[places.BATTLEGROUND] = true

        self.specConditions[specs[1]] = true
        self.specConditions[specs[2]] = true
        self.specConditions[specs[3]] = true
        self.specConditions[specs[4]] = true

        self:emit('change')
    end

    function Rule:togglePlace(place)
        self.placeConditions[place] = not self.placeConditions[place]
        self:emit('change')
    end

    function Rule:toggleSpec(spec)
        self.specConditions[spec] = not self.specConditions[spec]
        self:emit('change')
    end

    function Rule:changeProfile(name)
        self.profileName = name
        self:emit('change')
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
        self:emit('change')
    end

    function Rule:remove()
        self:emit('remove')
    end

    local rules = {}

    local profileSwitcher = EventEmitter:new()

    local function getNextRuleId()
        local maxId = 0

        for id, _ in pairs(rules) do
            if maxId < id then
                maxId = id
            end
        end

        return maxId + 1
    end

    local function initRules()
        local list = savedVariables:getCharacter('profilesRules')

        if list == nil then
            list = {}
            local tempRule = Rule:new(0)
            tempRule:enableEverywhere()
            list[tempRule.id] = tempRule:getData()
            savedVariables:setCharacter('profilesRules', list)
        end

        for id, data in pairs(list) do
            local rule = Rule:new(getNextRuleId())
            rules[rule.id] = rule
            rule:setData(data)
            rule:on('change', function() profileSwitcher:emit('change') end)
            rule:on('remove', function() profileSwitcher:removeRule(rule) end)
        end
    end

    local function saveRules()
        local list = {}

        for id, rule in pairs(rules) do
            list[id] = rule:getData()
        end

        -- savedVariables:setCharacter('profilesRules', list)
    end

    local function getDataFromSettings()
        profilesList = settings:getProfilesList()
        profileSwitcher:emit('change')
    end

    currentProfileName = settings:getName()
    profilesList = settings:getProfilesList()
    initRules()
    settings:on('change', getDataFromSettings)

    function profileSwitcher:createRule()
        local rule = Rule:new(getNextRuleId())

        rules[rule.id] = rule

        rule:on('change', function() self:emit('change') end)
        rule:on('remove', function() self:removeRule(rule) end)

        self:emit('change')

        return rule
    end

    function profileSwitcher:removeRule(rule)
        rules[rule.id] = nil
        self:emit('change')
    end

    function profileSwitcher:getRules()
        return rules
    end

    return profileSwitcher
end)
