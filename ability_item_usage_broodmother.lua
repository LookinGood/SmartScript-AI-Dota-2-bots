---@diagnostic disable: undefined-global, redefined-local
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
    Abilities[3],
    Abilities[1],
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
local InsatiableHunger = AbilitiesReal[1]
local SpinWeb = AbilitiesReal[2]
local SilkenBola = AbilitiesReal[3]
local SpinnersSnare = AbilitiesReal[4]
local SpawnSpiderlings = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castInsatiableHungerDesire = ConsiderInsatiableHunger();
    local castSpinWebDesire, castSpinWebLocation = ConsiderSpinWeb();
    local castSilkenBolaDesire, castSilkenBolaTarget, castSilkenBolaTargetType = ConsiderSilkenBola();
    local castSpinnersSnareDesire, castSpinnersSnareLocation = ConsiderSpinnersSnare();
    local castSpawnSpiderlingsDesire, castSpawnSpiderlingsTarget = ConsiderSpawnSpiderlings();

    if (castInsatiableHungerDesire ~= nil)
    then
        npcBot:Action_UseAbility(InsatiableHunger);
        return;
    end

    if (castSpinWebDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SpinWeb, castSpinWebLocation);
        return;
    end

    if (castSilkenBolaDesire ~= nil)
    then
        if (castSilkenBolaTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(SilkenBola, castSilkenBolaTarget);
            return;
        elseif (castSilkenBolaTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(SilkenBola, castSilkenBolaTarget);
            return;
        end
    end

    if (castSpinnersSnareDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SpinnersSnare, castSpinnersSnareLocation);
        return;
    end

    if (castSpawnSpiderlingsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SpawnSpiderlings, castSpawnSpiderlingsTarget);
        return;
    end
end

function ConsiderInsatiableHunger()
    local ability = InsatiableHunger;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_broodmother_insatiable_hunger")
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)
        then
            if utility.CanCastSpellOnTarget(ability, attackTarget)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderSpinWeb()
    local ability = SpinWeb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_broodmother_spin_web")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(attackTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, npcBot, delayAbility, 0);
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, npcBot, delayAbility, 0);
        end
    end

    -- General use
    if npcBot:WasRecentlyDamagedByCreep(2.0) or npcBot:WasRecentlyDamagedByTower(2.0) or npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, npcBot, delayAbility, 0);
    end
end

function ConsiderSilkenBola()
    local ability = SilkenBola;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

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
                        --npcBot:ActionImmediate_Chat("Использую SilkenBola 1 что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SilkenBola 2 что бы добить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
                    end
                end
            end
        end
    end
end

function ConsiderSpinnersSnare()
    local ability = SpinnersSnare;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsAlive()
    then
        return;
    end
end

function ConsiderSpawnSpiderlings()
    local ability = SpawnSpiderlings;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SpawnSpiderlings что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
                and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Last hit
    if not utility.PvPMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SpawnSpiderlings что бы добить крипа " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
    end
end
