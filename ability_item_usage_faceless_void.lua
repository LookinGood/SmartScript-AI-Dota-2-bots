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
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local TimeWalk = AbilitiesReal[1]
local TimeDilation = AbilitiesReal[2]
local TimeLock = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castTimeWalkDesire, castTimeWalkLocation = ConsiderTimeWalk();
    local castTimeDilationDesire = ConsiderTimeDilation();
    local castTimeLockDesire, castTimeLockLocation = ConsiderTimeLock();

    if (castTimeWalkDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(TimeWalk, castTimeWalkLocation);
        return;
    end

    if (castTimeDilationDesire > 0)
    then
        npcBot:Action_UseAbility(TimeDilation);
        return;
    end

    if (castTimeLockDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(TimeLock, castTimeLockLocation);
        return;
    end
end

function ConsiderTimeWalk()
    local ability = TimeWalk;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
        then
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTimeDilation()
    local ability = TimeDilation;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    and not enemy:HasModifier("modifier_faceless_void_time_dilation_slow")
                then
                    --npcBot:ActionImmediate_Chat("Использую TimeDilation против врага в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderTimeLock()
    local ability = TimeLock;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and not utility.IsDisabled(botTarget)
        then
            if ability:GetName() == "faceless_void_chronosphere"
            then
                local allyHeroes = botTarget:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#allyHeroes == 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую TimeLock по цели рядом с которой нет союзников!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif (#allyHeroes == 1)
                then
                    for _, ally in pairs(allyHeroes) do
                        if ally == npcBot
                        then
                            --npcBot:ActionImmediate_Chat("Использую TimeLock по цели рядом с которой только я!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH,
                                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                        end
                    end
                end
            elseif ability:GetName() == "faceless_void_time_zone"
            then
                --npcBot:ActionImmediate_Chat("Использую Time Zone по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if not utility.IsDisabled(enemy)
                    then
                        if ability:GetName() == "faceless_void_chronosphere"
                        then
                            local allyHeroes = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                            if (#allyHeroes == 0)
                            then
                                --npcBot:ActionImmediate_Chat("Использую TimeLock отступая по одному врагу!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH,
                                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                            elseif (#allyHeroes == 1)
                            then
                                for _, ally in pairs(allyHeroes) do
                                    if ally == npcBot
                                    then
                                        --npcBot:ActionImmediate_Chat("Использую TimeLock отступая по врагу рядом с которым только я!", true);
                                        return BOT_ACTION_DESIRE_VERYHIGH,
                                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                                    end
                                end
                            end
                        elseif ability:GetName() == "faceless_void_time_zone"
                        then
                            --npcBot:ActionImmediate_Chat("Использую Time Zone для отступления!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
