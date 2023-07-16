---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("purchase", package.seeall)
require(GetScriptDirectory() .. "/utility")

function ItemPurchase(ItemsToBuy)
	if GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS and GetGameState() ~= GAME_STATE_PRE_GAME
	then
		return;
	end

	local npcBot = GetBot();
	local courier = utility.GetBotCourier(npcBot)

	SellExtraItem()
	utility.PurchaseDust(npcBot)
	utility.PurchaseTP(npcBot)
	utility.PurchaseWardObserver(npcBot)
	--utility.PurchaseTomeOfKnowledge(npcBot) -- Item deleted

	if (#ItemsToBuy == 0)
	then
		npcBot:SetNextItemPurchaseValue(0);
		return;
	end

	sNextItem = ItemsToBuy[1];
	npcBot:SetNextItemPurchaseValue(GetItemCost(sNextItem))

	if npcBot:DistanceFromFountain() <= 1000 or npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4 or npcBot:GetGold() < GetItemCost(sNextItem)
	then
		npcBot.secretShopMode = false;
		npcBot.sideShopMode = false;
	end

	-- sNextItem == "item_aghanims_shard"
	if npcBot:GetGold() >= GetItemCost(sNextItem)
	then
		if GetItemStockCount(sNextItem) <= 0
		then
			if
				sNextItem == "item_tango" or
				sNextItem == "item_clarity" or
				sNextItem == "item_flask" or
				sNextItem == "item_enchanted_mango" or
				sNextItem == "item_infused_raindrop" or
				sNextItem == "item_blood_grenade"
			then
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = false;
				table.remove(ItemsToBuy, 1)
				sNextItem = ItemsToBuy[1];
				npcBot:SetNextItemPurchaseValue(GetItemCost(sNextItem))
			end
		end

		if npcBot:GetGold() >= GetItemCost(sNextItem)
		then
			if npcBot.secretShopMode ~= true and npcBot.sideShopMode ~= true
			then
				if IsItemPurchasedFromSideShop(sNextItem) and npcBot:DistanceFromSideShop() <= 3000
				then
					npcBot.sideShopMode = true;
				end
				if IsItemPurchasedFromSecretShop(sNextItem) and npcBot:DistanceFromSideShop() <= 3000
				then
					npcBot.secretShopMode = true;
				end
			end

			local PurchaseResult

			if npcBot.sideShopMode == true
			then
				if npcBot:DistanceFromSideShop() <= 200
				then
					PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem)
				end
			elseif npcBot.secretShopMode == true
			then
				if npcBot:DistanceFromSecretShop() <= 200
				then
					PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem)
				end
				if courier == nil
				then
					BuyCourier()
				else
					if courier:DistanceFromSecretShop() <= 200
					then
						PurchaseResult = courier:ActionImmediate_PurchaseItem(sNextItem)
					end
				end
			else
				if not utility.IsStashSlotsFull()
				then
					PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem)
				end
			end
			if PurchaseResult == PURCHASE_ITEM_SUCCESS
			then
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = false;
				table.remove(ItemsToBuy, 1)
			end
			if PurchaseResult == PURCHASE_ITEM_OUT_OF_STOCK
			then
				SellExtraItem()
			end
			if PurchaseResult == PURCHASE_ITEM_INVALID_ITEM_NAME or PurchaseResult == PURCHASE_ITEM_DISALLOWED_ITEM
			then
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = false;
				table.remove(ItemsToBuy, 1)
			end
			if PurchaseResult == PURCHASE_ITEM_INSUFFICIENT_GOLD
			then
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = false;
			end
			if PurchaseResult == PURCHASE_ITEM_NOT_AT_SECRET_SHOP
			then
				npcBot.secretShopMode = true
				npcBot.sideShopMode = false;
			end
			if PurchaseResult == PURCHASE_ITEM_NOT_AT_SIDE_SHOP
			then
				npcBot.sideShopMode = true
				npcBot.secretShopMode = false;
			end
			if PurchaseResult == PURCHASE_ITEM_NOT_AT_HOME_SHOP
			then
				npcBot.secretShopMode = false;
				npcBot.sideShopMode = false;
			end
		else
			npcBot.secretShopMode = false;
			npcBot.sideShopMode = false;
		end
	end
