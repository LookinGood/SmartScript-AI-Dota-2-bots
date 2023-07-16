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

    local tpLocation = nil;
    local botMode = npcBot:GetActiveMode();
    local botLoc = npcBot:GetLocation();
    local botTeam = GetTeam();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    --local allyShrines = npcBot:GetNearbyShrines(1600, false);
    local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local enemyTower = npcBot:GetNearbyTowers(1000, true);
    local tpDistance = 4000;
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
    local enemytopTower1 = GetTower(GetOpposingTeam(), TOWER_TOP_1);
    local enemytopTower2 = GetTower(GetOpposingTeam(), TOWER_TOP_2);
    local enemytopTower3 = GetTower(GetOpposingTeam(), TOWER_TOP_3);
    local enemymidTower1 = GetTower(GetOpposingTeam(), TOWER_MID_1);
    local enemymidTower2 = GetTower(GetOpposingTeam(), TOWER_MID_2);
    local enemymidTower3 = GetTower(GetOpposingTeam(), TOWER_MID_3);
    local enemybotTower1 = GetTower(GetOpposingTeam(), TOWER_BOT_1);
    local enemybotTower2 = GetTower(GetOpposingTeam(), TOWER_BOT_2);
    local enemybotTower3 = GetTower(GetOpposingTeam(), TOWER_BOT_3);

    if botMode == BOT_MODE_RETREAT
    then
        if npcBot:DistanceFromFountain() > tpDistance and (#enemyTower == 0)
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
    if botMode == BOT_MODE_LANING
    then
        local assignedLane = npcBot:GetAssignedLane();
        local botAmount = GetAmountAlongLane(assignedLane, botLoc);
        local laneFront = GetLaneFrontAmount(botTeam, assignedLane, false);
        if assignedLane == LANE_TOP then
            if topTower1 ~= nil and not topTower1:IsInvulnerable()
            then
                towerLaning = topTower1;
            elseif topTower2 ~= nil and not topTower2:IsInvulnerable()
            then
                towerLaning = topTower2;
            elseif topTower3 ~= nil and not topTower3:IsInvulnerable()
            then
                towerLaning = topTower3;
            end
        elseif assignedLane == LANE_MID then
            if midTower1 ~= nil and not midTower1:IsInvulnerable()
            then
                towerLaning = midTower1;
            elseif midTower2 ~= nil and not midTower2:IsInvulnerable()
            then
                towerLaning = midTower2;
            elseif midTower3 ~= nil and not midTower3:IsInvulnerable()
            then
                towerLaning = midTower3;
            end
        elseif assignedLane == LANE_BOT then
            if botTower1 ~= nil and not botTower1:IsInvulnerable()
            then
                towerLaning = botTower1;
            elseif botTower2 ~= nil and not botTower2:IsInvulnerable()
            then
                towerLaning = botTower2;
            elseif botTower3 ~= nil and not botTower3:IsInvulnerable()
            then
                towerLaning = botTower3;
            end
        end
        if towerLaning ~= nil and #enemyHeroes == 0 and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            and utility.CountEnemyHeroAroundUnit(towerLaning, 700) <= 2
        then
            tpLocation = utility.GetEscapeLocation(towerLaning, 800)
            --npcBot:ActionImmediate_Chat("Использую tpscroll для лайнинга на линии!", true);
            return true, tpLocation;
        end
    end

    if botMode == BOT_MODE_DEFEND_TOWER_TOP then
        if topTower1 ~= nil and not topTower1:IsInvulnerable()
        then
            towerDefend = topTower1;
        elseif topTower2 ~= nil and not topTower2:IsInvulnerable()
        then
            towerDefend = topTower2;
        elseif topTower3 ~= nil and not topTower3:IsInvulnerable()
        then
            towerDefend = topTower3;
        end
        if towerDefend ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
            and utility.CountEnemyHeroAroundUnit(towerDefend, 1000) <= 1
        then
            local botAmount = GetAmountAlongLane(LANE_TOP, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_TOP, false);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                --npcBot:ActionImmediate_Chat("Использую tpscroll для защиты топа!", true);
                return true, utility.GetEscapeLocation(towerDefend, 800)
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_MID
    then
        if midTower1 ~= nil and not midTower1:IsInvulnerable()
        then
            towerDefend = midTower1;
        elseif midTower2 ~= nil and not midTower2:IsInvulnerable()
        then
            towerDefend = midTower2;
        elseif midTower3 ~= nil and not midTower3:IsInvulnerable()
        then
            towerDefend = midTower3;
        elseif (midTower1 == nil and midTower2 == nil and midTower3 == nil)
        then
            towerDefend = ancient;
        end
        if towerDefend ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
        then
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_MID, false);
            local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerDefend, 1000);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
                and enemyHeroes <= 1
            then
                --npcBot:ActionImmediate_Chat("Использую tpscroll для защиты мида!", true);
                return true, utility.GetEscapeLocation(towerDefend, 800)
            end
        end
    elseif botMode == BOT_MODE_DEFEND_TOWER_BOT
    then
        if botTower1 ~= nil and not botTower1:IsInvulnerable()
        then
            towerDefend = botTower1;
        elseif botTower2 ~= nil and not botTower2:IsInvulnerable()
        then
            towerDefend = botTower2;
        elseif botTower3 ~= nil and not botTower3:IsInvulnerable()
        then
            towerDefend = botTower3;
        end
        if towerDefend ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
        then
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_BOT, false);
            local enemyHeroes = utility.CountEnemyHeroAroundUnit(towerDefend, 1000);
            if GetUnitToUnitDistance(npcBot, towerDefend) >= tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            and enemyHeroes <= 1
            then
                --npcBot:ActionImmediate_Chat("Использую tpscroll для защиты бота!", true);
                return true, GetEscapeLocation(towerDefend, 800)
            end
        end
    end

    if botMode == BOT_MODE_PUSH_TOWER_TOP
    then
        if enemytopTower1 ~= nil and not enemytopTower1:IsInvulnerable()
        then
            towerPush = enemytopTower1;
        elseif enemytopTower2 ~= nil and not enemytopTower2:IsInvulnerable()
        then
            towerPush = enemytopTower2;
        elseif enemytopTower3 ~= nil and not enemytopTower3:IsInvulnerable()
        then
            towerPush = enemytopTower3;
        end
        if towerPush ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
        then
            local botAmount = GetAmountAlongLane(LANE_TOP, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_TOP, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= tpDistance and (enemyHeroes <= 1)
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
        if enemymidTower1 ~= nil and not enemymidTower1:IsInvulnerable()
        then
            towerPush = enemymidTower1;
        elseif enemymidTower2 ~= nil and not enemymidTower2:IsInvulnerable()
        then
            towerPush = enemymidTower2;
        elseif enemymidTower3 ~= nil and not enemymidTower3:IsInvulnerable()
        then
            towerPush = enemymidTower3;
        elseif (enemymidTower1 == nil and enemymidTower2 == nil and enemymidTower3 == nil)
        then
            towerPush = enemyAncient;
        end
        if towerPush ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
        then
            local botAmount = GetAmountAlongLane(LANE_MID, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_MID, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= tpDistance and (enemyHeroes <= 1)
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
        if enemybotTower1 ~= nil and not enemybotTower1:IsInvulnerable()
        then
            towerPush = enemybotTower1;
        elseif enemybotTower2 ~= nil and not enemybotTower2:IsInvulnerable()
        then
            towerPush = enemybotTower2;
        elseif enemybotTower3 ~= nil and not enemybotTower3:IsInvulnerable()
        then
            towerPush = enemybotTower3;
        end
        if towerPush ~= nil and (#enemyHeroes == 0 and #enemyTower == 0)
        then
            local botAmount = GetAmountAlongLane(LANE_BOT, botLoc);
            local laneFront = GetLaneFrontAmount(botTeam, LANE_BOT, false);
            if GetUnitToUnitDistance(npcBot, towerPush) > tpDistance and (botAmount.distance >= tpDistance or botAmount.amount < laneFront / 5)
            then
                if #allyBuildings > 1
                then
                    for _, ally in pairs(allyBuildings) do
                        local enemyHeroes = utility.CountEnemyHeroAroundUnit(ally, 1000);
                        if GetUnitToUnitDistance(ally, towerPush) < GetUnitToUnitDistance(npcBot, towerPush) and
                            GetUnitToUnitDistance(npcBot, ally) >= tpDistance and (enemyHeroes <= 1)
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
