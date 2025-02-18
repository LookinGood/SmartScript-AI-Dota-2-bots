---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("purchase", package.seeall)
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/hero_role_generic")

function ItemPurchase(ItemsToBuy, realItemsToBuy)
    if GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS and GetGameState() ~= GAME_STATE_PRE_GAME
    then
        return;
    end

    local npcBot = GetBot();

    if npcBot == nil or npcBot:IsIllusion() or not npcBot:IsHero() or utility.IsClone(npcBot)
    then
        return;
    end

    local courier = utility.GetBotCourier(npcBot);
    local courierState = GetCourierState(courier);

    SellExtraItem()
    utility.PurchaseBottle(npcBot)
    utility.PurchaseTP(npcBot)
    utility.PurchaseWardObserver(npcBot)
    utility.PurchaseWardSentry(npcBot)
    utility.PurchaseDust(npcBot)
    utility.PurchaseInfusedRaindrop(npcBot)
    --utility.PurchaseTomeOfKnowledge(npcBot) -- Item deleted

    if (#ItemsToBuy == 0)
    then
        npcBot:SetNextItemPurchaseValue(0);
        return;
    end

    local sNextItem = ItemsToBuy[1];
    local itemRecepie = GetItemComponents(sNextItem);
    local itemComponents = itemRecepie[1];
    local PurchaseResult;

    if (#itemRecepie > 0)
    then
        if (#realItemsToBuy == 0) and (#realItemsToBuy < #itemComponents)
        then
            for _, item in pairs(itemComponents) do
                if item ~= nil
                then
                    table.insert(realItemsToBuy, item);
                else
                    break;
                end
            end
        end
    else
        if (#realItemsToBuy == 0)
        then
            table.insert(realItemsToBuy, 1, sNextItem);
        end
    end

    if realItemsToBuy[1] ~= nil
    then
        sNextItem = realItemsToBuy[1];
        npcBot:SetNextItemPurchaseValue(GetItemCost(sNextItem));
    else
        table.remove(realItemsToBuy, 1);
    end

    if sNextItem ~= nil
    then
        -- Удаление предметов не нуждающихся в дублировании
        if sNextItem == "item_blink" or
            sNextItem == "item_quelling_blade" or
            sNextItem == "item_orb_of_venom" or
            sNextItem == "item_lifesteal" or
            sNextItem == "item_boots" or
            sNextItem == "item_wind_lace"
        then
            if utility.IsBotHaveItem(sNextItem)
            then
                --npcBot:ActionImmediate_Chat("Удаляю предмет из списка т.к он уже есть.", true);
                npcBot.secretShopMode = false;
                npcBot.sideShopMode = false;
                table.remove(realItemsToBuy, 1);
            end
        end

        if npcBot:GetGold() < GetItemCost(sNextItem)
        then
            npcBot.secretShopMode = false;
            npcBot.sideShopMode = false;
        else
            if npcBot.secretShopMode ~= true and npcBot.sideShopMode ~= true
            then
                if IsItemPurchasedFromSideShop(sNextItem) and npcBot:DistanceFromSideShop() <= 3000 and not utility.IsItemSlotsFull()
                    and npcBot:DistanceFromSideShop() ~= 0
                then
                    npcBot.sideShopMode = true;
                end
                if IsItemPurchasedFromSecretShop(sNextItem) and npcBot:DistanceFromSecretShop() <= 3000 and not utility.IsItemSlotsFull()
                then
                    npcBot.secretShopMode = true;
                end
            end

            if npcBot.sideShopMode == true
            then
                if npcBot:DistanceFromSideShop() <= 200 and not utility.IsItemSlotsFull()
                then
                    PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem);
                end
            elseif npcBot.secretShopMode == true
            then
                if npcBot:DistanceFromSecretShop() <= 200 and not utility.IsItemSlotsFull()
                then
                    PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem);
                else
                    if courier ~= nil
                    then
                        if courier:DistanceFromSecretShop() <= 200 and not utility.IsCourierItemSlotsFull()
                        then
                            PurchaseResult = courier:ActionImmediate_PurchaseItem(sNextItem);
                        end
                    end
                end
            else
                if npcBot:DistanceFromFountain() <= 400
                then
                    if not utility.IsItemSlotsFull() or (utility.IsItemSlotsFull() and not utility.IsStashSlotsFull())
                    then
                        PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem);
                    else
                        if courierState == COURIER_STATE_AT_BASE and not utility.IsCourierItemSlotsFull()
                        then
                            PurchaseResult = courier:ActionImmediate_PurchaseItem(sNextItem);
                        end
                    end
                else
                    if not utility.IsStashSlotsFull()
                    then
                        PurchaseResult = npcBot:ActionImmediate_PurchaseItem(sNextItem);
                    else
                        if courierState == COURIER_STATE_AT_BASE and not utility.IsCourierItemSlotsFull()
                        then
                            PurchaseResult = courier:ActionImmediate_PurchaseItem(sNextItem);
                        end
                    end
                end
            end
            if sNextItem == "item_aghanims_shard"
            then
                if PurchaseResult ~= PURCHASE_ITEM_SUCCESS and
                    PurchaseResult ~= PURCHASE_ITEM_OUT_OF_STOCK and
                    PurchaseResult ~= PURCHASE_ITEM_INVALID_ITEM_NAME and
                    PurchaseResult ~= PURCHASE_ITEM_DISALLOWED_ITEM
                then
                    npcBot.secretShopMode = false;
                    npcBot.sideShopMode = false;
                    table.remove(realItemsToBuy, 1);
                end
            end
            if PurchaseResult == PURCHASE_ITEM_SUCCESS
            then
                npcBot.secretShopMode = false;
                npcBot.sideShopMode = false;
                table.remove(realItemsToBuy, 1);
            end
            if PurchaseResult == PURCHASE_ITEM_OUT_OF_STOCK
            then
                if sNextItem == "item_aghanims_shard"
                then
                    npcBot.secretShopMode = false;
                    npcBot.sideShopMode = false;
                    table.remove(realItemsToBuy, 1);
                    table.insert(realItemsToBuy, 3, "item_aghanims_shard");
                else
                    if sNextItem == "item_tango" or
                        sNextItem == "item_clarity" or
                        sNextItem == "item_flask" or
                        sNextItem == "item_enchanted_mango" or
                        sNextItem == "item_infused_raindrop" or
                        sNextItem == "item_blood_grenade"
                    then
                        npcBot.secretShopMode = false;
                        npcBot.sideShopMode = false;
                        table.remove(realItemsToBuy, 1);
                    end
                end
            end
            if PurchaseResult == PURCHASE_ITEM_INVALID_ITEM_NAME or PurchaseResult == PURCHASE_ITEM_DISALLOWED_ITEM
            then
                if sNextItem == "item_aghanims_shard"
                then
                    npcBot.secretShopMode = false;
                    npcBot.sideShopMode = false;
                    table.remove(realItemsToBuy, 1);
                    table.insert(realItemsToBuy, 3, "item_aghanims_shard");
                else
                    npcBot.secretShopMode = false;
                    npcBot.sideShopMode = false;
                    table.remove(realItemsToBuy, 1);
                end
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
        end
    end
    if (#realItemsToBuy == 0)
    then
        table.remove(ItemsToBuy, 1);
    end
end

function SellSpecifiedItem(item_name)
    local npcBot = GetBot();
    if not npcBot:IsAlive() or item_name == nil
    then
        return;
    end

    for i = 0, 8
    do
        local slotItem = npcBot:GetItemInSlot(i);
        if slotItem ~= nil and slotItem:GetName() == item_name
        then
            if npcBot:DistanceFromFountain() <= 600 or npcBot:DistanceFromSecretShop() <= 200
            then
                --npcBot:ActionImmediate_Chat("Продаю лишний предмет!", true);
                npcBot:ActionImmediate_SellItem(slotItem);
                return;
            end
        end
    end

    for i = 9, 14
    do
        local slotItem = npcBot:GetItemInSlot(i);
        if slotItem ~= nil and slotItem:GetName() == item_name
        then
            --npcBot:ActionImmediate_Chat("Продаю лишний предмет из тайника!", true);
            npcBot:ActionImmediate_SellItem(slotItem);
            return;
        end
    end

    --local courier = utility.GetBotCourier(npcBot);

    --[[     for i = 0, 8
    do
        local slotItem = courier:GetItemInSlot(i);
        if slotItem ~= nil and slotItem:GetName() == item_name
        then
            if courier:DistanceFromFountain() <= 600 or courier:DistanceFromSecretShop() <= 200
            then
                npcBot:ActionImmediate_Chat("Продаю лишний предмет из курьера!", true);
                courier:ActionImmediate_SellItem(slotItem);
                break;
            end
        end
    end ]]
end

function SellExtraItem()
    local npcBot = GetBot();
    if utility.IsItemSlotsFull()
    then
        if (DotaTime() > 5 * 60)
        then
            SellSpecifiedItem("item_tango")
            SellSpecifiedItem("item_clarity")
            SellSpecifiedItem("item_flask")
            SellSpecifiedItem("item_faerie_fire")
            SellSpecifiedItem("item_enchanted_mango")
            SellSpecifiedItem("item_blood_grenade")
        end
        if (DotaTime() > 10 * 60)
        then
            if not hero_role_generic.IsHeroBuyHolyLocket(npcBot)
            then
                SellSpecifiedItem("item_magic_wand")
            end
            if npcBot:GetLevel() > 10
            then
                SellSpecifiedItem("item_infused_raindrop")
            end
        end
        if (DotaTime() > 20 * 60)
        then
            SellSpecifiedItem("item_wraith_band")
            SellSpecifiedItem("item_bracer")
            SellSpecifiedItem("item_null_talisman")
            SellSpecifiedItem("item_bottle")
            SellSpecifiedItem("item_orb_of_corrosion")
            SellSpecifiedItem("item_falcon_blade")
            SellSpecifiedItem("item_soul_ring")
        end
        if (DotaTime() > 30 * 60)
        then
            SellSpecifiedItem("item_hand_of_midas")
            SellSpecifiedItem("item_mask_of_madness")
            SellSpecifiedItem("item_armlet")
            --SellSpecifiedItem("item_pavise")
            --SellSpecifiedItem("item_veil_of_discord")
        end
    end
    if utility.HaveTravelBoots(npcBot)
    then
        --SellSpecifiedItem("item_boots")
        SellSpecifiedItem("item_arcane_boots")
        SellSpecifiedItem("item_power_treads")
        SellSpecifiedItem("item_phase_boots")
        SellSpecifiedItem("item_tranquil_boots")
        SellSpecifiedItem("item_boots_of_bearing")
        SellSpecifiedItem("item_guardian_greaves")
    end
end

local function BuyCourier()
    local npcBot = GetBot();
    local courier = utility.GetBotCourier(npcBot);
    --local playerID = npcBot:GetPlayerID();
    --local courier = GetCourier(playerID);
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
