---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local introMessageDone = false;
local closestRune = nil;
local runeList = {
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4,
}

local bountyRuneRadiant = Vector(2183.8, -3906.2, 155.7);
local powerfulRuneRadiant = Vector(1155.8, -1230.5, 84.7);
local bountyRuneDire = Vector(-1559.8, 3460.0, 208.5);
local powerfulRuneDire = Vector(-1639.8, 1103.5, 58.3);

function GetRandomBotPlayer()
    local selectedBotHero = nil;
    local goldMin = 100000;
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    for _, ally in pairs(allyHeroes) do
        if IsPlayerBot(ally:GetPlayerID())
        then
            local playerGold = ally:GetGold();
            if playerGold < goldMin
            then
                goldMin = playerGold;
                selectedBotHero = ally;
            end
        end
    end

    --[[     for _, i in pairs(GetTeamPlayers(GetTeam()))
    do
        if IsPlayerBot(i)
        then
            local playerGold = i:GetGold();
            if playerGold < goldMin
            then
                goldMin = playerGold;
                selectedBotPlayer = i;
            end
        end
    end ]]

    return selectedBotHero;
end

function GetClosestRune()
    local closestRune = nil;
    local runeDistance = 100000;
    for _, rune in pairs(runeList)
    do
        local runeLocation = GetRuneSpawnLocation(rune);
        local runeStatus = GetRuneStatus(rune);
        if runeStatus == RUNE_STATUS_AVAILABLE
        then
            local botDistance = GetUnitToLocationDistance(npcBot, runeLocation);
            if botDistance < runeDistance
            then
                runeDistance = botDistance;
                closestRune = rune;
            end
        end
    end
    return closestRune, runeDistance;
end

function GetDesire()
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsClone(npcBot) or (#enemyHeroes > 0) or utility.IsBaseUnderAttack()
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    closestRune, runeDistance = GetClosestRune();
    if closestRune ~= nil and IsRadiusVisible(GetRuneSpawnLocation(closestRune), 200)
    then
        runeStatus = GetRuneStatus(closestRune);
        if runeStatus == RUNE_STATUS_AVAILABLE and runeDistance <= 2000
        then
            return BOT_MODE_DESIRE_HIGH;
        else
            return BOT_MODE_DESIRE_NONE;
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(15) and GetGameState() ~= GAME_STATE_PRE_GAME
    then
        npcBot:ActionImmediate_Chat("Иду за руной.", false);
    end
end

function OnEnd()
    --
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    --print(DotaTime())

    -- Message at the beginning of the game
    if GetGameState() == GAME_STATE_PRE_GAME
    then
        if introMessageDone == false and npcBot:HasModifier("modifier_fountain_aura_buff")
        then
            local chattingBot = GetRandomBotPlayer();
            if npcBot == chattingBot
            then
                --introMessageTimer = GameTime();
                local message =
                "You are welcomed by the author of Smart Bots. Thank you for choosing us, we hope you enjoy the game!";
                npcBot:ActionImmediate_Chat(message, false);
                introMessageDone = true;
            end
        end
    end
    --

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            if npcBot:GetAssignedLane() == LANE_BOT
            then
                npcBot:Action_MoveToLocation(bountyRuneRadiant + RandomVector(300));
                return;
            else
                npcBot:Action_MoveToLocation(powerfulRuneDire + RandomVector(300));
                return;
            end
        elseif npcBot:GetTeam() == TEAM_DIRE
        then
            if npcBot:GetAssignedLane() == LANE_TOP
            then
                npcBot:Action_MoveToLocation(bountyRuneDire + RandomVector(300));
                return;
            else
                npcBot:Action_MoveToLocation(powerfulRuneRadiant + RandomVector(300));
                return;
            end
        end
    end

    if runeDistance > 10
    then
        npcBot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune) + RandomVector(10));
        return;
    else
        npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
        npcBot:Action_PickUpRune(closestRune);
        return;
    end
end

--[[ function GetRandomBotPlayer()
    local botPlayers = {};
    local selectedBotPlayer = nil;
    for _, i in pairs(GetTeamPlayers(GetTeam()))
    do
        if IsPlayerBot(i)
        then
            table.insert(botPlayers, i);
        end
    end
    if (#botPlayers > 0) and selectedBotPlayer == nil
    then
        selectedBotPlayer = math.random(1, #botPlayers);
    end

    return selectedBotPlayer;
end ]]


--[[     for _, rune in pairs(runeList)
    do
        local runeStatus = GetRuneStatus(rune);
        if runeStatus == RUNE_STATUS_AVAILABLE
        then
            local runeLocation = GetRuneSpawnLocation(rune);
            local runeDistance = GetUnitToLocationDistance(npcBot, runeLocation);
            if runeDistance <= 2000
            then
                if GetUnitToLocationDistance(npcBot, runeLocation) >= 10
                then
                    npcBot:Action_MoveToLocation(runeLocation + RandomVector(9));
                    return;
                else
                    npcBot:Action_PickUpRune(rune);
                    npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
                    return;
                end
            end
        end
    end ]]

--[[     for _, rune in pairs(runeList)
    do
        if IsRadiusVisible(GetRuneSpawnLocation(rune), 200)
        then
            local runeStatus = GetRuneStatus(rune);
            if runeStatus == RUNE_STATUS_AVAILABLE
            then
                local runeLocation = GetRuneSpawnLocation(rune);
                local runeDistance = GetUnitToLocationDistance(npcBot, runeLocation);
                if runeDistance <= 1000
                then
                    return BOT_MODE_DESIRE_VERYHIGH;
                elseif runeDistance <= 2000
                then
                    return BOT_MODE_DESIRE_HIGH;
                else
                    return BOT_MODE_DESIRE_NONE;
                end
            else
                return BOT_MODE_DESIRE_NONE;
            end
        end
    end ]]
