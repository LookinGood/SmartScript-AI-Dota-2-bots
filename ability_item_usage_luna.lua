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
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local LucentBeam = AbilitiesReal[1]
local MoonGlaives = AbilitiesReal[2]
local Eclipse = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castLucentBeamDesire, castLucentBeamTarget = ConsiderLucentBeam();
    local castMoonGlaivesDesire = ConsiderMoonGlaives();
    local castEclipseDesire, castEclipseLocation, castEclipseTargetType = ConsiderEclipse();

    if (castLucentBeamDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LucentBeam, castLucentBeamTarget);
        return;
    end

    if (castMoonGlaivesDesire ~= nil)
    then
        npcBot:Action_UseAbility(MoonGlaives);
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
            npcBot:Action_UseAbilityOnLocation(Eclipse, castEclipseLocation);
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
    local damageAbility = ability:GetSpecialValueInt("beam_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LucentBeam что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LucentBeam что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderMoonGlaives()
    local ability = MoonGlaives;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("rotating_glaives_movement_radius");

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую MoonGlaives против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую MoonGlaives для отступления!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderEclipse()
    local ability = Eclipse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if not npcBot:HasScepter() and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Eclipse для нападения без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH, nil, nil;
            elseif npcBot:HasScepter() and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Eclipse для нападения с аганимом!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility), "location";
            end
        end
    end
end
