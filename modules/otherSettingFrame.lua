TrufiGCD:define('otherSettingFrame', function()
    local settings = TrufiGCD:require('settings')
    local utils = TrufiGCD:require('utils')

    local frame = CreateFrame('Frame', nil, UIParent, 'OptionsBoxTemplate')
    frame.name = 'Other settings'
    frame.parent = 'TrufiGCD'

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

    -- tooltip settings
    local frameTooltip = CreateFrame('Frame', nil, frame)
    frameTooltip:SetWidth(500)
    frameTooltip:SetHeight(500)
    frameTooltip:SetPoint('TOPLEFT', 20, -20)

    local textTooltip = frameTooltip:CreateFontString(nil, 'BACKGROUND')
    textTooltip:SetFont(STANDARD_TEXT_FONT, 12)
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

    return frame
end)
