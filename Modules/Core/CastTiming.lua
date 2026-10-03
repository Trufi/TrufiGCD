---@type string, Namespace
local _, ns = ...

local gcdSpellId = 61304
local eventWindow = 0.5
local idleResetSeconds = 30

---@class CastTimingSample
---@field time number
---@field spellId number
---@field elapsed? number
---@field gcdGap? number
---@field previousBlockingCast? BlockingCast
---@field blockingCast? BlockingCast

---@class BlockingCast
---@field spellId number
---@field castId? string
---@field kind "cast" | "channel"
---@field finish? number

---Player timing is independent of the icon queue and its animation speed.
---@class CastTiming
local castTiming = {}
ns.castTiming = castTiming

function castTiming:Reset()
    self.recentCasts = {}
    self.pending = {}
    self.lastCastTime = nil
    self.gcd = nil
    self.channel = nil
    self.blockingCast = nil
    self.lastSample = nil
    self.elapsedReset = false
    self.outOfCombatSince = nil
end

-- Reset only the elapsed reference, preserving the GCD and already recorded icons.
function castTiming:ResetElapsed()
    self.lastCastTime = nil
    self.elapsedReset = true
end

function castTiming:UpdateElapsed(time)
    if ns.settings.activeProfile.castTimingMode ~= "elapsed" then return end
    if UnitAffectingCombat("player") then
        self.outOfCombatSince = nil
        return
    end
    self.outOfCombatSince = self.outOfCombatSince or time
    if self.lastCastTime and not self.channel
        and time - math.max(self.lastCastTime, self.outOfCombatSince) >= idleResetSeconds then
        self:ResetElapsed()
    end
end

local function isReadable(value)
    return not issecretvalue or not issecretvalue(value)
end

local function canTriggerGCD(spellId)
    if GetSpellBaseCooldown then
        local _, baseGCD = GetSpellBaseCooldown(spellId)
        -- Only classify the spell here; the actual timing always comes from 61304.
        -- This prevents an off-GCD action in the same macro/frame claiming a GCD.
        if isReadable(baseGCD) and type(baseGCD) == "number" then return baseGCD > 0 end
    end
    return true
end

local function readGCD()
    local start, duration, enabled, rate
    if C_Spell and C_Spell.GetSpellCooldown then
        local info = C_Spell.GetSpellCooldown(gcdSpellId)
        if not info then return end
        start, duration, rate = info.startTime, info.duration, info.modRate
    elseif GetSpellCooldown then
        start, duration, enabled, rate = GetSpellCooldown(gcdSpellId)
    else
        return
    end

    -- Midnight can hide cooldown timestamps. Never compare or calculate with them.
    if not isReadable(start) or not isReadable(duration) or not isReadable(rate) then return end
    if type(start) ~= "number" or type(duration) ~= "number" then return end
    rate = type(rate) == "number" and rate > 0 and rate or 1
    return start, start + duration / rate, duration > 0
end

local function updateGap(gcd, sample)
    if not gcd.previousEnd then return end
    local readyTime = gcd.previousEnd
    local previousCast = sample.previousBlockingCast
    if previousCast then
        -- A cast/channel can occupy the player after its GCD has already ended.
        -- If its stop event has not arrived yet, an overlapping next cast has no idle gap.
        readyTime = math.max(readyTime, previousCast.finish or gcd.start)
    end
    sample.gcdGap = math.max(0, gcd.start - readyTime)
end

function castTiming:FinishBlockingCast(record, time)
    if not record.finish then record.finish = time end
    if self.channel and self.channel.blockingCast == record then self.channel = nil end
    -- Stop/success events can arrive after the next GCD was captured.
    if self.gcd and self.gcd.sample then updateGap(self.gcd, self.gcd.sample) end
end

function castTiming:UpdateCooldown()
    if ns.locationCheck and not ns.locationCheck.isAddonEnabled() then
        self:Reset()
        return
    end
    local now = GetTime()
    local start, finish, active = readGCD()
    if not start then
        -- Do not reuse an old readable cooldown across a restricted interval.
        self.gcd = nil
        self.pending = {}
        return
    end

    if active and start > 0 then
        if not self.gcd or self.gcd.start ~= start then
            self.gcd = {
                start = start,
                finish = finish,
                previousEnd = self.gcd and self.gcd.finish,
                claimed = false,
            }
        else
            self.gcd.finish = finish
        end
    elseif self.gcd and now < self.gcd.finish then
        -- Interrupted casts can refund the remaining GCD.
        self.gcd.finish = now
    end

    for i = #self.pending, 1, -1 do
        if now - self.pending[i].time > eventWindow then
            table.remove(self.pending, i)
        end
    end

    if not active or not self.gcd or self.gcd.claimed then return end
    local bestIndex, bestDistance
    for i, sample in ipairs(self.pending) do
        -- An off-GCD action earlier in the previous cooldown cannot claim this one.
        if sample.time >= start - 0.01 and sample.time - start <= eventWindow then
            local distance = math.abs(sample.time - start)
            if not bestDistance or distance < bestDistance then
                bestIndex, bestDistance = i, distance
            end
        end
    end
    if bestIndex then
        local sample = table.remove(self.pending, bestIndex)
        updateGap(self.gcd, sample)
        self.gcd.sample = sample
        self.gcd.claimed = true
    end
