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
    Abilities[2],
    Abilities[2],
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Impale = AbilitiesReal[1]
local MindFlare = AbilitiesReal[2]
local SpikedCarapace = AbilitiesReal[3]
local Burrow = AbilitiesReal[4]
local Unburrow = npcBot:GetAbilityByName("nyx_assassin_unburrow");
local Vendetta = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castImpaleDesire, castImpaleLocation = ConsiderImpale();
    local castMindFlareDesire, castMindFlareTarget = ConsiderMindFlare();
    local castSpikedCarapaceDesire = ConsiderSpikedCarapace();
    local castBurrowDesire = ConsiderBurrow();
    local castUnburrowDesire = ConsiderUnburrow();
    local castVendettaDesire = ConsiderVendetta();

    if (castImpaleDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Impale, castImpaleLocation);
        return;
    end

    if (castMindFlareDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(MindFlare, castMindFlareTarget);
        return;
    end

    if (castSpikedCarapaceDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpikedCarapace);
        return;
    end

    if (castBurrowDesire ~= nil)
    then
        npcBot:Action_UseAbility(Burrow);
        return;
    end

    if (castUnburrowDesire ~= nil)
    then
        npcBot:Action_UseAbility(Unburrow);
        return;
    end

    if (castVendettaDesire ~= nil)
    then
        npcBot:Action_UseAbility(Vendetta);
        return;
    end
end

function ConsiderImpale()
    local ability = Impale;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("width");
    local damageAbility = ability:GetSpecialValueInt("impale_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Impale что бы убить цель/сбить каст!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_nyx_assassin_vendetta")
    then
        return;
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                    --npcBot:ActionImmediate_Chat("Использую Impale для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.8) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
            and not utility.IsDisabled(enemy)
        then
            --npcBot:ActionImmediate_Chat("Использую Impale на лайне!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderMindFlare()
    local ability = MindFlare;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = enemy:GetAttributeValue(ATTRIBUTE_INTELLECT) *
                ability:GetSpecialValueInt("float_multiplier");
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую MindFlare что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_nyx_assassin_vendetta")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end
end

function ConsiderSpikedCarapace()
    local ability = SpikedCarapace;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_nyx_assassin_spiked_carapace")
    then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- (Only Burrow) Cast if can interrupt cast
    if npcBot:HasModifier("modifier_nyx_assassin_burrow")
    then
        local radiusAbility = Burrow:GetSpecialValueInt("carapace_radius");
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and enemy:IsChanneling()
                then
                    npcBot:ActionImmediate_Chat("Использую SpikedCarapace закопавшись!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    if npcBot:WasRecentlyDamagedByAnyHero(1.0)
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end
end

function ConsiderBurrow()
    local ability = Burrow;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_nyx_assassin_burrow")
    then
        return;
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and (HealthPercentage <= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Burrow для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderUnburrow()
    local ability = Unburrow;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    local allyAbility = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if (#enemyAbility <= 0) and (HealthPercentage > 0.9)
    then
        npcBot:ActionImmediate_Chat("Использую Unburrow потому что врагов рядом нет!",
            true);
        return BOT_ACTION_DESIRE_HIGH;
    elseif (#enemyAbility > 0) and (#allyAbility <= 1) and not npcBot:IsInvisible()
    then
        npcBot:ActionImmediate_Chat("Использую Unburrow потому что меня раскрыли!", true);
        return BOT_ACTION_DESIRE_MODERATE;
    elseif (#enemyAbility <= #allyAbility) and (HealthPercentage > 0.6)
    then
        --npcBot:ActionImmediate_Chat("Использую Unburrow потому что врагов меньше чем союзников!", true);
        return BOT_ACTION_DESIRE_MODERATE;
    end
end

function ConsiderVendetta()
    local ability = Vendetta;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_nyx_assassin_vendetta")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) < 3000
        then
            --npcBot:ActionImmediate_Chat("Использую Vendetta для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую Vendetta для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

--[[ function ConsiderImpale()
    local ability = Impale;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("width");
    local damageAbility = ability:GetSpecialValueInt("impale_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local abilitySpeed = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / abilitySpeed));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    npcBot:ActionImmediate_Chat("Использую Impale что бы убить цель/сбить каст!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_nyx_assassin_vendetta")
    then
        return;
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                local targetDistance = GetUnitToUnitDistance(botTarget, npcBot)
                local moveDirection = botTarget:GetMovementDirectionStability();
                local targetLocation = botTarget:GetExtrapolatedLocation(delayAbility +
                    (targetDistance / abilitySpeed));
                if moveDirection < 0.95
                then
                    targetLocation = botTarget:GetLocation();
                end
                return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
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
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / abilitySpeed));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    npcBot:ActionImmediate_Chat("Использую Impale для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.8) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
            and not utility.IsDisabled(enemy)
        then
            local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
            local moveDirection = enemy:GetMovementDirectionStability();
            local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                (targetDistance / abilitySpeed));
            if moveDirection < 0.95
            then
                targetLocation = enemy:GetLocation();
            end
            npcBot:ActionImmediate_Chat("Использую Impale на лайне!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
        end
    end
end ]]
