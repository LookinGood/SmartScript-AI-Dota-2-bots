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
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Void = AbilitiesReal[1]
local CripplingFear = AbilitiesReal[2]
local HunterInTheNight = AbilitiesReal[3]
local DarkAscension = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castVoidDesire, castVoidTarget, castVoidTargetType = ConsiderVoid();
    local castCripplingFearDesire = ConsiderCripplingFear();
    local castHunterInTheNightDesire, castHunterInTheNightTarget = ConsiderHunterInTheNight();
    local castDarkAscensionDesire = ConsiderDarkAscension();

    if (castVoidDesire ~= nil)
    then
        if (castVoidTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Void, castVoidTarget);
            return;
        elseif (castVoidTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Void, castVoidTarget);
            return;
        end
    end

    if (castCripplingFearDesire ~= nil)
    then
        npcBot:Action_UseAbility(CripplingFear);
        return;
    end

    if (castHunterInTheNightDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(HunterInTheNight, castHunterInTheNightTarget);
        return;
    end

    if (castDarkAscensionDesire ~= nil)
    then
        npcBot:Action_UseAbility(DarkAscension);
        return;
    end
end

function ConsiderVoid()
    local ability = Void;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Void для убийства без аганима!", true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Void для убийства с аганимом!", true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), "location";
                    end
                end
            end
            if utility.IsNight() or npcBot:HasModifier("modifier_night_stalker_void_zone")
                or npcBot:HasModifier("modifier_night_stalker_darkness")
            then
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Void для сбивания каста без аганима!", true);
                            return BOT_ACTION_DESIRE_ABSOLUTE, enemy, "target";
                        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Void для сбивания каста с аганимом!", true);
                            return BOT_ACTION_DESIRE_ABSOLUTE,
                                utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), "location";
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
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0), "location";
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), "location";
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
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
                radiusAbility,
                0, 0);
            if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 2)
            then
                --npcBot:ActionImmediate_Chat("Использую Void на крипов!", true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
            end
        end
    end
end

function ConsiderCripplingFear()
    local ability = CripplingFear;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                if ability:GetToggleState() == false
                then
                    --npcBot:ActionImmediate_Chat("Использую CripplingFear против врага!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            else
                if ability:GetToggleState() == true
                then
                    --npcBot:ActionImmediate_Chat("Выключаю CripplingFear.", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю CripplingFear2.", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        -- Cast if can interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_ACTION_DESIRE_ABSOLUTE;
                    end
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
        end
    end
end

function ConsiderHunterInTheNight()
    local ability = HunterInTheNight;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange() * 2;
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    -- General use
    if (HealthPercentage <= 0.7) or (ManaPercentage <= 0.8)
    then
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if utility.IsNight() or npcBot:HasModifier("modifier_night_stalker_void_zone")
                        or npcBot:HasModifier("modifier_night_stalker_darkness")
                    then
                        --npcBot:ActionImmediate_Chat("Использую HunterInTheNight ночью!", true);
                        return BOT_ACTION_DESIRE_MODERATE, enemy;
                    else
                        if not enemy:IsAncientCreep()
                        then
                            --npcBot:ActionImmediate_Chat("Использую HunterInTheNight днем!", true);
                            return BOT_ACTION_DESIRE_MODERATE, enemy;
                        end
                    end
                end
            end
        end
    end
end

function ConsiderDarkAscension()
    local ability = DarkAscension;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_night_stalker_darkness")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
