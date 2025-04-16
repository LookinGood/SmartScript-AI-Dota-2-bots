---@diagnostic disable: undefined-global, missing-parameter
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/hero_role_generic")

local npcBot = GetBot();
local realCamps = {};
local updateInterval = 60;
local lastUpdateTime = 0;

-- Debugg
--[[ local function printObjectFields(object)
    for key, value in pairs(object) do
        if type(value) == "table" then
            print(key .. ":")
            printObjectFields(value)              -- Рекурсивный вызов для таблиц
        else
            print(key .. ": " .. tostring(value)) -- Преобразование значения в строку
        end
    end
end ]]

function GetCountAllDeadHeroes()
    local countAllyHeroes = 0;
    local countEnemyHeroes = 0;

    local allyPlayers = GetTeamPlayers(GetTeam());
    local enemyPlayers = GetTeamPlayers(GetOpposingTeam());

    for _, i in pairs(allyPlayers)
    do
        if not IsHeroAlive(i)
        then
            countAllyHeroes = countAllyHeroes + 1;
        end
    end

    for _, i in pairs(enemyPlayers)
    do
        if not IsHeroAlive(i)
        then
            countEnemyHeroes = countEnemyHeroes + 1;
        end
    end

    return countAllyHeroes, countEnemyHeroes, #allyPlayers, #enemyPlayers;
end

