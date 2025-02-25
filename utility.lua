---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("utility", package.seeall)
require(GetScriptDirectory() .. "/hero_role_generic")

-- Debugg
function GetUnitInfo(npcTarget)
	local timer = 0.0

	if (GameTime() < timer + 10.0)
	then
		return;
	end

	GetBot():ActionImmediate_Chat("Вывожу в лог информацию о " .. npcTarget:GetUnitName(), true);

	if npcTarget:GetTeam() == TEAM_RADIANT
	then
		print(npcTarget:GetUnitName() .. " - команда: Radiant")
	end
	if npcTarget:GetTeam() == TEAM_DIRE
	then
		print(npcTarget:GetUnitName() .. " - команда: Dire")
	end
	if npcTarget:GetTeam() == TEAM_NEUTRAL
	then
		print(npcTarget:GetUnitName() .. " - команда: Neutral")
	end
	if npcTarget:GetTeam() == TEAM_NONE
	then
		print(npcTarget:GetUnitName() .. " - команда: Нет команды")
	end

	if npcTarget:IsCreep()
	then
		print(npcTarget:GetUnitName() .. " - тип: Крип")
	end
	if npcTarget:IsAncientCreep()
	then
		print(npcTarget:GetUnitName() .. " - тип: Древний Крип")
	end
	if npcTarget:IsHero()
	then
		print(npcTarget:GetUnitName() .. " - тип: Герой")
	end
	if npcTarget:IsBuilding()
	then
		print(npcTarget:GetUnitName() .. " - тип: Здание")
	end
	if npcTarget:IsTower()
	then
		print(npcTarget:GetUnitName() .. " - тип: Башня")
	end
	if npcTarget:IsBarracks()
	then
		print(npcTarget:GetUnitName() .. " - тип: Баррак")
	end
	if npcTarget:IsFort()
	then
		print(npcTarget:GetUnitName() .. " - тип: Древний (Форт)")
	end

	timer = GameTime();
end

function NotCurrectHeroBot(npcTarget)
	return npcTarget == nil or npcTarget:IsNull() or not npcTarget:IsHero() or IsIllusion(npcTarget)
end

function IsValidTarget(npcTarget)
	return npcTarget:CanBeSeen() and npcTarget ~= nil and not npcTarget:IsNull() and npcTarget:IsAlive()
		and not npcTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter");
end

function IsClone(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:HasModifier("modifier_arc_warden_tempest_double") or
			npcTarget:HasModifier("modifier_dazzle_nothl_projection_soul_clone"))
end

function IsNight()
	local time = GetTimeOfDay();
	return time < 0.5;
end

function IsBaseUnderAttack()
	local radiusUnit = 3000;
	local towers = {
		TOWER_TOP_3,
		TOWER_MID_3,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2,
	}

	for _, t in pairs(towers)
	do
		local tower = GetTower(GetTeam(), t);
		if tower ~= nil
		then
			if utility.CountEnemyCreepAroundUnit(tower, radiusUnit) > 1 or utility.CountEnemyHeroAroundUnit(tower, radiusUnit) > 0
			then
				return true;
			end
		end
	end

	local barracks = {
		BARRACKS_TOP_MELEE,
		BARRACKS_TOP_RANGED,
		BARRACKS_MID_MELEE,
		BARRACKS_MID_RANGED,
		BARRACKS_BOT_MELEE,
		BARRACKS_BOT_RANGED,
	}

	for _, b in pairs(barracks)
	do
		local barrack = GetBarracks(GetTeam(), b);
		if barrack ~= nil
		then
			if utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) > 1 or utility.CountEnemyHeroAroundUnit(barrack, radiusUnit) > 0
			then
				return true;
			end
		end
	end

	local ancient = GetAncient(GetTeam());
	if ancient ~= nil
	then
		if utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) > 1 or utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) > 0
		then
			return true;
		end
	end

	return false;
end

function IsUnitNeedToHide(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsDominated() or
			npcTarget:HasModifier("modifier_necrolyte_reapers_scythe"))
end

