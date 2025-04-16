---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

--local botDesire = npcBot:GetActiveModeDesire();
--local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

local npcBot = GetBot();
local radiusUnit = 2000;
local wanderRadius = 500;
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
    --[[     local buildingPinged = BuildingPingedByHumanPlayer();

    if buildingPinged ~= nil
    then
        npcBot:ActionImmediate_Chat("Защитить: " .. buildingPinged:GetUnitName(), true);
        desire = BOT_MODE_DESIRE_VERYHIGH;
        building = buildingPinged;
    end ]]

    for _, t in pairs(towers)
    do
        local tower = GetTower(GetTeam(), t);
        if tower ~= nil and not tower:IsInvulnerable()
        then
            if utility.CountEnemyCreepAroundUnit(tower, radiusUnit) > 5 and utility.CountAllyCreepAroundUnit(tower, radiusUnit) < 5
            then
                building = tower;
                desire = BOT_MODE_DESIRE_HIGH;
            elseif (utility.CountEnemyHeroAroundUnit(tower, radiusUnit) >= 5 and utility.CountEnemyCreepAroundUnit(tower, radiusUnit) >= 1
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
            if utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) > 5 and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) < 5
            then
                desire = BOT_MODE_DESIRE_HIGH;
                building = barrack;
            elseif (utility.CountEnemyHeroAroundUnit(barrack, radiusUnit) >= 5 and utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) >= 1
                    and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) <= 5)
            then
                desire = BOT_MODE_DESIRE_VERYHIGH;
                building = barrack;
            end
        end
    end

    if ancient ~= nil and not ancient:IsInvulnerable()
    then
        if utility.IsTargetedByEnemy(ancient, true) or
            utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) > 0 or
            utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) > 0
        --and utility.CountAllyCreepAroundUnit(ancient, radiusUnit) < 5)
        then
            desire = BOT_MODE_DESIRE_VERYHIGH;
            building = ancient;
        end

        if ancient:GetHealth() < ancient:GetMaxHealth()
        then
            botDefender = GetDefenderBotHero();
            if npcBot == botDefender
            then
                desire = BOT_MODE_DESIRE_ABSOLUTE;
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

