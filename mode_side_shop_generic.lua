---@diagnostic disable: undefined-global, param-type-mismatch, missing-parameter
require(GetScriptDirectory() .. "/utility")

-- Режим для Терзателя

local npcBot = GetBot();
local minAllyHeroes = 3;
local checkRadius = 8000;
local radiantTormentorLocation = Vector(7488.0, -7856.7, 351.6);
local direTormentorLocation = Vector(-7201.8, 7947.3, 328.1);
local updateInterval = 300;
local lastUpdateTime = 0;
local tormentorPositions = {}

--local radiantWisdomRuneLocation = Vector(-8136.8, -913.7, 1341.7);
--local direWisdomRuneLocation = Vector(8320.9, -339.3, 1318.9);
--local radiantTormentorCheckTimer = 0.0;
--local direTormentorCheckTimer = 0.0;

function IsPositionInTable(table, pos)
	for _, p in ipairs(table) do
		if p.x == pos.x and p.y == pos.y and p.z == pos.z
		then
			return true;
		end
	end
	return false;
end

function HasTormentorInPosition(tormentorLocation)
	local creeps = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS);

	if (#creeps > 0)
	then
		for _, creep in pairs(creeps)
		do
			if utility.IsTormentor(creep) and GetUnitToLocationDistance(creep, tormentorLocation) <= 1000
			then
				return true;
			end
		end
	end

	return false;
end

--[[ local function OLDGetClosestAvailableTormentor()
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
end ]]

function GetTormentor(unitsList)
	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if utility.IsTormentor(unit)
			then
				return unit;
			end
		end
	end

	return nil;
end

function GetClosestAvailableTormentorLocation()
	local closestLocation = nil;
	local distance = 100000;

	if (#tormentorPositions > 0)
	then
		for _, location in pairs(tormentorPositions)
		do
			local unitDistance = GetUnitToLocationDistance(npcBot, location);
			if unitDistance < distance
			then
				closestLocation = location;
				distance = unitDistance;
				break;
			end
		end
	end

	return closestLocation, distance;
end

function GetCountAllyHeroesAroundTormentorLocation(tormentorLocation, radius)
	local count = 0;
	local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			local enemyHeroes = unit:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			if not unit:IsIllusion() and GetUnitToLocationDistance(unit, tormentorLocation) <= radius and unit:GetHealth() / unit:GetMaxHealth() >= 0.2
				and (#enemyHeroes <= 0)
			then
				count = count + 1;
			end
		end
	end

	return count;
end

function IsAllyHeroAttackTormentor(tormentorLocation)
	local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	if (#unitsList > 0)
	then
		for _, unit in pairs(unitsList)
		do
			if not unit:IsIllusion() and utility.IsTormentor(unit:GetAttackTarget())
				and GetUnitToLocationDistance(unit, tormentorLocation) <= 1000
			then
				return true;
			end
		end
	end

	return false;
end

--table.insert(tormentorPositions, radiantTormentorLocation);
--table.insert(tormentorPositions, direTormentorLocation);

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	if not utility.IsHero(npcBot) or not npcBot:IsAlive() or (#enemyHeroes > 0) or utility.IsBaseUnderAttack() or utility.IsEnemyBaseUnderAttack()
		or npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.2 or DotaTime() < 20 * 60
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local currentTime = DotaTime();
	if currentTime - lastUpdateTime >= updateInterval
	then
		if utility.IsNight()
		then
			--npcBot:ActionImmediate_Chat("Ночь - Терзатель у Radiant.", true);
			tormentorPositions = {
				radiantTormentorLocation
			}
		else
			--npcBot:ActionImmediate_Chat("День - Терзатель у Dire.", true);
			tormentorPositions = {
				direTormentorLocation
			}
		end
		lastUpdateTime = currentTime;
		--npcBot:ActionImmediate_Chat("Обновляю список доступных Терзателей: " .. #tormentorPositions, true);
	end

	--IsLocationVisible(tormentorPositions[i])
	--IsRadiusVisible(tormentorPositions[i], 400)

	if (#tormentorPositions > 0)
	then
		for i = #tormentorPositions, 1, -1 do
			if IsLocationVisible(tormentorPositions[i])
			then
				if not HasTormentorInPosition(tormentorPositions[i])
				then
					--npcBot:ActionImmediate_Ping(tormentorPositions[i].x, tormentorPositions[i].y, false);
					--npcBot:ActionImmediate_Chat("Удаляю позицию Терзателя - его там нет.", true);
					table.remove(tormentorPositions, i);
				elseif HasTormentorInPosition(tormentorPositions[i]) and not IsPositionInTable(tormentorPositions, tormentorPositions[i])
				then
					--npcBot:ActionImmediate_Ping(tormentorPositions[i].x, tormentorPositions[i].y, false);
					--npcBot:ActionImmediate_Chat("Добавляю позицию Терзателя - он на месте.", true);
					table.insert(tormentorPositions, i);
				end
			end
		end
	end

	closestTormentorLocation, tormentorDistance = GetClosestAvailableTormentorLocation();
	local countAllyHeroesNear = GetCountAllyHeroesAroundTormentorLocation(closestTormentorLocation, checkRadius);

	--[[ 	local randomBot = utility.GetRandomBotPlayer();
	if npcBot == randomBot
	then
		utility.GetUnitInfo(closestTormentor)
	end ]]

	if tormentorDistance <= checkRadius and (countAllyHeroesNear >= minAllyHeroes or IsAllyHeroAttackTormentor(closestTormentorLocation))
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
		npcBot:ActionImmediate_Ping(closestTormentorLocation.x, closestTormentorLocation.y, true);
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

	local attackRange = 500;

	if closestTormentorLocation ~= nil
	then
		if GetUnitToLocationDistance(npcBot, closestTormentorLocation) > attackRange
		then
			--npcBot:ActionImmediate_Chat("Иду к Терзателю!", true);
			npcBot:Action_MoveToLocation(closestTormentorLocation);
			return;
		else
			if GetCountAllyHeroesAroundTormentorLocation(closestTormentorLocation, 1000) >= minAllyHeroes or IsAllyHeroAttackTormentor(closestTormentorLocation)
			then
				local neutralCreeps = npcBot:GetNearbyCreeps(1600, true);
				local tormentor = GetTormentor(neutralCreeps);
				if tormentor ~= nil and not tormentor:IsInvulnerable()
				then
					--npcBot:ActionImmediate_Chat("Атакую " .. tormentor:GetUnitName(), true);
					npcBot:SetTarget(tormentor);
					npcBot:Action_AttackUnit(tormentor, false);
					return;
				else
					npcBot:Action_MoveToLocation(closestTormentorLocation + RandomVector(400));
					return;
				end
			else
				--npcBot:ActionImmediate_Chat("Жду союзников!", true);
				npcBot:Action_MoveToLocation(closestTormentorLocation + RandomVector(400));
				return;
			end
		end
	end
end

-- unit:GetUnitName() == "npc_dota_watch_tower" -- не работает
--if string.find(unit:GetUnitName(), "watch_tower") and not unit:HasModifier("modifier_invulnerable")
-- npcBot:ActionImmediate_Chat(unit:GetUnitName(), true);
-- print(unit:GetUnitName())

--[[ 	if closestTormentor ~= nil
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
				
				if GetUnitToLocationDistance(npcBot, radiantWisdomRuneLocation) < GetUnitToLocationDistance(npcBot, direWisdomRuneLocation)
				then
					npcBot:Action_MoveDirectly(radiantWisdomRuneLocation + RandomVector(20));
					return;
				else
					npcBot:Action_MoveDirectly(direWisdomRuneLocation + RandomVector(20));
					return;
				end
			end
		end
	end ]]
