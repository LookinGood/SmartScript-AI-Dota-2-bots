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
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Refraction = AbilitiesReal[1]
local Meld = AbilitiesReal[2]
local Trap = AbilitiesReal[4]
local PsionicProjection = AbilitiesReal[5]
local PsionicTrap = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castRefractionDesire = ConsiderRefraction();
    local castMeldDesire = ConsiderMeld();
    local castTrapDesire = ConsiderTrap();
    local castPsionicProjectionDesire, castPsionicProjectionLocation = ConsiderPsionicProjection();
    local castPsionicTrapDesire, castPsionicTrapLocation = ConsiderPsionicTrap();

    if (castRefractionDesire ~= nil)
    then
        npcBot:Action_UseAbility(Refraction);
        return;
    end

    if (castMeldDesire ~= nil)
    then
        npcBot:Action_UseAbility(Meld);
        return;
    end

    if (castTrapDesire ~= nil)
    then
        npcBot:ActionPush_UseAbility(Trap);
        return;
    end

    if (castPsionicProjectionDesire ~= nil)
    then
        npcBot:Action_ClearAction(true);
        npcBot:Action_UseAbilityOnLocation(PsionicProjection, castPsionicProjectionLocation);
        return;
    end

    if (castPsionicTrapDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(PsionicTrap, castPsionicTrapLocation);
        return;
    end
end

function ConsiderRefraction()
    local ability = Refraction;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local abilityCount = ability:GetSpecialValueInt("instances");

    if utility.GetModifierCount(npcBot, "modifier_templar_assassin_refraction_absorb") >= abilityCount / 2
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
                and not utility.HaveReflectSpell(npcBot)
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- General use
    if (HealthPercentage <= 0.8) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or
            npcBot:WasRecentlyDamagedByCreep(2.0) or
            npcBot:WasRecentlyDamagedByTower(2.0))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderMeld()
    local ability = Meld;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and attackTarget == botTarget
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Meld для отхода!", true);
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderTrap()
    local ability = Trap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Из-за того что боты не умеют использовать альтернативное использование способностей, скил не работает как нужно и отключен до решения проблемы
    if npcBot:IsAlive()
    then
        return;
    end

    if utility.GetModifierCount(npcBot, "modifier_templar_assassin_psionic_trap_counter") < 1
    then
        return;
    end

    local radiusAbility = PsionicTrap:GetSpecialValueInt("trap_radius");
    local allyUnits = GetUnitList(UNIT_LIST_ALLIES);
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#allyUnits > 0)
    then
        for _, ally in pairs(allyUnits) do
            if ally:GetUnitName() == "npc_dota_templar_assassin_psionic_trap"
            then
                if (#enemyHeroes > 0)
                then
                    for _, enemy in pairs(enemyHeroes) do
                        if utility.CanCastSpellOnTarget(PsionicTrap, enemy) and GetUnitToUnitDistance(ally, enemy) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Взрываю ловушку рядом с врагом!", true);
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        end
    end
end

function ConsiderPsionicProjection()
    local ability = PsionicProjection;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsAlive()
    then
        return;
    end
end

function ConsiderPsionicTrap()
    local ability = PsionicTrap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.GetModifierCount(npcBot, "modifier_templar_assassin_psionic_trap_counter") >= 1
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("instant_trap_damage") +
        ability:GetSpecialValueInt("trap_bonus_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую PsionicTrap для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую PsionicTrap для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end
end
