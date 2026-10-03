-- Run with a Lua interpreter from the addon directory: lua Tests/CastTiming.lua
-- WoW event/cooldown mocks exercise the real timing, unit, queue, and icon modules.
local now, cooldown, timers = 10, {}, {}
local inCombat, frames, sharedMedia = false, {}, nil
local baseGCDs = {}
local compile = loadstring or load
local secret = setmetatable({}, {
    __lt = function() error("compared a secret") end,
    __le = function() error("compared a secret") end,
    __add = function() error("calculated with a secret") end,
    __div = function() error("calculated with a secret") end,
})
function GetTime() return now end
function UnitAffectingCombat() return inCombat end
function issecretvalue(value) return value == secret end
local testBuild = tonumber(os.getenv("TRUFIGCD_TEST_BUILD")) or 120001
function GetBuildInfo() return "test", "", "", testBuild end
function UnitName() return "Player" end
function GetRealmName() return "Realm" end
function UnitFactionGroup() return "Alliance" end
function GetSpellInfo(id) return "Spell " .. id, nil, id + 1000, 0 end
function GetSpellLink(id) return "spell:" .. id end
function GetSpellBaseCooldown(id) return 0, baseGCDs[id] or 1500 end
STANDARD_TEXT_FONT = "font"
UIParent = {}
C_Spell = { GetSpellCooldown = function(id)
    assert(id == 61304, "must read the GCD dummy spell")
    return cooldown
end }
C_Timer = { After = function(_, callback) timers[#timers + 1] = callback end }

local widget = {}
widget.__index = function(_, key) return widget[key] or function() end end
local function newWidget() return setmetatable({}, widget) end
function widget:CreateTexture() return newWidget() end
function widget:CreateFontString()
    local fontString = newWidget()
    fontString.isFontString = true
    return fontString
end
function widget:SetScript(event, callback) self[event] = callback end
function widget:SetText(text)
    assert(not rawget(self, "isFontString") or rawget(self, "font"), "FontString:SetText(): Font not set")
    self.text = text
end
function widget:SetTexture(texture) self.texture = texture end
function widget:SetFont(path, size, flags)
    self.font, self.fontSize, self.fontFlags = path, size, flags
    return path ~= "bad-font"
end
function widget:GetName() return self.name end
function widget:RegisterEvent(event) self.events[event] = true end
function widget:UnregisterEvent(event) self.events[event] = nil end
function widget:SetValue(value)
    local previous = self.value
    self.value = value
    if previous ~= value and self.OnValueChanged then self.OnValueChanged(self, value) end
end
function widget:GetTexture() return self.texture end
function widget:Show() self.shown = true end
function widget:Hide() self.shown = false end
function CreateFrame(_, name, _, template)
    local frame = newWidget()
    frame.name, frame.events, frame.parent = name, {}, false
    frames[#frames + 1] = frame
    if name then _G[name] = frame end
    if template and name then
        for _, suffix in ipairs({ "Text", "Low", "High" }) do _G[name .. suffix] = newWidget() end
    end
    return frame
end
function LibStub() return sharedMedia end
local function emit(event)
    for _, frame in ipairs(frames) do
        if frame.events[event] and frame.OnEvent then frame.OnEvent(frame, event) end
    end
end

local ns = { masqueHelper = { addIcon = function() end, reskinIcons = function() end } }
local function loadModule(path) assert(loadfile(path))("TrufiGCD", ns) end
for _, path in ipairs({
    "Modules/Constants.lua", "Modules/Utils.lua", "Modules/Fonts.lua",
    "Modules/Settings/LayoutSettings.lua", "Modules/Settings/UnitSettings.lua",
    "Modules/Settings/ProfileSettings.lua",
}) do loadModule(path) end
ns.settings = { activeProfile = ns.ProfileSettings:New({}) }
ns.innerBlockList, ns.innerIconsBlocklist = {}, {}
for _, path in ipairs({
    "Modules/Core/CastTiming.lua", "Modules/Core/Icon.lua",
    "Modules/Core/IconQueue.lua", "Modules/Core/Units.lua",
}) do loadModule(path) end
local unit = ns.units.player
local count = 0
local function equal(actual, expected, message)
    assert(actual == expected, (message or "value") .. ": expected " .. tostring(expected) .. ", got " .. tostring(actual))
end
local function near(actual, expected)
    assert(actual and math.abs(actual - expected) < 0.00001,
        "expected " .. expected .. ", got " .. tostring(actual))
end
local function flush()
    local callbacks = timers
    timers = {}
    for _, callback in ipairs(callbacks) do callback() end
end
local function setGCD(start, duration, rate)
    cooldown = { startTime = start, duration = duration, modRate = rate or 1 }
end
local function reset()
    unit:Clear()
    timers = {}
    baseGCDs = {}
    inCombat = false
    now = 10
    setGCD(0, 0)
    ns.settings.activeProfile.castTimingMode = "gcd"
    ns.settings.activeProfile.castTimingFont = ""
    ns.settings.activeProfile.castTimingFontSize = 0
    ns.settings.activeProfile.blocklist = {}
    unit.previousSpell = { id = 0, name = "" }
    unit.canceledSpell = { id = 0, castId = "", iconIndex = 0 }
end
local function cast(time, id, guid, start, duration, event)
    now = time
    if start then setGCD(start, duration) end
    local index = unit.iconQueue.iconIndex
    unit:OnSpellEvent(event or "UNIT_SPELLCAST_SUCCEEDED", id, "player", guid)
    return unit.iconQueue.icons[index]
end
local function test(name, callback)
    reset()
    callback()
    count = count + 1
    print("PASS " .. name)
end

test("1.2-second GCD, next cast at 1.5 seconds, label 0.3", function()
    local first = cast(10, 1, "a", 10, 1.2)
    equal(first.timing.gcdGap, nil)
    local second = cast(11.5, 2, "b", 11.5, 1.2)
    near(second.timing.gcdGap, 0.3)
    near(second.timing.elapsed, 1.5)
    second:Show()
    equal(second.timingText.text, "0.3")
    ns.settings.activeProfile.castTimingMode = "elapsed"
    second:UpdateTimingText()
    equal(second.timingText.text, "1.5")
    ns.settings.activeProfile.castTimingMode = "off"
    second:UpdateTimingText()
    equal(second.timingText.shown, false)
end)

test("haste and cooldown rate are measured per GCD", function()
    cast(10, 1, "a", 10, 1.5)
    local second = cast(11.5, 2, "b", 11.5, 0.75)
    near(second.timing.gcdGap, 0)
    local third = cast(12.35, 3, "c", 12.35, 1.5)
    near(third.timing.gcdGap, 0.1)
    cooldown.modRate = 2
    ns.castTiming:UpdateCooldown()
    local fourth = cast(13.2, 4, "d", 13.2, 1.5)
    near(fourth.timing.gcdGap, 0.1)
end)

test("off-GCD icons keep their appearance and cannot steal the next gap", function()
    cast(10, 1, "a", 10, 1.2)
    local offGCD = cast(11.1, 2, "off")
    equal(offGCD.timing.gcdGap, nil)
    local nextCast = cast(11.5, 3, "b", 11.5, 1.2)
    near(nextCast.timing.gcdGap, 0.3)
    equal(offGCD.timing.gcdGap, nil)
    near(nextCast.timing.elapsed, 0.4)
end)

test("an off-GCD event just before the next cast cannot steal its label", function()
    cast(10, 1, "a", 10, 1.2)
    local offGCD = cast(11.495, 2, "off")
    local nextCast = cast(11.5, 3, "b", 11.5, 1.2)
    near(nextCast.timing.gcdGap, 0.3)
    equal(offGCD.timing.gcdGap, nil)
end)

test("off-GCD and GCD abilities in the same frame attach the label correctly", function()
    cast(10, 1, "a", 10, 1.2)
    baseGCDs[2] = 0
    local offGCD = cast(11.5, 2, "off")
    local nextCast = cast(11.5, 3, "b", 11.5, 1.2)
    near(nextCast.timing.gcdGap, 0.3)
    equal(offGCD.timing.gcdGap, nil)
end)

test("supplementary spells sharing a cast GUID get no timing label", function()
    cast(10, 1, "a", 10, 1.2)
    local supplementary = cast(10.1, 2, "a")
    equal(supplementary.timing, nil)
    local nextCast = cast(11.5, 3, "b", 11.5, 1.2)
    near(nextCast.timing.elapsed, 1.5)
end)

test("start and success count once for a cast-time spell", function()
    cast(10, 1, "a", 10, 1.2, "UNIT_SPELLCAST_START")
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local nextCast = cast(12.1, 2, "b", 12.1, 1.2)
    near(nextCast.timing.elapsed, 2.1)
    near(nextCast.timing.gcdGap, 0.1)
end)

test("two-second casts with a 1.3-second GCD show zero when cast back to back", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local second = cast(12, 2, "b", 12, 1.3, "UNIT_SPELLCAST_START")
    near(second.timing.gcdGap, 0)
    near(second.timing.elapsed, 2)
    second:Show()
    equal(second.timingText.text, "0.0")
    now = 14
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 2, "player", "b")
    local third = cast(14, 3, "c", 14, 1.3)
    near(third.timing.gcdGap, 0)
end)

test("waiting 0.3 seconds after a long cast shows only the 0.3 seconds of idle time", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    now = 12.05
    ns.castTiming:OnSpellEvent("UNIT_SPELLCAST_STOP", 1, "a")
    local nextCast = cast(12.3, 2, "b", 12.3, 1.3)
    near(nextCast.timing.gcdGap, 0.3)
    near(nextCast.timing.elapsed, 2.3)
end)

test("a short cast still waits for the GCD to end", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 10.8
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local nextCast = cast(11.5, 2, "b", 11.5, 1.3)
    near(nextCast.timing.gcdGap, 0.2)
end)

test("off-GCD defensives during a long cast do not end that cast's busy interval", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    baseGCDs[2] = 0
    local defensive = cast(11.6, 2, "off")
    equal(defensive.timing.gcdGap, nil)
    equal(ns.castTiming.blockingCast.finish, nil)
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local nextCast = cast(12.2, 3, "b", 12.2, 1.3)
    near(nextCast.timing.gcdGap, 0.2)
end)

test("filtered long casts still prevent casting time from being counted as idle", function()
    ns.settings.activeProfile.blocklist = { 1 }
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local nextCast = cast(12.3, 2, "b", 12.3, 1.3)
    near(nextCast.timing.gcdGap, 0.3)
end)

test("cast pushback uses the observed finish instead of the original duration", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 13
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    local nextCast = cast(13.1, 2, "b", 13.1, 1.3)
    near(nextCast.timing.gcdGap, 0.1)
end)

test("cancelling after the GCD ends starts the idle interval at cancellation", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 11.6
    unit:OnSpellEvent("UNIT_SPELLCAST_STOP", 1, "player", "a")
    local nextCast = cast(11.8, 2, "b", 11.8, 1.3)
    near(nextCast.timing.gcdGap, 0.2)
end)

test("channels remain busy after their succeeded event until channel stop", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_CHANNEL_START")
    now = 10.05
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    equal(ns.castTiming.blockingCast.finish, nil)
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_CHANNEL_STOP", 1, "player", nil)
    local nextCast = cast(12.3, 2, "b", 12.3, 1.3)
    near(nextCast.timing.gcdGap, 0.3)
end)

test("empowered casts use their release/stop as the end of the busy interval", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_EMPOWER_START")
    now = 12
    unit:OnSpellEvent("UNIT_SPELLCAST_EMPOWER_STOP", 1, "player", "a")
    local nextCast = cast(12, 2, "b", 12, 1.3)
    near(nextCast.timing.gcdGap, 0)
end)

test("a queued new cast before the old stop event has no artificial gap", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    local second = cast(12, 2, "b", 12, 1.3, "UNIT_SPELLCAST_START")
    near(second.timing.gcdGap, 0)
    now = 12.05
    ns.castTiming:OnSpellEvent("UNIT_SPELLCAST_STOP", 1, "a")
    equal(ns.castTiming.blockingCast, second.timing.blockingCast)
    equal(ns.castTiming.blockingCast.finish, nil)
    now = 14
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 2, "player", "b")
    local third = cast(14.2, 3, "c", 14.2, 1.3)
    near(third.timing.gcdGap, 0.2)
end)

test("a cast followed by a channel under the same GUID remains busy until channel stop", function()
    cast(10, 1, "a", 10, 1.3, "UNIT_SPELLCAST_START")
    now = 11.5
    unit:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 1, "player", "a")
    cast(11.5, 1, "a", nil, nil, "UNIT_SPELLCAST_CHANNEL_START")
    equal(ns.castTiming.blockingCast.finish, nil)
    now = 14
    unit:OnSpellEvent("UNIT_SPELLCAST_CHANNEL_STOP", 1, "player", "a")
    local nextCast = cast(14.1, 2, "b", 14.1, 1.3)
    near(nextCast.timing.gcdGap, 0.1)
end)

