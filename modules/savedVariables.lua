TrufiGCD:define('savedVariables', function()
    local utils = TrufiGCD:require('utils')

    TrufiGCDGlSave = TrufiGCDGlSave or {}
    TrufiGCDChSave = TrufiGCDChSave or {}
    local commonSaves = TrufiGCDGlSave
    local characterSaves = TrufiGCDChSave

    local savedVariables = {}

    function savedVariables:getCommon(name)
        if name then
            return utils.clone(commonSaves[name], true)
        else
            return utils.clone(commonSaves, true)
        end
    end

    function savedVariables:getCharacter(name)
        if name then
            return utils.clone(characterSaves[name], true)
        else
            return utils.clone(characterSaves, true)
        end
    end

    function savedVariables:setCommon(name, settings)
        commonSaves[name] = utils.clone(settings, true)
    end

    function savedVariables:setCharacter(name, settings)
        characterSaves[name] = utils.clone(settings, true)
    end

    return savedVariables
end)
