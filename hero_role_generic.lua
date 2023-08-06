---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("hero_role_generic", package.seeall)

local C = {}
C["carryHeroes"] = {
    ["npc_dota_hero_centaur"] = 1,
    ["npc_dota_hero_gyrocopter"] = 1,
    ["npc_dota_hero_antimage"] = 1,
    ["npc_dota_hero_lycan"] = 1,
    ["npc_dota_hero_beastmaster"] = 1,
    ["npc_dota_hero_queenofpain"] = 1,
    ["npc_dota_hero_luna"] = 1,
    ["npc_dota_hero_terrorblade"] = 1,
    ["npc_dota_hero_drow_ranger"] = 1,
    ["npc_dota_hero_riki"] = 1,
    ["npc_dota_hero_slark"] = 1,
    ["npc_dota_hero_spectre"] = 1,
    ["npc_dota_hero_dawnbreaker"] = 1,
    ["npc_dota_hero_zuus"] = 1,
    ["npc_dota_hero_clinkz"] = 1,
    ["npc_dota_hero_tusk"] = 1,
    ["npc_dota_hero_alchemist"] = 1,
    ["npc_dota_hero_sven"] = 1,
    ["npc_dota_hero_skeleton_king"] = 1,
    ["npc_dota_hero_furion"] = 1,
    ["npc_dota_hero_sniper"] = 1,
    ["npc_dota_hero_doom_bringer"] = 1,
    ["npc_dota_hero_dragon_knight"] = 1,
}

local S = {}
S["supportHeroes"] = {
    ["npc_dota_hero_disruptor"] = 1,
    ["npc_dota_hero_venomancer"] = 1,
    ["npc_dota_hero_dazzle"] = 1,
    ["npc_dota_hero_undying"] = 1,
    ["npc_dota_hero_techies"] = 1,
    ["npc_dota_hero_silencer"] = 1,
    ["npc_dota_hero_vengefulspirit"] = 1,
    ["npc_dota_hero_enigma"] = 1,
    ["npc_dota_hero_grimstroke"] = 1,
    ["npc_dota_hero_shadow_demon"] = 1,
    ["npc_dota_hero_snapfire"] = 1,
    ["npc_dota_hero_winter_wyvern"] = 1,
    ["npc_dota_hero_ancient_apparition"] = 1,
    ["npc_dota_hero_enchantress"] = 1,
    ["npc_dota_hero_lion"] = 1,
    ["npc_dota_hero_leshrac"] = 1,
    ["npc_dota_hero_lina"] = 1,
    ["npc_dota_hero_shadow_shaman"] = 1,
    ["npc_dota_hero_warlock"] = 1,
    ["npc_dota_hero_ogre_magi"] = 1,
}


function IsHeroCarry(npcBot)
    if C["carryHeroes"][npcBot:GetUnitName()] == 1
    then
        return true;
    end

    return false;
end

function IsHeroSupport(npcBot)
    if S["supportHeroes"][npcBot:GetUnitName()] == 1
    then
        return true;
    end

    return false;
end

function HaveSupportInTeam(npcBot)
    local players = GetTeamPlayers(npcBot:GetTeam());

    for i = 1, #players do
        if S["supportHeroes"][GetSelectedHeroName(players[i])] == 1
        then
            return true;
        end
    end

    return false;
end

function HaveCarryInTeam(npcBot)
    local players = GetTeamPlayers(npcBot:GetTeam());

    for i = 1, #players do
        if C["carryHeroes"][GetSelectedHeroName(players[i])] == 1
        then
            return true;
        end
    end

    return false;
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(hero_role_generic) do _G._savedEnv[k] = v end
