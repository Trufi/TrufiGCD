TrufiGCD:define('masqueHelper', function()
    local Masque = LibStub('Masque', true)

    local icons

    local masqueHelper = {}

    if Masque then
        icons = Masque:Group("TrufiGCD", "All Icons")
    end

    function masqueHelper:addIcon(frame, texture)
        if Masque then
            icons:AddButton(frame, {Icon = texture})
        end
    end

    function masqueHelper:reskinIcons()
        if Masque then
            icons:ReSkin()
        end
    end

    return masqueHelper
end)
