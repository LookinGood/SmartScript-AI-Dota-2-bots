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
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[2],
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
local Reflection = AbilitiesReal[1]
local ConjureImage = AbilitiesReal[2]
local Metamorphosis = AbilitiesReal[3]
local DemonZeal = AbilitiesReal[4]
local TerrorWave = AbilitiesReal[5]
local Sunder = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castReflectionDesire, castReflectionLocation = ConsiderReflection();
    local castConjureImageDesire = ConsiderConjureImage();
    local castMetamorphosisDesire = ConsiderMetamorphosis();
    local castDemonZealDesire = ConsiderDemonZeal();
    local castTerrorWaveDesire = ConsiderTerrorWave();
    local castSunderDesire, castSunderTarget = ConsiderSunder();

    if (castReflectionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Reflection, castReflectionLocation);
        return;
    end

    if (castConjureImageDesire ~= nil)
    then
        npcBot:Action_UseAbility(ConjureImage);
        return;
    end

    if (castMetamorphosisDesire ~= nil)
    then
        npcBot:Action_UseAbility(Metamorphosis);
        return;
    end

    if (castDemonZealDesire ~= nil)
    then
        npcBot:Action_UseAbility(DemonZeal);
        return;
    end

    if (castTerrorWaveDesire ~= nil)
    then
        npcBot:Action_UseAbility(TerrorWave);
        return;
    end

    if (castSunderDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Sunder, castSunderTarget);
        return;
    end
end

function ConsiderReflection()
    local ability = Reflection;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility + radiusAbility),
            true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end
end

function ConsiderConjureImage()
    local ability = ConjureImage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTowers = npcBot:GetNearbyTowers(1600, true);
        local enemyBarracks = npcBot:GetNearbyBarracks(1600, true);
        local enemyAncient = GetAncient(GetOpposingTeam());
        if (ManaPercentage >= 0.4) and
            ((#enemyCreeps > 0) or
                (#enemyTowers > 0) or
                (#enemyBarracks > 0) or
                npcBot:GetAttackTarget() == enemyAncient)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderMetamorphosis()
    local ability = Metamorphosis;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_terrorblade_metamorphosis")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange() + ability:GetSpecialValueInt("bonus_range");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
        then
            --npcBot:ActionImmediate_Chat("Использую Metamorphosis для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderDemonZeal()
    local ability = DemonZeal;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_terrorblade_metamorphosis") or (utility.IsAbilityAvailable(Metamorphosis) or utility.IsAbilityAvailable(TerrorWave))
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую DemonZeal для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
            then
                --npcBot:ActionImmediate_Chat("Использую DemonZeal для отступления!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderTerrorWave()
    local ability = TerrorWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("scepter_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(radiusAbility), true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую TerrorWave что бы сбить заклинание цели!",true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            and not utility.IsDisabled(botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую TerrorWave для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TerrorWave для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSunder()
    local ability = Sunder;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local minimumHp = (ability:GetSpecialValueInt("hit_point_minimum_pct"));
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if enemy has more HP
    if (#enemyAbility > 0) and (HealthPercentage <= 0.2)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3)
            then
                --npcBot:ActionImmediate_Chat("Использую Sunder на врага со здоровьем ниже 30%!",true);
                return BOT_MODE_DESIRE_ABSOLUTE, enemy;
            end
        end
    end

    -- Try to safe ally
    if (#allyAbility > 1) and (HealthPercentage >= 0.3) and
        (not npcBot:WasRecentlyDamagedByAnyHero(2.0) and
            not npcBot:WasRecentlyDamagedByCreep(2.0) and
            not npcBot:WasRecentlyDamagedByTower(2.0))
    then
        for _, ally in pairs(allyAbility)
        do
            if (ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2)
                and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую Sunder на союзного героя со здоровьем ниже 20%!",true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end
