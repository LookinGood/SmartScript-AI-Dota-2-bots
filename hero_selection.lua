---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/bot_name_generic")
require(GetScriptDirectory() .. "/hero_role_generic")

--#region All bot-hero by DarkOblivion
--[[
	"npc_dota_hero_hoodwink", -- not work currect
	"npc_dota_hero_dark_willow", -- not work currect
    "npc_dota_hero_centaur",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_antimage",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_lycan",
	"npc_dota_hero_undying",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_techies",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_silencer",
	"npc_dota_hero_luna",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_zuus",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_riki",
	"npc_dota_hero_slark",
	"npc_dota_hero_spectre",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_enigma",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_tusk",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_sven",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_lion",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lina",
	"npc_dota_hero_furion",
	"npc_dota_hero_sniper",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_warlock",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_lich",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_axe",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_treant",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_viper",
	"npc_dota_hero_medusa",
	"npc_dota_hero_mirana",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_pudge",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_pugna",
	"npc_dota_hero_ursa",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_tiny",
	"npc_dota_hero_mars",
	"npc_dota_hero_puck",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_tinker",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_shredder",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_oracle",
	"npc_dota_hero_slardar",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_huskar",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_razor",
	"npc_dota_hero_batrider",
	"npc_dota_hero_weaver",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_rubick",
	"npc_dota_hero_bane",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_visage",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_chen",
	"npc_dota_hero_ringmaster",
	"npc_dota_hero_morphling",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_invoker",
	"npc_dota_hero_lone_druid",  -- not work currect
	"npc_dota_hero_wisp",
]]
--#endregion

local hero_pool_my =
{
	"npc_dota_hero_centaur",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_disruptor",
	"npc_dota_hero_antimage",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_lycan",
	"npc_dota_hero_undying",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_techies",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_silencer",
	"npc_dota_hero_luna",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_zuus",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_riki",
	"npc_dota_hero_slark",
	"npc_dota_hero_spectre",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_enigma",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_tusk",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_sven",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_lion",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lina",
	"npc_dota_hero_furion",
	"npc_dota_hero_sniper",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_warlock",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_lich",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_axe",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_treant",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_viper",
	"npc_dota_hero_medusa",
	"npc_dota_hero_mirana",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_pudge",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_pugna",
	"npc_dota_hero_ursa",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_tiny",
	"npc_dota_hero_mars",
	"npc_dota_hero_puck",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_tinker",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_shredder",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_oracle",
	"npc_dota_hero_slardar",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_huskar",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_razor",
	"npc_dota_hero_batrider",
	"npc_dota_hero_weaver",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_rubick",
	"npc_dota_hero_bane",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_visage",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_chen",
	"npc_dota_hero_ringmaster",
	"npc_dota_hero_morphling",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_invoker",
	--"npc_dota_hero_lone_druid",
	"npc_dota_hero_wisp",
}

local heroesCarry =
{
	"npc_dota_hero_centaur",
	"npc_dota_hero_gyrocopter",
	"npc_dota_hero_antimage",
	"npc_dota_hero_lycan",
	"npc_dota_hero_beastmaster",
	"npc_dota_hero_queenofpain",
	"npc_dota_hero_luna",
	"npc_dota_hero_terrorblade",
	"npc_dota_hero_zuus",
	"npc_dota_hero_drow_ranger",
	"npc_dota_hero_riki",
	"npc_dota_hero_slark",
	"npc_dota_hero_spectre",
	"npc_dota_hero_dawnbreaker",
	"npc_dota_hero_clinkz",
	"npc_dota_hero_tusk",
	"npc_dota_hero_alchemist",
	"npc_dota_hero_sven",
	"npc_dota_hero_skeleton_king",
	"npc_dota_hero_furion",
	"npc_dota_hero_sniper",
	"npc_dota_hero_doom_bringer",
	"npc_dota_hero_dragon_knight",
	"npc_dota_hero_ember_spirit",
	"npc_dota_hero_faceless_void",
	"npc_dota_hero_juggernaut",
	"npc_dota_hero_pangolier",
	"npc_dota_hero_monkey_king",
	"npc_dota_hero_spirit_breaker",
	"npc_dota_hero_axe",
	"npc_dota_hero_phantom_lancer",
	"npc_dota_hero_viper",
	"npc_dota_hero_medusa",
	"npc_dota_hero_mirana",
	"npc_dota_hero_naga_siren",
	"npc_dota_hero_pudge",
	"npc_dota_hero_nyx_assassin",
	"npc_dota_hero_bounty_hunter",
	"npc_dota_hero_ursa",
	"npc_dota_hero_troll_warlord",
	"npc_dota_hero_nevermore",
	"npc_dota_hero_kunkka",
	"npc_dota_hero_tiny",
	"npc_dota_hero_mars",
	"npc_dota_hero_puck",
	"npc_dota_hero_phantom_assassin",
	"npc_dota_hero_tinker",
	"npc_dota_hero_legion_commander",
	"npc_dota_hero_obsidian_destroyer",
	"npc_dota_hero_life_stealer",
	"npc_dota_hero_templar_assassin",
	"npc_dota_hero_windrunner",
	"npc_dota_hero_arc_warden",
	"npc_dota_hero_slardar",
	"npc_dota_hero_chaos_knight",
	"npc_dota_hero_night_stalker",
	"npc_dota_hero_huskar",
	"npc_dota_hero_broodmother",
	"npc_dota_hero_magnataur",
	"npc_dota_hero_razor",
	"npc_dota_hero_weaver",
	"npc_dota_hero_storm_spirit",
	"npc_dota_hero_bristleback",
	"npc_dota_hero_death_prophet",
	"npc_dota_hero_bloodseeker",
	"npc_dota_hero_brewmaster",
	"npc_dota_hero_morphling",
	"npc_dota_hero_void_spirit",
	"npc_dota_hero_invoker",
	--"npc_dota_hero_lone_druid",
}

