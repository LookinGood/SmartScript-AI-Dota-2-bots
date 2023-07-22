---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("teleportation_usage_generic", package.seeall)

require(GetScriptDirectory() .. "/utility")

--local utility = require(GetScriptDirectory() .. "/utility")

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

    local tpLocation = nil;
    local towerLaning = nil;
    local towerDefend = nil;
    local towerPush = nil;
    local botMode = npcBot:GetActiveMode();
    local botLoc = npcBot:GetLocation();
    local botTeam = GetTeam();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local tpDistance = 4000;
    local minTpDistance = 3000;
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
            if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6 and npcBot:WasRecentlyDamagedByAnyHero(2.0)) or (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4)
                or (not utility.CanMove(npcBot) and (#allyHeroes < 2) and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6))
            then
                tpLocation = utility.SafeLocation(npcBot);
                --npcBot:ActionImmediate_Chat("Использую tpscroll для отступления!", true);
                return true, tpLocation;
            end
        end
    end

    if (#enemyHeroes > 0)
    then
        return false, nil;
    end

    if botMode == BOT_MODE_LANING
    then
        if towerLaning == nil
        then
            if assignedLane == LANE_TOP
            then
                if utility.IsValidTarget(topTower1)
                then
                    towerLaning = topTower1;
                elseif utility.IsValidTarget(topTower2)
                then
                    towerLaning = topTower2;
                elseif utility.IsValidTarget(topTower3)
                then
                    towerLaning = topTower3;
                end
            elseif assignedLane == LANE_MID
            then
                if utility.IsValidTarget(midTower1)
                then
                    towerLaning = midTower1;
                elseif utility.IsValidTarget(midTower2)
                then
                    towerLaning = midTower2;
                elseif utility.IsValidTarget(midTower3)
                then
                    towerLaning = midTower3;
                end
            elseif assignedLane == LANE_BOT
            then
                if utility.IsValidTarget(botTower1)
                then
                    towerLaning = botTower1;
                elseif utility.IsValidTarget(botTower2)
                then
                    towerLaning = botTower2;
                elseif utility.IsValidTarget(botTower3)
                then
                    towerLaning = botTower3;
                end
            end
        end

        if towerLaning ~= nil
        then
            local assignedLane = npcBot:GetAssignedLane();
            local botAmount = GetAmountAlongLane(assignedLane, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, assignedLane, false);
            if GetUnitToUnitDistance(npcBot, towerLaning) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerLaning, 1000);
                if (enemyHeroes <= 2)
                then
                    return true, utility.GetEscapeLocation(towerLaning, 800);
                else
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerLaning) < GetUnitToUnitDistance(npcBot, towerLaning) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 2)
                        then
                            --npcBot:ActionImmediate_Chat("Использую tpscroll для лайнинга на линии!",true);
                            return true, utility.GetEscapeLocation(ally, 800);
                        end
                    end
                end
            end
        end
    end

    if botMode == BOT_MODE_DEFEND_TOWER_TOP
    then
        if towerDefend == nil
        then
            if utility.IsValidTarget(topTower1)
            then
                towerDefend = topTower1;
            elseif utility.IsValidTarget(topTower2)
            then
                towerDefend = topTower2;
            elseif utility.IsValidTarget(topTower3)
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
                local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerDefend, 1000);
                if (enemyHeroes <= 2)
                then
                    return true, utility.GetEscapeLocation(towerDefend, 800);
                else
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerDefend) < GetUnitToUnitDistance(npcBot, towerDefend) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            --npcBot:ActionImmediate_Chat("Использую tpscroll для дефа топа!", true);
                            return true, utility.GetEscapeLocation(ally, 800);
                        end
                    end
                end
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_MID
    then
        if towerDefend == nil
        then
            if utility.IsValidTarget(midTower1)
            then
                towerDefend = midTower1;
            elseif utility.IsValidTarget(midTower2)
            then
                towerDefend = midTower2;
            elseif utility.IsValidTarget(midTower3)
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
                local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerDefend, 1000);
                if (enemyHeroes <= 2)
                then
                    return true, utility.GetEscapeLocation(towerDefend, 800);
                else
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerDefend) < GetUnitToUnitDistance(npcBot, towerDefend) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            --npcBot:ActionImmediate_Chat("Использую tpscroll для дефа мида!", true);
                            return true, utility.GetEscapeLocation(ally, 800);
                        end
                    end
                end
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_BOT
    then
        if towerDefend == nil
        then
            if utility.IsValidTarget(botTower1)
            then
                towerDefend = botTower1;
            elseif utility.IsValidTarget(botTower2)
            then
                towerDefend = botTower2;
            elseif utility.IsValidTarget(botTower3)
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
                local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerDefend, 1000);
                if (enemyHeroes <= 2)
                then
                    return true, utility.GetEscapeLocation(towerDefend, 800);
                else
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerDefend) < GetUnitToUnitDistance(npcBot, towerDefend) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            --npcBot:ActionImmediate_Chat("Использую tpscroll для дефа бота!", true);
                            return true, utility.GetEscapeLocation(ally, 800);
                        end
                    end
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
            if utility.IsValidTarget(enemytopTower1)
            then
                towerPush = enemytopTower1;
            elseif utility.IsValidTarget(enemytopTower2)
            then
                towerPush = enemytopTower2;
            elseif utility.IsValidTarget(enemytopTower3)
            then
                towerPush = enemytopTower3;
            else
                towerPush = enemyAncient;
            end
        else
            local botAmount = GetAmountAlongLane(LANE_TOP, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_TOP, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            return true, ally:GetLocation();
                        end
                    end
                else
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для пуша мида!", true);
                    return true, towerPush:GetLocation();
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
            if utility.IsValidTarget(enemymidTower1)
            then
                towerPush = enemymidTower1;
            elseif utility.IsValidTarget(enemymidTower2)
            then
                towerPush = enemymidTower2;
            elseif utility.IsValidTarget(enemymidTower3)
            then
                towerPush = enemymidTower3;
            else
                towerPush = enemyAncient;
            end
        else
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_MID, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            return true, ally:GetLocation();
                        end
                    end
                else
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для пуша мида!", true);
                    return true, towerPush:GetLocation();
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
            if utility.IsValidTarget(enemybotTower1)
            then
                towerPush = enemybotTower1;
            elseif utility.IsValidTarget(enemybotTower2)
            then
                towerPush = enemybotTower2;
            elseif utility.IsValidTarget(enemybotTower3)
            then
                towerPush = enemybotTower3;
            else
                towerPush = enemyAncient;
            end
        else
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_BOT, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= minTpDistance and (enemyHeroes <= 1)
                        then
                            return true, ally:GetLocation();
                        end
                    end
                else
                    --npcBot:ActionImmediate_Chat("Использую tpscroll для пуша мида!", true);
                    return true, towerPush:GetLocation();
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
