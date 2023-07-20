---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("utility", package.seeall)
require(GetScriptDirectory() .. "/hero_role_generic")

function GetWeakestUnit(EnemyUnits)
	if EnemyUnits == nil or #EnemyUnits == 0 then
		return nil, 10000;
	end

	local WeakestUnit = nil;
	local LowestHealth = 10000;
	for _, unit in pairs(EnemyUnits)
	do
		if unit ~= nil and unit:IsAlive()
		then
			if unit:GetHealth() < LowestHealth
			then
				LowestHealth = unit:GetHealth();
				WeakestUnit = unit;
			end
		end
	end

	return WeakestUnit, LowestHealth
end

function GetStrongestUnit(EnemyUnits)
	if EnemyUnits == nil or #EnemyUnits == 0 then
		return nil, 0;
	end

	local StrongestUnit = nil;
	local HighestHealth = 0;
	for _, unit in pairs(EnemyUnits)
	do
		if unit ~= nil and unit:IsAlive()
		then
			if unit:GetHealth() > HighestHealth
			then
				HighestHealth = unit:GetHealth();
				StrongestUnit = unit;
			end
		end
	end

	return StrongestUnit, HighestHealth
end

function IsValidTarget(target)
	return target ~= nil and
		target:IsAlive() and
		target:CanBeSeen() and
		not target:IsInvulnerable()
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

	if (itemCount >= 8)
	then
		return true;
	else
		return false;
	end
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

	if (itemCount >= 6)
	then
		return true;
	else
		return false;
	end
end

function GetBotCourier(npcBot)
	local courier = GetCourier(0)
	local numPlayer = GetTeamPlayers(GetTeam())
	for i = 1, #numPlayer do
		local member = GetTeamMember(i)
		if member ~= nil and member:GetUnitName() == npcBot:GetUnitName()
		then
			courier = GetCourier(i - 1)
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

function IsRoshan(npcTarget)
	return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "roshan");
end

function IsHero(npcTarget)
	return IsValidTarget(npcTarget) and npcTarget:IsHero() and not IsIllusion(npcTarget);
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
	return IsValidTarget(npcTarget) and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_IDLE and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_DELAY and
		npcTarget:GetCurrentActionType() ~= BOT_ACTION_TYPE_NONE and
		not npcTarget:IsRooted() and
		not npcTarget:IsStunned() and
		not npcTarget:IsNightmared()
		and npcTarget:GetBaseMovementSpeed() > 0
end

function GetTargetPosition(npcTarget, fdelay)
	if IsMoving(npcTarget)
	then
		return npcTarget:GetExtrapolatedLocation(fdelay);
	else
		return npcTarget:GetLocation();
	end
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

function IsAbilityAvailable(ability)
	return ability:IsFullyCastable() and
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

function CanCast(npcTarget)
	return npcTarget:IsAlive() and
		not npcTarget:IsUsingAbility() and
		not npcTarget:IsCastingAbility() and
		not npcTarget:IsChanneling() and
		not npcTarget:IsSilenced() and
		not npcTarget:IsDominated() and
		not npcTarget:IsStunned() and
		not npcTarget:IsHexed() and
		not npcTarget:IsNightmared()
end

function CanAbilityKillTarget(npcTarget, damage, damagetype)
	if IsValidTarget(npcTarget) and npcTarget:GetActualIncomingDamage(damage, damagetype) >= npcTarget:GetHealth()
	then
		return true;
	else
		return false;
	end
end

function TargetCantDie(npcTarget)
	return IsValidTarget(npcTarget) and npcTarget:GetHealth() / npcTarget:GetMaxHealth() <= 0.3 and
		(npcTarget:HasModifier("modifier_dazzle_shallow_grave") or
			npcTarget:HasModifier("modifier_oracle_false_promise_timer") or
			npcTarget:HasModifier("modifier_item_aeon_disk_buff") or
			npcTarget:HasModifier("modifier_templar_assassin_refraction_absorb") or
			npcTarget:HasModifier("modifier_abaddon_aphotic_shield"));
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
		not npcTarget:HasModifier("modifier_black_king_bar_immune");
end

function CanCastOnInvulnerableTarget(npcTarget)
	return IsValidTarget(npcTarget) and not npcTarget:IsInvulnerable() and
		not npcTarget:HasModifier("modifier_invulnerable");
end

function CanCastOnMagicImmuneAndInvulnerableTarget(npcTarget)
	return CanCastOnMagicImmuneTarget(npcTarget) and CanCastOnInvulnerableTarget(npcTarget);
end

--[[ function CanCastSpellOnTarget(npcTarget, damageType)
	if damageType == DAMAGE_TYPE_MAGICAL
	then
		return CanCastOnMagicImmuneTarget(npcTarget);
	elseif damageType == DAMAGE_TYPE_PHYSICAL
	then
		return CanCastOnInvulnerableTarget(npcTarget);
	elseif damageType == DAMAGE_TYPE_PURE
	then
		return IsValidTarget(npcTarget) and not npcTarget:HasModifier("modifier_black_king_bar_immune");
	else
		return IsValidTarget(npcTarget);
	end
end ]]

function CanCastSpellOnTarget(spell, npcTarget)
	local damageType = spell:GetDamageType();

	if damageType == DAMAGE_TYPE_MAGICAL
	then
		return CanCastOnMagicImmuneTarget(npcTarget);
	elseif damageType == DAMAGE_TYPE_PHYSICAL
	then
		return CanCastOnInvulnerableTarget(npcTarget);
	elseif damageType == DAMAGE_TYPE_PURE
	then
		return IsValidTarget(npcTarget) and not npcTarget:HasModifier("modifier_black_king_bar_immune");
	else
		return IsValidTarget(npcTarget);
	end
end


function SafeCast(npcTarget, bfullSafe)
	if IsValidTarget(npcTarget) and
		(npcTarget:HasModifier("modifier_antimage_counterspell")
			or npcTarget:HasModifier("modifier_item_sphere_target")
			or npcTarget:HasModifier("modifier_item_lotus_orb_active")
			or npcTarget:HasModifier("modifier_nyx_assassin_spiked_carapace"))
	then
		return false;
	elseif bfullSafe == true
	then
		if IsValidTarget(npcTarget) and npcTarget:HasModifier("modifier_abaddon_borrowed_time")
		then
			return false;
		end
		return true;
	else
		return true;
	end
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
		botMode == BOT_MODE_ROSHAN);
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
	if npcTarget:CanBeSeen()
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
	if npcBot:GetGold() < GetItemCost("item_ward_observer") or IsItemSlotsFull() or GetItemStockCount("item_ward_observer") < 1
	then
		return;
	end

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

function HaveTravelBoots(npcBot)
	for i = 0, 16 do
		local item = npcBot:GetItemInSlot(i);
		if item ~= nil and (item:GetName() == "item_travel_boots" or item:GetName() == "item_travel_boots_2")
		then
			return true;
		else
			return false;
		end
	end
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
	if BotTeam == TEAM_RADIANT then
		return Vector(-7232.0, -6888.0, 364.5);
	elseif BotTeam == TEAM_DIRE then
		return Vector(7168.0, 6836.4, 423.6);
	end
end

function GetEscapeLocation(bot, maxAbilityRadius)
	local botLocation = bot:GetLocation()
	local direction = (SafeLocation(bot) - botLocation):Normalized();
	return botLocation + (direction * maxAbilityRadius)
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
	if npcBot:GetGold() < GetItemCost("item_dust") or IsItemSlotsFull() or DotaTime() < 5 * 60
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