function UpdateCreepCamps()
    local camps = GetNeutralSpawners();

    if (#camps > 0)
    then
        for i = #camps, 1, -1 do
            if camps[i].team == npcBot:GetTeam()
            then
                table.insert(realCamps, camps[i])
            end
        end
    end

    --[[     if (#camps > 0)
    then
        for _, camp in ipairs(camps) do
            if IsRadiusVisible(camp.location, 300)
            then
                if HasNeutralCreepsInCamp(camp.location)
                then
                    table.insert(realCamps, camp);
                end
            end
        end
    end ]]
end

function HasNeutralCreepsInCamp(campLocation)
    local creeps = GetUnitList(UNIT_LIST_NEUTRAL_CREEPS);

    if (#creeps > 0)
    then
        for _, creep in pairs(creeps)
        do
            if creep:CanBeSeen() and creep:IsAlive() and GetUnitToLocationDistance(creep, campLocation) <= 600
            then
                return true;
            end
        end
    end

    return false;
end

function HasAllyHeroInCamp(campLocation)
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes)
        do
            if string.find(npcBot:GetUnitName(), "meepo") and string.find(ally:GetUnitName(), "meepo")
                and npcBot:GetPlayerID() == ally:GetPlayerID()
            then
                return false;
            else
                if ally ~= npcBot and not ally:IsIllusion() and GetUnitToLocationDistance(ally, campLocation) <= 600
                    and ally:GetAttackTarget():IsCreep()
                then
                    return true;
                end
            end
        end
    end

    return false;
end

function GetClosestAvailableCreepCamp()
    local closestCampLocation = nil;
    local distance = 100000;
    local camps = realCamps;
    local botLevel = npcBot:GetLevel();

    --print(#camps);
    --printObjectFields(camps)

    if (#camps > 0)
    then
        for _, camp in pairs(camps)
        do
            if camp.team == npcBot:GetTeam()
            then
                if (botLevel >= 6 and botLevel < 12)
                then
                    if (camp.type == "small")
                    then
                        local unitDistance = GetUnitToLocationDistance(npcBot, camp.location)
                        if unitDistance < distance
                        then
                            closestCampLocation = camp.location;
                            distance = unitDistance;
                            --npcBot:ActionImmediate_Chat("Рядом есть доступный малый лагерь крипов!", true);
                            --npcBot:ActionImmediate_Ping(closestCampLocation.x, closestCampLocation.y, true);
                        end
                    end
                elseif (botLevel >= 12 and botLevel <= 18)
                then
                    if (camp.type == "medium")
                    then
                        local unitDistance = GetUnitToLocationDistance(npcBot, camp.location)
                        if unitDistance < distance
                        then
                            closestCampLocation = camp.location;
                            distance = unitDistance;
                            --npcBot:ActionImmediate_Chat("Рядом есть доступный средний лагерь крипов!", true);
                            --npcBot:ActionImmediate_Ping(closestCampLocation.x, closestCampLocation.y, true);
                        end
                    end
                else
                    if (camp.type == "large" or camp.type == "ancient")
                    then
                        local unitDistance = GetUnitToLocationDistance(npcBot, camp.location)
                        if unitDistance < distance
                        then
                            closestCampLocation = camp.location;
                            distance = unitDistance;
                            --npcBot:ActionImmediate_Chat("Рядом есть доступный большой/древний лагерь крипов!", true);
                            --npcBot:ActionImmediate_Ping(closestCampLocation.x, closestCampLocation.y, true);
                        end
                    end
                end
            end
        end
    end

    return closestCampLocation, distance;
end

--or DotaTime() < 1 * 60
-- (botLevel >= 30) or

function GetDesire()
    if utility.NotCurrectHeroBot(npcBot) or utility.IsBaseUnderAttack() or utility.IsEnemyBaseUnderAttack() or DotaTime() < 1 * 60
    then
        return BOT_MODE_DESIRE_NONE;
    end

    local countAllyDeadHeroes, countEnemyDeadHeroes, countAllyPlayers, countEnemyPlayers = GetCountAllDeadHeroes();

    if (countEnemyDeadHeroes >= math.floor(countEnemyPlayers / 2) + 1)
    then
        --npcBot:ActionImmediate_Chat(tostring(countEnemyDeadHeroes) .. " героев из " .. tostring(countEnemyPlayers) .. " игроков - мертвы.", true);
        return BOT_MODE_DESIRE_NONE;
    end

    local botLevel = npcBot:GetLevel();
    local botGold = npcBot:GetGold();
    local botKills = GetHeroKills(npcBot:GetPlayerID());
    local botDeaths = GetHeroDeaths(npcBot:GetPlayerID());
    local HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    --npcBot:ActionImmediate_Chat("Выкуп мой: " .. npcBot:GetBuybackCost(), true);

    if (botLevel < 6) or (botLevel >= 30) or (botGold > npcBot:GetBuybackCost()) or (HealthPercentage < 0.3) or (#enemyHeroes > 0)
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if hero_role_generic.HaveCarryInTeam(npcBot)
    then
        if hero_role_generic.IsHeroSupport(npcBot)
        then
            return BOT_MODE_DESIRE_NONE;
        end
    end

    --npcBot:ActionImmediate_Chat("Убийств: " .. tostring(botKills), true);
    --npcBot:ActionImmediate_Chat("Смертей: " .. tostring(botDeaths), true);

    local currentTime = DotaTime();
    if currentTime - lastUpdateTime >= updateInterval
    then
        UpdateCreepCamps()
        lastUpdateTime = currentTime;
        --npcBot:ActionImmediate_Chat("Обновляю список доступных лагерей!", true);
    end

    --and IsRadiusVisible(realCamps[i].location, 500)
    -- and IsLocationVisible(realCamps[i].location)

    if (#realCamps > 0)
    then
        for i = #realCamps, 1, -1 do
            if IsLocationVisible(realCamps[i].location) and not HasNeutralCreepsInCamp(realCamps[i].location)
            then
                --npcBot:ActionImmediate_Ping(realCamps[i].location.x, realCamps[i].location.y, true);
                --npcBot:ActionImmediate_Chat("Удаляю лагерь - Есть вижен и нет крипов.", true);
                table.remove(realCamps, i);
            end

            --[[        if GetUnitToLocationDistance(npcBot, realCamps[i].location) <= 300 and not HasNeutralCreepsInCamp(realCamps[i].location)
            then
                npcBot:ActionImmediate_Chat("Удаляю лагерь - Нет вижена, проверил - нет крипов.", true);
                table.remove(realCamps, i);
            end ]]


            --[[             (GetUnitToLocationDistance(npcBot, realCamps[i].location) <= 300 and not HasNeutralCreepsInCamp(realCamps[i].location)
                    and IsRadiusVisible(realCamps[i].location, 400)) or (HasAllyHeroInCamp(realCamps[i].location))
            then
                --npcBot:ActionImmediate_Chat("В лагере нет крипов, удаляю его из списка.", true);
                table.remove(realCamps, i);
            end ]]
        end
    end

    closestCampLocation, campDistance = GetClosestAvailableCreepCamp();

    if HasAllyHeroInCamp(closestCampLocation)
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if campDistance <= 6000
    then
        --npcBot:ActionImmediate_Chat("Рядом есть доступный лагерь крипов!", true);
        --npcBot:ActionImmediate_Chat("Доступных лагерей: " .. #realCamps, true);
        if botDeaths >= botKills
        then
            return BOT_MODE_DESIRE_VERYHIGH;
        else
            return BOT_MODE_DESIRE_HIGH;
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    --[[     if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Иду фармить в лес", false);
    end ]]
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local farmRange = 700;
    local attackRange = npcBot:GetAttackRange();
    local mainCreep = nil;

    if closestCampLocation ~= nil
    then
        if GetUnitToLocationDistance(npcBot, closestCampLocation) > farmRange
        then
            --npcBot:ActionImmediate_Chat("Иду к лагерю крипов!", true);
            npcBot:Action_MoveToLocation(closestCampLocation);
            return;
        else
            local neutralCreeps = npcBot:GetNearbyCreeps(600, true);
            if (#neutralCreeps > 0)
            then
                mainCreep = utility.GetWeakest(neutralCreeps);
                if mainCreep ~= nil
                then
                    npcBot:SetTarget(mainCreep);
                    if GetUnitToUnitDistance(npcBot, mainCreep) > attackRange
                    then
                        --npcBot:ActionImmediate_Chat("Иду фармить крипа " .. mainCreep:GetUnitName(), true);
                        npcBot:Action_MoveToLocation(mainCreep:GetLocation());
                        return;
                    else
                        --npcBot:ActionImmediate_Chat("Фармлю крипа " .. mainCreep:GetUnitName(), true);
                        npcBot:Action_AttackUnit(mainCreep, false);
                        return;
                    end
                end
            else
                --npcBot:ActionImmediate_Chat("Крипов в лагере нет.", true);
                npcBot:Action_MoveToLocation(closestCampLocation + RandomVector(200));
                return;
            end
        end
    end
end

--[[ function GetDesire()
    if utility.NotCurrectHeroBot(npcBot) or utility.IsBaseUnderAttack()
    then
        return BOT_MODE_DESIRE_NONE;
    end

    local botLevel = npcBot:GetLevel();
    local HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local neutralCreeps = npcBot:GetNearbyNeutralCreeps(1600);

    if botLevel >= 30 or botLevel < 10 or (HealthPercentage < 0.5) or (#neutralCreeps == 0) or (#enemyHeroes > 0)
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes)
        do
            if ally ~= npcBot and ally:GetAttackTarget():IsCreep()
            then
                return BOT_MODE_DESIRE_NONE;
            end
        end
    end

    if hero_role_generic.HaveCarryInTeam(npcBot)
    then
        if hero_role_generic.IsHeroCarry(npcBot)
        then
            if (#neutralCreeps > 0)
            then
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:CanBeSeen() and creep:IsAlive()
                    then
                        if (botLevel >= 6 and botLevel < 15)
                        then
                            if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                            then
                                return BOT_MODE_DESIRE_MODERATE;
                            end
                        else
                            return BOT_MODE_DESIRE_MODERATE;
                        end
                    end
                end
            end
        else
            if (#neutralCreeps > 0)
            then
                if (#allyHeroes > 1)
                then
                    for _, ally in pairs(allyHeroes)
                    do
                        if ally ~= npcBot and hero_role_generic.IsHeroCarry(ally) and ally:GetAttackTarget():IsCreep()
                        then
                            return BOT_MODE_DESIRE_MODERATE;
                        end
                    end
                end
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:CanBeSeen() and creep:IsAlive()
                    then
                        if (botLevel >= 10 and botLevel < 15)
                        then
                            if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                            then
                                return BOT_MODE_DESIRE_MODERATE;
                            end
                        else
                            return BOT_MODE_DESIRE_MODERATE;
                        end
                    end
                end
            end
        end
    else
        if (#neutralCreeps > 0)
        then
            for _, creep in pairs(neutralCreeps)
            do
                if creep:CanBeSeen() and creep:IsAlive()
                then
                    if (botLevel >= 10 and botLevel < 15)
                    then
                        if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                        then
                            return BOT_MODE_DESIRE_MODERATE;
                        end
                    else
                        return BOT_MODE_DESIRE_MODERATE;
                    end
                end
            end
        end
    end

    return BOT_MODE_DESIRE_NONE;
end ]]

--[[ function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local neutralCreeps = npcBot:GetNearbyNeutralCreeps(1600);

    if (#neutralCreeps > 0)
    then
        mainCreep = utility.GetWeakest(neutralCreeps);
    end

    if mainCreep ~= nil
    then
        npcBot:SetTarget(mainCreep);
        if GetUnitToUnitDistance(npcBot, mainCreep) > attackRange
        then
            --npcBot:ActionImmediate_Chat("Иду фармить лесных крипов!", true);
            npcBot:Action_MoveToLocation(mainCreep:GetLocation());
            return;
        else
            --npcBot:ActionImmediate_Chat("Фармлю лесных крипов!", true);
            npcBot:Action_AttackUnit(mainCreep, false);
            return;
        end
    end
end ]]

-- Список лагерей
--[[
=================================RADIANT=======================================
VScript: 1:
VScript: type: small
VScript: max: Vector 0000000000842E08 [4159.999512 -4967.618652 480.000153]
VScript: min: Vector 0000000000842EA8 [3326.915283 -5760.000000 -512.000122]
VScript: team: 2
VScript: location: Vector 0000000000842DC0 [3712.000000 -5376.000000 135.999878]
VScript: speed: fast
VScript: 2:
VScript: type: large
VScript: max: Vector 0000000000843000 [5200.000000 -3504.000000 464.000031]
VScript: min: Vector 00000000008430A0 [4272.000000 -4432.000000 -512.000000]
VScript: team: 2
VScript: location: Vector 0000000000842FB8 [4800.000000 -3776.000000 135.999878]
VScript: speed: slow
VScript: 3:
VScript: type: large
VScript: max: Vector 00000000008431F8 [363.500122 -1943.499878 480.000122]
VScript: min: Vector 0000000000843298 [-388.500122 -2679.500000 -512.000000]
VScript: team: 2
VScript: location: Vector 00000000008431B0 [128.000000 -2176.000000 320.000000]
VScript: speed: normal
VScript: 4:
VScript: type: medium
VScript: max: Vector 0000000000843438 [768.000122 -3392.000000 511.999969]
VScript: min: Vector 00000000008434D8 [-0.000092 -4032.000000 -511.999969]
VScript: team: 2
VScript: location: Vector 00000000008433F0 [512.000000 -3840.000000 263.999878]
VScript: speed: slow
VScript: 5:
VScript: type: ancient
VScript: max: Vector 0000000000843630 [-4288.000000 255.999939 968.000000]
VScript: min: Vector 00000000008436D0 [-5184.000000 -511.999939 -15.500000]
VScript: team: 2
VScript: location: Vector 00000000008435E8 [-4928.000000 -96.000000 263.999878]
VScript: speed: slow
VScript: 6:
VScript: type: large
VScript: max: Vector 0000000000843828 [-1664.000000 -4000.000000 575.999939]
VScript: min: Vector 00000000008438C8 [-2432.000000 -4576.000000 152.500046]
VScript: team: 2
VScript: location: Vector 00000000008437E0 [-2304.000000 -4160.000000 264.000122]
VScript: speed: slow
VScript: 7:
VScript: type: large
VScript: max: Vector 0000000000843A20 [-3488.000000 1304.000000 527.999939]
VScript: min: Vector 0000000000843AC0 [-4160.000000 584.000000 -511.999939]
VScript: team: 2
VScript: location: Vector 00000000008439D8 [-3840.003662 1124.979858 279.006836]
VScript: speed: normal
VScript: 8:
VScript: type: medium
VScript: max: Vector 0000000000843C18 [3264.000000 -2943.999756 384.000092]
VScript: min: Vector 0000000000843CB8 [2432.000000 -3655.110840 -512.000000]
VScript: team: 2
VScript: location: Vector 0000000000843BD0 [2816.000000 -3072.000000 264.000000]
VScript: speed: normal
VScript: 9:
VScript: type: medium
VScript: max: Vector 0000000000843E10 [362.261841 -7323.598145 480.000061]
VScript: min: Vector 0000000000843EB0 [-512.000000 -7778.286621 -512.000000]
VScript: team: 2
VScript: location: Vector 0000000000843DC8 [-192.000000 -7616.000000 135.999878]
VScript: speed: fast
VScript: 10:
VScript: type: large
VScript: max: Vector 0000000000844050 [-1863.999878 -7976.000000 480.000122]
VScript: min: Vector 00000000008440F0 [-2616.000000 -8712.000000 -512.000000]
VScript: team: 2
VScript: location: Vector 0000000000843678 [-2368.000000 -8384.000000 320.000000]
VScript: speed: normal
VScript: 11:
VScript: type: ancient
VScript: max: Vector 0000000000844330 [8864.000000 -736.000061 384.000031]
VScript: team: 2
VScript: location: Vector 0000000000844200 [8320.000000 -1088.000000 256.000000]
VScript: min: Vector 00000000008442E8 [8032.000000 -1440.000000 -512.000000]
VScript: 12:
VScript: type: large
VScript: max: Vector 0000000000844528 [2048.000000 -8064.000000 480.000122]
VScript: team: 2
VScript: location: Vector 0000000000844290 [1664.000000 -8448.000000 128.000000]
VScript: min: Vector 00000000008444E0 [1280.000000 -8832.000000 -512.000061]
VScript: 13:
VScript: type: small
VScript: max: Vector 0000000000844720 [4591.512207 -7934.072266 480.000122]
VScript: team: 2
VScript: location: Vector 0000000000844488 [4032.000000 -8256.000000 128.000000]
VScript: min: Vector 00000000008446D8 [3728.487793 -8833.927734 -512.000000]
VScript: 14:
VScript: type: medium
VScript: max: Vector 0000000000844830 [5163.955078 -6848.000000 480.000122]
VScript: min: Vector 00000000008448D0 [4416.000000 -7678.635742 -512.000000]
VScript: team: 2
VScript: location: Vector 0000000000844680 [4800.000000 -7296.000000 128.000000]
VScript: speed: fast
VScript: 15:
VScript: type: large
VScript: max: Vector 0000000000844A28 [-1088.000000 5344.000000 640.000122]
VScript: min: Vector 0000000000844AC8 [-1728.000000 4640.000000 127.999908]
VScript: team: 3
VScript: location: Vector 00000000008449E0 [-1408.000000 5056.000000 391.999756]
VScript: speed: normal
VScript: 16:
VScript: type: large
VScript: max: Vector 0000000000844C20 [3776.000000 -896.000000 816.000000]
VScript: min: Vector 0000000000844CC0 [3008.000000 -1536.000122 0.000000]
VScript: team: 3
VScript: location: Vector 0000000000844BD8 [3392.000000 -1408.000000 263.999878]
VScript: speed: normal
VScript: 17:
VScript: type: small
VScript: max: Vector 0000000000844E18 [-3200.000000 5248.000000 576.000000]
VScript: min: Vector 0000000000844EB8 [-3840.000000 4480.000000 -320.000000]
VScript: team: 3
VScript: location: Vector 0000000000844DD0 [-3520.000000 4800.000000 128.000000]
VScript: speed: fast
VScript: 18:
VScript: type: large
VScript: max: Vector 0000000000845140 [-4416.000000 4608.000000 384.500000]
VScript: team: 3
VScript: location: Vector 0000000000843FC0 [-4800.000000 4032.000000 179.733047]
VScript: min: Vector 0000000000844008 [-5184.000000 3840.000000 -384.000000]
VScript: 19:
VScript: type: ancient
VScript: max: Vector 0000000000845298 [4768.000000 448.000000 520.000000]
VScript: min: Vector 0000000000845338 [3744.000000 -256.000000 -264.000031]
VScript: team: 3
VScript: location: Vector 0000000000845250 [4352.000000 48.000000 312.971680]
VScript: speed: normal
VScript: 20:
VScript: type: large
VScript: max: Vector 0000000000845490 [2805.000000 8605.000000 496.000000]
VScript: min: Vector 0000000000845530 [2125.000000 8045.000000 -384.000000]
VScript: team: 3
VScript: location: Vector 0000000000845448 [2701.062988 8307.665039 264.000000]
VScript: speed: fast
VScript: 21:
VScript: type: medium
VScript: max: Vector 0000000000845688 [1520.750000 4420.000000 607.000000]
VScript: min: Vector 0000000000845728 [783.250000 3772.000000 -512.000000]
VScript: team: 3
VScript: location: Vector 0000000000845640 [1344.000000 4224.000000 263.999878]
VScript: speed: fast
VScript: 22:
VScript: type: medium
VScript: max: Vector 00000000007B3EB0 [-1983.999756 4080.000000 412.500000]
VScript: min: Vector 00000000005B9A48 [-2752.000244 3312.000000 -51.000000]
VScript: team: 3
VScript: location: Vector 0000000000845838 [-2496.000000 3584.000000 264.000000]
VScript: speed: normal
VScript: 23:
VScript: type: medium
VScript: max: Vector 0000000000816808 [832.000000 7840.000000 504.000366]
VScript: team: 3
VScript: location: Vector 00000000007B3F40 [320.000000 7616.000000 128.000000]
VScript: min: Vector 00000000007B3F88 [-192.000000 7136.000000 -7.999878]
VScript: 24:
VScript: type: ancient
VScript: max: Vector 00000000007FD748 [-7872.000000 1120.000000 960.000061]
VScript: team: 3
VScript: location: Vector 00000000007FD6B8 [-8576.000000 768.000000 256.000000]
VScript: min: Vector 00000000007FD700 [-8896.000000 416.000061 63.999878]
VScript: 25:
VScript: type: large
VScript: max: Vector 0000000000800EE8 [576.000000 3012.000000 607.000000]
VScript: min: Vector 000000000082E1D0 [-78.419434 2364.000000 -512.000000]
VScript: team: 3
VScript: location: Vector 00000000005FB348 [192.000000 2752.000000 263.999878]
VScript: speed: fast
VScript: 26:
VScript: type: large
VScript: max: Vector 000000000073AFF8 [-1003.937866 8608.000000 504.000366]
VScript: min: Vector 00000000005A0B78 [-1812.062134 7904.000000 -7.999878]
VScript: team: 3
VScript: location: Vector 000000000081FF48 [-1408.000000 8256.000000 128.000000]
VScript: speed: normal
VScript: 27:
VScript: type: small
VScript: max: Vector 0000000000755808 [-3229.168701 8736.000000 504.000397]
VScript: min: Vector 00000000007816C0 [-3938.831299 8032.000000 -7.999908]
VScript: team: 3
VScript: location: Vector 0000000000762B80 [-3456.000000 8448.000000 128.000000]
VScript: speed: normal
VScript: 28:
VScript: type: medium
VScript: max: Vector 000000000060C9E8 [-3997.168701 7904.000000 504.000397]
VScript: min: Vector 000000000076C950 [-4706.831055 7200.000000 -7.999908]
VScript: team: 3
VScript: location: Vector 00000000007E4C08 [-4288.000000 7488.000000 128.000000]
VScript: speed: fast ]]
