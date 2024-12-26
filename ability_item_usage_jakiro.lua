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
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local DualBreath = AbilitiesReal[1]
local IcePath = AbilitiesReal[2]
local LiquidFire = AbilitiesReal[3]
local LiquidFrost = AbilitiesReal[4]
local Macropyre = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDualBreathDesire, castDualBreathLocation = ConsiderDualBreath();
    local castIcePathDesire, castIcePathLocation = ConsiderIcePath();
    ConsiderLiquidFire();
    ConsiderLiquidFrost();
    local castMacropyreDesire, castMacropyreLocation = ConsiderMacropyre();

    if (castDualBreathDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DualBreath, castDualBreathLocation);
        return;
    end

    if (castIcePathDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IcePath, castIcePathLocation);
        return;
    end

    if (castMacropyreDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Macropyre, castMacropyreLocation);
        return;
    end
end

function ConsiderDualBreath()
    local ability = DualBreath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("end_radius");
    local damageAbility = ability:GetSpecialValueInt("burn_damage") * ability:GetSpecialValueInt("AbilityDuration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + 200), true,
        BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую DualBreath что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Retreat or help ally use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderIcePath()
    local ability = IcePath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("path_radius");
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("path_duration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + 200), true,
        BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую IcePath что бы убить цель/сбить каст!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat or help ally use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end
end

function ConsiderLiquidFire()
    local ability = LiquidFire;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast()
    end
end

function ConsiderLiquidFrost()
    local ability = LiquidFrost;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast()
    end
end

function ConsiderMacropyre()
    local ability = Macropyre;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("path_width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + 200), true,
        BOT_MODE_NONE);

    -- Cast if enemy hero immobilized
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsDisabled(enemy) and utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
            end
        end
    end

    -- Cast if enemy >=2
    if utility.PvPMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