function IsNotAttackTarget(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:HasModifier("modifier_item_blade_mail_reflect") or
			npcTarget:HasModifier("modifier_nyx_assassin_spiked_carapace") or
			npcTarget:HasModifier("modifier_abaddon_borrowed_time") or
			npcTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter_active"));
end

function GetWeakest(units)
	local target = nil;
	local minHP = 10000;
	if #units > 0
	then
		for i = 1, #units do
			if IsValidTarget(units[i])
			then
				local hp = units[i]:GetHealth();
				if hp < minHP
				then
					target = units[i];
					minHP  = hp;
				end
			end
		end
	end
	return target;
end

function GetStrongest(units)
	local target = nil;
	local maxHP = 0;
	if #units > 0
	then
		for i = 1, #units do
			if IsValidTarget(units[i])
			then
				local hp = units[i]:GetHealth();
				if hp > maxHP
				then
					target = units[i];
					maxHP  = hp;
				end
			end
		end
	end
	return target;
end

function GetWeakestHero(unit, radius)
	local enemies = unit:GetNearbyHeroes(radius, true, BOT_MODE_NONE);
	return GetWeakest(enemies);
end

function GetWeakestCreep(unit, radius)
	local creeps = unit:GetNearbyCreeps(radius, true);
	return GetWeakest(creeps);
end

function GetStrongestCreep(unit, radius)
	local creeps = unit:GetNearbyCreeps(radius, true);
	return GetStrongest(creeps);
end

function GetWeakestTower(unit, radius)
	local towers = unit:GetNearbyTowers(radius, true);
	return GetWeakest(towers);
end

function GetWeakestBarracks(unit, radius)
	local barracks = unit:GetNearbyBarracks(radius, true);
	return GetWeakest(barracks);
end

function HaveHumanInTeam(npcBot)
	local players = GetTeamPlayers(npcBot:GetTeam())
	for _, id in pairs(players) do
		if not IsPlayerBot(id)
		then
			return true;
		end
	end
	return false;
end

function GetClosestToLocationBotHero(vlocation)
	local unit = nil;
	local distance = 100000;
	local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	for _, ally in pairs(allyHeroes) do
		if IsPlayerBot(ally:GetPlayerID()) and ally:IsAlive()
		then
			local botDistance = GetUnitToLocationDistance(ally, vlocation);
			if botDistance < distance
			then
				unit = ally;
				distance = botDistance;
			end
		end
	end

	--print(unit:GetUnitName())
	return unit;
end

function GetRandomBotPlayer()
	local selectedBotHero = nil;
	local goldMin = 100000;
	local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	for _, ally in pairs(allyHeroes) do
		if IsPlayerBot(ally:GetPlayerID())
		then
			local playerGold = ally:GetGold();
			if playerGold < goldMin
			then
				goldMin = playerGold;
				selectedBotHero = ally;
			end
		end
	end

	--[[     for _, i in pairs(GetTeamPlayers(GetTeam()))
    do
        if IsPlayerBot(i)
        then
            local playerGold = i:GetGold();
            if playerGold < goldMin
            then
                goldMin = playerGold;
                selectedBotPlayer = i;
            end
        end
    end ]]

	return selectedBotHero;
end

--[[ function GetNearbyHeroes(target, nRadius, bEnemies)
	local unitList = {}
	if bEnemies == false
	then
		local enemyHeroes = target:GetUnitList(UNIT_LIST_ENEMY_HEROES)
		for _, enemy in pairs(enemyHeroes) do
			if IsValidTarget(enemy) and GetUnitToUnitDistance(target, enemy) <= nRadius
			then
				table.insert(unitList, enemy);
			end
		end
	elseif bEnemies == true
	then
		local allyHeroes = target:GetUnitList(UNIT_LIST_ALLIED_HEROES)
		for _, ally in pairs(allyHeroes) do
			if IsValidTarget(ally) and GetUnitToUnitDistance(target, ally) <= nRadius
			then
				table.insert(unitList, ally);
			end
		end
	end

	return unitList;
end ]]

function GetBiggerAttribute(npcTarget)
	if not IsHero(npcTarget)
	then
		return nil;
	end

	local targetStrenght = npcTarget:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local targetAgility = npcTarget:GetAttributeValue(ATTRIBUTE_AGILITY);
	local targetIntellect = npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
	--local biggerAttribute = (math.max(targetStrenght, targetAgility, targetIntellect));

	--print(targetStrenght)
	--print(targetAgility)
	--print(targetIntellect)

	local biggerAttribute = nil;
	local value = 0;
	local attributesTable = {
		targetStrenght,
		targetAgility,
		targetIntellect
	}

	for _, attribute in pairs(attributesTable) do
		if attribute > value
		then
			value = attribute;
			biggerAttribute = attribute;
		end
	end

	if biggerAttribute == targetStrenght
	then
		return ATTRIBUTE_STRENGTH;
	elseif biggerAttribute == targetAgility
	then
		return ATTRIBUTE_AGILITY;
	elseif biggerAttribute == targetIntellect
	then
		return ATTRIBUTE_INTELLECT;
	end

	return ATTRIBUTE_STRENGTH;
end

function GetCurrentCastDistance(castRangeAbility)
	local distance = castRangeAbility;
	if distance > 1600
	then
		distance = 1600
		return distance;
	else
		return distance;
	end
end

function GetItemSlotsCount()
	local npcBot = GetBot();
	local itemCount = 0;

	for i = 0, 8
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if (sCurItem ~= nil)
		then
			itemCount = itemCount + 1;
		end
	end

	return itemCount;
end

function IsItemSlotsFull()
	local itemCount = GetItemSlotsCount();
	return itemCount >= 9;
end

function GetStashSlotsCount()
	local npcBot = GetBot();
	local itemCount = 0;

	for i = 9, 14
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if (sCurItem ~= nil)
		then
			itemCount = itemCount + 1;
		end
	end

	return itemCount;
end

function IsStashSlotsFull()
	local itemCount = GetStashSlotsCount();
	return itemCount >= 6;
end

function GetCourierItemSlotsCount()
	local npcBot = GetBot();
	local courier = GetBotCourier(npcBot);
	local itemCount = 0;

	for i = 0, 8
	do
		local sCurItem = courier:GetItemInSlot(i);
		if (sCurItem ~= nil)
		then
			itemCount = itemCount + 1;
		end
	end

	return itemCount;
end

function IsCourierItemSlotsFull()
	local itemCount = GetCourierItemSlotsCount();
	return itemCount >= 9;
end

function GetBotCourier(npcBot)
	local courier = GetCourier(0);
	local numPlayer = GetTeamPlayers(GetTeam());
	for i = 1, #numPlayer do
		local member = GetTeamMember(i);
		if member ~= nil and member:GetUnitName() == npcBot:GetUnitName()
		then
			courier = GetCourier(i - 1);
		end
	end
	return courier;
end

--[[ function GetBotCourier(npcBot)
	local courier = GetCourier(0);

	if npcBot:GetTeam() == TEAM_RADIANT
	then
		local playerID = npcBot:GetPlayerID();
		courier = GetCourier(playerID);
	elseif npcBot:GetTeam() == TEAM_DIRE
	then
		courier = GetCourier(0);
		local numPlayer = GetTeamPlayers(GetTeam());
		for i = 1, #numPlayer do
			local member = GetTeamMember(i);
			if member ~= nil and member:GetUnitName() == npcBot:GetUnitName()
			then
				courier = GetCourier(i - 1);
			end
		end
	end
	return courier;
end ]]

function IsItemBreaksInvisibility(sItem)
	local npcBot = GetBot();
	if npcBot:IsInvisible()
	then
		if not sItem:UsingItemBreaksInvisibility()
		then
			return true;
		end
	end
	return false;
end

function IsIllusion(npcTarget)
	if not IsValidTarget(npcTarget)
	then
		return false;
	end

	local npcBot = GetBot();

	if IsAlly(npcBot, npcTarget)
	then
		if npcTarget:IsIllusion()
		then
			return true;
		end
	else
		local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
		for _, ally in pairs(allyHeroes) do
			if not ally:IsIllusion()
			then
				if ally:GetUnitName() == npcTarget:GetUnitName()
				then
					return true;
				end
			end
		end
	end
end

--[[ 	npcTarget:HasModifier("modifier_illusion") or
	npcTarget:HasModifier("modifier_antimage_blink_illusion") or
	npcTarget:HasModifier("modifier_bane_fiends_grip_illusion") or
	npcTarget:HasModifier("modifier_chaos_knight_phantasm_illusion") or
	npcTarget:HasModifier("modifier_hoodwink_decoy_illusion") or
	npcTarget:HasModifier("modifier_darkseer_wallofreplica_illusion") or
	npcTarget:HasModifier("modifier_terrorblade_conjureimage") or
	npcTarget:HasModifier("modifier_phantom_lancer_juxtapose_illusion") ]]

function IsAlly(unit1, unit2)
	return (unit1:GetTeam() == unit2:GetTeam());
end

-- (IsValidTarget(npcBot) and IsValidTarget(npcTarget)) and

function IsHero(npcTarget)
	return npcTarget:IsHero() and not IsIllusion(npcTarget) and not IsClone(npcTarget);
end

function IsBuilding(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsBuilding() or
			npcTarget:IsTower() or
			npcTarget:IsBarracks() or
			npcTarget:IsFort() or
			string.find(npcTarget:GetUnitName(), "rax") or
			string.find(npcTarget:GetUnitName(), "tower") or
			string.find(npcTarget:GetUnitName(), "fort")
			and not string.find(npcTarget:GetUnitName(), "fillers"));
end

function IsRoshan(npcTarget)
	return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "roshan");
end

function IsTormentor(npcTarget)
	return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "npc_dota_miniboss");
end

function IsBoss(npcTarget)
	return IsRoshan(npcTarget) or IsTormentor(npcTarget);
end

function IsDisabled(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsDominated() or
			npcTarget:IsHexed() or
			npcTarget:IsNightmared() or
			npcTarget:IsRooted() or
			npcTarget:IsStunned());
end

function IsCantBeControlled(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsDominated() or
			npcTarget:IsNightmared() or
			npcTarget:IsStunned());
end

function IsMoving(npcTarget)
	local moveDirection = npcTarget:GetMovementDirectionStability();
	return IsValidTarget(npcTarget) and
		npcTarget:GetBaseMovementSpeed() > 0 and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_IDLE and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_DELAY and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_NONE and
		not npcTarget:IsRooted() and
		not npcTarget:IsStunned() and
		not npcTarget:IsNightmared() and
		moveDirection > 0.95
end

