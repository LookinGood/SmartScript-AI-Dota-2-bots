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
    Abilities[2],
    Abilities[3],
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
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Fissure = AbilitiesReal[1]
local EnchantTotem = AbilitiesReal[2]
local Aftershock = AbilitiesReal[3]
local EchoSlam = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    if IsAftershockAvailable()
    then
        aftershockRadius = Aftershock:GetSpecialValueInt("aftershock_range");
        aftershockDamage = Aftershock:GetSpecialValueInt("aftershock_damage");
    end

    local castFissureDesire, castFissureLocation = ConsiderFissure();
    local castEnchantTotemDesire, castEnchantTotemTarget, castEnchantTotemTargetType = ConsiderEnchantTotem();
    local castEchoSlamDesire = ConsiderEchoSlam();

    if (castFissureDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Fissure, castFissureLocation);
        return;
    end

    if (castEnchantTotemDesire ~= nil)
    then
        if (castEnchantTotemTargetType == nil)
        then
            npcBot:Action_UseAbility(EnchantTotem);
            return;
        elseif (castEnchantTotemTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(EnchantTotem, castEnchantTotemTarget);
            return;
        elseif (castEnchantTotemTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(EnchantTotem, castEnchantTotemTarget);
            return;
        end
    end

    if (castEchoSlamDesire ~= nil)
    then
        npcBot:Action_UseAbility(EchoSlam);
        return;
    end
end

function IsAftershockAvailable()
    local ability = Aftershock;
    if ability:IsTrained() and ability:IsFullyCastable() and not ability:IsHidden()
    then
        return true;
    end

    return false;
end

function ConsiderFissure()
    local ability = Fissure;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("fissure_radius");
    local damageAbility = ability:GetSpecialValueInt("fissure_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if IsAftershockAvailable()
            then
                if GetUnitToUnitDistance(npcBot, enemy) <= aftershockRadius
                then
                    damageAbility = damageAbility + aftershockDamage;
                end
            end
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Fissure что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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

        -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end
end

function ConsiderEnchantTotem()
    local ability = EnchantTotem;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_earthshaker_enchant_totem")
    then
        return;
    end

    local attackRange = (npcBot:GetAttackRange() + ability:GetSpecialValueInt("bonus_attack_range")) * 2;
    local castRangeAbility = ability:GetSpecialValueInt("distance_scepter");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("scepter_acceleration_horizontal");

    if IsAftershockAvailable()
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        -- Cast if can kill somebody/interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanAbilityKillTarget(enemy, aftershockDamage, Aftershock:GetDamageType()) or enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(Aftershock, enemy)
                    then
                        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                            and GetUnitToUnitDistance(npcBot, botTarget) <= aftershockRadius
                        then
                            --npcBot:ActionImmediate_Chat("Использую EnchantTotem без аганима добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, nil, nil;
                        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT) and not utility.RetreatMode(npcBot)
                            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую EnchantTotem с аганимом по точке добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH,
                                utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility),
                                "location";
                        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                            and GetUnitToUnitDistance(npcBot, botTarget) <= aftershockRadius
                        then
                            npcBot:ActionImmediate_Chat(
                                "Использую EnchantTotem с аганимом по цели добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, npcBot, "target";
                        end
                    end
                end
            end
        end
    end

    if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastOnInvulnerableTarget(botTarget)
    then
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую EnchantTotem без аганима атакуя!", true);
                return BOT_ACTION_DESIRE_HIGH, nil, nil;
            end
        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую EnchantTotem с аганимом по точке атакуя!", true);
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility),
                    "location";
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    --npcBot:ActionImmediate_Chat("Использую EnchantTotem с аганимом по цели атакуя!", true);
                    return BOT_ACTION_DESIRE_HIGH, npcBot, "target";
                end
            end
        end
    end

    if utility.RetreatMode(npcBot)
    then
        if IsAftershockAvailable()
        then
            local enemyAbility = npcBot:GetNearbyHeroes(aftershockRadius, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility)
                do
                    if utility.CanCastSpellOnTarget(Aftershock, enemy) and not utility.IsDisabled(enemy)
                    then
                        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                        then
                            --npcBot:ActionImmediate_Chat("Использую EnchantTotem без аганима отступая!", true);
                            return BOT_ACTION_DESIRE_HIGH, nil, nil;
                        end
                    end
                end
            end
        end
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
        then
            if npcBot:DistanceFromFountain() >= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую EnchantTotem с аганимом отступая!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility), "location";
            end
        end
    end
end

local function EchoSlamDamage()
    local ability = EchoSlam;
    local radiusAbility = ability:GetAOERadius();
    local baseDamage = ability:GetSpecialValueInt("echo_slam_initial_damage");
    local echoDamage = ability:GetSpecialValueInt("echo_slam_echo_damage");
    local realDamage = baseDamage;
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);

    if (#enemyAbility > 0)
    then
        realDamage = realDamage + (#enemyAbility * (echoDamage * 2))
    end
    if (#enemyCreeps > 0)
    then
        realDamage = realDamage + (#enemyCreeps * echoDamage)
    end

    return realDamage;
end

function ConsiderEchoSlam()
    local ability = EchoSlam;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = EchoSlamDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill/do a lot of damage somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if IsAftershockAvailable()
            then
                if GetUnitToUnitDistance(npcBot, enemy) <= aftershockRadius
                then
                    damageAbility = damageAbility + aftershockDamage;
                end
            end
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or damageAbility >= math.floor(enemy:GetMaxHealth() / 2)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую EchoSlam добивая " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
