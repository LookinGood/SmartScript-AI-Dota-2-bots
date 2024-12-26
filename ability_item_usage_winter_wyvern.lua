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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
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
local ArcticBurn = AbilitiesReal[1]
local SplinterBlast = AbilitiesReal[2]
local ColdEmbrace = AbilitiesReal[3]
local WintersCurse = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castArcticBurnDesire = ConsiderArcticBurn();
    local castSplinterBlastDesire, castSplinterBlastTarget = ConsiderSplinterBlast();
    local castColdEmbraceDesire, castColdEmbraceTarget = ConsiderColdEmbrace();
    local castWintersCurseDesire, castWintersCurseTarget = ConsiderWintersCurse();

    if (castArcticBurnDesire ~= nil)
    then
        npcBot:Action_UseAbility(ArcticBurn);
        return;
    end

    if (castSplinterBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SplinterBlast, castSplinterBlastTarget);
        return;
    end

    if (castColdEmbraceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ColdEmbrace, castColdEmbraceTarget);
        return;
    end

    if (castWintersCurseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WintersCurse, castWintersCurseTarget);
        return;
    end
end

function ConsiderArcticBurn()
    local ability = ArcticBurn;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = npcBot:GetAttackRange() + ability:GetSpecialValueInt("attack_range_bonus");

    -- Off ability
    if not utility.PvPMode(npcBot) and npcBot:TimeSinceDamagedByAnyHero() >= 5.0
    then
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
        then
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю ArcticBurn!", true);
                return BOT_ACTION_DESIRE_HIGH;
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
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
                then
                    if ability:GetToggleState() == false and (ManaPercentage >= 0.2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ArcticBurn для нападения С АГАНИМОМ!",true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                else
                    --npcBot:ActionImmediate_Chat("Использую ArcticBurn для нападения без аганима!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
            then
                if ability:GetToggleState() == false
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcticBurn для ОТСТУПЛЕНИЯ С АГАНИМОМ!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            else
                --npcBot:ActionImmediate_Chat("Использую ArcticBurn для ОТСТУПЛЕНИЯ без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderSplinterBlast()
    local ability = SplinterBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local radiusAbility = ability:GetSpecialValueInt("split_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
            then
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#enemyHeroAround > 1)
                then
                    for _, enemyHero in pairs(enemyHeroAround) do
                        if enemyHero ~= enemy and utility.CanCastSpellOnTarget(ability, enemyHero)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на героя что бы добить врага!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemyHero;
                        end
                    end
                end
                if (#enemyCreepsAround > 0)
                then
                    for _, enemyCreep in pairs(enemyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, enemyCreep)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа что бы добить врага!", true);
                            return BOT_ACTION_DESIRE_HIGH, enemyCreep;
                        end
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreepsAround = botTarget:GetNearbyCreeps(radiusAbility, false);
            if (#enemyHeroAround > 1)
            then
                for _, enemy in pairs(enemyHeroAround) do
                    if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского героя рядом с целью!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if (#enemyCreepsAround > 0)
            then
                for _, enemy in pairs(enemyCreepsAround) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского крипа рядом с целью!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа для ПУША!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#enemyHeroAround > 1)
                then
                    for _, enemyHero in pairs(enemyHeroAround) do
                        if enemyHero ~= enemy and utility.CanCastSpellOnTarget(ability, enemyHero)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на героя для отхода!", true);
                            return BOT_ACTION_DESIRE_HIGH, enemyHero;
                        end
                    end
                end
                if (#enemyCreepsAround > 0)
                then
                    for _, enemyCreep in pairs(enemyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, enemyCreep)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа для отхода!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemyCreep;
                        end
                    end
                end
            end
        end
    end
end

function ConsiderColdEmbrace()
    local ability = ColdEmbrace;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use on allied heroes
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and not ally:IsChanneling()
            then
                if utility.IsDisabled(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and ally:WasRecentlyDamagedByAnyHero(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на союзника в стане!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                elseif (ally:GetHealth() / ally:GetMaxHealth() <= 0.4)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на союзнике со здоровьем 40%!",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderWintersCurse()
    local ability = WintersCurse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
        then
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            if (#enemyHeroAround > 2)
            then
                --npcBot:ActionImmediate_Chat("Использую WintersCurse на вражеских героев!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.IsValidTarget(enemy)
                    then
                        local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                        if (#enemyHeroAround > 1)
                        then
                            --npcBot:ActionImmediate_Chat("Использую WintersCurse для отхода!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
    end
end
