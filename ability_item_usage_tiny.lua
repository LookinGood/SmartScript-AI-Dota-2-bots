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
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Avalanche = AbilitiesReal[1]
local Toss = AbilitiesReal[2]
local TreeGrab = AbilitiesReal[3]
local TreeThrow = npcBot:GetAbilityByName("tiny_toss_tree");
local TreeVolley = AbilitiesReal[4]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castAvalancheDesire, castAvalancheLocation = ConsiderAvalanche();
    local castTossDesire, castTossTarget = ConsiderToss();
    local castTreeGrabDesire, castTreeGrabTarget = ConsiderTreeGrab();
    local castTreeThrowDesire, castTreeThrowTarget = ConsiderTreeThrow();
    local castTreeVolleyDesire, castTreeVolleyLocation = ConsiderTreeVolley();

    if (castAvalancheDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Avalanche, castAvalancheLocation);
        return;
    end

    if (castTossDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Toss, castTossTarget);
        return;
    end

    if (castTreeGrabDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnTree(TreeGrab, castTreeGrabTarget);
        return;
    end

    if (castTreeThrowDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(TreeThrow, castTreeThrowTarget);
        return;
    end

    if (castTreeVolleyDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TreeVolley, castTreeVolleyLocation);
        return;
    end
end

function ConsiderAvalanche()
    local ability = Avalanche;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("avalanche_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderToss()
    local ability = Toss;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local grabRadius = ability:GetSpecialValueInt("grab_radius");
    local grabAllyHeroes = npcBot:GetNearbyHeroes(grabRadius, true, BOT_MODE_NONE);
    local grabEnemyHeroes = npcBot:GetNearbyHeroes(grabRadius, true, BOT_MODE_NONE);
    local grabAllyCreeps = npcBot:GetNearbyCreeps(grabRadius, false);
    local grabEnemyCreeps = npcBot:GetNearbyCreeps(grabRadius, true);
    local creaturesAroundMe = #grabEnemyHeroes + #grabAllyCreeps + #grabEnemyCreeps;

    if (#grabAllyHeroes <= 1 and creaturesAroundMe <= 0) or (creaturesAroundMe <= 0)
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("toss_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Toss что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
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
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Toss по вражеским крипам!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#grabEnemyHeroes > 0) and (#grabAllyHeroes <= 1)
        then
            if (#enemyAbility > 1)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) >= castRangeAbility / 2
                    then
                        --npcBot:ActionImmediate_Chat("Использую Toss что бы откинуть врага в другого врага!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
            if (#enemyCreeps > 0)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) >= castRangeAbility / 2
                    then
                        --npcBot:ActionImmediate_Chat("Использую Toss что бы откинуть врага в крипа!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        if #grabAllyHeroes <= 1 and #grabEnemyHeroes > 0 or #grabAllyCreeps > 0 or #grabEnemyCreeps > 0
        then
            local enemy = utility.GetWeakest(enemyAbility);
            if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
            then
                --npcBot:ActionImmediate_Chat("Использую Toss на лайне!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end
end

function ConsiderTreeGrab()
    local ability = TreeGrab;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local trees = npcBot:GetNearbyTrees(castRangeAbility * 2);

    if (#trees == 0) or utility.RetreatMode(npcBot) or npcBot:HasModifier("modifier_tiny_tree_grab")
    then
        return;
    end

    if (#trees > 0) and (IsLocationVisible(GetTreeLocation(trees[1])) or IsLocationPassable(GetTreeLocation(trees[1])))
    then
        if botMode == BOT_MODE_LANING and (ManaPercentage >= 0.5)
        then
            return BOT_ACTION_DESIRE_HIGH, trees[1];
        else
            return BOT_ACTION_DESIRE_HIGH, trees[1];
        end
    end
end

function ConsiderTreeThrow()
    local ability = TreeThrow;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local damageAbility = npcBot:GetAttackDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TreeThrow что бы убить цель!", true);
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
                and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2) and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget;
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
                    --npcBot:ActionImmediate_Chat("Использую TreeThrow для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую TreeThrow на лайне!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderTreeVolley()
    local ability = TreeVolley;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local grabRadius = ability:GetSpecialValueInt("tree_grab_radius");
    local trees = npcBot:GetNearbyTrees(grabRadius);

    if (#trees < 4)
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("splash_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую ChaoticOffering по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую TreeVolley по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
