---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("utility", package.seeall)
require(GetScriptDirectory() .. "/hero_role_generic")

function IsValidTarget(target)
	if target ~= nil
	then
		if target:CanBeSeen() and
			target:IsAlive()
		then
			return true;
		end
	end
	return false;
end

function GetFountain(npcTarget)
	if IsValidTarget(npcTarget)
	then
		if npcTarget:GetTeam() == TEAM_RADIANT
		then
			local buildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
			if (#buildings > 0)
			then
				for _, ally in pairs(buildings)
				do
					if IsValidTarget(ally) and ally:GetName() == "dota_fountain"
					then
						return ally;
					end
				end
			end
		elseif npcTarget:GetTeam() == TEAM_DIRE
		then
			local buildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
			if (#buildings > 0)
			then
				for _, ally in pairs(buildings)
				do
					if IsValidTarget(ally) and ally:GetName() == "dota_fountain"
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
	if not utility.IsHero(npcTarget)
	then
		return nil;
	end

	local targetStrenght = npcTarget:GetAttributeValue(ATTRIBUTE_STRENGTH);
	local targetAgility = npcTarget:GetAttributeValue(ATTRIBUTE_AGILITY);
	local targetIntellect = npcTarget:GetAttributeValue(ATTRIBUTE_INTELLECT);
	--local biggerAttribute = (math.max(targetStrenght, targetAgility, targetIntellect));

	if (targetStrenght > targetAgility) and (targetStrenght > targetIntellect)
	then
		return ATTRIBUTE_STRENGTH;
	elseif (targetAgility > targetStrenght) and (targetAgility > targetIntellect)
	then
		return ATTRIBUTE_AGILITY;
	elseif (targetIntellect > targetStrenght) and (targetIntellect > targetAgility)
	then
		return ATTRIBUTE_INTELLECT;
	else
		return ATTRIBUTE_STRENGTH;
	end
end

function GetCurretCastDistance(castRangeAbility)
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

function IsIllusion(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsIllusion() or
			npcTarget:HasModifier("modifier_illusion") or
			npcTarget:HasModifier("modifier_antimage_blink_illusion") or
			npcTarget:HasModifier("modifier_bane_fiends_grip_illusion") or
			npcTarget:HasModifier("modifier_chaos_knight_phantasm_illusion") or
			npcTarget:HasModifier("modifier_hoodwink_decoy_illusion") or
			npcTarget:HasModifier("modifier_darkseer_wallofreplica_illusion") or
			npcTarget:HasModifier("modifier_terrorblade_conjureimage") or
			npcTarget:HasModifier("modifier_phantom_lancer_juxtapose_illusion"))
end

function IsAlly(npcBot, npcTarget)
	return IsValidTarget(npcBot) and IsValidTarget(npcTarget) and npcBot:GetTeam() == npcTarget:GetTeam();
end

function IsHero(npcTarget)
	local npcBot = GetBot();
	if IsValidTarget(npcTarget) and npcTarget:IsHero()
	then
		if IsAlly(npcBot, npcTarget)
		then
			if not IsIllusion(npcTarget)
			then
				return true;
			end
		end
		return true;
	else
		return false;
	end
end

function IsBuilding(npcTarget)
	return IsValidTarget(npcTarget) and
		npcTarget:IsTower() or npcTarget:IsFort() or npcTarget:IsBarracks() or
		string.find(npcTarget:GetUnitName(), "rax") or
		string.find(npcTarget:GetUnitName(), "tower") or
		string.find(npcTarget:GetUnitName(), "fort");
end

function IsRoshan(npcTarget)
	return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "roshan");
end

function IsDisabled(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsDominated() or
			npcTarget:IsHexed() or
			npcTarget:IsNightmared() or
			npcTarget:IsRooted() or
			npcTarget:IsStunned())
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

function IsBusy(npcTarget)
	return IsValidTarget(npcTarget) and
		( --npcTarget:IsUsingAbility() or
		--npcTarget:IsCastingAbility() or
			npcTarget:IsChanneling())
end

function IsAbilityAvailable(ability)
	return ability:IsFullyCastable() and
		ability:IsActivated() and
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
		local unitList = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
		if #unitList > 0
		then
			for _, creep in pairs(unitList)
			do
				if IsValidTarget(creep) and creep:GetUnitName() == unitName
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
				if IsValidTarget(creep) and creep:GetUnitName() == unitName
				then
					if GetUnitToUnitDistance(creep, target) <= radius
					then
						count = count + 1;
					end
				end
			end
		end
	elseif bEnemy == false
	then
		local unitList = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
		if #unitList > 0
		then
			for _, creep in pairs(unitList)
			do
				if IsValidTarget(creep) and creep:GetUnitName() == unitName
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
				if IsValidTarget(creep) and creep:GetUnitName() == unitName
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
		not npcTarget:IsIllusion() and
		--not npcTarget:IsUsingAbility() and
		not npcTarget:IsCastingAbility() and
		not npcTarget:IsChanneling() and
		not npcTarget:IsSilenced() and
		not npcTarget:IsDominated() and
		not npcTarget:IsStunned() and
		not npcTarget:IsHexed() and
		not npcTarget:IsNightmared()
end

function CanCastWhenChanneling(npcTarget)
	return npcTarget:IsAlive() and
		not npcTarget:IsCastingAbility() and
		not npcTarget:IsSilenced() and
		not npcTarget:IsDominated() and
		not npcTarget:IsStunned() and
		not npcTarget:IsHexed() and
		not npcTarget:IsNightmared()
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
			npcTarget:HasModifier("modifier_oracle_false_promise_timer"))
