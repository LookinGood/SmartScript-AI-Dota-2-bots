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
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Shrapnel = AbilitiesReal[1]
local TakeAim = AbilitiesReal[3]
local ConcussiveGrenade = AbilitiesReal[4]
local Assassinate = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castShrapnelDesire, castShrapnelLocation = ConsiderShrapnel();
    local castTakeAimDesire = ConsiderTakeAim();
    local castConcussiveGrenadeDesire, castConcussiveGrenadeLocation = ConsiderConcussiveGrenade();
    local castAssassinateDesire, castAssassinateTarget = ConsiderAssassinate();

    if (castShrapnelDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Shrapnel, castShrapnelLocation);
        return;
    end

    if (castTakeAimDesire ~= nil)
    then
        npcBot:Action_UseAbility(TakeAim);
        return;
    end

    if (castConcussiveGrenadeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ConcussiveGrenade, castConcussiveGrenadeLocation);
        return;
    end

    if (castAssassinateDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Assassinate, castAssassinateTarget);
        return;
    end
end

function ConsiderShrapnel()
    local ability = Shrapnel;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Shrapnel по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.8)
        then
            --npcBot:ActionImmediate_Chat("Использую Shrapnel по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderTakeAim()
    local ability = TakeAim;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange() + ability:GetSpecialValueInt("bonus_attack_range");

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую TakeAim против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderConcussiveGrenade()
    local ability = ConcussiveGrenade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.IsHero(botTarget)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую ConcussiveGrenade для атаки!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if not utility.IsDisabled(enemy) and GetUnitToLocationDistance(enemy, fountainLocation) > GetUnitToLocationDistance(npcBot, fountainLocation)
                then
                    --npcBot:ActionImmediate_Chat("Использую ConcussiveGrenade для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
    end
end

function ConsiderAssassinate()
    local ability = Assassinate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if not npcBot:WasRecentlyDamagedByAnyHero(5.0)
    then
        for _, enemy in pairs(enemyAbility) do
            if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Assassinate что бы убить цель или сбить каст!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
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
                and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.4
            then
                --npcBot:ActionImmediate_Chat("Использую Assassinate для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end
