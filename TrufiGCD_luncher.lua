-- TrufiGCD stevemyz@gmail.com

local addonIsLoad = false
local modulesToLoad = {}
local modules = {}

TrufiGCD = {
    define = function(self, name, module)
        if addonIsLoad then
            modules[name] = module()
        else
            table.insert(modulesToLoad, {name = name, module = module})
        end
    end,

    require = function(self, name)
        return modules[name]
    end
}

function loadAllDeps()
    addonIsLoad = true

    for i = 1, #modulesToLoad do
        modules[modulesToLoad[i].name] = modulesToLoad[i].module()
    end

    modulesToLoad = {}
end

local loadFrame = CreateFrame('Frame', nil, UIParent)
loadFrame:RegisterEvent('ADDON_LOADED')
loadFrame:SetScript('OnEvent', function(self, event, name)
    if name == 'TrufiGCD' then
        loadAllDeps()

        -- init main module
        TrufiGCD:require('main')()

        loadFrame:SetScript('OnEvent', nil)
        loadFrame:SetParent(nil)
        loadFrame = nil
    end
end)