test("blocklisted player actions still advance the reference", function()
    cast(10, 1, "a", 10, 1.2)
    ns.settings.activeProfile.blocklist = { 2 }
    local index = unit.iconQueue.iconIndex
    cast(11.5, 2, "b", 11.5, 1.2)
    equal(unit.iconQueue.iconIndex, index)
    local nextCast = cast(13, 3, "c", 13, 1.2)
    near(nextCast.timing.gcdGap, 0.3)
end)

test("cooldown data arriving after an icon is shown updates its label", function()
    cast(10, 1, "a", 10, 1.2)
    local nextCast = cast(11.5, 2, "b")
    nextCast:Show()
    equal(nextCast.timingText.shown, false)
    setGCD(11.5, 1.2)
    flush()
    unit.iconQueue:Update(now, 0.03, false)
    equal(nextCast.timingText.text, "0.3")
end)

test("cooldown event arriving before the cast keeps the previous GCD end", function()
    cast(10, 1, "a", 10, 1.2)
    now = 11.5
    setGCD(11.5, 1.2)
    ns.castTiming:UpdateCooldown()
    local nextCast = cast(11.5, 2, "b")
    near(nextCast.timing.gcdGap, 0.3)
end)

test("secret timestamps leave GCD gaps blank and elapsed mode works", function()
    cast(10, 1, "a", 10, 1.2)
    cooldown = { startTime = secret, duration = secret, modRate = secret }
    local second = cast(11.5, 2, "b")
    flush()
    equal(second.timing.gcdGap, nil)
    near(second.timing.elapsed, 1.5)
    local third = cast(13, 3, "c", 13, 1.2)
    equal(third.timing.gcdGap, nil, "no stale reference after restricted timing")
end)

