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
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Flux = AbilitiesReal[1]
local MagneticField = AbilitiesReal[2]
local SparkWraith = AbilitiesReal[3]
local TempestDouble = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botTeam = npcBot:GetTeam();
    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFluxDesire, castFluxTarget = ConsiderFlux();
    local castMagneticFieldDesire = ConsiderMagneticField();
    local castSparkWraithDesire, castSparkWraithLocation = ConsiderSparkWraith();
    local castTempestDoubleDesire, castTempestDoubleLocation = ConsiderTempestDouble();

    if castFluxDesire == nil then castFluxDesire = BOT_ACTION_DESIRE_NONE end;
    if castMagneticFieldDesire == nil then castMagneticFieldDesire = BOT_ACTION_DESIRE_NONE end;
    if castSparkWraithDesire == nil then castSparkWraithDesire = BOT_ACTION_DESIRE_NONE end;
    if castTempestDoubleDesire == nil then castTempestDoubleDesire = BOT_ACTION_DESIRE_NONE end;

    if (castFluxDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castFluxDesire > castMagneticFieldDesire and castSparkWraithDesire and castTempestDoubleDesire)
        then
            npcBot:Action_UseAbilityOnEntity(Flux, castFluxTarget);
            return;
        end
    end

    if (castMagneticFieldDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castMagneticFieldDesire > castFluxDesire and castSparkWraithDesire and castTempestDoubleDesire)
        then
            npcBot:Action_UseAbility(MagneticField);
            return;
        end
    end

    if (castSparkWraithDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castSparkWraithDesire > castFluxDesire and castMagneticFieldDesire and castTempestDoubleDesire)
        then
            npcBot:Action_UseAbilityOnLocation(SparkWraith, castSparkWraithLocation);
            return;
        end
    end

    if (castTempestDoubleDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castTempestDoubleDesire > castFluxDesire and castMagneticFieldDesire and castSparkWraithDesire)
        then
            npcBot:Action_UseAbilityOnLocation(TempestDouble, castTempestDoubleLocation);
            return;
        end
    end
end

