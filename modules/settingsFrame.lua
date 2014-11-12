TrufiGCD:define('settingsFrame', function()
    local viewSettingsFrame = TrufiGCD:require('savedVariables')
    local savedVariables = TrufiGCD:require('savedVariables')
    local settings = TrufiGCD:require('settings')
    local config = TrufiGCD:require('config')
    local utils = TrufiGCD:require('utils')
    local units = TrufiGCD:require('units')

    -- main settings frame
    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'TrufiGCD'

    InterfaceOptions_AddCategory(frame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    -- убрать потом
    TrGCDGUITEST = viewSettingsFrame
end)
