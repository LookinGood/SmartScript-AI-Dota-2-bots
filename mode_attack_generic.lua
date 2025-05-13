---@diagnostic disable: undefined-global, need-check-nil, undefined-field
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local mainEnemy = nil;
local mainEnemyInfo = nil;
local mainEnemyLastLocation = nil;
local botPotentialLocation = 0;
local combatZoneRadius = 2000;

function IsAllyAroundIsStronger(npcTarget)
    local allyPower = 0;
    local enemyPower = 0;
    local allyHeroAround = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local enemyHeroAround = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#enemyHeroAround > 0)
    then
        for _, enemy in pairs(enemyHeroAround) do
            if utility.IsValidTarget(enemy) and GetUnitToUnitDistance(npcTarget, enemy) <= combatZoneRadius
            then
                local enemyOffensivePower = enemy:GetRawOffensivePower();
                enemyPower = enemyPower + enemyOffensivePower;
            end
        end
    end

    if (#allyHeroAround > 0)
    then
        for _, ally in pairs(allyHeroAround) do
            if GetUnitToUnitDistance(npcTarget, ally) <= combatZoneRadius
            then
                local allyOffensivePower = ally:GetOffensivePower();
                allyPower = allyPower + allyOffensivePower;
            end
        end
    end

    if (allyPower >= enemyPower * 1.2)
    then
        --npcBot:ActionImmediate_Chat("Мы сильнее: " .. allyPower .. " , " .. enemyPower .. " * 1.2 = " .. enemyPower * 1.2, true);
        return true;
    end

    --[[   if (#allyHeroAround > 1)
    then
        for _, ally in pairs(allyHeroAround) do
            if ally ~= npcBot and GetUnitToUnitDistance(npcTarget, ally) <= combatZoneRadius
            then
                local allyDamage = ally:GetEstimatedDamageToTarget(true, npcTarget, 15.0, DAMAGE_TYPE_ALL);
                if (allyDamage >= npcTarget:GetHealth())
                then
                    --npcBot:ActionImmediate_Chat("Урон союзника по " .. npcTarget:GetUnitName() .. " = " .. allyDamage .. " , его HP: " .. npcTarget:GetHealth(), true);
                    return true;
                end
            end
        end
    end ]]

    --[[     if (#allyHeroAround > 1)
    then
        for _, ally in pairs(allyHeroAround) do
            if ally ~= npcBot and ally:GetAttackTarget() == npcTarget
            then
                return true;
            end
        end
    end ]]

    return false;
end

function IsPlayerControlledUnit(npcTarget)
    local unitID = npcTarget:GetPlayerID();
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if npcTarget:IsCourier()
    then
        return true;
    end

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

    return false;
end

function GetDesire()
    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or npcBot:HasModifier("modifier_fountain_fury_swipes_damage_increase")
    then
        return BOT_MODE_DESIRE_NONE;
    end

    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();

    if (healthPercent < 0.4) and not npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_MODE_DESIRE_NONE;
    end

    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local allyHeroesDamage = 0;

    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if not enemy:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") and
                not enemy:HasModifier("modifier_fountain_aura_buff") and
                enemy:IsAlive()
            then
                if (#allyHeroes > 0)
                then
                    for _, ally in pairs(allyHeroes) do
                        if ally:IsAlive() and GetUnitToUnitDistance(enemy, ally) <= combatZoneRadius
                        then
                            local allyDamage = ally:GetEstimatedDamageToTarget(true, enemy, 2.0, DAMAGE_TYPE_ALL);
                            allyHeroesDamage = allyHeroesDamage + allyDamage;
                            if IsAllyAroundIsStronger(enemy) and (allyHeroesDamage >= enemy:GetHealth())
                            then
                                mainEnemy = enemy;
                                if npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
                                then
                                    --npcBot:ActionImmediate_Chat("Нападаю под ультой SK на цель: " .. mainEnemy:GetUnitName(), true);
                                    return BOT_MODE_DESIRE_ABSOLUTE;
                                else
                                    if GetUnitToUnitDistance(npcBot, mainEnemy) <= combatZoneRadius and not npcBot:WasRecentlyDamagedByTower(2.0)
                                    then
                                        --npcBot:ActionImmediate_Chat("Наш урон по " .. enemy:GetUnitName() .. " = " .. allyHeroesDamage .. " , его HP: " .. enemy:GetHealth(), true);
                                        return BOT_MODE_DESIRE_VERYHIGH;
                                    else
                                        return BOT_MODE_DESIRE_VERYLOW;
                                    end
                                end
                            end
                        end
                    end
                end


                --[[
                local botDamage = npcBot:GetEstimatedDamageToTarget(true, enemy, 10.0, DAMAGE_TYPE_ALL);
                if IsAllyAroundIsStronger(enemy) and (botDamage >= enemy:GetHealth())
                then
                    --npcBot:ActionImmediate_Chat("Мой урон по " .. enemy:GetUnitName() .. " = " .. botDamage .. " , его HP: " .. enemy:GetHealth(), true);
                    mainEnemy = enemy;
                    if GetUnitToUnitDistance(npcBot, mainEnemy) <= combatZoneRadius and not npcBot:WasRecentlyDamagedByTower(2.0)
                    then
                        return BOT_MODE_DESIRE_HIGH;
                    elseif npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
                    then
                        return BOT_MODE_DESIRE_ABSOLUTE;
                    else
                        return BOT_MODE_DESIRE_MODERATE;
                    end
                end ]]
            end
        end
    end

    if npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        local weakestHeroNearby = utility.GetWeakest(npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE));
        local weakestCreepNearby = utility.GetWeakest(npcBot:GetNearbyCreeps(1600, true));
        if weakestHeroNearby ~= nil
        then
            --npcBot:ActionImmediate_Chat("Нападаю под ультой SK на героя " .. weakestHeroNearby:GetUnitName(), true);
            mainEnemy = weakestHeroNearby;
        elseif weakestCreepNearby ~= nil
        then
            --npcBot:ActionImmediate_Chat("Нападаю под ультой SK на крипа " .. weakestCreepNearby:GetUnitName(), true);
            mainEnemy = weakestCreepNearby;
        end
        return BOT_MODE_DESIRE_ABSOLUTE;
    end

    local enemyCreeps = GetUnitList(UNIT_LIST_ENEMIES);
    local enemyHeroesNearby = npcBot:GetNearbyHeroes(700, true, BOT_MODE_DESIRE_NONE);

    if (#enemyCreeps > 0) and (#enemyHeroesNearby <= 0)
    then
        for _, enemy in pairs(enemyCreeps) do
            if enemy:CanBeSeen() and not enemy:IsHero() and IsPlayerControlledUnit(enemy) and GetUnitToUnitDistance(npcBot, enemy) <= 1000 and
                not enemy:IsInvulnerable() and
                not enemy:IsAttackImmune() and
                not enemy:IsNightmared() and
                not npcBot:IsDisarmed() and
                not utility.IsNotAttackTarget(enemy)
            then
                mainEnemy = enemy;
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    if mainEnemy ~= nil
    then
        npcBot:SetTarget(mainEnemy);
        if RollPercentage(5)
        then
            npcBot:ActionImmediate_Chat("Нападаю на " .. mainEnemy:GetUnitName(), false);
            npcBot:ActionImmediate_Ping(mainEnemy:GetLocation().x, mainEnemy:GetLocation().y, true);
        end
    end
end

function OnEnd()
    npcBot:SetTarget(nil);
    mainEnemy = nil;
    mainEnemyInfo = nil;
    mainEnemyLastLocation = nil;
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    if mainEnemy ~= nil then npcBot:SetTarget(mainEnemy); end;

    if npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        if mainEnemy ~= nil
        then
            npcBot:Action_AttackUnit(mainEnemy, false);
            return;
        else
            if npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                --npcBot:ActionImmediate_Chat("Нападаю под ультой SK на древнего.", true);
                npcBot:Action_AttackMove(GetAncient(GetOpposingTeam()):GetLocation());
                return;
            end
        end
    end

    if mainEnemy ~= nil
    then
        local botAttackRange = npcBot:GetAttackRange();
        local mainEnemyLocation = mainEnemy:GetLocation();
        if mainEnemy:IsHero()
        then
            mainEnemyInfo = GetHeroLastSeenInfo(mainEnemy:GetPlayerID());
            mainEnemyLastLocation = mainEnemyInfo[1].location;
            --npcBot:ActionImmediate_Ping(mainEnemyLocation.x, mainEnemyLocation.y, true);
            if mainEnemy:IsInvulnerable()
            then
                --npcBot:ActionImmediate_Chat("Цель скрыта!", true);
                npcBot:Action_MoveToLocation(mainEnemyLocation);
                return;
            elseif mainEnemy:IsAttackImmune() or
                mainEnemy:IsDominated() or
                mainEnemy:IsNightmared() or
                npcBot:IsDisarmed() or
                utility.IsNotAttackTarget(mainEnemy)
            then
                if GetUnitToUnitDistance(npcBot, mainEnemy) < botAttackRange
                then
                    --npcBot:ActionImmediate_Chat("Держусь в радиусе атаки т.к цель не ударить!", true);
                    npcBot:Action_MoveToLocation(utility.GetMaxRangeCastLocation(npcBot, mainEnemy,
                        botAttackRange - 100) + RandomVector(100));
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Иду к цели т.к её не ударить!", true);
                    npcBot:Action_MoveToLocation(mainEnemyLocation);
                    return;
                end
            else
                if GetUnitToUnitDistance(npcBot, mainEnemy) > (botAttackRange * 2)
                then
                    --npcBot:ActionImmediate_Ping(mainEnemyLocation.x, mainEnemyLocation.y, true);
                    npcBot:Action_MoveToLocation(mainEnemyLastLocation);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Атакую вражескую ЦЕЛЬ!", true);
                    npcBot:Action_AttackUnit(mainEnemy, false);
                    return;
                end
            end
        else
            --npcBot:ActionImmediate_Chat("Атакую крипа игрока " .. mainEnemy:GetUnitName(), true);
            npcBot:Action_AttackUnit(mainEnemy, false);
            return;
        end
    end
end

--[[       npcBot:ActionImmediate_Chat("Цель не видно, выслеживаю!", true);
                npcBot:ActionImmediate_Ping(mainEnemyLastLocation.x, mainEnemyLastLocation.y, true);
                npcBot:Action_MoveToLocation(mainEnemyLastLocation + RandomVector(200));
                return; ]]



--[[            if (botDamage >= enemy:GetHealth())
                then
                    npcBot:SetTarget(enemy);
                    mainEnemy = npcBot:GetTarget();
                    npcBot:ActionImmediate_Chat(
                        "Урон по " ..
                        mainEnemy:GetUnitName() .. " = " .. botDamage .. " , его HP: " .. mainEnemy:GetHealth(),
                        true);
                    if GetUnitToUnitDistance(npcBot, mainEnemy) <= combatZoneRadius
                    then
                        return BOT_MODE_DESIRE_VERYHIGH;
                    else
                        return BOT_MODE_DESIRE_MODERATE;
                    end
                end ]]


--[[     if mainEnemy ~= nil
    then
        npcBot:SetTarget(mainEnemy);
        if mainEnemy:CanBeSeen()
        then
            mainEnemyInfo = GetHeroLastSeenInfo(mainEnemy:GetPlayerID());
            lastSeenLocation = mainEnemyInfo[1].location;
            --npcBot:ActionImmediate_Chat("Нападаю на " .. mainEnemy:GetUnitName(), true);
            npcBot:Action_AttackUnit(mainEnemy, false);
            return;
        else
            botPotentialLocation = GetUnitPotentialValue(mainEnemy, lastSeenLocation, 400);
            if botPotentialLocation > 128
            then
                npcBot:ActionImmediate_Chat("Цель не видно: " .. mainEnemyInfo[1].time_since_seen, true);
                npcBot:ActionImmediate_Ping(lastSeenLocation.x, lastSeenLocation.y, true);
                npcBot:Action_MoveToLocation(lastSeenLocation + RandomVector(200));
                return;
            end
        end
    end ]]
