---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")

function CourierUsageThink()
    ability_item_usage_generic.CourierUsageThink();
end

function BuybackUsageThink()
    ability_item_usage_generic.BuybackUsageThink();
end

-- Ability learn
local npcBot = GetBot();
local Abilities, Talents, AbilitiesReal = ability_levelup_generic.GetHeroAbilities(npcBot)

local AbilityToLevelUp =
{
    Abilities[1],
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SummonWolves = AbilitiesReal[1]
local Howl = AbilitiesReal[2]
local WolfBite = AbilitiesReal[4]
local Shapeshift = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSummonWolvesDesire = ConsiderSummonWolves();
    local castHowlDesire = ConsiderHowl();
    local castWolfBiteDesire, castWolfBiteTarget = ConsiderWolfBite();
    local castShapeshiftDesire = ConsiderShapeshift();

    if (castSummonWolvesDesire > 0)
    then
        npcBot:Action_UseAbility(SummonWolves);
        return;
    end

    if (castHowlDesire > 0)
    then
        npcBot:Action_UseAbility(Howl);
        return;
    end

    if (castWolfBiteDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(WolfBite, castWolfBiteTarget);
        return;
    end

    if (castShapeshiftDesire > 0)
    then
        npcBot:Action_UseAbility(Shapeshift);
        return;
    end
end

local function IsWolf(npcTarget)
    return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "npc_dota_lycan_wolf") and
        not string.find(npcTarget:GetUnitName(), "lane");
end

local function CountWolfs()
    local count = 0;
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if IsWolf(ally) and ally:GetPlayerID() == npcBot:GetPlayerID()
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function ConsiderSummonWolves()
    local ability = SummonWolves;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local maxUnits = ability:GetSpecialValueInt("wolf_count");

    if CountWolfs() >= maxUnits
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Cast if push/defend/farm/roshan
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTowers = npcBot:GetNearbyTowers(1600, true);
        local enemyBarracks = npcBot:GetNearbyBarracks(1600, true);
        local enemyAncient = GetAncient(GetOpposingTeam());
        if (ManaPercentage >= 0.4) and
            ((#enemyCreeps > 0) or
                (#enemyTowers > 0) or
                (#enemyBarracks > 0) or
                npcBot:GetAttackTarget() == enemyAncient)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderHowl()
    local ability = Howl;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetAOERadius();

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(radiusAbility), true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Howl против врага в радиусе действия!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    if utility.BossMode(npcBot)
    then
        if utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                -- npcBot:ActionImmediate_Chat("Использую Howl против Босса!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderWolfBite()
    local ability = WolfBite;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility)
            do
                if ally ~= npcBot and utility.IsHero(ally) and not ally:HasModifier("modifier_lycan_shapeshift")
                then
                    --npcBot:ActionImmediate_Chat("Использую Wolf Bite на союзного героя!", true);
                    return BOT_ACTION_DESIRE_VERYLOW, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShapeshift()
    local ability = Shapeshift;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_lycan_shapeshift")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 3000
            then
                --npcBot:ActionImmediate_Chat("Использую Shapeshift для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage < 0.5)
        then
            --npcBot:ActionImmediate_Chat("Использую Shapeshift для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
