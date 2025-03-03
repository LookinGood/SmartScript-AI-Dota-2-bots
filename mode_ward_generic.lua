---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_retreat_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

---RADIANT WARDING SPOT
local RADIANT_TOPSPOT1 = Vector(-4362.3, -1027.3, 229.5); -- Late game
local RADIANT_TOPSPOT2 = Vector(-4442.6, 2027.7, 86.1);
local RADIANT_TOPSPOT3 = Vector(-7938.8, 1834.6, 215.4);
local RADIANT_TOPSPOTNOTOWER = Vector(-6610.1, -3063.9, 209.1);

local RADIANT_TOPTORMENTOR = Vector(7254.8, -7080.2, 264.4); -- Late game

local RADIANT_MIDSPOT1 = Vector(499.2, -1761.3, 102.5);
local RADIANT_MIDSPOTNOTOWER = Vector(-4343.4, -3883.9, 175.1);

local RADIANT_BOTSPOT1 = Vector(-1305.4, -4340.0, 133.1);  -- Pillar in the forest
local RADIANT_BOTSPOT2 = Vector(-1293.7, -4948.0, 1174.7); -- Late game
local RADIANT_BOTSPOT3 = Vector(5079.9, -4689.8, 127.6);   -- Near T1
local RADIANT_BOTSPOT4 = Vector(963.1, -8698.7, 1211.5);   -- Near waterfall

local RADIANT_BOTSPOTPOND = Vector(8269.3, -5017.6, 178.8);
local RADIANT_BOTSPOTNOTOWER = Vector(-3603.6, -6108.9, 208.0);


---DIRE WARDING SPOT
local DIRE_TOPSPOT1 = Vector(-1914.8, 3854.4, 1229.0);
local DIRE_TOPSPOT2 = Vector(-884.8, 7634.8, 113.6); -- Late game
local DIRE_TOPSPOT3 = Vector(1023.3, 3573.9, 135.6); -- Forest on the pillar
local DIRE_TOPSPOT4 = Vector(-4211.4, 4805.2, 119.6);

local DIRE_TOPSPOTPOND = Vector(-7713.2, 4267.1, 119.0);
local DIRE_TOPSPOTNOTOWER = Vector(3098.2, 5769.3, 219.4);

local DIRE_TOPTORMENTOR = Vector(-7266.9, 7349.9, 239.6); -- Late game

local DIRE_MIDSPOT1 = Vector(-935.3, 1265.0, 100.4);
local DIRE_MIDSPOTNOTOWER = Vector(4012.5, 3470.9, 203.9);

local DIRE_BOTSPOT1 = Vector(4605.3, 776.1, 195.1); -- Late game
local DIRE_BOTSPOT2 = Vector(2660.3, -1363.4, 91.1);
local DIRE_BOTSPOT3 = Vector(7681.0, -1523.6, 240.7);
local DIRE_BOTSPOTNOTOWER = Vector(6321.9, 2595.6, 201.8);

