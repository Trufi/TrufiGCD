TrufiGCD:define('spellTooltip', function()
    local utils = TrufiGCD:require('utils')
    local savedVariables = TrufiGCD:require('savedVariables')

    local tooltip = {}

    local settings = savedVariables:getCharacter('spellTooltip')

    -- update settings if player change it
    savedVariables:on('change', function()
        settings = savedVariables:getCharacter('spellTooltip')
    end)

    function tooltip:show(spellId, frame)
        if settings.enable and spellId and frame then
            GameTooltip_SetDefaultAnchor(GameTooltip, frame)
            GameTooltip:SetSpellByID(spellId, false, false, true)
            GameTooltip:Show()

            if settings.showInChatId then
                print(GetSpellLink(spellId) .. ' ID: ' .. spellId)
            end
        end
    end

    function tooltip:hide()
        GameTooltip:Hide()
    end

    return tooltip
end)
