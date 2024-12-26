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
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local TameTheBeasts = AbilitiesReal[1]
local Crack = npcBot:GetAbilityByName("ringmaster_tame_the_beasts_crack");
local EscapeAct = AbilitiesReal[2]
local ImpalementArts = AbilitiesReal[3]
local Spotlight = AbilitiesReal[5]
local WheelOfWonder = AbilitiesReal[6]
local FunhouseMirror = npcBot:GetAbilityByName("ringmaster_funhouse_mirror");
local WhoopeeCushion = npcBot:GetAbilityByName("ringmaster_whoopee_cushion");
local StrongmanTonic = npcBot:GetAbilityByName("ringmaster_strongman_tonic");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castTameTheBeastsDesire, castTameTheBeastsLocation = ConsiderTameTheBeasts();
    local castCrackDesire = ConsiderCrack();
    local castEscapeActDesire, castEscapeActTarget = ConsiderEscapeAct();
    local castImpalementArtsDesire, castImpalementArtsLocation = ConsiderImpalementArts();
    local castSpotlightDesire, castSpotlightLocation = ConsiderSpotlight();
    local castWheelOfWonderDesire, castWheelOfWonderLocation = ConsiderWheelOfWonder();
    local castFunhouseMirrorDesire = ConsiderFunhouseMirror();
    local castWhoopeeCushionDesire = ConsiderWhoopeeCushion();
    local castStrongmanTonicDesire, castStrongmanTonicTarget = ConsiderStrongmanTonic();

    if (castTameTheBeastsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TameTheBeasts, castTameTheBeastsLocation);
        return;
    end

    if (castCrackDesire ~= nil)
    then
        npcBot:Action_UseAbility(Crack);
        return;
    end

    if (castEscapeActDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(EscapeAct, castEscapeActTarget);
        return;
    end

    if (castImpalementArtsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ImpalementArts, castImpalementArtsLocation);
        return;
    end

    if (castSpotlightDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Spotlight, castSpotlightLocation);
        return;
    end

    if (castWheelOfWonderDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WheelOfWonder, castWheelOfWonderLocation);
        return;
    end

    if (castFunhouseMirrorDesire ~= nil)
    then
        npcBot:Action_UseAbility(FunhouseMirror);
        return;
    end

    if (castWhoopeeCushionDesire ~= nil)
    then
        npcBot:Action_UseAbility(WhoopeeCushion);
        return;
    end

    if (castStrongmanTonicDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(StrongmanTonic, castStrongmanTonicTarget);
        return;
    end
end

function ConsiderTameTheBeasts()
    local ability = TameTheBeasts;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("end_width");
    local damageAbility = ability:GetSpecialValueInt("damage_max");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TameTheBeasts что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderCrack()
    local ability = Crack;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = TameTheBeasts:GetCastRange();
    local radiusAbility = TameTheBeasts:GetSpecialValueInt("end_width");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Crack что бы сбить каст " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        npcBot:ActionImmediate_Chat("Использую Crack отступая!", true);
        return BOT_ACTION_DESIRE_VERYHIGH;
    end
end

function ConsiderEscapeAct()
    local ability = EscapeAct;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally)
            then
                -- Saving ally
                if (ally:GetHealth() / ally:GetMaxHealth() <= 0.4)
                    and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0)) or
                    utility.IsUnitNeedToHide(ally)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally;
                end
                -- Block incoming spells
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    if not utility.HaveReflectSpell(ally) and not ally:IsInvulnerable()
                    then
                        for _, spell in pairs(incomingSpells)
                        do
                            if not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 500 and spell.is_attack == false
                            then
                                --npcBot:ActionImmediate_Chat("Использую EscapeAct сбивая снаряд на " .. ally:GetUnitName(),true);
                                return BOT_ACTION_DESIRE_VERYHIGH, ally;
                            end
                        end
                    end
                end
            end
        end
    end
end

