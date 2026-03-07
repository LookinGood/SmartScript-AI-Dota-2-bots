---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

--local botDesire = npcBot:GetActiveModeDesire();
--local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

local npcBot = GetBot();
local radiusUnit = 2000;
local lane = LANE_MID;

local towers = {
    TOWER_MID_1,
    TOWER_MID_2,
    TOWER_MID_3,
    TOWER_BASE_1,
    TOWER_BASE_2,
}

local barracks = {
    BARRACKS_MID_MELEE,
    BARRACKS_MID_RANGED,
}

function GetBuildingToProtect()
    local building = nil;
    local desire = BOT_MODE_DESIRE_NONE;
    local ancient = GetAncient(GetTeam());

    for _, t in pairs(towers)
    do
        local tower = GetTower(GetTeam(), t);
        if tower ~= nil and not tower:IsInvulnerable()
        then
            if IsPingedByHumanPlayer(tower)
            then
                --npcBot:ActionImmediate_Chat("Защищаю башню рядом с пингом: " .. tower:GetUnitName(), true);
                building = tower;
                desire = BOT_MODE_DESIRE_VERYHIGH;
            end
            if utility.CountEnemyCreepAroundUnit(tower, radiusUnit) > 5 and utility.CountAllyCreepAroundUnit(tower, radiusUnit) < 5
            then
                building = tower;
                desire = BOT_MODE_DESIRE_HIGH;
            end
            if (utility.CountEnemyHeroAroundUnit(tower, radiusUnit) >= 2 and utility.CountEnemyCreepAroundUnit(tower, radiusUnit) >= 1
                    and utility.CountAllyCreepAroundUnit(tower, radiusUnit) < 5)
            then
                desire = BOT_MODE_DESIRE_VERYHIGH;
                building = tower;
            end
        end
    end

    for _, b in pairs(barracks)
    do
        local barrack = GetBarracks(GetTeam(), b);
        if barrack ~= nil and not barrack:IsInvulnerable()
        then
            if IsPingedByHumanPlayer(barrack)
            then
                --npcBot:ActionImmediate_Chat("Защищаю баррак рядом с пингом: " .. tower:GetUnitName(), true);
                building = barrack;
                desire = BOT_MODE_DESIRE_VERYHIGH;
            end
            if utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) > 5 and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) < 5
            then
                building = barrack;
                desire = BOT_MODE_DESIRE_HIGH;
            end
            if (utility.CountEnemyHeroAroundUnit(barrack, radiusUnit) >= 2 and utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) >= 1
                    and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) <= 5)
            then
                building = barrack;
                desire = BOT_MODE_DESIRE_VERYHIGH;
            end
        end
    end

    if ancient ~= nil and not ancient:IsInvulnerable()
    then
        if IsPingedByHumanPlayer(ancient)
        then
            --npcBot:ActionImmediate_Chat("Защищаю Древнего рядом с пингом: " .. ancient:GetUnitName(), true);
            building = ancient;
            desire = BOT_MODE_DESIRE_VERYHIGH;
        end
        local ancientHealth = ancient:GetHealth() / ancient:GetMaxHealth();
        if (ancientHealth <= 0.7 and utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) > 0 and utility.IsTargetedByEnemy(ancient, true)) or
            (utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) > 0) or
            (utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) > 0 and GetUnitToUnitDistance(npcBot, ancient) <= radiusUnit)
        then
            desire = BOT_MODE_DESIRE_VERYHIGH;
            building = ancient;
        end

        if ancient:GetHealth() < ancient:GetMaxHealth()
        then
            botDefender = GetDefenderBotHero();
            if npcBot == botDefender
            then
                if (ancient:GetHealthRegen() > 0)
                then
                    --npcBot:ActionImmediate_Chat("Древний восстанавливает ХП, защищаю.", true);
                    desire = BOT_MODE_DESIRE_VERYHIGH;
                else
                    if utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) > 0 or
                        utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) > 0
                    then
                        --npcBot:ActionImmediate_Chat("Древний НЕ восстанавливает ХП, вокруг есть враги, защищаю.", true);
                        desire = BOT_MODE_DESIRE_VERYHIGH;
                    else
                        desire = BOT_MODE_DESIRE_MODERATE;
                    end
                end
                building = ancient;
            end
        end
    end

    return building, desire;
