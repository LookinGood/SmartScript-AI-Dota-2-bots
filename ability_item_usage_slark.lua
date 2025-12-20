---@diagnostic disable: undefined-global, redefined-local
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
    Abilities[2],
    Abilities[1],
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
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local DarkPact = npcBot:GetAbilityByName("slark_dark_pact");
local Pounce = npcBot:GetAbilityByName("slark_pounce");
local SaltwaterShiv = npcBot:GetAbilityByName("slark_saltwater_shiv");
local DepthShroud = npcBot:GetAbilityByName("slark_depth_shroud");
local ShadowDance = npcBot:GetAbilityByName("slark_shadow_dance");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDarkPactDesire = ConsiderDarkPact();
    ConsiderSaltwaterShiv();
    local castPounceDesire = ConsiderPounce();
    local castDepthShroudDesire, castDepthShroudLocation = ConsiderDepthShroud();
    local castShadowDanceDesire = ConsiderShadowDance();

    if (castDarkPactDesire > 0)
    then
        npcBot:Action_UseAbility(DarkPact);
        return;
    end

    if (castPounceDesire > 0)
    then
        npcBot:Action_UseAbility(Pounce);
        return;
    end

    if (castDepthShroudDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(DepthShroud, castDepthShroudLocation);
        return;
    end

    if (castShadowDanceDesire > 0)
    then
        npcBot:Action_UseAbility(ShadowDance);
        return;
    end
end

function ConsiderDarkPact()
    local ability = DarkPact;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local selfDamageAbility = ability:GetSpecialValueInt("total_damage") * ability:GetSpecialValueInt("self_damage_pct") /
        100;

    if utility.CanAbilityKillTarget(npcBot, selfDamageAbility, ability:GetDamageType())
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую DarkPact для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую DarkPact для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую DarkPact против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPounce()
    local ability = Pounce;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local castRangeAbility = ability:GetSpecialValueInt("pounce_distance");
    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and not utility.IsDisabled(botTarget)
            and (GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
            and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую Pounce по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую Pounce для отхода!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSaltwaterShiv()
    local ability = SaltwaterShiv;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if utility.CanCastSpellOnTarget(ability, attackTarget) and utility.IsHero(attackTarget)
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end
end

function ConsiderDepthShroud()
    local ability = DepthShroud;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.5)
                and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
                and not ally:HasModifier("modifier_slark_depth_shroud") and not ally:HasModifier("modifier_slark_shadow_dance")
            then
                --npcBot:ActionImmediate_Chat("Использую DepthShroud на союзного героя!", true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally:GetLocation();
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShadowDance()
    local ability = ShadowDance;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_slark_depth_shroud") or npcBot:HasModifier("modifier_slark_shadow_dance")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowDance для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowDance для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
