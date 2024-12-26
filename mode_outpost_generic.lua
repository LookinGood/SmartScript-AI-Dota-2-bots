---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

-- unit:GetUnitName() == "npc_dota_watch_tower" -- не работает
--if string.find(unit:GetUnitName(), "watch_tower") and not unit:HasModifier("modifier_invulnerable")
-- npcBot:ActionImmediate_Chat(unit:GetUnitName(), true);
-- print(unit:GetUnitName())

local function GetClosestAvailableOutpost()
	local closestUnit = nil;
	local distance = 100000;
	local unitsList = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if (unit:GetUnitName() == "#DOTA_OutpostName_South" or
					unit:GetUnitName() == "#DOTA_OutpostName_North")
				and not unit:IsInvulnerable()
			--and npcBot:GetTeam() ~= unit:GetTeam()
			--and unit:CanBeSeen()
			then
				local unitDistance = GetUnitToUnitDistance(npcBot, unit);
				if unitDistance < distance
				then
					closestUnit = unit;
					distance = unitDistance;
					break;
					--npcBot:ActionImmediate_Ping(outpost:GetLocation().x, outpost:GetLocation().y, true);
				end
			end
		end
	end

	return closestUnit, distance;
end

-- npc_dota_mango_tree -- Имя бассейна с лотусами

local function GetClosestAvailableLotusPool()
	-- У ботов нет команды для активации бассейна с лотусами, пока выключил функцию до лучших времён.
	-- or GetGameState() == GAME_STATE_GAME_IN_PROGRESS
	if GetGameState() == GAME_STATE_PRE_GAME
	then
		return nil, nil;
	end

	local closestUnit = nil;
	local distance = 100000;
	local unitsList = GetUnitList(UNIT_LIST_ALL);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if string.find(unit:GetUnitName(), "mango_tree") and unit:HasModifier("modifier_passive_mango_tree")
			then
				--print(unit:GetUnitName())
				local unitDistance = GetUnitToUnitDistance(npcBot, unit);
				if unitDistance < distance
				then
					closestUnit = unit;
					distance = unitDistance;
					break;
				end
			end
		end
	end

	return closestUnit, distance;
end

local function GetClosestAvailableWatcher()
	-- У ботов нет команды для активации Смотрителей, пока выключил функцию до лучших времён.
	-- or GetGameState() == GAME_STATE_GAME_IN_PROGRESS
	if GetGameState() == GAME_STATE_PRE_GAME
	then
		return nil, nil;
	end

	local closestUnit = nil;
	local distance = 100000;
	local unitsList = GetUnitList(UNIT_LIST_ALL);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if string.find(unit:GetUnitName(), "lantern") and not unit:HasModifier("modifier_lamp_on") and not unit:HasModifier("modifier_lamp_off")
			then
				--print(unit:GetUnitName())
				local unitDistance = GetUnitToUnitDistance(npcBot, unit);
				if unitDistance < distance
				then
					closestUnit = unit;
					distance = unitDistance;
					break;
				end
			end
		end
	end

	return closestUnit, distance;
end

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsClone(npcBot) or (#enemyHeroes > 0) or utility.IsBaseUnderAttack()
		or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") or
		string.find(npcBot:GetUnitName(), "npc_dota_lone_druid_bear")
	then
		return BOT_MODE_DESIRE_NONE;
	end

	--closestWatcher, watcherDistance = GetClosestAvailableWatcher()
	--closestLotusPull, lotusPoolDistance = GetClosestAvailableLotusPool();
	closestOutpost, outpostDistance = GetClosestAvailableOutpost();

	--[[ 	local randomBot = utility.GetRandomBotPlayer();
	if npcBot == randomBot
	then
		utility.GetUnitInfo(closestOutpost);
	end
 ]]
	if outpostDistance <= 3000
	then
		--npcBot:ActionImmediate_Chat("Рядом есть доступный для захвата аванпост.", true);
		if closestOutpost:HasModifier("modifier_watch_tower_capturing")
		then
			return BOT_MODE_DESIRE_VERYHIGH;
		else
			return BOT_MODE_DESIRE_HIGH;
		end
	end

--[[ 	if lotusPoolDistance <= 4000
	then
		npcBot:ActionImmediate_Chat("Рядом есть доступный бассейн с лотусами!", true);
		return BOT_MODE_DESIRE_VERYHIGH;
	end

	if watcherDistance <= 3000
	then
		npcBot:ActionImmediate_Chat("Рядом есть доступный смотритель!", true);
		return BOT_MODE_DESIRE_VERYHIGH;
	end ]]

	return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
	if RollPercentage(5)
	then
		npcBot:ActionImmediate_Chat("Иду захватывать аванпост.", false);
		npcBot:ActionImmediate_Ping(closestOutpost:GetLocation().x, closestOutpost:GetLocation().y, true);
	end
end

function OnEnd()
	npcBot:SetTarget(nil);
end

function Think()
	local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	if utility.IsBusy(npcBot) and (#enemyHeroes > 0 or npcBot:WasRecentlyDamagedByAnyHero(2.0))
	then
		npcBot:Action_ClearActions(true);
		return;
	end

	local captureRange = 300

--[[ 	if closestWatcher ~= nil
	then
		if GetUnitToUnitDistance(npcBot, closestWatcher) > captureRange
		then
			npcBot:ActionImmediate_Chat("Иду захватывать смотрителя!", true);
			npcBot:Action_MoveToLocation(closestWatcher:GetLocation());
			return;
		else
			npcBot:ActionImmediate_Chat("Захватываю смотрителя!", true);
			--npcBot:Action_AttackUnit(closestWatcher, false);
			npcBot:Action_MoveDirectly(closestWatcher:GetLocation() + RandomVector(50));
			return;
		end
	end ]]

--[[ 	if closestLotusPull ~= nil
	then
		if GetUnitToUnitDistance(npcBot, closestLotusPull) > 600
		then
			npcBot:ActionImmediate_Chat("Иду захватывать бассейн с лотусами!", true);
			npcBot:Action_MoveToLocation(closestLotusPull:GetLocation());
			return;
		else
			npcBot:ActionImmediate_Chat("Захватываю бассейн с лотусами!", true);
			--npcBot:Action_AttackUnit(closestLotusPull, false);
			npcBot:Action_MoveDirectly(closestLotusPull:GetLocation() + RandomVector(50));
			return;
		end
	end ]]

	if closestOutpost ~= nil
	then
		npcBot:SetTarget(closestOutpost);
		if GetUnitToUnitDistance(npcBot, closestOutpost) > captureRange
		then
			--npcBot:ActionImmediate_Chat("Иду захватывать " .. closestOutpost:GetUnitName(), true);
			npcBot:Action_MoveToLocation(closestOutpost:GetLocation());
			return;
		else
			--npcBot:ActionImmediate_Chat("Захватываю " .. closestOutpost:GetUnitName(), true);
			npcBot:Action_AttackUnit(closestOutpost, false);
			return;
		end
	end
end
