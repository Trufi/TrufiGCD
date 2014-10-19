TrufiGCD:define('savedVariables', function()
    local utils = TrufiGCD:require('utils')

    local commonSaves = TrufiGCDGlSave or {}
    local characterSaves = TrufiGCDChSave or {}

    local redirectionTable = {
        blacklist = 'TrGCDBL'
    }

    function Test()
        utils.log(characterSaves, true)
    end

    return {
        getCommon = function(self, name)
            local finallyName = redirectionTable[name] or name

            return utils.clone(commonSaves[finallyName], true)
        end,

        getCharacter = function(self, name)
            local finallyName = redirectionTable[name] or name

            return utils.clone(characterSaves[finallyName], true)
        end,

        setCommon = function(self, name, settings)
            local finallyName = redirectionTable[name] or name

            commonSaves[finallyName] = utils.clone(settings, true)
        end,

        setCharacter = function(self, name, settings)
            local finallyName = redirectionTable[name] or name

            characterSaves[finallyName] = utils.clone(settings, true)
        end
    }
end)
