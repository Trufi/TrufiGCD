---@type string, Namespace
local _, ns = ...

---@class Fonts
local fonts = {}
ns.fonts = fonts
local sharedMedia

function fonts:Refresh()
    if ns.units and ns.units.player then
        for _, icon in ipairs(ns.units.player.iconQueue.icons) do icon:UpdateTimingFont() end
    end
    if ns.settingsFrame and ns.settingsFrame.refreshTimingFont then ns.settingsFrame.refreshTimingFont() end
end

function fonts:OnMediaChanged(_, mediaType)
    if mediaType == "font" then self:Refresh() end
end

function fonts:GetSharedMedia()
    if not sharedMedia and LibStub then
        sharedMedia = LibStub("LibSharedMedia-3.0", true)
        if sharedMedia then
            sharedMedia.RegisterCallback(self, "LibSharedMedia_Registered", "OnMediaChanged")
            sharedMedia.RegisterCallback(self, "LibSharedMedia_SetGlobal", "OnMediaChanged")
        end
    end
    return sharedMedia
end

function fonts:List()
    local media = self:GetSharedMedia()
    return media and media:List("font") or {}
end

function fonts:Fetch(name)
    local media = self:GetSharedMedia()
    return name ~= "" and media and media:Fetch("font", name, true) or STANDARD_TEXT_FONT
end

function fonts:Apply(fontString, layoutType)
    local profile = ns.settings.activeProfile
    local size = profile.castTimingFontSize
    if size == 0 then
        size = math.max(9, math.min(16, profile.layoutSettings[layoutType].iconSize * 0.4))
    end
    if not fontString:SetFont(self:Fetch(profile.castTimingFont), size, "OUTLINE") then
        fontString:SetFont(STANDARD_TEXT_FONT, size, "OUTLINE")
    end
end

-- SharedMedia may be embedded in an addon that loads after TrufiGCD.
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:SetScript("OnEvent", function(self)
    if fonts:GetSharedMedia() then
        fonts:Refresh()
        self:UnregisterEvent("ADDON_LOADED")
    end
end)
