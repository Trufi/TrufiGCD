TrufiGCD:define('utils', function() 
    utils = {}

    utils.clone = function(table, isDeep)
        if type(table) ~= 'table' then return end
        local res = {}

        for i, el in pairs(table) do
            if isDeep and (type(el) == 'table') then
                el = utils.clone(el, isDeep)
            end

            res[i] = el
        end

        return res
    end

    utils.log = function(msg)
        if type(msg) == 'table' then
            print('{')
            for i, el in pairs(msg) do
                local txt = el

                if type(el) == 'function' then txt = 'function' end

                print('  ' .. i .. ' = ' .. txt)
            end
            print('}')
        else
            if type(msg) == 'function' then 
                print('function')
            else
                print(msg)
            end
        end
    end

    return utils
end)
