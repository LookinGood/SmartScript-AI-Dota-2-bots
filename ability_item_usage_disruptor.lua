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
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Ability Use
function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    ThunderStrike = AbilitiesReal[1]
    Glimpse = AbilitiesReal[2]
    KineticField = AbilitiesReal[3]
    StaticStorm = AbilitiesReal[6]

    castThunderStrikeDesire, castThunderStrikeTarget = ConsiderThunderStrike();
    castGlimpseDesire, castGlimpseTarget = ConsiderGlimpse();
    castKineticFieldDesire, castKineticFieldLocation = ConsiderKineticField();
    castStaticStormDesire, castStaticStormLocation = ConsiderStaticStorm();

    if (castThunderStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ThunderStrike, castThunderStrikeTarget);
        return;
    end

    if (castGlimpseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Glimpse, castGlimpseTarget);
        return;
    end

    if (castKineticFieldDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(KineticField, castKineticFieldLocation);
        return;
    end

    if (castStaticStormDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(StaticStorm, castStaticStormLocation);
        return;
    end
end

function ConsiderThunderStrike()
    local ability = ThunderStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local strikesAbility = ability:GetSpecialValueInt("strikes");
    local damageAbility = (ability:GetAbilityDamage() * strikesAbility);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                and utility.SafeCast(enemy, true)
            then
                --npcBot:ActionImmediate_Chat("Использую Thunder Strike против врага который может умереть от него!", true);
                return BOT_MODE_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Cast if attack
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.IsHero(botTarget)
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
                if (utility.CanCastOnMagicImmuneTarget(enemy)) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreepsLane = npcBot:GetNearbyLaneCreeps(castRangeAbility, true);
        if (#enemyCreepsLane > 2) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreepsLane) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and utility.SafeCast(enemy, true)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy;
                end
            end
        end
        -- Cast when laning
    elseif npcBot:GetActiveMode() == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Roshan
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and (ManaPercentage >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую Thunder Strike на Рошана!", true);
            return BOT_MODE_DESIRE_MODERATE, botTarget;
        end
    end
end

function ConsiderGlimpse()
    local ability = Glimpse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local AttackRange = npcBot:GetAttackRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanCastOnMagicImmuneTarget(enemy)) and enemy:IsChanneling()
            then
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end

    -- Stalking enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and (utility.CanCastOnMagicImmuneTarget(botTarget)) and
            GetUnitToUnitDistance(npcBot, botTarget) > (AttackRange * 2) and utility.SafeCast(botTarget, false)
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderKineticField()
    local ability = KineticField;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("formation_time");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Use when attack
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen() and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if utility.IsMoving(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую KineticField по бегущей цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
            else
                --npcBot:ActionImmediate_Chat("Использую KineticField по стоящей цели!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
            end
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen()
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую KineticField по бегущей цели отступая!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую KineticField по стоящей цели отступая!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end

function ConsiderStaticStorm()
    local ability = StaticStorm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if enemy hero immobilized
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsDisabled(enemy) and utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3)
            then
                -- npcBot:ActionImmediate_Chat("Использую Call Down против обездвиженного врага!",true);
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
            --npcBot:ActionImmediate_Chat("Использую StaticStorm по врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end