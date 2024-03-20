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
    Abilities[3],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Starstorm = AbilitiesReal[1]
local SacredArrow = AbilitiesReal[2]
local Leap = AbilitiesReal[3]
local MoonlightShadow = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStarstormDesire = ConsiderStarstorm();
    local castSacredArrowDesire, castSacredArrowLocation = ConsiderSacredArrow();
    local castLeapDesire, castLeapLocation, castLeapTargetType = ConsiderLeap();
    local castMoonlightShadowDesire = ConsiderMoonlightShadow();

    if (castStarstormDesire ~= nil)
    then
        npcBot:Action_UseAbility(Starstorm);
        return;
    end

    if (castSacredArrowDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SacredArrow, castSacredArrowLocation);
        return;
    end

    if (castLeapDesire ~= nil)
    then
        if (castLeapTargetType == nil)
        then
            npcBot:Action_UseAbility(Leap);
            return;
        elseif (castLeapTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Leap, castLeapLocation);
            return;
        end
    end

    if (castMoonlightShadowDesire ~= nil)
    then
        npcBot:Action_UseAbility(MoonlightShadow);
        return;
    end
end

function ConsiderStarstorm()
    local ability = Starstorm;
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
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
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
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSacredArrow()
    local ability = SacredArrow;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local abilityRadius = ability:GetSpecialValueInt("arrow_width");
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("arrow_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / speedAbility));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SacredArrow что бы сбить каст!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                local targetDistance = GetUnitToUnitDistance(botTarget, npcBot)
                local moveDirection = botTarget:GetMovementDirectionStability();
                local targetLocation = botTarget:GetExtrapolatedLocation(delayAbility +
                    (targetDistance / speedAbility));
                if moveDirection < 0.95
                then
                    targetLocation = botTarget:GetLocation();
                end
                if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius)
                then
                    --npcBot:ActionImmediate_Chat("Использую SacredArrow для атаки!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                end
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
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / speedAbility));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SacredArrow для отхода!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                    end
                end
            end
        end
    end
end

function ConsiderLeap()
    local ability = Leap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("leap_distance") * 2;
    local attackRange = npcBot:GetAttackRange();
    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
                and (GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
            then
                --npcBot:ActionImmediate_Chat("Использую Leap обычный, для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, nil, nil;
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
            then
                --npcBot:ActionImmediate_Chat("Использую Leap обычный, для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH, nil, nil;
            end
        end
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
    then
        if ability:GetToggleState() == false
        then
            --npcBot:ActionImmediate_Chat("Переключаю Leap!", true);
            return BOT_ACTION_DESIRE_HIGH, nil, nil;
        end
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
                and (GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
            then
                npcBot:ActionImmediate_Chat("Использую Leap шардовый, для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0)
            then
                npcBot:ActionImmediate_Chat("Использую Leap шардовый, для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility), "location";
            end
        end
    end
end

function ConsiderMoonlightShadow()
    local ability = MoonlightShadow;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#allyAbility > 0)
    then
        for i = 1, #allyAbility do
            local enemyAbility = allyAbility[i]:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if utility.IsHero(allyAbility[i]) and not allyAbility[i]:IsInvisible()
                and allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.7 and allyAbility[i]:WasRecentlyDamagedByAnyHero(2.0)
                and (#enemyAbility > 0)
            then
                --npcBot:ActionImmediate_Chat("Использую MoonlightShadow!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end
