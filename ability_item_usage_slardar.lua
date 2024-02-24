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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[4],
    Abilities[1],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local GuardianSprint = AbilitiesReal[1]
local SlithereenCrush = AbilitiesReal[2]
local CorrosiveHaze = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castGuardianSprintDesire = ConsiderGuardianSprint();
    local castSlithereenCrushDesire = ConsiderSlithereenCrush();
    local castCorrosiveHazeDesire, castCorrosiveHazeTarget = ConsiderCorrosiveHaze();

    if (castGuardianSprintDesire ~= nil)
    then
        npcBot:Action_UseAbility(GuardianSprint);
        return;
    end

    if (castSlithereenCrushDesire ~= nil)
    then
        npcBot:Action_UseAbility(SlithereenCrush);
        return;
    end

    if (castCorrosiveHazeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(CorrosiveHaze, castCorrosiveHazeTarget);
        return;
    end
end

function ConsiderGuardianSprint()
    local ability = GuardianSprint;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_slardar_sprint") then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= 1600 and GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange()
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) or npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderSlithereenCrush()
    local ability = SlithereenCrush;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую SlithereenCrush что бы убить цель/прервать каст!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
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
end

function ConsiderCorrosiveHaze()
    local ability = CorrosiveHaze;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if not botTarget:HasModifier("modifier_slardar_amplify_damage")
                then
                    return BOT_MODE_DESIRE_VERYHIGH, botTarget;
                else
                    if (#enemyAbility > 1)
                    then
                        for _, enemy in pairs(enemyAbility) do
                            if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_slardar_amplify_damage")
                            then
                                return BOT_ACTION_DESIRE_HIGH, enemy;
                            end
                        end
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.2)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                    and enemy:IsAncientCreep()
                then
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
        -- General use
    elseif botMode ~= BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.3)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_slardar_amplify_damage")
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end
