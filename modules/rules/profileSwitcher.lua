TrufiGCD:define('profileSwitcher', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local EventEmitter = TrufiGCD:require('eventEmitter')
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    local places = config.places
    local specs = config.specs

    -- актуальные значения места и спеки, обнвовляются при каждом изменении
    local playerPlace = config.places['WORLD']
    local playerSpecialization = config.specs[GetSpecialization()]

    local currentProfile = nil
    local profilesList = nil

    local Rule = EventEmitter:new()

    function Rule:new(id)
        local obj = EventEmitter:new()

        obj.id = id
        obj.placeConditions = {}
        obj.specConditions = {}

        -- TODO: нужно брать первый из списка профилей
        obj.profileId = currentProfile.id

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

    function Rule:changeProfile(id)
        self.profileId = id
        self:emit('change')
    end

    function Rule:getData()
        return {
            placeConditions = self.placeConditions,
            specConditions = self.specConditions,
            profileId = self.profileId
        }
    end

    function Rule:setData(data)
        self.placeConditions = data.placeConditions
        self.specConditions = data.specConditions
        self.profileId = data.profileId
        self:emit('change')
    end

    function Rule:remove()
        self:emit('remove')
    end

    -- проверка правила на удовлетворение текущего спека или места
    function Rule:satisfy(spec, place)
        return self.specConditions[spec] and self.placeConditions[place]
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

    local function defaultSavedRules()
        local list = {}
        local tempRule = Rule:new(0)
        tempRule:enableEverywhere()
        list[tempRule.id] = tempRule:getData()
        return list
    end

    local function loadRules()
        local list = savedVariables:getCharacter('profilesRules')

        if list == nil then
            list = defaultSavedRules()
            savedVariables:setCharacter('profilesRules', list)
        end

        rules = {}
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

        savedVariables:setCharacter('profilesRules', list)
    end

    local function getDataFromSettings()
        currentProfile = settings:getCurrentProfile()
        profilesList = settings:getProfilesList()
        profileSwitcher:emit('change')
    end

    currentProfile = settings:getCurrentProfile()
    profilesList = settings:getProfilesList()
    loadRules()
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

    function profileSwitcher:load()
        loadRules()
        self:emit('change')
    end

    function profileSwitcher:save()
        saveRules()
    end

    function profileSwitcher:default()
        local list = defaultSavedRules()
        rules = {}
        for id, data in pairs(list) do
            local rule = Rule:new(getNextRuleId())
            rules[rule.id] = rule
            rule:setData(data)
            rule:on('change', function() profileSwitcher:emit('change') end)
            rule:on('remove', function() profileSwitcher:removeRule(rule) end)
        end
        self:emit('change')
    end

    function profileSwitcher:updateCurrentSpecAndPlace(spec, place)
        playerPlace = place
        playerSpecialization = spec
        profileSwitcher:findAndSetCurrentProfile()
    end

    function profileSwitcher:findAndSetCurrentProfile()    
        for _, rule in pairs(rules) do
            if rule:satisfy(playerSpecialization, playerPlace) then
                utils.log(rule.profileId)
                settings:setCurrentProfile(rule.profileId)
                return
            end
        end
    end

    -- function TrGCDSetSpec(spec)
    --     playerSpecialization = config.specs[spec]
    --     profileSwitcher:findAndSetCurrentProfile()
    --     utils.log(spec)
    -- end

    -- function TrGCDFindCurrentProfile()
    --     utils.log(profileSwitcher:findAndSetCurrentProfile())
    -- end

    return profileSwitcher
end)