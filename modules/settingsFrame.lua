TrufiGCD:define('settingsFrame', function()
    local viewSettingsFrame = TrufiGCD:require('viewSettingsFrame')
    local profilesWidget = TrufiGCD:require('profilesWidget')
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

    -- profile widget
    local profileWidget = profilesWidget.full({
        parentFrame = frame,
        point = 'TOPLEFT',
        offset = {50, -30}
    })

    InterfaceOptions_AddCategory(frame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    InterfaceOptions_AddCategory(blacklistFrame)

    -- убрать потом
    TrGCDGUITEST = viewSettingsFrame
end)
