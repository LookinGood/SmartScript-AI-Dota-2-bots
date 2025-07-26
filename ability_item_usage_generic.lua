---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("ability_item_usage_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/teleportation_usage_generic")

--[[ local utility = require(GetScriptDirectory() .. "/utility")
local wardUsage = require(GetScriptDirectory() .. "/ward_usage_generic")
local teleportUsage = require(GetScriptDirectory() .. "/teleportation_usage_generic")
--require(GetScriptDirectory() .. "/ward_usage_generic")]]

--#region COURIER THINK
function CourierUsageThink()
	local npcBot = GetBot();

	if npcBot == nil or not utility.IsHero(npcBot) or utility.IsClone(npcBot) or utility.IsCloneMeepo(npcBot)
	then
		return;
	end

	local courier = utility.GetBotCourier(npcBot);
	local state = GetCourierState(courier);

	if (state == COURIER_STATE_DEAD)
	then
		return;
	end

	local burst = courier:GetAbilityByName("courier_burst");
	--local autoDeliver = courier:GetAbilityByName("courier_autodeliver");
	local shield = courier:GetAbilityByName("courier_shield");
	local canCastBurst = burst ~= nil and burst:IsFullyCastable();
	local canCastShield = shield ~= nil and shield:IsFullyCastable();
	--local canCastAutoDeliver = autoDeliver ~= nil and autoDeliver:IsFullyCastable();
	--local courierHealth = courier:GetHealth() / courier:GetMaxHealth();

	if (state == COURIER_STATE_IDLE) or
		(npcBot.secretShopMode ~= true and
			state ~= COURIER_STATE_AT_BASE and
			state ~= COURIER_STATE_DELIVERING_ITEMS and
			state ~= COURIER_STATE_RETURNING_TO_BASE)
	then
		--npcBot:ActionImmediate_Chat("Курьер бездельничает!", true);
		npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN_STASH_ITEMS);
		return;
	end

	if (state == COURIER_STATE_DELIVERING_ITEMS)
	then
		if (canCastBurst) and GetUnitToUnitDistance(courier, npcBot) >= 3000
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST);
		end
	end

	--[[ 	if canCastAutoDeliver
	then
		if npcBot:GetCourierValue() > 0
		then
			if not autoDeliver:GetAutoCastState()
			then
				npcBot:ActionImmediate_Chat("Автодоставка: Вкл: " .. autoDeliver:GetName(), true);
				autoDeliver:ToggleAutoCast()
			end
		else
			if autoDeliver:GetAutoCastState()
			then
				npcBot:ActionImmediate_Chat("Автодоставка: Выкл: " .. autoDeliver:GetName(), true);
				autoDeliver:ToggleAutoCast()
			end
		end
	end ]]

	if ((utility.CountEnemyHeroAroundUnit(courier, 1000) > 0 or utility.CountEnemyTowerAroundUnit(courier, 1000) > 0) and not courier:IsInvulnerable())
		or (courier:GetHealth() < courier:GetMaxHealth())
	then
		if canCastBurst and state == COURIER_STATE_MOVING and courier:DistanceFromFountain() > 1000
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_BURST);
		end
		if canCastShield
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SHIELD);
			--courier:Action_UseAbility(shield);
			--npcBot:ActionImmediate_Chat("Курьер юзает щит: " .. shield:GetName(), true);
		end
		if (state ~= COURIER_STATE_RETURNING_TO_BASE)
		then
			npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_RETURN_STASH_ITEMS);
			return;
		end
	else
		if (state ~= COURIER_STATE_MOVING) and (state ~= COURIER_STATE_DELIVERING_ITEMS)
		then
			if npcBot:IsAlive()
			then
				if (npcBot:GetStashValue() > 100) and (state == COURIER_STATE_AT_BASE)
				then
					npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TAKE_AND_TRANSFER_ITEMS);
					return;
				elseif (npcBot:GetCourierValue() > 0) and (npcBot:GetStashValue() <= 0)
				then
					npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_TRANSFER_ITEMS);
					return;
				elseif (npcBot.secretShopMode == true) and (npcBot:DistanceFromSecretShop() >= 3000) and (npcBot:GetCourierValue() <= 0)
					and not utility.IsCourierItemSlotsFull() and (state == COURIER_STATE_AT_BASE)
				then
					npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SECRET_SHOP);
					return;
				end
			else
				if (npcBot.secretShopMode == true) and not utility.IsCourierItemSlotsFull() and (npcBot:GetCourierValue() <= 0) and (state == COURIER_STATE_AT_BASE)
				then
					npcBot:ActionImmediate_Courier(courier, COURIER_ACTION_SECRET_SHOP);
					return;
				end
			end
		end
	end
end

--#endregion

--#region BUYBACK THINK
function BuybackUsageThink()
	local npcBot = GetBot();
	if not npcBot:IsHero() or npcBot:IsAlive() or npcBot:IsIllusion() or utility.IsClone(npcBot) or utility.IsCloneMeepo(npcBot)
	then
		return;
	elseif not npcBot:IsAlive() and not npcBot:HasBuyback()
	then
		return;
	end

	local respawnTime = npcBot:GetRespawnTime();

	if npcBot:HasBuyback() and (respawnTime > 60.0)
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
function GlyphUsageThink()
	local npcBot = GetBot();

	if npcBot == nil or not utility.IsHero(npcBot) or utility.IsClone(npcBot) or utility.IsCloneMeepo(npcBot)
	then
		return;
	end

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
		if tower ~= nil and (tower:GetHealth() > 0 and tower:GetHealth() / tower:GetMaxHealth() <= 0.7)
			and utility.IsTargetedByEnemy(tower, true)
		then
			npcBot:ActionImmediate_Chat("Использую Glyph для защиты " .. tower:GetUnitName(), false);
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
		if barrack ~= nil and (barrack:GetHealth() > 0 and barrack:GetHealth() / barrack:GetMaxHealth() <= 0.8)
			and utility.IsTargetedByEnemy(barrack, true)
		then
			npcBot:ActionImmediate_Chat("Использую Glyph для защиты " .. barrack:GetUnitName(), false);
			npcBot:ActionImmediate_Ping(barrack:GetLocation().x, barrack:GetLocation().y, false);
			npcBot:ActionImmediate_Glyph();
			return;
		end
	end

	local ancient = GetAncient(GetTeam());
	if ancient ~= nil and (ancient:GetHealth() > 0 and ancient:GetHealth() / ancient:GetMaxHealth() <= 0.8)
		and utility.IsTargetedByEnemy(ancient, true)
	then
		npcBot:ActionImmediate_Chat("Использую Glyph для защиты " .. ancient:GetUnitName(), false);
		npcBot:ActionImmediate_Ping(ancient:GetLocation().x, ancient:GetLocation().y, false);
		npcBot:ActionImmediate_Glyph();
		return;
	end
end

--#endregion

--#region ITEM USAGE THINK
local function HaveHealthRegenBuff(npcTarget)
	return npcTarget:HasModifier('modifier_fountain_aura_buff') or
		npcTarget:HasModifier('modifier_bottle_regeneration') or
		npcTarget:HasModifier('modifier_flask_healing');
end

local function HaveManaRegenBuff(npcTarget)
	return npcTarget:HasModifier('modifier_fountain_aura_buff') or
		npcTarget:HasModifier('modifier_bottle_regeneration') or
		npcTarget:HasModifier('modifier_clarity_potion');
end

local function IsItemAvailable(item_name)
	local npcBot = GetBot();
	local slot = npcBot:FindItemSlot(item_name);
	if npcBot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN and npcBot:GetItemInSlot(slot):IsFullyCastable()
	then
		return npcBot:GetItemInSlot(slot);
	end
	return nil;
end

function IsNeutralItemAvailable(item_name)
	local npcBot = GetBot();
	local neutralItem = npcBot:GetItemInSlot(16);

	if neutralItem ~= nil and neutralItem:GetName() == item_name and neutralItem:IsFullyCastable()
	then
		return neutralItem;
	end
	return nil;
end

local function Contains(set, key) -- Содержит ли таблица указанный коюч
	for index, value in ipairs(set) do
		if tostring(value) == tostring(key)
		then
			return true;
		end
	end
end

-- Имена способностей для использования которых необходимо использовать item_refresher
local _tableOfUltimatesAbility =
{
	"abaddon_borrowed_time",
	"antimage_mana_void",
	"bane_fiends_grip",
	"batrider_flaming_lasso",
	"beastmaster_primal_roar",
	"bloodseeker_rupture",
	"brewmaster_primal_split",
	"chen_hand_of_god",
	"crystal_maiden_freezing_field",
	"dark_seer_wall_of_replica",
	"dark_willow_terrorize",
	"dazzle_shallow_grave",
	"death_prophet_exorcism",
	"doom_bringer_doom",
	"earthshaker_echo_slam",
	"elder_titan_earth_splitter",
	"enigma_black_hole",
	"faceless_void_chronosphere",
	"gyrocopter_call_down",
	"jakiro_macropyre",
	"juggernaut_omni_slash",
	"kunkka_ghostship",
	"lich_chain_frost",
	"lion_finger_of_death",
	"luna_eclipse",
	"magnataur_reverse_polarity",
	"medusa_stone_gaze",
	"monkey_king_wukongs_command",
	"necrolyte_reapers_scythe",
	"nevermore_requiem",
	"obsidian_destroyer_sanity_eclipse",
	"omniknight_guardian_angel",
	"oracle_false_promise",
	"phoenix_supernova",
	"queenofpain_sonic_wave",
	"sandking_epicenter",
	"shadow_shaman_mass_serpent_ward",
	"silencer_global_silence",
	"skeleton_king_reincarnation",
	"skywrath_mage_mystic_flare",
	"slark_shadow_dance",
	"snapfire_mortimer_kisses",
	"spectre_haunt",
	"spirit_breaker_nether_strike",
	"sven_gods_strength",
	"terrorblade_metamorphosis",
	"tidehunter_ravage",
	"treant_overgrowth",
	"tusk_walrus_punch",
	"undying_tombstone",
	"venomancer_noxious_plague",
	"warlock_rain_of_chaos",
	"winter_wyvern_winters_curse",
	"witch_doctor_death_ward",
	"zuus_thundergods_wrath",
}

local previousKills = 0;
local isVictorySay = false;
local isDefeatSay = false;
local linesKillEnemyHero = {
	"You'll be lucky next time...or not.",
	"No luck - pure skill!",
	"It was easy!",
	"Don't be upset, it's just a game, you know?",
	"Ha! Not bad, huh?",
	"You can do better!",
	"Next time, try not to die!",
	"I learned from the best, what chance did you even have?",
	"Are there passive bots against us or what?",
	"You're not very good at this game, are you?",
}

