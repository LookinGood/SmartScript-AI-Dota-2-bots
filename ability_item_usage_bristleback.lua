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
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
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
local Warpath = AbilitiesReal[6]

--npcBot:GetAbilityByName("bristleback_hairball");

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
    local castWarpathDesire = ConsiderWarpath();

    if (castViscousNasalGooDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(ViscousNasalGoo, castViscousNasalGooTarget);
        return;
    end

    if (castQuillSprayDesire > 0)
    then
        npcBot:Action_UseAbility(QuillSpray);
        return;
    end

    if (castBristlebackDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Bristleback, castBristlebackLocation);
        return;
    end

    if (castHairballDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Hairball, castHairballLocation);
        return;
    end

    if (castWarpathDesire > 0)
    then
        npcBot:Action_UseAbility(Warpath);
        return;
    end
end

function ConsiderViscousNasalGoo()
    local ability = ViscousNasalGoo;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderQuillSpray()
    local ability = QuillSpray;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_AUTOCAST)
    then
        if utility.BossMode(npcBot) and utility.IsBoss(botTarget) and
            utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            if not ability:GetAutoCastState()
            then
                ability:ToggleAutoCast();
            end
        else
            if ability:GetAutoCastState()
            then
                ability:ToggleAutoCast();
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBristleback()
    local ability = Bristleback;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
    then
        local castRangeAbility = npcBot:GetAttackRange() * 2;
        local delayAbility = ability:GetSpecialValueInt("activation_delay");

        -- Cast if attack enemy
        if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
        then
            if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Bristleback на " .. botTarget:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                end
            end
        end

        -- Retreat use
        if utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Bristleback при отходе на " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderHairball()
    local ability = Hairball;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + radiusAbility), true,
        BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + radiusAbility)
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Hairball при малой дистанции на " .. botTarget:GetUnitName(),true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Hairball при большей дистанции на " .. botTarget:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
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
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Hairball для отхода при малой дистанции на " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Hairball для отхода при большей дистанции на " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count > 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Hairball против крипов.", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWarpath()
    local ability = Warpath;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_bristleback_warpath_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)
        then
            if utility.CanCastSpellOnTarget(ability, attackTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Warpath на врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.5)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    if utility.PvEMode(npcBot)
    then
        if (ManaPercentage >= 0.5) and attackTarget:IsAncientCreep() and utility.CanCastSpellOnTarget(ability, attackTarget)
            and (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую Warpath на крипа!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
