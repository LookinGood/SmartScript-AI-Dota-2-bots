---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_retreat_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
    return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
    --
end

function OnEnd()
    --
end

function Think()
    --
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_farm_generic) do _G._savedEnv[k] = v end
