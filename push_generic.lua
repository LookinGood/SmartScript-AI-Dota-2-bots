---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("push_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local retreatDistance = 1000;

function GetAllyCreepToRedirectTower(tower)
    local allyCreeps = npcBot:GetNearbyCreeps(tower:GetAttackRange() - 200, false);
    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if not ally:IsInvulnerable() and not ally:IsAttackImmune() and ally:GetHealth() / ally:GetMaxHealth() >= 0.5
                and ally:GetHealth() > npcBot:GetAttackDamage() and GetUnitToUnitDistance(ally, tower) <= tower:GetAttackRange()
            then
                --npcBot:ActionImmediate_Chat(ally:GetUnitName() .. " имеет здоровья: " .. ally:GetHealth() .. ", это больше чем сила моей атаки: " .. npcBot:GetAttackDamage(), true);
                return ally;
            end
        end
    end

    return nil;
end

function GetEnemyTowerNearAttackBot()
    local enemyTowers = npcBot:GetNearbyTowers(1600, true);
    if (#enemyTowers > 0)
    then
        for _, enemy in pairs(enemyTowers) do
            if enemy:GetAttackTarget() == npcBot
            then
                return enemy;
            end
        end
    end

    return nil;
end

function GetCurrentAttackTarget(radius)
    local enemyCreeps = npcBot:GetNearbyCreeps(radius, true);
    local enemyTowers = npcBot:GetNearbyTowers(radius, true);
    local enemyBarracks = npcBot:GetNearbyBarracks(radius, true);
    local enemyFillers = npcBot:GetNearbyFillers(radius, true);
    local enemyAncient = GetAncient(GetOpposingTeam());
    local attackTarget = nil;

    if (#enemyCreeps > 0)
    then
        attackTarget = utility.GetWeakest(enemyCreeps);
    elseif (#enemyTowers > 0)
    then
        attackTarget = utility.GetWeakest(enemyTowers);
    elseif (#enemyBarracks > 0)
    then
        attackTarget = utility.GetWeakest(enemyBarracks);
    elseif GetUnitToUnitDistance(npcBot, enemyAncient) <= radius
    then
        attackTarget = enemyAncient;
    elseif (#enemyFillers > 0)
    then
        attackTarget = utility.GetWeakest(enemyFillers);
    end

    return attackTarget;
end

function Think()
    npcBot = GetBot();
    local botMode = npcBot:GetActiveMode();
    local team = npcBot:GetTeam();
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

    local pushRadius = 300;
    local wanderRadius = 200;
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    --local enemyAncient = GetAncient(GetOpposingTeam());
    --local mainCreep = nil;
    --local mainBuilding = nil;

    --npcBot:WasRecentlyDamagedByAnyHero(3.0) or
    --utility.BotWasRecentlyDamagedByEnemyHero(3.0) or
    --npcBot:ActionImmediate_Chat("Отхожу от башни!", true);
    --npcBot:ActionImmediate_Ping(escapeLocation.x, escapeLocation.y, true);

    if utility.BotWasRecentlyDamagedByEnemyHero(3.0) or
        (npcBot:IsInvisible() and #allyHeroes < #enemyHeroes) or
        npcBot:IsDisarmed()
    then
        if retreatDistance < 3000
        then
            retreatDistance = retreatDistance + pushRadius;
        elseif retreatDistance >= 3000
        then
            retreatDistance = 1000;
        end
        npcBot:Action_ClearActions(false);
        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -retreatDistance) + RandomVector(wanderRadius));
        return;
    else
        local enemyTower = GetEnemyTowerNearAttackBot();
        if enemyTower ~= nil
        then
            local creepToRedirect = GetAllyCreepToRedirectTower(enemyTower);
            if creepToRedirect ~= nil
            then
                --npcBot:ActionImmediate_Chat("Переагриваю башню на " .. creepToRedirect:GetUnitName(), true);
                npcBot:Action_ClearActions(false);
                npcBot:Action_AttackUnit(creepToRedirect, true);
                return;
            else
                local escapeLocation = utility.GetEscapeLocation(npcBot, enemyTower:GetAttackRange() + wanderRadius);
                if GetUnitToLocationDistance(npcBot, escapeLocation) > 300
                then
                    --npcBot:ActionImmediate_Chat("Отхожу от башни!", true);
                    --npcBot:ActionImmediate_Ping(escapeLocation.x, escapeLocation.y, false);
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(escapeLocation);
                    return;
                else
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(wanderRadius));
                    return;
                end
            end
        else
            local frontlocation = GetLaneFrontLocation(team, lane, -pushRadius);
            local attackTarget = GetCurrentAttackTarget(1000);
            if GetUnitToLocationDistance(npcBot, frontlocation) > pushRadius and attackTarget == nil
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -pushRadius) + RandomVector(wanderRadius));
                return;
            else
                if utility.IsEnemiesAroundStronger()
                then
                    npcBot:Action_ClearActions(false);
                    npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -retreatDistance) +
                        RandomVector(wanderRadius));
                    return;
                else
                    if attackTarget ~= nil and GetUnitToLocationDistance(attackTarget, frontlocation) < 1000
                    then
                        if utility.CanCastOnInvulnerableTarget(attackTarget)
                        then
                            npcBot:SetTarget(attackTarget);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_AttackUnit(attackTarget, false);
                            --npcBot:ActionImmediate_Chat("Атакую цель: " .. attackTarget:GetUnitName(), true);
                            return;
                        else
                            --npcBot:ActionImmediate_Chat("Брожу на лайне, цель неуязвима: " .. attackTarget:GetUnitName(),true);
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -retreatDistance) +
                                RandomVector(wanderRadius));
                            return;
                        end
                    else
                        --npcBot:Action_ClearActions(false);
                        npcBot:Action_MoveToLocation(GetLaneFrontLocation(team, lane, -pushRadius) +
                            RandomVector(wanderRadius));
                        return;
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(push_generic) do _G._savedEnv[k] = v end
