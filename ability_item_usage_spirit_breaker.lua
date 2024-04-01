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
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ChargeOfDarkness = AbilitiesReal[1]
local Bulldoze = AbilitiesReal[2]
local GreaterBash = AbilitiesReal[3]
local PlanarPocket = AbilitiesReal[4]
local NetherStrike = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();
    GreaterBashDamage = npcBot:GetCurrentMovementSpeed() / 100 * GreaterBash:GetSpecialValueInt("damage");

    local castChargeOfDarknessDesire, castChargeOfDarknessTarget = ConsiderChargeOfDarkness();
    local castBulldozeDesire = ConsiderBulldoze();
    local castPlanarPocketDesire = ConsiderPlanarPocket();
    local castNetherStrikeDesire, castNetherStrikeTarget = ConsiderNetherStrike();

    if (castChargeOfDarknessDesire ~= nil)
    then
        if castChargeOfDarknessTarget ~= nil
        then
            npcBot:ActionImmediate_Ping(castChargeOfDarknessTarget.x, castChargeOfDarknessTarget.y, false);
            npcBot:ActionImmediate_Chat("Бегу на " .. castChargeOfDarknessTarget:GetUnitName(), false);
        end
        npcBot:Action_ClearActions(true);
        npcBot:Action_UseAbilityOnEntity(ChargeOfDarkness, castChargeOfDarknessTarget);
        return;
    end

    if (castBulldozeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Bulldoze);
        return;
    end

    if (castPlanarPocketDesire ~= nil)
    then
        npcBot:Action_UseAbility(PlanarPocket);
        return;
    end

    if (castNetherStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(NetherStrike, castNetherStrikeTarget);
        return;
    end

    --npcBot:Action_ClearActions(false);
    --npcBot:ActionQueue_Delay(1.0);
    --npcBot:ActionQueue_UseAbilityOnEntity(ChargeOfDarkness, castChargeOfDarknessTarget);
    --npcBot:Action_UseAbilityOnEntity(ChargeOfDarkness, castChargeOfDarknessTarget);
    --return;

    --[[     if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or
        npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness_target") or
        npcBot:NumQueuedActions() > 0 or
        ChargeOfDarkness:IsInAbilityPhase()
    then
        npcBot:Action_ClearActions(true);
        --npcBot:Action_AttackMove(npcBot:GetLocation())
        --npcBot:ActionQueue_Delay(1.0);
        return;
    end ]]
end

function ConsiderChargeOfDarkness()
    local ability = ChargeOfDarkness;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or npcBot:IsRooted()
    then
        return;
    end

    local castRangeAbility = 600;
    local damageAbility = GreaterBashDamage;
    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, GreaterBash:GetDamageType()) or enemy:IsChanneling()
                and not botTarget:HasModifier('modifier_fountain_aura_buff')
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness что бы сбить заклинание или убить цель!", true);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and not utility.IsDisabled(botTarget)
                and not botTarget:HasModifier('modifier_fountain_aura_buff')
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= 3000
                then
                    return BOT_MODE_DESIRE_HIGH, botTarget;
                else
                    local allyHeroes = botTarget:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                    if (#allyHeroes > 1)
                    then
                        return BOT_MODE_DESIRE_HIGH, botTarget;
                    end
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
        local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
        local fountainLocation = utility.SafeLocation(npcBot);
        if (#enemyHeroes > 0)
        then
            for _, enemy in pairs(enemyHeroes) do
                if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness для побега на врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness для побега на крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderBulldoze()
    local ability = Bulldoze;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_bulldoze")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 4)
            then
                --npcBot:ActionImmediate_Chat("Использую Bulldoze против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:DistanceFromFountain() >= 1000
        then
            --npcBot:ActionImmediate_Chat("Использую Bulldoze для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderPlanarPocket()
    local ability = PlanarPocket;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_planar_pocket")
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and
                not ally:HasModifier("modifier_antimage_counterspell") and
                not ally:HasModifier("modifier_item_sphere_target") and
                not ally:HasModifier("modifier_item_lotus_orb_active") and
                not ally:HasModifier("modifier_spirit_breaker_planar_pocket")
            then
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    for _, spell in pairs(incomingSpells)
                    do
                        if not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false
                        then
                            return BOT_ACTION_DESIRE_VERYHIGH;
                        end
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderNetherStrike()
    local ability = NetherStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = GreaterBashDamage + ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую NetherStrike что бы сбить заклинание или убить цель!",true);
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
    end
end
