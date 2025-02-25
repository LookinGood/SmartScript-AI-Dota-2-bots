---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")

function CourierUsageThink()
    ability_item_usage_generic.CourierUsageThink();
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
local Disruption = AbilitiesReal[1]
local Disseminate = AbilitiesReal[2]
local ShadowPoison = AbilitiesReal[3]
local ShadowPoisonRelease = AbilitiesReal[4]
local DemonicCleanse = AbilitiesReal[5]
local DemonicPurge = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDisruptionDesire, castDisruptionTarget = ConsiderDisruption();
    local castDisseminateDesire, castDisseminateTarget = ConsiderDisseminate();
    local castShadowPoisonDesire, castShadowPoisonLocation = ConsiderShadowPoison();
    local castShadowPoisonReleaseDesire = ConsiderShadowPoisonRelease();
    local castDemonicCleanseDesire, castDemonicCleanseTarget = ConsiderDemonicCleanse();
    local castDemonicPurgeDesire, castDemonicPurgeTarget = ConsiderDemonicPurge();

    if (castDisruptionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Disruption, castDisruptionTarget);
        return;
    end

    if (castDisseminateDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Disseminate, castDisseminateTarget);
        return;
    end

    if (castShadowPoisonDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ShadowPoison, castShadowPoisonLocation);
        return;
    end

    if (castShadowPoisonReleaseDesire ~= nil)
    then
        npcBot:Action_UseAbility(ShadowPoisonRelease);
        return;
    end

    if (castDemonicCleanseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DemonicCleanse, castDemonicCleanseTarget);
        return;
    end

    if (castDemonicPurgeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DemonicPurge, castDemonicPurgeTarget);
        return;
    end
end

function ConsiderDisruption()
    local ability = Disruption;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Disruption что бы сбить заклинание!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast to safe ally
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
                        if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 400 and spell.is_attack == false
                        then
                            --npcBot:ActionImmediate_Chat("Использую Disruption что бы уклониться от заклинания!",true);
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
                --npcBot:ActionImmediate_Chat("Использую Disruption что бы поймать врага!",true);
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
                    --npcBot:ActionImmediate_Chat("Использую Disruption что бы оторваться от врага!", true);
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
                --npcBot:ActionImmediate_Chat("Использую Disruption на союзного героя со здоровьем ниже 30%!",true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end

function ConsiderDisseminate()
    local ability = Disseminate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageRadiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200 and not botTarget:HasModifier("modifier_shadow_demon_disseminate")
        then
            -- npcBot:ActionImmediate_Chat("Использую Disseminate по вражескому герою!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Cast if ally attacked
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0) and not ally:HasModifier("modifier_shadow_demon_disseminate")
            then
                local enemyAbility = ally:GetNearbyHeroes(damageRadiusAbility, true, BOT_MODE_NONE);
                if (#enemyAbility > 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Disseminate на союзного героя которого атакуют!",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderShadowPoison()
    local ability = ShadowPoison;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Shadow Poison по крипам врага на линии!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (ManaPercentage >= 0.6)
        then
            local enemy = utility.GetWeakest(enemyAbility);
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowPoison по цели на ЛАЙНЕ!", true);
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
            end
        end
    end
end

function ConsiderShadowPoisonRelease()
    local ability = ShadowPoisonRelease;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    local creepsAbility = GetUnitList(UNIT_LIST_ENEMY_CREEPS);

    -- Use if enemy Hero has stacks
    for _, enemy in pairs(enemyAbility) do
        if utility.GetModifierCount(enemy, "modifier_shadow_demon_shadow_poison") >= 5 and utility.CanCastOnMagicImmuneTarget(enemy)
        then
            --npcBot:ActionImmediate_Chat("Использую Shadow Poison Release на врага с 5 и более стаками яда!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Use if enemy creeps has stacks
    if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(creepsAbility) do
            if utility.GetModifierCount(enemy, "modifier_shadow_demon_shadow_poison") >= 3 and utility.CanCastOnMagicImmuneTarget(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую Shadow Poison Release на крипов с 5 и более стаками яда!",true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderDemonicCleanse()
    local ability = DemonicCleanse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast if allys has negative effect or low HP
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier('modifier_shadow_demon_purge_slow')
            then
                if utility.IsDisabled(ally) or (ally:GetHealth() / ally:GetMaxHealth() <= 0.9 and ally:WasRecentlyDamagedByAnyHero(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую Demonic Cleanse на союзного героя!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderDemonicPurge()
    local ability = DemonicPurge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("purge_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую DemonicPurge что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier('modifier_shadow_demon_purge_slow')
                then
                    --npcBot:ActionImmediate_Chat("Использую Demonic Purge на врага в радиусе действия!",true);
                    return BOT_MODE_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end
