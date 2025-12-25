---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/bot_name_generic")
require(GetScriptDirectory() .. "/hero_role_generic")

local hero_pool_my, heroesTank, heroesHealers, heroesDpsMelee, heroesDpsRanged, heroesCarry, heroesSupport = hero_role_generic.GetHeroesList();

-- Insert here hero hame and set "testmode = true" if you want the bot to choose a specific hero (Work only in Radiant team)
local testmode = false;
local testHero = "npc_dota_hero_slark"

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

local function GetCarryHero()
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

local function GetTankHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesTank[RandomInt(1, #heroesTank)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesTank[RandomInt(1, #heroesTank)];
	end

	return hero;
end

local function GetHealerHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesHealers[RandomInt(1, #heroesHealers)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesHealers[RandomInt(1, #heroesHealers)];
	end

	return hero;
end

function GetMeleeDpsHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesDpsMelee[RandomInt(1, #heroesDpsMelee)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesDpsMelee[RandomInt(1, #heroesDpsMelee)];
	end

	return hero;
end

function GetRangedDpsHero()
	local hero;
	local picks = GetPicks();
	local selectedHeroes = {};

	for slot, hero in pairs(picks) do
		selectedHeroes[hero] = true;
	end

	if (hero == nil)
	then
		hero = heroesDpsRanged[RandomInt(1, #heroesDpsRanged)];
	end

	while (selectedHeroes[hero] == true) do
		hero = heroesDpsRanged[RandomInt(1, #heroesDpsRanged)];
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
				--print("Персонаж: ", testHero, " выбран для теста.");
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
					if hero_role_generic.GetCountTankHeroInTeam() < 1
					then
						hero = GetTankHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					elseif hero_role_generic.GetCountHealerHeroInTeam() < 1
					then
						hero = GetHealerHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					elseif hero_role_generic.GetCountSupportHeroInTeam() < 2
					then
						hero = GetSupportHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					elseif hero_role_generic.GetCountMeleeDpsHeroInTeam() < 2
					then
						hero = GetMeleeDpsHero();
						SelectHero(i, hero);
						lastpick = GameTime();
						return;
					elseif hero_role_generic.GetCountRangedDpsHeroInTeam() < 1
					then
						hero = GetRangedDpsHero();
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

--[[ 	if testPick
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
	end ]]

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