test("supplementary successes without a GUID leave the reference alone", function()
    cast(10, 1, "a", 10, 1.2)
    local supplementary = cast(11, 2, nil)
    equal(supplementary.timing, nil)
    local nextCast = cast(11.5, 3, "b", 11.5, 1.2)
    near(nextCast.timing.elapsed, 1.5)
end)

test("channel success and start are one action even with a missing GUID", function()
    cast(10, 1, "a", 10, 1.2)
    local succeeded = cast(11.5, 2, "b", 11.5, 1.2)
    local channel = cast(11.5, 2, nil, nil, nil, "UNIT_SPELLCAST_CHANNEL_START")
    equal(channel.timing, succeeded.timing)
    now = 12
    ns.castTiming:OnSpellEvent("UNIT_SPELLCAST_SUCCEEDED", 2, "channel-tick")
    now = 13
    ns.castTiming:OnSpellEvent("UNIT_SPELLCAST_CHANNEL_STOP", 2)
    local nextCast = cast(13.1, 3, "c", 13.1, 1.2)
    near(nextCast.timing.elapsed, 1.6)
end)

test("interrupted cast GCD refunds use the observed end", function()
    cast(10, 1, "a", 10, 1.2, "UNIT_SPELLCAST_START")
    now = 10.4
    setGCD(0, 0)
    ns.castTiming:UpdateCooldown()
    unit:OnSpellEvent("UNIT_SPELLCAST_STOP", 1, "player", "a")
    local nextCast = cast(10.7, 2, "b", 10.7, 1.2)
    near(nextCast.timing.gcdGap, 0.3)
end)

