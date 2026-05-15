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
	if utility.IsBusy(npcBot)
	then
		return;
	end

	if index1 ~= nil and index2 ~= nil
	then
		npcBot:ActionImmediate_Chat("Перекладываю вещи.", true);
		npcBot:ActionImmediate_SwapItems(index1, index2);
		return;
	end
end
