-- TrufiGCD stevemyz@gmail.com

---@type string, Namespace
local _, ns = ...

local TrGCDEnable = true
local PlayerDislocation = 0 -- Расположение игрока: 1 - Мир, 2 - ПвЕ, 3 - Арена, 4 - Бг.
TrGCDIconOnEnter = {} -- false - курсор на иконке
for i = 1, 12 do
	TrGCDIconOnEnter[i] = true
end

--Masque
local Masque = LibStub("Masque", true)
if Masque then
	TrGCDMasqueIcons = Masque:Group("TrufiGCD", "All Icons")
end

local lastUpdateTime = GetTime()
local minUpdateInterval = 0.03

local loadFrame = CreateFrame("Frame", nil, UIParent)
loadFrame:RegisterEvent("ADDON_LOADED")
loadFrame:SetScript("OnEvent", function(_, event, name)
	if name ~= "TrufiGCD" or event ~= "ADDON_LOADED" then
		return
	end

	ns.settings:LoadFromCharacterSavedVariables()
	ns.settingsFrame.syncWithSettings()

	ns.settings:LoadBlocklistFromCharacterSavedVariables()
	ns.blocklistFrame:syncWithSettings()

	TrGCDCheckToEnableAddon()

	-- Creating event enter arena/bg event frame
	TrGCDEnterEventFrame = CreateFrame("Frame", nil, UIParent)
	TrGCDEnterEventFrame:RegisterEvent("PLAYER_ENTERING_BATTLEGROUND")
	TrGCDEnterEventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	TrGCDEnterEventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	TrGCDEnterEventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
	TrGCDEnterEventFrame:RegisterEvent('PLAYER_TARGET_CHANGED')
	TrGCDEnterEventFrame:RegisterEvent('PLAYER_FOCUS_CHANGED')
	TrGCDEnterEventFrame:SetScript("OnEvent", TrGCDEnterEventHandler)

	-- Creating event spell frame
	local eventFrame = CreateFrame("Frame", nil, UIParent)
	eventFrame:RegisterEvent("UNIT_SPELLCAST_START")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
	eventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
	eventFrame:RegisterEvent("UNIT_AURA")

	eventFrame:SetScript("OnEvent", function(_, unitEvent, unitId, _, spellId)
		local unitIndex, isTrackedUnit = TrGCDPlayerDetect(unitId)
		if isTrackedUnit and TrGCDEnable then
			ns.units[unitIndex]:OnEvent(unitEvent, spellId, unitId)
		end
	end)

	eventFrame:SetScript("OnUpdate", function()
		local time = GetTime()
		local interval = time - lastUpdateTime
		if interval > minUpdateInterval then
			for unitIndex = 1, 12 do
				ns.units[unitIndex]:Update(time, interval)
			end
			lastUpdateTime = time
		end
	end)
end)

function TrGCDCheckToEnableAddon(t) -- проверяет галки EnableIn и от этого уже включен ли аддон
	if ns.settings.enabledIn.enabled == false or ns.settings.enabledIn.combatOnly then TrGCDEnable = false
	elseif PlayerDislocation == 1 then TrGCDEnable = ns.settings.enabledIn.world
	elseif PlayerDislocation == 2 then TrGCDEnable = ns.settings.enabledIn.party
	elseif PlayerDislocation == 3 then TrGCDEnable = ns.settings.enabledIn.arena
	elseif PlayerDislocation == 4 then TrGCDEnable = ns.settings.enabledIn.battleground
	elseif PlayerDislocation == 5 then TrGCDEnable = ns.settings.enabledIn.raid
	end
	if (t ~= nil) then
		if ((PlayerDislocation == t) or (t == 0) or (t == 6)) then
			for i = 1, 12 do
				ns.units[i]:Clear()
			end
		end
	end
