---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")

function CourierUsageThink()
    ability_item_usage_generic.CourierUsageThink()
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
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
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

    if (castSummonWolvesDesire ~= nil)
    then
        npcBot:Action_UseAbility(SummonWolves);
        return;
    end

    if (castHowlDesire ~= nil)
    then
        npcBot:Action_UseAbility(Howl);
        return;
    end

    if (castWolfBiteDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WolfBite, castWolfBiteTarget);
        return;
    end

    if (castShapeshiftDesire ~= nil)
    then
        npcBot:Action_UseAbility(Shapeshift);
        return;
    end
end

function ConsiderSummonWolves()
    local ability = SummonWolves;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Summon Wolves для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot) and (npcBot:DistanceFromFountain() > 1000)
    then
        --npcBot:ActionImmediate_Chat("Использую Summon Wolves против вражеских сил!", true);
        return BOT_ACTION_DESIRE_LOW;
    end
end

function ConsiderHowl()
    local ability = Howl;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
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
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRang
            then
                -- npcBot:ActionImmediate_Chat("Использую Howl против Рошана!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderWolfBite()
    local ability = WolfBite;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
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
end

function ConsiderShapeshift()
    local ability = Shapeshift;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not npcBot:HasModifier("modifier_lycan_shapeshift")
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and utility.IsHero(botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= 3000
            then
                --npcBot:ActionImmediate_Chat("Использую Shapeshift для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif botMode == BOT_MODE_RETREAT
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage < 0.5)
            then
                --npcBot:ActionImmediate_Chat("Использую Shapeshift для отступления!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end
