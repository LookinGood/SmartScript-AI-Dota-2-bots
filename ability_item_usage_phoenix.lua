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
    Abilities[2],
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[2],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local IcarusDive = AbilitiesReal[1]
local IcarusDiveStop = npcBot:GetAbilityByName("phoenix_icarus_dive_stop");
local FireSpirits = AbilitiesReal[2]
local LaunchFireSpirit = npcBot:GetAbilityByName("phoenix_launch_fire_spirit");
local SunRay = AbilitiesReal[3]
local StopSunRay = npcBot:GetAbilityByName("phoenix_sun_ray_stop");
local ToggleMovement = npcBot:GetAbilityByName("phoenix_sun_ray_toggle_move");
local Supernova = AbilitiesReal[6]

local icarusDiveLocation = nil;
local launchFireSpiritTimer = 0.0;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castIcarusDiveDesire, castIcarusDiveLocation = ConsiderIcarusDive();
    local castIcarusDiveStopDesire = ConsiderIcarusDiveStop();
    local castFireSpiritsDesire = ConsiderFireSpirits();
    local castLaunchFireSpiritDesire, castLaunchFireSpiritLocation = ConsiderLaunchFireSpirit();
    local castSunRayDesire, castSunRayLocation = ConsiderSunRay();
    local castStopSunRayDesire = ConsiderStopSunRay();
    local castToggleMovementDesire = ConsiderToggleMovement();
    local castSupernovaDesire, castSupernovaTarget, castSupernovaTargetType = ConsiderSupernova();

    if (castIcarusDiveDesire ~= nil)
    then
        icarusDiveLocation = castIcarusDiveLocation;
        npcBot:Action_UseAbilityOnLocation(IcarusDive, castIcarusDiveLocation);
        return;
    end

    if (castIcarusDiveStopDesire ~= nil)
    then
        npcBot:Action_UseAbility(IcarusDiveStop);
        return;
    end

    if (castFireSpiritsDesire ~= nil)
    then
        npcBot:Action_UseAbility(FireSpirits);
        return;
    end

    if (castLaunchFireSpiritDesire ~= nil) and (DotaTime() >= launchFireSpiritTimer + 2.0)
    then
        npcBot:Action_UseAbilityOnLocation(LaunchFireSpirit, castLaunchFireSpiritLocation);
        launchFireSpiritTimer = DotaTime();
        return;
    end

    if (castSunRayDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SunRay, castSunRayLocation);
        return;
    end

    if (castStopSunRayDesire ~= nil)
    then
        npcBot:Action_UseAbility(StopSunRay);
        return;
    end

    if (castToggleMovementDesire ~= nil)
    then
        npcBot:Action_UseAbility(ToggleMovement);
        return;
    end

    if (castSupernovaDesire ~= nil)
    then
        if (castSupernovaTargetType == nil)
        then
            npcBot:Action_UseAbility(Supernova);
            return;
        elseif (castSupernovaTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Supernova, castSupernovaTarget);
            return;
        end
    end

    if npcBot:HasModifier("modifier_phoenix_sun_ray")
    then
        local delayAbility = SunRay:GetSpecialValueInt("AbilityCastPoint");
        if utility.IsValidTarget(botTarget)
        then
            npcBot:Action_ClearActions(false);
            npcBot:ActionPush_MoveToLocation(utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0));
            return;
        else
            local enemyAbility = npcBot:GetNearbyHeroes(SunRay:GetCastRange(), true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.IsValidTarget(enemy)
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:ActionPush_MoveToLocation(utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0));
                        return;
                    end
                end
            end
        end
    end
end

function ConsiderIcarusDive()
    local ability = IcarusDive;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_phoenix_sun_ray")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("dash_length");
    local radiusAbility = ability:GetSpecialValueInt("dash_width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (HealthPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (HealthPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderIcarusDiveStop()
    local ability = IcarusDiveStop;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if GetUnitToLocationDistance(npcBot, icarusDiveLocation) <= 200
        then
            --npcBot:ActionImmediate_Chat("Использую IcarusDiveStop!", true);
            return BOT_ACTION_DESIRE_MODERATE;
        end
    end

    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(500, true, BOT_MODE_NONE);
        if GetUnitToLocationDistance(npcBot, icarusDiveLocation) <= 200 and (#enemyAbility <= 0)
        then
            return BOT_ACTION_DESIRE_MODERATE;
        end
    end
end

function ConsiderFireSpirits()
    local ability = FireSpirits;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_phoenix_fire_spirit_count")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FireSpirit что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
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
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (HealthPercentage >= 0.7) and (ManaPercentage >= 0.5)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderLaunchFireSpirit()
    local ability = LaunchFireSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("duration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("spirit_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_phoenix_fire_spirit_burn")
                then
                    --npcBot:ActionImmediate_Chat("Использую LaunchFireSpirit что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                if not botTarget:HasModifier("modifier_phoenix_fire_spirit_burn")
                then
                    --npcBot:ActionImmediate_Chat("Использую LaunchFireSpirit по основной цели!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                else
                    if (#enemyAbility > 1)
                    then
                        for _, enemy in pairs(enemyAbility) do
                            if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_phoenix_fire_spirit_burn")
                            then
                                --npcBot:ActionImmediate_Chat("Использую LaunchFireSpirit по 2 цели!", true);
                                return BOT_ACTION_DESIRE_HIGH,
                                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                            end
                        end
                    end
                end
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
                    and not enemy:HasModifier("modifier_phoenix_fire_spirit_burn")
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (HealthPercentage >= 0.7) and (ManaPercentage >= 0.5)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end
end

function ConsiderSunRay()
    local ability = SunRay;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_phoenix_sun_ray")
    then
        return;
    end

    local castRangeAbility = npcBot:GetAttackRange() + 200;
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end
end

function ConsiderStopSunRay()
    local ability = StopSunRay;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not npcBot:HasModifier("modifier_phoenix_sun_ray")
    then
        return;
    end

    local castRangeAbility = SunRay:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if utility.RetreatMode(npcBot) or GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility or (#enemyAbility <= 0)
    then
        --npcBot:ActionImmediate_Chat("Выключаю SunRay!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderToggleMovement()
    local ability = ToggleMovement;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not npcBot:HasModifier("modifier_phoenix_sun_ray") or npcBot:IsAlive()
    then
        return;
    end
end

function ConsiderSupernova()
    local ability = Supernova;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_phoenix_sun")
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("cast_range_tooltip_scepter");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Use in teamfight
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility >= 2)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Supernova1 по 2+ врагам!", true);
                        return BOT_ACTION_DESIRE_HIGH, nil;
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Supernova2 по 2+ врагам!", true);
                        return BOT_ACTION_DESIRE_HIGH, npcBot, "target";
                    end
                end
            end
        end
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        if (HealthPercentage <= 0.3) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0))
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
                if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.3)
                    and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую Supernova на  " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally, "target";
                end
            end
        end
    end
end
