TrufiGCD:define('settingsFrame', function()
    local viewSettingsFrame = TrufiGCD:require('viewSettingsFrame')
    local blacklistFrame = TrufiGCD:require('blacklistFrame')
    local settings = TrufiGCD:require('settings')

    -- main settings frame
    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'TrufiGCD'

    frame.okay = function()
        settings:save()
    end

    frame.cancel = function()
        settings:load()
    end

    frame.default = function()
        settings:default()
    end

    InterfaceOptions_AddCategory(frame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    -- убрать потом
    TrGCDGUITEST = viewSettingsFrame
end)
