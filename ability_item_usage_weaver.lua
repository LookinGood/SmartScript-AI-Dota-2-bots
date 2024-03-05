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
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local TheSwarm = AbilitiesReal[1]
local Shukuchi = AbilitiesReal[2]
local GeminateAttack = AbilitiesReal[3]
local TimeLapse = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castTheSwarmDesire, castTheSwarmLocation = ConsiderTheSwarm();
    local castShukuchiDesire = ConsiderShukuchi();
    ConsiderGeminateAttack();
    local castTimeLapseDesire, castTimeLapseTarget, castTimeLapseTargetType = ConsiderTimeLapse();

    if (castTheSwarmDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TheSwarm, castTheSwarmLocation);
        return;
    end

    if (castShukuchiDesire ~= nil)
    then
        npcBot:Action_UseAbility(Shukuchi);
        return;
    end

    if (castTimeLapseDesire ~= nil)
    then
        if (castTimeLapseTargetType == nil)
        then
            npcBot:Action_UseAbility(TimeLapse);
            return;
        elseif (castTimeLapseTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(TimeLapse, castTimeLapseTarget);
            return;
        end
    end
end

function ConsiderTheSwarm()
    local ability = TheSwarm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("duration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TheSwarm что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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

function ConsiderShukuchi()
    local ability = Shukuchi;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Shukuchi что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 1000)
                or GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        return BOT_MODE_DESIRE_VERYHIGH;
    end
end

function ConsiderGeminateAttack()
    local ability = GeminateAttack;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast()
    end
end

function ConsiderTimeLapse()
    local ability = TimeLapse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        if (HealthPercentage <= 0.4) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
        then
            return BOT_ACTION_DESIRE_ABSOLUTE, nil;
        end
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
    then
        local castRangeAbility = ability:GetCastRange();
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.4)
                    and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally, "target";
                end
            end
        end
    end
end
