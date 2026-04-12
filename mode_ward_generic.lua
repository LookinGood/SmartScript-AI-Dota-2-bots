---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

---RADIANT WARDING SPOT
local RADIANT_TOPSPOT1 = Vector(-4362.3, -1027.3, 229.5); -- Late game
local RADIANT_TOPSPOT2 = Vector(-4442.6, 2027.7, 86.1);
local RADIANT_TOPSPOT3 = Vector(-7938.8, 1834.6, 215.4);
local RADIANT_TOPSPOTNOTOWER = Vector(-6610.1, -3063.9, 209.1);

local RADIANT_BOTTWINGATE = Vector(6847.8, -7351.5, 155.6); -- Late game
local RADIANT_RUNEWISDOM = Vector(-8210.5, 420.0, 295.2);   -- Late game

local RADIANT_MIDSPOT1 = Vector(499.2, -1761.3, 102.5);
local RADIANT_MIDSPOTNOTOWER = Vector(-4343.4, -3883.9, 175.1);

local RADIANT_BOTSPOT1 = Vector(-1305.4, -4340.0, 133.1);  -- Pillar in the forest
local RADIANT_BOTSPOT2 = Vector(-1293.7, -4948.0, 1174.7); -- Late game
local RADIANT_BOTSPOT3 = Vector(5079.9, -4689.8, 127.6);   -- Near T1
local RADIANT_BOTSPOT4 = Vector(963.1, -8698.7, 1211.5);
local RADIANT_BOTSPOT5 = Vector(5431.7, -3572.1, 119.6);   -- Near T1 Dire

local RADIANT_BOTSPOTPOND = Vector(8269.3, -5017.6, 178.8);
local RADIANT_BOTSPOTNOTOWER = Vector(-3603.6, -6108.9, 208.0);


---DIRE WARDING SPOT
local DIRE_TOPSPOT1 = Vector(-1914.8, 3854.4, 1229.0);
local DIRE_TOPSPOT2 = Vector(-884.8, 7634.8, 113.6);  -- Late game
local DIRE_TOPSPOT3 = Vector(1023.3, 3573.9, 135.6);  -- Forest on the pillar
local DIRE_TOPSPOT4 = Vector(-4573.6, 4879.5, 131.4); -- Forest near T1
local DIRE_TOPSPOT5 = Vector(-5451.6, 3792.4, 113.7); -- Forest near T1 Radiant

local DIRE_TOPSPOTPOND = Vector(-7713.2, 4267.1, 119.0);
local DIRE_TOPSPOTNOTOWER = Vector(3098.2, 5769.3, 219.4);

local DIRE_TOPTWINGATE = Vector(-6877.1, 7461.0, 143.0); -- Late game
local DIRE_RUNEWISDOM = Vector(8448.0, -970.3, 290.8);   -- Late game

local DIRE_MIDSPOT1 = Vector(-935.3, 1265.0, 100.4);
local DIRE_MIDSPOTNOTOWER = Vector(4012.5, 3470.9, 203.9);

local DIRE_BOTSPOT1 = Vector(4605.3, 776.1, 195.1); -- Late game
local DIRE_BOTSPOT2 = Vector(2660.3, -1363.4, 91.1);
local DIRE_BOTSPOT3 = Vector(7681.0, -1523.6, 240.7);
local DIRE_BOTSPOTNOTOWER = Vector(6321.9, 2595.6, 201.8);