end

function GetTowerToDenying()
    local denyingTower = nil;
    local towers = {
        TOWER_MID_1,
        TOWER_MID_2,
    }

    for _, t in pairs(towers)
    do
        local tower = GetTower(GetTeam(), t);
        local towerHealthPercent = tower:GetHealth() / tower:GetMaxHealth();
        if (tower:IsAlive() and not tower:IsInvulnerable() and GetUnitToUnitDistance(npcBot, tower) <= 1000) and
            (towerHealthPercent <= 0.1 or tower:IsSpeciallyDeniable())
        then
            --npcBot:ActionImmediate_Chat("Нужно добить " .. tower:GetUnitName(), true);
            denyingTower = tower;
        end
    end

    return denyingTower;
end

function GetDefenderBotHero()
    local unit = nil;
    local forse = 100000;
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    for _, ally in pairs(allyHeroes) do
        if IsPlayerBot(ally:GetPlayerID()) and ally:IsAlive()
        then
            local botPower = ally:GetOffensivePower();
            if botPower < forse
            then
                unit = ally;
                forse = botPower;
            end
        end
    end

    --print(unit:GetUnitName())
    return unit;
end

function GetCurrentAttackTarget()
    local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
    local enemyOther = GetUnitList(UNIT_LIST_ENEMY_OTHER);

    if mainBuilding ~= nil
    then
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if not utility.IsNotAttackTarget(enemy)
                then
                    if enemy:GetAttackTarget() == mainBuilding
                    then
                        --npcBot:ActionImmediate_Chat("Крип атакует здание: " .. enemy:GetUnitName(), true);
                        return enemy;
                    end
                    if GetUnitToUnitDistance(enemy, mainBuilding) <= 2000
                    then
                        --npcBot:ActionImmediate_Chat("Крип рядом со зданием: " .. enemy:GetUnitName(), true);
                        return enemy;
                    end
                end
            end
        end

        if (#enemyOther > 0)
        then
            for _, enemy in pairs(enemyOther) do
                if not utility.IsNotAttackTarget(enemy)
                then
                    if enemy:GetAttackTarget() == mainBuilding
                    then
                        npcBot:ActionImmediate_Chat("Юнит атакует здание: " .. enemy:GetUnitName(), true);
                        return enemy;
                    end
                    if GetUnitToUnitDistance(enemy, mainBuilding) <= 2000
                    then
                        --npcBot:ActionImmediate_Chat("Юнит рядом со зданием: " .. enemy:GetUnitName(), true);
                        return enemy;
                    end
                end
            end
        end
    end

    return nil;
end

function IsPingedByHumanPlayer(unit)
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes)
        do
            if ally ~= nil and not ally:IsIllusion() and not IsPlayerBot(ally:GetPlayerID())
            then
                local ping = ally:GetMostRecentPing();
                if ping ~= nil and GetUnitToLocationDistance(unit, ping.location) < 300 and GameTime() - ping.time < 15
                then
                    --npcBot:ActionImmediate_Chat("Игрок пингует рядом со зданием: " .. unit:GetUnitName(), true);
                    return true;
                end
            end
        end
    end

    return false;
end

