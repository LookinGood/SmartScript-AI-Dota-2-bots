---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_rune_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local closestRune = nil;
local runeList = {
    RUNE_POWERUP_1,
    RUNE_POWERUP_2,
    RUNE_BOUNTY_1,
    RUNE_BOUNTY_2,
    RUNE_BOUNTY_3,
    RUNE_BOUNTY_4,
}

function GetRandomBotPlayer()
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
end

local bMessageDone = false;
local chattingBot = GetTeamMember(GetRandomBotPlayer());

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

    if not npcBot:IsAlive() or utility.IsBusy(npcBot) or not utility.CanMove(npcBot) or (#enemyHeroes > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
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
    else
        return BOT_MODE_DESIRE_NONE;
    end

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
end

function Think()
    local bountyRuneRadiant = Vector(2183.8, -3906.2, 155.7);
    local powerfulRuneRadiant = Vector(1155.8, -1230.5, 84.7);
    local bountyRuneDire = Vector(-1559.8, 3460.0, 208.5);
    local powerfulRuneDire = Vector(-1639.8, 1103.5, 58.3);

    -- Message at the beginning of the game
    if not bMessageDone
        and GetGameState() == GAME_STATE_PRE_GAME
        and DotaTime() < 5
        and npcBot:GetGold() < 300
        and npcBot == chattingBot
    then
        local message =
        "You are welcomed by the author of Smart Bots. Thank you for choosing us, we hope you enjoy the game!";
        npcBot:ActionImmediate_Chat(message, true);
        bMessageDone = true;
    end
    --

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            if npcBot:GetAssignedLane() == LANE_BOT
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(bountyRuneRadiant + RandomVector(300));
                return;
            else
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(powerfulRuneDire + RandomVector(300));
                return;
            end
        elseif npcBot:GetTeam() == TEAM_DIRE
        then
            if npcBot:GetAssignedLane() == LANE_TOP
            then
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(bountyRuneDire + RandomVector(300));
                return;
            else
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(powerfulRuneRadiant + RandomVector(300));
                return;
            end
        end
    end

    if runeDistance > 10
    then
        npcBot:Action_ClearActions(false);
        npcBot:Action_MoveToLocation(GetRuneSpawnLocation(closestRune) + RandomVector(5));
        return;
    else
        npcBot:Action_ClearActions(false);
        npcBot:Action_PickUpRune(closestRune);
        npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
        return;
    end

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
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_rune_generic) do _G._savedEnv[k] = v end
