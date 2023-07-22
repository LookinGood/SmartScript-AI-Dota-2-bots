---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_defend_tower_mid_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

function GetDesire()
    local npcBot = GetBot();

    if not utility.CanMove(npcBot)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    --local botHealth = npcBot:GetHealth() / npcBot:GetMaxHealth();
    --local botMode = npcBot:GetActiveMode();
    --local botDesire = npcBot:GetActiveModeDesire();
    local radiusUnit = 3000;

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
            if tower:GetHealth() / tower:GetMaxHealth() <= 0.9
            then
                if utility.CountEnemyCreepAroundUnit(tower, radiusUnit) >= 4 and utility.CountAllyCreepAroundUnit(tower, radiusUnit) < 4
                then
                    --npcBot:ActionImmediate_Chat("Я решил защищать башню на МИДУ от крипов!",true);
                    mainBuilding = tower;
                    return BOT_ACTION_DESIRE_HIGH;
                elseif (utility.CountEnemyHeroAroundUnit(tower, radiusUnit) >= 2 and utility.CountEnemyCreepAroundUnit(tower, radiusUnit) >= 1
                        and utility.CountAllyCreepAroundUnit(tower, radiusUnit) < 5)
                then
                    --npcBot:ActionImmediate_Chat("Я решил защищать башню на МИДУ от ГЕРОЕВ!",true);
                    mainBuilding = tower;
                    return BOT_ACTION_DESIRE_HIGH;
                end
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
            if barrack:GetHealth() / barrack:GetMaxHealth() <= 0.9
            then
                if utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) >= 4 and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) < 4
                then
                    --npcBot:ActionImmediate_Chat("Я решил защищать барраки на МИДУ от крипов!", true);
                    mainBuilding = barrack;
                    return BOT_ACTION_DESIRE_VERYHIGH;
                elseif (utility.CountEnemyHeroAroundUnit(barrack, radiusUnit) >= 2 and utility.CountEnemyCreepAroundUnit(barrack, radiusUnit) >= 1
                        and utility.CountAllyCreepAroundUnit(barrack, radiusUnit) <= 5)
                then
                    --npcBot:ActionImmediate_Chat("Я решил защищать барраки на МИДУ от героев!", true);
                    mainBuilding = barrack;
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    local ancient = GetAncient(GetTeam());
    if ancient ~= nil and not ancient:IsInvulnerable()
    then
        if (utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) >= 4 and utility.CountAllyCreepAroundUnit(ancient, radiusUnit) < 4) or
            (utility.CountEnemyCreepAroundUnit(ancient, radiusUnit) >= 1 and utility.CountEnemyHeroAroundUnit(ancient, radiusUnit) >= 1
                and utility.CountAllyCreepAroundUnit(ancient, radiusUnit) < 5)
        then
            --npcBot:ActionImmediate_Chat("Я решил защищать Древнего!", true);
            mainBuilding = ancient;
            return BOT_ACTION_DESIRE_ABSOLUTE;
        end
    end


    return BOT_ACTION_DESIRE_NONE;
end

function Think()
    local npcBot = GetBot();
    --local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    --local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
    local mainCreep = nil;
    local defendZonePatrol = nil;

    if mainBuilding ~= nil
    then
        local defendZone = utility.GetEscapeLocation(mainBuilding, 700);
        if defendZonePatrol == nil
        then
            if GetUnitToLocationDistance(npcBot, defendZone) > 700
            then
                npcBot:Action_MoveToLocation(defendZone);
            elseif GetUnitToLocationDistance(npcBot, defendZone) <= 700
            then
                defendZonePatrol = npcBot:GetLocation();
            end

            if defendZonePatrol ~= nil
            then
                if GetUnitToLocationDistance(npcBot, defendZonePatrol) <= 1600
                then
                    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                    local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
                    if (#enemyCreeps > 0) and (#enemyHeroes <= 1)
                    then
                        mainCreep = utility.GetWeakest(enemyCreeps);
                    else
                        npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(500));
                    end

                    if mainCreep ~= nil
                    then
                        if GetUnitToUnitDistance(npcBot, mainCreep) > attackRange
                        then
                            npcBot:Action_MoveToLocation(mainCreep:GetLocation());
                        else
                            npcBot:Action_AttackUnit(mainCreep, false);
                        end
                    else
                        npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(500));
                    end
                else
                    npcBot:Action_MoveToLocation(defendZonePatrol);
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_defend_tower_mid_generic) do _G._savedEnv[k] = v end
