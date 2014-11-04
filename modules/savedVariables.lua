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
        unitFrame = 'TrGCDQueueFr',
        all = {
            tooltip = {
                enable = 'TooltipEnable',
                showInChatId = 'TooltipSpellID',
                stopMove = 'TooltipStopMove'
            },
            unitFrame = 'TrGCDQueueFr',
            enableLocations = 'EnableIn',
            typeMovingIcon = 'ModScroll'
        }
    }

    local savedVariables = EventEmitter:new()

    -- get from settings
    local function recurrentGet(name, saves)
        local res = nil

        if type(name) == 'table' then
            res = {}

            for i, el in pairs(name) do
                res = recurrentGet(el, saves)
            end
        else
            res = utils.clone(saves[name], true)
        end

        return res
    end

    function savedVariables:getCommon(name)
        local finallyName = redirectionTable[name] or name

        return recurrentGet(finallyName, commonSaves)
    end

    function savedVariables:getCharacter(name)
        local finallyName = redirectionTable[name] or name

        return recurrentGet(finallyName, characterSaves)
    end

    -- set to settings
    local function recurrentSet(name, settings, saves)
        if type(name) == 'table' then
            for i, el in pairs(finallyName) do
                if settings[i] then
                    recurrentSet(el, settings[i], saves)
                end
            end
        else
            saves[name] = utils.clone(settings, true)
        end
    end

    function savedVariables:setCommon(name, settings)
        local finallyName = redirectionTable[name] or name

        recurrentSet(name, settings, commonSaves)

        self:emit('changeCommon')
    end

    function savedVariables:setCharacter(name, settings)
        local finallyName = redirectionTable[name] or name

        recurrentSet(name, settings, characterSaves)

        self:emit('change')
    end

    return savedVariables
end)