test("queue reset and recycled icons have no stale number", function()
    cast(10, 1, "a", 10, 1.2)
    local second = cast(11.5, 2, "b", 11.5, 1.2)
    second:Show()
    equal(second.timingText.text, "0.3")
    second:SetSpell(3, 1003)
    equal(second.timingText.shown, false)
    unit:Clear()
    local first = cast(20, 4, "c", 20, 1.2)
    equal(first.timing.gcdGap, nil)
    equal(first.timing.elapsed, nil)
end)

test("profile display mode is saved, loaded, and validated", function()
    for _, mode in ipairs({ "off", "gcd", "elapsed" }) do
        local profile = ns.ProfileSettings:New({ castTimingMode = mode })
        equal(profile:GetSavedVariables().castTimingMode, mode)
        equal(ns.ProfileSettings:New(profile:GetSavedVariables()).castTimingMode, mode)
    end
    equal(ns.ProfileSettings:New({ castTimingMode = "invalid" }).castTimingMode, "gcd")
end)

test("legacy cooldown API uses the same calculation", function()
    local modern = C_Spell
    C_Spell = nil
    GetSpellCooldown = function() return cooldown.startTime, cooldown.duration, 1, cooldown.modRate end
    cast(10, 1, "a", 10, 1.2)
    local second = cast(11.5, 2, "b", 11.5, 1.2)
    near(second.timing.gcdGap, 0.3)
    C_Spell = modern
    GetSpellCooldown = nil
end)

