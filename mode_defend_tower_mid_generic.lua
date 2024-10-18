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

local function GetBuildingToProtect()
    local building = nil;
    local desire = BOT_MODE_DESIRE_NONE;
    local ancient = GetAncient(GetTeam());

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

function GetDesire()
    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    --local botMode = npcBot:GetActiveMode();
    local botLevel = npcBot:GetLevel();

    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or healthPercent <= 0.3 or botLevel <= 3
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    mainBuilding, desire = GetBuildingToProtect();

    return desire;
end

function OnStart()
    if RollPercentage(15)
    then
        npcBot:ActionImmediate_Chat("Защищаю " .. mainBuilding:GetUnitName(), false);
    end
end

function OnEnd()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Прекращаю защищать " .. mainBuilding:GetUnitName(), false);
    end
    mainBuilding = nil;
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local ancient = GetAncient(GetTeam());
    local ancientLocation = ancient:GetLocation();
    local ancientRadius = 500.0;
    local fountainLocation = utility.GetFountainLocation();
    --SafeLocation(npcBot);
    local team = npcBot:GetTeam();
    local defendZone = utility.GetEscapeLocation(mainBuilding, wanderRadius);
    local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    local allyHeroes = npcBot:GetNearbyHeroes(500, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(500, true, BOT_MODE_NONE);
    local mainCreep = nil;

    if (healthPercent <= 0.4) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByCreep(3.0))
    then
        npcBot:Action_MoveToLocation(defendZone);
        return;
    else
        if npcBot == botDefender and mainBuilding == ancient
        then
            if npcBot:WasRecentlyDamagedByAnyHero(2.0) or (#enemyHeroes > #allyHeroes)
            then
                npcBot:Action_MoveToLocation(fountainLocation);
                return;
            else
                if GetUnitToLocationDistance(npcBot, ancientLocation) > 1000
                then
                    npcBot:Action_MoveToLocation(ancientLocation);
                    return;
                else
                    if (#enemyCreeps > 0)
                    then
                        mainCreep = enemyCreeps[1];
                        if mainCreep ~= nil
                        then
                            npcBot:Action_AttackUnit(mainCreep, false);
                            return;
                        end
                    else
                        local angle = math.rad(math.fmod(npcBot:GetFacing() + 30, 360));
                        local newLocation = Vector(ancientLocation.x + ancientRadius * math.cos(angle),
                            ancientLocation.y + ancientRadius * math.sin(angle), ancientLocation.z);
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
                npcBot:Action_MoveToLocation(defendZone);
                return;
            else
                if npcBot:WasRecentlyDamagedByAnyHero(2.0)
                then
                    npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -1000) + RandomVector(wanderRadius));
                    --npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                    return;
                else
                    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
                    if (#enemyCreeps > 0)
                    then
                        mainCreep = enemyCreeps[1];
                        if mainCreep ~= nil
                        then
                            if (#enemyHeroes >= #allyHeroes)
                            then
                                npcBot:Action_AttackUnit(mainCreep, true);
                                return;
                            else
                                npcBot:Action_AttackUnit(mainCreep, false);
                                return;
                            end
                        else
                            npcBot:Action_MoveToLocation(defendZone + RandomVector(wanderRadius));
                            return;
                        end
                    else
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
