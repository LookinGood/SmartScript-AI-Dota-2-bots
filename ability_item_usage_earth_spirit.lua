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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
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
local BoulderSmash = AbilitiesReal[1]
local RollingBoulder = AbilitiesReal[2]
local GeomagneticGrip = AbilitiesReal[3]
local StoneRemnant = AbilitiesReal[4]
local EnchantRemnant = AbilitiesReal[5]
local Magnetize = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBoulderSmashDesire, castBoulderSmashLocation, castBoulderSmashRemnant = ConsiderBoulderSmash();
    local castRollingBoulderDesire, castRollingBoulderLocation, castRollingBoulderRemnant, castRollingBoulderRemnantLocation =
        ConsiderRollingBoulder();
    local castGeomagneticGripDesire, castGeomagneticGripLocation, castGeomagneticGripRemnant, castGeomagneticGripRemnantLocation =
        ConsiderGeomagneticGrip();
    --local castStoneRemnantDesire, castStoneRemnantLocation = ConsiderStoneRemnant();
    local castEnchantRemnantDesire, castEnchantRemnantTarget = ConsiderEnchantRemnant();
    local castMagnetizeDesire, castMagnetizeRemnant, castMagnetizeRemnantLocation = ConsiderMagnetize();

    stoneRemnantRange = StoneRemnant:GetCastRange();

    if (castBoulderSmashDesire > 0)
    then
        if (castBoulderSmashRemnant == true)
        then
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_UseAbilityOnLocation(StoneRemnant, npcBot:GetLocation());
            npcBot:ActionQueue_UseAbilityOnLocation(BoulderSmash, castBoulderSmashLocation);
            return;
        else
            npcBot:Action_UseAbilityOnLocation(BoulderSmash, castBoulderSmashLocation);
            return;
        end
    end

    if (castRollingBoulderDesire > 0)
    then
        if (castRollingBoulderRemnant == true)
        then
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_UseAbilityOnLocation(StoneRemnant, castRollingBoulderRemnantLocation);
            npcBot:ActionQueue_UseAbilityOnLocation(RollingBoulder, castRollingBoulderLocation);
            return;
        else
            npcBot:Action_UseAbilityOnLocation(RollingBoulder, castRollingBoulderLocation);
            return;
        end
    end

    if (castGeomagneticGripDesire > 0)
    then
        if (castGeomagneticGripRemnant == true)
        then
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_UseAbilityOnLocation(StoneRemnant, castGeomagneticGripRemnantLocation);
            npcBot:ActionQueue_UseAbilityOnLocation(GeomagneticGrip, castGeomagneticGripLocation);
            return;
        else
            npcBot:Action_UseAbilityOnLocation(GeomagneticGrip, castGeomagneticGripLocation);
            return;
        end
    end

    if (castEnchantRemnantDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(EnchantRemnant, castEnchantRemnantTarget);
        return;
    end

    if (castMagnetizeDesire > 0)
    then
        if (castMagnetizeRemnant == true)
        then
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_UseAbilityOnLocation(StoneRemnant, castMagnetizeRemnantLocation);
            npcBot:ActionQueue_UseAbility(Magnetize);
            return;
        else
            npcBot:Action_UseAbility(Magnetize);
            return;
        end
    end
end

function IsStoneRemnantReady()
    return utility.IsAbilityAvailable(StoneRemnant)
end

function ConsiderBoulderSmash()
    local ability = BoulderSmash;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("unit_distance");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("rock_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local unitSearchRaduis = ability:GetSpecialValueInt("rock_search_aoe");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
    local enemyHeroesNearby = npcBot:GetNearbyHeroes(unitSearchRaduis, true, BOT_MODE_NONE);
    local enemyCreepsNearby = npcBot:GetNearbyCreeps(unitSearchRaduis, true);
    local allyCreepsNearby = npcBot:GetNearbyCreeps(unitSearchRaduis, false);
    local remnantCount = utility.CountUnitAroundTarget(npcBot, "npc_dota_earth_spirit_stone", false, unitSearchRaduis);
    local countUnitsAround = #enemyHeroesNearby + #enemyCreepsNearby + #allyCreepsNearby;

    --print("Копий рядом: " .. remnantCount)

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, enemy) <= stoneRemnantRange and remnantCount <= 0
                    then
                        --npcBot:ActionImmediate_Chat("Использую BoulderSmash(Статуя) что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), true;
                    else
                        if (countUnitsAround > 0)
                        then
                            --npcBot:ActionImmediate_Chat("Использую BoulderSmash(БезСтатуи) что бы добить " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE,
                                utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), false;
                        end
                    end
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
            then
                if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, botTarget) <= stoneRemnantRange and remnantCount <= 0
                then
                    --npcBot:ActionImmediate_Chat("Использую BoulderSmash(Статуя) для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), true;
                else
                    if (countUnitsAround > 0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BoulderSmash(БезСтатуи) для атаки! ", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), false;
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyHeroesNearby > 0)
        then
            for _, enemy in pairs(enemyHeroesNearby) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BoulderSmash для отхода! ", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), false;
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3) and (countUnitsAround > 0 or remnantCount > 0)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, false;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end

function ConsiderRollingBoulder()
    local ability = RollingBoulder;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0, 0;
    end

    local minCastRange = ability:GetSpecialValueInt("distance");
    local maxCastRange = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(minCastRange, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, enemy) <= stoneRemnantRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую RollingBoulder(Статуя) что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), true,
                            utility.GetMaxRangeCastLocation(npcBot, enemy, radiusAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую RollingBoulder(БезСтатуи) что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), false, nil;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
                and not utility.IsDisabled(botTarget)
            then
                if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, botTarget) <= stoneRemnantRange
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) <= maxCastRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую RollingBoulder(Статуя) для атаки!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), true,
                            utility.GetMaxRangeCastLocation(npcBot, botTarget, radiusAbility);
                    end
                else
                    if GetUnitToUnitDistance(npcBot, botTarget) <= minCastRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую RollingBoulder(БезСтатуи) для атаки!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), false, nil;
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= minCastRange
        then
            if (#enemyAbility > 0)
            then
                if IsStoneRemnantReady()
                then
                    --npcBot:ActionImmediate_Chat("Использую RollingBoulder(Статуя) для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, minCastRange), true,
                        utility.GetEscapeLocation(npcBot, minCastRange - 200);
                else
                    --npcBot:ActionImmediate_Chat("Использую RollingBoulder(БезСтатуи) для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, minCastRange), false, nil;
                end
            else
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, minCastRange), false, nil;
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot) and (#enemyAbility <= 0)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), minCastRange, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, false, nil;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0, 0;
end

function ConsiderGeomagneticGrip()
    local ability = GeomagneticGrip;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("rock_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, enemy) <= stoneRemnantRange
                    then
                        --npcBot:ActionImmediate_Chat("Использую GeomagneticGrip(Статуя) что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), true,
                            enemy:GetLocation();
                    else
                        local remnantCount = utility.CountUnitAroundTarget(enemy, "npc_dota_earth_spirit_stone", false,
                            radiusAbility);
                        if (remnantCount > 0)
                        then
                            --npcBot:ActionImmediate_Chat("Использую GeomagneticGrip(БезСтатуи) что бы добить " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE,
                                utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), false, nil;
                        end
                    end
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
                and not utility.IsDisabled(botTarget)
            then
                if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, botTarget) <= stoneRemnantRange
                then
                    --npcBot:ActionImmediate_Chat("Использую GeomagneticGrip(Статуя) для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), true,
                        botTarget:GetLocation();
                else
                    local remnantCount = utility.CountUnitAroundTarget(botTarget, "npc_dota_earth_spirit_stone", false,
                        radiusAbility);
                    --print("Копий рядом(враг): " .. remnantCount)
                    if (remnantCount > 0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую GeomagneticGrip(БезСтатуи) для атаки!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), false, nil;
                    end
                end
            end
        end
    end

    -- Try to safe ally
    if utility.CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES)
    then
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and ally ~= npcBot and not ally:IsChanneling()
                then
                    if ally:GetHealth() / ally:GetMaxHealth() <= 0.5 and (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2) and
                        ally:DistanceFromFountain() > npcBot:DistanceFromFountain() and
                        (ally:WasRecentlyDamagedByAnyHero(2.0) or
                            ally:WasRecentlyDamagedByCreep(2.0) or
                            ally:WasRecentlyDamagedByTower(2.0))
                    then
                        npcBot:ActionImmediate_Chat("Использую GeomagneticGrip на союзника!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally:GetLocation(), false, nil;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0, 0;
end

function ConsiderEnchantRemnant()
    local ability = EnchantRemnant;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local castRangeAlly = ability:GetSpecialValueInt("ally_cast_range");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAlly + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую EnchantRemnant сбивая каст " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Cast to safe ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility) do
            if not ally:IsChanneling()
            then
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    for _, spell in pairs(incomingSpells)
                    do
                        if GetUnitToLocationDistance(ally, spell.location) <= 400 and spell.is_attack == false
                        then
                            --npcBot:ActionImmediate_Chat("Использую EnchantRemnant сбивая снаряд на " .. ally:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, ally;
                        end
                    end
                end
            end
            -- Try to hide ally
            if utility.IsUnitNeedToHide(ally)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, ally;
            end
            -- Cast if ally attacked and low HP
            if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.3) and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую EnchantRemnant на союзного героя со здоровьем ниже 30%!", true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end

    -- Cast on second enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (#enemyAbility > 1)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and enemy ~= botTarget
                    then
                        --npcBot:ActionImmediate_Chat("Использую EnchantRemnant на 2 врага " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
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
                    --npcBot:ActionImmediate_Chat("Использую EnchantRemnant отступая от " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMagnetize()
    local ability = Magnetize;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local radiusAbility = ability:GetSpecialValueInt("cast_radius");
    local damageAbility = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("damage_duration");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_earth_spirit_magnetize")
                then
                    --npcBot:ActionImmediate_Chat("Использую Magnetize что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, false, nil;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                if IsStoneRemnantReady() and GetUnitToUnitDistance(npcBot, botTarget) <= stoneRemnantRange
                then
                    --npcBot:ActionImmediate_Chat("Использую Magnetize(Статуя) для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH, true, botTarget:GetLocation();
                else
                    --npcBot:ActionImmediate_Chat("Использую Magnetize(БезСтатуи) для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH, false, nil;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end