end
function TrGCDEnterEventHandler(self, event, ...) -- эвент, когда игрок заходит на бг, арену, пве, или наоборот выходит
	local _, PlayerLocation = IsInInstance()
	local enabledIn = ns.settings.enabledIn

	if event == "PLAYER_REGEN_DISABLED" and enabledIn.combatOnly then -- Entering combat, specific for each zone
		if (PlayerLocation == "arena") then
			PlayerDislocation = 3
			TrGCDEnable = enabledIn.arena
		elseif (PlayerLocation == "pvp") then
			PlayerDislocation = 4
			TrGCDEnable = enabledIn.battleground
		elseif (PlayerLocation == "party") then
			PlayerDislocation = 2
			TrGCDEnable = enabledIn.party
		elseif (PlayerLocation == "raid") then
			PlayerDislocation = 5
			TrGCDEnable = enabledIn.raid
		elseif ((PlayerLocation ~= "arena") or (PlayerLocation ~= "pvp")) then
			PlayerDislocation = 1
			TrGCDEnable = enabledIn.world
		end
	elseif event == "PLAYER_REGEN_ENABLED" and enabledIn.combatOnly then -- Ending combat
		TrGCDEnable = false
	elseif event == "PLAYER_ENTERING_BATTLEGROUND" and not enabledIn.combatOnly then -- if not Combat only, try to load at locations
		if (PlayerLocation == "arena") then
			PlayerDislocation = 3
			TrGCDEnable = enabledIn.arena
		elseif (PlayerLocation == "pvp") then
			PlayerDislocation = 4
			TrGCDEnable = enabledIn.battleground
		end
	elseif event == "PLAYER_ENTERING_WORLD" and not enabledIn.combatOnly then -- if not Combat only, try to load at locations
		if (PlayerLocation == "party") then
			PlayerDislocation = 2
			TrGCDEnable = enabledIn.party
		elseif (PlayerLocation == "raid") then
			PlayerDislocation = 5
			TrGCDEnable = enabledIn.raid
		elseif ((PlayerLocation ~= "arena") or (PlayerLocation ~= "pvp")) then
			PlayerDislocation = 1
			TrGCDEnable = enabledIn.world
		end
			elseif (event == "PLAYER_ENTERING_BATTLEGROUND") and enabledIn.combatOnly then -- if Combat only and just loaded in location
		if (PlayerLocation == "arena") then
			PlayerDislocation = 3
			if enabledIn.arena then TrGCDEnable = false end
		elseif (PlayerLocation == "pvp") then
			PlayerDislocation = 4
			if enabledIn.battleground then TrGCDEnable = false end
		end
	elseif event == "PLAYER_ENTERING_WORLD" and enabledIn.combatOnly then -- if Combat only and just loaded in location
		if (PlayerLocation == "party") then
			PlayerDislocation = 2
			if enabledIn.party then TrGCDEnable = false end
		elseif (PlayerLocation == "raid") then
			PlayerDislocation = 5
			if enabledIn.raid then TrGCDEnable = false end
		elseif ((PlayerLocation ~= "arena") or (PlayerLocation ~= "pvp")) then
			PlayerDislocation = 1
			if enabledIn.world then TrGCDEnable = false end
		end
	elseif event == "PLAYER_TARGET_CHANGED" then
		ns.units[11]:Clear()
		if ns.settings.unitSettings[11].enable then
			TrGCDPlayerTarFocDetect(11)
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		ns.units[12]:Clear()
		if ns.settings.unitSettings[12].enable then
			TrGCDPlayerTarFocDetect(12)
		end
	end
end

local function TrGCDCheckForEual(a,b) -- проверка эквивалентности юнитов - имя, хп
	local t = false
	if ((UnitName(a) == UnitName(b)) and (UnitName(a)~= nil) and (UnitName(b) ~= nil)) then
		if (UnitHealth(a) == UnitHealth(b)) then t = true end
	end
	return t
end
function TrGCDPlayerTarFocDetect(k) -- чек есть ли цель или фокус уже во фреймах (пати или арена)
	--k = 11 - target, 12 - focus
	local t = "null"
	local i = 0
	if (k == 11) then t = "target" end
	if (k == 12) then t = "focus" end
	if (TrGCDCheckForEual(t,"player")) then i = 1 end
	for j=2,5 do if (TrGCDCheckForEual(t,("party"..j-1))) then i = j end end
	for j=6,10 do if (TrGCDCheckForEual(t,("arena"..j-5))) then i = j end end
	if ((k ~= 11) and TrGCDCheckForEual(t,"target")) then i = 11 end
	if ((k~= 12) and TrGCDCheckForEual(t,"focus")) then i = 12 end
	if (i ~= 0) then -- если есть то копипаст всей очереди
		ns.units[k]:Copy(ns.units[i])
	end
end

function TrGCDPlayerDetect(who) --Определим игрока отправившего спелл
	local t = false --true - если ивент запустил кто-то в пати или на арене
	local i = 0
	if (who == "player") then i = 1 t = true return i,t end
	for j=2,5 do if (who == ("party"..j-1)) then i = j t = true return i,t end end
	for j=6,10 do if (who == ("arena"..j-5)) then i = j t = true return i,t end end
	if (who == "target") then i = 11 t = true return i,t end
	if (who == "focus") then i = 12 t = true end
	return i, t
end