test("disabled tracking cannot become the next session's reference", function()
    cast(10, 1, "a", 10, 1.2)
    ns.locationCheck = { isAddonEnabled = function() return false end }
    ns.castTiming:UpdateCooldown()
    equal(ns.castTiming.gcd, nil)
    ns.locationCheck = nil
    local nextCast = cast(20, 2, "b", 20, 1.2)
    equal(nextCast.timing.gcdGap, nil)
    equal(nextCast.timing.elapsed, nil)
end)

test("leaving combat resets elapsed to zero and preserves recorded icons and the GCD", function()
    ns.settings.activeProfile.castTimingMode = "elapsed"
    inCombat = true
    cast(10, 1, "a", 10, 1.2)
    local second = cast(11.5, 2, "b", 11.5, 1.2)
    local gcd = ns.castTiming.gcd
    now, inCombat = 12, false
    emit("PLAYER_REGEN_ENABLED")
    equal(ns.castTiming.lastCastTime, nil)
    equal(ns.castTiming.gcd, gcd)
    near(second.timing.elapsed, 1.5)
    local nextCast = cast(13, 3, "c", 13, 1.2)
    near(nextCast.timing.elapsed, 0)
    near(nextCast.timing.gcdGap, 0.3)
    nextCast:Show()
    equal(nextCast.timingText.text, "0.0")
end)

test("thirty seconds idle out of combat resets elapsed, including without an update frame", function()
    ns.settings.activeProfile.castTimingMode = "elapsed"
    cast(10, 1, "a", 10, 1.2)
    ns.castTiming:UpdateElapsed(39.99)
    equal(ns.castTiming.lastCastTime, 10)
    local nextCast = cast(40, 2, "b", 40, 1.2)
    near(nextCast.timing.elapsed, 0)
    local following = cast(41.5, 3, "c", 41.5, 1.2)
    near(following.timing.elapsed, 1.5)
    now = 71.5
    unit:Update(now, 0.03)
    equal(ns.castTiming.lastCastTime, nil, "the normal frame update also clears the reference")
end)

test("long pauses in combat do not reset elapsed mode", function()
    ns.settings.activeProfile.castTimingMode = "elapsed"
    inCombat = true
    emit("PLAYER_REGEN_DISABLED")
    cast(10, 1, "a", 10, 1.2)
    ns.castTiming:UpdateElapsed(90)
    local nextCast = cast(90, 2, "b", 90, 1.2)
    near(nextCast.timing.elapsed, 80)
end)

