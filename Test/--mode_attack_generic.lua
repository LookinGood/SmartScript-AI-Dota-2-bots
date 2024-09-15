---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local combatZoneRadius = 3000;

local function GetBotSecondTarget()
    local botSecondTarget = nil;
    local botTarget = npcBot:GetTarget();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if enemy:CanBeSeen() and not enemy:IsInvulnerable() and not utility.IsNotAttackTarget(enemy) and enemy ~= botTarget
            then
                botSecondTarget = enemy;
                return botSecondTarget;
            end
        end
    end
    if (#enemyCreeps > 0)
    then
        for _, enemy in pairs(enemyCreeps) do
            if enemy:CanBeSeen() and not enemy:IsInvulnerable() and not utility.IsNotAttackTarget(enemy) and enemy ~= botTarget
            then
                botSecondTarget = enemy;
                return botSecondTarget;
            end
        end
    end

    return botSecondTarget;
end

local function IsWeAreStronger(combatZoneRadius)
    local allyPower = 0;
    local enemyPower = 0;
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if utility.IsValidTarget(enemy)
            then
                if GetUnitToUnitDistance(npcBot, enemy) <= combatZoneRadius
                then
                    local enemyOffensivePower = enemy:GetRawOffensivePower();
                    enemyPower = enemyPower + enemyOffensivePower;
                end
            end
        end
    end

    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes) do
            if utility.IsValidTarget(ally)
            then
                if GetUnitToUnitDistance(npcBot, ally) <= combatZoneRadius
                then
                    local allyOffensivePower = ally:GetOffensivePower();
                    allyPower = allyPower + allyOffensivePower;
                end
            end
        end
    end

    if allyPower >= enemyPower
    then
        return true;
    end

    return false;
end

local function GetBotAttackTarget()
    local npcBot = GetBot();
    local botAttackTarget = nil;
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if utility.IsValidTarget(enemy)
            then
                if GetUnitToUnitDistance(npcBot, enemy) <= combatZoneRadius and not enemy:IsInvulnerable() and not utility.IsNotAttackTarget(enemy)
                    and not enemy:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
                then
                    botAttackTarget = enemy;
                end
            end
        end
    end

    return botAttackTarget;
end

function IsPlayerControlledUnit(npcTarget)
    --local botTeam = GetTeamPlayers(GetTeam());
    local unitID = npcTarget:GetPlayerID();
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    for _, enemy in pairs(enemyHeroes) do
        local playerID = enemy:GetPlayerID();
        if playerID == unitID
        then
            return true;
        end
    end

    for _, ally in pairs(allyHeroes) do
        local playerID = ally:GetPlayerID();
        if playerID == unitID
        then
            return true;
        end
    end

    --[[     for i = 1, #botTeam do
        if i == unitID
        then
            return true;
        end
    end ]]

    return false;
end

local function CanKillTarget(npcTarget, damage, damageType)
    local targetHealth = npcTarget:GetHealth();
    local botDamage = npcTarget:GetActualIncomingDamage(damage, damageType);

    return botDamage > targetHealth;
end

