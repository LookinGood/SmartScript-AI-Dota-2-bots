---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);

	if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsBusy(npcBot) or not utility.CanMove(npcBot) or utility.IsClone(npcBot) or
		(#enemyHeroes > 0) or npcBot.secretShopMode == false or secretShopDistance > 3000 or utility.IsItemSlotsFull()
	then
		return BOT_ACTION_DESIRE_NONE;
	end

	local desire = 0.0;
	local secretShopDistance = npcBot:DistanceFromSecretShop();

	if npcBot.secretShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue() and secretShopDistance <= 3000
	then
		desire = (3000 - secretShopDistance) / secretShopDistance * 0.3 + 0.3;
	else
		npcBot.secretShopMode = false;
		return BOT_ACTION_DESIRE_NONE;
	end

	return desire;
end

function Think()
	local shopLoc1 = GetShopLocation(GetTeam(), SHOP_SECRET);
	local shopLoc2 = GetShopLocation(GetTeam(), SHOP_SECRET2);

	if (GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2))
	then
		if GetUnitToLocationDistance(npcBot, shopLoc1) >= 100
		then
			npcBot:Action_MoveToLocation(shopLoc1);
			return;
		else
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
			return;
		end
	else
		if GetUnitToLocationDistance(npcBot, shopLoc2) >= 100
		then
			npcBot:Action_MoveToLocation(shopLoc2);
			return;
		else
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
			return;
		end
	end
end
