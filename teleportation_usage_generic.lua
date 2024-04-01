---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("teleportation_usage_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

--local utility = require(GetScriptDirectory() .. "/utility")

function IsValidTower(target)
    return target ~= nil and
        target:CanBeSeen() and
        target:IsAlive() and
        not target:IsInvulnerable()
end

function ClosestSafeBuilding(unit, distance, enemyRadius, enemyCount)
    local npcBot = GetBot();
    local safeBuilding = nil;
    local ancient = GetAncient(GetTeam());
    local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local allyHeroes = utility.CountAllyHeroAroundUnit(unit, enemyRadius)
    local enemyHeroes = utility.CountEnemyHeroAroundUnit(unit, enemyRadius);
    if (enemyHeroes <= enemyCount) or (allyHeroes >= 1) or (unit == ancient)
    then
        safeBuilding = unit;
        return safeBuilding;
    else
        for _, building in pairs(allyBuildings)
        do
            if building ~= unit
            then
                local enemyHeroes = utility.CountEnemyHeroAroundUnit(building, enemyRadius);
                if GetUnitToUnitDistance(unit, building) <= distance and GetUnitToUnitDistance(npcBot, building) > distance
                    and (enemyHeroes <= enemyCount)
                then
                    safeBuilding = building;
                    return safeBuilding;
                end
            end
        end
    end

    return safeBuilding;
end

--[[ function ClosestSafeBuilding(unit, distance, enemyRadius, enemyCount)
    local npcBot = GetBot();
    local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local safeBuilding = nil;
    local enemyAncient = GetAncient(GetOpposingTeam());

    local enemyHeroes = utility.CountEnemyHeroAroundUnit(unit, enemyRadius);
    if enemyHeroes <= enemyCount
    then
        safeBuilding = unit;
    else
        if (#allyBuildings > 0)
        then
            for i = 1, #allyBuildings do
                if allyBuildings[i] ~= unit and GetUnitToUnitDistance(allyBuildings[i], unit) < GetUnitToUnitDistance(npcBot, unit)
                    and GetUnitToUnitDistance(npcBot, allyBuildings[i]) > distance
                then
                    if GetUnitToUnitDistance(allyBuildings[i], enemyAncient) > GetUnitToUnitDistance(npcBot, enemyAncient)
                        and allyBuildings[i]:DistanceFromFountain() < npcBot:DistanceFromFountain()
                    then
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(allyBuildings[i], enemyRadius);
                        if enemyHeroes <= enemyCount
                        then
                            safeBuilding = allyBuildings[i];
                        end
                    end
                end
            end
        end
    end

    return safeBuilding;
end ]]

function ShouldTP()
    local npcBot = GetBot();
    if utility.IsHaveMaxSpeed(npcBot)
    then
        return false, nil;
    end

    local enemyTower = npcBot:GetNearbyTowers(1000, true);
    if (#enemyTower > 0)
    then
        return false, nil;
    end

    --local tpLocation = nil;
    local towerLaning = nil;
    local towerDefend = nil;
    local towerPush = nil;
    local botMode = npcBot:GetActiveMode();
    local botLoc = npcBot:GetLocation();
    local botTeam = GetTeam();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    --local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local tpDistance = 4000;
    local minTpDistance = 6000;
    local ancient = GetAncient(GetTeam());
    local enemyAncient = GetAncient(GetOpposingTeam());
    local topTower1 = GetTower(GetTeam(), TOWER_TOP_1);
    local topTower2 = GetTower(GetTeam(), TOWER_TOP_2);
    local topTower3 = GetTower(GetTeam(), TOWER_TOP_3);
    local midTower1 = GetTower(GetTeam(), TOWER_MID_1);
    local midTower2 = GetTower(GetTeam(), TOWER_MID_2);
    local midTower3 = GetTower(GetTeam(), TOWER_MID_3);
    local botTower1 = GetTower(GetTeam(), TOWER_BOT_1);
    local botTower2 = GetTower(GetTeam(), TOWER_BOT_2);
    local botTower3 = GetTower(GetTeam(), TOWER_BOT_3);

    if botMode == BOT_MODE_RETREAT
    then
        if npcBot:DistanceFromFountain() > tpDistance
        then
            if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4) or
                (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6 and npcBot:WasRecentlyDamagedByAnyHero(2.0)) or
                (not utility.CanMove(npcBot) and (#allyHeroes < 2) and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6))
            then
                --npcBot:ActionImmediate_Chat("Использую tpscroll для отступления!", true);
                return true, utility.SafeLocation(npcBot);
            end
        end
    end

    if (utility.IsBaseUnderAttack() and npcBot:DistanceFromFountain() <= 3000) or (#enemyHeroes > 0)
    then
        return false, nil;
    end

    if botMode == BOT_MODE_LANING
    then
        local assignedLane = npcBot:GetAssignedLane();
        if towerLaning == nil
        then
            if assignedLane == LANE_TOP
            then
                if IsValidTower(topTower1)
                then
                    towerLaning = topTower1;
                    --npcBot:SetTarget(topTower1)
                elseif IsValidTower(topTower2)
                then
                    towerLaning = topTower2;
                elseif IsValidTower(topTower3)
                then
                    towerLaning = topTower3;
                end
            elseif assignedLane == LANE_MID
            then
                if IsValidTower(midTower1)
                then
                    towerLaning = midTower1;
                elseif IsValidTower(midTower2)
                then
                    towerLaning = midTower2;
                elseif IsValidTower(midTower3)
                then
                    towerLaning = midTower3;
                end
            elseif assignedLane == LANE_BOT
            then
                if IsValidTower(botTower1)
                then
                    towerLaning = botTower1;
                elseif IsValidTower(botTower2)
                then
                    towerLaning = botTower2;
                elseif IsValidTower(botTower3)
                then
                    towerLaning = botTower3;
                end
            end
        end
        if towerLaning ~= nil
        then
            local botAmount = GetAmountAlongLane(assignedLane, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, assignedLane, false);
            if GetUnitToUnitDistance(npcBot, towerLaning) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerLaning, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для лайнинга на линии!", true);
                    return true, utility.GetEscapeLocation(tpTarget, 800);
                end
            end
        end
    end

    if botMode == BOT_MODE_DEFEND_TOWER_TOP
    then
        if towerDefend == nil
        then
            if IsValidTower(topTower1)
            then
                towerDefend = topTower1;
            elseif IsValidTower(topTower2)
            then
                towerDefend = topTower2;
            elseif IsValidTower(topTower3)
            then
                towerDefend = topTower3;
            else
                towerDefend = ancient;
            end
        end
        if towerDefend ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_TOP, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_TOP, false);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerDefend, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для дефа топа!", true);
                    return true, utility.GetEscapeLocation(tpTarget, 800);
                end
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_MID
    then
        if towerDefend == nil
        then
            if IsValidTower(midTower1)
            then
                towerDefend = midTower1;
            elseif IsValidTower(midTower2)
            then
                towerDefend = midTower2;
            elseif IsValidTower(midTower3)
            then
                towerDefend = midTower3;
            else
                towerDefend = ancient;
            end
        end
        if towerDefend ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_MID, false);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerDefend, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для дефа мида!", true);
                    return true, utility.GetEscapeLocation(tpTarget, 800);
                end
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_BOT
    then
        if towerDefend == nil
        then
            if IsValidTower(botTower1)
            then
                towerDefend = botTower1;
            elseif IsValidTower(botTower2)
            then
                towerDefend = botTower2;
            elseif IsValidTower(botTower3)
            then
                towerDefend = botTower3;
            else
                towerDefend = ancient;
            end
        end
        if towerDefend ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_BOT, false);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerDefend, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    -- npcBot:ActionImmediate_Chat("Использую tpscroll для дефа бота!", true);
                    return true, utility.GetEscapeLocation(tpTarget, 800);
                end
            end
        end
    end

    if botMode == BOT_MODE_PUSH_TOWER_TOP
    then
        local enemytopTower1 = GetTower(GetOpposingTeam(), TOWER_TOP_1);
        local enemytopTower2 = GetTower(GetOpposingTeam(), TOWER_TOP_2);
        local enemytopTower3 = GetTower(GetOpposingTeam(), TOWER_TOP_3);
        if towerPush == nil
        then
            if IsValidTower(enemytopTower1)
            then
                towerPush = enemytopTower1;
            elseif IsValidTower(enemytopTower2)
            then
                towerPush = enemytopTower2;
            elseif IsValidTower(enemytopTower3)
            then
                towerPush = enemytopTower3;
            else
                towerPush = enemyAncient;
            end
        end
        if towerPush ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_TOP, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_TOP, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerPush, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll пуша топа!", true);
                    return true, tpTarget:GetLocation() + RandomVector(300);
                end
            end
        end
    elseif botMode == BOT_MODE_PUSH_TOWER_MID
    then
        local enemymidTower1 = GetTower(GetOpposingTeam(), TOWER_MID_1);
        local enemymidTower2 = GetTower(GetOpposingTeam(), TOWER_MID_2);
        local enemymidTower3 = GetTower(GetOpposingTeam(), TOWER_MID_3);
        if towerPush == nil
        then
            if IsValidTower(enemymidTower1)
            then
                towerPush = enemymidTower1;
            elseif IsValidTower(enemymidTower2)
            then
                towerPush = enemymidTower2;
            elseif IsValidTower(enemymidTower3)
            then
                towerPush = enemymidTower3;
            else
                towerPush = enemyAncient;
            end
        end
        if towerPush ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_MID, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerPush, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll пуша мида!", true);
                    return true, tpTarget:GetLocation() + RandomVector(300);
                end
            end
        end
    elseif botMode == BOT_MODE_PUSH_TOWER_BOT
    then
        local enemybotTower1 = GetTower(GetOpposingTeam(), TOWER_BOT_1);
        local enemybotTower2 = GetTower(GetOpposingTeam(), TOWER_BOT_2);
        local enemybotTower3 = GetTower(GetOpposingTeam(), TOWER_BOT_3);
        if towerPush == nil
        then
            if IsValidTower(enemybotTower1)
            then
                towerPush = enemybotTower1;
            elseif IsValidTower(enemybotTower2)
            then
                towerPush = enemybotTower2;
            elseif IsValidTower(enemybotTower3)
            then
                towerPush = enemybotTower3;
            else
                towerPush = enemyAncient;
            end
        end
        if towerPush ~= nil
        then
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_BOT, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local tpTarget = ClosestSafeBuilding(towerPush, minTpDistance, 1000, 2)
                if tpTarget ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую tpscroll пуша бота!", true);
                    return true, tpTarget:GetLocation() + RandomVector(300);
                end
            end
        end
    end

    return false, nil;
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(teleportation_usage_generic) do _G._savedEnv[k] = v end


--local myTeam = GetTeam();
--local enemyTeam = GetOpposingTeam();


--[[         --if assignedLane == LANE_TOP then
        elseif assignedLane == LANE_MID then
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc)
            --local laneFront = GetLaneFrontAmount(myTeam, LANE_MID, false)
            if GetUnitToLocationDistance(npcBot, botAmount) > tpDistance then
                tpLocation = botAmount
                npcBot:ActionImmediate_Chat("Использую tpscroll для лайнинга на миде!", true);
                return true, tpLocation;
            end
        elseif assignedLane == LANE_BOT then
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc)
            --local laneFront = GetLaneFrontAmount(myTeam, LANE_BOT, false)
            if GetUnitToLocationDistance(npcBot, botAmount) > tpDistance then
                tpLocation = botAmount
                npcBot:ActionImmediate_Chat("Использую tpscroll для лайнинга на боте!", true);
                return true, tpLocation;
            end
        end ]]
