---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_defend_tower_mid_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

--local botDesire = npcBot:GetActiveModeDesire();
--local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

local npcBot = GetBot();

local function GetBuildingToProtect()
    local building = nil;
    local desire = BOT_MODE_DESIRE_NONE;
    local radiusUnit = 2000;
    local towers = {
        TOWER_MID_1,
        TOWER_MID_2,
        TOWER_MID_3,
        TOWER_BASE_1,
        TOWER_BASE_2,
    }

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

    local barracks = {
        BARRACKS_MID_MELEE,
        BARRACKS_MID_RANGED,
    }

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

    local ancient = GetAncient(GetTeam());
    if ancient ~= nil and not ancient:IsInvulnerable()
    then
        if (utility.IsTargetedByEnemy(ancient, true)) or
            (utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) >= 1 and utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) >= 1
                and utility.CountAllyCreepAroundUnit(ancient, radiusUnit) < 5)
        then
            desire = BOT_MODE_DESIRE_ABSOLUTE;
            building = ancient;
        end
    end

    return building, desire;
end

function GetDesire()
    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    --local botMode = npcBot:GetActiveMode();
    local botLevel = npcBot:GetLevel();

    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or not utility.CanMove(npcBot) or utility.IsBusy(npcBot) or npcBot:WasRecentlyDamagedByAnyHero(2.0)
        or healthPercent <= 0.3 or (botLevel <= 3)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    mainBuilding, desire = GetBuildingToProtect();

    return desire;

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

    if mainBuilding ~= nil
    then
        local defendZone = utility.GetEscapeLocation(mainBuilding, 500);
        if GetUnitToLocationDistance(npcBot, defendZone) > 700 and
            npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and
            npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
        then
            npcBot:Action_ClearActions(false);
            npcBot:Action_MoveToLocation(defendZone);
            return;
        else
            if npcBot:WasRecentlyDamagedByAnyHero(2.0)
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(utility.SafeLocation(npcBot));
                return;
            else
                local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
                local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
                local mainCreep = nil;
                local mainEnemy = nil;
                if (#enemyCreeps > 0)
                then
                    --mainCreep = utility.GetWeakest(enemyCreeps);
                    mainCreep = enemyCreeps[1];
                    if (#enemyHeroes <= 1)
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_AttackUnit(mainCreep, false);
                        return;
                    else
                        if npcBot:GetAttackRange() >= 500
                        then
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainCreep, true);
                            return;
                            --[[                         if GetUnitToUnitDistance(npcBot, mainCreep) > npcBot:GetAttackRange()
                        then
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(mainCreep:GetLocation());
                            --npcBot:Action_AttackMove(mainCreep:GetLocation());
                            return;
                        else
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainCreep, true);
                            return;
                        end ]]
                        else
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(500));
                            --npcBot:Action_AttackMove(npcBot:GetLocation() + RandomVector(500));
                            return;
                        end
                    end
                elseif (#enemyHeroes > 0) and (#allyHeroes >= #enemyHeroes)
                then
                    --mainEnemy = utility.GetWeakest(enemyHeroes);
                    mainEnemy = enemyHeroes[1];
                    if mainEnemy ~= nil
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_AttackUnit(mainEnemy, true);
                        return;

                        --[[                     if GetUnitToUnitDistance(npcBot, mainEnemy) > npcBot:GetAttackRange()
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(mainEnemy:GetLocation());
                        --npcBot:Action_AttackMove(mainEnemy:GetLocation());
                        return;
                    else
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_AttackUnit(mainEnemy, true);
                        return;
                    end ]]
                    end
                else
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(500));
                    return;
                    --npcBot:Action_AttackMove(npcBot:GetLocation() + RandomVector(500));
                end

                --[[         if mainCreep ~= nil
            then
                if GetUnitToUnitDistance(npcBot, mainCreep) > npcBot:GetAttackRange()
                then
                    npcBot:Action_MoveToLocation(mainCreep:GetLocation());
                else
                    npcBot:Action_AttackUnit(mainCreep, false);
                end
            else
                npcBot:Action_AttackMove(npcBot:GetLocation() + RandomVector(500));
                --npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(500));
            end ]]
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_defend_tower_mid_generic) do _G._savedEnv[k] = v end
