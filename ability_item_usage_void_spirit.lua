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
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[2],
    Abilities[2],
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[3],
    Abilities[1],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local AetherRemnant = AbilitiesReal[1]
local Dissimilate = AbilitiesReal[2]
local ResonantPulse = AbilitiesReal[3]
local AstralStep = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castAetherRemnantDesire, castAetherRemnantLocation = ConsiderAetherRemnant();
    local castDissimilateDesire = ConsiderDissimilate();
    local castResonantPulseDesire = ConsiderResonantPulse();
    local castAstralStepDesire, castAstralStepLocation = ConsiderAstralStep();

    if (castAetherRemnantDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(AetherRemnant, castAetherRemnantLocation);
        return;
    end

    if (castDissimilateDesire ~= nil)
    then
        npcBot:Action_UseAbility(Dissimilate);
        return;
    end

    if (castResonantPulseDesire ~= nil)
    then
        npcBot:Action_UseAbility(ResonantPulse);
        return;
    end

    if (castAstralStepDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(AstralStep, castAstralStepLocation);
        return;
    end
end

function ConsiderAetherRemnant()
    local ability = AetherRemnant;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AetherRemnant что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end
end

function ConsiderDissimilate()
    local ability = Dissimilate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
    local radiusAbility = ability:GetSpecialValueInt("damage_radius");
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Cast if get incoming spell
    if (#incomingSpells > 0) and not utility.HaveReflectSpell(npcBot)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderResonantPulse()
    local ability = ResonantPulse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ResonantPulse что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Roshan use
        if utility.IsRoshan(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.RetreatMode(npcBot)
    then
        if (not npcBot:HasModifier("modifier_void_spirit_resonant_pulse_physical_buff")) and
            (npcBot:WasRecentlyDamagedByAnyHero(2.0) or
                npcBot:WasRecentlyDamagedByCreep(2.0) or
                npcBot:WasRecentlyDamagedByTower(2.0))
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6) and not npcBot:HasModifier("modifier_void_spirit_resonant_pulse_physical_buff")
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderAstralStep()
    local ability = AstralStep;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local minCastRange = ability:GetSpecialValueInt("min_travel_distance");
    local maxCastRange = ability:GetSpecialValueInt("max_travel_distance");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("pop_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(maxCastRange, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AstralStep что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > minCastRange
                and GetUnitToUnitDistance(npcBot, botTarget) <= maxCastRange
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and npcBot:DistanceFromFountain() >= maxCastRange
        then
            if (npcBot:WasRecentlyDamagedByAnyHero(2.0) or
                    npcBot:WasRecentlyDamagedByCreep(2.0) or
                    npcBot:WasRecentlyDamagedByTower(2.0))
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, maxCastRange);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot) and (#enemyAbility <= 0)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), maxCastRange, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 5)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
