-- TrufiGCD stevemyz@gmail.com

---@type string, Namespace
local _, ns = ...

local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

---Icons queue for each unit:
---1 - player, 2 - party1, 3 - party2
---5 - arena1, 6 - arena2, 7 - arena3
---11 - target, 12 - focus
---@type { [number]: IconQueue }
TrGCDQueueFr = {}

TrGCDCastSp = {} -- 0 - каст идет, 1 - каст прошел и не идет
TrGCDCastSpBanTime = {} --время остановки каста

local trinket = "Interface\\Icons\\inv_jewelry_trinketpvp_01"
TrGCDInsSp = {}
TrGCDInsSp["spell"] = {}
TrGCDInsSp["time"] = {}
TrGCDSpStop = {} -- номер иконки у которой стопнулся каст спелла
TrGCDSpStopTime = {} -- номер иконки у которой стопнулся каст спелла
TrGCDSpStopName = {}
local TrGCDEnable = true
local PlayerDislocation = 0 -- Расположение игрока: 1 - Мир, 2 - ПвЕ, 3 - Арена, 4 - Бг.
TrGCDIconOnEnter = {} -- false - курсор на иконке
TrGCDTimeuseSpamSpell = {} -- время когда использовался спамящий в очередь спелл N -> SpellID -> Time

--Masque
local Masque = LibStub("Masque", true)
if Masque then
	TrGCDMasqueIcons = Masque:Group("TrufiGCD", "All Icons")
end

local TrGCDLoadFrame = CreateFrame("Frame", nil, UIParent)
TrGCDLoadFrame:RegisterEvent("ADDON_LOADED")
TrGCDLoadFrame:SetScript("OnEvent", TrufiGCDAddonLoaded)
function TrufiGCDAddonLoaded(self, event, ...)
	local arg1 = ...;
	if (arg1 == "TrufiGCD" and event == "ADDON_LOADED") then
		for i = 1, 12 do
			TrGCDQueueFr[i] = ns.IconQueue:New(i)
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
		TrGCDEventFrame = CreateFrame("Frame", nil, UIParent)
		TrGCDEventFrame:RegisterEvent("UNIT_SPELLCAST_START")
		TrGCDEventFrame:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
		TrGCDEventFrame:RegisterEvent("UNIT_SPELLCAST_STOP")
		TrGCDEventFrame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP")
		TrGCDEventFrame:SetScript("OnEvent", TrGCDEventHandler)
		TrGCDEventBuffFrame = CreateFrame("Frame", nil, UIParent)
		TrGCDEventBuffFrame:RegisterEvent("UNIT_AURA")
		TrGCDEventBuffFrame:SetScript("OnEvent", TrGCDEventBuffHandler)

		for i=1,12 do
			--if (TrGCDQueueOpt[i].enable) then
				TrGCDSpStop[i] = 0
				TrGCDSpStopTime[i] = GetTime()
				TrGCDCastSpBanTime[i] = GetTime()
				TrGCDInsSp["time"][i] = GetTime()
				TrGCDIconOnEnter[i] = true
				TrGCDTimeuseSpamSpell[i] = {}
				TrGCDCastSp[i] = 1 -- 0 - каст идет, 1 - каст прошел и не идет
			--end
		end
		TrGCDEventFrame:SetScript("OnUpdate", TrGCDUpdate)
	end
end
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
			for i=1,12 do TrGCDClear(i) end
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
		TrGCDClear(11)
		if ns.settings.unitSettings[11].enable then
			TrGCDPlayerTarFocDetect(11)
		end
	elseif event == "PLAYER_FOCUS_CHANGED" then
		TrGCDClear(12)
		if ns.settings.unitSettings[12].enable then
			TrGCDPlayerTarFocDetect(12)
		end
	end
end
function TrGCDClear(i)
	TrGCDCastSp[i] = 1
	TrGCDQueueFr[i]:Clear()
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
		TrGCDCastSp[k] = TrGCDCastSp[i]
		TrGCDCastSpBanTime[k] = TrGCDCastSpBanTime[i]
		TrGCDQueueFr[k]:Copy(TrGCDQueueFr[i])
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
--48108 - Огненная глыба!
--34936 - Ответный удар
--93400 - Падающие звезды
--69369 - Стремительность хищника
--81292 - Cимвол пронзания разума
--87160 - Наступление тьмы
--114255 - Пробуждение света
--124430 - Божественная мудрость
function TrGCDEventBuffHandler(self,event, ...) --запущена эвентом изменения баффов/дебаффов персонажа
	if (TrGCDEnable) then
		local who = ... ;
		local i,t = TrGCDPlayerDetect(who)
		local tt = true
		if (t) then
			for k=1,16 do
				local k = select(11,UnitBuff(who, k))
				if (k == 48108) then TrGCDInsSp["spell"][i] = 48108 tt = false
				elseif (k == 34936) then TrGCDInsSp["spell"][i] = 34936 tt = false
				elseif (k == 93400) then TrGCDInsSp["spell"][i] = 93400 tt = false
				elseif (k == 69369) then TrGCDInsSp["spell"][i] = 69369 tt = false
				elseif (k == 81292) then TrGCDInsSp["spell"][i] = 81292 tt = false
				elseif (k == 87160) then TrGCDInsSp["spell"][i] = 87160 tt = false
				elseif (k == 114255) then TrGCDInsSp["spell"][i] = 114255 tt = false
				elseif (k == 124430) then TrGCDInsSp["spell"][i] = 124430 tt = false end
			end
			if (((GetTime()-TrGCDInsSp["time"][i]) <0.1) and (tt)) then TrGCDInsSp["spell"][i] = 0 end
		end
	end
