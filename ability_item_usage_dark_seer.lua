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
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Vacuum = AbilitiesReal[1]
local IonShell = AbilitiesReal[2]
local Surge = AbilitiesReal[3]
local WallOfReplica = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castVacuumDesire, castVacuumLocation = ConsiderVacuum();
    local castIonShellDesire, castIonShellTarget = ConsiderIonShell();
    local castSurgeDesire, castSurgeTarget = ConsiderSurge();
    local castWallOfReplicaDesire, castWallOfReplicaLocation = ConsiderWallOfReplica();

    if (castVacuumDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Vacuum, castVacuumLocation);
        return;
    end

    if (castIonShellDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(IonShell, castIonShellTarget);
        return;
    end

    if (castSurgeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Surge, castSurgeTarget);
        return;
    end

    if (castWallOfReplicaDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WallOfReplica, castWallOfReplicaLocation);
        return;
    end
end

function ConsiderVacuum()
    local ability = Vacuum;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

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
                        --npcBot:ActionImmediate_Chat("Использую Vacuum сбивая каст в радиусе каста!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + (radiusAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Vacuum сбивая каст в радиусе каста+радиус!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Vacuum для атаки в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + (radiusAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую Vacuum для атаки в радиусе каста+радиус!",true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
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
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Vacuum на ЛАЙНЕ в радиусе каста!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + (radiusAbility / 2)
            then
                --npcBot:ActionImmediate_Chat("Использую Vacuum на ЛАЙНЕ в радиусе каста+радиус!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
            end
        end
    end
end

function ConsiderIonShell()
    local ability = IonShell;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and not ally:HasModifier("modifier_dark_seer_ion_shell")
                then
                    local enemyHeroes = ally:GetNearbyHeroes(radiusAbility * 2, true, BOT_MODE_NONE);
                    if (#enemyHeroes > 0)
                    then
                        for _, enemy in pairs(enemyHeroes) do
                            if utility.CanCastSpellOnTarget(ability, enemy)
                            then
                                --npcBot:ActionImmediate_Chat("Использую IonShell для атаки на союзника!", true);
                                return BOT_MODE_DESIRE_HIGH, ally;
                            end
                        end
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not npcBot:HasModifier("modifier_dark_seer_ion_shell")
                then
                    --npcBot:ActionImmediate_Chat("Использую IonShell для фарма рядом с вражескими крипами!",true);
                    return BOT_ACTION_DESIRE_HIGH, npcBot;
                end
            end
        end
        local allyCreeps = npcBot:GetNearbyCreeps(radiusAbility, false);
        if (#allyCreeps > 0) and (ManaPercentage >= 0.5)
        then
            for _, ally in pairs(allyCreeps) do
                if utility.IsValidTarget(ally) and (ally:GetHealth() / ally:GetMaxHealth() >= 0.8)
                    and not ally:HasModifier("modifier_dark_seer_ion_shell")
                then
                    --npcBot:ActionImmediate_Chat("Использую IonShell на союзного крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                    if (#enemyCreepsAround > 0)
                    then
                        for _, enemy in pairs(enemyCreepsAround) do
                            if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                                and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.8) and not enemy:HasModifier("modifier_dark_seer_ion_shell")
                            then
                                --npcBot:ActionImmediate_Chat("Использую IonShell на вражеского крипа рядом с врагом на лайне!", true);
                                return BOT_ACTION_DESIRE_HIGH, enemy;
                            end
                        end
                    end
                end
            end
        end
    end
end

function ConsiderSurge()
    local ability = Surge;
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
            if utility.IsHero(ally) and not utility.IsHaveMaxSpeed(ally) and not utility.IsDisabled(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.8
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(5.0) or
                    ally:WasRecentlyDamagedByTower(2.0) or
                    (utility.IsHero(ally:GetAttackTarget()) and GetUnitToUnitDistance(ally, ally:GetAttackTarget()) > (ally:GetAttackRange()))
                then
                    --npcBot:ActionImmediate_Chat("Использую Surge как баф на союзника!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if not utility.IsHaveMaxSpeed(ally) and not utility.IsDisabled(ally)
                    then
                        if utility.IsHero(ally) and GetUnitToUnitDistance(ally, botTarget) > ally:GetAttackRange()
                        then
                            --npcBot:ActionImmediate_Chat("Использую Surge на атакующего союзника!",true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end
        -- Cast if need retreat
    elseif utility.RetreatMode(npcBot) or botMode == BOT_MODE_WARD or botMode == BOT_MODE_RUNE
    then
        if not utility.IsHaveMaxSpeed(npcBot) and npcBot:DistanceFromFountain() > (npcBot:GetAttackRange() * 2)
        then
            return BOT_ACTION_DESIRE_HIGH, npcBot;
        end
    end
end

function ConsiderWallOfReplica()
    local ability = WallOfReplica;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.3)
            then
                --npcBot:ActionImmediate_Chat("Использую WallOfReplica по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую WallOfReplica по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
