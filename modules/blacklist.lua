TrufiGCD:define('blacklist', function()
    local savedVariables = TrufiGCD:require('savedVariables')
    local utils = TrufiGCD:require('utils')

    -- inner black list, consider only spell id
    local innerList = {
        61391, -- Typhoon x2
        5374, -- Mutilate х3
        27576, -- Mutilate Off-Hand х3
        88263, -- Hammer of the Righteous х3
        32175, -- Stormstrike
        32176, -- Stormstrike Off-Hand
        96103, -- Raging Blow
        85384, -- Raging Blow Off-Hand
        57794, -- Heroic Leap
        52174, -- Heroic Leap
        135299, -- Tar Trap
        114093, -- Windlash Off-Hand
        114089, -- Windlash
        115357, -- Windstrike
        115360, -- Windstrike Off-Hand
        127797, -- Ursol's Vortex
        102794, -- Ursol's Vortex
        50622, -- Bladestorm
        122128, -- Divine Star (shadow priest)
        110745, -- Divine Star (not shadow priest)
        120696, -- Halo (shadow priest)
        120692, -- Halo (not shadow priest)
        132951, -- Flare
        107270, -- Spinning Crane Kick
        228597, -- Frostbolt
        166646 -- Windwalking
    }

    local defaultBlacklist = {
        6603, -- Auto Attack
        75 -- Auto Shot
    }

    local list = nil

    local function initSettings()
        list = savedVariables:getCommon('blacklist')

        if list == nil then
            list = utils.clone(defaultBlacklist)
            savedVariables:setCommon('blacklist', list)
        end
    end

    initSettings()

    local blacklist = {}

    blacklist.has = function(self, el)
        for i, listElement in pairs(list) do
            -- check eqls ids
            if listElement == el then return true end
            -- check eqls spellnames
            if listElement == GetSpellInfo(el) then return true end
        end

        for i, listElement in pairs(innerList) do
            if listElement == el then return true end
        end

        return false
    end

    blacklist.getList = function()
        return utils.clone(list)
    end

    blacklist.add = function(self, el)
        if #list > 60 then return end

        for i = 1, #list do
            if list[i] == el then return end
        end

        local numEl = tonumber(el)

        if numEl ~= nil then
            table.insert(list, numEl)
        else
            table.insert(list, el)
        end
    end

    blacklist.remove = function(self, el)
        for i = 1, #list do
            if list[i] == el then 
                table.remove(list, i)
            end
        end
    end

    blacklist.save = function()
        savedVariables:setCommon('blacklist', list)
    end

    blacklist.load = function()
        initSettings()
    end

    blacklist.default = function()
        list = utils.clone(defaultBlacklist)
    end

    return blacklist
end)
