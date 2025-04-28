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
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SplitEarth = AbilitiesReal[1]
local DiabolicEdict = AbilitiesReal[2]
local LightningStorm = AbilitiesReal[3]
local Nihilism = AbilitiesReal[4]
local PulseNova = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSplitEarthDesire, castSplitEarthLocation = ConsiderSplitEarth();
    local castDiabolicEdictDesire = ConsiderDiabolicEdict();
    local castLightningStormDesire, castLightningStormTarget = ConsiderLightningStorm();
    local castNihilismDesire = ConsiderNihilism();
    local castPulseNovaDesire = ConsiderPulseNova();

    if (castSplitEarthDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(SplitEarth, castSplitEarthLocation);
        return;
    end

    if (castDiabolicEdictDesire > 0)
    then
        npcBot:Action_UseAbility(DiabolicEdict);
        return;
    end

    if (castLightningStormDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(LightningStorm, castLightningStormTarget);
        return;
    end

    if (castNihilismDesire > 0)
    then
        npcBot:Action_UseAbility(Nihilism);
        return;
    end

    if (castPulseNovaDesire > 0)
    then
        npcBot:Action_UseAbility(PulseNova);
        return;
    end

    if npcBot:HasModifier("modifier_leshrac_diabolic_edict")
    then
        local attackTarget = npcBot:GetAttackTarget();
        if utility.IsValidTarget(attackTarget)
        then
            if GetUnitToUnitDistance(npcBot, attackTarget) > (DiabolicEdict:GetSpecialValueInt("radius") - 100)
            then
                --npcBot:ActionImmediate_Chat("Сближаюсь с врагом что бы обжечь его!",true);
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(attackTarget:GetLocation());
            end
        end
    end

    if npcBot:HasModifier("modifier_leshrac_pulse_nova")
    then
        local attackTarget = npcBot:GetAttackTarget();
        if utility.IsHero(attackTarget)
        then
            if GetUnitToUnitDistance(npcBot, attackTarget) > (PulseNova:GetSpecialValueInt("radius") - 100)
            then
                --npcBot:ActionImmediate_Chat("Сближаюсь с врагом что бы обжечь его ультой!",true);
                npcBot:Action_ClearActions(false);
                npcBot:Action_MoveToLocation(attackTarget:GetLocation());
            end
        end
    end
end

function ConsiderSplitEarth()
    local ability = SplitEarth;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую SplitEarth по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDiabolicEdict()
    local ability = DiabolicEdict;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackTarget = npcBot:GetAttackTarget();
    --local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую DiabolicEdict против врага в радиусе действия!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Use when attack
    if utility.IsBuilding(attackTarget) and utility.CanCastSpellOnTarget(ability, attackTarget) and botMode ~= BOT_MODE_OUTPOST
    then
        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.2) and (ManaPercentage >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую DiabolicEdict против зданий!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.IsHero(attackTarget)
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderLightningStorm()
    local ability = LightningStorm;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LightningStorm что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
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
            then
                --npcBot:ActionImmediate_Chat("Использую LightningStorm по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LightningStorm что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps >= 3) and (ManaPercentage >= 0.7)
        then
            local enemy = utility.GetWeakest(enemyCreeps);
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую LightningStorm по крипам!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningStorm по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNihilism()
    local ability = Nihilism;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) < radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Nihilism против врага!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(5.0) or npcBot:WasRecentlyDamagedByTower(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Nihilism для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPulseNova()
    local ability = PulseNova;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetAOERadius();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
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
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.8)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        if ability:GetToggleState() == false
                        then
                            --npcBot:ActionImmediate_Chat("Выключаю PulseNova.", true);
                            return BOT_ACTION_DESIRE_HIGH;
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
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю PulseNova.", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
