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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
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

    SplitEarth = AbilitiesReal[1]
    DiabolicEdict = AbilitiesReal[2]
    LightningStorm = AbilitiesReal[3]
    Nihilism = AbilitiesReal[4]
    PulseNova = AbilitiesReal[6]

    castSplitEarthDesire, castSplitEarthLocation = ConsiderSplitEarth();
    castDiabolicEdictDesire = ConsiderDiabolicEdict();
    castLightningStormDesire, castLightningStormTarget = ConsiderLightningStorm();
    castNihilismDesire = ConsiderNihilism();
    castPulseNovaDesire = ConsiderPulseNova();

    if (castSplitEarthDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SplitEarth, castSplitEarthLocation);
        return;
    end

    if (castDiabolicEdictDesire ~= nil)
    then
        npcBot:Action_UseAbility(DiabolicEdict);
        return;
    end

    if (castLightningStormDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LightningStorm, castLightningStormTarget);
        return;
    end

    if (castNihilismDesire ~= nil)
    then
        npcBot:Action_UseAbility(Nihilism);
        return;
    end

    if (castPulseNovaDesire ~= nil)
    then
        npcBot:Action_UseAbility(PulseNova);
        return;
    end

    if npcBot:HasModifier("modifier_leshrac_diabolic_edict")
    then
        local attackTarget = npcBot:GetAttackTarget();
        if attackTarget ~= nil
        then
            if GetUnitToUnitDistance(npcBot, attackTarget) > (DiabolicEdict:GetSpecialValueInt("radius") - 100)
            then
                --npcBot:ActionImmediate_Chat("Сближаюсь с врагом что бы обжечь его!",true);
                npcBot:Action_MoveToLocation(attackTarget:GetLocation());
            end
        end
    end

    if npcBot:HasModifier("modifier_leshrac_pulse_nova")
    then
        local attackTarget = npcBot:GetAttackTarget();
        if attackTarget ~= nil and utility.IsHero(attackTarget)
        then
            if GetUnitToUnitDistance(npcBot, attackTarget) > (PulseNova:GetSpecialValueInt("radius") - 100)
            then
                --npcBot:ActionImmediate_Chat("Сближаюсь с врагом что бы обжечь его ультой!",true);
                npcBot:Action_MoveToLocation(attackTarget:GetLocation());
            end
        end
    end

end

function ConsiderSplitEarth()
    local ability = SplitEarth;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplitEarth по бегущей цели убивая", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую SplitEarth по стоящей цели убивая!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                if utility.IsMoving(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Использую SplitEarth по бегущей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
                else
                    --npcBot:ActionImmediate_Chat("Использую SplitEarth по стоящей цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplitEarth по бегущей цели ОТСТУПАЯ!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую SplitEarth по стоящей цели ОТСТУПАЯ!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end

function ConsiderDiabolicEdict()
    local ability = DiabolicEdict;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    --local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);

    if attackTarget ~= nil
    then
        if utility.IsHero(attackTarget)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen()
                then
                    --npcBot:ActionImmediate_Chat("Использую DiabolicEdict против врага в радиусе действия!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Use when attack building
    if attackTarget ~= nil
    then
        if attackTarget:IsTower() or attackTarget:IsFort() or attackTarget:IsBarracks()
        then
            if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.2) and ManaPercentage >= 0.4
            then
                --npcBot:ActionImmediate_Chat("Использую DiabolicEdict против зданий!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderLightningStorm()
    local ability = LightningStorm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                then
                    --npcBot:ActionImmediate_Chat("Использую LightningStorm что бы убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and utility.SafeCast(botTarget, true)
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
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую LightningStorm что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps >= 3) and (ManaPercentage >= 0.7)
        then
            local enemy = utility.GetWeakest(enemyCreeps);
            if enemy ~= nil and utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                --npcBot:ActionImmediate_Chat("Использую LightningStorm по крипам!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if enemy ~= nil and (ManaPercentage >= 0.7) and utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningStorm для лайнинга!", true);
            return BOT_ACTION_DESIRE_HIGH, enemy;
        end
    end
end

function ConsiderNihilism()
    local ability = Nihilism;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) < radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Nihilism против врага!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(5.0) or npcBot:WasRecentlyDamagedByTower(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Nihilism для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderPulseNova()
    local ability = PulseNova;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Использую PulseNova против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю PulseNova.", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if ability:GetToggleState() == false
                    then
                        --npcBot:ActionImmediate_Chat("Выключаю PulseNova.", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю PulseNova.", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
