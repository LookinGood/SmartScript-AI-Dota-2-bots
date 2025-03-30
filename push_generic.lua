---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("push_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local retreatDistance = 1000;

function Think()
    local npcBot = GetBot();
    local botMode = npcBot:GetActiveMode();
    local team = npcBot:GetTeam();
    local wanderRadius = 200;
    local lane = LANE_NONE;
    if botMode == BOT_MODE_PUSH_TOWER_TOP
    then
        lane = LANE_TOP;
    elseif botMode == BOT_MODE_PUSH_TOWER_MID
    then
        lane = LANE_MID;
    elseif botMode == BOT_MODE_PUSH_TOWER_BOT
    then
        lane = LANE_BOT;
    end

    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local enemyAncient = GetAncient(GetOpposingTeam());
    local mainCreep = nil;
    local mainBuilding = nil;

    if npcBot:WasRecentlyDamagedByTower(3.0) or
        utility.BotWasRecentlyDamagedByEnemyHero(3.0) or
        --npcBot:WasRecentlyDamagedByAnyHero(3.0) or
        (npcBot:IsInvisible() and #allyHeroes < #enemyHeroes) or
        npcBot:IsDisarmed() or
        npcBot:IsAttackImmune()
    then
        if retreatDistance < 3000
        then
            retreatDistance = retreatDistance + 500;
        elseif retreatDistance >= 3000
        then
            retreatDistance = 1000;
        end
        npcBot:Action_ClearActions(false);
        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -retreatDistance) + RandomVector(wanderRadius));
        return;
    else
        local frontlocation = GetLaneFrontLocation(team, lane, -200);
        if GetUnitToLocationDistance(npcBot, frontlocation) > 500 and
            npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and
            npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
        then
            local enemyTowers = npcBot:GetNearbyTowers(500, true);
            local enemyBarracks = npcBot:GetNearbyBarracks(500, true);
            if (#enemyTowers > 0)
            then
                if (#enemyTowers == 1)
                then
                    mainBuilding = enemyTowers[1];
                else
                    mainBuilding = utility.GetWeakest(enemyTowers);
                end
                npcBot:SetTarget(mainBuilding);
                --print(tostring(npcBot:GetTarget():GetUnitName()));
                if utility.CanCastOnInvulnerableTarget(mainBuilding)
                then
                    --npcBot:ActionImmediate_Chat("Атакую башню на моем пути.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_AttackUnit(mainBuilding, false);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Брожу около башни на пути, она неуязвима.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(wanderRadius));
                    return;
                end
            elseif (#enemyBarracks > 0)
            then
                if (#enemyBarracks == 1)
                then
                    mainBuilding = enemyBarracks[1];
                else
                    mainBuilding = utility.GetWeakest(enemyBarracks);
                end
                npcBot:SetTarget(mainBuilding);
                --print(tostring(npcBot:GetTarget():GetUnitName()));
                if utility.CanCastOnInvulnerableTarget(mainBuilding)
                then
                    --npcBot:ActionImmediate_Chat("Атакую баррак на пути.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_AttackUnit(mainBuilding, false);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Брожу рядом с барраком на пути, он неуязвим.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(wanderRadius));
                    return;
                end
            elseif GetUnitToUnitDistance(npcBot, enemyAncient) <= 500
            then
                mainBuilding = enemyAncient;
                npcBot:SetTarget(mainBuilding);
                --print(tostring(npcBot:GetTarget():GetUnitName()));
                if utility.CanCastOnInvulnerableTarget(mainBuilding)
                then
                    --npcBot:ActionImmediate_Chat("Атакую древнего на пути.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_AttackUnit(mainBuilding, false);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Брожу рядом с древним на пути, он неуязвим.", true);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(wanderRadius));
                    return;
                end
            else
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                return;
            end
        else
            local enemyCreeps = npcBot:GetNearbyCreeps(1000, true);
            local enemyTowers = npcBot:GetNearbyTowers(1000, true);
            local enemyBarracks = npcBot:GetNearbyBarracks(1000, true);
            local enemyFillers = npcBot:GetNearbyFillers(1000, true);
            --local enemyBuildings = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);
            if (#allyHeroes <= 1 and #enemyHeroes > 1) and utility.IsEnemiesAroundStronger()
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -1000) + RandomVector(wanderRadius));
                return;
            else
                if (#enemyCreeps > 0) or npcBot:WasRecentlyDamagedByCreep(2.0)
                then
                    if (#enemyCreeps == 1)
                    then
                        mainCreep = enemyCreeps[1];
                    else
                        mainCreep = utility.GetWeakest(enemyCreeps);
                    end
                    npcBot:SetTarget(mainCreep);
                    --print(tostring(npcBot:GetTarget():GetUnitName()));
                    if utility.CanCastOnInvulnerableTarget(mainCreep)
                    then
                        if mainCreep ~= nil and (#enemyHeroes <= 1)
                        then
                            --npcBot:ActionImmediate_Chat("Атакую крипов на лайне.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainCreep, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне пока рядом 2+ врагов.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, крипы неуязвимы.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                        return;
                    end
                elseif (#enemyTowers > 0)
                then
                    if (#enemyTowers == 1)
                    then
                        mainBuilding = enemyTowers[1];
                    else
                        mainBuilding = utility.GetWeakest(enemyTowers);
                    end
                    npcBot:SetTarget(mainBuilding);
                    --print(tostring(npcBot:GetTarget():GetUnitName()));
                    if utility.CanCastOnInvulnerableTarget(mainBuilding)
                    then
                        if utility.CountAllyCreepAroundUnit(mainBuilding, 700) > 0
                        then
                            --npcBot:ActionImmediate_Chat("Атакую башню.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainBuilding, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне пока крипы не нападают на башню.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, башни неуязвимы.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                        return;
                    end
                elseif (#enemyBarracks > 0)
                then
                    if (#enemyBarracks == 1)
                    then
                        mainBuilding = enemyBarracks[1];
                    else
                        mainBuilding = utility.GetWeakest(enemyBarracks);
                    end
                    npcBot:SetTarget(mainBuilding);
                    --print(tostring(npcBot:GetTarget():GetUnitName()));
                    if utility.CanCastOnInvulnerableTarget(mainBuilding)
                    then
                        if utility.CountAllyCreepAroundUnit(mainBuilding, 700) > 0
                        then
                            --npcBot:ActionImmediate_Chat("Атакую баррак.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainBuilding, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне пока крипы не нападают на баррак.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, барраки неуязвимы.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                        return;
                    end
                elseif GetUnitToUnitDistance(npcBot, enemyAncient) <= 1000
                then
                    mainBuilding = enemyAncient;
                    npcBot:SetTarget(mainBuilding);
                    --print(tostring(npcBot:GetTarget():GetUnitName()));
                    if utility.CanCastOnInvulnerableTarget(mainBuilding)
                    then
                        if utility.CountAllyCreepAroundUnit(mainBuilding, 700) > 0
                        then
                            --npcBot:ActionImmediate_Chat("Атакую древнего.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainBuilding, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне, крипы не атакуют древнего.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, древний неуязвим.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                        return;
                    end
                elseif (#enemyFillers > 0)
                then
                    mainBuilding = utility.GetWeakest(enemyFillers);
                    npcBot:SetTarget(mainBuilding);
                    if utility.CanCastOnInvulnerableTarget(mainBuilding)
                    then
                        if utility.CountAllyCreepAroundUnit(mainBuilding, 700) > 0
                        then
                            --npcBot:ActionImmediate_Chat("Атакую постройку.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainBuilding, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне, крипы не атакуют постройку.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, постройка неуязвима.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                            RandomVector(wanderRadius));
                        return;
                    end
                    --[[           elseif (#enemyBuildings > 0)
                then
                    for _, enemy in pairs(enemyBuildings) do
                        if GetUnitToUnitDistance(npcBot, enemy) <= 1000 and string.find(enemy:GetUnitName(), "fillers")
                        then
                            mainBuilding = enemy;
                            npcBot:SetTarget(mainBuilding);
                        end
                    end
                    --print(tostring(npcBot:GetTarget():GetUnitName()));
                    if utility.CanCastOnInvulnerableTarget(mainBuilding)
                    then
                        if utility.CountAllyCreepAroundUnit(mainBuilding, 700) > 0
                        then
                            --npcBot:ActionImmediate_Chat("Атакую постройку.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(mainBuilding, false);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне, крипы не атакуют постройку.", true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Брожу на лайне, постройка неуязвима.", true);
                        npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) +
                            RandomVector(wanderRadius));
                        return;
                    end ]]
                else
                    --npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -500) + RandomVector(wanderRadius));
                    return;
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(push_generic) do _G._savedEnv[k] = v end
