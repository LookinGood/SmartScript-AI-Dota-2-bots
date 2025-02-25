---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

-- Режим для Терзателя

local npcBot = GetBot();
local minAllyHeroes = 3;
local checkRadius = 4000;

--local radiantWisdomRuneLocation = Vector(-8136.8, -913.7, 1341.7);
--local direWisdomRuneLocation = Vector(8320.9, -339.3, 1318.9);

local radiantTormentorLocation = Vector(-8147.1, -1185.7, 273.6);
local direTormentorLocation = Vector(8125.5, 1022.9, 293.3);
local radiantTormentorCheckTimer = 0.0;
local direTormentorCheckTimer = 0.0;

local function GetClosestAvailableTormentor()
	local closestUnit = nil;
	local distance = 100000;
	local unitsList = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if unit:CanBeSeen() and unit:GetUnitName() == "npc_dota_miniboss"
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

local function GetCountAllyHeroesAroundTormentor(tormentor, radius)
	local count = 0;
	local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if not unit:IsIllusion() and GetUnitToUnitDistance(unit, tormentor) <= radius
			then
				count = count + 1;
			end
		end
	end

	return count;
end

local function IsAllyHeroAttackTormentor(tormentor)
	local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if not unit:IsIllusion() and unit:GetAttackTarget() == tormentor
			then
				return true;
			end
		end
	end

	return false;
end

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	if not utility.IsHero(npcBot) or not npcBot:IsAlive() or (#enemyHeroes > 0) or utility.IsBaseUnderAttack()
		or npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.2
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local countAllyHeroesNear = GetCountAllyHeroesAroundTormentor(closestTormentor, checkRadius);
	closestTormentor, tormentorDistance = GetClosestAvailableTormentor();

	--[[ 	local randomBot = utility.GetRandomBotPlayer();
	if npcBot == randomBot
	then
		utility.GetUnitInfo(closestTormentor)
	end ]]

	if tormentorDistance <= checkRadius and (countAllyHeroesNear >= minAllyHeroes or IsAllyHeroAttackTormentor(closestTormentor))
	then
		--npcBot:ActionImmediate_Chat("Рядом есть доступный Терзатель.", true);
		return BOT_MODE_DESIRE_VERYHIGH;
	end

	return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
	if RollPercentage(5)
	then
		npcBot:ActionImmediate_Chat("Атакую Терзателя!", false);
		npcBot:ActionImmediate_Ping(closestTormentor:GetLocation().x, closestTormentor:GetLocation().y, true);
	end
end

function OnEnd()
	npcBot:SetTarget(nil);
end

function Think()
	if utility.IsBusy(npcBot)
	then
		return;
	end

	local attackRange = 1000;
	local tormentorLocation = closestTormentor:GetLocation();

	if closestTormentor ~= nil
	then
		npcBot:SetTarget(closestTormentor);
		if GetUnitToUnitDistance(npcBot, closestTormentor) > attackRange
		then
			--npcBot:ActionImmediate_Chat("Иду к " .. closestTormentor:GetUnitName(), true);
			npcBot:Action_MoveToLocation(tormentorLocation);
			return;
		else
			if GetCountAllyHeroesAroundTormentor(closestTormentor, 1000) >= minAllyHeroes
			then
				--npcBot:ActionImmediate_Chat("Атакую " .. closestTormentor:GetUnitName(), true);
				npcBot:Action_AttackUnit(closestTormentor, false);
				return;
			else
				--npcBot:ActionImmediate_Chat("Жду союзников!", true);
				npcBot:Action_MoveToLocation(tormentorLocation + RandomVector(200));
				return;
				--[[
				if GetUnitToLocationDistance(npcBot, radiantWisdomRuneLocation) < GetUnitToLocationDistance(npcBot, direWisdomRuneLocation)
				then
					npcBot:Action_MoveDirectly(radiantWisdomRuneLocation + RandomVector(20));
					return;
				else
					npcBot:Action_MoveDirectly(direWisdomRuneLocation + RandomVector(20));
					return;
				end ]]
			end
		end
	end
end

-- unit:GetUnitName() == "npc_dota_watch_tower" -- не работает
--if string.find(unit:GetUnitName(), "watch_tower") and not unit:HasModifier("modifier_invulnerable")
-- npcBot:ActionImmediate_Chat(unit:GetUnitName(), true);
-- print(unit:GetUnitName())
