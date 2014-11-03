TrufiGCD:define('savedVariables', function()
    local utils = TrufiGCD:require('utils')
    local EventEmitter = TrufiGCD:require('eventEmitter')

    local commonSaves = TrufiGCDGlSave or {}
    local characterSaves = TrufiGCDChSave or {}

    -- new name to old names
    local redirectionTable = {
        blacklist = 'TrGCDBL',
        spellTooltip = {
            enable = 'TooltipEnable',
            showInChatId = 'TooltipSpellID'
        },
        unitFrame = 'TrGCDQueueFr'
    }

    local savedVariables = EventEmitter:new()

    function savedVariables:getCommon(name)
        local finallyName = redirectionTable[name] or name
        local res

        if type(finallyName) == 'table' then
            res = {}

            table.foreach(finallyName, function(i, el)
                res[i] = utils.clone(commonSaves[el], true)
            end)
        else
            res = utils.clone(commonSaves[finallyName], true)
        end

        return res
    end

    function savedVariables:getCharacter(name)
        local finallyName = redirectionTable[name] or name
        local res

        if type(finallyName) == 'table' then
            res = {}

            table.foreach(finallyName, function(i, el)
                res[i] = utils.clone(characterSaves[el], true)
            end)
        else
            res = utils.clone(characterSaves[finallyName], true)
        end

        return res
    end

    function savedVariables:setCommon(name, settings)
        local finallyName = redirectionTable[name] or name
        local res

        if type(finallyName) == 'table' then
            res = {}

            table.foreach(finallyName, function(i, el)
                res[i] = utils.clone(settings[el], true)
            end)
        else
            res = utils.clone(settings[finallyName], true)
        end

        commonSaves[finallyName] = res

        self:emit('changeCommon')
    end

    function savedVariables:setCharacter(name, settings)
        local finallyName = redirectionTable[name] or name
        local res

        if type(finallyName) == 'table' then
            res = {}

            table.foreach(finallyName, function(i, el)
                res[i] = utils.clone(settings[el], true)
            end)
        else
            res = utils.clone(settings[finallyName], true)
        end

        characterSaves[finallyName] = res

        self:emit('change')
    end

    return savedVariables
end)
