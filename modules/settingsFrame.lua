TrufiGCD:define('settingsFrame', function()
    local viewSettingsFrame = TrufiGCD:require('viewSettingsFrame')
    local profilesWidget = TrufiGCD:require('profilesWidget')
    local blacklistFrame = TrufiGCD:require('blacklistFrame')
    local profileSwitcherFrame = TrufiGCD:require('profileSwitcherFrame2')
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')

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

    local tooltipSettings = nil

    local function getDataFromSettings()
        tooltipSettings = settings:getGeneral('tooltip')
    end

    getDataFromSettings()
    settings:on('change', getDataFromSettings)

    -- profile widget
    local profileWidget = profilesWidget.full({
        parentFrame = frame,
        point = 'TOPLEFT',
        offset = {50, -30}
    })

    -- tooltip settings
    local frameTooltip = CreateFrame('Frame', nil, frame)
    frameTooltip:SetWidth(500)
    frameTooltip:SetHeight(500)
    frameTooltip:SetPoint('TOPLEFT', 300, -400)

    local textTooltip = frameTooltip:CreateFontString(nil, 'BACKGROUND')
    textTooltip:SetFont('Fonts\\FRIZQT__.TTF', 12)
    textTooltip:SetText('Tooltip:')
    textTooltip:SetPoint('TOPLEFT', 0, 0)

    local chboxTooltipEnable = CreateFrame('CheckButton', 'TrGCDTooltipEnable', frameTooltip, 'OptionsSmallCheckButtonTemplate')
    chboxTooltipEnable:SetPoint('TOPLEFT', 0, -20)
    chboxTooltipEnable:SetChecked(tooltipSettings.enable)
    _G[chboxTooltipEnable:GetName() .. 'Text']:SetText('Enable')

    local chboxTooltipIconMove = CreateFrame('CheckButton', 'TrGCDTooltipIconMove', frameTooltip, 'OptionsSmallCheckButtonTemplate')
    chboxTooltipIconMove:SetPoint('TOPLEFT', 0, -50)
    chboxTooltipIconMove:SetChecked(tooltipSettings.stopMove)
    _G[chboxTooltipIconMove:GetName() .. 'Text']:SetText('Stop icons')

    local chboxTooltipSpellId = CreateFrame('CheckButton', 'TrGCDTooltipSpellId', frameTooltip, 'OptionsSmallCheckButtonTemplate')
    chboxTooltipSpellId:SetPoint('TOPLEFT', 0, -80)
    chboxTooltipSpellId:SetChecked(tooltipSettings.showIdInChat)
    _G[chboxTooltipSpellId:GetName() .. 'Text']:SetText('Spell ID')

    function tooltipEnableOnclick()
        tooltipSettings.enable = not tooltipSettings.enable
        settings:setGeneral('tooltip', tooltipSettings)
    end

    function tooltipIconMoveOnclick()
        tooltipSettings.stopMove = not tooltipSettings.stopMove
        settings:setGeneral('tooltip', tooltipSettings)
    end

    function tooltipSpellIdOnclick()
        tooltipSettings.showIdInChat = not tooltipSettings.showIdInChat
        settings:setGeneral('tooltip', tooltipSettings)
    end

    chboxTooltipEnable:SetScript('OnClick', tooltipEnableOnclick)
    chboxTooltipIconMove:SetScript('OnClick', tooltipIconMoveOnclick)
    chboxTooltipSpellId:SetScript('OnClick', tooltipSpellIdOnclick)

    InterfaceOptions_AddCategory(frame)

    InterfaceOptions_AddCategory(viewSettingsFrame)

    InterfaceOptions_AddCategory(blacklistFrame)

    InterfaceOptions_AddCategory(profileSwitcherFrame)

    -- TODO: убрать потом
    -- TrGCDGUITEST = viewSettingsFrame
    -- /run InterfaceOptionsFrame_OpenToCategory(TrGCDGUITEST)
end)
