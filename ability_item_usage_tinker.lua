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
    Abilities[2],
    Abilities[3],
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
local Laser = AbilitiesReal[1]
local HeatSeekingMissile = npcBot:GetAbilityByName("tinker_heat_seeking_missile");
local MarchOfTheMachines = AbilitiesReal[2]
local DefenseMatrix = AbilitiesReal[3]
local WarpFlare = AbilitiesReal[4]
local KeenConveyance = AbilitiesReal[5]
local Rearm = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castLaserDesire, castLaserTarget = ConsiderLaser();
    local castMarchOfTheMachinesDesire, castMarchOfTheMachinesLocation = ConsiderMarchOfTheMachines();
    local castHeatSeekingMissileDesire = ConsiderHeatSeekingMissile();
    local castDefenseMatrixDesire, castDefenseMatrixTarget = ConsiderDefenseMatrix();
    local castWarpFlareDesire, castWarpFlareTarget = ConsiderWarpFlare();
    local castKeenConveyanceDesire, castKeenConveyanceLocation = ConsiderKeenConveyance();
    local castRearmDesire = ConsiderRearm();

    if (castLaserDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Laser, castLaserTarget);
        return;
    end

    if (castMarchOfTheMachinesDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MarchOfTheMachines, castMarchOfTheMachinesLocation);
        return;
    end

    if (castHeatSeekingMissileDesire ~= nil)
    then
        npcBot:Action_UseAbility(HeatSeekingMissile);
        return;
    end

    if (castDefenseMatrixDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DefenseMatrix, castDefenseMatrixTarget);
        return;
    end

    if (castWarpFlareDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WarpFlare, castWarpFlareTarget);
        return;
    end

    if (castKeenConveyanceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(KeenConveyance, castKeenConveyanceLocation);
        return;
    end

    if (castRearmDesire ~= nil)
    then
        --npcBot:Action_ClearAction(false);
        npcBot:Action_UseAbility(Rearm);
        return;
    end
end

function ConsiderLaser()
    local ability = Laser;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local damageAbility = ability:GetSpecialValueInt("laser_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Laser что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                local enemyAttackTarget = enemy:GetAttackTarget();
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.IsHero(enemyAttackTarget)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderMarchOfTheMachines()
    local ability = MarchOfTheMachines;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Shrapnel по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderHeatSeekingMissile()
    local ability = HeatSeekingMissile;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
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
                    --npcBot:ActionImmediate_Chat("Использую HeatSeekingMissile что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot)
    then
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

function ConsiderDefenseMatrix()
    local ability = DefenseMatrix;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_tinker_defense_matrix")
            then
                if (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                    and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Использую DefenseMatrix для защиты союзника!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderWarpFlare()
    local ability = WarpFlare;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WarpFlare что бы сбить каст!", true);
                    return BOT_MODE_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 1)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WarpFlare против 2 по счёту врага рядом!", true);
                    return BOT_MODE_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_MODE_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderKeenConveyance()
    local ability = KeenConveyance;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local tps = npcBot:GetItemInSlot(15);
    if tps == nil or not tps:IsFullyCastable()
    then
        local tpLocation = nil;
        local shouldTP = false;

        shouldTP, tpLocation = teleportation_usage_generic.ShouldTP()

        if shouldTP
        then
            --npcBot:ActionImmediate_Chat("Использую KeenConveyance!", true);
            return BOT_ACTION_DESIRE_HIGH, tpLocation;
        end
    end
end

function ConsiderRearm()
    local ability = Rearm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local ability1 = npcBot:GetAbilityInSlot(0);
    local ability2 = npcBot:GetAbilityInSlot(1);

    -- General use
    if utility.PvPMode(npcBot)
    then
        if (not ability1:IsCooldownReady() and not ability2:IsCooldownReady())
            and (npcBot:GetMana() >= ability1:GetManaCost() + ability2:GetManaCost() + ability:GetManaCost())
        then
            --npcBot:ActionImmediate_Chat("Использую Rearm в бою!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    else
        if not KeenConveyance:IsCooldownReady() and (npcBot:GetMana() >= KeenConveyance:GetManaCost() + ability:GetManaCost())
        then
            --npcBot:ActionImmediate_Chat("Использую Rearm вне боя!", true);
            return BOT_ACTION_DESIRE_MODERATE;
        end
    end
end