function ConsiderFlux()
    local ability = Flux;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility;
    if botTeam == TEAM_RADIANT
    then
        damageAbility = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("duration");
    elseif botTeam == TEAM_DIRE
    then
        damageAbility = ability:GetSpecialValueInt("tempest_damage_per_second") * ability:GetSpecialValueInt("duration");
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local searchRadius = ability:GetSpecialValueInt("search_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local allyAround = enemy:GetNearbyHeroes(searchRadius, false, BOT_MODE_DESIRE_NONE);
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and (#allyAround <= 1)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Flux что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        local allyAround = enemy:GetNearbyHeroes(searchRadius, false, BOT_MODE_DESIRE_NONE);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7) and (#allyAround <= 1)
        then
            return BOT_ACTION_DESIRE_MODERATE, enemy;
        end
    end
end

function ConsiderMagneticField()
    local ability = MagneticField;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        -- Attack use
        if botMode ~= BOT_MODE_LANING
        then
            for _, ally in pairs(allyAbility)
            do
                local attackTarget = ally:GetAttackTarget();
                if utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)
                then
                    if utility.IsHero(ally) and not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
                    then
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
        -- Buff allies
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSparkWraith()
    local ability = SparkWraith;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility;
    if botTeam == TEAM_RADIANT
    then
        damageAbility = ability:GetSpecialValueInt("spark_damage_base");
    elseif botTeam == TEAM_DIRE
    then
        damageAbility = ability:GetSpecialValueInt("spark_damage_tempest");
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SparkWraith что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
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
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility and not utility.IsDisabled(enemy)
                then
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                    then
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            return BOT_ACTION_DESIRE_HIGH,
                                utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                        end
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count > 0)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderTempestDouble()
    local ability = TempestDouble;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + attackRange)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую TempestDouble в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + attackRange
                then
                    --npcBot:ActionImmediate_Chat("Использую TempestDouble в касте+радиусе!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        local allyAbility = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
        if (#enemyAbility > 0 and #enemyAbility <= 2) or (#enemyAbility > 0 and #allyAbility > 1)
        then
            return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation() + RandomVector(castRangeAbility);
        end
    end

    -- Use when attack building
    if utility.IsBuilding(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3)
        then
            return BOT_ACTION_DESIRE_MODERATE, attackTarget:GetLocation() + RandomVector(castRangeAbility);
        end
    end
end

--[[ function ConsiderMagneticField() --- СТАРАЯ ВЕРСИЯ по области
    local ability = MagneticField;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        -- Attack use
        if botMode ~= BOT_MODE_LANING
        then
            for _, ally in pairs(allyAbility)
            do
                local attackTarget = ally:GetAttackTarget();
                if utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)
                then
                    if utility.IsHero(ally) and not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
                    then
                        if GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую MagneticField в радиусе каста для атаки!", true);
                            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                        elseif GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility + radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую MagneticField в касте+радиусе для атаки!", true);
                            return BOT_ACTION_DESIRE_HIGH,
                                utility.GetMaxRangeCastLocation(npcBot, ally, castRangeAbility);
                        end
                    end
                end
            end
        end
        -- Buff allies
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    if GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую MagneticField в радиусе каста для защиты!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую MagneticField в касте+радиусе для защиты!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetMaxRangeCastLocation(npcBot, ally, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Cast to buff ally buildings
    if botTeam == TEAM_RADIANT and not utility.PvPMode(npcBot)
    then
        local allyTowers = npcBot:GetNearbyTowers(1600, false);
        local allyBarracks = npcBot:GetNearbyBarracks(1600, false);
        local allyAncient = GetAncient(GetTeam());
        if (#allyTowers > 0)
        then
            for _, ally in pairs(allyTowers)
            do
                if not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") and utility.IsTargetedByEnemy(ally, true)
                then
                    if GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую MagneticField в радиусе каста на башню!", true);
                        return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую MagneticField в касте+радиусе на башню!", true);
                        return BOT_ACTION_DESIRE_MODERATE,
                            utility.GetMaxRangeCastLocation(npcBot, ally, castRangeAbility);
                    end
                end
            end
        end
        if (#allyBarracks > 0)
        then
            for _, ally in pairs(allyBarracks)
            do
                if not ally:HasModifier("modifier_arc_warden_magnetic_field_attack_speed") and utility.IsTargetedByEnemy(ally, true)
                then
                    if GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        npcBot:ActionImmediate_Chat("Использую MagneticField в радиусе каста на барраки!", true);
                        return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility + radiusAbility
                    then
                        npcBot:ActionImmediate_Chat("Использую MagneticField в касте+радиусе на барраки!", true);
                        return BOT_ACTION_DESIRE_MODERATE,
                            utility.GetMaxRangeCastLocation(npcBot, ally, castRangeAbility);
                    end
                end
            end
        end
        if utility.IsTargetedByEnemy(allyAncient, true) and npcBot:DistanceFromFountain() <= 3000
        then
            if GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility
                and not allyAncient:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
            then
                --npcBot:ActionImmediate_Chat("Использую MagneticField в радиусе каста на ДРЕВНЕГО!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, allyAncient, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility + radiusAbility
                and not allyAncient:HasModifier("modifier_arc_warden_magnetic_field_attack_speed")
            then
                --npcBot:ActionImmediate_Chat("Использую MagneticField в касте+радиусе на ДРЕВНЕГО!", true);
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetMaxRangeCastLocation(npcBot, allyAncient, castRangeAbility);
            end
        end
    end
end ]]







--[[             for _, enemy in pairs(enemyAbility) do
                if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + attackRange
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                end
            end ]]


--[[             if (castMagneticFieldDesire ~= nil)
            then
                npcBot:Action_UseAbilityOnLocation(MagneticField, castMagneticFieldLocation);
                return;
            end

            if (castSparkWraithDesire ~= nil)
            then
                npcBot:Action_UseAbilityOnLocation(SparkWraith, castSparkWraithLocation);
                return;
            end

            if (castTempestDoubleDesire ~= nil)
            then
                npcBot:Action_UseAbilityOnLocation(TempestDouble, castTempestDoubleLocation);
                return;
            end ]]