local linesDefeat = {
	"GG.",
	"Well played.",
	"Next time we will win.",
	"Wow, that's unexpected.",
	"I'm waiting for a tip on my profile!",
}

local linesVictory = {
	"GG.",
	"Well played.",
	"Easiest win!",
	"Didn't even break a sweat! Go next?",
	"Try practicing with bots, okay?",
	"We won? I mean... of course we won!",
	"Well done everyone!",
}

local function BotChatMessages()
	local npcBot = GetBot();
	--local currentKills = GetHeroKills(npcBot:GetPlayerID());
	local ancient = GetAncient(GetTeam());
	local enemyAncient = GetAncient(GetOpposingTeam());

	if ancient ~= nil and not ancient:IsInvulnerable() and ancient:GetHealth() / ancient:GetMaxHealth() < 0.1
	then
		if (isDefeatSay == false)
		then
			local message = linesDefeat[math.random(#linesDefeat)];
			npcBot:ActionImmediate_Chat(message, true);
			isDefeatSay = true;
			return;
		end
	end

	if enemyAncient ~= nil and enemyAncient:CanBeSeen() and not enemyAncient:IsInvulnerable() and enemyAncient:GetHealth() / enemyAncient:GetMaxHealth() < 0.1
	then
		if (isVictorySay == false)
		then
			local message = linesVictory[math.random(#linesVictory)];
			npcBot:ActionImmediate_Chat(message, true);
			isVictorySay = true;
			return;
		end
	end

	--[[ 	if (currentKills > previousKills)
	then
		if RollPercentage(95)
		then
			local message = linesKillEnemyHero[math.random(#linesKillEnemyHero)];
			npcBot:ActionImmediate_Chat(message, true);
		end
		previousKills = currentKills;
		return;
	end ]]
end

--local message = nil;
--local message = linesKillEnemyHero[math.random(#linesKillEnemyHero)];

function ItemUsageThink()
	local npcBot = GetBot();

	GlyphUsageThink()

	if not utility.IsHero(npcBot) or not utility.CanUseItems(npcBot) or utility.IsCloneMeepo(npcBot) or
		(npcBot:IsInvisible() and not npcBot:HasModifier("modifier_invisible"))
	then
		return;
	end

	if not utility.IsClone(npcBot)
	then
		BotChatMessages()
	end

	local botMode = npcBot:GetActiveMode();
	local attackRange = npcBot:GetAttackRange();
	local botTarget = npcBot:GetTarget();
	local botVisionRange = npcBot:GetCurrentVisionRange();
	local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
	local manaPercent = npcBot:GetMana() / npcBot:GetMaxMana();
	local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

	-- NO INTERRUPT CAST ITEM
	-- item_shadow_amulet/item_glimmer_cape
	local shadowAmulet = IsItemAvailable('item_shadow_amulet');
	local glimmerCape = IsItemAvailable('item_glimmer_cape');
	if shadowAmulet ~= nil and shadowAmulet:IsFullyCastable()
	then
		local itemRange = shadowAmulet:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and not ally:IsInvisible() and not ally:HasModifier("modifier_spirit_breaker_charge_of_darkness")
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(2.0)) or ally:IsChanneling() or
						ally:HasModifier("modifier_crystal_maiden_freezing_field") or
						ally:HasModifier("modifier_teleporting") or
						ally:HasModifier("modifier_wisp_relocate_return")
					then
						--npcBot:ActionImmediate_Chat("Использую shadow Amulet на союзнике!", true);
						npcBot:Action_UseAbilityOnEntity(shadowAmulet, ally);
						return;
					end
				end
			end
		end
	end
	if glimmerCape ~= nil and glimmerCape:IsFullyCastable()
	then
		local itemRange = glimmerCape:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and not ally:IsInvisible() and not ally:HasModifier("modifier_spirit_breaker_charge_of_darkness")
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(2.0)) or ally:IsChanneling() or
						ally:HasModifier("modifier_crystal_maiden_freezing_field") or
						ally:HasModifier("modifier_teleporting") or
						ally:HasModifier("modifier_wisp_relocate_return")
					then
						--npcBot:ActionImmediate_Chat("Использую glimmerCape на союзнике!", true);
						npcBot:Action_UseAbilityOnEntity(glimmerCape, ally);
						return;
					end
				end
			end
		end
	end

	-- INTERRUPT CAST ITEMS
	if npcBot:IsChanneling() or npcBot:IsUsingAbility()
	then
		return;
	end

	-- item_tpscroll
	local tps = npcBot:GetItemInSlot(15);
	if tps ~= nil and tps:IsFullyCastable()
	then
		if botMode ~= BOT_MODE_EVASIVE_MANEUVERS
		then
			local shouldTP, tpLocation = teleportation_usage_generic.ShouldTP()
			if shouldTP and tpLocation ~= nil
			then
				npcBot:Action_UseAbilityOnLocation(tps, tpLocation);
				return;
			end
		end
	end

	-- item_tango/item_tango_single
	local tango = IsItemAvailable("item_tango");
	local tangoSingle = IsItemAvailable("item_tango_single");
	if tango ~= nil and tango:IsFullyCastable()
	then
		local itemRange = tango:GetCastRange();
		local itemHeal = tango:GetSpecialValueInt("health_regen") * tango:GetSpecialValueInt("buff_duration");
		local trees = npcBot:GetNearbyTrees(itemRange + botVisionRange);
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange + botVisionRange, false, BOT_MODE_NONE);
		if npcBot:GetHealth() < npcBot:GetMaxHealth() - itemHeal and
			(#trees > 0) and
			IsLocationVisible(GetTreeLocation(trees[1])) and
			IsLocationPassable(GetTreeLocation(trees[1])) and
			npcBot:DistanceFromFountain() > 1000 and
			utility.CanBeHeal(npcBot) and
			not HaveHealthRegenBuff(npcBot) and
			not npcBot:HasModifier("modifier_tango_heal")
		then
			npcBot:Action_UseAbilityOnTree(tango, trees[1]);
			return;
		end
		if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot)
		then
			if (#allyHeroes > 1)
			then
				for _, ally in pairs(allyHeroes)
				do
					if ally ~= npcBot and utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6)
						and utility.GetItemCount(ally, "item_tango") == 0 and utility.GetItemCount(ally, "item_tango_single") == 0
						and not ally:HasModifier("modifier_tango_heal") and utility.CanBeHeal(ally) and not utility.IsTargetItemSlotsFull(ally)
					then
						npcBot:Action_UseAbilityOnEntity(tango, ally);
						return;
					end
				end
			end
		end
	end
	if tangoSingle ~= nil and tangoSingle:IsFullyCastable()
	then
		local itemRange = tangoSingle:GetCastRange();
		local itemHeal = tangoSingle:GetSpecialValueInt("health_regen") * tangoSingle:GetSpecialValueInt("buff_duration");
		local trees = npcBot:GetNearbyTrees(itemRange + botVisionRange);
		if npcBot:GetHealth() < npcBot:GetMaxHealth() - itemHeal and
			(#trees > 0) and
			IsLocationVisible(GetTreeLocation(trees[1])) and
			IsLocationPassable(GetTreeLocation(trees[1])) and
			utility.CanBeHeal(npcBot) and
			not npcBot:HasModifier("modifier_tango_heal")
		then
			npcBot:Action_UseAbilityOnTree(tangoSingle, trees[1]);
			return;
		end
	end

	-- item_flask/item_clarity
	local flask = IsItemAvailable("item_flask");
	local clarity = IsItemAvailable("item_clarity");
	if flask ~= nil and flask:IsFullyCastable()
	then
		local itemRange = flask:GetCastRange();
		local itemHeal = flask:GetSpecialValueInt("health_regen") * flask:GetSpecialValueInt("buff_duration");
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange * 2, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and
					ally:GetHealth() < ally:GetMaxHealth() - itemHeal and
					ally:TimeSinceDamagedByAnyHero() >= 5.0 and
					ally:TimeSinceDamagedByCreep() >= 5.0 and
					ally:DistanceFromFountain() > 3000 and
					not HaveHealthRegenBuff(ally) and
					utility.CanBeHeal(ally)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет flask что бы подлечить союзника!",true);
					npcBot:Action_UseAbilityOnEntity(flask, ally);
					return;
				end
			end
		end
	end
	if clarity ~= nil and clarity:IsFullyCastable()
	then
		local itemRange = clarity:GetCastRange();
		local itemManaRegen = clarity:GetSpecialValueInt("mana_regen") * clarity:GetSpecialValueInt("buff_duration");
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange * 2, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and
					ally:GetMana() < ally:GetMaxMana() - itemManaRegen and
					ally:TimeSinceDamagedByAnyHero() >= 5.0 and
					ally:TimeSinceDamagedByCreep() >= 5.0 and
					ally:DistanceFromFountain() > 3000 and
					not HaveManaRegenBuff(ally)
				then
					npcBot:Action_UseAbilityOnEntity(clarity, ally);
					return;
				end
			end
		end
	end

	-- item_faerie_fire
	local faerieFire = IsItemAvailable("item_faerie_fire");
	if faerieFire ~= nil and faerieFire:IsFullyCastable()
	then
		if npcBot:DistanceFromFountain() > 1000 and (healthPercent <= 0.2) and utility.CanBeHeal(npcBot) and
			(npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or npcBot:WasRecentlyDamagedByCreep(2.0))
		then
			--npcBot:ActionImmediate_Chat("Использую предмет Faerie Fire что бы подлечить себя!",true);
			npcBot:Action_UseAbility(faerieFire);
			return;
		end
	end

	-- item_enchanted_mango
	local enchantedMango = IsItemAvailable("item_enchanted_mango");
	if enchantedMango ~= nil and enchantedMango:IsFullyCastable()
	then
		if utility.PvPMode(npcBot) and (manaPercent <= 0.3) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
		then
			--npcBot:ActionImmediate_Chat("Использую предмет Enchanted Mango! что бы восстановить себе ману!",true);
			npcBot:Action_UseAbility(enchantedMango);
			return;
		end
	end

	-- item_blood_grenade
	local bloodGrenade = IsItemAvailable("item_blood_grenade");
	if bloodGrenade ~= nil and bloodGrenade:IsFullyCastable()
	then
		local itemRange = bloodGrenade:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(bloodGrenade, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую bloodGrenade по врагу!", true);
				npcBot:Action_UseAbilityOnLocation(bloodGrenade, botTarget:GetLocation());
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0) and (healthPercent >= 0.2 and healthPercent <= 0.6)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.CanCastSpellOnTarget(bloodGrenade, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет bloodGrenade для оступления!", true);
						npcBot:Action_UseAbilityOnLocation(bloodGrenade, enemy:GetLocation());
						return;
					end
				end
			end
		end
	end

	-- item_healing_lotus/item_great_healing_lotus
	local healingLotus = IsItemAvailable("item_famango");
	local greatHealingLotus = IsItemAvailable("item_great_famango");
	local greaterHealingLotus = IsItemAvailable("item_greater_famango");
	if (healingLotus ~= nil and healingLotus:IsFullyCastable()) or (greatHealingLotus ~= nil and greatHealingLotus:IsFullyCastable())
		or (greaterHealingLotus ~= nil and greaterHealingLotus:IsFullyCastable())
	then
		if healingLotus ~= nil and (healthPercent <= 0.8 or manaPercent <= 0.8)
		then
			--npcBot:ActionImmediate_Chat("Использую предмет healingLotus!", true);
			npcBot:Action_UseAbility(healingLotus);
			return;
		end
		if greatHealingLotus ~= nil and (healthPercent <= 0.6 or manaPercent <= 0.6)
		then
			--npcBot:ActionImmediate_Chat("Использую предмет greatHealingLotus!", true);
			npcBot:Action_UseAbility(greatHealingLotus);
			return;
		end
		if greaterHealingLotus ~= nil and (healthPercent <= 0.5 or manaPercent <= 0.5)
		then
			--npcBot:ActionImmediate_Chat("Использую предмет greaterHealingLotus!", true);
			npcBot:Action_UseAbility(greaterHealingLotus);
			return;
		end
	end

	-- item_cheese
	local cheese = IsItemAvailable("item_cheese");
	if cheese ~= nil and cheese:IsFullyCastable()
	then
		if (healthPercent <= 0.3) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0))
			and utility.CanBeHeal(npcBot)
		then
			npcBot:Action_UseAbility(cheese);
			return;
		end
	end

	-- item_soul_ring
	local soulRing = IsItemAvailable("item_soul_ring");
	if soulRing ~= nil and soulRing:IsFullyCastable()
	then
		local itemHealthCost = soulRing:GetSpecialValueInt("AbilityHealthCost");
		local itemMana = soulRing:GetSpecialValueInt("mana_gain");
		if utility.PvPMode(npcBot) and not npcBot:IsSilenced()
		then
			if utility.IsHero(botTarget) and npcBot:GetHealth() > itemHealthCost and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 3)
			then
				for i = 0, 23, 1 do
					local ability = npcBot:GetAbilityInSlot(i)
					if ability ~= nil and not ability:IsTalent() and not ability:IsHidden() and not ability:IsPassive()
						and ability:IsCooldownReady() and npcBot:GetMana() < ability:GetManaCost()
					then
						if npcBot:GetMana() + itemMana >= ability:GetManaCost()
						then
							--npcBot:ActionImmediate_Chat("Использую предмет soulRing что бы восстановить себе ману!",true);
							npcBot:Action_UseAbility(soulRing);
							return;
						end
					end
				end
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local reincarnation = npcBot:GetAbilityByName("skeleton_king_reincarnation");
			if reincarnation ~= nil and not reincarnation:IsHidden() and reincarnation:IsCooldownReady() and npcBot:GetMana() < reincarnation:GetManaCost()
				and (healthPercent <= 0.2) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				if npcBot:GetMana() + itemMana >= reincarnation:GetManaCost()
				then
					npcBot:Action_UseAbility(soulRing);
					return;
				end
			end
		end
	end

	-- item_magic_stick/item_magic_wand/item_holy_locket
	local magicStick = IsItemAvailable("item_magic_stick");
	local magicWand = IsItemAvailable("item_magic_wand");
	local holyLocket = IsItemAvailable("item_holy_locket");
	if magicStick ~= nil and magicStick:IsFullyCastable()
	then
		if (healthPercent <= 0.5) or (manaPercent <= 0.4) and utility.CanBeHeal(npcBot)
			and magicStick:GetCurrentCharges() > 1
		then
			--npcBot:ActionImmediate_Chat("Использую magic Stick!", true);
			npcBot:Action_UseAbility(magicStick);
			return;
		end
	end
	if magicWand ~= nil and magicWand:IsFullyCastable()
	then
		if (healthPercent <= 0.5) or (manaPercent <= 0.4) and utility.CanBeHeal(npcBot)
			and magicWand:GetCurrentCharges() > 1
		then
			--npcBot:ActionImmediate_Chat("Использую magic Stick!", true);
			npcBot:Action_UseAbility(magicWand);
			return;
		end
	end
	if holyLocket ~= nil and holyLocket:IsFullyCastable()
	then
		local itemRange = holyLocket:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and utility.CanBeHeal(ally) and holyLocket:GetCurrentCharges() > 1
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7)
					then
						npcBot:Action_UseAbilityOnEntity(holyLocket, ally);
						return;
					elseif (ally:GetMana() / ally:GetMaxMana() <= 0.5)
					then
						npcBot:Action_UseAbilityOnEntity(holyLocket, ally);
						return;
					end
				end
			end
		end
	end

	-- item_dust
	local dust = IsItemAvailable("item_dust");
	if dust ~= nil and dust:IsFullyCastable()
	then
		local itemRange = dust:GetAOERadius();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE)
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes)
			do
				if enemy:IsInvisible() and utility.IsHero(enemy) and not enemy:HasModifier("modifier_item_dustofappearance")
				then
					--npcBot:ActionImmediate_Chat("Использую предмет dust против невидимых героев!",true);
					npcBot:Action_UseAbility(dust);
					npcBot:ActionImmediate_Ping(enemy:GetLocation().x, enemy:GetLocation().y, true);
					return;
				end
			end
		end
	end

	-- item_quelling_blade/item_bfury
	local quellingBlade = IsItemAvailable('item_quelling_blade');
	local battleFury = IsItemAvailable('item_bfury');
	if quellingBlade ~= nil and quellingBlade:IsFullyCastable()
	then
		local itemRange = quellingBlade:GetCastRange();
		local trees = npcBot:GetNearbyTrees(itemRange);
		if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and
			(#trees > 0) and IsLocationVisible(GetTreeLocation(trees[1])) and IsLocationPassable(GetTreeLocation(trees[1]))
		then
			--npcBot:ActionImmediate_Chat("Использую quelling Blade!", true);
			npcBot:Action_UseAbilityOnTree(quellingBlade, trees[1]);
			return;
		end
	end
	if battleFury ~= nil and battleFury:IsFullyCastable()
	then
		local itemRange = battleFury:GetCastRange();
		local trees = npcBot:GetNearbyTrees(itemRange);
		if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and
			(#trees > 0) and IsLocationVisible(GetTreeLocation(trees[1])) and IsLocationPassable(GetTreeLocation(trees[1]))
		then
			--npcBot:ActionImmediate_Chat("Использую battleFury!", true);
			npcBot:Action_UseAbilityOnTree(battleFury, trees[1]);
			return;
		end
	end

	-- item_power_treads
	local powerTreads = IsItemAvailable("item_power_treads");
	if powerTreads ~= nil and powerTreads:IsFullyCastable()
	then
		if npcBot:GetLevel() <= 6
		then
			if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
			then
				npcBot:Action_UseAbility(powerTreads);
				return;
			end
		else
			if utility.RetreatMode(npcBot)
			then
				if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
				then
					npcBot:Action_UseAbility(powerTreads);
					return;
				end
			else
				if npcBot:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH
				then
					if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
					then
						npcBot:Action_UseAbility(powerTreads);
						return;
					end
				elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_AGILITY
				then
					if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT
					then
						npcBot:Action_UseAbility(powerTreads);
						return;
					end
				elseif npcBot:GetPrimaryAttribute() == ATTRIBUTE_INTELLECT
				then
					if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY
					then
						npcBot:Action_UseAbility(powerTreads);
						return;
					end
				else
					local biggerAttribute = utility.GetBiggerAttribute(npcBot);
					if biggerAttribute == ATTRIBUTE_STRENGTH
					then
						if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_STRENGTH
						then
							--npcBot:ActionImmediate_Chat("Использую PowerTreads на больший стат силу!", true);
							npcBot:Action_UseAbility(powerTreads);
							return;
						end
					elseif biggerAttribute == ATTRIBUTE_AGILITY
					then
						if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_INTELLECT
						then
							--npcBot:ActionImmediate_Chat("Использую PowerTreads на больший стат ловкость!", true);
							npcBot:Action_UseAbility(powerTreads);
							return;
						end
					elseif biggerAttribute == ATTRIBUTE_INTELLECT
					then
						if powerTreads:GetPowerTreadsStat() ~= ATTRIBUTE_AGILITY
						then
							--npcBot:ActionImmediate_Chat("Использую PowerTreads на больший стат интеллект!", true);
							npcBot:Action_UseAbility(powerTreads);
							return;
						end
					end
				end
			end
		end
	end

	-- item_arcane_boots
	local arcaneBoots = IsItemAvailable("item_arcane_boots");
	if arcaneBoots ~= nil and arcaneBoots:IsFullyCastable() and not npcBot:IsInvisible()
	then
		local itemRange = arcaneBoots:GetAOERadius();
		local itemMana = arcaneBoots:GetSpecialValueInt("replenish_amount");
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and ally:GetMana() < ally:GetMaxMana() - itemMana
				then
					--npcBot:ActionImmediate_Chat("Использую предмет Arcane Boots что бы восстановить ману союзнику!",true);
					npcBot:Action_UseAbility(arcaneBoots);
					return;
				end
			end
		end
	end

	-- item_phase_boots
	local phaseBoots = IsItemAvailable("item_phase_boots");
	if phaseBoots ~= nil and phaseBoots:IsFullyCastable()
	then
		if not utility.IsItemBreaksInvisibility(phaseBoots)
		then
			if utility.IsMoving(npcBot)
			then
				npcBot:Action_UseAbility(phaseBoots);
				return;
			end
		end
	end

	-- item_pavise
	local pavise = IsItemAvailable("item_pavise");
	local solarCrest = IsItemAvailable("item_solar_crest");
	if pavise ~= nil and pavise:IsFullyCastable()
	then
		local itemRange = pavise:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and not ally:HasModifier("modifier_item_pavise_shield")
				then
					if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
						(ally:WasRecentlyDamagedByAnyHero(2.0) or
							ally:WasRecentlyDamagedByTower(2.0) or
							ally:WasRecentlyDamagedByCreep(2.0))
					then
						--npcBot:ActionImmediate_Chat("Использую предмет pavise!", true);
						npcBot:Action_UseAbilityOnEntity(pavise, ally);
						return;
					end
				end
			end
		end
	end
	if solarCrest ~= nil and solarCrest:IsFullyCastable()
	then
		local itemRange = solarCrest:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not ally:HasModifier("modifier_item_solar_crest_armor_addition") and not utility.IsIllusion(ally)
				then
					if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
						(ally:WasRecentlyDamagedByAnyHero(2.0) or
							ally:WasRecentlyDamagedByTower(2.0) or
							ally:WasRecentlyDamagedByCreep(2.0))
					then
						--npcBot:ActionImmediate_Chat("Использую предмет solarCrest!", true);
						npcBot:Action_UseAbilityOnEntity(solarCrest, ally);
						return;
					end
					if utility.IsHero(botTarget) and ally ~= npcBot
					then
						if GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() * 2 or
							GetUnitToUnitDistance(ally, botTarget) > (ally:GetAttackRange() * 2)
						then
							--npcBot:ActionImmediate_Chat("Использую предмет solarCrest на союзника для атаки!", true);
							npcBot:Action_UseAbilityOnEntity(solarCrest, ally);
							return;
						end
					end
				end
			end
		end
	end

	-- item_ancient_janggo/item_boots_of_bearing
	local drumOfEndurance = IsItemAvailable("item_ancient_janggo");
	local bootsOfBearing = IsItemAvailable("item_boots_of_bearing");
	if drumOfEndurance ~= nil and drumOfEndurance:IsFullyCastable()
	then
		local itemRange = drumOfEndurance:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and
					not ally:HasModifier("modifier_item_ancient_janggo_active") and
					not ally:HasModifier("modifier_item_boots_of_bearing_active")
				then
					if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
					then
						if GetUnitToUnitDistance(ally, botTarget) <= itemRange
						then
							--npcBot:ActionImmediate_Chat("Использую drum Of Endurance для нападения!", true);
							npcBot:Action_UseAbility(drumOfEndurance);
							return;
						end
					end
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(2.0)
					then
						--npcBot:ActionImmediate_Chat("Использую drum Of Endurance для отступления!",true);
						npcBot:Action_UseAbility(drumOfEndurance);
						return;
					end
				end
			end
		end
	end
	if bootsOfBearing ~= nil and bootsOfBearing:IsFullyCastable()
	then
		local itemRange = bootsOfBearing:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and
					not ally:HasModifier("modifier_item_ancient_janggo_active") and
					not ally:HasModifier("modifier_item_boots_of_bearing_active")
				then
					if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
					then
						if GetUnitToUnitDistance(ally, botTarget) <= itemRange
						then
							--npcBot:ActionImmediate_Chat("Использую bootsOfBearing для нападения!", true);
							npcBot:Action_UseAbility(bootsOfBearing);
							return;
						end
					end
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(2.0)
					then
						--npcBot:ActionImmediate_Chat("Использую bootsOfBearing для отступления!",true);
						npcBot:Action_UseAbility(bootsOfBearing);
						return;
					end
				end
			end
		end
	end

	-- item_mekansm/item_guardian_greaves
	local mekansm = IsItemAvailable("item_mekansm");
	local guardianGreaves = IsItemAvailable("item_guardian_greaves");
	if mekansm ~= nil and mekansm:IsFullyCastable()
	then
		local itemRange = mekansm:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.5)
					and not ally:HasModifier("modifier_item_mekansm_noheal")
				then
					--npcBot:ActionImmediate_Chat("Использую предмет mekansm!",true);
					npcBot:Action_UseAbility(mekansm);
					return;
				end
			end
		end
	end
	if guardianGreaves ~= nil and guardianGreaves:IsFullyCastable()
	then
		local itemRange = guardianGreaves:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally)
				then
					if utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.5)
						and not ally:HasModifier("modifier_item_mekansm_noheal")
					then
						--npcBot:ActionImmediate_Chat("Использую предмет guardianGreaves!",true);
						npcBot:Action_UseAbility(guardianGreaves);
						return;
					end
					if (ally:GetMana() / ally:GetMaxMana() <= 0.3)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет Guardian greaves для маны!",true);
						npcBot:Action_UseAbility(guardianGreaves);
						return;
					end
				end
			end
		end
	end

	-- item_crimson_guard
	local crimsonGuard = IsItemAvailable("item_crimson_guard");
	if crimsonGuard ~= nil and crimsonGuard:IsFullyCastable()
	then
		local itemRange = crimsonGuard:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and not ally:HasModifier("modifier_item_crimson_guard_nostack")
				then
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(2.0)) or
						(ally:GetHealth() / ally:GetMaxHealth() <= 0.5 and ally:WasRecentlyDamagedByTower(2.0)) or
						(ally:GetHealth() / ally:GetMaxHealth() <= 0.3 and ally:WasRecentlyDamagedByCreep(2.0))
					then
						--npcBot:ActionImmediate_Chat("Использую предмет crimson Guard!",true);
						npcBot:Action_UseAbility(crimsonGuard);
						return;
					end
				end
			end
		end
	end

	-- item_shivas_guard
	local shivasGuard = IsItemAvailable("item_shivas_guard");
	if shivasGuard ~= nil and shivasGuard:IsFullyCastable()
	then
		local itemRange = shivasGuard:GetAOERadius();
		if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes) do
					if utility.CanCastOnMagicImmuneTarget(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую item_shivas_guard для нападения/отступления!",true);
						npcBot:Action_UseAbility(shivasGuard);
						return;
					end
				end
			end
		end
	end

	-- item_pipe
	local pipe = IsItemAvailable("item_pipe");
	if pipe ~= nil and pipe:IsFullyCastable()
	then
		local itemRange = pipe:GetAOERadius();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and ally:WasRecentlyDamagedByAnyHero(2.0)
					and not ally:HasModifier("modifier_item_pipe_barrier")
				then
					--npcBot:ActionImmediate_Chat("Использую предмет pipe!", true);
					npcBot:Action_UseAbility(pipe);
					return;
				end
			end
		end
	end

	--[[ 		 	-- item_hood_of_defiance(DELETE)/item_eternal_shroud
	--local hoodOfDefiance = IsItemAvailable("item_hood_of_defiance");
	--local eternalShroud = IsItemAvailable("item_eternal_shroud");
		
		if hoodOfDefiance ~= nil and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9 and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			npcBot:Action_UseAbility(hoodOfDefiance);
			--npcBot:ActionImmediate_Chat("Использую предмет hood Of Defiance!", true);
			--return;
 		elseif eternalShroud ~= nil and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
		then
			npcBot:Action_UseAbility(eternalShroud);
			npcBot:ActionImmediate_Chat("Использую предмет eternal Shroud!", true);
			--return;  ]]


	-- item_force_staff
	local forceStaff = IsItemAvailable("item_force_staff");
	if forceStaff ~= nil and forceStaff:IsFullyCastable()
	then
		local itemRange = forceStaff:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if not utility.CanMove(enemy)
				then
					npcBot:Action_UseAbilityOnEntity(forceStaff, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
					and utility.CanMove(npcBot)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет force_staff что бы сблизиться с целью!",true);
					npcBot:Action_UseAbilityOnEntity(forceStaff, npcBot);
					return;
				end
				if botTarget:IsFacingLocation(npcBot:GetLocation(), 20) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
				then
					--npcBot:ActionImmediate_Chat("Использую предмет force_staff на врага который смотрит в мою сторону!",true);
					npcBot:Action_UseAbilityOnEntity(forceStaff, botTarget);
					return;
				end
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allyHeroes > 0)
			then
				for _, ally in pairs(allyHeroes)
				do
					if not utility.IsIllusion(ally) and utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and ally:WasRecentlyDamagedByAnyHero(2.0)
						and ally:IsFacingLocation(utility.GetFountainLocation(), 40) and utility.CanMove(ally)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет force_staff для отступления!",true);
						npcBot:Action_UseAbilityOnEntity(forceStaff, ally);
						return;
					end
				end
			end
		end
	end

	-- item_hurricane_pike
	local hurricanePike = IsItemAvailable("item_hurricane_pike");
	if hurricanePike ~= nil and hurricanePike:IsFullyCastable()
	then
		local pikeAllyRange = hurricanePike:GetCastRange();
		local pikeEnemyRange = hurricanePike:GetSpecialValueInt("cast_range_enemy");
		local enemyHeroes = npcBot:GetNearbyHeroes(pikeEnemyRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if not utility.CanMove(enemy)
				then
					npcBot:Action_UseAbilityOnEntity(hurricanePike, enemy);
					return;
				end
			end
		end

		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget)
			then
				if GetUnitToUnitDistance(npcBot, botTarget) <= pikeEnemyRange
				then
					--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike на ближнего врага!", true);
					npcBot:Action_UseAbilityOnEntity(hurricanePike, botTarget);
					return;
				end
				if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= pikeAllyRange
					and npcBot:IsFacingLocation(botTarget:GetLocation(), 10) and utility.CanMove(npcBot)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike что бы сблизиться с врагом!",true);
					npcBot:Action_UseAbilityOnEntity(hurricanePike, npcBot);
					return;
				end
			end
		end

		if utility.RetreatMode(npcBot)
		then
			local allyHeroes = npcBot:GetNearbyHeroes(pikeAllyRange, false, BOT_MODE_NONE);
			if (#allyHeroes > 0)
			then
				for _, ally in pairs(allyHeroes)
				do
					if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and ally:WasRecentlyDamagedByAnyHero(2.0)
						and ally:IsFacingLocation(utility.GetFountainLocation(), 20) and utility.CanMove(ally)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет hurricane Pike для отступления!",true);
						npcBot:Action_UseAbilityOnEntity(hurricanePike, ally);
						return;
					end
				end
			end
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes) do
					if utility.CanCastOnMagicImmuneTarget(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет hurricanePike что бы оторваться от врага!",true);
						npcBot:Action_UseAbilityOnEntity(hurricanePike, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_abyssal_blade
	local abyssalBlade = IsItemAvailable("item_abyssal_blade");
	if abyssalBlade ~= nil and abyssalBlade:IsFullyCastable()
	then
		local itemRange = abyssalBlade:GetCastRange() * 2;
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if enemy:IsChanneling()
				then
					npcBot:Action_UseAbilityOnEntity(abyssalBlade, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет abyssal blade на враге!", true);
				npcBot:Action_UseAbilityOnEntity(abyssalBlade, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет abyssal blade для оступления!",true);
						npcBot:Action_UseAbilityOnEntity(abyssalBlade, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_heavens_halberd
	local heavensHalberd = IsItemAvailable("item_heavens_halberd");
	if heavensHalberd ~= nil and heavensHalberd:IsFullyCastable()
	then
		local itemRange = heavensHalberd:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes)
			do
				if not enemy:IsDisarmed()
				then
					local enemyAttackTarget = enemy:GetAttackTarget();
					if enemyAttackTarget ~= nil and utility.IsHero(enemyAttackTarget)
					then
						npcBot:Action_UseAbilityOnEntity(heavensHalberd, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_orchid/item_bloodthorn
	local orchid = IsItemAvailable("item_orchid");
	local bloodthorn = IsItemAvailable("item_bloodthorn");
	if orchid ~= nil and orchid:IsFullyCastable()
	then
		local itemRange = orchid:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if enemy:IsChanneling() or enemy:IsUsingAbility() or enemy:IsCastingAbility()
				then
					npcBot:Action_UseAbilityOnEntity(orchid, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
				and utility.SafeCast(botTarget) and not botTarget:IsSilenced()
			then
				npcBot:Action_UseAbilityOnEntity(orchid, enemy);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.SafeCast(enemy) and not enemy:IsSilenced()
					then
						--npcBot:ActionImmediate_Chat("Использую предмет orchid для отступления!",true);
						npcBot:Action_UseAbilityOnEntity(orchid, enemy);
						return;
					end
				end
			end
		end
	end

	if bloodthorn ~= nil and bloodthorn:IsFullyCastable()
	then
		local itemRange = bloodthorn:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if enemy:IsChanneling() or enemy:IsUsingAbility() or enemy:IsCastingAbility()
				then
					npcBot:Action_UseAbilityOnEntity(bloodthorn, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
				and utility.SafeCast(botTarget) and not botTarget:IsSilenced()
			then
				npcBot:Action_UseAbilityOnEntity(bloodthorn, enemy);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.SafeCast(enemy) and not enemy:IsSilenced()
					then
						--npcBot:ActionImmediate_Chat("Использую предмет bloodthorn для отступления!",true);
						npcBot:Action_UseAbilityOnEntity(bloodthorn, enemy);
						return;
					end
				end
			end
		end
	end

	-- 	item_sphere/item_lotus_orb
	local sphere = IsItemAvailable("item_sphere");
	local lotusOrb = IsItemAvailable("item_lotus_orb");
	if sphere ~= nil and sphere:IsFullyCastable()
	then
		local itemRange = sphere:GetCastRange();
		local botIncomingSpells = npcBot:GetIncomingTrackingProjectiles();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 1) and (#botIncomingSpells <= 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if ally ~= npcBot and not utility.IsIllusion(ally) and not utility.HaveReflectSpell(ally)
				then
					local incomingSpells = ally:GetIncomingTrackingProjectiles();
					if (#incomingSpells > 0)
					then
						for _, spell in pairs(incomingSpells)
						do
							if (not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false)
							then
								--npcBot:ActionImmediate_Chat("Использую предмет sphere на союзнике!",true);
								npcBot:Action_UseAbilityOnEntity(sphere, ally);
								return;
							end
						end
					end
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and ally:WasRecentlyDamagedByAnyHero(1.0)
					then
						npcBot:Action_UseAbilityOnEntity(sphere, ally);
						return;
					end
				end
			end
		end
	end
	if lotusOrb ~= nil and lotusOrb:IsFullyCastable()
	then
		local itemRange = lotusOrb:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally)
				then
					local incomingSpells = ally:GetIncomingTrackingProjectiles();
					if (#incomingSpells > 0) and not utility.HaveReflectSpell(ally)
					then
						for _, spell in pairs(incomingSpells)
						do
							if (not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false)
							then
								--npcBot:ActionImmediate_Chat("Использую предмет lotusOrb на союзнике!",true);
								npcBot:Action_UseAbilityOnEntity(lotusOrb, ally);
								return;
							end
						end
					end
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and ally:WasRecentlyDamagedByAnyHero(1.0)
					then
						npcBot:Action_UseAbilityOnEntity(lotusOrb, ally);
						return;
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
			local itemRange = discord:GetAOERadius();
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if not enemy:HasModifier("modifier_item_veil_of_discord_debuff")
					then
						--npcBot:ActionImmediate_Chat("Использую предмет discord на враге!", true);
						npcBot:Action_UseAbility(discord);
						return;
					end
				end
			end
		end
	end

	-- item_mjollnir
	local mjollnir = IsItemAvailable("item_mjollnir");
	if (mjollnir ~= nil and mjollnir:IsFullyCastable())
	then
		local itemRange = mjollnir:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.9) and not ally:HasModifier("modifier_item_mjollnir_static") and
					(ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByCreep(2.0))
				then
					--npcBot:ActionImmediate_Chat("Использую предмет mjollnir на союзнике!",true);
					npcBot:Action_UseAbilityOnEntity(mjollnir, ally);
					return;
				end
			end
		end
	end

	-- item_black_king_bar
	local blackKingBar = IsItemAvailable("item_black_king_bar");
	if blackKingBar ~= nil and blackKingBar:IsFullyCastable()
	then
		if utility.CanCastOnMagicImmuneTarget(npcBot)
		then
			if utility.PvPMode(npcBot)
			then
				if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
					and npcBot:WasRecentlyDamagedByAnyHero(2.0)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет black King Bar для нападения!",true);
					npcBot:Action_UseAbility(blackKingBar);
					return;
				end
			end
			if utility.RetreatMode(npcBot)
			then
				if (healthPercent <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет black King Bar для отступления!",true);
					npcBot:Action_UseAbility(blackKingBar);
					return;
				end
			end
			if (#incomingSpells > 0)
			then
				for _, spell in pairs(incomingSpells)
				do
					if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
						and not utility.HaveReflectSpell(npcBot)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет black king bar для блока заклинания!",true);
						npcBot:Action_UseAbility(blackKingBar);
						return;
					end
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
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 3)
			then
				--npcBot:ActionImmediate_Chat("Использую предмет manta style для нападения!",true);
				npcBot:Action_UseAbility(manta);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (healthPercent <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				--npcBot:ActionImmediate_Chat("Использую предмет manta style для отступления!",true);
				npcBot:Action_UseAbility(manta);
				return;
			end
		end
		if (#incomingSpells > 0)
		then
			for _, spell in pairs(incomingSpells)
			do
				if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 200 and spell.is_attack == false
					and not utility.HaveReflectSpell(npcBot)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет manta для блока заклинания!",true);
					npcBot:Action_UseAbility(manta);
					return;
				end
			end
		end
	end

	-- item_blade_mail
	local bladeMail = IsItemAvailable("item_blade_mail");
	if bladeMail ~= nil and bladeMail:IsFullyCastable()
	then
		if not npcBot:HasModifier("modifier_item_blade_mail_reflect")
		then
			if utility.PvPMode(npcBot)
			then
				if npcBot:WasRecentlyDamagedByAnyHero(2.0)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет blade Mail для нападения!",true);
					npcBot:Action_UseAbility(bladeMail);
					return;
				end
			end
			if utility.RetreatMode(npcBot)
			then
				if (healthPercent <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет blade Mail для отступления!",true);
					npcBot:Action_UseAbility(bladeMail);
					return;
				end
			end
		end
	end

	-- item_bloodstone
	local bloodstone = IsItemAvailable("item_bloodstone");
	if bloodstone ~= nil and bloodstone:IsFullyCastable()
	then
		if not npcBot:HasModifier("modifier_item_bloodstone_active") and not npcBot:HasModifier("modifier_item_bloodstone_drained")
		then
			if utility.PvPMode(npcBot) and (healthPercent <= 0.5)
			then
				if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
				then
					npcBot:Action_UseAbility(bloodstone);
					return;
				end
			end
			if utility.RetreatMode(npcBot)
			then
				if (healthPercent <= 0.5) and npcBot:WasRecentlyDamagedByAnyHero(5.0)
				then
					npcBot:Action_UseAbility(bloodstone);
					return;
				end
			end
		end
	end

	-- item_satanic
	local satanic = IsItemAvailable("item_satanic");
	if satanic ~= nil and satanic:IsFullyCastable()
	then
		if not npcBot:HasModifier("modifier_item_satanic_unholy")
		then
			if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
			then
				if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
				then
					if (healthPercent <= 0.5) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
						and npcBot:GetAttackTarget() == botTarget
					then
						npcBot:Action_UseAbility(satanic);
						return;
					end
				end
			end
		end
	end

	--item_blink/item_overwhelming_blink/item_swift_blink/item_arcane_blink
	local blink = IsItemAvailable('item_blink');
	local overwhelmingBlink = IsItemAvailable('item_overwhelming_blink');
	local swiftBlink = IsItemAvailable('item_swift_blink');
	local arcaneBlink = IsItemAvailable('item_arcane_blink');
	if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
	then
		if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2) and utility.CanMove(npcBot)
		then
			if blink ~= nil and blink:IsFullyCastable()
			then
				--npcBot:ActionImmediate_Chat("Использую предмет Blink для нападения!",true);
				npcBot:Action_UseAbilityOnLocation(blink, botTarget:GetLocation());
				return;
			end
			if overwhelmingBlink ~= nil and overwhelmingBlink:IsFullyCastable()
			then
				--npcBot:ActionImmediate_Chat("Использую предмет overwhelmingBlink для нападения!",true);
				npcBot:Action_UseAbilityOnLocation(overwhelmingBlink, botTarget:GetLocation());
				return;
			end
			if swiftBlink ~= nil and swiftBlink:IsFullyCastable()
			then
				--npcBot:ActionImmediate_Chat("Использую предмет swiftBlink для нападения!",true);
				npcBot:Action_UseAbilityOnLocation(swiftBlink, botTarget:GetLocation());
				return;
			end
			if arcaneBlink ~= nil and arcaneBlink:IsFullyCastable()
			then
				--npcBot:ActionImmediate_Chat("Использую предмет arcaneBlink для нападения!",true);
				npcBot:Action_UseAbilityOnLocation(arcaneBlink, botTarget:GetLocation());
				return;
			end
		end
	end
	if utility.RetreatMode(npcBot) and npcBot:DistanceFromFountain() >= 1000
	then
		if blink ~= nil and blink:IsFullyCastable()
		then
			local itemRange = blink:GetCastRange();
			--npcBot:ActionImmediate_Chat("Использую предмет Blink для отступления!",true);
			npcBot:Action_UseAbilityOnLocation(blink, utility.GetEscapeLocation(npcBot, itemRange));
			return;
		end
		if overwhelmingBlink ~= nil and overwhelmingBlink:IsFullyCastable()
		then
			local itemRange = overwhelmingBlink:GetCastRange();
			--npcBot:ActionImmediate_Chat("Использую предмет overwhelmingBlink для отступления!",true);
			npcBot:Action_UseAbilityOnLocation(overwhelmingBlink, utility.GetEscapeLocation(npcBot, itemRange));
			return;
		end
		if swiftBlink ~= nil and swiftBlink:IsFullyCastable()
		then
			local itemRange = swiftBlink:GetCastRange();
			--npcBot:ActionImmediate_Chat("Использую предмет swiftBlink для отступления!",true);
			npcBot:Action_UseAbilityOnLocation(swiftBlink, utility.GetEscapeLocation(npcBot, itemRange));
			return;
		end
		if arcaneBlink ~= nil and arcaneBlink:IsFullyCastable()
		then
			local itemRange = arcaneBlink:GetCastRange();
			--npcBot:ActionImmediate_Chat("Использую предмет arcaneBlink для отступления!",true);
			npcBot:Action_UseAbilityOnLocation(arcaneBlink, utility.GetEscapeLocation(npcBot, itemRange));
			return;
		end
	end

	-- item_urn_of_shadows/item_spirit_vessel
	local urnOfShadows = IsItemAvailable('item_urn_of_shadows');
	local spiritVessel = IsItemAvailable('item_spirit_vessel');
	if urnOfShadows ~= nil and urnOfShadows:IsFullyCastable()
	then
		if urnOfShadows:GetCurrentCharges() > 0
		then
			local itemRange = urnOfShadows:GetCastRange();
			local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allyHeroes > 0)
			then
				for _, ally in pairs(allyHeroes)
				do
					if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and utility.CanBeHeal(ally) and (ally:TimeSinceDamagedByAnyHero() >= 5.0)
						and not ally:HasModifier("modifier_fountain_aura_buff") and not ally:HasModifier("modifier_item_urn_heal")
						and not ally:HasModifier("modifier_item_spirit_vessel_heal")
					then
						--npcBot:ActionImmediate_Chat("Использую urn Of Shadows на союзнике!", true);
						npcBot:Action_UseAbilityOnEntity(urnOfShadows, ally);
						return;
					end
				end
			end
			if utility.PvPMode(npcBot)
			then
				if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
					and not botTarget:HasModifier("modifier_item_urn_damage")
				then
					--npcBot:ActionImmediate_Chat("Использую urn Of Shadows на враге!", true);
					npcBot:Action_UseAbilityOnEntity(urnOfShadows, botTarget);
					return;
				end
			end
		end
	end
	if spiritVessel ~= nil and spiritVessel:IsFullyCastable()
	then
		if spiritVessel:GetCurrentCharges() > 0
		then
			local itemRange = spiritVessel:GetCastRange();
			local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allyHeroes > 0)
			then
				for _, ally in pairs(allyHeroes)
				do
					if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and utility.CanBeHeal(ally) and (ally:TimeSinceDamagedByAnyHero() >= 5.0)
						and not ally:HasModifier("modifier_fountain_aura_buff") and not ally:HasModifier("modifier_item_urn_heal")
						and not ally:HasModifier("modifier_item_spirit_vessel_heal")
					then
						--npcBot:ActionImmediate_Chat("Использую spiritVessel на союзнике!", true);
						npcBot:Action_UseAbilityOnEntity(spiritVessel, ally);
						return;
					end
				end
			end
			if utility.PvPMode(npcBot)
			then
				if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
					and not botTarget:HasModifier("modifier_item_spirit_vessel_damage")
				then
					--npcBot:ActionImmediate_Chat("Использую spiritVessel на враге!", true);
					npcBot:Action_UseAbilityOnEntity(spiritVessel, botTarget);
					return;
				end
			end
		end
	end

	-- item_cyclone/item_wind_waker
	local eulScepter = IsItemAvailable('item_cyclone');
	local windWaker = IsItemAvailable('item_wind_waker');
	if eulScepter ~= nil and eulScepter:IsFullyCastable()
	then
		local itemRange = eulScepter:GetCastRange();
		if (#incomingSpells > 0) and not utility.HaveReflectSpell(npcBot)
		then
			for _, spell in pairs(incomingSpells)
			do
				if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
				then
					--npcBot:ActionImmediate_Chat("Использую eulScepter что бы уклониться от снаряда!",true);
					npcBot:Action_UseAbilityOnEntity(eulScepter, npcBot);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 1)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if enemy ~= botTarget and utility.CanCastSpellOnTarget(eulScepter, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую eulScepter на не основную цель!",true);
						npcBot:Action_UseAbilityOnEntity(eulScepter, enemy);
						return;
					end
				end
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (healthPercent <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
			then
				--npcBot:ActionImmediate_Chat("Использую eulScepter для отступления!",true);
				npcBot:Action_UseAbilityOnEntity(eulScepter, npcBot);
				return;
			end
		end
	end
	if windWaker ~= nil and windWaker:IsFullyCastable()
	then
		local itemRange = windWaker:GetCastRange();
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if not utility.IsIllusion(ally)
				then
					local incomingSpells = ally:GetIncomingTrackingProjectiles();
					if (#incomingSpells > 0) and not utility.HaveReflectSpell(ally)
					then
						for _, spell in pairs(incomingSpells)
						do
							if (not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false)
							then
								--npcBot:ActionImmediate_Chat("Использую предмет windWaker на союзнике!",true);
								npcBot:Action_UseAbilityOnEntity(windWaker, ally);
								return;
							end
						end
					end
					if (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(1.0)
					then
						npcBot:Action_UseAbilityOnEntity(windWaker, ally);
						return;
					end
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 1)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if enemy ~= botTarget and utility.CanCastSpellOnTarget(windWaker, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую windWaker на не основную цель!",true);
						npcBot:Action_UseAbilityOnEntity(windWaker, enemy);
						return;
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
	if dagon1 ~= nil and dagon1:IsFullyCastable()
	then
		local itemRange = dagon1:GetCastRange();
		local itemDamage = dagon1:GetSpecialValueInt("damage");
		--npcBot:ActionImmediate_Chat("Радиус/Урон" .. itemRange .. " / " .. itemDamage, true);
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanAbilityKillTarget(enemy, itemDamage, dagon1:GetDamageType()) and utility.CanCastSpellOnTarget(dagon1, enemy)
				then
					npcBot:Action_UseAbilityOnEntity(dagon1, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(dagon1, botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую " .. dagon1:GetName(), true);
				npcBot:Action_UseAbilityOnEntity(dagon1, botTarget);
				return;
			end
		end
	end
	if dagon2 ~= nil and dagon2:IsFullyCastable()
	then
		local itemRange = dagon2:GetCastRange();
		local itemDamage = dagon2:GetSpecialValueInt("damage");
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanAbilityKillTarget(enemy, itemDamage, dagon2:GetDamageType()) and utility.CanCastSpellOnTarget(dagon2, enemy)
				then
					npcBot:Action_UseAbilityOnEntity(dagon2, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(dagon2, botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую " .. dagon2:GetName(), true);
				npcBot:Action_UseAbilityOnEntity(dagon2, botTarget);
				return;
			end
		end
	end
	if dagon3 ~= nil and dagon3:IsFullyCastable()
	then
		local itemRange = dagon3:GetCastRange();
		local itemDamage = dagon3:GetSpecialValueInt("damage");
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanAbilityKillTarget(enemy, itemDamage, dagon3:GetDamageType()) and utility.CanCastSpellOnTarget(dagon3, enemy)
				then
					npcBot:Action_UseAbilityOnEntity(dagon3, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(dagon3, botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую " .. dagon3:GetName(), true);
				npcBot:Action_UseAbilityOnEntity(dagon3, botTarget);
				return;
			end
		end
	end
	if dagon4 ~= nil and dagon4:IsFullyCastable()
	then
		local itemRange = dagon4:GetCastRange();
		local itemDamage = dagon4:GetSpecialValueInt("damage");
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanAbilityKillTarget(enemy, itemDamage, dagon4:GetDamageType()) and utility.CanCastSpellOnTarget(dagon4, enemy)
				then
					npcBot:Action_UseAbilityOnEntity(dagon4, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(dagon4, botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую " .. dagon4:GetName(), true);
				npcBot:Action_UseAbilityOnEntity(dagon4, botTarget);
				return;
			end
		end
	end
	if dagon5 ~= nil and dagon5:IsFullyCastable()
	then
		local itemRange = dagon5:GetCastRange();
		local itemDamage = dagon5:GetSpecialValueInt("damage");
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanAbilityKillTarget(enemy, itemDamage, dagon5:GetDamageType()) and utility.CanCastSpellOnTarget(dagon5, enemy)
				then
					npcBot:Action_UseAbilityOnEntity(dagon5, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(dagon5, botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую " .. dagon5:GetName(), true);
				npcBot:Action_UseAbilityOnEntity(dagon5, botTarget);
				return;
			end
		end
	end

	-- item_rod_of_atos/item_gungir
	local rodOfAtos = IsItemAvailable('item_rod_of_atos');
	local gleipnir = IsItemAvailable('item_gungir');
	if rodOfAtos ~= nil and rodOfAtos:IsFullyCastable()
	then
		local itemRange = rodOfAtos:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(rodOfAtos, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую rodOfAtos по врагу!", true);
				npcBot:Action_UseAbilityOnEntity(rodOfAtos, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.CanCastSpellOnTarget(rodOfAtos, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет rodOfAtos для оступления!",true);
						npcBot:Action_UseAbilityOnEntity(rodOfAtos, enemy);
						return;
					end
				end
			end
		end
	end
	if gleipnir ~= nil and gleipnir:IsFullyCastable()
	then
		local itemRange = gleipnir:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(gleipnir, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую gleipnir по врагу!", true);
				npcBot:Action_UseAbilityOnLocation(gleipnir, botTarget:GetLocation());
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.CanCastSpellOnTarget(gleipnir, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет gleipnir для оступления!",true);
						npcBot:Action_UseAbilityOnLocation(gleipnir, enemy:GetLocation());
						return;
					end
				end
			end
		end
	end

	-- item_moon_shard
	local moonShard = IsItemAvailable("item_moon_shard");
	if moonShard ~= nil and moonShard:IsFullyCastable()
	then
		if not npcBot:HasModifier("modifier_item_moon_shard_consumed")
		then
			npcBot:Action_UseAbilityOnEntity(moonShard, npcBot);
			return;
		else
			local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
			if (#allyHeroes > 1)
			then
				for _, ally in pairs(allyHeroes)
				do
					if ally ~= npcBot and utility.IsHero(ally) and not ally:HasModifier("modifier_item_moon_shard_consumed")
					then
						--npcBot:ActionImmediate_Chat("Использую предмет moonShard на союзника!",true);
						npcBot:Action_UseAbilityOnEntity(moonShard, ally);
						return;
					end
				end
			end
		end
	end

	-- 	item_ghost/item_ethereal_blade
	local ghost = IsItemAvailable("item_ghost");
	local etherealBlade = IsItemAvailable("item_ethereal_blade");
	if ghost ~= nil and ghost:IsFullyCastable()
	then
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if enemy:GetAttackTarget() == npcBot and (healthPercent <= 0.8)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет ghost!", true);
						npcBot:Action_UseAbility(ghost);
						return;
					end
				end
			end
		end
	end
	if etherealBlade ~= nil and etherealBlade:IsFullyCastable()
	then
		local itemRange = etherealBlade:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and not botTarget:IsAttackImmune() and (npcBot:GetMana() / npcBot:GetMaxMana() >= 0.2)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет etherealBlade для нападения",true);
				npcBot:Action_UseAbilityOnEntity(etherealBlade, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if not enemy:IsAttackImmune()
					then
						--npcBot:ActionImmediate_Chat("Использую предмет etherealBlade для оступления!",true);
						npcBot:Action_UseAbilityOnEntity(etherealBlade, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_invis_sword/item_silver_edge
	local shadowBlade = IsItemAvailable("item_invis_sword");
	local silverEdge = IsItemAvailable("item_silver_edge");
	if shadowBlade ~= nil and shadowBlade:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			if (#incomingSpells > 0)
			then
				for _, spell in pairs(incomingSpells)
				do
					if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
						and not utility.HaveReflectSpell(npcBot)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет shadowBlade для блока заклинания!",true);
						npcBot:Action_UseAbility(shadowBlade);
						return;
					end
				end
			end
			if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
			then
				if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 4)
				then
					npcBot:Action_UseAbility(shadowBlade);
					return;
				end
			end
			if utility.RetreatMode(npcBot)
			then
				if (healthPercent <= 0.8)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет shadowBlade для отступления!",true);
					npcBot:Action_UseAbility(shadowBlade);
					return;
				end
			end
		end
	end
	if silverEdge ~= nil and silverEdge:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			if (#incomingSpells > 0)
			then
				for _, spell in pairs(incomingSpells)
				do
					if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
						and not utility.HaveReflectSpell(npcBot)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет shadowBlade для блока заклинания!",true);
						npcBot:Action_UseAbility(silverEdge);
						return;
					end
				end
			end
			if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
			then
				if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 4)
				then
					npcBot:Action_UseAbility(silverEdge);
					return;
				end
			end
			if utility.RetreatMode(npcBot)
			then
				if (healthPercent <= 0.8)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет silverEdge для отступления!",true);
					npcBot:Action_UseAbility(silverEdge);
					return;
				end
			end
		end
	end


	-- item_diffusal_blade/item_disperser
	local diffusalBlade = IsItemAvailable("item_diffusal_blade");
	local disperser = IsItemAvailable("item_disperser");
	if diffusalBlade ~= nil and diffusalBlade:IsFullyCastable()
	then
		local itemRange = diffusalBlade:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет diffusal_blade на враге!", true);
				npcBot:Action_UseAbilityOnEntity(diffusalBlade, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет diffusal_blade для отхода!",true);
						npcBot:Action_UseAbilityOnEntity(diffusalBlade, enemy);
						return;
					end
				end
			end
		end
	end
	if disperser ~= nil and disperser:IsFullyCastable()
	then
		local itemRange = disperser:GetCastRange();
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет disperser на враге!", true);
				npcBot:Action_UseAbilityOnEntity(disperser, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет disperser для отхода!",true);
						npcBot:Action_UseAbilityOnEntity(disperser, enemy);
						return;
					end
				end
			end
		end
		local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
		if (#allyHeroes > 0)
		then
			for _, ally in pairs(allyHeroes)
			do
				if utility.IsHero(botTarget)
				then
					if GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() * 2 or
						GetUnitToUnitDistance(ally, botTarget) > (ally:GetAttackRange() * 2)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет disperser на союзника для атаки!", true);
						npcBot:Action_UseAbilityOnEntity(disperser, ally);
						return;
					end
				end
				if utility.IsDisabled(ally) or ally:WasRecentlyDamagedByAnyHero(1.0)
				then
					--npcBot:ActionImmediate_Chat("Использую предмет disperser на союзнике!",true);
					npcBot:Action_UseAbilityOnEntity(disperser, ally);
					return;
				end
			end
		end
	end

	-- item_harpoon
	local harpoon = IsItemAvailable("item_harpoon");
	if harpoon ~= nil and harpoon:IsFullyCastable()
	then
		local itemRange = harpoon:GetCastRange();
		if utility.PvPMode(npcBot) and utility.CanMove(npcBot)
		then
			if utility.IsHero(botTarget) and (GetUnitToUnitDistance(npcBot, botTarget) <= itemRange and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
			then
				--npcBot:ActionImmediate_Chat("Использую предмет harpoon на враге!", true);
				npcBot:Action_UseAbilityOnEntity(harpoon, botTarget);
				return;
			end
		end
	end

	-- item_hand_of_midas
	local handOfMidas = IsItemAvailable("item_hand_of_midas");
	if handOfMidas ~= nil and handOfMidas:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			local itemRange = handOfMidas:GetCastRange();
			local enemy = utility.GetStrongestCreep(npcBot, itemRange);
			if utility.CanCastSpellOnTarget(handOfMidas, enemy) and not enemy:IsAncientCreep() and (enemy:GetLevel() > 1)
				and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.8)
			then
				--npcBot:ActionImmediate_Chat("Использую handOfMidas!", true);
				npcBot:Action_UseAbilityOnEntity(handOfMidas, enemy);
				return;
			end
		end
	end

	-- item_sheepstick
	local scytheOfVyse = IsItemAvailable("item_sheepstick");
	if scytheOfVyse ~= nil and scytheOfVyse:IsFullyCastable()
	then
		local itemRange = scytheOfVyse:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanCastSpellOnTarget(scytheOfVyse, enemy) and enemy:IsChanneling()
				then
					npcBot:Action_UseAbilityOnEntity(scytheOfVyse, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(scytheOfVyse, botTarget) and not utility.IsDisabled(botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет scytheOfVyse на враге!", true);
				npcBot:Action_UseAbilityOnEntity(scytheOfVyse, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.CanCastSpellOnTarget(scytheOfVyse, enemy) and not utility.IsDisabled(enemy)
					then
						--npcBot:ActionImmediate_Chat("Использую предмет scytheOfVyse для оступления!",true);
						npcBot:Action_UseAbilityOnEntity(scytheOfVyse, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_mask_of_madness
	local maskOfMadness = IsItemAvailable("item_mask_of_madness");
	if maskOfMadness ~= nil and maskOfMadness:IsFullyCastable()
	then
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
			then
				if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange + 200
					and not npcBot:IsDisarmed()
				then
					--npcBot:ActionImmediate_Chat("Использую предмет maskOfMadness для нападения!",true);
					npcBot:Action_UseAbility(maskOfMadness);
					return;
				end
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (healthPercent <= 0.5) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > 1000
			then
				--npcBot:ActionImmediate_Chat("Использую предмет maskOfMadness для отхода!", true);
				npcBot:Action_UseAbility(maskOfMadness);
				return;
			end
		end
	end

	-- item_helm_of_the_dominator/item_helm_of_the_overlord
	local helmOfTheDominator = IsItemAvailable("item_helm_of_the_dominator");
	local helmOfTheOverlord = IsItemAvailable("item_helm_of_the_overlord");
	if helmOfTheDominator ~= nil and helmOfTheDominator:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			local itemRange = helmOfTheDominator:GetCastRange();
			local enemyCreeps = npcBot:GetNearbyCreeps(itemRange, true);
			if (#enemyCreeps > 0)
			then
				for _, enemy in pairs(enemyCreeps) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetLevel() >= 3) and not enemy:IsAncientCreep()
					then
						npcBot:Action_UseAbilityOnEntity(helmOfTheDominator, enemy);
						return;
					end
				end
			end
		end
	end
	if helmOfTheOverlord ~= nil and helmOfTheOverlord:IsFullyCastable()
	then
		if not npcBot:IsInvisible()
		then
			local itemRange = helmOfTheOverlord:GetCastRange();
			local enemyCreeps = npcBot:GetNearbyCreeps(itemRange, true);
			if (#enemyCreeps > 0)
			then
				for _, enemy in pairs(enemyCreeps) do
					if utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetLevel() >= 3)
					then
						npcBot:Action_UseAbilityOnEntity(helmOfTheOverlord, enemy);
						return;
					end
				end
			end
		end
	end

	--#Region Основной алгоритм
	local refresher = IsItemAvailable("item_refresher");                                                               -- Получение item_refresher
	local refresherShard = IsItemAvailable("item_refresher_shard");                                                    -- Получение item_refresher_shard
	if (refresher ~= nil and refresher:IsFullyCastable()) or (refresherShard ~= nil and refresherShard:IsFullyCastable()) -- Проверка доступности item_refresher/shard
	then
		if utility.CanCast(npcBot)
		then
			--local _messageRefresherUsage = "Использую refresher!"; -- Сообщение при использовании item_refresher
			local _countMaxOfSlots = 26;                           -- Максимальное количество слотов
			local _countBonusManaValue = 350;                      -- Запас маны для каста
			local _kCD = 0.5;                                      -- Коэффициент величины отката способности

			for i = 0, _countMaxOfSlots, 1 do                      -- Итерация по всем слотам
				local ability = npcBot:GetAbilityInSlot(i)         -- Получение способности
				if ability ~= nil
					and not ability:IsTalent()                     -- Не является талантом
					and not ability:IsPassive()                    -- Не пассивная
					and not ability:IsHidden()                     -- Не скрытая
				then
					local abilityManaCost = ability:GetManaCost(); -- Получение величины стоимости способности
					if npcBot:GetMana() >= abilityManaCost + _countBonusManaValue -- Проверка маны
					then
						if Contains(_tableOfUltimatesAbility, ability:GetName()) --Проеверка содержания иназвания в способности в вышеопределенном списке
						then
							local abilityCD = ability:GetCooldown(); -- Получение величины времени отката способности
							if ability:GetCooldownTimeRemaining() >= abilityCD * _kCD -- Проверка отката
							then
								if refresher ~= nil
								then
									--npcBot:ActionImmediate_Chat(_messageRefresherUsage, true); -- Оставление отладочного сообщения в часте
									npcBot:Action_UseAbility(refresher); -- Использование refresher_item
									return;
								elseif refresherShard ~= nil
								then
									--npcBot:Action_ClearActions(false);
									--npcBot:ActionImmediate_Chat("Использую рефрешер шард", true); -- Оставление отладочного сообщения в часте
									npcBot:Action_UseAbility(refresherShard); -- Использование refresher_shard_item
									return;
								end
							end
						elseif ability:GetCooldownTimeRemaining() >= 50
						then
							if refresher ~= nil
							then
								--npcBot:Action_ClearActions(false);
								--npcBot:ActionImmediate_Chat(_messageRefresherUsage, true); -- Оставление отладочного сообщения в часте
								npcBot:Action_UseAbility(refresher); -- Использование refresher_item
								return;
							elseif refresherShard ~= nil
							then
								--npcBot:Action_ClearActions(false);
								--npcBot:ActionImmediate_Chat("Использую рефрешер шард", true); -- Оставление отладочного сообщения в часте
								npcBot:Action_UseAbility(refresherShard); -- Использование refresher_shard_item
								return;
							end
						end
					end
				end
			end
		end
	end
	--#endregion Основной алгоритм

	-- item_meteor_hammer
	local meteorHammer = IsItemAvailable("item_meteor_hammer");
	if meteorHammer ~= nil and meteorHammer:IsFullyCastable()
	then
		local itemRange = meteorHammer:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		-- Cast if can interrupt cast
		if (#enemyHeroes > 0) and not utility.RetreatMode(npcBot)
		then
			for _, enemy in pairs(enemyHeroes) do
				if enemy:IsChanneling()
				then
					--npcBot:ActionImmediate_Chat("Использую предмет meteorHammer что бы сбить каст!",true);
					npcBot:Action_UseAbilityOnLocation(meteorHammer, enemy:GetLocation());
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				--npcBot:ActionImmediate_Chat("Использую предмет meteorHammer на враге!", true);
				npcBot:Action_UseAbilityOnLocation(meteorHammer, botTarget:GetLocation());
				return;
			end
		end
		if utility.PvEMode(npcBot)
		then
			local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), itemRange, 400, 0, 0);
			if locationAoE ~= nil and (locationAoE.count >= 3)
			then
				--npcBot:ActionImmediate_Chat("Использую предмет meteorHammer на крипов!", true);
				npcBot:Action_UseAbilityOnLocation(meteorHammer, locationAoE.targetloc);
				return;
			end
		end
		-- Cast if attack buildings
		local attackTarget = npcBot:GetAttackTarget();
		if utility.IsBuilding(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
		then
			--npcBot:ActionImmediate_Chat("Использую предмет meteorHammer на ЗДАНИЕ!", true);
			npcBot:Action_UseAbilityOnLocation(meteorHammer, attackTarget:GetLocation());
			return;
		end
	end

	-- item_bottle
	local bottle = IsItemAvailable("item_bottle");
	if bottle ~= nil and bottle:IsFullyCastable()
	then
		local itemCharges = bottle:GetCurrentCharges();
		if (itemCharges > 0) and (npcBot:TimeSinceDamagedByAnyHero() >= 5.0 and npcBot:TimeSinceDamagedByCreep() >= 5.0)
		then
			if healthPercent <= 0.6 and utility.CanBeHeal(npcBot) and not HaveHealthRegenBuff(npcBot)
			then
				npcBot:Action_UseAbility(bottle);
				return;
			end
			if npcBot:GetMana() / npcBot:GetMaxMana() <= 0.4 and not HaveManaRegenBuff(npcBot)
			then
				npcBot:Action_UseAbility(bottle);
				return;
			end
			if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE or botMode == BOT_MODE_RUNE
			then
				if npcBot:GetHealth() < npcBot:GetMaxHealth() and utility.CanBeHeal(npcBot) and not HaveHealthRegenBuff(npcBot)
				then
					npcBot:Action_UseAbility(bottle);
					return;
				end
				if npcBot:GetMana() < npcBot:GetMaxMana() and not HaveManaRegenBuff(npcBot)
				then
					npcBot:Action_UseAbility(bottle);
					return;
				end
			end
			if (npcBot:HasModifier('modifier_fountain_aura_buff') and not npcBot:HasModifier('modifier_bottle_regeneration')) and
				(npcBot:GetHealth() < npcBot:GetMaxHealth() or npcBot:GetMana() < npcBot:GetMaxMana())
			then
				npcBot:Action_UseAbility(bottle);
				return;
			end
		end
	end

	-- item_armlet
	local armlet = IsItemAvailable("item_armlet");
	if armlet ~= nil and armlet:IsFullyCastable()
	then
		if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
		then
			if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and npcBot:GetAttackTarget() == botTarget
			then
				if armlet:GetToggleState() == false
				then
					--npcBot:Action_ClearActions(false);
					npcBot:Action_UseAbility(armlet);
					return;
				end
			else
				if armlet:GetToggleState() == true
				then
					--npcBot:Action_ClearActions(false);
					npcBot:Action_UseAbility(armlet);
					return;
				end
			end
		else
			if armlet:GetToggleState() == true
			then
				--npcBot:Action_ClearActions(false);
				npcBot:Action_UseAbility(armlet);
				return;
			end
		end
	end

	-- item_nullifier
	local nullifier = IsItemAvailable("item_nullifier");
	if nullifier ~= nil and nullifier:IsFullyCastable()
	then
		local itemRange = nullifier:GetCastRange();
		local enemyHeroes = npcBot:GetNearbyHeroes(itemRange, true, BOT_MODE_NONE);
		if (#enemyHeroes > 0)
		then
			for _, enemy in pairs(enemyHeroes) do
				if utility.CanCastSpellOnTarget(nullifier, enemy) and (enemy:IsAttackImmune() or utility.TargetCantDie(enemy))
				then
					npcBot:Action_UseAbilityOnEntity(nullifier, enemy);
					return;
				end
			end
		end
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(nullifier, botTarget) and not utility.IsDisabled(botTarget)
				and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange
			then
				npcBot:Action_UseAbilityOnEntity(nullifier, botTarget);
				return;
			end
		end
		if utility.RetreatMode(npcBot)
		then
			if (#enemyHeroes > 0)
			then
				for _, enemy in pairs(enemyHeroes)
				do
					if utility.CanCastSpellOnTarget(nullifier, enemy) and not utility.IsDisabled(enemy)
					then
						npcBot:Action_UseAbilityOnEntity(nullifier, enemy);
						return;
					end
				end
			end
		end
	end

	-- item_revenants_brooch (Passive)
	--[[ 	local revenantsBrooch = IsItemAvailable("item_revenants_brooch");
	if revenantsBrooch ~= nil and revenantsBrooch:IsFullyCastable()
	then
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
				and not npcBot:HasModifier("modifier_item_revenants_brooch_counter")
			then
				if botTarget:IsAttackImmune() or utility.CanCastOnMagicImmuneTarget(botTarget)
				then
					--npcBot:Action_ClearActions(false);
					npcBot:Action_UseAbility(revenantsBrooch);
				end
			end
		end
	end ]]

	--[[ 	-- item_tome_of_knowledge (DELETE)
	local tomeOfKnowledge = IsItemAvailable("item_tome_of_knowledge");
	if tomeOfKnowledge ~= nil and tomeOfKnowledge:IsFullyCastable() then
		npcBot:Action_UseAbility(tomeOfKnowledge);
		--npcBot:ActionImmediate_Chat("Использую предмет Tome Of Knowledge!",true);
		return;
	end ]]


	------------NEUTRAL ITEMS
	--[[ 	-- item_grisgris
	local grisgris = IsNeutralItemAvailable("item_grisgris");
	if grisgris ~= nil
	then
		if utility.GetModifierCount(npcBot, "modifier_item_grisgris_counter") >= (npcBot:GetGold() * 2)
		then
			npcBot:ActionImmediate_Chat("Использую предмет " .. grisgris:GetName(), true);
			npcBot:ActionPush_UseAbility(grisgris);
		end
	end

	-- item_black_grimoire
	local blackGrimoire = IsNeutralItemAvailable("item_black_grimoire");
	if blackGrimoire ~= nil
	then
		if blackGrimoire:GetCurrentCharges() >= 10
		then
			npcBot:ActionImmediate_Chat("Использую предмет " .. blackGrimoire:GetName(), true);
			npcBot:Action_UseAbility(blackGrimoire);
		end
	end ]]






	------------
end

--#endregion

for k, v in pairs(ability_item_usage_generic) do _G._savedEnv[k] = v end


-- 7.35 - СТАРАЯ ВЕРСИЯ - медаль удалили, соларкрест изменён
--[[ 	-- item_medallion_of_courage/item_solar_crest
	local medallionOfCourage = IsItemAvailable("item_medallion_of_courage");
	local solarCrest = IsItemAvailable("item_solar_crest");
	if (medallionOfCourage ~= nil and medallionOfCourage:IsFullyCastable()) or (solarCrest ~= nil and solarCrest:IsFullyCastable())
	then
		local itemRange = 1000;
		if utility.PvPMode(npcBot)
		then
			if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= itemRange and utility.CanCastOnMagicImmuneTarget(botTarget)
			then
				if medallionOfCourage ~= nil and not botTarget:HasModifier("modifier_item_medallion_of_courage_armor_reduction")
				then
					npcBot:Action_UseAbilityOnEntity(medallionOfCourage, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет medallion of courage на враге!",true);
					--return;
				elseif solarCrest ~= nil and not botTarget:HasModifier("modifier_item_solar_crest_armor_reduction") and utility.SafeCast(botTarget)
				then
					npcBot:Action_UseAbilityOnEntity(solarCrest, botTarget);
					--npcBot:ActionImmediate_Chat("Использую предмет solar Crest на враге!", true);
					--return;
				end
			end
		elseif not utility.RetreatMode(npcBot)
		then
			local allyHeroes = npcBot:GetNearbyHeroes(itemRange, false, BOT_MODE_NONE);
			if (#allyHeroes > 1)
			then
				for _, ally in pairs(allyHeroes)
				do
					if ally ~= npcBot and utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and ally:WasRecentlyDamagedByAnyHero(2.0)
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
	end ]]


--[[ 		-- item_veil_of_discord
		local discord = IsItemAvailable("item_veil_of_discord");
		if discord ~= nil and discord:IsFullyCastable()
		then
			if utility.PvPMode(npcBot)
			then
				if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1200
					and not botTarget:HasModifier("modifier_item_veil_of_discord_debuff")
				then
					npcBot:Action_UseAbilityOnLocation(discord, botTarget:GetLocation());
					--npcBot:ActionImmediate_Chat("Использую предмет discord на враге!", true);
					--return;
				end
			end
		end ]]
