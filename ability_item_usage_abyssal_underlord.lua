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
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Firestorm = npcBot:GetAbilityByName("abyssal_underlord_firestorm");
local PitOfMalice = npcBot:GetAbilityByName("abyssal_underlord_pit_of_malice");
local FiendsGate = npcBot:GetAbilityByName("abyssal_underlord_dark_portal");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFirestormDesire, castFirestormLocation = ConsiderFirestorm();
    local castPitOfMaliceDesire, castPitOfMaliceLocation = ConsiderPitOfMalice();
    local castFiendsGateDesire, castFiendsGateLocation = ConsiderFiendsGate();

    if (castFirestormDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Firestorm, castFirestormLocation);
        return;
    end

    if (castPitOfMaliceDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(PitOfMalice, castPitOfMaliceLocation);
        return;
    end

    if (castFiendsGateDesire > 0)
    then
        npcBot:Action_ClearActions(true);
        npcBot:ActionQueue_UseAbilityOnLocation(FiendsGate, castFiendsGateLocation);
        npcBot:ActionQueue_Delay(3.0);
        return;
    end
end

function ConsiderFirestorm()
    local ability = Firestorm;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Firestorm по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Firestorm по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPitOfMalice()
    local ability = PitOfMalice;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую PitOfMalice по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFiendsGate()
    local ability = FiendsGate;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local minDistance = ability:GetSpecialValueInt("minimum_distance");
    local minFountainDistance = ability:GetSpecialValueInt("distance_from_fountain");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CountAllyHeroAroundUnit(botTarget, minDistance) >= utility.CountEnemyHeroAroundUnit(botTarget, minDistance)
            then
                if (#allyAbility > 1) and GetUnitToUnitDistance(npcBot, botTarget) >= minDistance and not botTarget:HasModifier('modifier_fountain_aura_buff')
                then
                    for _, ally in pairs(allyAbility)
                    do
                        if ally ~= npcBot and utility.IsHero(ally) and GetUnitToUnitDistance(npcBot, ally) >= minDistance
                            and GetUnitToUnitDistance(botTarget, ally) <= (ally:GetAttackRange() * 2)
                        then
                            --npcBot:ActionImmediate_Chat("Использую FiendsGate атакуя, на " .. botTarget:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH,
                                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0) +
                                RandomVector(npcBot:GetAttackRange());
                        end
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local ancient = GetAncient(GetTeam());
        if (HealthPercentage <= 0.6) and utility.BotWasRecentlyDamagedByEnemyHero(2.0) and GetUnitToUnitDistance(npcBot, ancient) > minDistance
            and npcBot:DistanceFromFountain() > minFountainDistance
        then
            --npcBot:ActionImmediate_Chat("Использую FiendsGate для отхода!", true);
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetEscapeLocation(ancient, npcBot:GetAttackRange() * 2);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
