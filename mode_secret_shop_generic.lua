---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

function GetDesire()
	local npcBot = GetBot();
	local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
	local desire = 0.0;
	local secretShopDistance = npcBot:DistanceFromSecretShop()

	if not npcBot:IsAlive() or npcBot:IsUsingAbility() or npcBot:IsChanneling() or not utility.CanMove(npcBot) or (#enemyHeroes > 0)
		or npcBot.secretShopMode == false or secretShopDistance > 3000 or utility.IsItemSlotsFull()
	then
		return BOT_ACTION_DESIRE_NONE;
	end

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
	local npcBot = GetBot();

	local shopLoc1 = GetShopLocation(GetTeam(), SHOP_SECRET);
	local shopLoc2 = GetShopLocation(GetTeam(), SHOP_SECRET2);

	if (GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2))
	then
		if GetUnitToLocationDistance(npcBot, shopLoc1) >= 100
		then
			npcBot:Action_MoveToLocation(shopLoc1);
		else
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
		end
	else
		if GetUnitToLocationDistance(npcBot, shopLoc2) >= 100
		then
			npcBot:Action_MoveToLocation(shopLoc2);
		else
			npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
		end
	end
end
