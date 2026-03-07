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

local botLocationRadiant = Vector(1194.2, -4201.9, 203.7);
local topLocationRadiant = Vector(-2017.6, -92.2, 93.2);

local botLocationDire = Vector(1329.2, -201.4, 91.395233);
local topLocaltionDire = Vector(-1741.1, 3796.4, 198.9);

function GetClosestRune()
    local closestRune = nil;
    local runeDistance = 100000;
    for _, rune in pairs(runeList)
    do
        local runeStatus = GetRuneStatus(rune);
        if runeStatus == RUNE_STATUS_AVAILABLE
        then
            local runeLocation = GetRuneSpawnLocation(rune);
            local botDistance = GetUnitToLocationDistance(npcBot, runeLocation);
            if botDistance < runeDistance
            then
                closestRune = rune;
                runeDistance = botDistance;
            end
        end
    end
    --and IsRadiusVisible(GetRuneSpawnLocation(closestRune), 200)
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
    runeLocation = GetRuneSpawnLocation(closestRune);
    local closestAlly = utility.GetClosestToLocationBotHero(runeLocation);

    if runeDistance <= 3000 and npcBot == closestAlly
    then
        --npcBot:ActionImmediate_Chat("Иду за доступной руной: " .. tostring(runeStatus), true);
        --npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
        return BOT_MODE_DESIRE_HIGH;
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    --[[     if RollPercentage(15) and GetGameState() ~= GAME_STATE_PRE_GAME
    then
        --npcBot:ActionImmediate_Chat("Иду за руной.", false);
        npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
    end ]]
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot) or npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE
    then
        return;
    end

    -- Message at the beginning of the game
    if GetGameState() == GAME_STATE_PRE_GAME
    then
        if introMessageDone == false and npcBot:HasModifier("modifier_fountain_aura_buff")
        then
            local chattingBot = utility.GetRandomBotPlayer();
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
    --and GetGameStateTimeRemaining() <= 30.0

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        local boundingRadius = npcBot:GetBoundingRadius();
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            if npcBot:GetAssignedLane() == LANE_BOT
            then
                npcBot:Action_MoveToLocation(botLocationRadiant + RandomVector(boundingRadius * 4));
                return;
            else
                npcBot:Action_MoveToLocation(topLocationRadiant + RandomVector(boundingRadius * 4));
                return;
            end
        elseif npcBot:GetTeam() == TEAM_DIRE
        then
            if npcBot:GetAssignedLane() == LANE_TOP
            then
                npcBot:Action_MoveToLocation(topLocaltionDire + RandomVector(boundingRadius * 4));
                return;
            else
                npcBot:Action_MoveToLocation(botLocationDire + RandomVector(boundingRadius * 4));
                return;
            end
        end
    end

    if closestRune ~= nil
    then
        if GetUnitToLocationDistance(npcBot, runeLocation) > 100
        then
            npcBot:Action_MoveToLocation(runeLocation + RandomVector(10));
            return;
        else
            --npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_MoveToLocation(runeLocation + RandomVector(100));
            npcBot:ActionQueue_PickUpRune(closestRune);
            return;
        end
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
