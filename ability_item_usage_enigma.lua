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
local Malefice = AbilitiesReal[1]
local DemonicSummoning = AbilitiesReal[2]
local MidnightPulse = AbilitiesReal[3]
local BlackHole = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castMaleficeDesire, castMaleficeTarget = ConsiderMalefice();
    local castDemonicSummoningDesire, castDemonicSummoningLocation = ConsiderDemonicSummoning();
    local castMidnightPulseDesire, castMidnightPulseLocation = ConsiderMidnightPulse();
    local castBlackHoleDesire, castBlackHoleLocation = ConsiderBlackHole();

    if (castMaleficeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Malefice, castMaleficeTarget);
        return;
    end

    if (castDemonicSummoningDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DemonicSummoning, castDemonicSummoningLocation);
        return;
    end

    if (castMidnightPulseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MidnightPulse, castMidnightPulseLocation);
        return;
    end

    if (castBlackHoleDesire ~= nil)
    then
        --npcBot:Action_ClearActions(true);
        --npcBot:ActionQueue_Delay(1.0);
        npcBot:Action_UseAbilityOnLocation(BlackHole, castBlackHoleLocation);
        return;
    end
end

function ConsiderMalefice()
    local ability = Malefice;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local strikesAbility = ability:GetSpecialValueInt("stun_instances");
    local damageAbility = ability:GetSpecialValueInt("damage") * strikesAbility;
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Malefice что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Malefice по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Malefice что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Malefice по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderDemonicSummoning()
    local ability = DemonicSummoning;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local minionAttackRange = ability:GetSpecialValueInt("eidolon_attack_range");

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + minionAttackRange)
            then
                return BOT_MODE_DESIRE_MODERATE, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_MODERATE, enemy:GetLocation();
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
        local frendlyTower = npcBot:GetNearbyTowers(castRangeAbility, false);
        local enemyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, true);
        local frendlyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, false);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                end
            end
        end
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                end
            end
            if (#frendlyTower > 0)
            then
                for _, ally in pairs(frendlyTower) do
                    if utility.CanCastSpellOnTarget(ability, ally)
                    then
                        return BOT_MODE_DESIRE_LOW, ally:GetLocation() + RandomVector(minionAttackRange);
                    end
                end
            end
            if (#enemyBarracks > 0)
            then
                for _, enemy in pairs(enemyBarracks) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                    end
                end
            end
            if (#frendlyBarracks > 0)
            then
                for _, ally in pairs(frendlyBarracks) do
                    if utility.CanCastSpellOnTarget(ability, ally)
                    then
                        return BOT_MODE_DESIRE_LOW, ally:GetLocation() + RandomVector(minionAttackRange);
                    end
                end
            end
        end
    end
end

function ConsiderMidnightPulse()
    local ability = MidnightPulse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую MidnightPulse по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую MidnightPulse по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderBlackHole()
    local ability = BlackHole;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("duration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlackHole что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
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
            --npcBot:ActionImmediate_Chat("Использую BlackHole по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

-- OLD ABILITIES

--[[ function ConsiderDemonicConversion()
    local ability = DemonicConversion;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
    local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
    local creepMaxLevel = ability:GetSpecialValueInt("creep_max_level");

    -- General use
    if botMode ~= BOT_MODE_LANING and (ManaPercentage > 0.5)
    then
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and not enemy:IsAncientCreep() and not enemy:HasModifier("modifier_creep_bonus_xp")
                        and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.8)) and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        if (#allyCreeps > 0)
        then
            for _, ally in pairs(allyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(ally) and not ally:IsAncientCreep() and not ally:HasModifier("modifier_creep_bonus_xp")
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.2)) and ally:GetLevel() <= creepMaxLevel
                then
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end ]]
