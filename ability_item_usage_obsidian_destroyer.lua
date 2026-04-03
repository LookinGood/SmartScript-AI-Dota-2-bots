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
    Abilities[1],
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
    Talents[5],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ArcaneOrb = npcBot:GetAbilityByName("obsidian_destroyer_arcane_orb");
local AstralImprisonment = npcBot:GetAbilityByName("obsidian_destroyer_astral_imprisonment");
local Objurgation = npcBot:GetAbilityByName("obsidian_destroyer_objurgation");
local SanitysEclipse = npcBot:GetAbilityByName("obsidian_destroyer_sanity_eclipse");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    ConsiderArcaneOrb();
    local castAstralImprisonmentDesire, castAstralImprisonmentTarget = ConsiderAstralImprisonment();
    local castObjurgationDesire = ConsiderObjurgation();
    local castSanitysEclipseDesire, castSanitysEclipseLocation = ConsiderSanitysEclipse();

    if (castAstralImprisonmentDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(AstralImprisonment, castAstralImprisonmentTarget);
        return;
    end

    if (castObjurgationDesire > 0)
    then
        npcBot:Action_UseAbility(Objurgation);
        return;
    end

    if (castSanitysEclipseDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(SanitysEclipse, castSanitysEclipseLocation);
        return;
    end
end

function ConsiderArcaneOrb()
    local ability = ArcaneOrb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.IsNeedTurnOnAttackModifier()
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end
end

function ConsiderAstralImprisonment()
    local ability = AstralImprisonment;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AstralImprisonment что бы сбить заклинание или убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast to safe ally from enemy spells
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility) do
            if not ally:IsChanneling()
            then
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    for _, spell in pairs(incomingSpells)
                    do
                        if not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 400 and spell.is_attack == false
                            and not utility.HaveReflectSpell(ally)
                        then
                            --npcBot:ActionImmediate_Chat("Использую AstralImprisonment что бы уклониться от заклинания!",true);
                            return BOT_ACTION_DESIRE_VERYHIGH, ally;
                        end
                    end
                end
            end
            -- Try to hide ally
            if utility.IsUnitNeedToHide(ally)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, ally;
            end
        end
    end

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and not utility.IsDisabled(botTarget)
            and not utility.IsUnitNeedToHide(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange()
            then
                --npcBot:ActionImmediate_Chat("Использую AstralImprisonment что бы поймать врага!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Use if need retreat
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and not utility.IsUnitNeedToHide(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AstralImprisonment что бы оторваться от врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    -- Cast if ally attacked and low HP
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.3) and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую AstralImprisonment на союзного героя со здоровьем ниже 30%!",true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderObjurgation()
    local ability = Objurgation;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_obsidian_destroyer_equilibrium_barrier")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

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

    -- General use
    if (HealthPercentage <= 0.6) and (utility.BotWasRecentlyDamagedByEnemyHero(2.0) or
            npcBot:WasRecentlyDamagedByCreep(2.0) or
            npcBot:WasRecentlyDamagedByTower(2.0))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSanitysEclipse()
    local ability = SanitysEclipse;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local botMana = npcBot:GetMana();
    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local baseDamageAbility = ability:GetSpecialValueInt("base_damage");
    local damageMultiplier = ability:GetSpecialValueInt("damage_multiplier");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- General use
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local enemyMana = enemy:GetMana();
            local difference = botMana - enemyMana;
            local damageAbility = baseDamageAbility + (damageMultiplier * difference);
            if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or (damageAbility >= enemy:GetMaxHealth() / 2) and utility.PvPMode(npcBot))
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SanitysEclipse по врагу в радиусе каста!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SanitysEclipse по врагу на расстоянии каста+радиуса!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
