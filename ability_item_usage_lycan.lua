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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

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

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    SummonWolves = AbilitiesReal[1]
    Howl = AbilitiesReal[2]
    WolfBite = AbilitiesReal[4]
    Shapeshift = AbilitiesReal[6]

    castSummonWolvesDesire = ConsiderSummonWolves();
    castHowlDesire = ConsiderHowl();
    castWolfBiteDesire, castWolfBiteTarget = ConsiderWolfBite();
    castShapeshiftDesire = ConsiderShapeshift();

    if (castShapeshiftDesire ~= nil)
    then
        npcBot:Action_UseAbility(Shapeshift);
        return;
    end

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
end

function ConsiderSummonWolves()
    local ability = SummonWolves;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnInvulnerableTarget(botTarget))
        then
            --npcBot:ActionImmediate_Chat("Использую Summon Wolves для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT and (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
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
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if (utility.CanCastOnMagicImmuneTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую Howl против врага в радиусе действия!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
        then
            -- npcBot:ActionImmediate_Chat("Использую Howl против Рошана!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderWolfBite()
    local ability = WolfBite;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or (botMode == BOT_MODE_RETREAT)
    then
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and (ally ~= npcBot) and not ally:HasModifier("modifier_lycan_shapeshift_aura")
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

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnInvulnerableTarget(botTarget) and utility.IsHero(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= 3000
        then
            --npcBot:ActionImmediate_Chat("Использую Shapeshift для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT and (HealthPercentage < 0.5)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую Shapeshift для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
