TrufiGCD:define('settingsFrame', function()
    local viewSettingsFrame = TrufiGCD:require('viewSettingsFrame')
    local savedVariables = TrufiGCD:require('savedVariables')
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')

    -- main settings frame
    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'TrufiGCD'

    InterfaceOptions_AddCategory(frame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    -- убрать потом
    TrGCDGUITEST = viewSettingsFrame
end)
