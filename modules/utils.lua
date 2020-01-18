TrufiGCD:define('utils', function()
    local utils = {}

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

    utils.extend = function(a, b)
        if type(a) ~= 'table' or type(b) ~= 'table' then return end

        for i, el in pairs(b) do
            if type(el) == 'table' then
                a[i] = a[i] or {}
                utils.extend(a[i], el)
            else
                a[i] = el
            end
        end
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
            print(offset .. tostring(msg))
        end
    end

    utils.contain = function(collection, element)
        for i, el in pairs(collection) do
            if el == element then
                return true
            end
        end

        return false
    end

    utils.size = function(collection)
        local size = 0

        for i, el in pairs(collection) do
            size = size + 1
        end

        return size
    end

    utils.uuid = function()
        local template ='xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
        return string.gsub(template, '[xy]', function(c)
            local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
            return string.format('%x', v)
        end)
    end

    return utils
end)
