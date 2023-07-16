---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("ability_item_usage_generic", package.seeall)

--[[ local utility = require(GetScriptDirectory() .. "/utility")
local wardUsage = require(GetScriptDirectory() .. "/ward_usage_generic")
local teleportUsage = require(GetScriptDirectory() .. "/teleportation_usage_generic") ]]
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ward_usage_generic")
require(GetScriptDirectory() .. "/teleportation_usage_generic")

--#region COURIER THINK
function CourierUsageThink()
	local npcBot = GetBot();
	local courier = utility.GetBotCourier(npcBot);
	local state = GetCourierState(courier);

	if (state == COURIER_STATE_DEAD) or not utility.IsHero(npcBot) or npcBot:HasModifier("modifier_arc_warden_tempest_double")
	then
		return;
	end

	local burst = courier:GetAbilityByName("courier_burst");
	local shield = courier:GetAbilityByName("courier_shield");
	local canCastBurst = burst ~= nil and burst:IsFullyCastable();
	local canCastShield = shield ~= nil and shield:IsFullyCastable();
	local courierHealth = courier:GetHealth() / courier:GetMaxHealth();

	if not courier:IsInvulnerable()
	then
		if utility.CountEnemyHeroAroundUnit(courier, 1000) > 0 or utility.CountEnemyTowerAroundUnit(courier, 1000) > 0 or courierHealth <= 0.9
		then
			if (canCastBurst) and (state == COURIER_STATE_MOVING)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST);
				return;
			end
			if (canCastShield)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SHIELD);
				return;
				--courier:Action_UseAbility(shield);
			end
			if (state ~= COURIER_STATE_AT_BASE) and (state ~= COURIER_STATE_RETURNING_TO_BASE)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN_STASH_ITEMS);
				return;
			end
			return;
		end
	end

	if (state == COURIER_STATE_DELIVERING_ITEMS)
	then
		if (canCastBurst)
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST);
			return;
		end
	end
	if (state == COURIER_STATE_IDLE)
	then
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN_STASH_ITEMS);
		return;
	end

	if (state ~= COURIER_STATE_MOVING) and (state ~= COURIER_STATE_DELIVERING_ITEMS)
	then
		if npcBot:IsAlive()
		then
			if (npcBot:GetStashValue() > 100) and (state == COURIER_STATE_AT_BASE)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS);
				return;
			elseif (npcBot:GetCourierValue() > 0)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TRANSFER_ITEMS);
				return;
			elseif (npcBot.secretShopMode == true) and (npcBot:DistanceFromSecretShop() >= 3000) and (courier:DistanceFromSecretShop() > 200)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SECRET_SHOP);
				return;
			end
		elseif not npcBot:IsAlive()
		then
			if (npcBot.secretShopMode == true) and (courier:DistanceFromSecretShop() > 200)
			then
				npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SECRET_SHOP);
				return;
			end
		end
	end
end

--#endregion

--#region BUYBACK THINK
function BuybackUsageThink()
	local npcBot = GetBot();

	if not npcBot:IsHero() or npcBot:IsIllusion()
	then
		return;
	elseif npcBot:IsAlive()
	then
		return;
	elseif not npcBot:IsAlive() and not npcBot:HasBuyback()
	then
		return;
	end

	local respawnTime = npcBot:GetRespawnTime();

	if npcBot:HasBuyback() and not npcBot:IsAlive() and (respawnTime > 60.0)
	then
		if (npcBot.idletime == nil)
		then
			npcBot.idletime = GameTime()
		else
			if (GameTime() - npcBot.idletime >= 5)
			then
				npcBot.idletime = nil;
				npcBot:ActionImmediate_Buyback();
				npcBot:ActionImmediate_Chat("Выкупаюсь!", false);
				return;
			end
		end
	end
end

--#endregion

--#region GLYPH THINK

function GlyphUsageThink(npcBot)
	if GetGlyphCooldown() > 0 then
		return;
	end

	local towers = {
		TOWER_TOP_1,
		TOWER_TOP_2,
		TOWER_TOP_3,
		TOWER_MID_1,
		TOWER_MID_2,
		TOWER_MID_3,
		TOWER_BOT_1,
		TOWER_BOT_2,
		TOWER_BOT_3,
		TOWER_BASE_1,
		TOWER_BASE_2,
	}

	for _, t in pairs(towers)
	do
		local tower = GetTower(GetTeam(), t);
		if tower ~= nil and (tower:GetHealth() / tower:GetMaxHealth() <= 0.7) and utility.IsTargetedByEnemy(tower, true)
		then
			npcBot:ActionImmediate_Chat("Использую Glyph для защиты башни!", false);
			npcBot:ActionImmediate_Ping(tower:GetLocation().x, tower:GetLocation().y, false);
			npcBot:ActionImmediate_Glyph();
			return;
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
		if barrack ~= nil and (barrack:GetHealth() / barrack:GetMaxHealth() <= 0.8) and utility.IsTargetedByEnemy(barrack, true)
		then
			npcBot:ActionImmediate_Chat("Использую Glyph для защиты барраков!", false);
			npcBot:ActionImmediate_Ping(barrack:GetLocation().x, barrack:GetLocation().y, false);
			npcBot:ActionImmediate_Glyph();
			return;
		end
	end

	local ancient = GetAncient(GetTeam());
	if ancient ~= nil and (ancient:GetHealth() / ancient:GetMaxHealth() <= 0.8) and utility.IsTargetedByEnemy(ancient, true)
	then
		npcBot:ActionImmediate_Chat("Использую Glyph для защиты Древнего!", false);
		npcBot:ActionImmediate_Ping(ancient:GetLocation().x, ancient:GetLocation().y, false);
		npcBot:ActionImmediate_Glyph();
		return;
	end
end

--#endregion

--#region ITEM USAGE THINK
function HaveHealthRegenBuff(target)
	return target:HasModifier('modifier_fountain_aura_buff')
		or target:HasModifier('modifier_bottle_regeneration')
		or target:HasModifier('modifier_flask_healing');
end

function HaveManaRegenBuff(target)
	return target:HasModifier('modifier_fountain_aura_buff')
		or target:HasModifier('modifier_bottle_regeneration')
		or target:HasModifier('modifier_clarity_potion');
end

function IsItemAvailable(item_name)
	local npcBot = GetBot();
	local slot = npcBot:FindItemSlot(item_name);
	if npcBot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
	then
		return npcBot:GetItemInSlot(slot);
	end
	return nil;
end

