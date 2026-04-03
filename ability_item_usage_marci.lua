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
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Dispose = npcBot:GetAbilityByName("marci_grapple");
local Rebound = npcBot:GetAbilityByName("marci_companion_run");
local Bodyguard = npcBot:GetAbilityByName("marci_bodyguard");
local SpecialDelivery = npcBot:GetAbilityByName("marci_special_delivery");
local Unleashed = npcBot:GetAbilityByName("marci_unleash");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDisposeDesire, castDisposeTarget = ConsiderDispose();
    local castReboundDesire, castReboundTarget = ConsiderRebound();
    local castBodyguardDesire, castBodyguardTarget = ConsiderBodyguard();
    local castSpecialDeliveryDesire = ConsiderSpecialDelivery();
    local castUnleashedDesire = ConsiderUnleashed();

    if (castDisposeDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Dispose, castDisposeTarget);
        return;
    end

    if (castReboundDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Rebound, castReboundTarget);
        return;
    end

    if (castBodyguardDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Bodyguard, castBodyguardTarget);
        return;
    end

    if (castSpecialDeliveryDesire > 0)
    then
        npcBot:Action_UseAbility(SpecialDelivery);
        return;
    end

    if (castUnleashedDesire > 0)
    then
        npcBot:Action_UseAbility(Unleashed);
        return;
    end
end

function ConsiderDispose()
    local ability = Dispose;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange() * 2;
    local radiusAbility = ability:GetSpecialValueInt("landing_radius");
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Dispose что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget;
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
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_MODERATE, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

local function GetNearbyAllyUnit(npcTarget, radius)
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes)
        do
            if ally ~= npcBot and not utility.IsTargetInvulnerable(ally) and GetUnitToUnitDistance(ally, npcTarget) <= radius
            then
                return ally;
            end
        end
    end

    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps)
        do
            if not utility.IsTargetInvulnerable(ally) and GetUnitToUnitDistance(ally, npcTarget) <= radius
            then
                return ally;
            end
        end
    end

    return nil;
end

function ConsiderRebound()
    local ability = Rebound;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:IsRooted()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("landing_radius");
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local canUseOnEnemy = ability:GetSpecialValueInt("can_jump_off_allies");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if canUseOnEnemy == 1
                    then
                        --npcBot:ActionImmediate_Chat("Использую Rebound убивая цель напрямую " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                    end
                    local nearbyAlly = GetNearbyAllyUnit(enemy, radiusAbility);
                    if nearbyAlly ~= nil
                    then
                        --npcBot:ActionImmediate_Chat("Использую Rebound для убийства на: " .. nearbyAlly:GetUnitName(),  true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, nearbyAlly;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if canUseOnEnemy == 1
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat( "Использую Rebound атакуя цель напрямую " .. botTarget:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, botTarget;
                    end
                end
                local nearbyAlly = GetNearbyAllyUnit(botTarget, radiusAbility);
                if nearbyAlly ~= nil and GetUnitToUnitDistance(npcBot, nearbyAlly) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Rebound для атаки: " .. nearbyAlly:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, nearbyAlly;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local fountainLocation = utility.GetFountainLocation();
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility) do
                    if ally ~= npcBot and GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Rebound для побега на allyHero: " .. ally:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Rebound для побега на allyCreep: " .. ally:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if canUseOnEnemy == 1
            then
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastSpellOnTarget(ability, enemy) and
                            GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                            (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                        then
                            --npcBot:ActionImmediate_Chat( "Использую Rebound для побега на enemyHero: " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
                if (#enemyCreeps > 0)
                then
                    for _, enemy in pairs(enemyCreeps) do
                        if utility.CanCastSpellOnTarget(ability, enemy) and
                            GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                            (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                        then
                            --npcBot:ActionImmediate_Chat( "Использую Rebound для побега на enemyCreep: " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
    end
end

-- plus_high_five

function ConsiderBodyguard()
    local ability = Bodyguard;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and not ally:HasModifier("modifier_marci_bodyguarded")
            then
                if (utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.7)) and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
                if ally:GetAttackTarget() == botTarget
                then
                    npcBot:ActionImmediate_Chat("Использую Bodyguard для атаки на союзника: " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
                -- Cast to buff self
                if ((HealthPercentage <= 0.7) and not npcBot:HasModifier("modifier_marci_bodyguarded")) and
                    (utility.BotWasRecentlyDamagedByEnemyHero(2.0) or
                        npcBot:WasRecentlyDamagedByCreep(2.0) or
                        npcBot:WasRecentlyDamagedByTower(2.0))
                then
                    npcBot:ActionImmediate_Chat("Использую Bodyguard на союзника для бафа себя: " .. ally:GetUnitName(),
                        true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSpecialDelivery()
    local ability = SpecialDelivery;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local courier = utility.GetBotCourier(npcBot);
    local state = GetCourierState(courier);

    if courier == nil or (state == COURIER_STATE_DEAD) or utility.RetreatMode(npcBot)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if (#enemyAbility <= 0) and (state == COURIER_STATE_DELIVERING_ITEMS)
    then
        if GetUnitToUnitDistance(courier, npcBot) > 3000 and npcBot:GetCourierValue() > 150
        then
            --npcBot:ActionImmediate_Chat("Использую SpecialDelivery!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderUnleashed()
    local ability = Unleashed;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_marci_unleash") or npcBot:IsDisarmed()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAcquisitionRange()
            then
                --npcBot:ActionImmediate_Chat("Использую Unleashed для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
