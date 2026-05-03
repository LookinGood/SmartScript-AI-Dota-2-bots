---@diagnostic disable: undefined-global, param-type-mismatch, missing-parameter, need-check-nil
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local minAllyHeroes = 4;
local minHealthPrecent = 0.3;
local checkRadius = 5000;
local updateInterval = 660;
local lastRoshanKillTime = 0;
local roshanDayLocation = Vector(-3199.2, 2387.2, 38.9);
local roshanNightLocation = Vector(2908.1, -2834.1, 40.3);

local radiantDayWaitLocation = Vector(-3464.1, 541.3, 114.7);
local direDayWaitLocation = Vector(-1539.0, 2785.3, 143.9);

local radiantNightWaitLocation = Vector(1115.7, -3246.4, 166.2);
local direNightWaitLocation = Vector(2698.8, -1159.2, 98.3);

function GetRoshan()
    local creeps = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS);

    if (#creeps > 0)
    then
        for _, creep in pairs(creeps)
        do
            if utility.IsRoshan(creep)
            then
                return creep;
            end
        end
    end

    return nil;
end

function GetRoshanLocation()
    if DotaTime() < 15 * 60
    then
        return roshanDayLocation;
    else
        if not utility.IsNight()
        then
            --npcBot:ActionImmediate_Chat("День - Рошан в верхнем логове.", true);
            return roshanDayLocation;
        else
            --npcBot:ActionImmediate_Chat("Ночь - Рошан в нижнем логове.", true);
            return roshanNightLocation;
        end
    end
end

function GetPreparationLocation()
    if npcBot:GetTeam() == TEAM_RADIANT
    then
        if DotaTime() < 15 * 60
        then
            return radiantDayWaitLocation;
        else
            if not utility.IsNight()
            then
                return radiantDayWaitLocation;
            else
                return radiantNightWaitLocation;
            end
        end
    elseif npcBot:GetTeam() == TEAM_DIRE
    then
        if DotaTime() < 15 * 60
        then
            return direDayWaitLocation;
        else
            if not utility.IsNight()
            then
                return direDayWaitLocation;
            else
                return direNightWaitLocation;
            end
        end
    else
        return Vector(0, 0, 0);
    end
end

function IsHeroReadyForRoshan(npcTarget)
    local enemyHeroes = npcTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    return npcTarget:GetHealth() / npcTarget:GetMaxHealth() > minHealthPrecent and npcTarget:GetLevel() >= 10 and
        (#enemyHeroes <= 0)
end

function GetCountAllyHeroesAroundPreparationLoc(location, radius)
    local count = 0;
    local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#unitsList > 0)
    then
        for _, unit in pairs(unitsList)
        do
            local enemyHeroes = unit:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if not unit:IsIllusion() and GetUnitToLocationDistance(unit, location) <= radius and IsHeroReadyForRoshan(unit)
                and (#enemyHeroes <= 0)
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function IsAllyHeroAttackRoshan(roshanLocation)
    local unitsList = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#unitsList > 0)
    then
        for _, unit in pairs(unitsList)
        do
            if not unit:IsIllusion() and utility.IsRoshan(unit:GetAttackTarget()) and GetUnitToLocationDistance(unit, roshanLocation) <= checkRadius
            then
                return true;
            end
        end
    end

    return false;
end

function GetDesire()
    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsBaseUnderAttack() or utility.IsEnemyBaseUnderAttack()
        or not IsHeroReadyForRoshan(npcBot) or GetGameState() == GAME_STATE_PRE_GAME
    then
        return BOT_MODE_DESIRE_NONE;
    end

    --print(GetRoshanKillTime())
    --print(currentTime - roshanKillTime)

    npcRoshan = GetRoshan();
    roshanLocation = GetRoshanLocation();
    preparationLocation = GetPreparationLocation();

    local currentKillTime = GetRoshanKillTime();

    if currentKillTime ~= lastRoshanKillTime
    then
        lastRoshanKillTime = currentKillTime
        --[[     if currentKillTime ~= 0
        then
            print("Рошан убит в ", currentKillTime);
        end ]]
    end

    local currentTime = DotaTime();
    local isRoshanAlive = (lastRoshanKillTime == 0) or (currentTime - lastRoshanKillTime >= updateInterval);

    if isRoshanAlive
    then
        --print("Рошан жив.")
        local countAllyHeroesNear = GetCountAllyHeroesAroundPreparationLoc(preparationLocation, checkRadius);

        if GetUnitToLocationDistance(npcBot, preparationLocation) <= checkRadius and countAllyHeroesNear >= minAllyHeroes
        then
            --npcBot:ActionImmediate_Ping(roshanLocation.x, roshanLocation.y, false);
            --npcBot:ActionImmediate_Chat("Рядом есть доступный Рошан.", true);
            return BOT_MODE_DESIRE_VERYHIGH;
        end
        --[[    else
        print("Рошан мёртв.") ]]
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(15)
    then
        npcBot:ActionImmediate_Chat("Атакую Рошана!", false);
        npcBot:ActionImmediate_Ping(roshanLocation.x, roshanLocation.y, true);
    end
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local boundRadius = npcBot:GetBoundingRadius();

    if npcRoshan ~= nil
    then
        if GetUnitToLocationDistance(npcRoshan, roshanLocation) <= 300
        then
            if GetUnitToLocationDistance(npcBot, roshanLocation) < 360
            then
                npcBot:SetTarget(npcRoshan);
                if npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6 and npcRoshan:GetAttackTarget() == npcBot
                then
                    --npcBot:ActionImmediate_Chat(npcBot:GetTarget():GetUnitName() .. " атакует меня, отхожу в зону ожидания.", true);
                    npcBot:Action_MoveToLocation(preparationLocation);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Атакую " .. npcBot:GetTarget():GetUnitName(), true);
                    npcBot:Action_AttackUnit(npcRoshan, false);
                    return;
                end
            else
                --npcBot:ActionImmediate_Chat("Подхожу ближе к Рошану для атаки.", true);
                npcBot:Action_MoveToLocation(roshanLocation);
                return;
            end
        else
            if GetUnitToLocationDistance(npcBot, preparationLocation) > npcBot:GetAcquisitionRange()
            then
                --npcBot:ActionImmediate_Chat("Рошан недоступен для атаки, отхожу в зону ожидания.", true);
                npcBot:Action_MoveToLocation(preparationLocation);
                return;
            else
                --npcBot:ActionImmediate_Chat("Рошан недоступен для атаки, ожидаю.", true);
                npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(boundRadius * 2));
                return;
            end
        end
    else
        if GetCountAllyHeroesAroundPreparationLoc(roshanLocation, 4000) >= minAllyHeroes
        then
            if GetUnitToLocationDistance(npcBot, roshanLocation) > 200
            then
                --npcBot:ActionImmediate_Chat("Герои готовы, иду в Логово Рошана.", true);
                npcBot:Action_MoveToLocation(roshanLocation);
                return;
            else
                --npcBot:ActionImmediate_Chat("Рошана нет в логове, ожидаю.", true);
                npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(boundRadius * 2));
                return;
            end
        else
            if preparationLocation ~= nil
            then
                if GetUnitToLocationDistance(npcBot, preparationLocation) > npcBot:GetAcquisitionRange()
                then
                    --npcBot:ActionImmediate_Chat("Иду к зоне ожидания (Рошан не замечен)", true);
                    npcBot:Action_MoveToLocation(preparationLocation);
                    return;
                else
                    --npcBot:ActionImmediate_Chat("Героев рядом в зоне подготовки недостаточно, ожидаю.", true);
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(boundRadius * 2));
                    return;
                end
            end
        end
    end
end
