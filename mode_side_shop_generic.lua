function GetDesire()

	local npcBot = GetBot();
	
	local desire = 0.0;
	
	if ( npcBot:IsUsingAbility() or npcBot:IsChanneling() )		--不应打断持续施法
	then
		return 0
	end
	
	if ( npcBot.sideShopMode == true and npcBot:GetGold() >= npcBot:GetNextItemPurchaseValue()) then
		local d=npcBot:DistanceFromSideShop()
		if d<2000
		then
			desire = (2000-d)/d*0.3+0.3;					--根据离边路商店的距离返回欲望值
		end
	else
		npcBot.sideShopMode = false
	end

	return desire

end

function Think()
	
	local npcBot = GetBot();
	
	local shopLoc1 = GetShopLocation( GetTeam(), SHOP_SIDE );
	local shopLoc2 = GetShopLocation( GetTeam(), SHOP_SIDE2 );

	if ( GetUnitToLocationDistance(npcBot, shopLoc1) <= GetUnitToLocationDistance(npcBot, shopLoc2) ) then	--选择前往距离自己更近的商店
		npcBot:Action_MoveToLocation( shopLoc1 );
	else
		npcBot:Action_MoveToLocation( shopLoc2 );
	end
end