local heroesSupport =
{
	"npc_dota_hero_disruptor",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_dazzle",
	"npc_dota_hero_shadow_demon",
	"npc_dota_hero_undying",
	"npc_dota_hero_techies",
	"npc_dota_hero_silencer",
	"npc_dota_hero_vengefulspirit",
	"npc_dota_hero_enigma",
	"npc_dota_hero_grimstroke",
	"npc_dota_hero_snapfire",
	"npc_dota_hero_winter_wyvern",
	"npc_dota_hero_ancient_apparition",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_lion",
	"npc_dota_hero_leshrac",
	"npc_dota_hero_lina",
	"npc_dota_hero_shadow_shaman",
	"npc_dota_hero_warlock",
	"npc_dota_hero_ogre_magi",
	"npc_dota_hero_lich",
	"npc_dota_hero_abyssal_underlord",
	"npc_dota_hero_necrolyte",
	"npc_dota_hero_crystal_maiden",
	"npc_dota_hero_treant",
	"npc_dota_hero_omniknight",
	"npc_dota_hero_pugna",
	"npc_dota_hero_abaddon",
	"npc_dota_hero_witch_doctor",
	"npc_dota_hero_elder_titan",
	"npc_dota_hero_tidehunter",
	"npc_dota_hero_dark_seer",
	"npc_dota_hero_keeper_of_the_light",
	"npc_dota_hero_shredder",
	"npc_dota_hero_oracle",
	"npc_dota_hero_jakiro",
	"npc_dota_hero_batrider",
	"npc_dota_hero_rubick",
	"npc_dota_hero_bane",
	"npc_dota_hero_rattletrap",
	"npc_dota_hero_sand_king",
	"npc_dota_hero_skywrath_mage",
	"npc_dota_hero_earthshaker",
	"npc_dota_hero_visage",
	"npc_dota_hero_phoenix",
	"npc_dota_hero_chen",
	"npc_dota_hero_ringmaster",
	"npc_dota_hero_earth_spirit",
	"npc_dota_hero_wisp",
}

local testTeam =
{
	"npc_dota_hero_lycan",
	"npc_dota_hero_enchantress",
	"npc_dota_hero_venomancer",
	"npc_dota_hero_beastmaster",
}

function GetBotNames()
	return bot_name_generic.GetBotName();
end

function GetPicks()
	local selectedHeroes = {};
	--local pickedSlots = {};
	for _, i in pairs(GetTeamPlayers(GetTeam()))
	do
		if GetSelectedHeroName(i) ~= "" then
			selectedHeroes[i] = GetSelectedHeroName(i);
		end
	end
	-- check dire
	for _, i in pairs(GetTeamPlayers(GetOpposingTeam()))
	do
		if GetSelectedHeroName(i) ~= "" then
			selectedHeroes[i] = GetSelectedHeroName(i);
		end
	end
	return selectedHeroes;
end

function GetCarryHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesCarry[RandomInt(1, #heroesCarry)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesCarry[RandomInt(1, #heroesCarry)];
	end

	return hero;
end

function GetSupportHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesSupport[RandomInt(1, #heroesSupport)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesSupport[RandomInt(1, #heroesSupport)];
	end

	return hero;
end

function GetRandomHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = hero_pool_my[RandomInt(1, #hero_pool_my)];
	end

	while (selectedHeroes[hero] == true) do
		hero = hero_pool_my[RandomInt(1, #hero_pool_my)];
	end

	return hero;
end

function GetTestPick()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = testTeam[RandomInt(1, #testTeam)];
	end

	while (selectedHeroes[hero] == true) do
		hero = testTeam[RandomInt(1, #testTeam)];
	end

	return hero;
end

-- Insert here hero hame and set "testmode = true" if you want the bot to choose a specific hero (Work only in Radiant team)
local testmode = false;
local testHero = "npc_dota_hero_monkey_king"

local botPlayers = {};
local testPlayer = nil;
local testPick = false;

function Think()
	if GetGameState() ~= GAME_STATE_HERO_SELECTION
	then
		return;
	end

	if testmode
	then
		for _, i in pairs(GetTeamPlayers(GetTeam()))
		do
			if IsPlayerBot(i) and GetSelectedHeroName(i) == ""
			then
				table.insert(botPlayers, i);
			end
		end
		if (#botPlayers > 0)
		then
			if testPlayer == nil
			then
				testPlayer = math.random(1, #botPlayers);
				SelectHero(testPlayer, testHero);
				print("Персонаж: ", testHero, " выбран для теста.");
			end
		end
	end
	--

	local lastpick = 10;

	if testPick
	then
		if GameTime() >= lastpick + 5
		then
			for _, i in pairs(GetTeamPlayers(GetTeam()))
			do
				if IsPlayerBot(i) and GetSelectedHeroName(i) == "" and (i ~= testPlayer)
				then
					hero = GetTestPick();
					SelectHero(i, hero);
					lastpick = GameTime();
					return;
				end
			end
		end
	else
		if (IsHumansPickHeroes() and GameTime() >= lastpick + 5) or
			(GameTime() >= 60 and GameTime() >= lastpick + 2)
		then
			for _, i in pairs(GetTeamPlayers(GetTeam()))
			do
				if IsPlayerBot(i) and GetSelectedHeroName(i) == "" and (i ~= testPlayer)
				then
					local hero = nil;
					if hero_role_generic.GetCountCarryHeroInTeam() < 3
					then
						hero = GetCarryHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					elseif hero_role_generic.GetCountSupportHeroInTeam() < 2
					then
						hero = GetSupportHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					else
						hero = GetRandomHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					end
				end
			end
		end
	end
end

--[[ for _, i in pairs(GetTeamPlayers(GetTeam()))
do
	if IsPlayerBot(i) and GetSelectedHeroName(i) == "" and (i ~= testPlayer)
	then
		if GetCountCarryHeroInTeam() < 3
		then
			hero = GetCarryHero();
			SelectHero(i, hero);
			return;
		elseif GetCountSupportHeroInTeam() < 2
		then
			hero = GetSupportHero();
			SelectHero(i, hero);
			return;
		else
			hero = GetRandomHero();
			SelectHero(i, hero);
			return;
		end
	end
end ]]

-- GetSelectedHeroName(i) == ""
-- not IsPlayerInHeroSelectionControl(i)

function IsHumansPickHeroes()
	-- check radiant
	for _, i in pairs(GetTeamPlayers(GetTeam())) do
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i)
		then
			return false;
		end
	end
	-- check dire
	for _, i in pairs(GetTeamPlayers(GetOpposingTeam())) do
		if GetSelectedHeroName(i) == "" and not IsPlayerBot(i)
		then
			return false;
		end
	end
	-- else humans have picked
	return true;
end

--[[ function UpdateLaneAssignments()
	local lanes =
	{
		[3] = LANE_MID,
		[2] = LANE_TOP,
		[1] = LANE_TOP,
		[4] = LANE_BOT,
		[5] = LANE_BOT,
	}
	return lanes;
end ]]

--[[  for i, id in pairs(GetTeamPlayers(GetTeam()))
do
	if (IsPlayerBot(id) and (GetSelectedHeroName(id) == "" or GetSelectedHeroName(id) == nil))
	then
		local i = RandomInt(1, #hero_pool_my)
		local heroname = hero_pool_my[i]
		table.remove(hero_pool_my, i)
		SelectHero(id, heroname);
	end
end  ]]
--[[ for i, id in pairs(GetTeamPlayers(GetTeam()))
do
	if (IsPlayerBot(id) and (GetSelectedHeroName(id) == "" or GetSelectedHeroName(id) == nil))
	then
		local i = RandomInt(1, #hero_pool_my)
		local heroname = hero_pool_my[i]
		SelectHero(id, heroname);
		table.remove(hero_pool_my, i);
	end
end ]]
--[[ function Think()
	for i, id in pairs(GetTeamPlayers(GetTeam()))
	do
		if (IsPlayerBot(id) and (GetSelectedHeroName(id) == "" or GetSelectedHeroName(id) == nil))
		then
			local i = RandomInt(1, #hero_pool_my)
			local heroname = hero_pool_my[i]
			SelectHero(id, heroname);
			table.remove(hero_pool_my, i)


			--[[ local i = RandomInt(1, #hero_pool_my)
			local num = hero_pool_my[i]
			SelectHero(id, num);
			table.remove(hero_pool_my, i)
		end
	end
end ]]