function IsHaveMaxSpeed(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:HasModifier("modifier_rune_haste") or
			npcTarget:HasModifier("modifier_lycan_shapeshift") or
			npcTarget:HasModifier("modifier_lycan_shapeshift_speed") or
			npcTarget:HasModifier("modifier_centaur_stampede") or
			npcTarget:HasModifier("modifier_dark_seer_surge") or
			npcTarget:GetCurrentMovementSpeed() >= 500)
end

function IsHaveStunEffect(npcTarget)
	return IsValidTarget(npcTarget) and
		npcTarget:HasModifier("modifier_enigma_malefice");
end

function HaveRemovedRegenBuff(npcTarget)
	return npcTarget:HasModifier('modifier_bottle_regeneration') or
		npcTarget:HasModifier('modifier_flask_healing') or
		npcTarget:HasModifier('modifier_clarity_potion');
end

function IsAllyHeroesBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local units = hSource:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i, unit in pairs(units) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	local targetUnits = hTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i, unit in pairs(targetUnits) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	return false;
end

function IsEnemyHeroesBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local units = hSource:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	for i, unit in pairs(units) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	local targetUnits = hTarget:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	for i, unit in pairs(targetUnits) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	return false;
end

function IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local units = hSource:GetNearbyCreeps(1600, false);
	for i, unit in pairs(units) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	local targetUnits = hTarget:GetNearbyCreeps(1600, true);
	for i, unit in pairs(targetUnits) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	return false;
end

function IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local units = hSource:GetNearbyCreeps(1600, true);
	for i, unit in pairs(units) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	local targetUnits = hTarget:GetNearbyCreeps(1600, false);
	for i, unit in pairs(targetUnits) do
		local tResult = PointToLineDistance(vStart, vEnd, unit:GetLocation());
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	return false;
end

function IsTreeBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	local vStart = hSource:GetLocation();
	local vEnd = vLoc;
	local treesSource = hSource:GetNearbyTrees(1600);
	for i, tree in pairs(treesSource) do
		local tResult = PointToLineDistance(vStart, vEnd, GetTreeLocation(tree));
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	local treesTarget = hTarget:GetNearbyTrees(1600);
	for i, tree in pairs(treesTarget) do
		local tResult = PointToLineDistance(vStart, vEnd, GetTreeLocation(tree));
		if tResult ~= nil and tResult.within and tResult.distance <= nRadius + 50
		then
			return true;
		end
	end
	return false;
end

function IsAnyUnitsBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius)
	return IsAllyHeroesBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) or
		IsEnemyHeroesBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) or
		IsAllyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius) or
		IsEnemyCreepBetweenMeAndTarget(hSource, hTarget, vLoc, nRadius);
end

function IsEnemiesAroundStronger()
	local npcBot = GetBot();
	local allyPower = 0;
	local enemyPower = 0;
	local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
	local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

	if (#enemyHeroAround > 0)
	then
		for _, enemy in pairs(enemyHeroAround) do
			if utility.IsValidTarget(enemy)
			then
				local enemyOffensivePower = enemy:GetRawOffensivePower();
				enemyPower = enemyPower + enemyOffensivePower;
			end
		end
	end

	if (#allyHeroAround > 0)
	then
		for _, ally in pairs(allyHeroAround) do
			local allyOffensivePower = ally:GetOffensivePower();
			allyPower = allyPower + allyOffensivePower;
		end
	end

	if enemyPower > allyPower
	then
		return true;
	else
		return false;
	end
end

function IsBusy(npcTarget)
	return IsValidTarget(npcTarget) and
		(IsCantBeControlled(npcTarget) or
			--npcTarget:IsUsingAbility() or
			--npcTarget:IsCastingAbility() or
			npcTarget:IsChanneling() or
			npcTarget:IsUsingAbility() or
			npcTarget:IsCastingAbility() or
			npcTarget:NumQueuedActions() > 0)
end

function IsAbilityAvailable(ability)
	return ability ~= nil and
		ability:IsFullyCastable() and
		ability:IsActivated() and
		ability:IsTrained() and
		not ability:IsHidden() and
		not ability:IsPassive()
end

function IsTargetedByEnemy(unit, bcreeps)
	local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
	for _, enemy in pairs(enemyHeroes)
	do
		if enemy:GetAttackTarget() == unit
		then
			return true;
		end
	end
	if bcreeps == true
	then
		local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
		for _, enemy in pairs(enemyCreeps)
		do
			if enemy:GetAttackTarget() == unit
			then
				return true;
			end
		end
	end
	return false;
end

function CountAllyCreepAroundUnit(unit, radius)
	local count = 0;
	local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);

	for _, ally in pairs(allyCreeps)
	do
		if GetUnitToUnitDistance(unit, ally) <= radius
		then
			count = count + 1;
		end
	end

	return count;
end

function CountEnemyCreepAroundUnit(unit, radius)
	local count = 0;
	local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);

	for _, enemy in pairs(enemyCreeps)
	do
		if GetUnitToUnitDistance(unit, enemy) <= radius
		then
			count = count + 1;
		end
	end

	return count;
end

function CountAllyTowerAroundUnit(unit, radius)
	local count = 0;
	local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

	for _, ally in pairs(allyCreeps)
	do
		if GetUnitToUnitDistance(unit, ally) <= radius and ally:IsTower()
		then
			count = count + 1;
		end
	end

	return count;
end

function CountAllyTowerAroundPosition(position, radius)
	local count = 0;
	local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

	for _, ally in pairs(allyCreeps)
	do
		if GetUnitToLocationDistance(ally, position) <= radius and ally:IsTower()
		then
			count = count + 1;
		end
	end

	return count;
end

function CountEnemyTowerAroundUnit(unit, radius)
	local count = 0;
	local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);

	for _, enemy in pairs(enemyCreeps)
	do
		if GetUnitToUnitDistance(unit, enemy) <= radius and enemy:IsTower()
		then
			count = count + 1;
		end
	end

	return count;
end

function CountEnemyTowerAroundPosition(position, radius)
	local count = 0;
	local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);

	for _, enemy in pairs(enemyCreeps)
	do
		if GetUnitToLocationDistance(enemy, position) <= radius and enemy:IsTower()
		then
			count = count + 1;
		end
	end

	return count;
end

function CountAllyHeroAroundUnit(unit, radius)
	local count = 0;
	local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

	for _, ally in pairs(allyHeroes)
	do
		if GetUnitToUnitDistance(unit, ally) <= radius
		then
			count = count + 1;
		end
	end

	return count;
end

function CountEnemyHeroAroundUnit(unit, radius)
	local count = 0;
	local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);

	for _, enemy in pairs(enemyHeroes)
	do
		if GetUnitToUnitDistance(unit, enemy) <= radius
		then
			count = count + 1;
		end
	end

	return count;
end

