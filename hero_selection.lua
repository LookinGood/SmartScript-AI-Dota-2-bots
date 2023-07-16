---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/bot_name_generic")

--#region All bot-hero by DarkOblivion
--[[
	"npc_dota_hero_hoodwink", -- not work currect
	"npc_dota_hero_keeper_of_the_light", -- not work currect
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
]]
--#endregion

hero_pool_my =
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

function GetRandomHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil) then
		hero = hero_pool_my[RandomInt(1, #hero_pool_my)];
	end

	while (selectedHeroes[hero] == true) do
		hero = hero_pool_my[RandomInt(1, #hero_pool_my)];
	end

	return hero;
end

function Think()
	if GetGameState() ~= GAME_STATE_HERO_SELECTION
	then
		return;
	end

	-- Insert here hero hame and set "testmode = true" if you want the bot to choose a specific hero
	testmode = false;
	testHero = "npc_dota_hero_lina"

	if testmode
	then
		local botPlayers = {};
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
			else
				SelectHero(testPlayer, testHero);
				print("Персонаж: ", testHero, " выбран для теста.");
			end
		end
	end

	--[[ 	if testmode
	then
		for _, i in pairs(GetTeamPlayers(GetTeam()))
		do
			if IsPlayerBot(i) and GetSelectedHeroName(i) == "" and GetSelectedHeroName(i) ~= testHero
			then
				SelectHero(i, testHero);
				--i:ActionImmediate_Chat("Тестирую: " + testHero, true);
				break;
			end
		end
	end ]]

	if (IsHumansPickHeroes() and GameTime() >= 10) or GameTime() >= 60
	then
		for _, i in pairs(GetTeamPlayers(GetTeam()))
		do
			if IsPlayerBot(i) and GetSelectedHeroName(i) == "" and (i ~= testPlayer)
			then
				hero = GetRandomHero();
				SelectHero(i, hero);
			end
		end
	end
end

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