--[[ function TestBuildingPingedByHumanPlayer()
    local listPings = {};
    local teamPlayers = GetTeamPlayers(GetTeam());
    local ancient = GetAncient(GetTeam());
end

function BuildingPingedByHumanPlayer()
    local listPings = {};
    local teamPlayers = GetTeamPlayers(GetTeam()); -- Таблица с playerID союзников
    local ancient = GetAncient(GetTeam());

    -- Перебираем союзников
    if (#teamPlayers > 0)
    then
        for k, v in pairs(teamPlayers) do
            local member = GetTeamMember(k)
            if member ~= nil and not IsPlayerBot(k)
            then
                local ping = member:GetMostRecentPing()
                if ping ~= nil and (not ping.normal_ping)
                then
                    npcBot:ActionImmediate_Chat("Мой ID: ", true);
                    table.insert(listPings, ping);
                end
            end
        end


              for _, playerID in ipairs(teamPlayers) do
            local member = GetTeamMember(playerID);
            if member ~= nil and not IsPlayerBot(playerID)
            then
                npcBot:ActionImmediate_Chat("Мой ID: ", true);
                local ping = member:GetMostRecentPing();
                if ping ~= nil
                then
                    table.insert(listPings, ping);
                end
            end
        end
    end

    -- Перебираем все найденные пинги
    if (#listPings > 0)
    then
        for _, ping in ipairs(listPings) do
            if ping ~= nil
            --and not ping.normal_ping
            then
                for _, t in ipairs(towers) do
                    local tower = GetTower(GetTeam(), t)
                    if tower ~= nil and not tower:IsInvulnerable() and GetUnitToLocationDistance(tower, ping.location) <= 500
                    then
                        npcBot:ActionImmediate_Chat("Пинг рядом с башней: " .. tower:GetUnitName(), true);
                        return tower;
                    end
                end

                for _, b in ipairs(barracks) do
                    local barrack = GetBarracks(GetTeam(), b)
                    if barrack ~= nil and not barrack:IsInvulnerable() and GetUnitToLocationDistance(barrack, ping.location) <= 500
                    then
                        npcBot:ActionImmediate_Chat("Пинг рядом с барраками: " .. barrack:GetUnitName(), true);
                        return barrack;
                    end
                end

                if ancient ~= nil and not ancient:IsInvulnerable() and GetUnitToLocationDistance(ancient, ping.location) <= 500
                then
                    npcBot:ActionImmediate_Chat("Пинг рядом с Древним: " .. ancient:GetUnitName(), true);
                    return ancient;
                end
            end
        end
    end

    return nil;
end ]]

--[[ local function OLDBuildingPingedByHumanPlayer()
    local listPings = {};
    local teamPlayers = GetTeamPlayers(GetTeam());
    local ancient = GetAncient(GetTeam());

    if (#teamPlayers > 0)
    then
        for i = #teamPlayers, 1, -1
        do
            local member = GetTeamMember(i);
            if not IsPlayerBot(i)
            then
                local ping = member:GetMostRecentPing();
                table.insert(listPings, ping);
            end
        end
    end

    if (#listPings > 0)
    then
        for _, ping in pairs(listPings)
        do
            if ping ~= nil and ping.normal_ping
            then
                for _, t in pairs(towers)
                do
                    local tower = GetTower(GetTeam(), t);
                    if tower ~= nil and not tower:IsInvulnerable() and GetUnitToLocationDistance(tower, ping.location) <= 500
                    then
                        npcBot:ActionImmediate_Chat("Пинг рядом с башней: " .. tower:GetUnitName(), true);
                        return tower;
                    end
                end

                for _, b in pairs(barracks)
                do
                    local barrack = GetBarracks(GetTeam(), b);
                    if barrack ~= nil and not barrack:IsInvulnerable() and GetUnitToLocationDistance(barrack, ping.location) <= 500
                    then
                        npcBot:ActionImmediate_Chat("Пинг рядом с барраками: " .. barrack:GetUnitName(), true);
                        return barrack;
                    end
                end

                if ancient ~= nil and not ancient:IsInvulnerable() and GetUnitToLocationDistance(ancient, ping.location) <= 500
                then
                    npcBot:ActionImmediate_Chat("Пинг рядом с Древним: " .. ancient:GetUnitName(), true);
                    return ancient;
                end
            end
        end
    end

    return nil;
end ]]

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
    local ancientRadius = 500.0;
    local fountainLocation = utility.GetFountainLocation();
    local team = npcBot:GetTeam();
    local defendZone = utility.GetEscapeLocation(mainBuilding, wanderRadius);
    local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    local allyHeroes = npcBot:GetNearbyHeroes(500, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(500, true, BOT_MODE_NONE);
    local mainCreep = nil;

    npcBot:SetTarget(mainBuilding);

    if utility.BotWasRecentlyDamagedByEnemyHero(2.0) or (healthPercent <= 0.4 and npcBot:WasRecentlyDamagedByCreep(2.0))
    then
        npcBot:Action_ClearActions(false);
        npcBot:Action_MoveToLocation(fountainLocation);
        return;
    else
        if npcBot == botDefender and mainBuilding == ancient
        then
            if utility.BotWasRecentlyDamagedByEnemyHero(2.0) or (#enemyHeroes > #allyHeroes)
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(fountainLocation);
                return;
            else
                if GetUnitToLocationDistance(npcBot, ancientLocation) > 1000
                then
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(ancientLocation);
                    return;
                else
                    if (#enemyCreeps > 0)
                    then
                        for _, enemy in pairs(enemyCreeps) do
                            if not utility.IsNotAttackTarget(enemy)
                            then
                                if string.find(enemy:GetUnitName(), "siege") or enemy:GetAttackTarget() == ancient
                                then
                                    mainCreep = enemy;
                                    break;
                                else
                                    mainCreep = enemy;
                                    break;
                                end
                            end
                        end
                        if mainCreep ~= nil
                        then
                            npcBot:SetTarget(mainCreep);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainCreep, false);
                            return;
                        end
                    else
                        local angle = math.rad(math.fmod(npcBot:GetFacing() + 30, 360));
                        local newLocation = Vector(ancientLocation.x + ancientRadius * math.cos(angle),
                            ancientLocation.y + ancientRadius * math.sin(angle), ancientLocation.z);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(newLocation);
                        --DebugDrawLine(ancientLocation, newLocation, 255, 0, 0);
                        --npcBot:ActionImmediate_Chat("Охраняю древнего.", true);
                        return;
                    end
                end
            end
        else
            if GetUnitToLocationDistance(npcBot, defendZone) > 700 and
                npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and
                npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(defendZone);
                return;
            else
                if utility.BotWasRecentlyDamagedByEnemyHero(2.0)
                then
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -1000) + RandomVector(wanderRadius));
                    --npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                    return;
                else
                    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
                    if (#enemyCreeps > 0)
                    then
                        for _, enemy in pairs(enemyCreeps) do
                            if not utility.IsNotAttackTarget(enemy)
                            then
                                if string.find(enemy:GetUnitName(), "siege") or enemy:GetAttackTarget() == mainBuilding
                                then
                                    mainCreep = enemy;
                                    break;
                                else
                                    mainCreep = enemy;
                                    break;
                                end
                            end
                        end
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
                    else
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(defendZone + RandomVector(wanderRadius));
                        return;
                    end
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
