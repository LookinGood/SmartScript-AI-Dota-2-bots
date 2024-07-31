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
local Firestorm = AbilitiesReal[1]
local PitOfMalice = AbilitiesReal[2]
local FiendsGate = AbilitiesReal[6]

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

    if (castFirestormDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Firestorm, castFirestormLocation);
        return;
    end

    if (castPitOfMaliceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(PitOfMalice, castPitOfMaliceLocation);
        return;
    end

    if (castFiendsGateDesire ~= nil)
    then
        -- npcBot:Action_ClearActions(false);
        npcBot:Action_Delay(5.0);
        npcBot:Action_UseAbilityOnLocation(FiendsGate, castFiendsGateLocation);
        return;
    end
end

function ConsiderFirestorm()
    local ability = Firestorm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Firestorm по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Firestorm по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderPitOfMalice()
    local ability = PitOfMalice;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
    end
end

function ConsiderFiendsGate()
    local ability = FiendsGate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local minDistance = ability:GetSpecialValueInt("minimum_distance");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local ancient = GetAncient(GetTeam());

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            local allyHeroes = botTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#allyHeroes > 0) and GetUnitToUnitDistance(npcBot, botTarget) >= minDistance
            then
                if GetUnitToUnitDistance(npcBot, allyHeroes[1]) >= minDistance
                then
                    --npcBot:ActionImmediate_Chat("Использую FiendsGate для атаки!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetPosition(allyHeroes[1], delayAbility) + RandomVector(npcBot:GetAttackRange());
                else
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetPosition(botTarget, delayAbility) + RandomVector(npcBot:GetAttackRange());
                end
            end
        end
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > minDistance
        then
            --npcBot:ActionImmediate_Chat("Использую FiendsGate для отхода!", true);
            --return BOT_ACTION_DESIRE_VERYHIGH, utility.SafeLocation(npcBot) + RandomVector(npcBot:GetAttackRange() * 4);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetEscapeLocation(ancient, 1000) + RandomVector(100);
        end
    end
end
