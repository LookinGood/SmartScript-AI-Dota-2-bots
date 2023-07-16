---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("bot_name_generic", package.seeall)

function GetBotName()
    if (GetTeam() == TEAM_RADIANT) then
        name =
        { "DevoDeAL",
            "Murdage",
            "Vilverin-Talekon",
            "Barracuda",
            "O tempora, o mores!",
        }
    elseif (GetTeam() == TEAM_DIRE) then
        name =
        {
            "Sezam",
            "Gwinblade",
            "Spartacus",
            "Bortel",
            "iadmireyou",
        }
    end
    return name;
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(bot_name_generic) do _G._savedEnv[k] = v end
