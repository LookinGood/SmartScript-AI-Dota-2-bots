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
local ColdFeet = npcBot:GetAbilityByName("ancient_apparition_cold_feet");
local IceVortex = npcBot:GetAbilityByName("ancient_apparition_ice_vortex");
local ChillingTouch = npcBot:GetAbilityByName("ancient_apparition_chilling_touch");
local Release = npcBot:GetAbilityByName("ancient_apparition_ice_blast_release");
local IceBlast = npcBot:GetAbilityByName("ancient_apparition_ice_blast");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castColdFeetDesire, castColdFeetTarget, castColdFeetTargetType = ConsiderColdFeet();
    local castIceVortexDesire, castIceVortexLocation = ConsiderIceVortex();
    ConsiderChillingTouch();
    local castReleaseDesire = ConsiderRelease();
    local castIceBlastDesire, castIceBlastLocation = ConsiderIceBlast();

    if (castColdFeetDesire > 0)
    then
        if (castColdFeetTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(ColdFeet, castColdFeetTarget);
            return;
        elseif (castColdFeetTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(ColdFeet, castColdFeetTarget);
            return;
        end
    end

    if (castIceVortexDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(IceVortex, castIceVortexLocation);
        return;
    end

    if (castReleaseDesire > 0)
    then
        npcBot:Action_UseAbility(Release);
        return;
    end

    if (castIceBlastDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(IceBlast, castIceBlastLocation);
        --releaseLocation = castIceBlastLocation;
        return;
    end
end

function ConsiderColdFeet()
    local ability = ColdFeet;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, nil;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling() or utility.IsDisabled(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ColdFeet по цели!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ColdFeet по области!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                            "location";
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
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet для атаки по цели!", true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet для атаки по области!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0),
                        "location";
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ColdFeet для отхода по цели!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ColdFeet для отхода по области!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                            "location";
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, nil;
end

function ConsiderIceVortex()
    local ability = IceVortex;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:HasModifier("modifier_ice_vortex")
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
            and not enemy:HasModifier("modifier_ice_vortex")
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderChillingTouch()
    local ability = ChillingTouch;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.IsNeedTurnOnAttackModifier()
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

function ConsiderRelease()
    local ability = Release;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local projectiles = GetLinearProjectiles();
    local minRadius = IceBlast:GetSpecialValueInt("radius_min");
    local killPrecent = IceBlast:GetSpecialValueInt("kill_pct");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#projectiles > 0) and (#enemyAbility > 0)
    then
        for _, iceBlast in pairs(projectiles)
        do
            if iceBlast ~= nil and iceBlast.ability:GetName() == "ancient_apparition_ice_blast"
            then
                for _, enemy in pairs(enemyAbility) do
                    if (enemy == botTarget or enemy:GetHealth() <= (enemy:GetMaxHealth() / 100 * killPrecent)) and
                        GetUnitToLocationDistance(enemy, iceBlast.location) <= minRadius
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderIceBlast()
    local ability = IceBlast;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local killPrecent = ability:GetSpecialValueInt("kill_pct");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local abilitySpeed = ability:GetSpecialValueInt("speed");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() <= (enemy:GetMaxHealth() / 100 * killPrecent))
            then
                --npcBot:ActionImmediate_Chat("Использую IceBlast что бы добить: " .. enemy:GetUnitName(), true);
                return BOT_ACTION_DESIRE_ABSOLUTE,
                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, abilitySpeed);
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую IceBlast по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, abilitySpeed);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

--[[ for i = 1, #enemyAbility do
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

for i = 1, #enemyAbility do
    if enemyAbility[i]:GetHealth() <= (enemyAbility[i]:GetMaxHealth() / 100 * healthLimit)
    then
        --npcBot:ActionImmediate_Chat("Использую IceBlast что бы добить врага!", true);
        return BOT_ACTION_DESIRE_VERYHIGH,
            utility.GetTargetCastPosition(npcBot, enemyAbility[i], delayAbility, abilitySpeed);
    end
end
 ]]
