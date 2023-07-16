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
    Abilities[2],
    Abilities[4],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[4],
    Abilities[4],
    Talents[3],
    Abilities[4],
    Abilities[6],
    Talents[6],
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

    WildAxes = AbilitiesReal[1]
    SummonBoar = AbilitiesReal[2]
    SummonHawk = AbilitiesReal[3]
    DrumsOfSlom = AbilitiesReal[5]
    PrimalRoar = AbilitiesReal[6]

    --SummonBoar = npcBot:GetAbilityByName("beastmaster_call_of_the_wild_boar");
    --SummonHawk = npcBot:GetAbilityByName("beastmaster_call_of_the_wild_hawk");

    castWildAxesDesire, castWildAxesLocation = ConsiderWildAxes();
    castSummonBoarDesire = ConsiderSummonBoar();
    castSummonHawkDesire, castSummonHawkLocation = ConsiderSummonHawk();
    castDrumsOfSlomDesire = ConsiderDrumsOfSlom();
    castPrimalRoarDesire, castPrimalRoarTarget = ConsiderPrimalRoar();

    if (castWildAxesDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WildAxes, castWildAxesLocation);
        return;
    end

    if (castSummonBoarDesire ~= nil)
    then
        npcBot:Action_UseAbility(SummonBoar);
        return;
    end

    if (castSummonHawkDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SummonHawk, castSummonHawkLocation + RandomVector(100));
        return;
    end

    if (castDrumsOfSlomDesire ~= nil)
    then
        npcBot:Action_UseAbility(DrumsOfSlom);
        return;
    end

    if (castPrimalRoarDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(PrimalRoar, castPrimalRoarTarget);
        return;
    end
end

function ConsiderWildAxes()
    local ability = WildAxes;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("axe_damage") * 2;
    local delayAbility = ability:GetSpecialValueInt("min_throw_duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) and not utility.TargetCantDie(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую WildAxes что бы убить бегущую цель!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую WildAxes что бы убить бегущую цель!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if utility.IsMoving(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Использую WildAxes по бегущей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
                else
                    --npcBot:ActionImmediate_Chat("Использую WildAxes по стоящей цели!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую WildAxes по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую WildAxes по бегущей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую WildAxes по стоящей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end

function ConsiderSummonBoar()
    local ability = SummonBoar;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnInvulnerableTarget(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Summon Boar для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Summon Boar для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if npcBot:DistanceFromFountain() > 1000
        then
            --npcBot:ActionImmediate_Chat("Использую Summon Boar против вражеских сил!", true);
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderSummonHawk()
    local ability = SummonHawk;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Use for exploration
    if not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT
    then
        local neutralCreeps = npcBot:GetNearbyNeutralCreeps(castRangeAbility);
        if (#neutralCreeps > 0) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(neutralCreeps) do
                if enemy:CanBeSeen()
                then
                    --npcBot:ActionImmediate_Chat("Использую Summon Hawk для разведки!", true);
                    return BOT_ACTION_DESIRE_VERYLOW, enemy:GetLocation();
                end
            end
        end
    end

    if ability:GetBehavior() == ABILITY_BEHAVIOR_AUTOCAST
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast();
        end
    end

    if ability:GetAutoCastState()
    then
        if utility.PvPMode(npcBot)
        then
            if botTarget ~= nil and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget))
            then
                npcBot:ActionImmediate_Chat("Использую Summon Hawk по врагу в радиусе действия!",
                    true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            end
            -- Use if need retreat
        elseif botMode == BOT_MODE_RETREAT
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy))
                    then
                        npcBot:ActionImmediate_Chat("Использую Summon Hawk что бы оторваться от врага!",
                            true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end

function ConsiderDrumsOfSlom()
    local ability = DrumsOfSlom;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack or retreat use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy))
                then
                    npcBot:ActionImmediate_Chat("Использую Drums Of Slom по врагу в радиусе действия!",
                        true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderPrimalRoar()
    local ability = PrimalRoar;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnInvulnerableTarget(enemy) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Primal Roar что бы сбить заклинание врага!", true);
                return BOT_MODE_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Primal Roar по врагу в радиусе действия!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Primal Roar что бы оторваться от врага!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end
