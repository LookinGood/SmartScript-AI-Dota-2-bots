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
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
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

    LucentBeam = AbilitiesReal[1]
    Eclipse = AbilitiesReal[6]

    castLucentBeamDesire, castLucentBeamTarget = ConsiderLucentBeam();
    castEclipseDesire, castEclipseTarget, castEclipseTargetType = ConsiderEclipse();

    if (castLucentBeamDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LucentBeam, castLucentBeamTarget);
        return;
    end

    if (castEclipseDesire ~= nil)
    then
        if (castEclipseTargetType == nil)
        then
            npcBot:Action_UseAbility(Eclipse);
            return;
        elseif (castEclipseTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Eclipse, castEclipseTarget);
            return;
        end
    end
end

function ConsiderLucentBeam()
    local ability = LucentBeam;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("beam_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую LucentBeam что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
        then
            --npcBot:ActionImmediate_Chat("Использую LucentBeam по врагу в радиусе действия!",true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую LucentBeam что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Roshan
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую LucentBeam на Рошана!", true);
                return BOT_MODE_DESIRE_MODERATE, botTarget;
            end
        end
    end
end

function ConsiderEclipse()
    local ability = Eclipse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
        then
            if not npcBot:HasScepter() and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Eclipse для нападения без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget, nil;
            elseif npcBot:HasScepter() and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Eclipse для нападения с аганимом!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
            end
        end
    end
end
