---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
	local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
	local secretShopDistance = npcBot:DistanceFromSecretShop();

	if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsClone(npcBot) or (#enemyHeroes > 0)
		or npcBot.secretShopMode == false or secretShopDistance > 3000 or utility.IsItemSlotsFull() or utility.IsBaseUnderAttack()
	then
		return BOT_ACTION_DESIRE_NONE;
	end

	--local desire = 0.0;

	if npcBot.secretShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue() and secretShopDistance <= 3000
	then
		--desire = (3000 - secretShopDistance) / secretShopDistance * 0.3 + 0.3;
		return BOT_ACTION_DESIRE_HIGH;
	end

	--return desire;
	--npcBot.secretShopMode = false;
	return BOT_ACTION_DESIRE_NONE;
end

--[[ function OnStart()
	if RollPercentage(5)
	then
		npcBot:ActionImmediate_Chat("Иду в секретную лавку.", false);
	end
end ]]

function OnEnd()
	npcBot:SetTarget(nil);
end

function Think()
	if utility.IsBusy(npcBot)
	then
		return;
	end

	local shopLoc1 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET);
	local shopLoc2 = GetShopLocation(npcBot:GetTeam(), SHOP_SECRET2);

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