function ConsiderImpalementArts()
    local ability = ImpalementArts;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local abilityRadius = ability:GetSpecialValueInt("dagger_width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("dagger_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = ability:GetSpecialValueInt("damage_impact") + ((enemy:GetMaxHealth() / 100 *
                ability:GetSpecialValueInt("bleed_health_pct")) * ability:GetSpecialValueInt("bleed_duration"));
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / speedAbility));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ImpalementArts что бы убить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, targetLocation;
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
                and not utility.IsDisabled(botTarget)
            then
                local targetDistance = GetUnitToUnitDistance(botTarget, npcBot)
                local moveDirection = botTarget:GetMovementDirectionStability();
                local targetLocation = botTarget:GetExtrapolatedLocation(delayAbility +
                    (targetDistance / speedAbility));
                if moveDirection < 0.95
                then
                    targetLocation = botTarget:GetLocation();
                end
                if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, botTarget, targetLocation, abilityRadius)
                then
                    return BOT_ACTION_DESIRE_HIGH, targetLocation;
                end
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
                    local targetDistance = GetUnitToUnitDistance(enemy, npcBot)
                    local moveDirection = enemy:GetMovementDirectionStability();
                    local targetLocation = enemy:GetExtrapolatedLocation(delayAbility +
                        (targetDistance / speedAbility));
                    if moveDirection < 0.95
                    then
                        targetLocation = enemy:GetLocation();
                    end
                    if not utility.IsEnemyCreepBetweenMeAndTarget(npcBot, enemy, targetLocation, abilityRadius)
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, targetLocation;
                    end
                end
            end
        end
    end
end

function ConsiderSpotlight()
    local ability = Spotlight;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("sweep_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- General use
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local enemyAttackTarget = enemy:GetAttackTarget();
            if utility.CanCastSpellOnTarget(ability, enemy) and (utility.IsHero(enemyAttackTarget) or enemy:IsInvisible())
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
            end
        end
    end
end

function ConsiderWheelOfWonder()
    local ability = WheelOfWonder;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local minCastRangeAbility = ability:GetSpecialValueInt("min_range");
    local radiusAbility = ability:GetSpecialValueInt("mesmerize_radius");
    local damageAbility = ability:GetSpecialValueInt("explosion_damage") +
        (ability:GetSpecialValueInt("aura_damage") * ability:GetSpecialValueInt("wheel_stun"));
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.IsDisabled(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WheelOfWonder что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= minCastRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую WheelOfWonder на врага вблизи!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetMaxRangeCastLocation(npcBot, botTarget, minCastRangeAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) > minCastRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую WheelOfWonder на врага на расстоянии!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую WheelOfWonder по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

-- Items Ability
function ConsiderFunhouseMirror()
    local ability = FunhouseMirror;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Block incoming spells
    if (#incomingSpells > 0)
    then
        if not npcBot:HasModifier("modifier_antimage_counterspell") and
            not npcBot:HasModifier("modifier_item_sphere_target") and
            not npcBot:HasModifier("modifier_item_lotus_orb_active")
        then
            for _, spell in pairs(incomingSpells)
            do
                if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) < 50 and spell.is_attack == false
                then
                    --npcBot:ActionImmediate_Chat("Использую FunhouseMirror что бы сбить снаряд!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
        then
            --npcBot:ActionImmediate_Chat("Использую FunhouseMirror для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую FunhouseMirror для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderWhoopeeCushion()
    local ability = WhoopeeCushion;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("leap_distance");
    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if (GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + attackRange) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
            then
                --npcBot:ActionImmediate_Chat("Использую WhoopeeCushion по врагу в радиусе действия!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую WhoopeeCushion для отхода!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderStrongmanTonic()
    local ability = StrongmanTonic;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and not ally:HasModifier("modifier_ringmaster_strongman_tonic")
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(5.0) or
                    ally:WasRecentlyDamagedByTower(2.0) or
                    utility.IsHero(ally:GetAttackTarget())
                then
                    --npcBot:ActionImmediate_Chat("Использую StrongmanTonic на раненого союзника!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally) and utility.IsHero(ally:GetAttackTarget()) and ally:GetPrimaryAttribute() == ATTRIBUTE_STRENGTH
                        and not ally:HasModifier("modifier_ringmaster_strongman_tonic")
                    then
                        --npcBot:ActionImmediate_Chat("Использую StrongmanTonic на атакующего союзника!", true);
                        return BOT_MODE_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
end
