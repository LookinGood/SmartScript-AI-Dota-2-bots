---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_rune_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

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

function GetDesire()
    local npcBot = GetBot();
    --local botDesire = npcBot:GetActiveModeDesire();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not npcBot:IsAlive() or utility.IsBusy(npcBot) or not utility.CanMove(npcBot) or (#enemyHeroes > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    -- Message at the beginning of the game
    if not bMessageDone
        --and DotaTime() < 0
        and npcBot:GetGold() < 300
        and npcBot == chattingBot
    then
        local message =
        "You are welcomed by the author of Smart Bots. Thank you for choosing us, we hope you enjoy the game!";
        npcBot:ActionImmediate_Chat(message, true);
        bMessageDone = true;
    end
    --

    for _, rune in pairs(runeList)
    do
        if IsRadiusVisible(GetRuneSpawnLocation(rune), 200)
        then
            local runeStatus = GetRuneStatus(rune);
            if runeStatus == RUNE_STATUS_AVAILABLE
            then
                local runeLocation = GetRuneSpawnLocation(rune);
                local runeDistance = GetUnitToLocationDistance(npcBot, runeLocation);
                if runeDistance <= 3000
                then
                    return BOT_MODE_DESIRE_HIGH;
                else
                    return BOT_MODE_DESIRE_NONE;
                end
            else
                return BOT_MODE_DESIRE_NONE;
            end
        end
    end
end

function Think()
    local npcBot = GetBot();

    local bountyRuneRadiant = Vector(2183.8, -3906.2, 155.7);
    local powerfulRuneRadiant = Vector(1155.8, -1230.5, 84.7);
    local bountyRuneDire = Vector(-1559.8, 3460.0, 208.5);
    local powerfulRuneDire = Vector(-1639.8, 1103.5, 58.3);

    if GetGameState() == GAME_STATE_PRE_GAME
    then
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            if npcBot:GetAssignedLane() == LANE_BOT
            then
                npcBot:Action_MoveToLocation(bountyRuneRadiant + RandomVector(300));
                --return;
            else
                npcBot:Action_MoveToLocation(powerfulRuneDire + RandomVector(300));
                --return;
            end
        elseif npcBot:GetTeam() == TEAM_DIRE
        then
            if npcBot:GetAssignedLane() == LANE_TOP
            then
                npcBot:Action_MoveToLocation(bountyRuneDire + RandomVector(300));
                --return;
            else
                npcBot:Action_MoveToLocation(powerfulRuneRadiant + RandomVector(300));
                --return;
            end
        end
    end

    for _, rune in pairs(runeList)
    do
        local runeStatus = GetRuneStatus(rune);
        if runeStatus == RUNE_STATUS_AVAILABLE
        then
            local runeLocation = GetRuneSpawnLocation(rune);
            local runeDistance = GetUnitToLocationDistance(npcBot, runeLocation);
            if runeDistance <= 3000
            then
                if GetUnitToLocationDistance(npcBot, runeLocation) >= 10
                then
                    npcBot:Action_MoveToLocation(runeLocation + RandomVector(9));
                    --return;
                else
                    npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
                    npcBot:Action_PickUpRune(rune);
                    --return;
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_rune_generic) do _G._savedEnv[k] = v end
