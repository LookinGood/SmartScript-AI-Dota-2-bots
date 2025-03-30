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
local StaticRemnant = AbilitiesReal[1]
local ElectricVortex = AbilitiesReal[2]
local Overload = AbilitiesReal[3]
local BallLightning = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStaticRemnantDesire, castStaticRemnantLocation, castStaticRemnantTargetType = ConsiderStaticRemnant();
    local castElectricVortexDesire, castElectricVortexTarget, castElectricVortexTargetType = ConsiderElectricVortex();
    local castOverloadDesire = ConsiderOverload();
    local castBallLightningDesire, castBallLightningLocation = ConsiderBallLightning();

    if (castStaticRemnantDesire ~= nil)
    then
        if (castStaticRemnantTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(StaticRemnant, castStaticRemnantLocation);
            return;
        elseif (castStaticRemnantTargetType == nil)
        then
            npcBot:Action_UseAbility(StaticRemnant);
            return;
        end
    end

    if (castElectricVortexDesire ~= nil)
    then
        if (castElectricVortexTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(ElectricVortex, castElectricVortexTarget);
            return;
        elseif (castElectricVortexTargetType == nil)
        then
            npcBot:Action_UseAbility(ElectricVortex);
            return;
        end
    end

    if (castOverloadDesire ~= nil)
    then
        npcBot:Action_UseAbility(Overload);
        return;
    end

    if (castBallLightningDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BallLightning, castBallLightningLocation);
        return;
    end
end

function ConsiderStaticRemnant()
    local ability = StaticRemnant;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("static_remnant_radius");
    local damageAbility = ability:GetSpecialValueInt("static_remnant_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("static_remnant_travel_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую StaticRemnant по точке добивая " .. enemy:GetUnitName(),true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility),
                            "location";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                    then
                        if GetUnitToUnitDistance(npcBot, enemy) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую StaticRemnant ненаправленно добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE, nil, nil;
                        end
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    --npcBot:ActionImmediate_Chat("Использую StaticRemnant по точке атакуя " .. botTarget:GetUnitName(),true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility),
                        "location";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую StaticRemnant ненаправленно атакуя " .. botTarget:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, nil, nil;
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую StaticRemnant по точке отступая от " .. enemy:GetUnitName(),true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility),
                            "location";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                    then
                        if GetUnitToUnitDistance(npcBot, enemy) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую StaticRemnant ненаправленно отступая от " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE, nil, nil;
                        end
                    end
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
                0, 0);
            if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count > 2)
            then
                --npcBot:ActionImmediate_Chat("Использую StaticRemnant по точке против крипов", true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
            end
        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
            if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_ACTION_DESIRE_LOW, nil, nil;
                    end
                end
            end
        end
    end
end

function ConsiderElectricVortex()
    local ability = ElectricVortex;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius_scepter");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ElectricVortex без аганима на " .. enemy:GetUnitName(),true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif
                        utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ElectricVortex с аганимом на " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, nil;
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                and not utility.IsDisabled(botTarget)
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                then
                    return BOT_ACTION_DESIRE_HIGH, nil;
                end
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
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                    then
                        return BOT_ACTION_DESIRE_HIGH, nil;
                    end
                end
            end
        end
    end
end

function ConsiderOverload()
    local ability = Overload;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_storm_spirit_electric_rave")
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local attackRange = npcBot:GetAttackRange();

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        -- Attack use
        if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
        then
            if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end

        -- Use when attack building
        if utility.IsBuilding(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
        then
            if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3) and (ManaPercentage >= 0.5)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderBallLightning()
    local ability = BallLightning;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_storm_spirit_ball_lightning")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetSpecialValueInt("ball_lightning_aoe");
    local escapeRadius = ability:GetSpecialValueInt("ball_lightning_vision_radius");

    -- Cast if get incoming spell
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 500 and spell.is_attack == false
                and spell.is_dodgeable == true
            then
                --npcBot:ActionImmediate_Chat("Использую BallLightning для уклонения от снарядов!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, escapeRadius);
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 1000
                and (ManaPercentage >= 0.4)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation() + RandomVector(radiusAbility);
            end
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:DistanceFromFountain() >= escapeRadius
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, escapeRadius * 2);
        end
    end
end
