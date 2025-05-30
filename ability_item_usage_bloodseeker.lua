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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[4],
    Abilities[1],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Bloodrage = AbilitiesReal[1]
local BloodRite = AbilitiesReal[2]
local Thirst = AbilitiesReal[3]
local BloodMist = AbilitiesReal[4]
local Rupture = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBloodrageDesire, castBloodrageTarget = ConsiderBloodrage();
    local castBloodRiteDesire, castBloodRiteLocation = ConsiderBloodRite();
    local castThirstDesire = ConsiderThirst();
    local castBloodMistDesire = ConsiderBloodMist();
    local castRuptureDesire, castRuptureTarget = ConsiderRupture();

    if (castBloodrageDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Bloodrage, castBloodrageTarget);
        return;
    end

    if (castBloodRiteDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(BloodRite, castBloodRiteLocation);
        return;
    end

    if (castThirstDesire > 0)
    then
        npcBot:Action_UseAbility(Thirst);
        return;
    end

    if (castBloodMistDesire > 0)
    then
        npcBot:Action_UseAbility(BloodMist);
        return;
    end

    if (castRuptureDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Rupture, castRuptureTarget);
        return;
    end
end

function ConsiderBloodrage()
    local ability = Bloodrage;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0) and not utility.RetreatMode(npcBot) and botMode ~= BOT_MODE_LANING
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_bloodseeker_bloodrage")
            then
                if ally:GetAttackTarget() ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую Bloodrage на " .. ally:GetUnitName(), true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBloodRite()
    local ability = BloodRite;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BloodRite на " .. enemy:GetUnitName(), true);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemyAbility, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if enemy ~= nil and utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderThirst()
    local ability = Thirst;
    if not utility.IsAbilityAvailable(ability)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_bloodseeker_thirst_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if not utility.IsIllusion(enemy) and enemy:GetHealth() >= enemy:GetMaxHealth()
            then
                return BOT_ACTION_DESIRE_NONE;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) < 1000
        then
            --npcBot:ActionImmediate_Chat("Использую Thirst для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую Thirst для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBloodMist()
    local ability = BloodMist;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Использую BloodMist против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю BloodMist.", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю BloodMist2.", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderRupture()
    local ability = Rupture;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = (enemy:GetMaxHealth() / 100 * ability:GetSpecialValueInt("hp_pct"));
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Rupture что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if not botTarget:HasModifier("modifier_bloodseeker_rupture")
                then
                    --npcBot:ActionImmediate_Chat("Использую Rupture по основной цели: " .. botTarget:GetUnitName(), true);
                    return BOT_MODE_DESIRE_VERYHIGH, botTarget;
                else
                    if (#enemyAbility > 1)
                    then
                        for _, enemy in pairs(enemyAbility) do
                            if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_bloodseeker_rupture")
                            then
                                --npcBot:ActionImmediate_Chat("Использую Rupture по второй цели: " .. enemy:GetUnitName(),true);
                                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                            end
                        end
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
