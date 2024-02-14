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
    ["npc_dota_hero_ember_spirit"] = 1,
    ["npc_dota_hero_faceless_void"] = 1,
    ["npc_dota_hero_juggernaut"] = 1,
    ["npc_dota_hero_pangolier"] = 1,
    ["npc_dota_hero_monkey_king"] = 1,
    ["npc_dota_hero_spirit_breaker"] = 1,
    ["npc_dota_hero_axe"] = 1,
    ["npc_dota_hero_phantom_lancer"] = 1,
    ["npc_dota_hero_viper"] = 1,
    ["npc_dota_hero_medusa"] = 1,
    ["npc_dota_hero_mirana"] = 1,
    ["npc_dota_hero_naga_siren"] = 1,
    ["npc_dota_hero_pudge"] = 1,
    ["npc_dota_hero_nyx_assassin"] = 1,
    ["npc_dota_hero_bounty_hunter"] = 1,
    ["npc_dota_hero_ursa"] = 1,
    ["npc_dota_hero_troll_warlord"] = 1,
    ["npc_dota_hero_nevermore"] = 1,
    ["npc_dota_hero_kunkka"] = 1,
    ["npc_dota_hero_tiny"] = 1,
    ["npc_dota_hero_mars"] = 1,
    ["npc_dota_hero_puck"] = 1,
    ["npc_dota_hero_phantom_assassin"] = 1,
    ["npc_dota_hero_tinker"] = 1,
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
    ["npc_dota_hero_lich"] = 1,
    ["npc_dota_hero_abyssal_underlord"] = 1,
    ["npc_dota_hero_necrolyte"] = 1,
    ["npc_dota_hero_crystal_maiden"] = 1,
    ["npc_dota_hero_treant"] = 1,
    ["npc_dota_hero_omniknight"] = 1,
    ["npc_dota_hero_pugna"] = 1,
    ["npc_dota_hero_abaddon"] = 1,
    ["npc_dota_hero_witch_doctor"] = 1,
    ["npc_dota_hero_elder_titan"] = 1,
    ["npc_dota_hero_tidehunter"] = 1,
    ["npc_dota_hero_dark_seer"] = 1,
    ["npc_dota_hero_dark_willow"] = 1,
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