test("combat exit and out-of-combat inactivity do not change GCD mode", function()
    cast(10, 1, "a", 10, 1.2)
    emit("PLAYER_REGEN_ENABLED")
    ns.castTiming:UpdateElapsed(50)
    equal(ns.castTiming.lastCastTime, 10)
    local nextCast = cast(50, 2, "b", 50, 1.2)
    near(nextCast.timing.gcdGap, 38.8)
end)

test("font settings round-trip and invalid sizes use automatic sizing", function()
    local profile = ns.ProfileSettings:New({ castTimingFont = "Custom Font", castTimingFontSize = 18 })
    local restored = ns.ProfileSettings:New(profile:GetSavedVariables())
    equal(restored.castTimingFont, "Custom Font")
    equal(restored.castTimingFontSize, 18)
    for _, size in ipairs({ -1, 41, "large", 0 / 0 }) do
        equal(ns.ProfileSettings:New({ castTimingFontSize = size }).castTimingFontSize, 0)
    end
end)

test("no SharedMedia uses the game font and manual size survives resizing", function()
    equal(#ns.fonts:List(), 0)
    local icon = unit.iconQueue.icons[1]
    ns.settings.activeProfile.castTimingFont = "Missing Font"
    ns.settings.activeProfile.castTimingFontSize = 18
    icon:Resize()
    equal(icon.timingText.font, STANDARD_TEXT_FONT)
    equal(icon.timingText.fontSize, 18)
    local previous = ns.settings.activeProfile.layoutSettings.player.iconSize
    ns.settings.activeProfile.layoutSettings.player.iconSize = 60
    icon:Resize()
    equal(icon.timingText.fontSize, 18)
    ns.settings.activeProfile.castTimingFontSize = 0
    icon:Resize()
    equal(icon.timingText.fontSize, 16)
    ns.settings.activeProfile.layoutSettings.player.iconSize = previous
end)

local mediaCallbacks = {}
test("late SharedMedia loading and new font registrations refresh icons", function()
    sharedMedia = { fonts = { Alpha = "Fonts/alpha.ttf", Beta = "Fonts/beta.ttf" } }
    function sharedMedia:List(mediaType)
        equal(mediaType, "font")
        local names = {}
        for name in pairs(self.fonts) do names[#names + 1] = name end
        table.sort(names)
        return names
    end
    function sharedMedia:Fetch(mediaType, name, noDefault)
        equal(mediaType, "font")
        equal(noDefault, true)
        return self.fonts[name]
    end
    function sharedMedia.RegisterCallback(target, event, method)
        mediaCallbacks[event] = function(mediaType) target[method](target, event, mediaType) end
    end
    ns.settings.activeProfile.castTimingFont = "Late Font"
    ns.settings.activeProfile.castTimingFontSize = 20
    emit("ADDON_LOADED")
    local icon = unit.iconQueue.icons[1]
    equal(icon.timingText.font, STANDARD_TEXT_FONT)
    sharedMedia.fonts["Late Font"] = "Fonts/late.ttf"
    mediaCallbacks.LibSharedMedia_Registered("font")
    equal(icon.timingText.font, "Fonts/late.ttf")
    equal(icon.timingText.fontSize, 20)
    equal(#ns.fonts:List(), 3)
    sharedMedia.fonts["Late Font"] = "bad-font"
    mediaCallbacks.LibSharedMedia_Registered("font")
    equal(icon.timingText.font, STANDARD_TEXT_FONT, "invalid files also fall back")
    sharedMedia.fonts["Late Font"] = "Fonts/late.ttf"
end)

test("font picker lists all fonts, updates labels, and its size control persists", function()
    SlashCmdList = {}
    Settings = { RegisterCanvasLayoutCategory = function() return newWidget() end,
        RegisterAddOnCategory = function() end }
    function UIDropDownMenu_Initialize(frame, callback)
        frame.initialize = callback
        callback(frame)
    end
    function UIDropDownMenu_SetWidth() end
    function UIDropDownMenu_SetText(frame, text) frame.menuText = text end
    function UIDropDownMenu_CreateInfo() return {} end
    local legacyEntries = {}
    function UIDropDownMenu_AddButton(info) legacyEntries[#legacyEntries + 1] = info end
    function ToggleDropDownMenu(_, _, menu) legacyEntries = {}; menu.initialize() end
    local entries, scrollHeight = {}, nil
    MenuUtil = { CreateContextMenu = function(button, callback)
        entries = {}
        callback(button, {
            SetScrollMode = function(_, height) scrollHeight = height end,
            CreateRadio = function(_, label, checked, select, data)
                entries[#entries + 1] = { label = label, checked = checked, select = select, data = data }
            end,
        })
    end }
    ns.settings.Save = function() end
    loadModule("Modules/Frames/FrameUtils.lua")
    local file = assert(io.open("Modules/Frames/SettingsFrame.lua"))
    local source = file:read("*a")
    file:close()
    if _VERSION == "Lua 5.5" then
        source = source:gsub("for _, unit in pairs%(ns%.units%) do", "for unitIndex, unit in pairs(ns.units) do")
    end
    assert(compile(source, "@Modules/Frames/SettingsFrame.lua"))("TrufiGCD", ns)
    equal(type(ns.settingsFrame.syncWithSettings), "function", "settings file must finish loading before OnLoad")
    ns.settingsFrame.syncWithSettings()
    local button = TrGCDTimingFontButton
    equal(button.text, "Game default", "the font picker must have a label after startup")
    button.OnClick(button)
    equal(scrollHeight, 240)
    equal(#entries, #ns.fonts:List() + 1)
    equal(entries[1].label, "Game default")
    entries[2].select(entries[2].data)
    equal(ns.settings.activeProfile.castTimingFont, "Alpha")
    equal(unit.iconQueue.icons[1].timingText.font, "Fonts/alpha.ttf")
    TrGCDTimingFontSizeSlider:SetValue(24)
    equal(ns.settings.activeProfile.castTimingFontSize, 24)
    equal(unit.iconQueue.icons[1].timingText.fontSize, 24)
    equal(ns.settings.activeProfile:GetSavedVariables().castTimingFontSize, 24)
    MenuUtil = nil
    button.OnClick(button)
    equal(#legacyEntries, #ns.fonts:List() + 1)
end)

-- Check syntax and module existence for every client manifest without loading WoW UI.
local function checkManifest(toc)
    -- Master has one multi-client manifest; release packages also have split manifests.
    local manifest = io.open(toc)
    assert(manifest or toc ~= "TrufiGCD.toc", "main manifest must exist")
    if not manifest then return 0 end
    manifest:close()
    local foundTiming = false
    for line in io.lines(toc) do
        local path = line:match("^(.+%.lua)%s*$")
        if path then
            path = path:gsub("\\", "/")
            local file = assert(io.open(path))
            local source = file:read("*a")
            file:close()
            -- Lua 5.5 makes loop variables const. WoW's Lua 5.1 allows the existing
            -- anchor-saving code to use its unused loop index as a discard target.
            if _VERSION == "Lua 5.5" and path == "Modules/Frames/SettingsFrame.lua" then
                source = source:gsub("for _, unit in pairs%(ns%.units%) do", "for unitIndex, unit in pairs(ns.units) do")
            end
            assert(compile(source, "@" .. path))
            if path == "Modules/Core/CastTiming.lua" then foundTiming = true end
            if path == "Modules/Core/Units.lua" then assert(foundTiming, "timing module must load before units") end
        end
    end
    print("PASS syntax and load order: " .. toc)
    return 1
end
local manifestCount = 0
for _, toc in ipairs({ "TrufiGCD.toc", "TrufiGCD_Cata.toc", "TrufiGCD_Mists.toc", "TrufiGCD_TBC.toc", "TrufiGCD_Vanilla.toc" }) do
    manifestCount = manifestCount + checkManifest(toc)
end
print(count .. " behavior checks passed; " .. manifestCount .. " client manifests parsed (build " .. testBuild .. ").")
