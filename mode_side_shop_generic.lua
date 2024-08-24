---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
	local desire = 0.0;

	if not npcBot:IsAlive() or utility.IsClone(npcBot) or (#enemyHeroes > 0) or utility.IsBaseUnderAttack()
	then
		return BOT_ACTION_DESIRE_NONE;
	end

	if (npcBot.sideShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue())
	then
		local d = npcBot:DistanceFromSideShop()
		if d < 2000
		then
			desire = (2000 - d) / d * 0.3 + 0.3;
		end
	else
		npcBot.sideShopMode = false
		return BOT_ACTION_DESIRE_NONE;
	end

	return desire;
end

function Think()
	if utility.IsBusy(npcBot)
	then
		return;
	end

	local shopLoc1 = GetShopLocation(GetTeam(), SHOP_SIDE);
	local shopLoc2 = GetShopLocation(GetTeam(), SHOP_SIDE2);

	if (GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2))
	then
		npcBot:Action_MoveToLocation(shopLoc1);
		return;
	else
		npcBot:Action_MoveToLocation(shopLoc2);
		return;
	end
end