end

function IsTargetInvulnerable(npcTarget)
	return IsValidTarget(npcTarget) and
		(npcTarget:IsInvulnerable() or
			npcTarget:HasModifier("modifier_item_aeon_disk_buff") or
			npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") or
			npcTarget:HasModifier("modifier_abaddon_aphotic_shield") or
			npcTarget:HasModifier("modifier_abaddon_borrowed_time") or
			npcTarget:HasModifier("modifier_fountain_glyph"));
end

function CanBeHeal(npcTarget)
	return IsValidTarget(npcTarget) and not npcTarget:HasModifier("modifier_ice_blast")
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
						return CanCastOnMagicImmuneTarget(npcTarget);
					elseif damageType == DAMAGE_TYPE_PHYSICAL
					then
						return CanCastOnInvulnerableTarget(npcTarget)
					elseif damageType == DAMAGE_TYPE_PURE
					then
						return not npcTarget:HasModifier("modifier_black_king_bar_immune");
					end
				end
			else
				return CanCastOnMagicImmuneTarget(npcTarget);
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

function PvPMode(npcBot)
	local botMode = npcBot:GetActiveMode();
	return (botMode == BOT_MODE_ATTACK or
		botMode == BOT_MODE_ROAM or
		botMode == BOT_MODE_TEAM_ROAM or
		botMode == BOT_MODE_DEFEND_ALLY or
		botMode == BOT_MODE_EVASIVE_MANEUVERS);
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
		botMode == BOT_MODE_RUNE or
		botMode == BOT_MODE_ITEM or
		botMode == BOT_MODE_ASSEMBLE or
		botMode == BOT_MODE_SHRINE or
		botMode == BOT_MODE_ROSHAN);
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

function HaveItem(npc, itemName)
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
end

function GetItemCount(npc, item_name)
	local count = 0;
	for i = 0, 8
	do
		local item = npc:GetItemInSlot(i)
		if item ~= nil and item:GetName() == item_name
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
			return npcTarget:GetModifierStackCount(modifier)
		else
			return 0;
		end
	else
		return 0;
	end
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
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
	then
		return;
	end

	--print(tostring(npcBot:GetNextItemPurchaseValue()))

	local courier = GetBotCourier(npcBot);
	local assignedLane = npcBot:GetAssignedLane();

	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_ward_observer"
		then
			return;
		end
	end

	for i = 0, 8 do
		local item = courier:GetItemInSlot(i);
		if item ~= nil and item:GetName() == "item_ward_observer"
		then
			return;
		end
	end

	if assignedLane == LANE_MID and GetGameState() == GAME_STATE_PRE_GAME
	then
		npcBot:ActionImmediate_PurchaseItem("item_ward_observer");
		--npcBot:ActionImmediate_Chat("Покупаю вард на мид!", true);
		return;
	elseif HaveHumanInTeam(npcBot)
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
	elseif not HaveHumanInTeam(npcBot)
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
end

function PurchaseTP(npcBot)
	if npcBot:GetGold() < GetItemCost("item_tpscroll") or IsStashSlotsFull() or HaveTravelBoots(npcBot)
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
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
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
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

	--npcBot:ActionImmediate_Chat("Покупаю BOTTLE!", true);
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
		or npcBot:GetLevel() > 10 or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
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
	['npc_dota_hero_broodmother'] = 1,
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
		or (npcBot:GetNextItemPurchaseValue() > 0 and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
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
	end
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
