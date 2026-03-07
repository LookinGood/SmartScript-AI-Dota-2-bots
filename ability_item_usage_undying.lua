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
    Abilities[3],
    Abilities[1],
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
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Decay = npcBot:GetAbilityByName("undying_decay");
local SoulRip = npcBot:GetAbilityByName("undying_soul_rip");
local Tombstone = npcBot:GetAbilityByName("undying_tombstone");
local FleshGolem = npcBot:GetAbilityByName("undying_flesh_golem");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDecayDesire, castDecayLocation = ConsiderDecay();
    local castSoulRipDesire, castSoulRipTarget = ConsiderSoulRip();
    local castTombstoneDesire, castTombstoneTarget, castTombstoneTargetType = ConsiderTombstone();
    local castFleshGolemDesire = ConsiderFleshGolem();

    if (castDecayDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Decay, castDecayLocation);
        return;
    end

    if (castSoulRipDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(SoulRip, castSoulRipTarget);
        return;
    end

    if (castTombstoneDesire > 0)
    then
        if (castTombstoneTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Tombstone, castTombstoneTarget);
            return;
        elseif (castTombstoneTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Tombstone, castTombstoneTarget);
            return;
        end
    end

    if (castFleshGolemDesire > 0)
    then
        npcBot:Action_UseAbility(FleshGolem);
        return;
    end
end

function ConsiderDecay()
    local ability = Decay;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("decay_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + radiusAbility), true,
        BOT_MODE_NONE);

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
                        --npcBot:ActionImmediate_Chat("Использую Decay1 что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Decay2 что бы добить " .. enemy:GetUnitName(), true);
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
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
    end

    -- Use if need retreat
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH,
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
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 2) and (damageAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую Decay по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.5)
        then
            if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
            then
                return BOT_ACTION_DESIRE_MODERATE,
                    utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSoulRip()
    local ability = SoulRip;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyCreepsAround = npcBot:GetNearbyCreeps(radiusAbility, false);
    local allyHeroAbilityAround = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
    local enemyCreepsAround = npcBot:GetNearbyCreeps(radiusAbility, true);
    local enemyHeroAround = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
    local unitAroundMe = #allyCreepsAround + #allyHeroAbilityAround + #enemyCreepsAround + #enemyHeroAround;
    local damageAbility = math.min(unitAroundMe, ability:GetSpecialValueInt("max_units")) *
        ability:GetSpecialValueInt("damage_per_unit");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    --print("Целей SoulRip: " .. unitAroundMe)
    --print("Урон SoulRip: " .. damageAbility)

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SoulRip с уроном " .. damageAbility .. " что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Cast to heal ally hero
    if (#allyAbility > 0) and damageAbility >= (ability:GetSpecialValueInt("damage_per_unit") * 2)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую Soul Rip на союзного героя со здоровьем ниже 80%",true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and damageAbility >= (ability:GetSpecialValueInt("damage_per_unit") * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Soul Rip по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTombstone()
    local ability = Tombstone;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Tombstone для нападения вблизи!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0),
                    "location";
            elseif GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) < radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Tombstone для нападения издалека!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility),
                    "location";
            end
        end
    end

    -- Use if need retreat
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Tombstone что бы оторваться от врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation() + RandomVector(npcBot:GetAttackRange()),
                        "location";
                end
            end
        end
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
    then
        -- General use on allied heroes
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and not ally:IsChanneling()
                then
                    if utility.IsDisabled(ally) or ((ally:GetHealth() / ally:GetMaxHealth() <= 0.5) and ally:WasRecentlyDamagedByAnyHero(2.0))
                    then
                        --npcBot:ActionImmediate_Chat("Использую Tombstone на союзника в стане!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally, "target";
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end

function ConsiderFleshGolem()
    local ability = FleshGolem;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_undying_flesh_golem")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAcquisitionRange()
        then
            --npcBot:ActionImmediate_Chat("Использую Flesh Golem для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Flesh Golem для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
