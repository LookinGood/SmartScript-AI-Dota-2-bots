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
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ChargeOfDarkness = npcBot:GetAbilityByName("spirit_breaker_charge_of_darkness");
local Bulldoze = npcBot:GetAbilityByName("spirit_breaker_bulldoze");
local GreaterBash = npcBot:GetAbilityByName("spirit_breaker_greater_bash");
local PlanarPocket = npcBot:GetAbilityByName("spirit_breaker_planar_pocket");
local NetherStrike = npcBot:GetAbilityByName("spirit_breaker_nether_strike");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") and (botTarget:HasModifier('modifier_fountain_aura_buff'))
    then
        npcBot:Action_ClearActions(true);
        --npcBot:ActionImmediate_Chat("Отменяю ChargeOfDarkness.", true);
        return;
    end

    if GreaterBash:IsTrained()
    then
        GreaterBashDamage = math.floor(npcBot:GetCurrentMovementSpeed() / 100 * GreaterBash:GetSpecialValueInt("damage"));
    end

    local castChargeOfDarknessDesire, castChargeOfDarknessTarget, castChargeOfDarknessTargetType =
        ConsiderChargeOfDarkness();
    local castBulldozeDesire = ConsiderBulldoze();
    local castPlanarPocketDesire, castPlanarPocketTarget = ConsiderPlanarPocket();
    local castNetherStrikeDesire, castNetherStrikeTarget = ConsiderNetherStrike();

    if (castChargeOfDarknessDesire > 0)
    then
        if (castChargeOfDarknessTargetType == "combo")
        then
            npcBot:Action_ClearActions(true);
            npcBot:ActionQueue_UseAbilityOnEntity(ChargeOfDarkness, castChargeOfDarknessTarget);
            npcBot:ActionQueue_UseAbility(Bulldoze);
            npcBot:ActionQueue_Delay(5.0);
            return;
        else
            npcBot:Action_ClearActions(true);
            npcBot:ActionQueue_UseAbilityOnEntity(ChargeOfDarkness, castChargeOfDarknessTarget);
            npcBot:ActionQueue_Delay(5.0);
            return;
        end
    end

    if (castBulldozeDesire > 0)
    then
        npcBot:Action_UseAbility(Bulldoze);
        return;
    end

    if (castPlanarPocketDesire > 0)
    then
        npcBot:ActionQueue_UseAbilityOnEntity(PlanarPocket, castPlanarPocketTarget);
        return;
    end

    if (castNetherStrikeDesire > 0)
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

local function IsBulldozeComboReady()
    return utility.IsAbilityAvailable(ChargeOfDarkness) and utility.IsAbilityAvailable(Bulldoze)
        and npcBot:GetMana() > (ChargeOfDarkness:GetManaCost() + Bulldoze:GetManaCost())
end

--npcBot:ActionImmediate_Ping(botTarget.x, botTarget.y, false);

function ConsiderChargeOfDarkness()
    local ability = ChargeOfDarkness;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness") or npcBot:IsRooted()
    then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local castRangeAbility = 800;
    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and GreaterBash:IsTrained()
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanAbilityKillTarget(enemy, GreaterBashDamage, GreaterBash:GetDamageType()) or enemy:IsChanneling())
                and not enemy:HasModifier('modifier_fountain_aura_buff')
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if IsBulldozeComboReady()
                    then
                        --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness сбивая/убивая с комбо " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "combo";
                    else
                        --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness сбивая/убивая без комбо " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, 0;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and not utility.IsDisabled(botTarget)
                and not botTarget:HasModifier('modifier_fountain_aura_buff')
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= 3000
                then
                    if IsBulldozeComboReady()
                    then
                        --npcBot:ActionImmediate_Chat("Бегу вблизи с комбо на " .. botTarget:GetUnitName(), false);
                        return BOT_ACTION_DESIRE_HIGH, botTarget, "combo";
                    else
                        --npcBot:ActionImmediate_Chat("Бегу вблизи без комбо на " .. botTarget:GetUnitName(), false);
                        return BOT_ACTION_DESIRE_HIGH, botTarget, 0;
                    end
                else
                    local allyHeroes = botTarget:GetNearbyHeroes(700, true, BOT_MODE_NONE);
                    local enemyHeroes = botTarget:GetNearbyHeroes(700, false, BOT_MODE_NONE);
                    if (#allyHeroes >= #enemyHeroes)
                    then
                        if IsBulldozeComboReady()
                        then
                            --npcBot:ActionImmediate_Chat("Бегу с комбо на " .. botTarget:GetUnitName(), false);
                            return BOT_ACTION_DESIRE_HIGH, botTarget, "combo";
                        else
                            --npcBot:ActionImmediate_Chat("Бегу без комбо на " .. botTarget:GetUnitName(), false);
                            return BOT_ACTION_DESIRE_HIGH, botTarget, 0;
                        end
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7)
        then
            local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
            local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
            local fountainLocation = utility.GetFountainLocation();
            if (#enemyHeroes > 0)
            then
                for _, enemy in pairs(enemyHeroes) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        if IsBulldozeComboReady()
                        then
                            --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness убегая на героя с комбо " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy, "combo";
                        else
                            --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness убегая на героя без комбо " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy, 0;
                        end
                    end
                end
            end
            if (#enemyCreeps > 0)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        if IsBulldozeComboReady()
                        then
                            --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness убегая на крипа с комбо " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy, "combo";
                        else
                            --npcBot:ActionImmediate_Chat("Использую ChargeOfDarkness убегая на крипа без комбо " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy, 0;
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end

function ConsiderBulldoze()
    local ability = Bulldoze;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_bulldoze")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 4)
            then
                --npcBot:ActionImmediate_Chat("Использую Bulldoze против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую Bulldoze для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPlanarPocket()
    local ability = PlanarPocket;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_spirit_breaker_planar_pocket_aura")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Ally use
    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and not utility.HaveReflectSpell(ally)
                and not ally:HasModifier("modifier_spirit_breaker_planar_pocket")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.9 and ally:WasRecentlyDamagedByAnyHero(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую PlanarPocket на союзника " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Retreat use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_spirit_breaker_planar_pocket")
                then
                    --npcBot:ActionImmediate_Chat("Использую PlanarPocket отступая!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNetherStrike()
    local ability = NetherStrike;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
