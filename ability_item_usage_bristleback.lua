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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
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
local ViscousNasalGoo = AbilitiesReal[1]
local QuillSpray = AbilitiesReal[2]
local Bristleback = AbilitiesReal[3]
local Hairball = AbilitiesReal[4]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castViscousNasalGooDesire, castViscousNasalGooTarget = ConsiderViscousNasalGoo();
    local castQuillSprayDesire = ConsiderQuillSpray();
    local castBristlebackDesire, castBristlebackLocation = ConsiderBristleback();
    local castHairballDesire, castHairballLocation = ConsiderHairball();

    if (castViscousNasalGooDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ViscousNasalGoo, castViscousNasalGooTarget);
        return;
    end

    if (castQuillSprayDesire ~= nil)
    then
        npcBot:Action_UseAbility(QuillSpray);
        return;
    end

    if (castBristlebackDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Bristleback, castBristlebackLocation);
        return;
    end

    if (castHairballDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Hairball, castHairballLocation);
        return;
    end
end

function ConsiderViscousNasalGoo()
    local ability = ViscousNasalGoo;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
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
end

function ConsiderQuillSpray()
    local ability = QuillSpray;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                return BOT_MODE_DESIRE_HIGH;
            end
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility)
                do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    elseif utility.RetreatMode(npcBot)
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
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderBristleback()
    local ability = Bristleback;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
    then
        local castRangeAbility = QuillSpray:GetAOERadius();
        local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

        -- Cast if attack enemy
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(QuillSpray, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                end
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(QuillSpray, enemy) and not utility.IsDisabled(enemy)
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
                end
            end
        end
    end
end

function ConsiderHairball()
    local ability = Hairball;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility + radiusAbility), true,
        BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + radiusAbility)
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
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
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count > 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
