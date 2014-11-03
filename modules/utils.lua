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

    utils.log = function(msg, isDeep, name, _layerNum)
        local offset = ''

        if name ~= nil then
            name = tostring(name) .. ' = '
        else
            name = ''
        end

        _layerNum = _layerNum or 0
        for i = 0, _layerNum do
            offset = offset .. '  '
        end

        if type(msg) == 'table' then
            print(offset .. name .. '{')
            for i, el in pairs(msg) do
                local txt = el

                if isDeep and type(el) == 'table' then
                    utils.log(el, true, i, _layerNum + 1)
                else
                    if type(el) == 'function' then txt = 'function'
                    elseif type(el) == 'table' then txt = 'table' end
                    print(offset .. '  ' .. i .. ' = ' .. tostring(txt))
                end
            end
            print(offset .. '}')
        else
            if msg == nil then msg = 'nil'
            elseif type(msg) == 'function' then msg = 'function' end
            print(offset .. msg)
        end
    end

    utils.contain = function(collection, element)
        local res = false

        table.foreach(collection, function(i, el)
            if el == element then
                res = true
                return false
            end
        end)

        return res
    end

    return utils
end)