function GetWardSpot()
    local npcBot = GetBot();
    local RadiantWardSpotEarlyGame = {
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOT4,
        RADIANT_BOTSPOTPOND,

        DIRE_TOPSPOT3,
        DIRE_TOPSPOT4,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
    }

    local DireWardSpotEarlyGame = {
        DIRE_TOPSPOT3,
        DIRE_TOPSPOT4,
        DIRE_TOPSPOTPOND,
        DIRE_MIDSPOT1,
        DIRE_BOTSPOT2,
        DIRE_BOTSPOT3,

        RADIANT_TOPSPOT2,
        RADIANT_MIDSPOT1,
        RADIANT_BOTSPOT3,
        RADIANT_BOTSPOT4,
        RADIANT_BOTSPOTPOND,
    }

    local WardSpotLateGame = {
        RADIANT_TOPSPOT1,
        RADIANT_TOPSPOT2,
        RADIANT_TOPSPOT3,
        RADIANT_TOPSPOTNOTOWER,
        RADIANT_TOPTORMENTOR,
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
        DIRE_TOPTORMENTOR,
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

--[[ function IsObserverWardAvailable()
    local npcBot = GetBot();
    local slot = npcBot:FindItemSlot("item_ward_observer");
    if npcBot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
    then
        return npcBot:GetItemInSlot(slot);
    end
    return nil;
end ]]

function IsWardAvailable(sWardType)
    local npcBot = GetBot();
    local slot = npcBot:FindItemSlot(sWardType);
    if npcBot:GetItemSlotType(slot) == ITEM_SLOT_TYPE_MAIN
    then
        return npcBot:GetItemInSlot(slot);
    end
    return nil;
end

function CloseToAvailableWard(sWardType, wardLoc)
    local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
    local visionRad = 1600;

    for _, ward in pairs(WardList) do
        if ward:GetUnitName() == sWardType and GetUnitToLocationDistance(ward, wardLoc) <= visionRad
        then
            return true;
        end
    end
    return false;
end

--[[ function CloseToAvailableWard(wardLoc)
    local WardList = GetUnitList(UNIT_LIST_ALLIED_WARDS);
    local visionRad = 1600;

    for _, ward in pairs(WardList) do
        if ward:GetUnitName() == "npc_dota_observer_wards" and GetUnitToLocationDistance(ward, wardLoc) <= visionRad
        then
            return true;
        end
    end
    return false;
end ]]

function GetDesire()
    if GetGameState() == GAME_STATE_PRE_GAME or GetGameState() ~= GAME_STATE_GAME_IN_PROGRESS
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or utility.IsBaseUnderAttack() or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local enemyHeroes = npcBot:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
    local enemyTowers = npcBot:GetNearbyTowers(1000, true);

    if (#enemyHeroes > 0) or (#enemyTowers > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    wardObserver = IsWardAvailable("item_ward_observer");
    wardSentry = IsWardAvailable("item_ward_sentry");
    wardDispenser = IsWardAvailable("item_ward_dispenser");
    enemyWard = nil;
    enemyCourier = nil;

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
                    if not CloseToAvailableWard("npc_dota_observer_wards", s)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                elseif wardSentry ~= nil
                then
                    if not CloseToAvailableWard("npc_dota_sentry_wards", s)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                elseif wardDispenser ~= nil
                then
                    if not CloseToAvailableWard("npc_dota_observer_wards", s) and not CloseToAvailableWard("npc_dota_sentry_wards", s)
                    then
                        wardSpot = s;
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end

    local enemyWards = GetUnitList(UNIT_LIST_ENEMY_WARDS);
    if (#enemyWards > 0)
    then
        for _, ward in pairs(enemyWards) do
            if ward:CanBeSeen() and GetUnitToUnitDistance(npcBot, ward) <= (npcBot:GetAttackRange() + 150 * 2)
            then
                enemyWard = ward;
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    local enemyCouriers = npcBot:GetNearbyCreeps(npcBot:GetAttackRange() + 200, true);
    if (#enemyCouriers > 0)
    then
        for _, courier in pairs(enemyCouriers) do
            if courier:CanBeSeen() and courier:IsCourier() and not courier:IsInvulnerable()
                and IsLocationPassable(courier:GetLocation())
            then
                enemyCourier = courier;
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

--[[ function OnStart()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Иду ставить вард.", false);
    end
end
 ]]

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
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
    elseif enemyCourier ~= nil
    then
        npcBot:SetTarget(enemyCourier);
        npcBot:Action_AttackUnit(enemyCourier, false);
        return;

        --[[         if GetUnitToUnitDistance(npcBot, enemyCourier) > (npcBot:GetAttackRange() + 200)
        then
            npcBot:Action_MoveToLocation(enemyCourier:GetLocation());
            return;
        else
            npcBot:ActionImmediate_Chat("Атакую вражеского курьера!", true);
            npcBot:Action_AttackUnit(enemyCourier, false);
            return;
        end ]]
    elseif wardSpot ~= nil
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

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_retreat_generic) do _G._savedEnv[k] = v end