end

function SellSpecifiedItem(item_name)
	local npcBot = GetBot();

	local itemCount = 0;
	local item = nil;

	for i = 0, 14
	do
		local sCurItem = npcBot:GetItemInSlot(i);
		if (sCurItem ~= nil)
		then
			itemCount = itemCount + 1;
			if (sCurItem:GetName() == item_name)
			then
				item = sCurItem;
			end
		end
	end

	if (item ~= nil and itemCount >= 6 and (npcBot:DistanceFromFountain() <= 600 or npcBot:DistanceFromSideShop() <= 200 or npcBot:DistanceFromSecretShop() <= 200))
	then
		npcBot:ActionImmediate_SellItem(item);
	end
end

function SellExtraItem()
	local npcBot = GetBot();
	if utility.IsItemSlotsFull()
	then
		if (DotaTime() > 15 * 60)
		then
			SellSpecifiedItem("item_branches")
			SellSpecifiedItem("item_faerie_fire")
			SellSpecifiedItem("item_enchanted_mango")
			SellSpecifiedItem("item_tango")
			SellSpecifiedItem("item_clarity")
			SellSpecifiedItem("item_flask")
			SellSpecifiedItem("item_blood_grenade")
		end
		if (DotaTime() > 20 * 60)
		then
			SellSpecifiedItem("item_magic_stick")
			SellSpecifiedItem("item_magic_wand")
			SellSpecifiedItem("item_stout_shield")
		end
		if (DotaTime() > 30 * 60)
		then
			SellSpecifiedItem("item_wraith_band")
			SellSpecifiedItem("item_bracer")
			SellSpecifiedItem("item_null_talisman")
			SellSpecifiedItem("item_bottle")
			SellSpecifiedItem("item_orb_of_venom")
			SellSpecifiedItem("item_orb_of_corrosion")
			SellSpecifiedItem("item_falcon_blade")
			SellSpecifiedItem("item_soul_ring")
			--SellSpecifiedItem("item_quelling_blade")
			--SellSpecifiedItem("item_urn_of_shadows")
			--SellSpecifiedItem("item_drums_of_endurance")
			--SellSpecifiedItem("item_ring_of_basilius")
		end
		if (DotaTime() > 60 * 60)
		then
			SellSpecifiedItem("item_hand_of_midas")
			SellSpecifiedItem("item_pavise")
			SellSpecifiedItem("item_mask_of_madness")
		end
	end
	if utility.HaveTravelBoots(npcBot)
	then
		SellSpecifiedItem("item_boots")
		SellSpecifiedItem("item_arcane_boots")
		SellSpecifiedItem("item_power_treads")
		SellSpecifiedItem("item_phase_boots")
		SellSpecifiedItem("item_tranquil_boots")
		SellSpecifiedItem("item_boots_of_bearing")
		SellSpecifiedItem("item_guardian_greaves")
	end
end

function BuyCourier()
	local npcBot = GetBot()
	local playerID = npcBot:GetPlayerID()
	local courier = GetCourier(playerID)
	if courier == nil
	then
		if (npcBot:GetGold() >= GetItemCost("item_courier"))
		then
			local info = npcBot:ActionImmediate_PurchaseItem("item_courier");
			if info == PURCHASE_ITEM_SUCCESS
			then
				print(npcBot:GetUnitName() .. ' buy the courier', info);
			end
		end
	else
		if DotaTime() > 60 * 3 and npcBot:GetGold() >= GetItemCost("item_flying_courier") and (courier:GetMaxHealth() == 75)
		then
			local info = npcBot:ActionImmediate_PurchaseItem("item_flying_courier");
			if info == PURCHASE_ITEM_SUCCESS
			then
				print(npcBot:GetUnitName() .. ' has upgraded the courier.', info);
			end
		end
	end
end

for k, v in pairs(purchase) do _G._savedEnv[k] = v end
