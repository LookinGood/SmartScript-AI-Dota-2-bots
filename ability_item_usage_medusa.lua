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
    Talents[3],
    Abilities[1],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SplitShot = AbilitiesReal[1]
local MysticSnake = AbilitiesReal[2]
local GorgonsGrasp = AbilitiesReal[3]
local StoneGaze = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSplitShotDesire = ConsiderSplitShot();
    local castMysticSnakeDesire, castMysticSnakeTarget = ConsiderMysticSnake();
    local castGorgonsGraspDesire, castGorgonsGraspLocation = ConsiderGorgonsGrasp();
    local castStoneGazeDesire = ConsiderStoneGaze();

    if (castSplitShotDesire ~= nil)
    then
        npcBot:Action_UseAbility(SplitShot);
        return;
    end

    if (castMysticSnakeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(MysticSnake, castMysticSnakeTarget);
        return;
    end

    if (castGorgonsGraspDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(GorgonsGrasp, castGorgonsGraspLocation);
        return;
    end

    if (castStoneGazeDesire ~= nil)
    then
        npcBot:Action_UseAbility(StoneGaze);
        return;
    end
end

function ConsiderSplitShot()
    local ability = SplitShot;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local castRangeAbility = npcBot:GetAttackRange() + ability:GetSpecialValueInt("split_shot_bonus_range");
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(attackTarget) and (ability:GetLevel() >= 3)
        then
            if (#enemyAbility > 1) or (#enemyCreeps > 4)
            then
                if ability:GetToggleState() == false
                then
                    --npcBot:ActionImmediate_Chat("Включаю SplitShot для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            else
                if ability:GetToggleState() == true
                then
                    --npcBot:ActionImmediate_Chat("Выключаю SplitShot для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        if (#enemyCreeps > 1) and utility.IsValidTarget(attackTarget)
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю SplitShot против крипов!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю SplitShot против крипов!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю SplitShot!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderMysticSnake()
    local ability = MysticSnake;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("snake_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                and utility.CanCastSpellOnTarget(ability, enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую MysticSnake что бы убить цель!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
            -- Cast if can interrupt spell
            if npcBot:HasScepter()
            then
                if enemy:IsChanneling() and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- (Only Scepter) Cast if can interrupt cast
    if npcBot:HasScepter() and (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget;
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

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую MysticSnake против крипов!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderGorgonsGrasp()
    local ability = GorgonsGrasp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local bonusRange = ability:GetSpecialValueInt("radius") + ability:GetSpecialValueInt("radius_grow");
    local damageAbility = ability:GetSpecialValueInt("damage") +
        (ability:GetSpecialValueInt("damage_pers") * ability:GetSpecialValueInt("duration"));
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + bonusRange, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую GorgonsGrasp в радиусе каста что бы убить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + bonusRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую GorgonsGrasp в радиусе каста+радиус что бы убить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + bonusRange
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
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
                        --npcBot:ActionImmediate_Chat("Использую GorgonsGrasp в радиусе каста для отхода!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + bonusRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую GorgonsGrasp в радиусе каста+радиус для отхода!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
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
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderStoneGaze()
    local ability = StoneGaze;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_medusa_stone_gaze")
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            and not utility.IsDisabled(botTarget) and botTarget:IsFacingLocation(npcBot:GetLocation(), 80)
        then
            --npcBot:ActionImmediate_Chat("Использую StoneGaze для нападения по цели!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if enemy > 1
        if (#enemyAbility > 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.IsHero(enemy) and not utility.IsDisabled(enemy) and enemy:IsFacingLocation(npcBot:GetLocation(), 80)
                then
                    --npcBot:ActionImmediate_Chat("Использую StoneGaze для нападения по 2+ целям!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7 or ManaPercentage <= 0.5) and (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую StoneGaze для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
