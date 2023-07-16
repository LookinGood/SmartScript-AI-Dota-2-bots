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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

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
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    Disruption = AbilitiesReal[1]
    Disseminate = AbilitiesReal[2]
    ShadowPoison = AbilitiesReal[3]
    ShadowPoisonRelease = AbilitiesReal[4]
    DemonicCleanse = AbilitiesReal[5]
    DemonicPurge = AbilitiesReal[6]

    castDisruptionDesire, castDisruptionTarget = ConsiderDisruption();
    castDisseminateDesire, castDisseminateTarget = ConsiderDisseminate();
    castShadowPoisonDesire, castShadowPoisonLocation = ConsiderShadowPoison();
    castShadowPoisonReleaseDesire = ConsiderShadowPoisonRelease();
    castDemonicCleanseDesire, castDemonicCleanseTarget = ConsiderDemonicCleanse();
    castDemonicPurgeDesire, castDemonicPurgeTarget = ConsiderDemonicPurge();

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
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую Disruption что бы сбить заклинание!", true);
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
                        if GetUnitToLocationDistance(ally, spell.location) <= 400 and spell.is_attack == false
                        then
                            --npcBot:ActionImmediate_Chat("Использую Disruption что бы уклониться от заклинания!",true);
                            return BOT_ACTION_DESIRE_VERYHIGH, ally;
                        end
                    end
                end
            end
        end
    end

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and utility.SafeCast(botTarget, false)
            and not utility.IsDisabled(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange()
            then
                --npcBot:ActionImmediate_Chat("Использую Disruption что бы поймать врага!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false)
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
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200 and utility.IsHero(botTarget) and utility.SafeCast(botTarget, true)
        then
            -- npcBot:ActionImmediate_Chat("Использую Disseminate по вражескому герою!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Cast if ally attacked and low HP
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allysAbility)
        do
            if utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
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

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if utility.IsMoving(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowPoison по бегущей цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(delayAbility);
            else
                --npcBot:ActionImmediate_Chat("Использую ShadowPoison по стоящей цели!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Shadow Poison по крипам врага на линии!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);
        if (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowPoison по бегущей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetExtrapolatedLocation(delayAbility);
                    else
                        --npcBot:ActionImmediate_Chat("Использую ShadowPoison по стоящей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                    end
                end
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
    if not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT
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
            if enemy:CanBeSeen() and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                then
                    --npcBot:ActionImmediate_Chat("Использую DemonicPurge что бы убить цель!",true);
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
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen() and utility.SafeCast(enemy, true) and not enemy:HasModifier('modifier_shadow_demon_purge_slow')
                then
                    --npcBot:ActionImmediate_Chat("Использую Demonic Purge на врага в радиусе действия!",true);
                    return BOT_MODE_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end
