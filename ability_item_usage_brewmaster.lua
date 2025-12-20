---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")

function CourierUsageThink()
    ability_item_usage_generic.CourierUsageThink()
end

function BuybackUsageThink()
    ability_item_usage_generic.BuybackUsageThink();
end

-- Ability learn
local npcBot = GetBot();
local Abilities, Talents, AbilitiesReal = ability_levelup_generic.GetHeroAbilities(npcBot)

local AbilityToLevelUp =
{
    Abilities[1],
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ThunderClap = npcBot:GetAbilityByName("brewmaster_thunder_clap");
local CinderBrew = npcBot:GetAbilityByName("brewmaster_cinder_brew");
local DrunkenBrawler = npcBot:GetAbilityByName("brewmaster_drunken_brawler");
local LiquidCourage = npcBot:GetAbilityByName("brewmaster_liquid_courage");
local PrimalCompanion = npcBot:GetAbilityByName("brewmaster_primal_companion");
local PrimalSplit = npcBot:GetAbilityByName("brewmaster_primal_split");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castThunderClapDesire = ConsiderThunderClap();
    local castCinderBrewDesire, castCinderBrewLocation = ConsiderCinderBrew();
    local castDrunkenBrawlerDesire = ConsiderDrunkenBrawler();
    local castLiquidCourageDesire, castLiquidCourageTarget = ConsiderLiquidCourage();
    local castPrimalCompanionDesire = ConsiderPrimalCompanion();
    local castPrimalSplitDesire = ConsiderPrimalSplit();

    if (castThunderClapDesire > 0)
    then
        npcBot:Action_UseAbility(ThunderClap);
        return;
    end

    if (castCinderBrewDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(CinderBrew, castCinderBrewLocation);
        return;
    end

    if (castDrunkenBrawlerDesire > 0)
    then
        npcBot:Action_UseAbility(DrunkenBrawler);
        return;
    end

    if (castLiquidCourageDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(LiquidCourage, castLiquidCourageTarget);
        return;
    end

    if (castPrimalCompanionDesire > 0)
    then
        npcBot:Action_UseAbility(PrimalCompanion);
        return;
    end

    if (castPrimalSplitDesire > 0)
    then
        npcBot:Action_UseAbility(PrimalSplit);
        return;
    end
end

function ConsiderThunderClap()
    local ability = ThunderClap;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_LOW;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderCinderBrew()
    local ability = CinderBrew;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDrunkenBrawler()
    local ability = DrunkenBrawler;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Нет возможности отследить какая стойка активна
    if npcBot:IsAlive()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderLiquidCourage()
    local ability = LiquidCourage;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.6 and not ally:HasModifier("modifier_brewmaster_liquid_courage_passive")
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(5.0) or
                    ally:WasRecentlyDamagedByTower(2.0) or
                    utility.IsHero(ally:GetAttackTarget())
                then
                    --npcBot:ActionImmediate_Chat("Использую LiquidCourage на раненого союзника: " .. ally:GetUnitName(), true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPrimalCompanion()
    local ability = PrimalCompanion;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if utility.IsAbilityAvailable(PrimalSplit) and (HealthPercentage < 0.3)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Cast if push/defend/farm/roshan
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.4)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPrimalSplit()
    local ability = PrimalSplit;
    if not utility.IsAbilityAvailable(ability)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_brewmaster_primal_split_duration") or (HealthPercentage >= 0.3)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
