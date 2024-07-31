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
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
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
local BatteryAssault = AbilitiesReal[1]
local PowerCogs = AbilitiesReal[2]
local RocketFlare = AbilitiesReal[3]
local Overclocking = AbilitiesReal[4]
local Jetpack = AbilitiesReal[5]
local Hookshot = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBatteryAssaultDesire = ConsiderBatteryAssault();
    local castPowerCogsDesire = ConsiderPowerCogs();
    local castRocketFlareDesire, castRocketFlareLocation = ConsiderRocketFlare();
    local castOverclockingDesire = ConsiderOverclocking();
    local castJetpackDesire = ConsiderJetpack();
    local castHookshotDesire, castHookshotLocation = ConsiderHookshot();

    if (castBatteryAssaultDesire ~= nil)
    then
        npcBot:Action_UseAbility(BatteryAssault);
        return;
    end

    if (castPowerCogsDesire ~= nil)
    then
        npcBot:Action_UseAbility(PowerCogs);
        return;
    end

    if (castRocketFlareDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(RocketFlare, castRocketFlareLocation);
        return;
    end

    if (castOverclockingDesire ~= nil)
    then
        npcBot:Action_UseAbility(Overclocking);
        return;
    end

    if (castJetpackDesire ~= nil)
    then
        npcBot:Action_UseAbility(Jetpack);
        return;
    end

    if (castHookshotDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Hookshot, castHookshotLocation);
        return;
    end

    local mainCog = IsCogNeedsToBeBroken();
    if mainCog ~= nil
    then
        npcBot:ActionImmediate_Ping(mainCog.x, mainCog.y, false);
        npcBot:ActionImmediate_Chat("Ломаю Cog!", true);
        npcBot:Action_ClearActions(false);
        npcBot:Action_AttackUnit(mainCog, false);
        return;
    end
end

function IsCogNeedsToBeBroken()
    local mainCog = nil;
    local cogs = GetUnitList(UNIT_LIST_ALLIED_OTHER);
    local fountainLocation = utility.SafeLocation(npcBot);
    if (#cogs > 0)
    then
        for _, cog in pairs(cogs) do
            if cog:GetUnitName() == "npc_dota_rattletrap_cog" and not cog:IsInvulnerable()
            then
                if utility.IsValidTarget(botTarget)
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange() and GetUnitToUnitDistance(npcBot, cog) <= npcBot:GetAttackRange()
                    then
                        mainCog = cog;
                    end
                end
                if utility.RetreatMode(npcBot)
                then
                    if GetUnitToLocationDistance(cog, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        GetUnitToUnitDistance(npcBot, cog) <= npcBot:GetAttackRange()
                    then
                        mainCog = cog;
                    end
                end
            end
        end
    end

    return mainCog;
end

function ConsiderBatteryAssault()
    local ability = BatteryAssault;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_rattletrap_battery_assault")
    then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderPowerCogs()
    local ability = PowerCogs;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_rattletrap_cog_immune")
    then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local triggerRadius = ability:GetSpecialValueInt("trigger_distance");
    local fountainLocation = utility.SafeLocation(npcBot);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) < radiusAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility + triggerRadius, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if not utility.IsDisabled(enemy) and GetUnitToLocationDistance(enemy, fountainLocation) > GetUnitToLocationDistance(npcBot, fountainLocation)
                    and (GetUnitToUnitDistance(npcBot, enemy) > radiusAbility and GetUnitToUnitDistance(npcBot, enemy) <= radiusAbility + triggerRadius)
                then
                    --npcBot:ActionImmediate_Chat("Использую PowerCogs для отхода!", true);
                    return BOT_MODE_DESIRE_MODERATE;
                end
            end
        end
    end
end

function ConsiderRocketFlare()
    local ability = RocketFlare;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody/remove invisibility
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsInvisible()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую RocketFlare что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), 1600,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderOverclocking()
    local ability = Overclocking;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_rattletrap_overclocking")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
        then
            if (utility.IsAbilityAvailable(BatteryAssault) and npcBot:GetMana() >= ability:GetManaCost() + BatteryAssault:GetManaCost()) or
                (utility.IsAbilityAvailable(PowerCogs) and npcBot:GetMana() >= ability:GetManaCost() + PowerCogs:GetManaCost()) or
                (utility.IsAbilityAvailable(RocketFlare) and npcBot:GetMana() >= ability:GetManaCost() + RocketFlare:GetManaCost()) or
                (utility.IsAbilityAvailable(Jetpack) and npcBot:GetMana() >= ability:GetManaCost() + Jetpack:GetManaCost()) or
                (utility.IsAbilityAvailable(Hookshot) and npcBot:GetMana() >= ability:GetManaCost() + Hookshot:GetManaCost())
            then
                return BOT_ACTION_DESIRE_ABSOLUTE;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (utility.IsAbilityAvailable(Jetpack) and npcBot:GetMana() >= ability:GetManaCost() + Jetpack:GetManaCost())
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderJetpack()
    local ability = Jetpack;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_rattletrap_jetpack")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 4) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                --npcBot:ActionImmediate_Chat("Использую Jetpack для атаки!", true);
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderHookshot()
    local ability = Hookshot;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local abilityRadius = ability:GetSpecialValueInt("latch_radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local abilitySpeed = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / abilitySpeed));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    if not utility.IsAnyUnitsBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Hookshot что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                local targetDistance = GetUnitToUnitDistance(botTarget, npcBot)
                local moveDirection = botTarget:GetMovementDirectionStability();
                local targetLocation = botTarget:GetExtrapolatedLocation(delayAbility +
                    (targetDistance / abilitySpeed));
                if moveDirection < 0.95
                then
                    targetLocation = botTarget:GetLocation();
                end
                if not utility.IsAllyHeroesBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius) and
                    not utility.IsAllyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius) and
                    not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                end
            end
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local fountainLocation = utility.SafeLocation(npcBot);
            local allyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), false,
                BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(utility.GetCurretCastDistance(castRangeAbility), false);
            local enemyCreeps = npcBot:GetNearbyCreeps(utility.GetCurretCastDistance(castRangeAbility), true);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) >= castRangeAbility / 3)
                    then
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                            local moveDirection = enemy:GetMovementDirectionStability();
                            local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                                (targetDistance / abilitySpeed));
                            if moveDirection < 0.95
                            then
                                targetLocation = enemy:GetLocation();
                            end
                            if not utility.IsAnyUnitsBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                            then
                                --npcBot:ActionImmediate_Chat("Использую Hookshot для отхода по вражескому герою!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                            end
                        end
                    end
                end
            end
            if (#enemyCreeps > 0)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) >= castRangeAbility / 3)
                    then
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                            local moveDirection = enemy:GetMovementDirectionStability();
                            local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                                (targetDistance / abilitySpeed));
                            if moveDirection < 0.95
                            then
                                targetLocation = enemy:GetLocation();
                            end
                            if not utility.IsAnyUnitsBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                            then
                                --npcBot:ActionImmediate_Chat("Использую Hookshot для отхода по вражескому крипу!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                            end
                        end
                    end
                end
            end
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) >= castRangeAbility / 3)
                    then
                        if utility.CanCastSpellOnTarget(ability, ally)
                        then
                            local targetDistance = GetUnitToUnitDistance(ally, npcBot)
                            local moveDirection = ally:GetMovementDirectionStability();
                            local targetLocation = ally:GetExtrapolatedLocation(delayAbility +
                                (targetDistance / abilitySpeed));
                            if moveDirection < 0.95
                            then
                                targetLocation = ally:GetLocation();
                            end
                            if not utility.IsAnyUnitsBetweenMeAndTarget(npcBot, ally, targetLocation, abilityRadius)
                            then
                                --npcBot:ActionImmediate_Chat("Использую Hookshot для отхода по союзному герою!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                            end
                        end
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) >= castRangeAbility / 3)
                    then
                        if utility.CanCastSpellOnTarget(ability, ally)
                        then
                            local targetDistance = GetUnitToUnitDistance(ally, npcBot)
                            local moveDirection = ally:GetMovementDirectionStability();
                            local targetLocation = ally:GetExtrapolatedLocation(delayAbility +
                                (targetDistance / abilitySpeed));
                            if moveDirection < 0.95
                            then
                                targetLocation = ally:GetLocation();
                            end
                            if not utility.IsAnyUnitsBetweenMeAndTarget(npcBot, ally, targetLocation, abilityRadius)
                            then
                                --npcBot:ActionImmediate_Chat("Использую Hookshot для отхода по союзному крипу!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                            end
                        end
                    end
                end
            end
        end
    end
end
