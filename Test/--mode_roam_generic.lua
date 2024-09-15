---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

function GetDesire()
    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    --
end

function OnEnd()
    --
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end
end
