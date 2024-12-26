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
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Gush = AbilitiesReal[1]
local AnchorSmash = AbilitiesReal[3]
local DeadInIheWater = AbilitiesReal[4]
local Ravage = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castGushDesire, castGushTarget, castGushTargetType = ConsiderGush();
    local castAnchorSmashDesire = ConsiderAnchorSmash();
    local castDeadInIheWaterDesire, castDeadInIheWaterTarget = ConsiderDeadInIheWater();
    local castRavageDesire = ConsiderRavage();

    if (castGushDesire ~= nil)
    then
        if (castGushTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Gush, castGushTarget);
            return;
        elseif (castGushTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Gush, castGushTarget);
            return;
        end
    end

    if (castAnchorSmashDesire ~= nil)
    then
        npcBot:Action_UseAbility(AnchorSmash);
        return;
    end

    if (castDeadInIheWaterDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DeadInIheWater, castDeadInIheWaterTarget);
        return;
    end

    if (castRavageDesire ~= nil)
    then
        npcBot:Action_UseAbility(Ravage);
        return;
    end
end

function ConsiderGush()
    local ability = Gush;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("aoe_scepter");
    local damageAbility = ability:GetSpecialValueInt("gush_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed_scepter");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Gush что бы убить цель без аганима!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Gush что бы убить цель с аганимом!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
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
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), "location";
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage < 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Gush для отхода без аганимом!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Gush для отхода с аганимом!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.7)
        then
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Gush по вражеским крипам без аганима!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    end
                end
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
                    radiusAbility,
                    0, 0);
                if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
                then
                    --npcBot:ActionImmediate_Chat("Использую Gush по вражеским крипам с аганимом!", true);
                    return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                --npcBot:ActionImmediate_Chat("Использую Gush на лайне без аганимом!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                --npcBot:ActionImmediate_Chat("Использую Gush на лайне с аганимом!",true);
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
            end
        end
    end
end

function ConsiderAnchorSmash()
    local ability = AnchorSmash;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("attack_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AnchorSmash что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
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
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
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

function ConsiderDeadInIheWater()
    local ability = DeadInIheWater;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую DeadInIheWater что бы сбить заклинание !",true);
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
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderRavage()
    local ability = Ravage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
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
                    --npcBot:ActionImmediate_Chat("Использую Ravage что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Use in teamfight
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility >= 2)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ravage!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ravage для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
