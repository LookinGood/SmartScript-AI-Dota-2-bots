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
local ThunderClap = AbilitiesReal[1]
local CinderBrew = AbilitiesReal[2]
local DrunkenBrawler = AbilitiesReal[3]
local PrimalCompanion = AbilitiesReal[4]
local PrimalSplit = AbilitiesReal[6]

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
    local castPrimalCompanionDesire = ConsiderPrimalCompanion();
    local castPrimalSplitDesire = ConsiderPrimalSplit();

    if (castThunderClapDesire ~= nil)
    then
        npcBot:Action_UseAbility(ThunderClap);
        return;
    end

    if (castCinderBrewDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(CinderBrew, castCinderBrewLocation);
        return;
    end

    if (castDrunkenBrawlerDesire ~= nil)
    then
        npcBot:Action_UseAbility(DrunkenBrawler);
        return;
    end

    if (castPrimalCompanionDesire ~= nil)
    then
        npcBot:Action_UseAbility(PrimalCompanion);
        return;
    end

    if (castPrimalSplitDesire ~= nil)
    then
        npcBot:Action_UseAbility(PrimalSplit);
        return;
    end
end

function ConsiderThunderClap()
    local ability = ThunderClap;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
    elseif utility.PvEMode(npcBot)
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
end

function ConsiderCinderBrew()
    local ability = CinderBrew;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
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
end

function ConsiderDrunkenBrawler()
    local ability = DrunkenBrawler;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Нет возможности отследить какая стойка активна
    if npcBot:IsAlive()
    then
        return;
    end
end

function ConsiderPrimalCompanion()
    local ability = PrimalCompanion;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.IsAbilityAvailable(PrimalSplit) and (HealthPercentage < 0.3)
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.4)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderPrimalSplit()
    local ability = PrimalSplit;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_brewmaster_primal_split_duration") or (HealthPercentage >= 0.3)
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
