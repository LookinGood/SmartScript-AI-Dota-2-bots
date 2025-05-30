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
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local BladeFury = AbilitiesReal[1]
local HealingWard = AbilitiesReal[2]
local Swiftslash = AbilitiesReal[4]
local Omnislash = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBladeFuryDesire = ConsiderBladeFury();
    local castHealingWardDesire, castHealingWardLocation = ConsiderHealingWard();
    local castSwiftslashDesire, castSwiftslashTarget = ConsiderSwiftslash();
    local castOmnislashDesire, castOmnislashTarget = ConsiderOmnislash();

    if (castBladeFuryDesire > 0)
    then
        npcBot:Action_UseAbility(BladeFury);
        return;
    end

    if (castHealingWardDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(HealingWard, castHealingWardLocation);
        return;
    end

    if (castSwiftslashDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Swiftslash, castSwiftslashTarget);
        return;
    end

    if (castOmnislashDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Omnislash, castOmnislashTarget);
        return;
    end
end

function ConsiderBladeFury()
    local ability = BladeFury;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if not utility.CanCastOnMagicImmuneTarget(npcBot)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetAOERadius();
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

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

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую BladeFury против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую BladeFury для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую BladeFury против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderHealingWard()
    local ability = HealingWard;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("healing_ward_aura_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, false, BOT_MODE_NONE);

    -- Use to heal damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.7)
                and not ally:HasModifier("modifier_juggernaut_healing_ward_heal")
            then
                if GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility + radiusAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, ally, castRangeAbility);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSwiftslash()
    local ability = Swiftslash;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_juggernaut_blade_fury")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = Omnislash:GetSpecialValueInt("omni_slash_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if (#enemyAbility > 0)
    then
        -- Cast if can interrupt cast
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Swiftslash что бы сбить заклинание!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end

        -- Try to kill enemy hero
        for _, enemy in pairs(enemyAbility) do
            local enemyAbility = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreeps = enemy:GetNearbyCreeps(radiusAbility, false);
            if enemy:GetHealth() / enemy:GetMaxHealth() <= 0.3 and (#enemyCreeps <= 1) and (#enemyAbility <= 1)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Swiftslash пытаясь убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            local enemyCreeps = botTarget:GetNearbyCreeps(radiusAbility, false);
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and (#enemyCreeps <= 1)
            then
                --npcBot:ActionImmediate_Chat("Использую Swiftslash для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOmnislash()
    local ability = Omnislash;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_juggernaut_blade_fury")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("omni_slash_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if (#enemyAbility > 0)
    then
        -- Cast if can interrupt cast
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Omnislash что бы сбить заклинание!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end

        -- Try to kill enemy hero
        for _, enemy in pairs(enemyAbility) do
            local enemyAbility = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreeps = enemy:GetNearbyCreeps(radiusAbility, false);
            if enemy:GetHealth() / enemy:GetMaxHealth() <= 0.5 and (#enemyCreeps <= 1) and (#enemyAbility <= 1)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Omnislash пытаясь убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            local enemyCreeps = botTarget:GetNearbyCreeps(radiusAbility, false);
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and (#enemyCreeps <= 1)
            then
                --npcBot:ActionImmediate_Chat("Использую Omnislash для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