end

---@param event string
---@param spellId number
---@param castId? string
---@return CastTimingSample | nil
function castTiming:OnSpellEvent(event, spellId, castId)
    if not isReadable(spellId) or not isReadable(castId) then return end

    local now = GetTime()
    local sample = castId and self.recentCasts[castId]
    local channelStart = event == "UNIT_SPELLCAST_CHANNEL_START" or event == "UNIT_SPELLCAST_EMPOWER_START"
    local channelStop = event == "UNIT_SPELLCAST_CHANNEL_STOP" or event == "UNIT_SPELLCAST_EMPOWER_STOP"
    if event == "UNIT_SPELLCAST_STOP" or channelStop then
        local record = sample and sample.blockingCast
        if not record and channelStop and self.channel and self.channel.spellId == spellId then
            record = self.channel.blockingCast
        end
        if record and record.spellId == spellId
            and ((channelStop and record.kind == "channel") or (not channelStop and record.kind == "cast")) then
            self:FinishBlockingCast(record, now)
        end
        return
    end
    if event ~= "UNIT_SPELLCAST_START" and event ~= "UNIT_SPELLCAST_SUCCEEDED" and not channelStart then
        return
    end
    -- Supplementary successes without a cast GUID are not a new player action.
    if not castId and not channelStart then return end
    if sample and sample.spellId ~= spellId then return end
    if event == "UNIT_SPELLCAST_SUCCEEDED" and sample and sample.blockingCast
        and sample.blockingCast.kind == "cast" then
        self:FinishBlockingCast(sample.blockingCast, now)
    end
    if event == "UNIT_SPELLCAST_SUCCEEDED" and self.channel and self.channel.spellId == spellId then
        return
    end

    for id, sample in pairs(self.recentCasts) do
        if now - sample.time > 60 then self.recentCasts[id] = nil end
    end

    -- Some clients omit the channel GUID; SUCCEEDED may precede CHANNEL_START.
    if not sample and channelStart and self.lastSample and self.lastSample.spellId == spellId
        and now - self.lastSample.time < 0.1 then
        sample = self.lastSample
    end
    if not sample then
        self:UpdateElapsed(now)
        sample = {
            time = now,
            spellId = spellId,
            previousBlockingCast = self.blockingCast,
            elapsed = self.lastCastTime and math.max(0, now - self.lastCastTime)
                or (self.elapsedReset and 0 or nil),
        }
        self.lastCastTime = now
        self.lastSample = sample
        self.elapsedReset = false
        if canTriggerGCD(spellId) then table.insert(self.pending, sample) end
    end
    if castId then self.recentCasts[castId] = sample end
    if event == "UNIT_SPELLCAST_START" or channelStart then
        if not sample.blockingCast then
            -- A queued next cast can start before the previous stop event is delivered.
            if self.blockingCast and not self.blockingCast.finish then
                self:FinishBlockingCast(self.blockingCast, now)
            end
            sample.blockingCast = {
                spellId = spellId,
                castId = castId,
                kind = channelStart and "channel" or "cast",
            }
        elseif channelStart and sample.blockingCast.kind == "cast" then
            -- Some spells have a cast phase followed by a channel under the same GUID.
            sample.blockingCast.kind = "channel"
            sample.blockingCast.finish = nil
        end
        self.blockingCast = sample.blockingCast
    end
    if channelStart then self.channel = sample end

    self:UpdateCooldown()
    -- Cooldown data can arrive after the cast event, even for instant spells.
    C_Timer.After(0, function() self:UpdateCooldown() end)
    return sample
end

castTiming:Reset()
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("SPELL_UPDATE_COOLDOWN")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:SetScript("OnEvent", function(_, event)
    if event == "PLAYER_ENTERING_WORLD" then
        castTiming:Reset()
    elseif event == "PLAYER_REGEN_ENABLED" then
        castTiming.outOfCombatSince = GetTime()
        if ns.settings.activeProfile.castTimingMode == "elapsed" then castTiming:ResetElapsed() end
    elseif event == "PLAYER_REGEN_DISABLED" then
        castTiming.outOfCombatSince = nil
    else
        -- Let the associated cast event arrive before assigning the new GCD.
        C_Timer.After(0, function() castTiming:UpdateCooldown() end)
    end
end)
