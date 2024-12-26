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
    RUNE_WISDOM_1,
    RUNE_WISDOM_2,
}

local bountyRuneRadiant = Vector(2183.8, -3906.2, 155.7);
local powerfulRuneRadiant = Vector(1155.8, -1230.5, 84.7);
local bountyRuneDire = Vector(-1559.8, 3460.0, 208.5);
local powerfulRuneDire = Vector(-1639.8, 1103.5, 58.3);

local checkRuneTimer = 0.0;

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
    --and IsRadiusVisible(GetRuneSpawnLocation(closestRune), 200)

    runeStatus = GetRuneStatus(closestRune);
    runeLocation = GetRuneSpawnLocation(closestRune);
    closestAlly = utility.GetClosestToLocationBotHero(runeLocation);

    if runeDistance <= 3000 and npcBot == closestAlly
    then
        if runeStatus == RUNE_STATUS_AVAILABLE
        then
            if runeStatus == RUNE_STATUS_UNKNOWN
            then
                if (DotaTime() >= checkRuneTimer + 2 * 60)
                then
                    npcBot:ActionImmediate_Chat("Иду проверять руну!", true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            elseif runeStatus == RUNE_STATUS_MISSING
            then
                npcBot:ActionImmediate_Chat("Руна пропала!", true);
                return BOT_MODE_DESIRE_NONE;
            else
                --npcBot:ActionImmediate_Chat("Иду за доступной руной!", true);
                checkRuneTimer = DotaTime();
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    --npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
    if RollPercentage(15) and GetGameState() ~= GAME_STATE_PRE_GAME
    then
        npcBot:ActionImmediate_Chat("Иду за руной.", false);
    end
end

function OnEnd()
    closestAlly = nil;
    npcBot:SetTarget(nil);
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

    if runeStatus == RUNE_STATUS_AVAILABLE
    then
        if runeDistance > 10
        then
            npcBot:Action_MoveToLocation(runeLocation + RandomVector(10));
            return;
        else
            npcBot:ActionImmediate_Ping(runeLocation.x, runeLocation.y, true);
            npcBot:Action_ClearActions(false);
            npcBot:ActionQueue_MoveToLocation(runeLocation + RandomVector(10));
            npcBot:ActionQueue_PickUpRune(closestRune);
            return;
        end
    elseif runeStatus == RUNE_STATUS_UNKNOWN
    then
        npcBot:Action_MoveToLocation(runeLocation + RandomVector(100));
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
