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
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local DragonSlave = AbilitiesReal[1]
local LightStrikeArray = AbilitiesReal[2]
local FlameCloak = AbilitiesReal[4]
local LagunaBlade = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDragonSlaveDesire, castDragonSlaveLocation = ConsiderDragonSlave();
    local castLightStrikeArrayDesire, castLightStrikeArrayLocation = ConsiderLightStrikeArray();
    local castFlameCloakDesire = ConsiderFlameCloak();
    local castLagunaBladeDesire, castLagunaBladeTarget = ConsiderLagunaBlade();

    if (castDragonSlaveDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DragonSlave, castDragonSlaveLocation);
        return;
    end

    if (castLightStrikeArrayDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(LightStrikeArray, castLightStrikeArrayLocation);
        return;
    end

    if (castFlameCloakDesire ~= nil)
    then
        npcBot:Action_UseAbility(FlameCloak);
        return;
    end

    if (castLagunaBladeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LagunaBlade, castLagunaBladeTarget);
        return;
    end
end

function ConsiderDragonSlave()
    local ability = DragonSlave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("dragon_slave_width_end");
    local damageAbility = ability:GetSpecialValueInt("dragon_slave_damage") +
    (ability:GetSpecialValueInt("dragon_slave_burn") * ability:GetSpecialValueInt("dragon_slave_burn_duration"));
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("dragon_slave_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую DragonSlave по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую DragonSlave по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderLightStrikeArray()
    local ability = LightStrikeArray;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("light_strike_array_damage");
    local delayAbility = ability:GetSpecialValueInt("light_strike_array_delay_time");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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

function ConsiderFlameCloak()
    local ability = FlameCloak;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую FlameCloak против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую FlameCloak для отступления!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderLagunaBlade()
    local ability = LagunaBlade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LagunaBlade что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5
            then
                --npcBot:ActionImmediate_Chat("Использую LagunaBlade для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end