function GetDesire()
    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local botMode = npcBot:GetActiveMode();
    local botLevel = npcBot:GetLevel();

    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or healthPercent <= 0.3 or botLevel <= 3 or
        botMode == BOT_MODE_DEFEND_TOWER_TOP or botMode == BOT_MODE_DEFEND_TOWER_BOT
    then
        return BOT_MODE_DESIRE_NONE;
    end

    mainBuilding, desire = GetBuildingToProtect();

    if mainBuilding ~= nil
    then
        return desire;
    end

    denyingTower = GetTowerToDenying();

    if denyingTower ~= nil
    then
        --npcBot:ActionImmediate_Chat("Хочу добить " .. denyingTower:GetUnitName(), true);
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(5)
    then
        if mainBuilding ~= nil
        then
            npcBot:ActionImmediate_Chat("Защищаю " .. mainBuilding:GetUnitName(), false);
        end
    end
end

function OnEnd()
    mainBuilding = nil;
    denyingTower = nil;
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    if denyingTower ~= nil
    then
        --npcBot:ActionImmediate_Chat("Добиваю " .. denyingTower:GetUnitName(), true);
        npcBot:Action_ClearActions(false);
        npcBot:Action_AttackUnit(denyingTower, false);
        return;
    end

    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local ancient = GetAncient(GetTeam());
    local ancientLocation = ancient:GetLocation();
    local ancientRadius = ancient:GetBoundingRadius();
    local fountainLocation = utility.GetFountainLocation();
    --local team = npcBot:GetTeam();
    local wanderRadius = 500;
    local defendZone = utility.GetEscapeLocation(mainBuilding, wanderRadius);
    --local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    --local allyHeroes = npcBot:GetNearbyHeroes(1000, false, BOT_MODE_NONE);
    --local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
    local mainCreep = nil;

    npcBot:SetTarget(mainBuilding);

    if utility.BotWasRecentlyDamagedByEnemyHero(2.0) or
        (healthPercent <= 0.4 and npcBot:WasRecentlyDamagedByCreep(2.0)) or
        (utility.IsEnemiesAroundStronger())
    then
        npcBot:Action_ClearActions(false);
        npcBot:Action_MoveToLocation(fountainLocation);
        return;
    else
        if npcBot == botDefender and mainBuilding == ancient and mainCreep == nil
        then
            if GetUnitToLocationDistance(npcBot, ancientLocation) > 1600
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(ancientLocation);
                return;
            else
                mainCreep = GetCurrentAttackTarget();
                if mainCreep ~= nil
                then
                    npcBot:SetTarget(mainCreep);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_AttackUnit(mainCreep, false);
                    return;
                else
                    local angle = math.rad(math.fmod(npcBot:GetFacing() + 30, 360));
                    local newLocation = Vector(ancientLocation.x + ancientRadius * math.cos(angle),
                        ancientLocation.y + ancientRadius * math.sin(angle), ancientLocation.z);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(newLocation);
                    --DebugDrawLine(ancientLocation, newLocation, 255, 0, 0);
                    --npcBot:ActionImmediate_Chat("Охраняю древнего вокруг его радиуса: " .. ancientRadius, true);
                    return;
                end
            end
        else
            if GetUnitToLocationDistance(npcBot, defendZone) > 700 and mainCreep == nil
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(defendZone);
                return;
            else
                local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
                mainCreep = GetCurrentAttackTarget();
                if mainCreep ~= nil
                then
                    npcBot:SetTarget(mainCreep);
                    if (#enemyHeroes >= #allyHeroes)
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_AttackUnit(mainCreep, true);
                        return;
                    else
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_AttackUnit(mainCreep, false);
                        return;
                    end
                else
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(defendZone + RandomVector(wanderRadius));
                    return;
                end
            end
        end
    end
end

--[[     if mainBuilding:IsTower()
    then
        return BOT_ACTION_DESIRE_HIGH;
    elseif mainBuilding:IsBarracks()
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    elseif mainBuilding:IsFort() or mainBuilding == GetAncient(GetTeam())
    then
        return BOT_ACTION_DESIRE_ABSOLUTE;
    else
        return BOT_ACTION_DESIRE_NONE;
    end ]]
