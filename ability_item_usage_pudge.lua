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
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local MeatHook = AbilitiesReal[1]
local Rot = AbilitiesReal[2]
local FleshHeap = AbilitiesReal[3]
local Eject = AbilitiesReal[4]
local Dismember = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castMeatHookDesire, castMeatHookLocation = ConsiderMeatHook();
    local castRotDesire = ConsiderRot();
    local castFleshHeapDesire = ConsiderFleshHeap();
    local castEjectDesire = ConsiderEject();
    local castDismemberDesire, castDismemberTarget = ConsiderDismember();

    if (castMeatHookDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MeatHook, castMeatHookLocation);
        return;
    end

    if (castRotDesire ~= nil)
    then
        npcBot:Action_UseAbility(Rot);
        return;
    end

    if (castFleshHeapDesire ~= nil)
    then
        npcBot:Action_UseAbility(FleshHeap);
        return;
    end

    if (castEjectDesire ~= nil)
    then
        npcBot:Action_UseAbility(Eject);
        return;
    end

    if (castDismemberDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Dismember, castDismemberTarget);
        return;
    end
end

function ConsiderMeatHook()
    local ability = MeatHook;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local abilityRadius = ability:GetSpecialValueInt("hook_width");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local abilitySpeed = ability:GetSpecialValueInt("hook_speed");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
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
                        --npcBot:ActionImmediate_Chat("Использую MeatHook что бы убить цель!", true);
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
                    not IsAllyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius) and
                    not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius)
                then
                    --npcBot:ActionImmediate_Chat("Использую MeatHook для атаки!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.6)
        then
            local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
            local moveDirection = enemy:GetMovementDirectionStability();
            local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                (targetDistance / abilitySpeed));
            if moveDirection < 0.95
            then
                targetLocation = enemy:GetLocation();
            end
            if not utility.IsAllyHeroesBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius) and
                not IsAllyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius) and
                not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
            then
                --npcBot:ActionImmediate_Chat("Использую MeatHook на лайне по врагу!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
            end
        end
    end

    -- Try to safe ally
    if not utility.RetreatMode(npcBot) and (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally ~= npcBot
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.5 and (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2) and
                    ally:DistanceFromFountain() > npcBot:DistanceFromFountain() and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
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
                        --npcBot:ActionImmediate_Chat("Использую MeatHook на союзного героя!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                    end
                end
            end
        end
    end
end

function ConsiderRot()
    local ability = Rot;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility
    if not npcBot:HasScepter()
    then
        radiusAbility = ability:GetSpecialValueInt("rot_radius");
    else
        radiusAbility = ability:GetSpecialValueInt("rot_radius") + ability:GetSpecialValueInt("scepter_rot_radius_bonus")
    end

    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if ability:GetToggleState() == false
                    then
                        --npcBot:ActionImmediate_Chat("Включаю Rot против 2+ врагов!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                else
                    if ability:GetToggleState() == true
                    then
                        --npcBot:ActionImmediate_Chat("Выключаю Rot против 2+ врагов!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю Rot если врагов нет!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage >= 0.1) and (#enemyAbility > 0)
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю Rot для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю Rot для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Try to self-denyi
--[[         if (HealthPercentage < 0.1) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю Rot что бы задинать себя!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю Rot что бы задинать себя!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end ]]
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (HealthPercentage >= 0.2) and (#enemyCreeps > 1)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if ability:GetToggleState() == false
                    then
                        --npcBot:ActionImmediate_Chat("Включаю Rot для крипов!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                else
                    if ability:GetToggleState() == true
                    then
                        --npcBot:ActionImmediate_Chat("Выключаю Rot для имунных крипов!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю Rot для крипов!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю Rot!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderFleshHeap()
    local ability = FleshHeap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_pudge_flesh_heap_block")
    then
        return;
    end

    -- General use
    if (HealthPercentage <= 0.8) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or
            npcBot:WasRecentlyDamagedByCreep(2.0) or
            npcBot:WasRecentlyDamagedByTower(2.0))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderEject()
    local ability = Eject;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Use if swallowed hero have full HP
    for _, ally in pairs(allyHeroes) do
        if ally:HasModifier("modifier_pudge_swallow_hide") and ally:GetHealth() >= ally:GetMaxHealth()
        then
            npcBot:ActionImmediate_Chat("Использую Eject на вылеченного героя!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderDismember()
    local ability = Dismember;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local damageAbility = ability:GetSpecialValueInt("dismember_damage") * ability:GetSpecialValueInt("ticks");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Dismember что бы сбить заклинание или убить цель!",true);
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
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Try to safe ally
    if utility.CheckFlag(ability:GetTargetFlags(), ABILITY_TARGET_FLAG_NOT_MAGIC_IMMUNE_ALLIES)
    then
        -- General use on allied heroes
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility)
            do
                if ally ~= npcBot and utility.IsHero(ally) and not ally:IsChanneling()
                then
                    if (ally:GetHealth() / ally:GetMaxHealth() <= 0.5) and not ally:HasModifier("modifier_pudge_swallow_hide")
                        and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                    then
                        npcBot:ActionImmediate_Chat("Использую Dismember на союзника!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
end
