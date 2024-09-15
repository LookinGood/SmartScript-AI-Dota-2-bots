---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("minion_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
print("KEKE!")

function MinionThink(hMinionUnit)
    print("MinionThink!")

    botLocation = npcBot:GetLocation();
    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    botAttackTarget = npcBot:GetAttackTarget();
    globRadius = 1600;
    allyAncientLocation = GetAncient(GetTeam()):GetLocation();

    local moveDesire, moveLocation = ConsiderUnitMove(hMinionUnit);

    if (moveDesire ~= nil)
    then
        hMinionUnit:Action_MoveToLocation(moveLocation);
        return;
    end
end

function ConsiderUnitMove(minion)
    print("MOVE!")
    if GetUnitToUnitDistance(minion, npcBot) > 500
    then
        return BOT_ACTION_DESIRE_HIGH, botLocation;
    else
        return BOT_ACTION_DESIRE_HIGH, botLocation + RandomVector(100);
    end

    --[[     if npcBot:IsAlive()
    then
        if GetUnitToUnitDistance(minion, npcBot) > 500
        then
            return BOT_ACTION_DESIRE_HIGH, botLocation;
        else
            return BOT_ACTION_DESIRE_HIGH, botLocation + RandomVector(100);
        end
    else
        if GetUnitToLocationDistance(minion, allyAncientLocation) > 500
        then
            return BOT_ACTION_DESIRE_HIGH, allyAncientLocation;
        else
            return BOT_ACTION_DESIRE_HIGH, allyAncientLocation + RandomVector(300);
        end
    end ]]
end

for k, v in pairs(minion_generic) do _G._savedEnv[k] = v end