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
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SpiritLance = AbilitiesReal[1]
local Doppelganger = AbilitiesReal[2]
local PhantomRush = AbilitiesReal[3]
local Juxtapose = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSpiritLanceDesire, castSpiritLanceTarget = ConsiderSpiritLance();
    local castDoppelgangerDesire, castDoppelgangerLocation = ConsiderDoppelganger();
    local castPhantomRushDesire = ConsiderPhantomRush();
    local castJuxtaposeDesire = ConsiderJuxtapose();

    if (castSpiritLanceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SpiritLance, castSpiritLanceTarget);
        return;
    end

    if (castDoppelgangerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Doppelganger, castDoppelgangerLocation);
        return;
    end

    if (castPhantomRushDesire ~= nil)
    then
        npcBot:Action_UseAbility(PhantomRush);
        return;
    end

    if (castJuxtaposeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Juxtapose);
        return;
    end
end

function ConsiderSpiritLance()
    local ability = SpiritLance;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("lance_damage")
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SpiritLance что бы убить цель!", true);
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
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderDoppelganger()
    local ability = Doppelganger;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                --npcBot:ActionImmediate_Chat("Использую Doppelganger что бы уклониться от снаряда!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, npcBot:GetLocation();
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:DistanceFromFountain() >= castRangeAbility and
            (npcBot:WasRecentlyDamagedByAnyHero(2.0) or
                npcBot:WasRecentlyDamagedByCreep(2.0) or
                npcBot:WasRecentlyDamagedByTower(2.0))
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end

function ConsiderPhantomRush()
    local ability = PhantomRush;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --local minCastRangeAbility = ability:GetSpecialValueInt("min_distance");
    --local maxCastRangeAbility = ability:GetSpecialValueInt("max_distance");
    --local attackTarget = npcBot:GetAttackTarget();

    if ability:GetToggleState() == false
    then
        --npcBot:ActionImmediate_Chat("Включаю PhantomRush!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end

    --[[ if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_ATTACK
    then
        if ability:GetToggleState() == false
        then
            --npcBot:ActionImmediate_Chat("Включаю PhantomRush!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю PhantomRush!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end ]]


    --[[ if attackTarget ~= nil and (GetUnitToUnitDistance(npcBot, attackTarget) >= minCastRangeAbility and
            GetUnitToUnitDistance(npcBot, attackTarget) <= maxCastRangeAbility) ]]
end

function ConsiderJuxtapose()
    local ability = Juxtapose;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                --npcBot:ActionImmediate_Chat("Использую Juxtapose что бы уклониться от снаряда!",true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую Juxtapose для отхода!", true);
            return BOT_MODE_DESIRE_HIGH;
        end
    end
end
