---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("ward_usage_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")
--local utility = require(GetScriptDirectory() .. "/utility")

---RADIANT WARDING SPOT
local RADIANT_TOPSPOT1 = Vector(-4362.3, -1027.3, 229.5); -- Late game
local RADIANT_TOPSPOT2 = Vector(-4104.0, 1566.7, 117.2);
local RADIANT_TOPSPOT3 = Vector(-7938.8, 1834.6, 215.4);
--local RADIANT_TOPSPOTNOTOWER = Vector(-6610.1, -3063.9, 209.1);

local RADIANT_MIDSPOT1 = Vector(108.0, -1221.3, 108.7);
--local RADIANT_MIDSPOTNOTOWER = Vector(-4343.4, -3883.9, 175.1);

local RADIANT_BOTSPOT1 = Vector(763.7, -4569.0, 210.1);
local RADIANT_BOTSPOT2 = Vector(2553.6, -7157.3, 137.1); -- Late game
local RADIANT_BOTSPOT3 = Vector(3843.6, -4593.7, 131.0);
local RADIANT_BOTSPOTPORTAL = Vector(5914.4, -7468.1, 90.7);
local RADIANT_BOTSPOTPOND = Vector(8269.3, -5017.6, 178.8);
--local RADIANT_BOTSPOTNOTOWER = Vector(-3603.6, -6108.9, 208.0);


---DIRE WARDING SPOT
local DIRE_TOPSPOT1 = Vector(1030.2, 3338.1, 130.3);
local DIRE_TOPSPOT2 = Vector(-1551.3, 6919.4, 140.2); -- Late game
local DIRE_TOPSPOT3 = Vector(-775.1, 3594.4, 195.4);
local DIRE_TOPSPOTPORTAL = Vector(-6126.5, 7167.6, 112.4);
local DIRE_TOPSPOTPOND = Vector(-8462.6, 4525.2, 154.3);
--local DIRE_TOPSPOTNOTOWER = Vector(3098.2, 5769.3, 219.4);

local DIRE_MIDSPOT1 = Vector(-658.8, 891.4, 80.2);
--local DIRE_MIDSPOTNOTOWER = Vector(4012.5, 3470.9, 203.9);

local DIRE_BOTSPOT1 = Vector(4605.3, 776.1, 195.1); -- Late game
local DIRE_BOTSPOT2 = Vector(2047.3, -761.8, 108.9);
local DIRE_BOTSPOT3 = Vector(7681.0, -1523.6, 240.7);
--local DIRE_BOTSPOTNOTOWER = Vector(6321.9, 2595.6, 201.8);

-- Tier 3 Towers
--[[ local topTower3 = GetTower(GetTeam(), TOWER_TOP_3);
local midTower3 = GetTower(GetTeam(), TOWER_MID_3);
local botTower3 = GetTower(GetTeam(), TOWER_BOT_3); ]]

function GetWardSpot()
    local npcBot = GetBot();

    local RadiantWardSpotEarlyGame = {
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOTPORTAL,
        RADIANT_BOTSPOTPOND,

        DIRE_TOPSPOT3,
        DIRE_TOPSPOTPORTAL,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
    }

    local DireWardSpotEarlyGame = {
        DIRE_TOPSPOT3,
        DIRE_TOPSPOTPORTAL,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,

        RADIANT_TOPSPOT2,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOTPORTAL,
        RADIANT_BOTSPOTPOND,
    }

    local WardSpotLateGame = {
        RADIANT_TOPSPOT1,
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT1,
        RADIANT_BOTSPOT2,
        RADIANT_BOTSPOT3,
        DIRE_TOPSPOT1,
        DIRE_TOPSPOT2,
        DIRE_TOPSPOT3,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,
        RADIANT_BOTSPOTPORTAL,
        DIRE_TOPSPOTPORTAL,
    }

    --[[     if npcBot:GetTeam() == TEAM_RADIANT then
        if topTower3 == nil then
            table.insert(WardSpotLateGame, RADIANT_TOPSPOTNOTOWER);
        elseif midTower3 == nil then
            table.insert(WardSpotLateGame, RADIANT_MIDSPOTNOTOWER);
        elseif botTower3 == nil then
            table.insert(WardSpotLateGame, RADIANT_BOTSPOTNOTOWER);
        end
    elseif npcBot:GetTeam() == TEAM_DIRE then
        if topTower3 == nil then
            table.insert(WardSpotLateGame, DIRE_TOPSPOTNOTOWER);
        elseif midTower3 == nil then
            table.insert(WardSpotLateGame, DIRE_MIDSPOTNOTOWER);
        elseif botTower3 == nil then
            table.insert(WardSpotLateGame, DIRE_BOTSPOTNOTOWER);
        end
        --return;
    end ]]

    if DotaTime() < 15 * 60
    then
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            return RadiantWardSpotEarlyGame;
        else
            return DireWardSpotEarlyGame;
        end
    else
        return WardSpotLateGame;
    end
end

--[[ function GetAvailableSpot()
    local wardpos = {};

    for _, s in pairs(GetWardSpot()) do
        if not CloseToAvailableWard(s) then
            table.insert(wardpos, s);
        end
    end

    return wardpos;
end ]]
function CloseToAvailableWard(wardLoc)
    local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
    local visionRad = 1600;
    
    for _, ward in pairs(WardList) do
        if ward:GetUnitName() == "npc_dota_observer_wards" and GetUnitToLocationDistance(ward, wardLoc) <= visionRad
        then
            return true;
        end
    end
    return false;
end

--[[ function IsObserver(wardUnit)
    return wardUnit:GetUnitName() == "npc_dota_observer_wards";
end ]]

function ShouldUseWard()
    if GetGameState() == GAME_STATE_PRE_GAME or GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS then
        return;
    end

    local npcBot = GetBot();
    local botMode = npcBot:GetActiveMode();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if (npcBot.idletime == nil)
    then
        npcBot.idletime = GameTime()
    else
        if (GameTime() - npcBot.idletime >= 10)
        then
            if not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT and (#enemyHeroes <= 0)
            then
                for _, s in pairs(GetWardSpot()) do
                    if GetUnitToLocationDistance(npcBot, s) <= 3000 and not CloseToAvailableWard(s)
                    then
                        npcBot.idletime = nil
                        --npcBot:ActionImmediate_Chat("Нужно поставить вард!", true);
                        return true, s;
                    end
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(ward_usage_generic) do _G._savedEnv[k] = v end


--[[     local RadiantWardSpot = {
        RADIANT_TOPSPOT1,
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT1,
        RADIANT_BOTSPOT2,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOTPORTAL,
        RADIANT_BOTSPOTPOND,
    } ]]
--[[     local DireWardSpot = {
        DIRE_TOPSPOT1,
        DIRE_TOPSPOT2,
        DIRE_TOPSPOT3,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,
        DIRE_TOPSPOTPORTAL,
        DIRE_TOPSPOTPOND,
    } ]]