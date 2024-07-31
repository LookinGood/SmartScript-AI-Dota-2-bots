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
    Abilities[3],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
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
local ColdFeet = AbilitiesReal[1]
local IceVortex = AbilitiesReal[2]
local ChillingTouch = AbilitiesReal[3]
local Release = npcBot:GetAbilityByName("ancient_apparition_ice_blast_release");
local IceBlast = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castColdFeetDesire, castColdFeetTarget = ConsiderColdFeet();
    local castIceVortexDesire, castIceVortexLocation = ConsiderIceVortex();
    ConsiderChillingTouch();
    local castReleaseDesire = ConsiderRelease();
    local castIceBlastDesire, castIceBlastLocation = ConsiderIceBlast();

    if (castColdFeetDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ColdFeet, castColdFeetTarget);
        return;
    end

    if (castIceVortexDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceVortex, castIceVortexLocation);
        return;
    end

    if (castReleaseDesire ~= nil)
    then
        npcBot:Action_UseAbility(Release);
        return;
    end

    if (castIceBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceBlast, castIceBlastLocation);
        --releaseLocation = castIceBlastLocation;
        return;
    end
end

function ConsiderColdFeet()
    local ability = ColdFeet;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetDuration();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling() or utility.IsDisabled(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую ColdFeet по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderIceVortex()
    local ability = IceVortex;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:HasModifier("modifier_ice_vortex")
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_ice_vortex")
                then
                    --npcBot:ActionImmediate_Chat("Использую IceVortex для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemyAbility, delayAbility, 0);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
            and not enemy:HasModifier("modifier_ice_vortex")
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderChillingTouch()
    local ability = ChillingTouch;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));
    local attackTarget = npcBot:GetAttackTarget();

    if (utility.IsHero(botTarget) or utility.IsRoshan(botTarget)) and utility.CanCastSpellOnTarget(ability, botTarget)
        and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState()
        then
            ability:ToggleAutoCast()
        end
    end

    if attackTarget ~= nil
    then
        if (utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)) and utility.CanCastSpellOnTarget(ability, attackTarget)
        then
            if not ability:GetAutoCastState()
            then
                ability:ToggleAutoCast()
            end
        else
            if ability:GetAutoCastState()
            then
                ability:ToggleAutoCast()
            end
        end
    end
end

function ConsiderRelease()
    local ability = Release;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local projectiles = GetLinearProjectiles();
    local radiusAbility = IceBlast:GetSpecialValueInt("radius_min");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    for _, iceBlast in pairs(projectiles)
    do
        if iceBlast ~= nil and iceBlast.ability:GetName() == "ancient_apparition_ice_blast"
        then
            for i = 1, #enemyAbility do
                if GetUnitToLocationDistance(enemyAbility[i], iceBlast.location) <= radiusAbility
                then
                    if botTarget == enemyAbility[i] or enemyAbility[i]:GetHealth() <= (enemyAbility[i]:GetMaxHealth() / 100 * IceBlast:GetSpecialValueInt("kill_pct"))
                    then
                        --npcBot:ActionImmediate_Chat("Использую Release рядом с врагом!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    else
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                end
            end
        end
    end
end

function ConsiderIceBlast()
    local ability = IceBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local healthLimit = ability:GetSpecialValueInt("kill_pct");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local abilitySpeed = ability:GetSpecialValueInt("speed");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Generic use if can kill enemy hero
    for i = 1, #enemyAbility do
        if enemyAbility[i]:GetHealth() <= (enemyAbility[i]:GetMaxHealth() / 100 * healthLimit)
        then
            --npcBot:ActionImmediate_Chat("Использую IceBlast что бы добить врага!", true);
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, enemyAbility[i], delayAbility, abilitySpeed);
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую IceBlast по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
    end
end