function GetWardSpot()
    local RadiantWardSpotEarlyGame = {
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOT4,
        RADIANT_BOTSPOT5,
        RADIANT_BOTSPOTPOND,

        DIRE_TOPSPOT3,
        DIRE_TOPSPOT4,
        DIRE_TOPSPOT5,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
    }

    local DireWardSpotEarlyGame = {
        DIRE_TOPSPOT3,
        DIRE_TOPSPOT4,
        DIRE_TOPSPOT5,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,

        RADIANT_TOPSPOT2,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOT4,
        RADIANT_BOTSPOT5,
        RADIANT_BOTSPOTPOND,
    }

    local WardSpotLateGame = {
        RADIANT_TOPSPOT1,
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_TOPSPOTNOTOWER,
        RADIANT_BOTTWINGATE,
        RADIANT_RUNEWISDOM,
        RADIANT_MIDSPOT1,
        RADIANT_MIDSPOTNOTOWER,
        RADIANT_BOTSPOT1,
        RADIANT_BOTSPOT2,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOTNOTOWER,
        DIRE_TOPSPOT1,
        DIRE_TOPSPOT2,
        DIRE_TOPSPOT3,
        DIRE_TOPSPOTNOTOWER,
        DIRE_TOPTWINGATE,
        DIRE_RUNEWISDOM,
        DIRE_MIDSPOT1,
        DIRE_MIDSPOTNOTOWER,
        DIRE_BOTSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,
        DIRE_BOTSPOTNOTOWER,
    }

    if DotaTime() < 15 * 60
    then
        if npcBot:GetTeam() == TEAM_RADIANT
        then
            return RadiantWardSpotEarlyGame;
        else
            return DireWardSpotEarlyGame;
        end
    else
        return WardSpotLateGame;
    end
end

function IsWardAvailable(sWardType)
    local slot = npcBot:FindItemSlot(sWardType);
    if npcBot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
    then
        return npcBot:GetItemInSlot(slot);
    end
    return nil;
end

