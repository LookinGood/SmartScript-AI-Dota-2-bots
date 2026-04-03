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
    Abilities[3],
    Abilities[2],
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
local Laser = npcBot:GetAbilityByName("tinker_laser");
local HeatSeekingMissile = npcBot:GetAbilityByName("tinker_heat_seeking_missile");
local MarchOfTheMachines = npcBot:GetAbilityByName("tinker_march_of_the_machines");
local DefenseMatrix = npcBot:GetAbilityByName("tinker_defense_matrix");
local DeployTurrets = npcBot:GetAbilityByName("tinker_deploy_turrets");
local WarpFlare = npcBot:GetAbilityByName("tinker_warp_grenade");
local KeenConveyance = npcBot:GetAbilityByName("tinker_keen_teleport");
local Rearm = npcBot:GetAbilityByName("tinker_rearm");

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
    local castDeployTurretsDesire, castDeployTurretsLocation = ConsiderDeployTurrets();
    local castWarpFlareDesire, castWarpFlareTarget = ConsiderWarpFlare();
    local castKeenConveyanceDesire, castKeenConveyanceLocation = ConsiderKeenConveyance();
    local castRearmDesire = ConsiderRearm();

    if (castLaserDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Laser, castLaserTarget);
        return;
    end

    if (castMarchOfTheMachinesDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(MarchOfTheMachines, castMarchOfTheMachinesLocation);
        return;
    end

    if (castHeatSeekingMissileDesire > 0)
    then
        npcBot:Action_UseAbility(HeatSeekingMissile);
        return;
    end

    if (castDefenseMatrixDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(DefenseMatrix, castDefenseMatrixTarget);
        return;
    end

    if (castDeployTurretsDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(DeployTurrets, castDeployTurretsLocation);
        return;
    end

    if (castWarpFlareDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(WarpFlare, castWarpFlareTarget);
        return;
    end

    if (castKeenConveyanceDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(KeenConveyance, castKeenConveyanceLocation);
        return;
    end

    if (castRearmDesire > 0)
    then
        npcBot:Action_ClearAction(true);
        npcBot:ActionQueue_UseAbility(Rearm);
        return;
    end
end

function ConsiderLaser()
    local ability = Laser;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMarchOfTheMachines()
    local ability = MarchOfTheMachines;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
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
            --npcBot:ActionImmediate_Chat("Использую MarchOfTheMachines по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderHeatSeekingMissile()
    local ability = HeatSeekingMissile;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
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

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDefenseMatrix()
    local ability = DefenseMatrix;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWarpFlare()
    local ability = WarpFlare;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDeployTurrets()
    local ability = DeployTurrets;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("drop_aoe_radius");
    local damageAbility = ability:GetSpecialValueInt("drop_damage");
    local turretsAttackRange = ability:GetSpecialValueInt("missile_target_range");
    local delayAbility = ability:GetSpecialValueInt("drop_delay");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую DeployTurrets в радиусе каста добивая!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую DeployTurrets в касте+радиусе добивая!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
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
                --npcBot:ActionImmediate_Chat("Использую DeployTurrets на врага в радиусе каста!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + turretsAttackRange
            then
                --npcBot:ActionImmediate_Chat("Использую DeployTurrets на врага в радиусе атаки варда!",true);
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
                        --npcBot:ActionImmediate_Chat("Использую DeployTurrets в радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую DeployTurrets в касте+радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderKeenConveyance()
    local ability = KeenConveyance;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local tpLocation = nil;
    local shouldTP = false;

    shouldTP, tpLocation = teleportation_usage_generic.ShouldTP()

    if shouldTP
    then
        --npcBot:ActionImmediate_Chat("Использую KeenConveyance!", true);
        return BOT_ACTION_DESIRE_HIGH, tpLocation;
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderRearm()
    local ability = Rearm;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local ability1 = npcBot:GetAbilityInSlot(0);
    local ability2 = npcBot:GetAbilityInSlot(1);
    local ability3 = npcBot:GetAbilityInSlot(2);

    -- General use
    if utility.PvPMode(npcBot)
    then
        if (not ability1:IsCooldownReady() and not ability2:IsCooldownReady() and not ability3:IsCooldownReady())
            and (npcBot:GetMana() >= ability:GetManaCost() + ability1:GetManaCost() + ability2:GetManaCost() + ability3:GetManaCost())
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

    return BOT_ACTION_DESIRE_NONE;
end
