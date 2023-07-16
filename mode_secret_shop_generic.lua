---@diagnostic disable: undefined-global
function GetDesire()
	local npcBot = GetBot();
	local desire = 0.0;

	--(npcBot:IsUsingAbility() or npcBot:IsChanneling())

	if not utility.CanCast(npcBot) --不应打断持续施法
	then
		return 0;
	end

	if (npcBot.secretShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) 
	then
		local d = npcBot:DistanceFromSecretShop()
		if d < 3000
		then
			desire = (3000 - d) / d * 0.3 + 0.3; --根据离边路商店的距离返回欲望值
		end
	else
		npcBot.secretShopMode = false
	end

	return desire
end

function Think()
	local npcBot = GetBot();

	local shopLoc1 = GetShopLocation(GetTeam(), SHOP_SECRET);
	local shopLoc2 = GetShopLocation(GetTeam(), SHOP_SECRET2);

	if (GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2))  --选择前往距离自己更近的商店
	then
		npcBot:Action_MoveToLocation(shopLoc1);
	else
		npcBot:Action_MoveToLocation(shopLoc2);
	end
end
