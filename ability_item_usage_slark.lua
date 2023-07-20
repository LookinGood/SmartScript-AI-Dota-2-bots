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
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    DarkPact = AbilitiesReal[1]
    Pounce = AbilitiesReal[2]
    DepthShroud = AbilitiesReal[4]
    ShadowDance = AbilitiesReal[6]

    castDarkPactDesire = ConsiderDarkPact();
    castPounceDesire = ConsiderPounce();
    castDepthShroudDesire, castDepthShroudLocation = ConsiderDepthShroud();
    castShadowDanceDesire = ConsiderShadowDance();

    if (castDarkPactDesire ~= nil)
    then
        npcBot:Action_UseAbility(DarkPact);
        return;
    end

    if (castPounceDesire ~= nil)
    then
        npcBot:Action_UseAbility(Pounce);
        return;
    end

    if (castDepthShroudDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DepthShroud, castDepthShroudLocation);
        return;
    end

    if (castShadowDanceDesire ~= nil)
    then
        npcBot:Action_UseAbility(ShadowDance);
        return;
    end
end

function ConsiderDarkPact()
    local ability = DarkPact;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local selfDamageAbility = ability:GetSpecialValueInt("total_damage") * ability:GetSpecialValueInt("self_damage_pct") / 100;

    -- Attack use
    if not utility.CanAbilityKillTarget(npcBot, selfDamageAbility, ability:GetDamageType())
    then
        if utility.PvPMode(npcBot)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую DarkPact для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif botMode == BOT_MODE_RETREAT
        then
            if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
            then
                --npcBot:ActionImmediate_Chat("Использую DarkPact для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
            if (#enemyCreeps > 2)
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
    end
end

function ConsiderPounce()
    local ability = Pounce;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую Pounce для отхода!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderDepthShroud()
    local ability = DepthShroud;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderShadowDance()
    local ability = ShadowDance;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    if not npcBot:HasModifier("modifier_slark_depth_shroud") or not npcBot:HasModifier("modifier_slark_shadow_dance")
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and
                GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowDance для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif botMode == BOT_MODE_RETREAT
        then
            if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowDance для отступления!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end
