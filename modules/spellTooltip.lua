TrufiGCD:define('spellTooltip', function()
    local utils = TrufiGCD:require('utils')

    local tooltip = {}

    -- TODO: включен или нет из настроек, включен или нет вывод spellId в чат

    GameTooltip_SetDefaultAnchor(GameTooltip)

    function tooltip:show(spellId)
        if (self.spellId) then
            GameTooltip:SetSpellByID(spellId, false, false, true)
            GameTooltip:Show()

            print(GetSpellLink(spellId) .. ' ID: ' .. spellId) end
        end
    end

    function tooltip:hide()
        GameTooltip:Hide()
    end

end
