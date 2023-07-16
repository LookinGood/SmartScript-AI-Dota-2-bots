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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

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
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    DragonSlave = AbilitiesReal[1]
    LightStrikeArray = AbilitiesReal[2]
    FlameCloak = AbilitiesReal[4]
    LagunaBlade = AbilitiesReal[6]

    castDragonSlaveDesire, castDragonSlaveLocation = ConsiderDragonSlave();
    castLightStrikeArrayDesire, castLightStrikeArrayLocation = ConsiderLightStrikeArray();
    castFlameCloakDesire = ConsiderFlameCloak();
    castLagunaBladeDesire, castLagunaBladeTarget = ConsiderLagunaBlade();

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
    local damageAbility = ability:GetSpecialValueInt("dragon_slave_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую DragonSlave что бы убить бегущую цель!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую DragonSlave что бы убить бегущую цель!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if utility.IsMoving(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Использую DragonSlave по бегущей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
                else
                    --npcBot:ActionImmediate_Chat("Использую DragonSlave по стоящей цели!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую DragonSlave по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.IsValidTarget(enemy) and (ManaPercentage >= 0.7) and utility.CanCastOnMagicImmuneTarget(enemy)
        then
            if utility.IsMoving(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую DragonSlave по бегущей цели на ЛАЙНЕ!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
            else
                --npcBot:ActionImmediate_Chat("Использую DragonSlave по стоящей цели на ЛАЙНЕ!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
            end
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
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по бегущей цели убивая", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по стоящей цели убивая!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200 and not utility.IsDisabled(botTarget)
            then
                if utility.IsMoving(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по бегущей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
                else
                    --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по стоящей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по бегущей цели ОТСТУПАЯ!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по стоящей цели ОТСТУПАЯ!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
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
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую FlameCloak против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.9) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую FlameCloak для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderLagunaBlade()
    local ability = LagunaBlade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local damageType = ability:GetDamageType();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, damageType)
                then
                    if damageType == DAMAGE_TYPE_MAGICAL
                    then
                        if utility.CanCastOnMagicImmuneTarget(enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую LagunaBlade что бы убить врага маг уроном!",true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Использую LagunaBlade что бы убить врага чистым уроном!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and utility.SafeCast(botTarget, true) and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5
        then
            if damageType == DAMAGE_TYPE_MAGICAL
            then
                if utility.CanCastOnMagicImmuneTarget(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Использую LagunaBlade с маг уроном!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget;
                end
            else
                --npcBot:ActionImmediate_Chat("Использую LagunaBlade с чистым уроном!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget;
            end
        end
    end
end
