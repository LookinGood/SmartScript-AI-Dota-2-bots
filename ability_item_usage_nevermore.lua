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
    Abilities[4],
    Abilities[5],
    Abilities[1],
    Abilities[1],
    Abilities[4],
    Abilities[1],
    Abilities[4],
    Abilities[4],
    Talents[2],
    Abilities[5],
    Abilities[6],
    Abilities[6],
    Abilities[5],
    Talents[4],
    Abilities[5],
    Abilities[6],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Shadowraze1 = AbilitiesReal[1]
local Shadowraze2 = AbilitiesReal[2]
local Shadowraze3 = AbilitiesReal[3]
local Necromastery = AbilitiesReal[4]
local RequiemOfSouls = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castShadowraze1Desire = ConsiderShadowraze1();
    local castShadowraze2Desire = ConsiderShadowraze2();
    local castShadowraze3Desire = ConsiderShadowraze3();
    local castNecromasteryDesire, castNecromasteryTarget = ConsiderNecromastery();
    local castRequiemOfSoulsDesire = ConsiderRequiemOfSouls();

    if (castShadowraze1Desire ~= nil)
    then
        npcBot:Action_UseAbility(Shadowraze1);
        return;
    end

    if (castShadowraze2Desire ~= nil)
    then
        npcBot:Action_UseAbility(Shadowraze2);
        return;
    end

    if (castShadowraze3Desire ~= nil)
    then
        npcBot:Action_UseAbility(Shadowraze3);
        return;
    end

    if (castNecromasteryDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Necromastery, castNecromasteryTarget);
        return;
    end

    if (castRequiemOfSoulsDesire ~= nil)
    then
        npcBot:Action_UseAbility(RequiemOfSouls);
        return;
    end
end

function ConsiderShadowraze1()
    local ability = Shadowraze1;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("shadowraze_range");
    local radiusAbility = ability:GetSpecialValueInt("shadowraze_radius");
    local damageAbility = ability:GetSpecialValueInt("shadowraze_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze1 что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
                and GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility - radiusAbility
                and GetUnitToUnitDistance(npcBot, botTarget) < castRangeAbility + radiusAbility
            then
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze1 против крипов!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.5) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
            and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
            and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Shadowraze1 по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderShadowraze2()
    local ability = Shadowraze2;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("shadowraze_range");
    local radiusAbility = ability:GetSpecialValueInt("shadowraze_radius");
    local damageAbility = ability:GetSpecialValueInt("shadowraze_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze2 что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
                and GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility - radiusAbility
                and GetUnitToUnitDistance(npcBot, botTarget) < castRangeAbility + radiusAbility
            then
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze2 против крипов!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.5) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
            and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
            and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Shadowraze2 по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderShadowraze3()
    local ability = Shadowraze3;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("shadowraze_range");
    local radiusAbility = ability:GetSpecialValueInt("shadowraze_radius");
    local damageAbility = ability:GetSpecialValueInt("shadowraze_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze3 что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
                and GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility - radiusAbility
                and GetUnitToUnitDistance(npcBot, botTarget) < castRangeAbility + radiusAbility
            then
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                    and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
                    and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadowraze3 против крипов!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.5) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
            and GetUnitToUnitDistance(npcBot, enemy) > castRangeAbility - radiusAbility
            and GetUnitToUnitDistance(npcBot, enemy) < castRangeAbility + radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Shadowraze3 по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderNecromastery()
    local ability = Necromastery;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_AUTOCAST) and utility.GetModifierCount(npcBot, "modifier_nevermore_necromastery") >= 1
    then
        if not ability:GetAutoCastState()
        then
            --npcBot:ActionImmediate_Chat("Переключаю Necromastery в автокаст!", true);
            ability:ToggleAutoCast();
        end

        -- Cast if can interrupt cast
        local enemyAbility = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
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

        -- Retreat use
        if utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Necromastery для отхода!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
    end
end

function ConsiderRequiemOfSouls()
    local ability = RequiemOfSouls;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.GetModifierCount(npcBot, "modifier_nevermore_necromastery") < 10
    then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility / 2, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую RequiemOfSouls для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end

        if (#enemyAbility > 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую RequiemOfSouls по 2+ врагам!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую RequiemOfSouls для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
