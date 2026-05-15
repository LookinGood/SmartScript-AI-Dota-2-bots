---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

-- Debugg
local function printObjectFields(object)
	for key, value in pairs(object) do
		if type(value) == "table" then
			print(key .. ":")
			printObjectFields(value)     -- Рекурсивный вызов для таблиц
		else
			print(key .. ": " .. tostring(value)) -- Преобразование значения в строку
		end
	end
end

function GetMostExpensiveBackpackItem()
	local expensiveItem = nil;
	local maxCost = 0;

	for i = 6, 8 do
		local item = npcBot:GetItemInSlot(i);
		local cost = GetItemCost(item:GetName());
		if cost > maxCost and not string.find(item:GetName(), "ward")
		then
			expensiveItem = item;
			maxCost = cost;
		end
	end

	return expensiveItem;
end

function GetMostCheapestMainItem()
	local cheapestItem = nil;
	local minCost = 10000;

	for i = 0, 5 do
		local item = npcBot:GetItemInSlot(i);
		local cost = GetItemCost(item:GetName());
		if cost < minCost and not string.find(item:GetName(), "ward")
		then
			cheapestItem = item;
			minCost = cost;
		end
	end

	return cheapestItem;
end

function GetDesire()
	--local itemList = GetDroppedItemList();
	--print(printObjectFields(itemList))

	if not utility.IsHero(npcBot) or utility.IsCloneMeepo(npcBot)
	then
		return BOT_MODE_DESIRE_NONE;
	end

	local emptyMainSlot = utility.GetEmptyMainItemSlot();
	local emptyBackpackSlot = utility.GetEmptyBackpackItemSlot();
	local cheapestMainItem = GetMostCheapestMainItem();
	local expensiveBackpackItem = GetMostExpensiveBackpackItem();

	index1 = nil;
	index2 = nil;
	local emptySlot = utility.GetEmptyMainItemSlot();
	local emptyStashItemSlot = utility.GetEmptyStashItemSlot();
	local trashItemSlot = utility.GetBotTrashItemSlot();
	local recipeItemSlot = utility.GetBotRecipeItemSlot();

	if expensiveBackpackItem ~= nil and emptyMainSlot ~= nil
	then
		index1 = npcBot:FindItemSlot(expensiveBackpackItem:GetName());
		index2 = emptyMainSlot;
		npcBot:ActionImmediate_Chat("Хочу переложить в пустой слот: " .. index1 .. " и " .. index2, true);
		return BOT_MODE_DESIRE_ABSOLUTE;
	elseif expensiveBackpackItem ~= nil and cheapestMainItem ~= nil
	then
		if GetItemCost(expensiveBackpackItem:GetName()) > GetItemCost(cheapestMainItem:GetName())
		then
			index1 = npcBot:FindItemSlot(expensiveBackpackItem:GetName());
			index2 = npcBot:FindItemSlot(cheapestMainItem:GetName());
			npcBot:ActionImmediate_Chat("Хочу переложить: " .. index1 .. " и " .. index2, true);
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	end

	-- Перемещение бесценных предметов в инвентарь
	--[[ if emptySlot ~= nil
	then
		local zeroCostItemSlot = utility.GetZeroCostItemSlot();
		if zeroCostItemSlot ~= nil
		then
			if npcBot:GetItemSlotType(zeroCostItemSlot) == ITEM_SLOT_TYPE_BACKPACK
			then
				index1 = zeroCostItemSlot;
				index2 = emptySlot;
				--npcBot:ActionImmediate_Chat("Хочу переложить бесценый итем в инвентарь: " .. index1 .. " в " .. index2, true);
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		end
	end ]]

	-- Освобождение места в инвентаре
	if npcBot:DistanceFromFountain() <= 500
	then
		local expensiveStashItem = utility.GetMostExpensiveStashItem();

		if trashItemSlot ~= nil and (npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_MAIN or npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_BACKPACK)
		then
			if expensiveStashItem ~= nil and not utility.IsItemRecipe(expensiveStashItem:GetName()) and
				not utility.IsItemTrash(expensiveStashItem:GetName())
			then
				index1 = trashItemSlot;
				index2 = npcBot:FindItemSlot(expensiveStashItem:GetName());
				--npcBot:ActionImmediate_Chat("Хочу переложить мусор и стеш-вещь: " .. index1 .. " и " .. index2, true);
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		end

		if recipeItemSlot ~= nil and (npcBot:GetItemSlotType(recipeItemSlot) == ITEM_SLOT_TYPE_MAIN or npcBot:GetItemSlotType(recipeItemSlot) == ITEM_SLOT_TYPE_BACKPACK)
		then
			if expensiveStashItem ~= nil and not utility.IsItemRecipe(expensiveStashItem:GetName())
			then
				index1 = recipeItemSlot;
				index2 = npcBot:FindItemSlot(expensiveStashItem:GetName());
				--npcBot:ActionImmediate_Chat("Хочу переложить рецепт и вещь: " .. index1 .. " и " .. index2, true);
				return BOT_MODE_DESIRE_ABSOLUTE;
			end

			if emptyStashItemSlot ~= nil
			then
				index1 = recipeItemSlot;
				index2 = emptyStashItemSlot;
				--npcBot:ActionImmediate_Chat("Хочу переложить рецепт в пустой стеш-слот: " .. index1 .. " и " .. index2, true);
				return BOT_MODE_DESIRE_ABSOLUTE;
			end
		end
	end

	local enemyHeroes = npcBot:GetNearbyHeroes(npcBot:GetAcquisitionRange(), true, BOT_MODE_NONE);

	if (#enemyHeroes > 0)
	then
		return BOT_ACTION_DESIRE_NONE;
	end

	-- Подбор предметов
	local itemList = GetDroppedItemList();
	pickUpItem = nil;
	pickUpItemLocation = nil;
	dropItem = nil;

	if not utility.IsClone(npcBot) and (#itemList > 0)
	then
		for _, droppedItem in pairs(itemList) do
			if droppedItem ~= nil and GetUnitToLocationDistance(npcBot, droppedItem.location) <= 1600 and IsLocationPassable(droppedItem.location)
			then
				if ((droppedItem.item:GetName() == "item_gem" and not utility.IsBotHaveItem("item_gem")) or
						droppedItem.item:GetName() == "item_rapier" or
						droppedItem.item:GetName() == "item_aegis")
				then
					if utility.GetEmptyMainItemSlot() ~= nil
					then
						pickUpItem = droppedItem.item;
						pickUpItemLocation = droppedItem.location;
						npcBot:ActionImmediate_Chat("Нужно поднять гем/рапиру/аегис: " .. pickUpItem:GetName(), true);
						return BOT_MODE_DESIRE_ABSOLUTE;
					else
						if trashItemSlot ~= nil and (npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_MAIN)
						then
							dropItem = npcBot:GetItemInSlot(trashItemSlot);
							pickUpItem = droppedItem.item;
							pickUpItemLocation = droppedItem.location;
							--npcBot:ActionImmediate_Chat("Выкидываю/Поднимаю: " .. dropItem:GetName() .. " , " .. pickUpItem:GetName(), true);
							return BOT_MODE_DESIRE_ABSOLUTE;
						end
					end
				elseif (droppedItem.item:GetName() == "item_cheese" or
						droppedItem.item:GetName() == "item_roshans_banner" or
						droppedItem.item:GetName() == "item_refresher_shard")
				then
					if not utility.IsItemSlotsFull()
					then
						pickUpItem = droppedItem.item;
						pickUpItemLocation = droppedItem.location;
						--npcBot:ActionImmediate_Chat("Нужно поднять вещь рошана: " .. pickUpItem:GetName(), true);
						return BOT_MODE_DESIRE_ABSOLUTE;
					else
						if trashItemSlot ~= nil and (npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_MAIN or
								npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_BACKPACK)
						then
							dropItem = npcBot:GetItemInSlot(trashItemSlot);
							pickUpItem = droppedItem.item;
							pickUpItemLocation = droppedItem.location;
							--npcBot:ActionImmediate_Chat("Выкидываю/Поднимаю(Рошан): " .. dropItem:GetName() .. " , " .. pickUpItem:GetName(), true);
							return BOT_MODE_DESIRE_ABSOLUTE;
						end
					end
				else
					if droppedItem.owner == npcBot
					then
						if not utility.IsItemSlotsFull()
						then
							pickUpItem = droppedItem.item;
							pickUpItemLocation = droppedItem.location;
							--npcBot:ActionImmediate_Chat("Нужно поднять мою вещь: " .. pickUpItem:GetName(), true);
							return BOT_MODE_DESIRE_ABSOLUTE;
						end
					end
				end
			end
		end
	end

	courier = utility.GetBotCourier(npcBot);
	isCourierNearAndDeliver = false;

	if not utility.IsClone(npcBot) and (GetCourierState(courier) == COURIER_STATE_DELIVERING_ITEMS) and GetUnitToUnitDistance(courier, npcBot) <= npcBot:GetAcquisitionRange()
		and not utility.IsRoshan(npcBot:GetAttackTarget())
	then
		if trashItemSlot ~= nil
		then
			if (not utility.IsItemSlotsFull() and utility.IsTargetHaveItem(courier, "item_gem") and npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_MAIN)
				or utility.IsItemSlotsFull()
			then
				dropItem = npcBot:GetItemInSlot(trashItemSlot);
				if dropItem ~= nil and npcBot:GetCourierValue() > GetItemCost(dropItem:GetName())
				then
					--npcBot:ActionImmediate_Chat("Нужно встретить курьера: " .. dropItem:GetName(), true);
					isCourierNearAndDeliver = true;
					return BOT_MODE_DESIRE_ABSOLUTE;
				end
			end
		end
		if not utility.IsItemSlotsFull() and npcBot:DistanceFromFountain() >= 3000
		then
			isCourierNearAndDeliver = true;
			return BOT_MODE_DESIRE_ABSOLUTE;
		end
	end

	return BOT_ACTION_DESIRE_NONE;
end

function OnStart()

end

function OnEnd()
	npcBot:SetTarget(nil);
	index1 = nil;
	index2 = nil;
end

function Think()
	if utility.IsBusy(npcBot) or
		npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_ITEM or
		npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_DROP_ITEM
	then
		return;
	end

	if index1 ~= nil and index2 ~= nil
	then
		npcBot:ActionImmediate_Chat("Перекладываю вещи.", true);
		npcBot:ActionImmediate_SwapItems(index1, index2);
		return;
	end

	if pickUpItem ~= nil and pickUpItemLocation ~= nil
	then
		if dropItem == nil
		then
			if GetUnitToLocationDistance(npcBot, pickUpItemLocation) > 100
			then
				--npcBot:ActionImmediate_Chat("Иду к предмету: " .. pickUpItem:GetName(), true);
				--npcBot:ActionImmediate_Ping(pickUpItemLocation.x, pickUpItemLocation.y, true);
				npcBot:Action_MoveToLocation(pickUpItemLocation + RandomVector(100));
				return;
			else
				--npcBot:ActionImmediate_Chat("Поднимаю предмет: " .. pickUpItem:GetName(), true);
				npcBot:Action_PickUpItem(pickUpItem);
				return;
			end
		else
			if GetUnitToLocationDistance(npcBot, pickUpItemLocation) > 100
			then
				npcBot:Action_MoveToLocation(pickUpItemLocation + RandomVector(100));
				return;
			else
				--npcBot:ActionImmediate_Chat("Выкидываю/Поднимаю.", true);
				npcBot:ActionQueue_DropItem(dropItem, npcBot:GetLocation());
				npcBot:ActionQueue_PickUpItem(pickUpItem);
				return;
			end
		end
	end

	if (isCourierNearAndDeliver == true)
	then
		if dropItem ~= nil
		then
			if GetItemCost(dropItem:GetName()) > 0 and (npcBot:DistanceFromFountain() <= 500 or npcBot:DistanceFromSecretShop() <= 500)
			then
				--npcBot:ActionImmediate_Chat("Продаю предмет: " .. dropItem:GetName(), true);
				npcBot:ActionImmediate_SellItem(dropItem);
				return;
			else
				--npcBot:ActionImmediate_Chat("Выкидываю предмет: " .. dropItem:GetName(), true);
				npcBot:Action_DropItem(dropItem, npcBot:GetLocation());
				return;
			end
		end
		--npcBot:ActionImmediate_Chat("Встречаю курьера!", true);
		npcBot:Action_MoveToUnit(courier);
		return;
	end
end
