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
local npcBot = GetBot();

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
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    Malefice = AbilitiesReal[1]
    DemonicConversion = AbilitiesReal[2]
    MidnightPulse = AbilitiesReal[3]
    BlackHole = AbilitiesReal[6]

    castMaleficeDesire, castMaleficeTarget = ConsiderMalefice();
    castDemonicConversionDesire, castDemonicConversionTarget = ConsiderDemonicConversion();
    castMidnightPulseDesire, castMidnightPulseLocation = ConsiderMidnightPulse();
    castBlackHoleDesire, castBlackHoleLocation = ConsiderBlackHole();

    if (castMaleficeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Malefice, castMaleficeTarget);
        return;
    end

    if (castDemonicConversionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DemonicConversion, castDemonicConversionTarget);
        return;
    end

    if (castMidnightPulseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MidnightPulse, castMidnightPulseLocation);
        return;
    end

    if (castBlackHoleDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BlackHole, castBlackHoleLocation);
        --return;
    end

    --[[     if npcBot:GetCurrentActiveAbility() == BlackHole
    then
        npcBot:ActionImmediate_Chat("Стою кастую блек хол!", true);
        npcBot:Action_Delay(1.0)
        --npcBot:Action_ClearActions(true);
        --npcBot:Action_ClearActions(true);
        --npcBot:ActionQueue_UseAbilityOnLocation(BlackHole, castBlackHoleLocation);
        --npcBot:ActionQueue_Delay(0.5);
        --npcBot:ActionPush_UseAbilityOnLocation(BlackHole, castBlackHoleLocation);
        
    end ]]
end

function ConsiderMalefice()
    local ability = Malefice;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local strikesAbility = ability:GetSpecialValueInt("stun_instances");
    local damageAbility = (ability:GetSpecialValueInt("damage") * strikesAbility);
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую Malefice что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)) and not utility.IsDisabled(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.IsHero(botTarget)
            and utility.SafeCast(botTarget, true)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif (botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy)) and utility.SafeCast(enemy, true) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif npcBot:GetActiveMode() == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy)) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Roshan
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and (ManaPercentage >= 0.5)
        then
            --npcBot:ActionImmediate_Chat("Использую Malefice на Рошана!", true);
            return BOT_MODE_DESIRE_MODERATE, botTarget;
        end
    end
end

function ConsiderDemonicConversion()
    local ability = DemonicConversion;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
    local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
    local creepMaxLevel = ability:GetSpecialValueInt("creep_max_level");

    -- General use
    if botMode ~= BOT_MODE_LANING and (ManaPercentage > 0.5)
    then
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and not enemy:IsAncientCreep() and not enemy:HasModifier("modifier_creep_bonus_xp")
                        and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.8)) and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        if (#allyCreeps > 0)
        then
            for _, ally in pairs(allyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(ally) and not ally:IsAncientCreep() and not ally:HasModifier("modifier_creep_bonus_xp")
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.2)) and ally:GetLevel() <= creepMaxLevel
                then
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderMidnightPulse()
    local ability = MidnightPulse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnInvulnerableTarget(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if (ManaPercentage >= 0.8) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую MidnightPulse по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if (ManaPercentage >= 0.8) and (locationAoE.count > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую MidnightPulse по героям врага на линии!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderBlackHole()
    local ability = BlackHole;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("duration");
    local radiusAbility = (ability:GetSpecialValueInt("radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE)

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_PURE) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.1)
            then
                --npcBot:ActionImmediate_Chat("Использую BlackHole что бы добить врага!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
            end
        end
    end

    -- Cast if enemy >=2
    if utility.PvPMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую BlackHole по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