end

function TrGCDUnitChannelInfo(unit)
	if not isClassic then
	  return UnitChannelInfo(unit)
	elseif UnitIsUnit(unit, "player") then
	  return ChannelInfo()
	else
	  return nil
	end
end

function TrGCDEventHandler(self, event, who, _, spellId)
	local TrGCDBL = ns.settings.blocklist
	local InnerBL = ns.innerBlockList
	local spellicon = select(3, GetSpellInfo(spellId))
	local casttime = select(4, GetSpellInfo(spellId)) / 1000
	local spellname = GetSpellInfo(spellId)
	local i,t = TrGCDPlayerDetect(who) -- i - номер пользователя, t = true - если кто то из пати или на арене
	if TrGCDEnable and t and ns.settings.unitSettings[i].enable then
		--print(spellId .. " - " .. spellname)
		local blt = true -- для открытого черного списка
		local sblt = true -- для закрытого черного списка (внутри по ID)
		TrGCDInsSp["time"][i] = GetTime()
		for l=1, #TrGCDBL do if ((TrGCDBL[l] == spellname) or (TrGCDBL[l] == spellId)) then blt = false end end -- проверка на черный список
		for l=1, #InnerBL do if (InnerBL[l] == spellId) then sblt = false end end -- проверка на закрытый черный список
		if ((spellicon ~= nil) and t and blt and sblt and (GetSpellLink(spellId) ~= nil)) then
			if (spellId == 42292) then spellicon = trinket end --замена текстуры пвп тринкета
			local IsChannel = TrGCDUnitChannelInfo(who) -- check for channeling spell
			if (event == "UNIT_SPELLCAST_START") then
				--print("cast " .. spellname)
				TrGCDQueueFr[i]:AddSpell(spellId, spellicon)
				TrGCDCastSp[i] = 0-- 0 - каст идет, 1 - каст прошел и не идет
				TrGCDCastSpBanTime[i] = GetTime()

			elseif (event == "UNIT_SPELLCAST_SUCCEEDED") then
				if (TrGCDCastSp[i] == 0) then
					-- print("succeeded then " .. spellname .. ", is channeling: " .. IsChannel)
					if (IsChannel) then
						TrGCDQueueFr[i]:AddSpell(spellId, spellicon)
					else
						-- show instant spells while channeling, e.g. for monk mist spells
						TrGCDCastSp[i] = 1
					end
				else
					local b = false --висит ли багнутый бафф инстант каста
					if ((TrGCDInsSp["spell"][i] == 48108) and (spellId == 11366)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 48108) and (spellId == 2120)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 34936) and (spellId == 29722)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 93400) and (spellId == 78674)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 69369) and ((spellId == 339) or (spellId == 33786) or (spellId == 5185) or (spellId == 2637) or (spellId == 20484)))then b = true
					elseif ((TrGCDInsSp["spell"][i] == 81292) and (spellId == 8092)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 87160) and (spellId == 73510)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 114255) and (spellId == 2061)) then b = true
					elseif ((TrGCDInsSp["spell"][i] == 124430) and (spellId == 8092)) then b = true end
					TrGCDCastSpBanTime[i] = GetTime()
					if (IsChannel ~= nil) then TrGCDCastSp[i] = 0 end
					if (((GetTime()-TrGCDSpStopTime[i]) < 1) and (TrGCDSpStopName[i] == spellname) and (b == false)) then
						TrGCDQueueFr[i]:HideCancel(TrGCDSpStop[i])
					end
					if casttime <= 0 or b then
						TrGCDQueueFr[i]:AddSpell(spellId, spellicon)
					end
					--print("succeeded " .. spellname .. " - " ..TrGCDCastSp[i])
				end
			elseif ((event == "UNIT_SPELLCAST_STOP") and (TrGCDCastSp[i] == 0)) then
				-- print("stop " .. spellname)
				TrGCDCastSp[i] = 1

				local canceledIconIndex = TrGCDQueueFr[i]:ShowCancel()
				TrGCDSpStop[i] = canceledIconIndex
				TrGCDSpStopName[i] = spellname
				TrGCDSpStopTime[i] = GetTime()
			elseif (event == "UNIT_SPELLCAST_CHANNEL_STOP") then
				TrGCDCastSp[i] = 1
				--print("channel stop " .. spellname .. " - " .. TrGCDCastSp[i])
			end
		end
	end
end

local lastUpdateTime = GetTime()
local minUpdateInterval = 0.03

function TrGCDUpdate(self)
	local time = GetTime()
	local interval = time - lastUpdateTime

	if interval > minUpdateInterval then
		for unitIndex = 1, 12 do
			if TrGCDIconOnEnter[unitIndex] then
				if time - TrGCDCastSpBanTime[unitIndex] > 10 then
					TrGCDCastSp[unitIndex] = 1
				end

				TrGCDQueueFr[unitIndex]:Update(interval, TrGCDCastSp[unitIndex] == 0)
			end
		end

		lastUpdateTime = time
	end
end
