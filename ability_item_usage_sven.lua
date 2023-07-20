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
    Abilities[2],
    Abilities[1],
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

    StormHammer = AbilitiesReal[1]
    Warcry = AbilitiesReal[3]
    GodsStrength = AbilitiesReal[6]

    castStormHammerDesire, castStormHammerTarget = ConsiderStormHammer();
    castWarcryDesire = ConsiderWarcry();
    castGodsStrengthDesire = ConsiderGodsStrength();

    if (castStormHammerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(StormHammer, castStormHammerTarget);
        return;
    end

    if (castWarcryDesire ~= nil)
    then
        npcBot:Action_UseAbility(Warcry);
        return;
    end

    if (castGodsStrengthDesire ~= nil)
    then
        npcBot:Action_UseAbility(GodsStrength);
        return;
    end
end

function ConsiderStormHammer()
    local ability = StormHammer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую StormHammer что бы сбить заклинание или убить цель!",true);
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
                and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую StormHammer что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:HasScepter()
    then
        if utility.PvPMode(npcBot)
        then
            if tility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                if ability:GetAutoCastState()
                then
                    ability:ToggleAutoCast()
                end
            else
                if not ability:GetAutoCastState()
                then
                    ability:ToggleAutoCast()
                end
            end
        else
            if not ability:GetAutoCastState()
            then
                ability:ToggleAutoCast()
            end
        end
    end
end

function ConsiderWarcry()
    local ability = Warcry;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);

    -- Use to buff damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.9)
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Warcry для бафа!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 4
        then
            --npcBot:ActionImmediate_Chat("Использую Warcry для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderGodsStrength()
    local ability = GodsStrength;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) and not npcBot:IsDisarmed()
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 4
        then
            --npcBot:ActionImmediate_Chat("Использую GodsStrength для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