local function LocalGetDesire()
    if not utility.IsHero(npcBot) or not npcBot:IsAlive()
    then
        return BOT_MODE_DESIRE_NONE;
    end

    botTarget = nil;
    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    --local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local enemyHeroesNearby = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_DESIRE_NONE);
    --local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    local enemyCreeps = GetUnitList(UNIT_LIST_ENEMIES);

    if (healthPercent <= 0.4)
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if GetUnitToUnitDistance(npcBot, enemy) <= combatZoneRadius
            then
                for _, ally in pairs(allyHeroes) do
                    if GetUnitToUnitDistance(ally, enemy) <= combatZoneRadius
                    then
                        local allyDamageToEnemy = ally:GetEstimatedDamageToTarget(true, enemy, 3.0, DAMAGE_TYPE_ALL);
                        if IsWeAreStronger(combatZoneRadius) and (allyDamageToEnemy >= enemy:GetHealth() / 2)
                        then
                            npcBot:SetTarget(enemy);
                            botTarget = npcBot:GetTarget();
                            if npcBot:WasRecentlyDamagedByTower(2.0) and healthPercent <= 0.5
                            then
                                return BOT_MODE_DESIRE_MODERATE;
                            else
                                return BOT_MODE_DESIRE_VERYHIGH;
                            end
                        end
                    end
                end

                --local myDamageToEnemy = npcBot:GetEstimatedDamageToTarget(true, enemy, 5.0, DAMAGE_TYPE_ALL);
                --local enemyDamageToMe = enemy:GetEstimatedDamageToTarget(false, npcBot, 5.0, DAMAGE_TYPE_ALL);
                -- and enemyDamageToMe < npcBot:GetHealth() / 2)
                --[[                 if IsWeAreStronger(1600)
                then
                    --npcBot:ActionImmediate_Chat("Атакую (Мы сильнее) " .. enemy:GetUnitName(), true);
                    npcBot:SetTarget(enemy);
                    botTarget = npcBot:GetTarget();
                    return BOT_MODE_DESIRE_VERYHIGH;
                end ]]
                --[[                 if IsWeAreStronger(combatZoneRadius) and (myDamageToEnemy >= enemy:GetHealth() / 2)
                then
                    npcBot:ActionImmediate_Chat("Атакую (Могу убить) " .. enemy:GetUnitName(), true);
                    npcBot:SetTarget(enemy);
                    botTarget = npcBot:GetTarget();
                    return BOT_MODE_DESIRE_VERYHIGH;
                end ]]
            end

            --[[        for _, ally in pairs(allyHeroes) do
                if ally ~= npcBot and ally:GetAttackTarget() == enemy and GetUnitToUnitDistance(npcBot, enemy) <= combatZoneRadius
                then
                    npcBot:ActionImmediate_Chat("Атакую (Помогаю) " .. enemy:GetUnitName(), true);
                    npcBot:SetTarget(enemy);
                    botTarget = npcBot:GetTarget();
                    return BOT_MODE_DESIRE_LOW;
                end
            end ]]
        end
    end
    if (#enemyCreeps > 0) and (#enemyHeroesNearby <= 0)
    then
        for _, enemy in pairs(enemyCreeps) do
            if not enemy:IsHero() and IsPlayerControlledUnit(enemy) and GetUnitToUnitDistance(npcBot, enemy) <= 1000
            then
                npcBot:ActionImmediate_Chat("Атакую крипа игрока " .. enemy:GetUnitName(), true);
                npcBot:SetTarget(enemy);
                botTarget = npcBot:GetTarget();
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

--[[ function OnStart()
    --npcBot:ActionImmediate_Chat("Атакую (Союзник может убить) " .. botTarget:GetUnitName(), true);
end ]]

--[[ function OnEnd()
    npcBot:SetTarget(nil);
end ]]

function LocalThink()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    --local botActionType = npcBot:GetCurrentActionType();
    local botAttackRange = npcBot:GetAttackRange();
    local botTargetLocation = botTarget:GetLocation();
    local botTargetInfo = GetHeroLastSeenInfo(botTarget:GetPlayerID());
    local botLastTargetLocation = botTargetInfo[1].location;
    local botSecondTarget = GetBotSecondTarget();
    --local botSecondTargetLocation = botSecondTarget:GetLocation();

    --print(npcBot:GetUnitName() .. "--->" .. botTarget:GetUnitName())

    --[[     if botActionType ~= BOT_ACTION_TYPE_IDLE
        then
            return;
        end ]]

    --[[     if botTarget == nil or botTarget:IsNull()
        then
            npcBot:ActionImmediate_Chat("Цели нет, отхожу!", true);
            npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
            return;
        end ]]

    if botTarget:CanBeSeen()
    then
        --npcBot:ActionImmediate_Ping(botTargetLocation.x, botTargetLocation.y, true);
        if botTarget:IsAlive()
        then
            if botTarget:IsInvulnerable()
            then
                if botSecondTarget ~= nil
                then
                    --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                    --npcBot:ActionImmediate_Chat("Цель скрыта, бью вторую цель!", true);
                    npcBot:Action_AttackUnit(botSecondTarget, false);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Цель скрыта, отхожу!", true);
                    npcBot:Action_MoveToLocation(botTargetLocation);
                    return;
                    --npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                end
            elseif botTarget:IsAttackImmune() or
                botTarget:IsDominated() or
                botTarget:IsNightmared() or
                utility.IsNotAttackTarget(botTarget)
            then
                if botSecondTarget ~= nil
                then
                    --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                    --npcBot:ActionImmediate_Chat("Цель нельзя ударить, бью второго героя!", true);
                    npcBot:Action_AttackUnit(botSecondTarget, false);
                    return;
                else
                    if GetUnitToUnitDistance(npcBot, botTarget) < botAttackRange
                    then
                        --npcBot:ActionImmediate_Chat("Держусь в радиусе атаки т.к цель не ударить!", true);
                        npcBot:Action_MoveToLocation(utility.GetMaxRangeCastLocation(npcBot, botTarget,
                            botAttackRange - 100) + RandomVector(100));
                        return;
                    else
                        --npcBot:ActionImmediate_Chat("Иду к цели т.к её не ударить!", true);
                        npcBot:Action_MoveToLocation(botTargetLocation);
                        return;
                    end
                end
            elseif npcBot:IsDisarmed()
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= botAttackRange
                then
                    --npcBot:ActionImmediate_Chat("Держусь в радиусе атаки т.к обезоружен!", true);
                    npcBot:Action_MoveToLocation(utility.GetMaxRangeCastLocation(npcBot, botTarget, botAttackRange - 100) +
                        RandomVector(100));
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Иду к цели т.к её обезоружен!", true);
                    npcBot:Action_MoveToLocation(botTargetLocation);
                    return;
                end
            elseif botTarget:HasModifier("modifier_fountain_aura_buff")
            then
                --npcBot:ActionImmediate_Chat("Цель под фонтаном, отхожу!", true);
                npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                return;
            else
                --npcBot:ActionImmediate_Chat("Атакую вражескую ЦЕЛЬ!", true);
                --npcBot:ActionImmediate_Ping(botTargetLocation.x, botTargetLocation.y, true);
                npcBot:Action_AttackUnit(botTarget, false);
                return;
            end
        else
            if botSecondTarget ~= nil
            then
                --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                --npcBot:ActionImmediate_Chat("Цель мертва, бью вторую цель!", true);
                npcBot:Action_AttackUnit(botSecondTarget, false);
                return;
            else
                --npcBot:ActionImmediate_Chat("Цель мертва, отхожу!", true);
                npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                return;
            end
        end
    else
        --npcBot:Action_AttackMove(npcBot:GetLocation() + RandomVector(botAttackRange));
        --npcBot:Action_MoveToLocation(botTargetLocation);
        --npcBot:Action_AttackMove(botTargetInfo.location);

        --npcBot:ActionImmediate_Chat("Цель не видно, выслеживаю!", true);
        --npcBot:ActionImmediate_Ping(botLastTargetLocation.x, botLastTargetLocation.y, true);
        npcBot:Action_MoveToLocation(botLastTargetLocation + RandomVector(200));
        return;
    end
end

--[[ if IsWeAreStronger(combatZoneRadius)
then
    local botAttackTarget = GetBotAttackTarget();
    if botAttackTarget ~= nil
    then
        npcBot:ActionImmediate_Chat("Атакую " .. botAttackTarget:GetUnitName(), true);
        npcBot:SetTarget(botAttackTarget);
        print(npcBot:GetUnitName() .. "Атакует--->" .. botAttackTarget:GetUnitName())
        if CanKillTarget(botAttackTarget, npcBot:GetAttackDamage(), DAMAGE_TYPE_PHYSICAL)
        then
            npcBot:ActionImmediate_Chat("Пытаюсь убить цель!", true);
            return BOT_MODE_DESIRE_VERYHIGH;
        elseif botAttackTarget:HasModifier("modifier_fountain_aura_buff")
        then
            npcBot:ActionImmediate_Chat("Цель под фонтаном!", true);
            return BOT_MODE_DESIRE_NONE;
        elseif npcBot:WasRecentlyDamagedByTower(3.0)
        then
            npcBot:ActionImmediate_Chat("Я под атакой башни!", true);
            return BOT_MODE_DESIRE_MODERATE;
        else
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    else
        --npcBot:ActionImmediate_Chat("Нет подходящей цели!", true);
        npcBot:SetTarget(nil);
        return BOT_MODE_DESIRE_NONE;
    end ]]


--[[function Think()
        if utility.IsBusy(npcBot)
        then
            return;
        end

        --local botActionType = npcBot:GetCurrentActionType();
        local botAttackRange = npcBot:GetAttackRange();
        local botTargetLocation = botTarget:GetLocation();
        local botTargetInfo = GetHeroLastSeenInfo(botTarget:GetPlayerID());
        local botLastTargetLocation = botTargetInfo[1].location;
        local botSecondTarget = GetBotSecondTarget();
        --local botSecondTargetLocation = botSecondTarget:GetLocation();

        --print(npcBot:GetUnitName() .. "--->" .. botTarget:GetUnitName())

        --[[     if botActionType ~= BOT_ACTION_TYPE_IDLE
        then
            return;
        end

        --[[     if botTarget == nil or botTarget:IsNull()
        then
            npcBot:ActionImmediate_Chat("Цели нет, отхожу!", true);
            npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
            return;
        end

        if botTarget:CanBeSeen()
        then
            if botTarget:IsAlive()
            then
                if botTarget:IsInvulnerable()
                then
                    if botSecondTarget ~= nil
                    then
                        --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                        --npcBot:ActionImmediate_Chat("Цель скрыта, бью вторую цель!", true);
                        npcBot:Action_AttackUnit(botSecondTarget, false);
                        return;
                    else
                        --npcBot:ActionImmediate_Chat("Цель скрыта, отхожу!", true);
                        npcBot:Action_MoveToLocation(botTargetLocation);
                        return;
                        --npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                    end
                elseif botTarget:IsAttackImmune() or
                    botTarget:IsDominated() or
                    botTarget:IsNightmared() or
                    utility.IsNotAttackTarget(botTarget)
                then
                    if botSecondTarget ~= nil
                    then
                        --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                        --npcBot:ActionImmediate_Chat("Цель нельзя ударить, бью второго героя!", true);
                        npcBot:Action_AttackUnit(botSecondTarget, false);
                        return;
                    else
                        if GetUnitToUnitDistance(npcBot, botTarget) < botAttackRange
                        then
                            --npcBot:ActionImmediate_Chat("Держусь в радиусе атаки т.к цель не ударить!", true);
                            npcBot:Action_MoveToLocation(utility.GetMaxRangeCastLocation(npcBot, botTarget,
                                botAttackRange - 100) + RandomVector(100));
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Иду к цели т.к её не ударить!", true);
                            npcBot:Action_MoveToLocation(botTargetLocation);
                            return;
                        end
                    end
                elseif npcBot:IsDisarmed()
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) <= botAttackRange
                    then
                        --npcBot:ActionImmediate_Chat("Держусь в радиусе атаки т.к обезоружен!", true);
                        npcBot:Action_MoveToLocation(utility.GetMaxRangeCastLocation(npcBot, botTarget, botAttackRange - 100) +
                            RandomVector(100));
                        return;
                    else
                        --npcBot:ActionImmediate_Chat("Иду к цели т.к её обезоружен!", true);
                        npcBot:Action_MoveToLocation(botTargetLocation);
                        return;
                    end
                elseif botTarget:HasModifier("modifier_fountain_aura_buff")
                then
                    --npcBot:ActionImmediate_Chat("Цель под фонтаном, отхожу!", true);
                    npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                    return;
                else
                    if GetUnitToUnitDistance(npcBot, botTarget) > botAttackRange
                    then
                        local path = npcBot:GeneratePath(npcBot:GetLocation(), botTargetLocation, GetAvoidanceZones(),
                            funcCompletion);
                        npcBot:Action_MovePath(path);
                        npcBot:ActionImmediate_Chat("Прокладываю маршрут до цели!", true);
                    else
                        --npcBot:ActionImmediate_Chat("Атакую вражескую ЦЕЛЬ!", true);
                        --npcBot:ActionImmediate_Ping(botTargetLocation.x, botTargetLocation.y, true);
                        npcBot:Action_AttackUnit(botTarget, false);
                        return;
                    end
                end
            else
                if botSecondTarget ~= nil
                then
                    --npcBot:ActionImmediate_Ping(botSecondTargetLocation.x, botSecondTargetLocation.y, true);
                    --npcBot:ActionImmediate_Chat("Цель мертва, бью вторую цель!", true);
                    npcBot:Action_AttackUnit(botSecondTarget, false);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Цель мертва, отхожу!", true);
                    npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                    return;
                end
            end
        else
            --npcBot:Action_AttackMove(npcBot:GetLocation() + RandomVector(botAttackRange));
            --npcBot:Action_MoveToLocation(botTargetLocation);
            --npcBot:Action_AttackMove(botTargetInfo.location);

            --npcBot:ActionImmediate_Chat("Цель не видно, выслеживаю!", true);
            --npcBot:ActionImmediate_Ping(botLastTargetLocation.x, botLastTargetLocation.y, true);
            npcBot:Action_MoveToLocation(botLastTargetLocation + RandomVector(200));
            return;
        end
    end ]]