function GetDesire()
    if utility.NotCurrectHeroBot(npcBot) or utility.IsCloneMeepo(npcBot) or not npcBot:IsAlive() or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    index1 = nil;
    index2 = nil;
    local emptySlot = utility.GetEmptyMainItemSlot();
    local emptyStashItemSlot = utility.GetEmptyStashItemSlot();
    local trashItemSlot = utility.GetBotTrashItemSlot();
    local recipeItemSlot = utility.GetBotRecipeItemSlot();

    -- Перемещение бесценных предметов в инвентарь
    if emptySlot ~= nil
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

        --[[ local lotusSlot1 = npcBot:FindItemSlot("item_famango");
        local lotusSlot2 = npcBot:FindItemSlot("item_great_famango");
        local lotusSlot3 = npcBot:FindItemSlot("item_greater_famango");

        if lotusSlot1 ~= nil or
            lotusSlot2 ~= nil or
            lotusSlot3 ~= nil
        then
            if npcBot:GetItemSlotType(lotusSlot1) == ITEM_SLOT_TYPE_BACKPACK
            then
                --npcBot:ActionImmediate_Chat("Хочу переложить healingLotus!", true);
                index1 = lotusSlot1;
                index2 = emptySlot;
                return BOT_MODE_DESIRE_ABSOLUTE;
            end
            if npcBot:GetItemSlotType(lotusSlot2) == ITEM_SLOT_TYPE_BACKPACK
            then
                --npcBot:ActionImmediate_Chat("Хочу переложить greatHealingLotus!", true);
                index1 = lotusSlot2;
                index2 = emptySlot;
                return BOT_MODE_DESIRE_ABSOLUTE;
            end
            if npcBot:GetItemSlotType(lotusSlot3) == ITEM_SLOT_TYPE_BACKPACK
            then
                --npcBot:ActionImmediate_Chat("Хочу переложить greaterHealingLotus!", true);
                index1 = lotusSlot3;
                index2 = emptySlot;
                return BOT_MODE_DESIRE_ABSOLUTE;
            end
        end ]]
    end

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

    local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);

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
                if ((droppedItem.item:GetName() == "item_gem" and not utility.IsBotHaveItem("item_gem")) or droppedItem.item:GetName() == "item_rapier")
                then
                    if utility.GetEmptyMainItemSlot() ~= nil
                    then
                        pickUpItem = droppedItem.item;
                        pickUpItemLocation = droppedItem.location;
                        --npcBot:ActionImmediate_Chat("Нужно поднять гем/рапиру: " .. pickUpItem:GetName(), true);
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

    if not utility.IsClone(npcBot) and (GetCourierState(courier) == COURIER_STATE_DELIVERING_ITEMS) and GetUnitToUnitDistance(courier, npcBot) <= 1600
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

    local enemyTowers = npcBot:GetNearbyTowers(1000, true);

    if (#enemyTowers > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    enemyWard = nil;
    enemyCourier = nil;
    -- (npcBot:GetAttackRange() + 150 * 2)

    local enemyWards = GetUnitList(UNIT_LIST_ENEMY_WARDS);
    if (#enemyWards > 0)
    then
        for _, ward in pairs(enemyWards) do
            if ward:CanBeSeen() and not ward:IsInvulnerable() and GetUnitToUnitDistance(npcBot, ward) <= 1600
                and IsLocationPassable(ward:GetLocation())
            then
                enemyWard = ward;
                return BOT_ACTION_DESIRE_ABSOLUTE;
            end
        end
    end

    local enemyCouriers = npcBot:GetNearbyCreeps(1600, true);
    if (#enemyCouriers > 0)
    then
        for _, courier in pairs(enemyCouriers) do
            if (courier:CanBeSeen() and not courier:IsInvulnerable() and IsLocationPassable(courier:GetLocation())) and
                (courier:IsCourier() or courier:IsFlyingCourier())
            then
                enemyCourier = courier;
                return BOT_ACTION_DESIRE_ABSOLUTE;
            end
        end
    end

    if GetGameState() == GAME_STATE_PRE_GAME or GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS or utility.IsBaseUnderAttack()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    wardObserver = IsWardAvailable("item_ward_observer");
    wardSentry = IsWardAvailable("item_ward_sentry");
    wardDispenser = IsWardAvailable("item_ward_dispenser");

    if (wardObserver ~= nil and wardObserver:IsFullyCastable()) or
        (wardSentry ~= nil and wardSentry:IsFullyCastable()) or
        (wardDispenser ~= nil and wardDispenser:IsFullyCastable())
    then
        for _, s in pairs(GetWardSpot()) do
            if GetUnitToLocationDistance(npcBot, s) <= 2000 and utility.CountAllyTowerAroundPosition(s, 1000) <= 0
                and utility.CountEnemyTowerAroundPosition(s, 1000) <= 0
            then
                if wardObserver ~= nil
                then
                    local wardObserverRadius = wardObserver:GetSpecialValueInt("vision_range_tooltip");
                    if not utility.CloseToAvailableWard("npc_dota_observer_wards", s, wardObserverRadius)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                elseif wardSentry ~= nil
                then
                    local wardSentryRadius = wardSentry:GetSpecialValueInt("true_sight_range");
                    if not utility.CloseToAvailableWard("npc_dota_sentry_wards", s, wardSentryRadius)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                elseif wardDispenser ~= nil
                then
                    local wardObserverRadius = wardDispenser:GetSpecialValueInt("observer_vision_range_tooltip");
                    local wardSentryRadius = wardDispenser:GetSpecialValueInt("true_sight_range");
                    if not utility.CloseToAvailableWard("npc_dota_observer_wards", s, wardObserverRadius) and
                        not utility.CloseToAvailableWard("npc_dota_sentry_wards", s, wardSentryRadius)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
    --[[     if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Иду ставить вард.", false);
    end ]]
end

function OnEnd()
    enemyWard = nil;
    enemyCourier = nil;
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot) or npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_ITEM or npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_DROP_ITEM
    then
        return;
    end

    if index1 ~= nil and index2 ~= nil
    then
        --npcBot:ActionImmediate_Chat("Перекладываю вещи.", true);
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
        local boundRadius = npcBot:GetBoundingRadius();
        if GetUnitToUnitDistance(npcBot, courier) > boundRadius * 2
        then
            if dropItem ~= nil
            then
                if GetItemCost(dropItem:GetName()) > 0 and (npcBot:DistanceFromFountain() <= 500 or npcBot:DistanceFromSecretShop() <= 500)
                then
                    npcBot:ActionImmediate_Chat("Продаю предмет: " .. dropItem:GetName(), true);
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

    if enemyWard ~= nil
    then
        npcBot:SetTarget(enemyWard);
        npcBot:Action_AttackUnit(enemyWard, false);
        return;
        --[[   if GetUnitToUnitDistance(npcBot, enemyWard) > (npcBot:GetAttackRange() + 150)
        then
            npcBot:Action_MoveToLocation(enemyWard:GetLocation());
            return;
        else
            --npcBot:ActionImmediate_Chat("Ломаю вражеский вард!", true);
            npcBot:Action_AttackUnit(enemyWard, false);
            return;
        end ]]
    end

    if enemyCourier ~= nil
    then
        npcBot:SetTarget(enemyCourier);
        npcBot:Action_AttackUnit(enemyCourier, false);
        return;

        --[[ if GetUnitToUnitDistance(npcBot, enemyCourier) > (npcBot:GetAttackRange() + 200)
        then
            npcBot:Action_MoveToLocation(enemyCourier:GetLocation());
            return;
        else
            npcBot:ActionImmediate_Chat("Атакую вражеского курьера!", true);
            npcBot:Action_AttackUnit(enemyCourier, false);
            return;
        end ]]
    end

    if wardSpot ~= nil
    then
        if GetUnitToLocationDistance(npcBot, wardSpot) > 500
        then
            npcBot:Action_MoveToLocation(wardSpot);
            return;
        else
            if wardObserver ~= nil and wardObserver:IsFullyCastable()
            then
                --npcBot:ActionImmediate_Chat("Ставлю wardObserver!", true);
                npcBot:Action_UseAbilityOnLocation(wardObserver, wardSpot + RandomVector(50));
                return;
            elseif wardSentry ~= nil and wardSentry:IsFullyCastable()
            then
                --npcBot:ActionImmediate_Chat("Ставлю wardSentry!", true);
                npcBot:Action_UseAbilityOnLocation(wardSentry, wardSpot + RandomVector(50));
                return;
            elseif wardDispenser ~= nil and wardDispenser:IsFullyCastable()
            then
                --npcBot:ActionImmediate_Chat("Ставлю wardDispenser!", true);
                npcBot:Action_UseAbilityOnLocation(wardDispenser, wardSpot + RandomVector(50));
                return;
            end
        end
    end
end

--[[     if (itemLotus ~= nil)
    then
        npcBot:ActionImmediate_SwapItems(itemLotusSlot, emptySlot);
        --npcBot:ActionImmediate_Chat("Перекладываю healingLotus!", true);
        --npcBot:Action_ClearActions(false);
        --npcBot:Action_DropItem(itemLotus, npcBot:GetLocation());
        return;
    end ]]


--[[ if utility.IsItemSlotsFull()
then
    if trashItemSlot ~= nil and (npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_MAIN or npcBot:GetItemSlotType(trashItemSlot) == ITEM_SLOT_TYPE_BACKPACK)
    then
        if (droppedItem.item:GetName() == "item_gem" or droppedItem.item:GetName() == "item_rapier")
        then
            dropItem = npcBot:GetItemInSlot(trashItemSlot);
            pickUpItem = droppedItem.item;
            pickUpItemLocation = droppedItem.location;
            --npcBot:ActionImmediate_Chat("Нужно поднять: " .. pickUpItem:GetName(), true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
        if (droppedItem.owner == npcBot and (droppedItem.item:GetName() ~= "item_gem" or droppedItem.item:GetName() ~= "item_rapier")) or
            (droppedItem.item:GetName() == "item_cheese" or
                droppedItem.item:GetName() == "item_roshans_banner" or
                droppedItem.item:GetName() == "item_refresher_shard")
        then
            dropItem = npcBot:GetItemInSlot(trashItemSlot);
            pickUpItem = droppedItem.item;
            pickUpItemLocation = droppedItem.location;
            --npcBot:ActionImmediate_Chat("Нужно поднять: " .. pickUpItem:GetName(), true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
    end
else

end

if utility.GetEmptyMainItemSlot() ~= nil
then
    if droppedItem.owner == npcBot or
        (droppedItem.item:GetName() == "item_cheese" or
            droppedItem.item:GetName() == "item_roshans_banner" or
            droppedItem.item:GetName() == "item_refresher_shard")
    then

    end
else

end

if (droppedItem.owner == npcBot and droppedItem.item:GetName() ~= "item_gem" and droppedItem.item:GetName() ~= "item_rapier") or
    (droppedItem.item:GetName() == "item_cheese" or
        droppedItem.item:GetName() == "item_roshans_banner" or
        droppedItem.item:GetName() == "item_refresher_shard") or
    (droppedItem.item:GetName() == "item_gem" or droppedItem.item:GetName() == "item_rapier"
        and utility.GetEmptyMainItemSlot() ~= nil)
then
    pickUpItem = droppedItem.item;
    pickUpItemLocation = droppedItem.location;
    --npcBot:ActionImmediate_Chat("Нужно поднять: " .. pickUpItem:GetName(), true);
    return BOT_MODE_DESIRE_ABSOLUTE;
end ]]
