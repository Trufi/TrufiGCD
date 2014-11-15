TrufiGCD:define('spellTooltip', function()
    local utils = TrufiGCD:require('utils')
    local settingsModule = TrufiGCD:require('settings')

    local tooltip = {}

    local settings = settingsModule:get('tooltip')

    -- update settings if player change it
    settingsModule:on('change', function()
        settings = settingsModule:get('tooltip')
    end)

    function tooltip:show(spellId, frame)
        if settings.enable and spellId and frame then
            GameTooltip_SetDefaultAnchor(GameTooltip, frame)
            GameTooltip:SetSpellByID(spellId, false, false, true)
            GameTooltip:Show()

            if settings.showIdInChat then
                print(GetSpellLink(spellId) .. ' ID: ' .. spellId)
            end
        end
    end

    function tooltip:hide()
        GameTooltip:Hide()
    end

    return tooltip
end)