function CountUnitAroundTarget(target, unitName, bEnemy, radius)
	local count = 0;

	if bEnemy == true
	then
		local heroList = GetUnitList(UNIT_LIST_ENEMY_HEROES);
		if #heroList > 0
		then
			for _, creep in pairs(heroList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
		if #unitList > 0
		then
			for _, creep in pairs(unitList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local wardList = GetUnitList(UNIT_LIST_ENEMY_WARDS);
		if #wardList > 0
		then
			for _, creep in pairs(wardList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local otherUnitList = GetUnitList(UNIT_LIST_ENEMY_OTHER)
		if #otherUnitList > 0
		then
			for _, creep in pairs(otherUnitList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end
	else
		local heroList = GetUnitList(UNIT_LIST_ALLIED_HEROES);
		if #heroList > 0
		then
			for _, creep in pairs(heroList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
		if #unitList > 0
		then
			for _, creep in pairs(unitList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local wardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
		if #wardList > 0
		then
			for _, creep in pairs(wardList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end

		local otherUnitList = GetUnitList(UNIT_LIST_ALLIED_OTHER);
		if #otherUnitList > 0
		then
			for _, creep in pairs(otherUnitList)
			do
				if IsValidTarget(creep) and (creep:GetUnitName() == unitName or string.find(creep:GetUnitName(), unitName))
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end
	end

	return count;
end

function CanCast(npcTarget)
	return npcTarget:IsAlive() and
		npcTarget:NumQueuedActions() <= 0 and
		not npcTarget:IsIllusion() and
		not npcTarget:IsUsingAbility() and
		not npcTarget:IsCastingAbility() and
		not npcTarget:IsChanneling() and
		not npcTarget:IsSilenced() and
		not IsCantBeControlled(npcTarget)
end

function CanCastWhenChanneling(npcTarget)
	return npcTarget:IsAlive() and
		npcTarget:NumQueuedActions() <= 0 and
		not npcTarget:IsCastingAbility() and
		not npcTarget:IsSilenced() and
		not IsCantBeControlled(npcTarget)
end

function CanUseItems(npcTarget)
	return npcTarget:IsAlive() and
		npcTarget:NumQueuedActions() <= 0 and
		not npcTarget:IsIllusion() and
		--not npcTarget:IsUsingAbility() and
		not npcTarget:IsCastingAbility() and
		--not npcTarget:IsChanneling() and
		not npcTarget:IsMuted() and
		not IsCantBeControlled(npcTarget)
end

function CheckFlag(bitfield, flag)
	return ((bitfield / flag) % 2) >= 1;
end

--[[ function GetTargetPosition(npcTarget, fdelay)
	if IsMoving(npcTarget)
	then
		return npcTarget:GetExtrapolatedLocation(fdelay);
	else
		return npcTarget:GetLocation();
	end
end ]]

function GetTargetCastPosition(npcCaster, npcTarget, fDelay, fSpellSpeed)
	if fSpellSpeed == nil
	then
		fSpellSpeed = 0.0;
	end

	if fDelay == nil
	then
		fDelay = 0.1;
	end

	local targetDistance = GetUnitToUnitDistance(npcCaster, npcTarget)
	local moveDirection = npcTarget:GetMovementDirectionStability();
	local targetLocation = npcTarget:GetExtrapolatedLocation(fDelay +
		(targetDistance / fSpellSpeed));
	if moveDirection < 0.95
	then
		targetLocation = npcTarget:GetLocation();
	end

	return targetLocation;
end

function CanAbilityKillTarget(npcTarget, damage, damagetype)
	return IsValidTarget(npcTarget) and npcTarget:GetActualIncomingDamage(damage, damagetype) >= npcTarget:GetHealth()
end

function TargetCantDie(npcTarget)
	return IsValidTarget(npcTarget) and npcTarget:GetHealth() / npcTarget:GetMaxHealth() <= 0.3 and
		(npcTarget:HasModifier("modifier_dazzle_shallow_grave") or
			npcTarget:HasModifier("modifier_oracle_false_promise_timer") or
			npcTarget:HasModifier("modifier_troll_warlord_battle_trance") or
			npcTarget:HasModifier("modifier_item_aeon_disk_buff") or
			npcTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter_active"))
end

function IsTargetInvulnerable(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsInvulnerable() or
			npcTarget:HasModifier("modifier_item_aeon_disk_buff") or
			npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") or
			npcTarget:HasModifier("modifier_abaddon_aphotic_shield") or
			npcTarget:HasModifier("modifier_abaddon_borrowed_time") or
			npcTarget:HasModifier("modifier_fountain_glyph") or
			npcTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter_active"));
end

function CanBeHeal(npcTarget)
	return IsValidTarget(npcTarget) and not npcTarget:HasModifier("modifier_ice_blast") and
		not npcTarget:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
end

function CanMove(npcTarget)
	if IsValidTarget(npcTarget) and npcTarget:GetHealth() / npcTarget:GetMaxHealth() < 0.6
	then
		if not npcTarget:HasModifier("modifier_bloodseeker_rupture") and
			not npcTarget:HasModifier("modifier_techies_minefield_sign_scepter_aura")
		then
			return true;
		else
			return false;
		end
	else
		return true;
	end
end

function CanCastOnMagicImmuneTarget(npcTarget)
	return IsValidTarget(npcTarget) and not npcTarget:IsMagicImmune() and
		not npcTarget:HasModifier("modifier_black_king_bar_immune") and
		not npcTarget:HasModifier("modifier_juggernaut_blade_fury") and
		not npcTarget:HasModifier("modifier_life_stealer_rage");
end

function CanCastOnInvulnerableTarget(npcTarget)
	return IsValidTarget(npcTarget) and not IsTargetInvulnerable(npcTarget);
end

function CanCastOnMagicImmuneAndInvulnerableTarget(npcTarget)
	return CanCastOnMagicImmuneTarget(npcTarget) and CanCastOnInvulnerableTarget(npcTarget);
end

function CanCastSpellOnTarget(spell, npcTarget)
	if spell == nil or npcTarget == nil
	then
		return false;
	end

	local npcBot = GetBot();
	local damageType = spell:GetDamageType();

	if spell ~= nil and IsValidTarget(npcTarget)
	then
		if SafeCast(npcTarget)
		then
			if damageType == DAMAGE_TYPE_MAGICAL or damageType == DAMAGE_TYPE_PHYSICAL or damageType == DAMAGE_TYPE_PURE
			then
				if not IsTargetInvulnerable(npcTarget) and not TargetCantDie(npcTarget) and not npcBot:HasModifier("modifier_item_aeon_disk_buff")
				then
					if damageType == DAMAGE_TYPE_MAGICAL
					then
						if utility.CheckFlag(spell:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
						then
							return true;
						else
							return CanCastOnMagicImmuneTarget(npcTarget);
						end
					elseif damageType == DAMAGE_TYPE_PHYSICAL
					then
						if utility.CheckFlag(spell:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
						then
							return true;
						else
							return CanCastOnInvulnerableTarget(npcTarget);
						end
					elseif damageType == DAMAGE_TYPE_PURE
					then
						if utility.CheckFlag(spell:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
						then
							return true;
						else
							return not npcTarget:HasModifier("modifier_black_king_bar_immune");
						end
					end
				end
			else
				if utility.CheckFlag(spell:GetTargetFlags(), ABILITY_TARGET_FLAG_MAGIC_IMMUNE_ENEMIES)
				then
					return true;
				else
					return CanCastOnMagicImmuneTarget(npcTarget);
				end
			end
		end
	end

	return false;
end

function SafeCast(npcTarget)
	return IsValidTarget(npcTarget)
		and (not npcTarget:HasModifier("modifier_antimage_counterspell")
			and not npcTarget:HasModifier("modifier_item_sphere_target")
			and not npcTarget:HasModifier("modifier_item_lotus_orb_active")
			and not npcTarget:HasModifier("modifier_item_blade_mail_reflect")
			and not npcTarget:HasModifier("modifier_nyx_assassin_spiked_carapace"));
end

function HaveReflectSpell(npcTarget)
	return IsValidTarget(npcTarget)
		and (npcTarget:HasModifier("modifier_antimage_counterspell") or
			npcTarget:HasModifier("modifier_item_sphere_target") or
			npcTarget:HasModifier("modifier_item_lotus_orb_active"));
end

function PvPMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_ATTACK or
		botMode == BOT_MODE_ROAM or
		botMode == BOT_MODE_DEFEND_ALLY or
		botMode == BOT_MODE_EVASIVE_MANEUVERS);
end

function BossMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_ROSHAN or
		botMode == BOT_MODE_SIDE_SHOP);
end

function PvEMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_PUSH_TOWER_TOP or
		botMode == BOT_MODE_PUSH_TOWER_MID or
		botMode == BOT_MODE_PUSH_TOWER_BOT or
		botMode == BOT_MODE_DEFEND_TOWER_TOP or
		botMode == BOT_MODE_DEFEND_TOWER_MID or
		botMode == BOT_MODE_DEFEND_TOWER_BOT or
		botMode == BOT_MODE_FARM or
		botMode == BOT_MODE_SECRET_SHOP or
		botMode == BOT_MODE_SIDE_SHOP or
		botMode == BOT_MODE_ITEM or
		botMode == BOT_MODE_ASSEMBLE or
		botMode == BOT_MODE_SHRINE or
		botMode == BOT_MODE_OUTPOST or
		botMode == BOT_MODE_ROSHAN);
end

function WanderMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_PUSH_TOWER_TOP or
		botMode == BOT_MODE_PUSH_TOWER_MID or
		botMode == BOT_MODE_PUSH_TOWER_BOT or
		botMode == BOT_MODE_DEFEND_TOWER_TOP or
		botMode == BOT_MODE_DEFEND_TOWER_MID or
		botMode == BOT_MODE_DEFEND_TOWER_BOT or
		botMode == BOT_MODE_SECRET_SHOP or
		botMode == BOT_MODE_SIDE_SHOP or
		botMode == BOT_MODE_RUNE or
		botMode == BOT_MODE_ITEM or
		botMode == BOT_MODE_ASSEMBLE or
		botMode == BOT_MODE_SHRINE or
		botMode == BOT_MODE_ROSHAN or
		botMode == BOT_MODE_OUTPOST);
end

function RetreatMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_RETREAT or
		botMode == BOT_MODE_EVASIVE_MANEUVERS);
end

-- Looks for an item in the inventory, and if wanted in backpack or stash.
-- Usage: local item = npcBot:GetItemByName("item_clarity",false,false)
function GetItemByName(target, itemName, bBackpack, bStash)
	local slots = 5 -- -1 because 0 indexed
	if bStash == true then
		slots = slots + 6 + 3
	elseif bBackpack == true then
		slots = slots + 3
	end
	for i = 0, slots do
		local item = target:GetItemInSlot(i)
		if item then
			if item:GetName() == itemName then
				return item
			end
		end
	end
end

--[[ function HaveItem(npc, itemName)
	for i = 0, 8 do
		local item = npc:GetItemInSlot(i)
		if item ~= nil
		then
			if item:GetName() == itemName
			then
				return true;
			else
				return false;
			end
		else
			return false;
		end
	end
end ]]

function IsBotHaveItem(itemName)
	local npcBot = GetBot();
	local courier = GetBotCourier(npcBot);

	--[[ 	local itemSlot = npcBot:FindItemSlot(itemName);
	local itemSlotType = GetItemSlotType(itemSlot);

	print(itemSlot)
	print(itemSlotType)

	if itemSlotType == ITEM_SLOT_TYPE_MAIN or
		itemSlotType == ITEM_SLOT_TYPE_BACKPACK or
		itemSlotType == ITEM_SLOT_TYPE_STASH
	then
		if itemSlotType == ITEM_SLOT_TYPE_MAIN
		then
			npcBot:ActionImmediate_Chat("Предмет уже есть в ИНВЕНТАРЕ!", true);
		elseif itemSlotType == ITEM_SLOT_TYPE_BACKPACK
		then
			npcBot:ActionImmediate_Chat("Предмет уже есть в РЮКЗАКЕ!", true);
		elseif itemSlotType == ITEM_SLOT_TYPE_STASH
		then
			npcBot:ActionImmediate_Chat("Предмет уже есть в ХРАНИЛИЩЕ!", true);
		end
		
		return true;
	end ]]

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i)
		if item ~= nil and item:GetName() == itemName
		then
			return true;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == itemName
		then
			return true;
		end
	end

	return false;
end

function GetItemCount(npc, itemName)
	local count = 0;

	for i = 0, 16
	do
		local item = npc:GetItemInSlot(i)
		if item ~= nil and item:GetName() == itemName
		then
			count = count + 1;
		end
	end

	return count;
end

function GetModifierCount(npcTarget, modifier)
	if IsValidTarget(npcTarget)
	then
		local modifier = npcTarget:GetModifierByName(modifier)
		if (modifier ~= nil)
		then
			return npcTarget:GetModifierStackCount(modifier);
		end
	end
	return 0;
end

--[[ --ITEM HAS BEEN DELETED
	function PurchaseTomeOfKnowledge(npcBot)
	if npcBot:GetGold() < GetItemCost("item_tome_of_knowledge") and IsItemSlotsFull() and GetItemStockCount("item_tome_of_knowledge") < 1 or npcBot:GetLevel() > 29
	then
		return;
	end

	local itemSlot = npcBot:FindItemSlot("item_tome_of_knowledge");
	local item = npcBot:GetItemInSlot(itemSlot);

	if GetItemStockCount("item_tome_of_knowledge") > 0 and item == nil and utility.IsStashSlotsFull() == false
	then
		npcBot:ActionImmediate_PurchaseItem("item_tome_of_knowledge");
	end
end ]]

function PurchaseWardObserver(npcBot)
	if npcBot:GetGold() < GetItemCost("item_ward_observer") or IsItemSlotsFull() or IsStashSlotsFull() or GetItemStockCount("item_ward_observer") < 1
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or not npcBot:IsAlive()
	then
		return;
	end

	--print(tostring(npcBot:GetNextItemPurchaseValue()))

	local courier = GetBotCourier(npcBot);
	local assignedLane = npcBot:GetAssignedLane();
	local botMode = npcBot:GetActiveMode();

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry" or item:GetName() == "item_ward_dispenser")
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry" or item:GetName() == "item_ward_dispenser")
		then
			return;
		end
	end

	if assignedLane == LANE_MID and botMode == BOT_MODE_LANING
	then
		npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
		--npcBot:ActionImmediate_Chat("Покупаю вард на мид!", true);
		return;
	else
		if HaveHumanInTeam(npcBot)
		then
			if GetItemStockCount("item_ward_observer") > 1
			then
				if hero_role_generic.HaveSupportInTeam(npcBot)
				then
					if hero_role_generic.IsHeroSupport(npcBot)
					then
						npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
						return;
					end
				else
					npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
					return;
				end
			end
		else
			if hero_role_generic.HaveSupportInTeam(npcBot)
			then
				if hero_role_generic.IsHeroSupport(npcBot)
				then
					npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
					return;
				end
			else
				npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
				return;
			end
		end
	end
end

function PurchaseWardSentry(npcBot)
	if npcBot:GetGold() < GetItemCost("item_ward_sentry") * 2 or IsItemSlotsFull() or IsStashSlotsFull() or GetItemStockCount("item_ward_sentry") < 1
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS
		or not npcBot:IsAlive()
	then
		return;
	end

	local courier = GetBotCourier(npcBot);

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry" or item:GetName() == "item_ward_dispenser")
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_ward_observer" or item:GetName() == "item_ward_sentry" or item:GetName() == "item_ward_dispenser")
		then
			return;
		end
	end

	if HaveHumanInTeam(npcBot)
	then
		if GetItemStockCount("item_ward_sentry") > 1
		then
			if hero_role_generic.HaveSupportInTeam(npcBot)
			then
				if hero_role_generic.IsHeroSupport(npcBot)
				then
					npcBot:ActionImmediate_PurchaseItem("item_ward_sentry");
					return;
				end
			else
				npcBot:ActionImmediate_PurchaseItem("item_ward_sentry");
				return;
			end
		end
	else
		if hero_role_generic.HaveSupportInTeam(npcBot)
		then
			if hero_role_generic.IsHeroSupport(npcBot)
			then
				npcBot:ActionImmediate_PurchaseItem("item_ward_sentry");
				return;
			end
		else
			npcBot:ActionImmediate_PurchaseItem("item_ward_sentry");
			return;
		end
	end
end

function PurchaseTP(npcBot)
	if npcBot:GetGold() < GetItemCost("item_tpscroll") or IsStashSlotsFull() or
		(npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or not npcBot:IsAlive()
	then
		return;
	end

	local courier = GetBotCourier(npcBot);

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_tpscroll"
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_tpscroll"
		then
			return;
		end
	end

	npcBot:ActionImmediate_PurchaseItem("item_tpscroll");
end

function PurchaseBottle(npcBot)
	local assignedLane = npcBot:GetAssignedLane();

	if assignedLane ~= LANE_MID
	then
		return;
	end

	if npcBot:GetGold() < GetItemCost("item_bottle") * 2 or IsItemSlotsFull() or IsStashSlotsFull() or DotaTime() > 20 * 60
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or not npcBot:IsAlive()
	then
		return;
	end

	local courier = GetBotCourier(npcBot);

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_bottle"
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_bottle"
		then
			return;
		end
	end

	npcBot:ActionImmediate_PurchaseItem("item_bottle");
end

function HaveTravelBoots(npcBot)
	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_travel_boots" or item:GetName() == "item_travel_boots_2" or item:GetName() == "item_force_boots")
		then
			return true;
		end
	end

	return false;
end

function HasAganimShard(npcBot)
	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_aghanims_shard"
		then
			return true;
		else
			return false
		end
	end
end

function GetFountain(npcTarget)
	if IsValidTarget(npcTarget)
	then
		if npcTarget:GetTeam() == TEAM_RADIANT or npcTarget:GetTeam() == TEAM_DIRE
		then
			local buildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
			if (#buildings > 0)
			then
				for _, ally in pairs(buildings)
				do
					if ally ~= nil and (string.find(ally:GetUnitName(), "fountain") or ally:DistanceFromFountain() == 0 or ally:HasModifier('modifier_fountain_aura_buff'))
					then
						return ally;
					end
				end
			end
		else
			return nil;
		end
	else
		return nil;
	end
end

-- or ally:HasModifier('modifier_fountain_aura_buff')
-- or ally:DistanceFromFountain() == 0

function GetFountainLocation()
	local buildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
	if (#buildings > 0)
	then
		for _, ally in pairs(buildings)
		do
			if ally ~= nil and string.find(ally:GetUnitName(), "fountain")
			then
				return ally:GetLocation();
			end
		end
	end

	return Vector(0, 0, 0);
end

function SafeLocation(npcBot)
	local BotTeam = npcBot:GetTeam();
	if BotTeam == TEAM_RADIANT
	then
		return Vector(-7232.0, -6888.0, 364.5);
	elseif BotTeam == TEAM_DIRE
	then
		return Vector(7168.0, 6836.4, 423.6);
	end
end

function GetEscapeLocation(bot, maxAbilityRadius)
	local botLocation = bot:GetLocation()
	local direction = (SafeLocation(bot) - botLocation):Normalized();
	return botLocation + (direction * maxAbilityRadius)
end

function GetMaxRangeCastLocation(npcBot, npcTarget, maxAbilityRange)
	local botLocation = npcBot:GetLocation();
	local targetLocation = npcTarget:GetLocation();
	local direction = (targetLocation - botLocation):Normalized();
	return botLocation + (direction * maxAbilityRange)
end

-- Mage enemy check
local M = {}
local mageEnemyCheck = false;

M['mageHeroes'] = {
	["npc_dota_hero_ancient_apparition"] = 1,
	["npc_dota_hero_crystal_maiden"] = 1,
	["npc_dota_hero_disruptor"] = 1,
	["npc_dota_hero_death_prophet"] = 1,
	["npc_dota_hero_dark_willow"] = 1,
	["npc_dota_hero_earthshaker"] = 1,
	["npc_dota_hero_ember_spirit"] = 1,
	["npc_dota_hero_grimstroke"] = 1,
	["npc_dota_hero_hoodwink"] = 1,
	["npc_dota_hero_invoker"] = 1,
	["npc_dota_hero_jakiro"] = 1,
	["npc_dota_hero_leshrac"] = 1,
	["npc_dota_hero_lich"] = 1,
	["npc_dota_hero_lina"] = 1,
	["npc_dota_hero_lion"] = 1,
	["npc_dota_hero_magnataur"] = 1,
	["npc_dota_hero_ogre_magi"] = 1,
	["npc_dota_hero_oracle"] = 1,
	["npc_dota_hero_phoenix"] = 1,
	["npc_dota_hero_puck"] = 1,
	["npc_dota_hero_pugna"] = 1,
	["npc_dota_hero_queenofpain"] = 1,
	["npc_dota_hero_rattletrap"] = 1,
	["npc_dota_hero_razor"] = 1,
	["npc_dota_hero_sand_king"] = 1,
	["npc_dota_hero_shadow_demon"] = 1,
	["npc_dota_hero_shadow_shaman"] = 1,
	["npc_dota_hero_silencer"] = 1,
	["npc_dota_hero_skywrath_mage"] = 1,
	["npc_dota_hero_snapfire"] = 1,
	["npc_dota_hero_storm_spirit"] = 1,
	["npc_dota_hero_techies"] = 1,
	["npc_dota_hero_tidehunter"] = 1,
	["npc_dota_hero_tiny"] = 1,
	["npc_dota_hero_venomancer"] = 1,
	["npc_dota_hero_viper"] = 1,
	["npc_dota_hero_visage"] = 1,
	["npc_dota_hero_warlock"] = 1,
	["npc_dota_hero_winter_wyvern"] = 1,
	["npc_dota_hero_witch_doctor"] = 1,
	["npc_dota_hero_zuus"] = 1,
}

function HaveMagesInEnemyTeam()
	if mageEnemyCheck == false and DotaTime() >= 3 * 60
	then
		local players = GetTeamPlayers(GetOpposingTeam());
		for i = 1, #players do
			if M["mageHeroes"][GetSelectedHeroName(players[i])] == 1
			then
				return true;
			end
		end
		mageEnemyCheck = true;
	end
end

function PurchaseInfusedRaindrop(npcBot)
	if npcBot:GetGold() < GetItemCost("item_infused_raindrop") * 2 or IsItemSlotsFull() or IsStashSlotsFull() or GetItemStockCount("item_infused_raindrop") < 1
		or npcBot:GetLevel() > 10 or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or not npcBot:IsAlive()
	then
		return;
	end

	local courier = GetBotCourier(npcBot);

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_infused_raindrop"
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_infused_raindrop"
		then
			return;
		end
	end

	if HaveMagesInEnemyTeam()
	then
		--npcBot:ActionImmediate_Chat("Покупаю infused raindrop против врагов магов!", true);
		npcBot:ActionImmediate_PurchaseItem("item_infused_raindrop");
		return;
	end
end

-- Invis enemy check
local X = {}

X['invisEnemyExist'] = false;
local globalEnemyCheck = false;
local lastCheck = -90;

X['invisHeroes'] = {
	['npc_dota_hero_templar_assassin'] = 1,
	['npc_dota_hero_clinkz'] = 1,
	['npc_dota_hero_mirana'] = 1,
	['npc_dota_hero_riki'] = 1,
	['npc_dota_hero_nyx_assassin'] = 1,
	['npc_dota_hero_bounty_hunter'] = 1,
	['npc_dota_hero_invoker'] = 1,
	['npc_dota_hero_sand_king'] = 1,
	['npc_dota_hero_treant'] = 1,
	--['npc_dota_hero_broodmother'] = 1,
	['npc_dota_hero_weaver'] = 1,
	['npc_dota_hero_hoodwink'] = 1,
}

function UpdateInvisEnemyStatus(bot)
	if globalEnemyCheck == false
	then
		local players = GetTeamPlayers(GetOpposingTeam());
		for i = 1, #players do
			if X["invisHeroes"][GetSelectedHeroName(players[i])] == 1
			then
				X['invisEnemyExist'] = true;
				break;
			end
		end
		globalEnemyCheck = true;
	elseif globalEnemyCheck == true and DotaTime() >= 5 * 60 and DotaTime() > lastCheck + 3.0
	then
		local enemies = bot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
		if #enemies > 0
		then
			for i = 1, #enemies
			do
				if enemies[i] ~= nil and enemies[i]:IsNull() == false and enemies[i]:CanBeSeen() == true
				then
					local SASlot = enemies[i]:FindItemSlot("item_shadow_amulet");
					local GCSlot = enemies[i]:FindItemSlot("item_glimmer_cape");
					local ISSlot = enemies[i]:FindItemSlot("item_invis_sword");
					local SESlot = enemies[i]:FindItemSlot("item_silver_edge");
					if SASlot >= 0 or GCSlot >= 0 or ISSlot >= 0 or SESlot >= 0
					then
						X['invisEnemyExist'] = true;
						break;
					end
				end
			end
		end
		lastCheck = DotaTime();
	end
end

function PurchaseDust(npcBot)
	if npcBot:GetGold() < GetItemCost("item_dust") * 2 or IsItemSlotsFull() or IsStashSlotsFull() or DotaTime() < 5 * 60
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) or not npcBot:IsAlive()
	then
		return;
	end

	local courier = GetBotCourier(npcBot);

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_dust"
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_dust"
		then
			return;
		end
	end

	UpdateInvisEnemyStatus(npcBot)

	if X['invisEnemyExist'] == true
	then
		--npcBot:ActionImmediate_Chat("Покупаю dust против невидимых врагов!", true);
		npcBot:ActionImmediate_PurchaseItem("item_dust");
		return;
	end
end

function GetLineForPush()
	local npcBot = GetBot();
	local botLevel = npcBot:GetLevel();
	local countEnemyTopBuilding = 5;
	local countEnemyMidBuilding = 5;
	local countEnemyBotBuilding = 5;

	local countAllyTopBuilding = 5;
	local countAllyMidBuilding = 5;
	local countAllyBotBuilding = 5;

	local lanes = {
		LANE_TOP,
		LANE_MID,
		LANE_BOT,
	}

	local towersTop = {
		TOWER_TOP_1,
		TOWER_TOP_2,
		TOWER_TOP_3,
	}

	local barracksTop = {
		BARRACKS_TOP_MELEE,
		BARRACKS_TOP_RANGED,
	}

	local towersMid = {
		TOWER_MID_1,
		TOWER_MID_2,
		TOWER_MID_3,
	}

	local barracksMid = {
		BARRACKS_MID_MELEE,
		BARRACKS_MID_RANGED,
	}

	local towersBot = {
		TOWER_BOT_1,
		TOWER_BOT_2,
		TOWER_BOT_3,
	}

	local barracksBot = {
		BARRACKS_BOT_MELEE,
		BARRACKS_BOT_RANGED,
	}

	-- TOP LINE
	for _, t in pairs(towersTop)
	do
		local allyTower = GetTower(GetTeam(), t);
		local enemyTower = GetTower(GetOpposingTeam(), t);
		if allyTower == nil or not allyTower:IsAlive()
		then
			countAllyTopBuilding = countAllyTopBuilding - 1;
		end
		if enemyTower == nil or not enemyTower:IsAlive()
		then
			countEnemyTopBuilding = countEnemyTopBuilding - 1;
		end
	end

	for _, b in pairs(barracksTop)
	do
		local allybarrack = GetBarracks(GetTeam(), b);
		local enemyBarrack = GetBarracks(GetOpposingTeam(), b);
		if allyBarrack == nil or not allybarrack:IsAlive()
		then
			countAllyTopBuilding = countAllyTopBuilding - 1;
		end
		if enemyBarrack == nil or not enemyBarrack:IsAlive()
		then
			countEnemyTopBuilding = countEnemyTopBuilding - 1;
		end
	end

	-- MID LINE
	for _, t in pairs(towersMid)
	do
		local allyTower = GetTower(GetTeam(), t);
		local enemyTower = GetTower(GetOpposingTeam(), t);
		if allyTower == nil or not allyTower:IsAlive()
		then
			countAllyMidBuilding = countAllyMidBuilding - 1;
		end
		if enemyTower == nil or not enemyTower:IsAlive()
		then
			countEnemyMidBuilding = countEnemyMidBuilding - 1;
		end
	end

	for _, b in pairs(barracksMid)
	do
		local allybarrack = GetBarracks(GetTeam(), b);
		local enemyBarrack = GetBarracks(GetOpposingTeam(), b);
		if allyBarrack == nil or not allybarrack:IsAlive()
		then
			countAllyMidBuilding = countAllyMidBuilding - 1;
		end
		if enemyBarrack == nil or not enemyBarrack:IsAlive()
		then
			countEnemyMidBuilding = countEnemyMidBuilding - 1;
		end
	end

	-- BOT LINE
	for _, t in pairs(towersBot)
	do
		local allyTower = GetTower(GetTeam(), t);
		local enemyTower = GetTower(GetOpposingTeam(), t);
		if allyTower == nil or not allyTower:IsAlive()
		then
			countAllyBotBuilding = countAllyBotBuilding - 1;
		end
		if enemyTower == nil or not enemyTower:IsAlive()
		then
			countEnemyBotBuilding = countEnemyBotBuilding - 1;
		end
	end

	for _, b in pairs(barracksBot)
	do
		local allybarrack = GetBarracks(GetTeam(), b);
		local enemyBarrack = GetBarracks(GetOpposingTeam(), b);
		if allyBarrack == nil or not allybarrack:IsAlive()
		then
			countAllyBotBuilding = countAllyBotBuilding - 1;
		end
		if enemyBarrack == nil or not enemyBarrack:IsAlive()
		then
			countEnemyBotBuilding = countEnemyBotBuilding - 1;
		end
	end

	local strongestEnemyLane = math.max(countEnemyTopBuilding, countEnemyMidBuilding, countEnemyBotBuilding);
	local weakestAllyLane = math.min(countAllyTopBuilding, countAllyMidBuilding, countAllyBotBuilding);

	--local botLocation = npcBot:GetLocation();
	--local botAmountTop = GetAmountAlongLane(LANE_TOP, botLocation);
	--local botAmountMid = GetAmountAlongLane(LANE_MID, botLocation);
	--local botAmountBot = GetAmountAlongLane(LANE_BOT, botLocation);
	--local frontlocationTop = GetLaneFrontLocation(npcBot:GetTeam(), LANE_TOP, 0);
	--local frontlocationMid = GetLaneFrontLocation(npcBot:GetTeam(), LANE_MID, 0);
	--local frontlocationBot = GetLaneFrontLocation(npcBot:GetTeam(), LANE_BOT, 0);

	--[[ 	if weakestEnemyLane == countEnemyTopBuilding and (GetUnitToLocationDistance(npcBot, frontlocationTop) < GetUnitToLocationDistance(npcBot, frontlocationMid))
		and (GetUnitToLocationDistance(npcBot, frontlocationTop) < GetUnitToLocationDistance(npcBot, frontlocationBot))
	then
		currentLine = LANE_TOP;
	elseif weakestEnemyLane == countEnemyMidBuilding and (GetUnitToLocationDistance(npcBot, frontlocationMid) < GetUnitToLocationDistance(npcBot, frontlocationTop))
		and (GetUnitToLocationDistance(npcBot, frontlocationMid) < GetUnitToLocationDistance(npcBot, frontlocationBot))
	then
		currentLine = LANE_MID;
	elseif weakestEnemyLane == countEnemyBotBuilding and (GetUnitToLocationDistance(npcBot, frontlocationBot) < GetUnitToLocationDistance(npcBot, frontlocationTop))
		and (GetUnitToLocationDistance(npcBot, frontlocationBot) < GetUnitToLocationDistance(npcBot, frontlocationMid))
	then
		currentLine = LANE_BOT;
	end ]]

	if (DotaTime() >= 10 * 60) or (botLevel > 6)
	then
		if strongestEnemyLane ~= 0 and ((countEnemyTopBuilding ~= countEnemyMidBuilding and countEnemyTopBuilding ~= countEnemyBotBuilding)
				and (countEnemyMidBuilding ~= countEnemyTopBuilding and countEnemyMidBuilding ~= countEnemyBotBuilding)
				and (countEnemyBotBuilding ~= countEnemyTopBuilding and countEnemyBotBuilding ~= countEnemyMidBuilding))
		then
			if strongestEnemyLane == countEnemyTopBuilding
			then
				currentLine = LANE_TOP;
			end
			if strongestEnemyLane == countEnemyMidBuilding
			then
				currentLine = LANE_MID;
			end
			if strongestEnemyLane == countEnemyBotBuilding
			then
				currentLine = LANE_BOT;
			end
		elseif weakestAllyLane ~= 0 and ((countAllyTopBuilding ~= countAllyMidBuilding and countAllyTopBuilding ~= countAllyBotBuilding)
				and (countAllyMidBuilding ~= countAllyTopBuilding and countAllyMidBuilding ~= countAllyBotBuilding)
				and (countAllyBotBuilding ~= countAllyTopBuilding and countAllyBotBuilding ~= countAllyMidBuilding))
		then
			if weakestAllyLane == countAllyTopBuilding
			then
				currentLine = LANE_TOP;
			end
			if weakestAllyLane == countAllyMidBuilding
			then
				currentLine = LANE_MID;
			end
			if weakestAllyLane == countAllyBotBuilding
			then
				currentLine = LANE_BOT;
			end
		else
			currentLine = npcBot:GetAssignedLane();
		end
	else
		currentLine = npcBot:GetAssignedLane();
	end

	return currentLine;

	--currentLine = lanes[RandomInt(1, #lanes)];
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(utility) do _G._savedEnv[k] = v end



--[[ function PurchaseBootsAndTP(npcBot)
	local hasTravelBoots = false;
	local tpScroll = nil;
	local otherBoots = nil;

	for i = 0, 14 do
		local item = npcBot:GetItemInSlot(i);
		if (item) and item:GetName() == "item_travel_boots" or item:GetName() == "item_travel_boots_2" then
			hasTravelBoots = true;
		end
		if (item) and item:GetName() == "item_tpscroll" then
			tpScroll = item;
		end
		if (item) and (item:GetName() == "item_phase_boots" or item:GetName() == "item_arcane_boots") then
			otherBoots = item;
		end
	end

	if hasTravelBoots then
		if tpScroll > 1 and npcBot:DistanceFromFountain() <= 1000 or npcBot:DistanceFromSecretShop() <= 200 then
			npcBot:ActionImmediate_SellItem(tpScroll);
		end
		if otherBoots ~= nil and npcBot:DistanceFromFountain() <= 1000 or npcBot:DistanceFromSecretShop() <= 200 then
			npcBot:ActionImmediate_SellItem(otherBoots);
		end
	else
		PurchaseTP(npcBot);
	end
end ]]
--[[ function PurchaseBootsAndTP(npcBot)
	local hasTravelBoots = false;
	local tpScroll = nil;
	local otherBoots = nil;

	for i = 0, 14 do
		local item = npcBot:GetItemInSlot(i);
		if (item) and item:GetName() == "item_travel_boots" then
			hasTravelBoots = true;
		end
		if (item) and item:GetName() == "item_tpscroll" then
			tpScroll = item;
		end
		if (item) and (item:GetName() == "item_phase_boots" or item:GetName() == "item_arcane_boots") then
			otherBoots = item;
		end
	end

	if hasTravelBoots then
		if tpScroll > 1 then
			npcBot:ActionImmediate_SellItem(tpScroll);
		end
		if otherBoots ~= nil then
			npcBot:ActionImmediate_SellItem(otherBoots);
		end
	else
		PurchaseTP(npcBot);
	end
end ]]
--[[ 	if GetItemByName(npcBot, "item_tome_of_knowledge", true, true) then
		return;
	else
		npcBot:ActionImmediate_Chat("Покупаю tome_of_knowledge!", true);
		npcBot:ActionImmediate_PurchaseItem("item_tome_of_knowledge");
		return;
	end ]]
--[[ 	if (npcBot.idletime == nil)
	then
		npcBot.idletime = GameTime()
	else
		if (GameTime() - npcBot.idletime >= 1 * 60) and item == nil
		then
			npcBot:ActionImmediate_PurchaseItem("item_tome_of_knowledge");
			npcBot.idletime = nil
			--npcBot:ActionImmediate_Chat("Покупаю tome_of_knowledge!", true);
			return
		end
	end ]]
