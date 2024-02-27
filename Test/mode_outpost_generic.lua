---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_outpost_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

local function GetCurrectShrine()
    local currectShrine = nil;
    local shrineDistance = 100000;
    local enemyMidTower = GetTower(GetOpposingTeam(), TOWER_MID_2);
    local shrines = {
        SHRINE_JUNGLE_1,
        SHRINE_JUNGLE_2,
    }

    for _, s in pairs(shrines)
    do
        local shrine = GetShrine(GetOpposingTeam(), s)
        if shrine ~= nil and not enemyMidTower:IsAlive()
        then
            local botDistance = GetUnitToUnitDistance(npcBot, shrine)
            if botDistance < shrineDistance
            then
                shrineDistance = botDistance;
                currectShrine = shrine;
            end
        end
    end

    return currectShrine, shrineDistance;
end

function GetDesire()
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not utility.IsHero(npcBot) or not utility.CanMove(npcBot) or utility.IsBusy(npcBot) or npcBot:WasRecentlyDamagedByAnyHero(2.0)
        or (#enemyHeroAround > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    currectShrine, shrineDistance = GetCurrectShrine();

    if currectShrine ~= nil and GetUnitToUnitDistance(npcBot, currectShrine) <= 6000
    then
        npcBot:Action_Chat(npcBot:GetUnitName() .. " решил захватить аванпост!", true);
        return BOT_MODE_DESIRE_HIGH;
    else
        return BOT_MODE_DESIRE_NONE;
    end
end

function Think()
    if shrineDistance > 300
    then
        npcBot:Action_Chat("Иду к аванпосту!", true);
        npcBot:Action_MoveToLocation(currectShrine:GetLocation() + RandomVector(200));
        return;
    else
        npcBot:Action_Chat("Захватываю аванпост!", true);
        npcBot:Action_UseShrine(currectShrine);
        npcBot:ActionImmediate_Ping(currectShrine.x, currectShrine.y, true);
        return;
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_outpost_generic) do _G._savedEnv[k] = v end