function ItemUsageThink()
	local npcBot = GetBot();
	GlyphUsageThink(npcBot)

	if not npcBot:IsAlive() or npcBot:IsMuted() or npcBot:IsDominated() or npcBot:IsStunned() or npcBot:IsHexed() or npcBot:IsNightmared()
	then
		return;
	end

	local botMode = npcBot:GetActiveMode();
	local attackRange = npcBot:GetAttackRange();
	local botTarget = npcBot:GetTarget();
	local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

	-- NO INTERRUPT CAST ITEM
	-- item_shadow_amulet/item_glimmer_cape
	local shadowAmulet = IsItemAvailable('item_shadow_amulet');
	local glimmerCape = IsItemAvailable('item_glimmer_cape');
	if (shadowAmulet ~= nil and shadowAmulet:IsFullyCastable()) or (glimmerCape ~= nil and glimmerCape:IsFullyCastable())
	then
		local allies = npcBot:GetNearbyHeroes(600, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if not ally:IsInvisible() and utility.IsHero(ally)
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(5.0)) or ally:IsChanneling()
					then
						if shadowAmulet ~= nil and not ally:HasModifier("modifier_item_shadow_amulet_fade") and not ally:HasModifier("modifier_item_dustofappearance")
						then
							npcBot:Action_UseAbilityOnEntity(shadowAmulet, ally);
							--npcBot:ActionImmediate_Chat("Использую shadow Amulet на союзнике!", true);
							--return;
						elseif glimmerCape ~= nil and not ally:HasModifier("modifier_item_glimmer_cape_fade")
						then
							npcBot:Action_UseAbilityOnEntity(glimmerCape, ally);
							--npcBot:ActionImmediate_Chat("Использую glimmer Cape на союзнике!", true);
							--return;
						end
					end
				end
			end
		end
	end

	-- INTERRUPT CAST ITEMS
	if not npcBot:IsAlive() or npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsMuted() or npcBot:IsDominated() or npcBot:IsStunned() or npcBot:IsHexed() or
		npcBot:IsNightmared()
	then
		return;
	end

	-- item_tpscroll
	local tps = npcBot:GetItemInSlot(15);
	if tps ~= nil and tps:IsFullyCastable()
	then
		local tpLocation = nil
		local shouldTP = false
		shouldTP, tpLocation = teleportation_usage_generic.ShouldTP()
		if shouldTP
		then
			npcBot:Action_UseAbilityOnLocation(tps, tpLocation + RandomVector(100));
			--return;
		end
	end

	-- item_ward_observer
	local wardObserver = IsItemAvailable("item_ward_observer");
	if wardObserver ~= nil and wardObserver:IsFullyCastable()
	then
		local wardLocation = nil;
		local shouldUseWard = false;
		shouldUseWard, wardLocation = ward_usage_generic.ShouldUseWard()
		if shouldUseWard
		then
			npcBot:Action_UseAbilityOnLocation(wardObserver, wardLocation + RandomVector(50));
			--return;
		end
	end

	-- item_tango/item_tango_single
	local tango = IsItemAvailable("item_tango");
	local tangoSingle = IsItemAvailable("item_tango_single");
	if (tango ~= nil and tango:IsFullyCastable()) or (tangoSingle ~= nil and tangoSingle:IsFullyCastable())
	then
		if npcBot:DistanceFromFountain() > 1000 and npcBot:GetHealth() < npcBot:GetMaxHealth() - 200 and not npcBot:HasModifier("modifier_tango_heal")
			and utility.CanBeHeal(npcBot)
		then
			if tango ~= nil
			then
				local trees = npcBot:GetNearbyTrees(165 * 2);
				if trees[1] ~= nil and (IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])))
				then
					npcBot:Action_UseAbilityOnTree(tango, trees[1]);
					--npcBot:ActionImmediate_Chat("Использую tango!", true);
					--return;
				end
			elseif tangoSingle ~= nil
			then
				local trees = npcBot:GetNearbyTrees(165 * 3);
				if trees[1] ~= nil and (IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])))
				then
					npcBot:Action_UseAbilityOnTree(tangoSingle, trees[1]);
					--npcBot:ActionImmediate_Chat("Использую tango single!", true);
					--return;
				end
			end
		elseif not utility.PvPMode(npcBot) or botMode ~= BOT_MODE_RETREAT
		then
			if tango ~= nil and npcBot:DistanceFromFountain() > 3000
			then
				local allies = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE);
				if (#allies > 1)
				then
					for _, ally in pairs(allies)
					do
						if ally ~= npcBot and utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.6)
							and utility.GetItemCount(ally, "item_tango") == 0 and utility.GetItemCount(ally, "item_tango_single") == 0
							and not ally:HasModifier("modifier_tango_heal") and utility.CanBeHeal(ally)
						then
							npcBot:Action_UseAbilityOnEntity(tango, ally);
							--npcBot:ActionImmediate_Chat("Использую tango single!", true);
							--return;
						end
					end
				end
			end
		end
	end

	-- item_flask/item_clarity
	local flask = IsItemAvailable("item_flask");
	local clarity = IsItemAvailable("item_clarity");
	if (flask ~= nil and flask:IsFullyCastable()) or (clarity ~= nil and clarity:IsFullyCastable())
	then
		local allies = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if utility.IsHero(ally) and (ally:TimeSinceDamagedByAnyHero() >= 5.0 and ally:TimeSinceDamagedByCreep() >= 5.0)
					and ally:DistanceFromFountain() > 3000
				then
					if flask ~= nil and not HaveHealthRegenBuff(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6)
						and utility.CanBeHeal(ally)
					then
						npcBot:Action_UseAbilityOnEntity(flask, ally);
						--npcBot:ActionImmediate_Chat("Использую предмет flask что бы подлечить союзника!",true);
						--return;
					elseif clarity ~= nil and not HaveManaRegenBuff(ally) and (ally:GetMana() / ally:GetMaxMana() <= 0.4)
					then
						npcBot:Action_UseAbilityOnEntity(clarity, ally);
						--npcBot:ActionImmediate_Chat("Использую предмет clarity что бы восстановить ману союзнику!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_faerie_fire
	local faerieFire = IsItemAvailable("item_faerie_fire");
	if faerieFire ~= nil and faerieFire:IsFullyCastable()
	then
		if npcBot:DistanceFromFountain() > 1000 and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.2) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			and utility.CanBeHeal(npcBot)
		then
			npcBot:Action_UseAbility(faerieFire);
			--npcBot:ActionImmediate_Chat("Использую предмет Faerie Fire что бы подлечить себя!",true);
			--return;
		end
	end

	-- item_enchanted_mango
	local enchantedMango = IsItemAvailable("item_enchanted_mango");
	if enchantedMango ~= nil and enchantedMango:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if npcBot:GetMana() / npcBot:GetMaxMana() <= 0.3
			then
				npcBot:Action_UseAbility(enchantedMango);
				--npcBot:ActionImmediate_Chat("Использую предмет Enchanted Mango! что бы восстановить себе ману!",true);
				--return;
			end
		end
	end

	-- item_healing_lotus/item_great_healing_lotus
	local healingLotus = IsItemAvailable("item_healing_lotus");
	local greatHealingLotus = IsItemAvailable("item_great_healing_lotus");
	local greaterHealingLotus = IsItemAvailable("item_greater_healing_lotus");
	if (healingLotus ~= nil and healingLotus:IsFullyCastable()) or (greatHealingLotus ~= nil and greatHealingLotus:IsFullyCastable())
		or (greaterHealingLotus ~= nil and greaterHealingLotus:IsFullyCastable())
	then
		if npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.5 or npcBot:GetMana() / npcBot:GetMaxMana() <= 0.5
		then
			if healingLotus ~= nil
			then
				npcBot:Action_UseAbility(healingLotus);
			elseif greatHealingLotus ~= nil
			then
				npcBot:Action_UseAbility(greatHealingLotus);
			elseif greaterHealingLotus ~= nil
			then
				npcBot:Action_UseAbility(greaterHealingLotus);
			end
		end
	end

	-- item_cheese
	local cheese = IsItemAvailable("item_cheese");
	if cheese ~= nil and cheese:IsFullyCastable()
	then
		if npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.3
		then
			if npcBot:WasRecentlyDamagedByAnyHero(5.0) or npcBot:WasRecentlyDamagedByTower(2.0)
			then
				npcBot:Action_UseAbility(cheese);
			end
		end
	end

	-- item_soul_ring
	local soulRing = IsItemAvailable("item_soul_ring");
	if soulRing ~= nil and soulRing:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and (npcBot:GetMana() / npcBot:GetMaxMana() <= 0.5 and npcBot:GetHealth() / npcBot:GetMaxHealth() > 0.1)
				and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
			then
				npcBot:Action_UseAbility(soulRing);
				--npcBot:ActionImmediate_Chat("Использую предмет soulRing что бы восстановить себе ману!",true);
				--return;
			end
		end
	end

	--[[ 	-- item_tome_of_knowledge (DELETE)
	local tomeOfKnowledge = IsItemAvailable("item_tome_of_knowledge");
	if tomeOfKnowledge ~= nil and tomeOfKnowledge:IsFullyCastable() then
		npcBot:Action_UseAbility(tomeOfKnowledge);
		--npcBot:ActionImmediate_Chat("Использую предмет Tome Of Knowledge!",true);
		return;
	end ]]

	-- item_magic_stick/item_magic_wand
	local magicStick = IsItemAvailable("item_magic_stick");
	local magicWand = IsItemAvailable("item_magic_wand");
	if (magicStick ~= nil and magicStick:IsFullyCastable()) or (magicWand ~= nil and magicWand:IsFullyCastable())
	then
		if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.5) or (npcBot:GetMana() / npcBot:GetMaxMana() <= 0.4)
		then
			if magicStick ~= nil and magicStick:GetCurrentCharges() > 0
			then
				npcBot:Action_UseAbility(magicStick);
				--npcBot:ActionImmediate_Chat("Использую magic Stick для нападения!", true);
				--return;
			elseif magicWand ~= nil and magicWand:GetCurrentCharges() > 0
			then
				npcBot:Action_UseAbility(magicWand);
				--npcBot:ActionImmediate_Chat("Использую magic Wand для нападения!", true);
				--return;
			end
		end
	end

	-- item_dust
	local dust = IsItemAvailable("item_dust");
	if dust ~= nil and dust:IsFullyCastable()
	then
		local enemys = npcBot:GetNearbyHeroes(1050, true, BOT_MODE_NONE)
		if (#enemys > 0)
		then
			for _, enemy in pairs(enemys)
			do
				if enemy:IsInvisible() and utility.IsHero(enemy) and not enemy:HasModifier("modifier_item_dustofappearance")
				then
					npcBot:Action_UseAbility(dust);
					npcBot:ActionImmediate_Ping(enemy:GetLocation().x, enemy:GetLocation().y, true);
					--npcBot:ActionImmediate_Chat("Использую предмет dust против невидимых героев!",true);
					--return;
				end
			end
		end
	end

	-- item_quelling_blade/item_bfury
	local quellingBlade = IsItemAvailable('item_quelling_blade');
	local battleFury = IsItemAvailable('item_bfury');
	if (quellingBlade ~= nil and quellingBlade:IsFullyCastable()) or (battleFury ~= nil and battleFury:IsFullyCastable())
	then
		if not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT and not npcBot:IsInvisible()
		then
			local trees = npcBot:GetNearbyTrees(350);
			if trees[1] ~= nil and (IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])))
			then
				if quellingBlade ~= nil
				then
					npcBot:Action_UseAbilityOnTree(quellingBlade, trees[1]);
					--npcBot:ActionImmediate_Chat("Использую quelling Blade!", true);
					--return;
				elseif battleFury ~= nil
				then
					npcBot:Action_UseAbilityOnTree(battleFury, trees[1]);
					--npcBot:ActionImmediate_Chat("Использую battle Fury!", true);
					--return;
				end
			end
		end
	end

	-- item_power_treads
	local powerTreads = IsItemAvailable("item_power_treads");
	if powerTreads ~= nil and powerTreads:IsFullyCastable() and not npcBot:IsInvisible()
	then
		if botMode == BOT_MODE_RETREAT and powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
		then
			npcBot:Action_UseAbility(powerTreads);
			--return;
		end
		if botMode ~= BOT_MODE_RETREAT
		then
			if npcBot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH and powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
			then
				npcBot:Action_UseAbility(powerTreads);
				--return;
			elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY and powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT
			then
				npcBot:Action_UseAbility(powerTreads);
				--return;
			elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT and powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY
			then
				npcBot:Action_UseAbility(powerTreads);
				--return;
			elseif (npcBot:GetPrimaryAttribute() ~= ATTRIBUTE_STRENGTH and
					npcBot:GetPrimaryAttribute() ~= ATTRIBUTE_AGILITY and
					npcBot:GetPrimaryAttribute() ~= ATTRIBUTE_INTELLECT) and powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY
			then
				npcBot:Action_UseAbility(powerTreads);
				--return;
			end
		end
	end

	-- item_arcane_boots
	local arcaneBoots = IsItemAvailable("item_arcane_boots");
	if arcaneBoots ~= nil and arcaneBoots:IsFullyCastable() and not npcBot:IsInvisible()
	then
		local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if ally:GetMana() / ally:GetMaxMana() <= 0.6 and utility.IsHero(ally)
				then
					npcBot:Action_UseAbility(arcaneBoots);
					--npcBot:ActionImmediate_Chat("Использую предмет Arcane Boots что бы восстановить ману союзнику!",true);
				end
			end
		end
	end

	-- item_phase_boots
	local phaseBoots = IsItemAvailable("item_phase_boots");
	if phaseBoots ~= nil and phaseBoots:IsFullyCastable() and not npcBot:IsInvisible()
	then
		if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_IDLE and
			npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_DELAY and
			npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_NONE
		then
			npcBot:Action_UseAbility(phaseBoots);
			--npcBot:ActionImmediate_Chat("Использую предмет phaseBoots!",true);
			--return;
		end
	end

	-- item_pavise
	local pavise = IsItemAvailable("item_pavise");
	if pavise ~= nil and pavise:IsFullyCastable()
	then
		local allies = npcBot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(2.0)
					and not ally:HasModifier("modifier_item_pavise_shield")
				then
					npcBot:Action_UseAbilityOnEntity(pavise, ally);
					--npcBot:ActionImmediate_Chat("Использую предмет pavise!",true);
				end
			end
		end
	end

	-- item_ancient_janggo/item_boots_of_bearing
	local drumOfEndurance = IsItemAvailable("item_ancient_janggo");
	local bootsOfBearing = IsItemAvailable("item_boots_of_bearing");
	if (drumOfEndurance ~= nil and drumOfEndurance:IsFullyCastable()) or (bootsOfBearing ~= nil and bootsOfBearing:IsFullyCastable())
	then
		local itemRange = 1200;
		local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange * 2
			then
				for _, ally in pairs(allies)
				do
					if drumOfEndurance ~= nil and drumOfEndurance:GetCurrentCharges() > 0 and not ally:HasModifier("modifier_item_ancient_janggo_active")
						and utility.IsHero(botTarget)
					then
						npcBot:Action_UseAbility(drumOfEndurance);
						--npcBot:ActionImmediate_Chat("Использую drum Of Endurance для нападения!", true);
						--return;
					elseif bootsOfBearing ~= nil and not ally:HasModifier("modifier_item_boots_of_bearing_active") and utility.IsHero(botTarget)
					then
						npcBot:Action_UseAbility(bootsOfBearing);
						--npcBot:ActionImmediate_Chat("Использую boots Of Bearing для нападения!", true);
						--return;
					end
				end
			end
		end
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(2.0)
				then
					if drumOfEndurance ~= nil and drumOfEndurance:GetCurrentCharges() > 0 and not ally:HasModifier("modifier_item_ancient_janggo_active")
					then
						npcBot:Action_UseAbility(drumOfEndurance);
						--npcBot:ActionImmediate_Chat("Использую drum Of Endurance для отступления!",true);
						--return;
					elseif bootsOfBearing ~= nil and not ally:HasModifier("modifier_item_boots_of_bearing_active")
					then
						npcBot:Action_UseAbility(bootsOfBearing);
						--npcBot:ActionImmediate_Chat("Использую boots Of Bearing для отступления!", true);
						--return;
					end
				end
			end
		end
	end

	-- item_mekansm/item_guardian_greaves
	local mekansm = IsItemAvailable("item_mekansm");
	local guardianGreaves = IsItemAvailable("item_guardian_greaves");
	if (mekansm ~= nil and mekansm:IsFullyCastable()) or (guardianGreaves ~= nil and guardianGreaves:IsFullyCastable())
	then
		local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if utility.IsHero(ally) and utility.CanBeHeal(ally) and not ally:HasModifier("modifier_item_mekansm_noheal")
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.5)
					then
						if mekansm ~= nil
						then
							npcBot:Action_UseAbility(mekansm);
							--npcBot:ActionImmediate_Chat("Использую предмет mekansm!",true);
							--return;
						elseif guardianGreaves ~= nil
						then
							npcBot:Action_UseAbility(guardianGreaves);
							--npcBot:ActionImmediate_Chat("Использую предмет Guardian greaves!",true);
							--return;
						end
					elseif (ally:GetMana() / ally:GetMaxMana() <= 0.3)
					then
						if guardianGreaves ~= nil
						then
							npcBot:Action_UseAbility(guardianGreaves);
							--npcBot:ActionImmediate_Chat("Использую предмет Guardian greaves!",true);
							--return;
						end
					end
				end
			end
		end
	end

	-- item_crimson_guard
	local crimsonGuard = IsItemAvailable("item_crimson_guard");
	if crimsonGuard ~= nil and crimsonGuard:IsFullyCastable()
	then
		local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if not ally:HasModifier("modifier_item_crimson_guard_nostack")
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
					then
						npcBot:Action_UseAbility(crimsonGuard);
						--npcBot:ActionImmediate_Chat("Использую предмет crimson Guard!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_shivas_guard
	local shivasGuard = IsItemAvailable("item_shivas_guard");
	if shivasGuard ~= nil and shivasGuard:IsFullyCastable()
	then
		local itemRadius = 900;
		if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
		then
			local enemys = npcBot:GetNearbyHeroes(itemRadius, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую item_shivas_guard для нападения/отступления!",true);
						npcBot:Action_UseAbility(shivasGuard);
						--return;
					end
				end
			end
		end
	end

	-- item_hood_of_defiance(DELETE)/item_pipe/item_eternal_shroud
	--local hoodOfDefiance = IsItemAvailable("item_hood_of_defiance");
	local pipe = IsItemAvailable("item_pipe");
	--local eternalShroud = IsItemAvailable("item_eternal_shroud");
	if (hoodOfDefiance ~= nil and hoodOfDefiance:IsFullyCastable()) or (pipe ~= nil and pipe:IsFullyCastable()) or (eternalShroud ~= nil and eternalShroud:IsFullyCastable())
	then
		--[[ 		if hoodOfDefiance ~= nil and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9 and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			npcBot:Action_UseAbility(hoodOfDefiance);
			--npcBot:ActionImmediate_Chat("Использую предмет hood Of Defiance!", true);
			--return;
 		elseif eternalShroud ~= nil and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			npcBot:Action_UseAbility(eternalShroud);
			npcBot:ActionImmediate_Chat("Использую предмет eternal Shroud!", true);
			--return;  ]]
		if pipe ~= nil
		then
			local allies = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);
			if (#allies > 0)
			then
				for _, ally in pairs(allies)
				do
					if not ally:HasModifier("modifier_item_pipe_barrier")
					then
						if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(5.0)
						then
							npcBot:Action_UseAbility(pipe);
							--npcBot:ActionImmediate_Chat("Использую предмет pipe!", true);
							--return;
						end
					end
				end
			end
		end
	end

	-- item_force_staff
	local forceStaff = IsItemAvailable("item_force_staff");
	if forceStaff ~= nil and forceStaff:IsFullyCastable()
	then
		local itemRange = 550;
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget)
			then
				if GetUnitToUnitDistance(npcBot, botTarget) > (attackRange) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
					and utility.CanMove(npcBot)
				then
					npcBot:Action_UseAbilityOnEntity(forceStaff, npcBot);
					--npcBot:ActionImmediate_Chat("Использую предмет force_staff что бы сблизиться с целью!",true);
					--return;
				elseif (botTarget:IsFacingLocation(npcBot:GetLocation(), 20) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange) or
					(not utility.CanMove(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange)
				then
					npcBot:Action_UseAbilityOnEntity(forceStaff, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет force_staff на врага который смотрит в мою сторону!",true);
					--return;
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allies > 0)
			then
				for _, ally in pairs(allies)
				do
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
						and ally:IsFacingLocation(GetAncient(GetTeam()):GetLocation(), 40) and utility.CanMove(ally)
					then
						npcBot:Action_UseAbilityOnEntity(forceStaff, ally);
						--npcBot:ActionImmediate_Chat("Использую предмет force_staff для отступления!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_hurricane_pike
	local hurricanePike = IsItemAvailable("item_hurricane_pike");
	if hurricanePike ~= nil and hurricanePike:IsFullyCastable()
	then
		local pikeEnemyRange = 450;
		local pikeAllyRange = 650;
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget)
			then
				if GetUnitToUnitDistance(npcBot, botTarget) <= pikeEnemyRange
				then
					npcBot:Action_UseAbilityOnEntity(hurricanePike, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike на ближнего врага!",true);
					--return;
				elseif GetUnitToUnitDistance(npcBot, botTarget) > attackRange and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
					and utility.CanMove(npcBot)
				then
					npcBot:Action_UseAbilityOnEntity(hurricanePike, npcBot);
					--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike что бы сблизиться с врагом!",true);
					--return;
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			local enemys = npcBot:GetNearbyHeroes(pikeEnemyRange, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy)
					then
						npcBot:Action_UseAbilityOnEntity(hurricanePike, enemy);
						--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike что бы оторваться от врага!",true);
						--return;
					end
				end
			else
				local allies = npcBot:GetNearbyHeroes(pikeAllyRange, false, BOT_MODE_NONE);
				if (#allies > 0)
				then
					for _, ally in pairs(allies)
					do
						if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
							and ally:IsFacingLocation(GetAncient(GetTeam()):GetLocation(), 20) and utility.CanMove(ally)
						then
							npcBot:Action_UseAbilityOnEntity(hurricanePike, ally);
							--npcBot:ActionImmediate_Chat("Использую предмет hurricane Pike для отступления!",true);
							--return;
						end
					end
				end
			end
		end
	end

	-- item_medallion_of_courage/item_solar_crest
	local medallionOfCourage = IsItemAvailable("item_medallion_of_courage");
	local solarCrest = IsItemAvailable("item_solar_crest");
	if (medallionOfCourage ~= nil and medallionOfCourage:IsFullyCastable()) or (solarCrest ~= nil and solarCrest:IsFullyCastable())
	then
		local itemRange = 1000;
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange and utility.CanCastOnMagicImmuneTarget(botTarget)
			then
				if medallionOfCourage ~= nil and not botTarget:HasModifier("modifier_item_medallion_of_courage_armor_reduction")
				then
					npcBot:Action_UseAbilityOnEntity(medallionOfCourage, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет medallion of courage на враге!",true);
					--return;
				elseif solarCrest ~= nil and not botTarget:HasModifier("modifier_item_solar_crest_armor_reduction") and utility.SafeCast(botTarget, false)
				then
					npcBot:Action_UseAbilityOnEntity(solarCrest, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет solar Crest на враге!", true);
					--return;
				end
			end
		elseif botMode ~= BOT_MODE_RETREAT
		then
			local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allies > 1)
			then
				for _, ally in pairs(allies)
				do
					if ally ~= npcBot and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
					then
						if medallionOfCourage ~= nil and not ally:HasModifier("modifier_item_medallion_of_courage_armor_addition")
						then
							npcBot:Action_UseAbilityOnEntity(medallionOfCourage, ally);
							--npcBot:ActionImmediate_Chat("Использую предмет medallion Of Courage на союзнике!",true);
							--return;
						elseif solarCrest ~= nil and not ally:HasModifier("modifier_item_solar_crest_armor_addition")
						then
							npcBot:Action_UseAbilityOnEntity(solarCrest, ally);
							--npcBot:ActionImmediate_Chat("Использую предмет solar Crest на союзнике!",true);
							--return;
						end
					end
				end
			end
		end
	end


	-- item_abyssal_blade
	local abyssalBlade = IsItemAvailable("item_abyssal_blade");
	if abyssalBlade ~= nil and abyssalBlade:IsFullyCastable()
	then
		local itemRange = 150 * 2;
		local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);

		if (#enemys > 0)
		then
			for _, enemy in pairs(enemys) do
				if enemy:IsChanneling()
				then
					npcBot:Action_UseAbilityOnEntity(abyssalBlade, enemy);
					--return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and botTarget:CanBeSeen() and not utility.IsDisabled(botTarget) and utility.IsHero(botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= (itemRange)
			then
				npcBot:Action_UseAbilityOnEntity(abyssalBlade, botTarget);
				--npcBot:ActionImmediate_Chat("Использую предмет abyssal blade на враге!", true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys)
				do
					if enemy:CanBeSeen() and not utility.IsDisabled(enemy)
					then
						npcBot:Action_UseAbilityOnEntity(abyssalBlade, enemy);
						--npcBot:ActionImmediate_Chat("Использую предмет abyssal blade для оступления!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_heavens_halberd
	local heavensHalberd = IsItemAvailable("item_heavens_halberd");
	if heavensHalberd ~= nil and heavensHalberd:IsFullyCastable()
	then
		local itemRange = 650;
		local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemys > 0)
		then
			for _, enemy in pairs(enemys)
			do
				if enemy:CanBeSeen() and not utility.IsDisabled(enemy) and not enemy:IsDisarmed()
				then
					local enemyAttackTarget = enemy:GetAttackTarget();
					if enemyAttackTarget ~= nil and utility.IsHero(enemyAttackTarget)
					then
						npcBot:Action_UseAbilityOnEntity(heavensHalberd, enemy);
					end
				end
			end
		end
	end

	-- item_orchid/item_bloodthorn
	local orchid = IsItemAvailable("item_orchid");
	local bloodthorn = IsItemAvailable("item_bloodthorn");
	if (orchid ~= nil and orchid:IsFullyCastable()) or (bloodthorn ~= nil and bloodthorn:IsFullyCastable())
	then
		local itemRange = 900;
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
				and utility.SafeCast(botTarget, false) and not botTarget:IsSilenced() and botTarget:CanBeSeen()
			then
				if orchid ~= nil
				then
					npcBot:Action_UseAbilityOnEntity(orchid, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет orchid на враге!", true);
					--return;
				elseif bloodthorn ~= nil
				then
					npcBot:Action_UseAbilityOnEntity(bloodthorn, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет bloodthorn на враге!", true);
					--return;
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys)
				do
					if enemy:CanBeSeen() and utility.SafeCast(enemy, false) and not enemy:IsSilenced()
					then
						if orchid ~= nil
						then
							npcBot:Action_UseAbilityOnEntity(orchid, enemy);
							--npcBot:ActionImmediate_Chat("Использую предмет orchid для отступления!",true);
							--return;
						elseif bloodthorn ~= nil
						then
							npcBot:Action_UseAbilityOnEntity(bloodthorn, enemy);
							--npcBot:ActionImmediate_Chat("Использую предмет bloodthorn для отступления!",true);
							--return;
						end
					end
				end
			end
		end
	end

	-- 	item_sphere/item_lotus_orb
	local sphere = IsItemAvailable("item_sphere");
	local lotusOrb = IsItemAvailable("item_lotus_orb");
	if (sphere ~= nil and sphere:IsFullyCastable()) or (lotusOrb ~= nil and lotusOrb:IsFullyCastable())
	then
		local itemRange = 900;
		local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				local incomingSpells = ally:GetIncomingTrackingProjectiles();
				if (incomingSpells > 0)
				then
					for _, spell in pairs(incomingSpells)
					do
						if GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false
						then
							if sphere ~= nil
							then
								if ally ~= npcBot and not ally:HasModifier("modifier_item_sphere_target")
								then
									npcBot:Action_UseAbilityOnEntity(sphere, ally);
									--npcBot:ActionImmediate_Chat("Использую предмет sphere на союзнике!",true);
									--return;
								end
							elseif lotusOrb ~= nil
							then
								if not ally:HasModifier("modifier_item_lotus_orb_active")
								then
									npcBot:Action_UseAbilityOnEntity(lotusOrb, ally);
									--npcBot:ActionImmediate_Chat("Использую предмет lotusOrb на союзнике!",true);
									--return;
								end
							end
						end
					end
				end
			end
		end
	end

	-- item_veil_of_discord
	local discord = IsItemAvailable("item_veil_of_discord");
	if discord ~= nil and discord:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= 1200 and not botTarget:HasModifier("modifier_item_veil_of_discord_debuff")
			then
				npcBot:Action_UseAbilityOnLocation(discord, botTarget:GetLocation());
				--npcBot:ActionImmediate_Chat("Использую предмет discord на враге!", true);
				--return;
			end
		end
	end

	-- item_mjollnir
	local mjollnir = IsItemAvailable("item_mjollnir");
	if (mjollnir ~= nil and mjollnir:IsFullyCastable())
	then
		local allies = npcBot:GetNearbyHeroes(800, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if (ally:GetHealth() / ally:GetMaxHealth() <= 0.9) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
					and not ally:HasModifier("modifier_item_mjollnir_static")
				then
					npcBot:Action_UseAbilityOnEntity(mjollnir, ally);
					--npcBot:ActionImmediate_Chat("Использую предмет mjollnir на союзнике!",true);
					--return;
				end
			end
		end
	end

	-- item_black_king_bar
	local blackKingBar = IsItemAvailable("item_black_king_bar");
	if blackKingBar ~= nil and blackKingBar:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
			then
				npcBot:Action_UseAbility(blackKingBar);
				--npcBot:ActionImmediate_Chat("Использую предмет black King Bar для нападения!",true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				npcBot:Action_UseAbility(blackKingBar);
				--npcBot:ActionImmediate_Chat("Использую предмет black King Bar для отступления!",true);
				--return;
			end
		end
		if (#incomingSpells > 0)
		then
			for _, eSpell in pairs(incomingSpells)
			do
				if GetUnitToLocationDistance(npcBot, eSpell.location) <= 500 and eSpell.is_attack == false
				then
					npcBot:Action_UseAbility(blackKingBar);
					--npcBot:ActionImmediate_Chat("Использую предмет black King Bar для блока заклинания!",true);
				end
			end
		end
	end

	-- item_manta
	local manta = IsItemAvailable("item_manta");
	if manta ~= nil and manta:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
			then
				npcBot:Action_UseAbility(manta);
				--npcBot:ActionImmediate_Chat("Использую предмет manta style для нападения!",true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				npcBot:Action_UseAbility(manta);
				--npcBot:ActionImmediate_Chat("Использую предмет manta style для отступления!",true);
				--return;
			end
		end
		if (#incomingSpells > 0)
		then
			for _, eSpell in pairs(incomingSpells)
			do
				if GetUnitToLocationDistance(npcBot, eSpell.location) <= 100 and eSpell.is_attack == false
				then
					npcBot:Action_UseAbility(manta);
					--npcBot:ActionImmediate_Chat("Использую предмет manta для блока заклинания!",true);
				end
			end
		end
	end

	-- item_blade_mail
	local bladeMail = IsItemAvailable("item_blade_mail");
	if bladeMail ~= nil and bladeMail:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
				and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				npcBot:Action_UseAbility(bladeMail);
				--npcBot:ActionImmediate_Chat("Использую предмет blade Mail для нападения!",true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(5.0)
			then
				npcBot:Action_UseAbility(bladeMail);
				--npcBot:ActionImmediate_Chat("Использую предмет blade Mail для отступления!",true);
				--return;
			end
		end
	end

	-- item_bloodstone
	local bloodstone = IsItemAvailable("item_bloodstone");
	if bloodstone ~= nil and bloodstone:IsFullyCastable()
	then
		if utility.PvPMode(npcBot) and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.5)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
			then
				npcBot:Action_UseAbility(bloodstone);
				--npcBot:ActionImmediate_Chat("Использую предмет bloodstone для нападения!",true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.5) and npcBot:WasRecentlyDamagedByAnyHero(5.0)
			then
				npcBot:Action_UseAbility(bloodstone);
				--npcBot:ActionImmediate_Chat("Использую предмет bloodstone для отступления!",true);
				--return;
			end
		end
	end

	--item_blink/item_overwhelming_blink/item_swift_blink/item_arcane_blink
	local blink = IsItemAvailable('item_blink');
	local overwhelmingBlink = IsItemAvailable('item_overwhelming_blink');
	local swiftBlink = IsItemAvailable('item_swift_blink');
	local arcaneBlink = IsItemAvailable('item_arcane_blink');
	if (blink ~= nil and blink:IsFullyCastable()) or (overwhelmingBlink ~= nil and overwhelmingBlink:IsFullyCastable()) or
		(swiftBlink ~= nil and swiftBlink:IsFullyCastable()) or (arcaneBlink ~= nil and arcaneBlink:IsFullyCastable())
	then
		local itemRange = 1200;
		if utility.CanMove(npcBot)
		then
			if utility.PvPMode(npcBot)
			then
				if utility.IsValidTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2) and utility.IsHero(botTarget)
				then
					if blink ~= nil
					then
						npcBot:Action_UseAbilityOnLocation(blink, botTarget:GetLocation());
						--npcBot:ActionImmediate_Chat("Использую предмет Blink для нападения!",true);
						--return;
					elseif overwhelmingBlink ~= nil
					then
						npcBot:Action_UseAbilityOnLocation(overwhelmingBlink, botTarget:GetLocation());
						--npcBot:ActionImmediate_Chat("Использую предмет Blink для нападения!",true);
						--return;
					elseif swiftBlink ~= nil
					then
						npcBot:Action_UseAbilityOnLocation(swiftBlink, botTarget:GetLocation());
						--npcBot:ActionImmediate_Chat("Использую предмет Blink для нападения!",true);
						--return;
					elseif arcaneBlink ~= nil
					then
						npcBot:Action_UseAbilityOnLocation(arcaneBlink, botTarget:GetLocation());
						--npcBot:ActionImmediate_Chat("Использую предмет Blink для нападения!",true);
						--return;
					end
				end
			elseif botMode == BOT_MODE_RETREAT and npcBot:DistanceFromFountain() >= 400
			then
				if blink ~= nil
				then
					npcBot:Action_UseAbilityOnLocation(blink, utility.GetEscapeLocation(npcBot, itemRange));
					--npcBot:ActionImmediate_Chat("Использую предмет Blink для отступления!",true);
					--return;
				elseif overwhelmingBlink ~= nil
				then
					npcBot:Action_UseAbilityOnLocation(overwhelmingBlink, utility.GetEscapeLocation(npcBot, itemRange));
					--npcBot:ActionImmediate_Chat("Использую предмет Blink для отступления!",true);
					--return;
				elseif swiftBlink ~= nil
				then
					npcBot:Action_UseAbilityOnLocation(swiftBlink, utility.GetEscapeLocation(npcBot, itemRange));
					--npcBot:ActionImmediate_Chat("Использую предмет Blink для отступления!",true);
					--return;
				elseif arcaneBlink ~= nil
				then
					npcBot:Action_UseAbilityOnLocation(arcaneBlink, utility.GetEscapeLocation(npcBot, itemRange));
					--npcBot:ActionImmediate_Chat("Использую предмет Blink для отступления!",true);
					--return;
				end
			end
		end
	end

	-- item_urn_of_shadows/item_spirit_vessel
	local urnOfShadows = IsItemAvailable('item_urn_of_shadows');
	local spiritVessel = IsItemAvailable('item_spirit_vessel');
	if (urnOfShadows ~= nil and urnOfShadows:IsFullyCastable()) or (spiritVessel ~= nil and spiritVessel:IsFullyCastable())
	then
		local urnOfShadowsRange = 750;
		local allies = npcBot:GetNearbyHeroes(urnOfShadowsRange, false, BOT_MODE_NONE);
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:TimeSinceDamagedByAnyHero() >= 5.0)
					and not ally:HasModifier("modifier_fountain_aura_buff")
				then
					if urnOfShadows ~= nil and (urnOfShadows:GetCurrentCharges() > 0) and not ally:HasModifier("modifier_item_urn_heal")
					then
						npcBot:Action_UseAbilityOnEntity(urnOfShadows, ally);
						--npcBot:ActionImmediate_Chat("Использую urn Of Shadows на союзнике!", true);
						--return;
					elseif spiritVessel ~= nil and (spiritVessel:GetCurrentCharges() > 0) and not ally:HasModifier("modifier_item_spirit_vessel_heal")
					then
						npcBot:Action_UseAbilityOnEntity(spiritVessel, ally);
						--npcBot:ActionImmediate_Chat("Использую spirit Vessel на союзнике!", true);
						--return;
					end
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= urnOfShadowsRange and utility.CanCastOnMagicImmuneTarget(botTarget)
			then
				if urnOfShadows ~= nil and (urnOfShadows:GetCurrentCharges() > 0) and not botTarget:HasModifier("modifier_item_urn_damage")
				then
					npcBot:Action_UseAbilityOnEntity(urnOfShadows, botTarget);
					--npcBot:ActionImmediate_Chat("Использую urn Of Shadows на враге!", true);
					--return;
				elseif spiritVessel ~= nil and (spiritVessel:GetCurrentCharges() > 0) and not botTarget:HasModifier("modifier_item_spirit_vessel_damage")
					and utility.SafeCast(botTarget, true)
				then
					npcBot:Action_UseAbilityOnEntity(spiritVessel, botTarget);
					--npcBot:ActionImmediate_Chat("Использую spirit Vessel на враге!", true);
					--return;
				end
			end
		end
	end

	-- item_cyclone/item_wind_waker
	local eulScepter = IsItemAvailable('item_cyclone');
	local windWaker = IsItemAvailable('item_wind_waker');
	if (eulScepter ~= nil and eulScepter:IsFullyCastable()) or (windWaker ~= nil and windWaker:IsFullyCastable())
	then
		local itemRange = 550;
		if (#incomingSpells > 0)
		then
			if eulScepter ~= nil
			then
				for _, eSpell in pairs(incomingSpells)
				do
					if GetUnitToLocationDistance(npcBot, eSpell.location) <= 300 and eSpell.is_attack == false
					then
						npcBot:Action_UseAbilityOnEntity(eulScepter, npcBot);
						--npcBot:ActionImmediate_Chat("Использую eulScepter что бы уклониться от снаряда!",true);
						--return;
					end
				end
			elseif windWaker ~= nil
			then
				for _, eSpell in pairs(incomingSpells)
				do
					if GetUnitToLocationDistance(npcBot, eSpell.location) <= 500 and eSpell.is_attack == false
					then
						npcBot:Action_UseAbilityOnEntity(windWaker, npcBot);
						--npcBot:ActionImmediate_Chat("Использую wind Waker что бы уклониться от снаряда!",true);
						--return;
					end
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys)
				do
					if enemy ~= npcBot:GetAttackTarget() and utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false) == true
					then
						if eulScepter ~= nil
						then
							--npcBot:ActionImmediate_Chat("Использую eulScepter на не основную цель!",true);
							npcBot:Action_UseAbilityOnEntity(eulScepter, enemy);
							--return;
						elseif windWaker ~= nil
						then
							--npcBot:ActionImmediate_Chat("Использую windWaker на не основную цель!",true);
							npcBot:Action_UseAbilityOnEntity(windWaker, enemy);
							--return;
						end
					end
				end
			end
		end
		if eulScepter ~= nil and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			--npcBot:ActionImmediate_Chat("Использую eulScepter для отступления!",true);
			npcBot:Action_UseAbilityOnEntity(eulScepter, npcBot);
			--return;
		elseif windWaker ~= nil
		then
			local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allies > 0)
			then
				for _, ally in pairs(allies)
				do
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and utility.IsHero(ally) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
					then
						npcBot:Action_UseAbilityOnEntity(windWaker, ally);
						--npcBot:ActionImmediate_Chat("Использую wind Waker на союзнике!", true);
						--return;
					end
				end
			end
		end
	end

	-- item_dagon 1-5
	local dagon1 = IsItemAvailable('item_dagon');
	local dagon2 = IsItemAvailable('item_dagon_2');
	local dagon3 = IsItemAvailable('item_dagon_3');
	local dagon4 = IsItemAvailable('item_dagon_4');
	local dagon5 = IsItemAvailable('item_dagon_5');
	if (dagon1 ~= nil and dagon1:IsFullyCastable()) or (dagon2 ~= nil and dagon2:IsFullyCastable()) or (dagon3 ~= nil and dagon3:IsFullyCastable()) or
		(dagon4 ~= nil and dagon4:IsFullyCastable()) or (dagon5 ~= nil and dagon5:IsFullyCastable())
	then
		if dagon1 ~= nil
		then
			local enemys = npcBot:GetNearbyHeroes(700, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
					then
						if utility.CanAbilityKillTarget(enemy, 400, DAMAGE_TYPE_MAGICAL)
						then
							npcBot:Action_UseAbilityOnEntity(dagon1, enemy);
							--return;
						end
					end
				end
			end
		elseif dagon2 ~= nil
		then
			local enemys = npcBot:GetNearbyHeroes(750, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
					then
						if utility.CanAbilityKillTarget(enemy, 500, DAMAGE_TYPE_MAGICAL)
						then
							npcBot:Action_UseAbilityOnEntity(dagon2, enemy);
							--return;
						end
					end
				end
			end
		elseif dagon3 ~= nil
		then
			local enemys = npcBot:GetNearbyHeroes(800, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
					then
						if utility.CanAbilityKillTarget(enemy, 600, DAMAGE_TYPE_MAGICAL)
						then
							npcBot:Action_UseAbilityOnEntity(dagon3, enemy);
							--return;
						end
					end
				end
			end
		elseif dagon4 ~= nil
		then
			local enemys = npcBot:GetNearbyHeroes(850, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
					then
						if utility.CanAbilityKillTarget(enemy, 700, DAMAGE_TYPE_MAGICAL)
						then
							npcBot:Action_UseAbilityOnEntity(dagon4, enemy);
							--return;
						end
					end
				end
			end
		elseif dagon5 ~= nil
		then
			local enemys = npcBot:GetNearbyHeroes(900, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
					then
						if utility.CanAbilityKillTarget(enemy, 800, DAMAGE_TYPE_MAGICAL)
						then
							npcBot:Action_UseAbilityOnEntity(dagon5, enemy);
							--return;
						end
					end
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget)
			then
				if utility.CanCastOnMagicImmuneTarget(botTarget) and utility.SafeCast(botTarget, true) == true and utility.IsHero(botTarget)
				then
					if dagon1 ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= 700
					then
						npcBot:Action_UseAbilityOnEntity(dagon1, botTarget);
						--npcBot:ActionImmediate_Chat("Использую Dagon по врагу!", true);
						--return;
					elseif dagon2 ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= 750
					then
						npcBot:Action_UseAbilityOnEntity(dagon2, botTarget);
						--npcBot:ActionImmediate_Chat("Использую Dagon по врагу!", true);
						--return;
					elseif dagon3 ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= 800
					then
						npcBot:Action_UseAbilityOnEntity(dagon3, botTarget);
						--npcBot:ActionImmediate_Chat("Использую Dagon по врагу!", true);
						--return;
					elseif dagon4 ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= 850
					then
						npcBot:Action_UseAbilityOnEntity(dagon4, botTarget);
						--npcBot:ActionImmediate_Chat("Использую Dagon по врагу!", true);
						--return;
					elseif dagon5 ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= 900
					then
						npcBot:Action_UseAbilityOnEntity(dagon5, botTarget);
						--npcBot:ActionImmediate_Chat("Использую Dagon по врагу!", true);
						--return;
					end
				end
			end
		end
	end

	-- item_rod_of_atos/item_gleipnir
	local rodOfAtos = IsItemAvailable('item_rod_of_atos');
	local gleipnir = IsItemAvailable('item_gleipnir');
	if (rodOfAtos ~= nil and rodOfAtos:IsFullyCastable()) or (gleipnir ~= nil and gleipnir:IsFullyCastable())
	then
		local itemRange = 1100;
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget)
			then
				if utility.CanCastOnMagicImmuneTarget(botTarget) and utility.IsHero(botTarget) and
					not utility.IsDisabled(botTarget)
				then
					if rodOfAtos ~= nil and utility.SafeCast(botTarget, false) == true
					then
						npcBot:Action_UseAbilityOnEntity(rodOfAtos, botTarget);
						--npcBot:ActionImmediate_Chat("Использую rodOfAtos по врагу!", true);
						--return;
					elseif gleipnir ~= nil
					then
						npcBot:Action_UseAbilityOnLocation(gleipnir, botTarget:GetLocation());
						npcBot:ActionImmediate_Chat("Использую gleipnir по врагу!", true);
						--return;
					end
				end
			elseif botMode == BOT_MODE_RETREAT
			then
				local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
				if (#enemys > 0)
				then
					for _, enemy in pairs(enemys)
					do
						if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
						then
							if rodOfAtos ~= nil and utility.SafeCast(enemy, false) == true
							then
								npcBot:Action_UseAbilityOnEntity(rodOfAtos, enemy);
								npcBot:ActionImmediate_Chat("Использую предмет rodOfAtos для оступления!",
									true);
								--return;
							elseif gleipnir ~= nil
							then
								npcBot:Action_UseAbilityOnLocation(gleipnir, enemy:GetLocation());
								npcBot:ActionImmediate_Chat("Использую gleipnir для оступления!",
									true);
								--return;
							end
						end
					end
				end
			end
		end
	end

	-- item_moon_shard
	local moonShard = IsItemAvailable("item_moon_shard");
	if moonShard ~= nil and moonShard:IsFullyCastable()
	then
		if botMode ~= BOT_MODE_RETREAT
		then
			if not npcBot:HasModifier("modifier_item_moon_shard_consumed")
			then
				npcBot:Action_UseAbilityOnEntity(moonShard, npcBot);
			else
				local allies = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
				if (#allies > 1)
				then
					for _, ally in pairs(allies)
					do
						if utility.IsHero(ally) and ally ~= npcBot and not ally:HasModifier("modifier_item_moon_shard_consumed")
						then
							npcBot:Action_UseAbilityOnEntity(moonShard, ally);
							npcBot:ActionImmediate_Chat("Использую предмет moonShard на союзника!",
								true);
						end
					end
				end
			end
		end
	end

	-- 	item_ghost/item_ethereal_blade
	local ghost = IsItemAvailable("item_ghost");
	local etherealBlade = IsItemAvailable("item_ethereal_blade");
	if (ghost ~= nil and ghost:IsFullyCastable()) or (etherealBlade ~= nil and etherealBlade:IsFullyCastable())
	then
		local itemRange = 800;
		if botMode == BOT_MODE_RETREAT
		then
			if npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6
			then
				if ghost ~= nil
				then
					npcBot:Action_UseAbility(ghost);
					--npcBot:ActionImmediate_Chat("Использую предмет ghost!", true);
					--return;
				elseif etherealBlade ~= nil
				then
					local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
					if (#enemys > 0)
					then
						for _, enemy in pairs(enemys)
						do
							if not enemy:IsAttackImmune()
							then
								npcBot:Action_UseAbilityOnEntity(etherealBlade, enemy);
								--npcBot:ActionImmediate_Chat("Использую предмет etherealBlade для оступления!",true);
								--return;
							end
						end
					end
				end
			end
		end
		if etherealBlade ~= nil and utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and (npcBot:GetMana() / npcBot:GetMaxMana() >= 0.2)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				npcBot:Action_UseAbilityOnEntity(etherealBlade, botTarget);
				--npcBot:ActionImmediate_Chat("Использую предмет etherealBlade для нападения",true);
				--return;
			end
		end
	end

	-- item_invis_sword/item_silver_edge
	local shadowBlade = IsItemAvailable("item_invis_sword");
	local silverEdge = IsItemAvailable("item_silver_edge");
	if (shadowBlade ~= nil and shadowBlade:IsFullyCastable()) or (silverEdge ~= nil and silverEdge:IsFullyCastable()) and not npcBot:IsInvisible()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
			then
				if silverEdge ~= nil
				then
					npcBot:Action_UseAbility(silverEdge);
					--npcBot:ActionImmediate_Chat("Использую предмет silverEdge для нападения!",true);
					--return;
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				if shadowBlade ~= nil
				then
					npcBot:Action_UseAbility(shadowBlade);
					--npcBot:ActionImmediate_Chat("Использую предмет shadowBlade для отступления!",true);
					--return;
				elseif silverEdge ~= nil
				then
					npcBot:Action_UseAbility(silverEdge);
					--npcBot:ActionImmediate_Chat("Использую предмет silverEdge для отступления!",true);
					--return;
				end
			end
		end
		if (#incomingSpells > 0)
		then
			for _, eSpell in pairs(incomingSpells)
			do
				if GetUnitToLocationDistance(npcBot, eSpell.location) <= 300 and eSpell.is_attack == false
				then
					if shadowBlade ~= nil
					then
						npcBot:Action_UseAbility(shadowBlade);
						--npcBot:ActionImmediate_Chat("Использую предмет shadowBlade для блока заклинания!",true);
						--return;
					elseif silverEdge ~= nil
					then
						npcBot:Action_UseAbility(silverEdge);
						--npcBot:ActionImmediate_Chat("Использую предмет silverEdge для блока заклинания!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_diffusal_blade/item_disperser
	local diffusalBlade = IsItemAvailable("item_diffusal_blade");
	local disperser = IsItemAvailable("item_disperser");
	if (diffusalBlade ~= nil and diffusalBlade:IsFullyCastable()) or (disperser ~= nil and disperser:IsFullyCastable())
	then
		local itemRange = 600;
		local allies = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and not utility.IsDisabled(botTarget) and utility.IsHero(botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= (itemRange)
			then
				if diffusalBlade ~= nil and not botTarget:HasModifier("modifier_item_diffusal_blade_slow")
				then
					npcBot:Action_UseAbilityOnEntity(diffusalBlade, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет diffusal_blade на враге!", true);
					--return;
				elseif disperser ~= nil and not botTarget:HasModifier("modifier_item_Disperser_slow")
				then
					npcBot:Action_UseAbilityOnEntity(disperser, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет disperser на враге!", true);
					--return;
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys)
				do
					if utility.IsValidTarget(enemy) and not utility.IsDisabled(enemy)
					then
						if diffusalBlade ~= nil and not enemy:HasModifier("modifier_item_diffusal_blade_slow")
						then
							npcBot:Action_UseAbilityOnEntity(diffusalBlade, enemy);
							--npcBot:ActionImmediate_Chat("Использую предмет diffusal_blade для отхода!",true);
							--return;
						elseif disperser ~= nil and not enemy:HasModifier("modifier_item_Disperser_slow")
						then
							npcBot:Action_UseAbilityOnEntity(disperser, enemy);
							--npcBot:ActionImmediate_Chat("Использую предмет disperser для отхода!",true);
							--return;
						end
					end
				end
			end
		end
		if (#allies > 0)
		then
			for _, ally in pairs(allies)
			do
				if utility.IsDisabled(ally) or ally:WasRecentlyDamagedByAnyHero(2.0)
				then
					if disperser ~= nil
					then
						npcBot:Action_UseAbilityOnEntity(disperser, ally);
						--npcBot:ActionImmediate_Chat("Использую предмет disperser на союзнике!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_harpoon
	local harpoon = IsItemAvailable("item_harpoon");
	if harpoon ~= nil and harpoon:IsFullyCastable()
	then
		local itemRange = 700;
		if utility.PvPMode(npcBot) and utility.CanMove(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget)
				and (GetUnitToUnitDistance(npcBot, botTarget) <= itemRange and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
			then
				npcBot:Action_UseAbilityOnEntity(harpoon, botTarget);
				--npcBot:ActionImmediate_Chat("Использую предмет harpoon на враге!", true);
				--return;
			end
		end
	end

	-- item_hand_of_midas
	local handOfMidas = IsItemAvailable("item_hand_of_midas");
	if handOfMidas ~= nil and handOfMidas:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			local enemy = utility.GetStrongestCreep(npcBot, 600 + 200);
			if utility.IsValidTarget(enemy) and utility.CanCastOnMagicImmuneTarget(enemy) and not enemy:IsAncientCreep() and (enemy:GetLevel() >= 3)
				and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.8)
			then
				npcBot:Action_UseAbilityOnEntity(handOfMidas, enemy);
				--npcBot:ActionImmediate_Chat("Использую handOfMidas!", true);
				--return;
			end
		end
	end


	-- item_sheepstick
	local scytheOfVyse = IsItemAvailable("item_sheepstick");
	if scytheOfVyse ~= nil and scytheOfVyse:IsFullyCastable()
	then
		local itemRange = 800;
		local enemys = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemys > 0)
		then
			for _, enemy in pairs(enemys) do
				if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:IsChanneling()
				then
					npcBot:Action_UseAbilityOnEntity(scytheOfVyse, enemy);
					--return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget)
				and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (itemRange)
			then
				npcBot:Action_UseAbilityOnEntity(scytheOfVyse, botTarget);
				--npcBot:ActionImmediate_Chat("Использую предмет scytheOfVyse на враге!", true);
				--return;
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if (#enemys > 0)
			then
				for _, enemy in pairs(enemys)
				do
					if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
					then
						npcBot:Action_UseAbilityOnEntity(scytheOfVyse, enemy);
						--npcBot:ActionImmediate_Chat("Использую предмет scytheOfVyse для оступления!",true);
						--return;
					end
				end
			end
		end
	end

	-- item_mask_of_madness
	local maskOfMadness = IsItemAvailable("item_mask_of_madness");
	if maskOfMadness ~= nil and maskOfMadness:IsFullyCastable()
	then
		if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
		then
			if utility.IsValidTarget(botTarget) and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
			then
				if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange + 200
				then
					npcBot:Action_UseAbility(maskOfMadness);
					--npcBot:ActionImmediate_Chat("Использую предмет maskOfMadness для нападения!",true);
				end
			end
		elseif botMode == BOT_MODE_RETREAT
		then
			if npcBot:DistanceFromFountain() > 1000 and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				npcBot:Action_UseAbility(maskOfMadness);
				--npcBot:ActionImmediate_Chat("Использую предмет maskOfMadness для отхода!", true);
			end
		end
	end

	-- item_helm_of_the_dominator/item_helm_of_the_overlord
	local helmOfTheDominator = IsItemAvailable("item_helm_of_the_dominator");
	local helmOfTheOverlord = IsItemAvailable("item_helm_of_the_overlord");
	if (helmOfTheDominator ~= nil and helmOfTheDominator:IsFullyCastable()) or (helmOfTheOverlord ~= nil and helmOfTheOverlord:IsFullyCastable())
	then
		if not npcBot:IsInvisible()
		then
			local itemRange = 700;
			local enemyCreeps = npcBot:GetNearbyCreeps(itemRange, true);
			if (#enemyCreeps > 0)
			then
				local count = 0;
				local contolledCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
				for _, ally in pairs(contolledCreeps) do
					if ally:HasModifier("modifier_item_helm_of_the_dominator_bonushealth")
					then
						count = count + 1;
					end
				end
				if count <= 0
				then
					for _, enemy in pairs(enemyCreeps) do
						if utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetLevel() >= 3)
						then
							if helmOfTheDominator ~= nil
							then
								if not enemy:IsAncientCreep()
								then
									npcBot:Action_UseAbilityOnEntity(helmOfTheDominator, enemy);
								end
							elseif helmOfTheOverlord ~= nil
							then
								npcBot:Action_UseAbilityOnEntity(helmOfTheOverlord, enemy);
							end
						end
					end
				end
			end
		end
	end

	-- item_revenants_brooch
	local revenantsBrooch = IsItemAvailable("item_revenants_brooch");
	if revenantsBrooch ~= nil and revenantsBrooch:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
				and not npcBot:HasModifier("modifier_item_revenants_brooch_counter")
			then
				if botTarget:IsAttackImmune() or utility.CanCastOnMagicImmuneTarget(botTarget)
				then
					npcBot:Action_UseAbility(revenantsBrooch);
				end
			end
		end
	end





	------------
end

--#endregion

for k, v in pairs(ability_item_usage_generic) do _G._savedEnv[k] = v end


--[[ function ItemUsageThinkTEST()
	local npcBot = GetBot()

	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted() or npcBot:HasModifier("modifier_doom_bringer_doom")
	then
		return;
	end

	local incomingSpells = npcBot:GetIncomingTrackingProjectiles()
	local allysHero = npcBot:GetNearbyHeroes(1200, false, BOT_MODE_NONE);


	-- item_tango
	item = npcBot:GetItemByName("item_tango", false, false);
	if item ~= nil and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		if npcBot:GetHealth() < npcBot:GetMaxHealth() - 200 and (not npcBot:HasModifier("modifier_tango_heal")) then
			local trees = npcBot:GetNearbyTrees(itemRange * 2);
			if (#trees > 0) then
				npcBot:ActionImmediate_Chat("Использую предмет tango что бы подлечить себя!",
					true);
				npcBot:ActionPush_UseAbilityOnTree(item, trees[1]);
				return;
			end
		end
	end

	-- item_clarity
	local item = npcBot:GetItemByName("item_clarity", false, false);
	if item ~= nil and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		local allysClarity = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		for _, aItemTarget in pairs(allysClarity)
		do
			if aItemTarget:GetMana() / aItemTarget:GetMaxMana() <= 0.4 and aItemTarget:HaveManaRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет clarity что бы восстановить цели ману!",
					true);
				npcBot:ActionPush_UseAbilityOnEntity(item, aItemTarget);
				return;
			end
		end
	end

	-- item_flask
	local item = npcBot:GetItemByName("item_flask", false, false);
	if item ~= nil and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		local allysFlask = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		for _, aItemTarget in pairs(allysFlask)
		do
			if aItemTarget:GetHealth() / aItemTarget:GetMaxHealth() <= 0.4 and aItemTarget:HaveHealthRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет Flask что бы восстановить цели здоровье!",
					true);
				npcBot:ActionPush_UseAbilityOnEntity(item, aItemTarget);
				return;
			end
		end
	end
end ]]
--[[
		local mainSlotItem = {
		npcBot:GetItemInSlot(0),
		npcBot:GetItemInSlot(1),
		npcBot:GetItemInSlot(2),
		npcBot:GetItemInSlot(3),
		npcBot:GetItemInSlot(4),
		npcBot:GetItemInSlot(5),
		npcBot:GetItemInSlot(15),
	}


for i = 1, #mainSlotItem do
	local item = npcBot:GetItemInSlot(i);

	-- item_tango
	if (item) and item:GetName() == "item_tango" and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		if npcBot:GetHealth() < npcBot:GetMaxHealth() - 200 and (not npcBot:HasModifier("modifier_tango_heal")) then
			local trees = npcBot:GetNearbyTrees(itemRange * 2);
			if (#trees > 0) then
				npcBot:ActionImmediate_Chat("Использую предмет tango что бы подлечить себя!",
					true);
				npcBot:ActionPush_UseAbilityOnTree(item, trees[1]);
				return;
			end
		end
	end

	-- item_clarity
	if (item) and item:GetName() == "item_clarity" and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		local allysClarity = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		for _, aItemTarget in pairs(allysClarity)
		do
			if aItemTarget:GetMana() / aItemTarget:GetMaxMana() <= 0.4 and aItemTarget:HaveManaRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет clarity что бы восстановить цели ману!",
					true);
				npcBot:ActionPush_UseAbilityOnEntity(item, aItemTarget);
				return;
			end
		end
	end

	-- item_flask
	if (item) and item:GetName() == "item_flask" and item:IsFullyCastable() then
		local itemRange = item:GetCastRange();
		local allysFlask = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		for _, aItemTarget in pairs(allysFlask)
		do
			if aItemTarget:GetHealth() / aItemTarget:GetMaxHealth() <= 0.4 and aItemTarget:HaveHealthRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет Flask что бы восстановить цели здоровье!",
					true);
				npcBot:ActionPush_UseAbilityOnEntity(item, aItemTarget);
				return;
			end
		end
	end ]]
--[[ function GetTheItem(sItem)
	for i = 1, #npcBot.mainSlotItem do
		if npcBot.mainSlotItem[i] ~= nil and npcBot.mainSlotItem[i]:GetName() == sItem then
			return npcBot.mainSlotItem[i];
		end
	end
	return nil;
end

function CanUseItem(sItem)
	local item = GetTheItem(sItem);
	if item ~= nil and item:IsFullyCastable() then
		return item;
	end
	return false;
end

function ItemUsageThinks()
	local npcBot = GetBot()

	if npcBot:IsChanneling() or npcBot:IsUsingAbility() or npcBot:IsInvisible() or npcBot:IsMuted() or npcBot:HasModifier("modifier_doom_bringer_doom")
	then
		return;
	end

	local incomingSpells = npcBot:GetIncomingTrackingProjectiles()


	-- item_courier
	local itemToUse = CanUseItem('item_courier');
	if itemToUse ~= false then
		npcBot:Action_UseAbility(itemToUse);
		return;
	end

	-- item_tome_of_knowledge
	local itemToUse = CanUseItem('item_tome_of_knowledge');
	if itemToUse ~= false then
		npcBot:ActionImmediate_Chat("Использую предмет tome_of_knowledge!", true);
		npcBot:Action_UseAbility(itemToUse);
		return;
	end

	-- item_tango
	local itemToUse = CanUseItem('item_tango');
	if itemToUse ~= false then
		if npcBot:GetHealth() < npcBot:GetMaxHealth() - 200 and (not npcBot:HasModifier("modifier_tango_heal")) then
			local trees = npcBot:GetNearbyTrees(300);
			if (#trees > 0) then
				npcBot:ActionImmediate_Chat("Использую предмет tango что бы подлечить себя!",
					true);
				npcBot:Action_UseAbilityOnTree(item, trees[1]);
				return;
			end
		end
	end

	--item_clarity
	local itemToUse = CanUseItem('item_clarity');
	local allysClarity = npcBot:GetNearbyHeroes(250, false, BOT_MODE_NONE);
	if itemToUse ~= false and #incomingSpells == 0 and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		for _, aClarity in pairs(allysClarity)
		do
			if aClarity:GetMana() / aClarity:GetMaxMana() <= 0.4 and aClarity:HaveManaRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет clarity что бы восстановить цели ману!",
					true);
				npcBot:Action_UseAbilityOnEntity(itemToUse, aClarity);
			end
		end
	end

	--item_flask
	local itemToUse = CanUseItem('item_flask');
	local allysFlask = npcBot:GetNearbyHeroes(250, false, BOT_MODE_NONE);
	if itemToUse ~= false and #incomingSpells == 0 and npcBot:GetActiveMode() ~= BOT_MODE_RETREAT
	then
		for _, aFlask in pairs(allysFlask)
		do
			if aFlask:GetHealt() / aFlask:GetMaxHealth() <= 0.5 and aFlask:HaveHealthRegenBuff() == false then
				npcBot:ActionImmediate_Chat("Использую предмет flask что бы восстановить цели здоровье!",
					true);
				npcBot:Action_UseAbilityOnEntity(itemToUse, aFlask);
			end
		end
	end
end
 ]]
--[[  function BuybackUsageThink()
	local npcBot = GetBot()

	if npcBot:IsAlive() and npcBot:IsInvulnerable() or not npcBot:IsHero() or npcBot:IsIllusion() then
		return;
	end

	if npcBot:IsAlive() and TimeDeath ~= nil then
		TimeDeath = nil;
	end

	if not npcBot:HasBuyback() then
		return;
	end

	if not npcBot:IsAlive() then
		if TimeDeath == nil then
			TimeDeath = DotaTime();
		end
	end

	local RespawnTime = GetRemainingRespawnTime();

	if RespawnTime < 15 then
		return;
	end

	local ancient = GetAncient(GetTeam());

	if ancient ~= nil
	then
		local nEnemies = GetNumEnemyNearby(ancient);
		if nEnemies > 0 and nEnemies >= GetNumOfAliveHeroes(GetTeam()) then
			npcBot:ActionImmediate_Buyback();
			npcBot:ActionImmediate_Chat("Выкупаюсь!", true);
			return;
		end
	end
end ]]