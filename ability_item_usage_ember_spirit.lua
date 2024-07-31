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
local SearingChains = AbilitiesReal[1]
local SleightOfFist = AbilitiesReal[2]
local FlameGuard = AbilitiesReal[3]
local ActivateFireRemnant = AbilitiesReal[4]
local FireRemnant = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSearingChainsDesire = ConsiderSearingChains();
    local castSleightOfFistDesire, castSleightOfFistLocation = ConsiderSleightOfFist();
    local castFlameGuardDesire = ConsiderFlameGuard();
    local castActivateFireRemnantDesire, castActivateFireRemnantLocation = ConsiderActivateFireRemnant();
    local castFireRemnantDesire, castFireRemnantLocation = ConsiderFireRemnant();

    if (castSearingChainsDesire ~= nil)
    then
        npcBot:Action_UseAbility(SearingChains);
        return;
    end

    if (castSleightOfFistDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SleightOfFist, castSleightOfFistLocation);
        return;
    end

    if (castFlameGuardDesire ~= nil)
    then
        npcBot:Action_UseAbility(FlameGuard);
        return;
    end

    if (castActivateFireRemnantDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ActivateFireRemnant, castActivateFireRemnantLocation);
        return;
    end

    if (castFireRemnantDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(FireRemnant, castFireRemnantLocation);
        return;
    end
end

function ConsiderSearingChains()
    local ability = SearingChains;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("duration");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SearingChains против врага в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSleightOfFist()
    local ability = SleightOfFist;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("bonus_hero_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SleightOfFist что бы добить врага!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SleightOfFist что бы уклониться от снаряда по героям!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                        end
                    end
                end
                if (#enemyCreeps > 0)
                then
                    for _, enemy in pairs(enemyCreeps) do
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SleightOfFist что бы уклониться от снаряда по крипам!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                        end
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (ManaPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую SleightOfFist по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую SleightOfFist по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderFlameGuard()
    local ability = FlameGuard;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_ember_spirit_flame_guard")
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FlameGuard для нападения!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.9) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую FlameGuard для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderActivateFireRemnant()
    local ability = ActivateFireRemnant;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = FireRemnant:GetCastRange();
    local radiusAbility = FireRemnant:GetSpecialValueInt("radius");
    local allyUnits = GetUnitList(UNIT_LIST_ALLIED_OTHER);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if #allyUnits > 0
            then
                for _, ally in pairs(allyUnits) do
                    if ally:GetUnitName() == "npc_dota_ember_spirit_remnant" and GetUnitToUnitDistance(ally, botTarget) <= radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую ActivateFireRemnant для атаки!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally:GetLocation();
                    end
                end
            end
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if #allyUnits > 0
        then
            for _, ally in pairs(allyUnits) do
                if ally:GetUnitName() == "npc_dota_ember_spirit_remnant" and GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2
                    and ally:DistanceFromFountain() < npcBot:DistanceFromFountain()
                then
                    --npcBot:ActionImmediate_Chat("Использую ActivateFireRemnant для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally:GetLocation();
                end
            end
        end
    end
end

function ConsiderFireRemnant()
    local ability = FireRemnant;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --[[     if npcBot:GetMana() < ActivateFireRemnant:GetManaCost()
    then
        return;
    end ]]

    local castRangeAbility = ability:GetCastRange();
    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed_multiplier");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую FireRemnant для атаки!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            else
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility) + RandomVector(radiusAbility);
            end
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if not npcBot:HasModifier("modifier_ember_spirit_fire_remnant_timer") and (HealthPercentage <= 0.9)
            and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > castRangeAbility / 2
        then
            --npcBot:ActionImmediate_Chat("Использую FireRemnant для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end
