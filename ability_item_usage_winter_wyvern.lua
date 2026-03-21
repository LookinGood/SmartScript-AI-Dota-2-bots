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
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
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
local ArcticBurn = npcBot:GetAbilityByName("winter_wyvern_arctic_burn");
local SplinterBlast = npcBot:GetAbilityByName("winter_wyvern_splinter_blast");
local ColdEmbrace = npcBot:GetAbilityByName("winter_wyvern_cold_embrace");
local WintersCurse = npcBot:GetAbilityByName("winter_wyvern_winters_curse");

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

    if (castArcticBurnDesire > 0)
    then
        npcBot:Action_UseAbility(ArcticBurn);
        return;
    end

    if (castSplinterBlastDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(SplinterBlast, castSplinterBlastTarget);
        return;
    end

    if (castColdEmbraceDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(ColdEmbrace, castColdEmbraceTarget);
        return;
    end

    if (castWintersCurseDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(WintersCurse, castWintersCurseTarget);
        return;
    end
end

function ConsiderArcticBurn()
    local ability = ArcticBurn;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local castRangeAbility = npcBot:GetAttackRange() + ability:GetSpecialValueInt("attack_range_bonus");

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
    then
        if npcBot:GetMana() < ability:GetManaCost() + (ability:GetSpecialValueInt("mana_cost_scepter") * 2)
        then
            if ability:GetToggleState() == false
            then
                return BOT_ACTION_DESIRE_NONE;
            else
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Off ability
    if not utility.PvPMode(npcBot) and not utility.BossMode(npcBot) and npcBot:TimeSinceDamagedByAnyHero() > 5.0
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
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_TOGGLE)
                then
                    if ability:GetToggleState() == false
                    then
                        if npcBot:GetManaRegen() >= 20
                        then
                            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility * 2
                            then
                                --npcBot:ActionImmediate_Chat("Использую ArcticBurn-Аганим с регеном маны!", true);
                                return BOT_ACTION_DESIRE_HIGH;
                            end
                        else
                            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                            then
                                --npcBot:ActionImmediate_Chat("Использую ArcticBurn-Аганим без регена маны!", true);
                                return BOT_ACTION_DESIRE_HIGH;
                            end
                        end
                    end
                else
                    if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую ArcticBurn для нападения без аганима!",true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and utility.BotWasRecentlyDamagedByEnemyHero(5.0)
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

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSplinterBlast()
    local ability = SplinterBlast;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
                local allyHeroAround = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                local allyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, true);
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#allyHeroAround > 0)
                then
                    for _, ally in pairs(allyHeroAround) do
                        if ally ~= npcBot and utility.CanCastSpellOnTarget(ability, ally)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на союзного героя " .. ally:GetUnitName() .. " добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
                if (#allyCreepsAround > 0)
                then
                    for _, ally in pairs(allyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, ally)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на союзного крипа " .. ally:GetUnitName() .. " добивая " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
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
                    for _, enemy in pairs(enemyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа что бы добить врага!", true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            local allyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            local allyCreepsAround = botTarget:GetNearbyCreeps(radiusAbility, true);
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreepsAround = botTarget:GetNearbyCreeps(radiusAbility, false);
            if (#allyHeroAround > 0)
            then
                for _, ally in pairs(allyHeroAround) do
                    if ally ~= npcBot and utility.CanCastSpellOnTarget(ability, ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на союзного героя " .. ally:GetUnitName() .. " атакуя " .. botTarget:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreepsAround > 0)
            then
                for _, ally in pairs(allyCreepsAround) do
                    if utility.CanCastSpellOnTarget(ability, ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat( "Использую SplinterBlast на союзного крипа " .. ally:GetUnitName() .. " атакуя " .. botTarget:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#enemyHeroAround > 1)
            then
                for _, enemy in pairs(enemyHeroAround) do
                    if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского героя рядом с целью!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if (#enemyCreepsAround > 0)
            then
                for _, enemy in pairs(enemyCreepsAround) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского крипа рядом с целью!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot)
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                local allyHeroAround = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                local allyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, true);
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#allyHeroAround > 0)
                then
                    for _, ally in pairs(allyHeroAround) do
                        if ally ~= npcBot and utility.CanCastSpellOnTarget(ability, ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на союзного героя " .. ally:GetUnitName() .. " отступая от " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
                if (#allyCreepsAround > 0)
                then
                    for _, ally in pairs(allyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на союзного крипа " .. ally:GetUnitName() .. " отступая от " .. enemy:GetUnitName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
                if (#enemyHeroAround > 1)
                then
                    for _, enemyHero in pairs(enemyHeroAround) do
                        if enemyHero ~= enemy and utility.CanCastSpellOnTarget(ability, enemyHero) and GetUnitToUnitDistance(npcBot, enemyHero) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на героя для отхода!", true);
                            return BOT_ACTION_DESIRE_HIGH, enemyHero;
                        end
                    end
                end
                if (#enemyCreepsAround > 0)
                then
                    for _, enemy in pairs(enemyCreepsAround) do
                        if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа для отхода!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderColdEmbrace()
    local ability = ColdEmbrace;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local canCastOnBuildings = ability:GetSpecialValueInt("can_target_buildings");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use on allied heroes
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:IsChanneling()
            then
                if (ally:GetHealth() / ally:GetMaxHealth() <= 0.4) and utility.CanBeHeal(ally)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на союзнике со здоровьем 40%!",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
                if utility.IsDisabled(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на союзника в стане!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end

    if canCastOnBuildings == 1
    then
        -- Cast to buff ally buildings
        local allyTowers = npcBot:GetNearbyTowers(castRangeAbility, false);
        local allyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, false);
        local allyAncient = GetAncient(GetTeam());
        if (#allyTowers > 0)
        then
            for _, ally in pairs(allyTowers)
            do
                if not ally:HasModifier("modifier_winter_wyvern_cold_embrace") and utility.IsTargetedByEnemy(ally, true)
                    and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на башню " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
        if (#allyBarracks > 0)
        then
            for _, ally in pairs(allyBarracks)
            do
                if not ally:HasModifier("modifier_winter_wyvern_cold_embrace") and utility.IsTargetedByEnemy(ally, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на казармы " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
        if GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility
        then
            if not allyAncient:HasModifier("modifier_winter_wyvern_cold_embrace") and utility.IsTargetedByEnemy(allyAncient, true)
            then
                --npcBot:ActionImmediate_Chat("Использую ColdEmbrace на древнего " .. allyAncient:GetUnitName(), true);
                return BOT_ACTION_DESIRE_HIGH, allyAncient;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWintersCurse()
    local ability = WintersCurse;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not utility.IsDisabled(botTarget)
        then
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            if (#enemyHeroAround > 2)
            then
                --npcBot:ActionImmediate_Chat("Использую WintersCurse на вражеских героев!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.IsHero(enemy) and not not utility.IsDisabled(enemy)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end
