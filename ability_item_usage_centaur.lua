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
    Abilities[2],
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[2],
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
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

    HoofStomp = AbilitiesReal[1]
    DoubleEdge = AbilitiesReal[2]
    HitchARide = AbilitiesReal[4]
    Stampede = AbilitiesReal[6]

    castHoofStompDesire = ConsiderHoofStomp();
    castDoubleEdgeDesire, castDoubleEdgeTarget = ConsiderDoubleEdge();
    castHitchARideDesire, castHitchARideTarget = ConsiderHitchARide();
    castStampedeDesire = ConsiderStampede();

    if (castHoofStompDesire ~= nil)
    then
        npcBot:Action_UseAbility(HoofStomp);
        return
    end

    if (castDoubleEdgeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DoubleEdge, castDoubleEdgeTarget);
        return;
    end

    if (castHitchARideDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(HitchARide, castHitchARideTarget);
        return;
    end

    if (castStampedeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Stampede);
        return
    end
end

function ConsiderHoofStomp()
    local ability = HoofStomp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRadiusAbility = (ability:GetSpecialValueInt("radius"));
    local damageAbility = (ability:GetSpecialValueInt("stomp_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility - 100, true, BOT_MODE_NONE);


    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                then
                    --npcBot:ActionImmediate_Chat("Использую HoofStomp что бы убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Hoof Stomp против врага в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.IsHero(enemy) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Hoof Stomp что бы сбить заклинание врага!", true);
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
    end
end

function ConsiderDoubleEdge()
    local ability = DoubleEdge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() * 2;
    local strengthDamage =  npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH) / 100 * ability:GetSpecialValueInt("strength_damage");
    local damageAbility = ability:GetSpecialValueInt("edge_damage") + strengthDamage;
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                then
                    --npcBot:ActionImmediate_Chat("Использую DoubleEdge что бы убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and (HealthPercentage > 0.1)
        then
            --npcBot:ActionImmediate_Chat("Использую Double Edge против врага в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and (HealthPercentage > 0.4) then
            --npcBot:ActionImmediate_Chat("Использую Double Edge на Рошана!", true);
            return BOT_MODE_DESIRE_MODERATE, botTarget;
        end
    end
end

function ConsiderHitchARide()
    local ability = HitchARide;
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
                if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and utility.IsHero(ally) and ally ~= npcBot
                then
                    --npcBot:ActionImmediate_Chat("Использую Hitch a Ride на союзного героя со здоровьем ниже 80%!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderStampede()
    local ability = Stampede;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and botTarget:CanBeSeen() and utility.IsHero(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Stampede для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage < 0.5)
        then
            --npcBot:ActionImmediate_Chat("Использую Stampede для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
