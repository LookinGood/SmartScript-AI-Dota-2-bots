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
local Talents = {}
local Abilities = {}
local npcBot = GetBot();

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

    ArcticBurn = AbilitiesReal[1]
    SplinterBlast = AbilitiesReal[2]
    ColdEmbrace = AbilitiesReal[3]
    WintersCurse = AbilitiesReal[6]

    castArcticBurnDesire = ConsiderArcticBurn();
    castSplinterBlastDesire, castSplinterBlastTarget = ConsiderSplinterBlast();
    castColdEmbraceDesire, castColdEmbraceTarget = ConsiderColdEmbrace();
    castWintersCurseDesire, castWintersCurseTarget = ConsiderWintersCurse();

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

    local castRangeAbility = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));

    -- Off ability
    if not utility.PvPMode(npcBot) and npcBot:TimeSinceDamagedByAnyHero() >= 5.0
    then
        if npcBot:HasScepter()
        then
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю ArcticBurn!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) 
        and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if not npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую ArcticBurn для нападения без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH;
            elseif npcBot:HasScepter()
            then
                if ability:GetToggleState() == false and (ManaPercentage >= 0.2)
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcticBurn для нападения С АГАНИМОМ!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            if not npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую ArcticBurn для ОТСТУПЛЕНИЯ без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH;
            elseif npcBot:HasScepter()
            then
                if ability:GetToggleState() == false
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcticBurn для ОТСТУПЛЕНИЯ С АГАНИМОМ!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
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
    local damageAbility = (ability:GetSpecialValueInt("damage"));
    local radiusAbility = (ability:GetSpecialValueInt("split_radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) and utility.CanCastOnMagicImmuneTarget(enemy)
            then
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#enemyHeroAround > 1)
                then
                    for _, enemyHero in pairs(enemyHeroAround) do
                        if enemyHero ~= enemy and utility.CanCastOnMagicImmuneTarget(enemyHero)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на героя что бы добить врага!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemyHero;
                        end
                    end
                end
                if (#enemyCreepsAround > 0)
                then
                    for _, enemyCreep in pairs(enemyCreepsAround) do
                        if utility.CanCastOnMagicImmuneTarget(enemyCreep)
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
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
        then
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreepsAround = botTarget:GetNearbyCreeps(radiusAbility, false);
            if (#enemyHeroAround > 1)
            then
                for _, enemy in pairs(enemyHeroAround) do
                    if enemy ~= botTarget and utility.CanCastOnMagicImmuneTarget(enemy) and GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                        and utility.SafeCast(enemy, false)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского героя рядом с целью!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if (#enemyCreepsAround > 0)
            then
                for _, enemy in pairs(enemyCreepsAround) do
                    if enemy ~= botTarget and utility.CanCastOnMagicImmuneTarget(enemy) and GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                        and utility.SafeCast(enemy, false)
                    then
                        --npcBot:ActionImmediate_Chat("Использую SplinterBlast на вражеского крипа рядом с целью!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.5)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SplinterBlast на крипа для ПУША!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#enemyHeroAround > 1)
                then
                    for _, enemyHero in pairs(enemyHeroAround) do
                        if enemyHero ~= enemy and utility.CanCastOnMagicImmuneTarget(enemyHero)
                        then
                            --npcBot:ActionImmediate_Chat("Использую SplinterBlast на героя для отхода!", true);
                            return BOT_ACTION_DESIRE_HIGH, enemyHero;
                        end
                    end
                end
                if (#enemyCreepsAround > 0)
                then
                    for _, enemyCreep in pairs(enemyCreepsAround) do
                        if utility.CanCastOnMagicImmuneTarget(enemyCreep)
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
                if utility.IsDisabled(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.5) and ally:WasRecentlyDamagedByAnyHero(2.0)
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
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen()
            and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
        then
            local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            if (#enemyHeroAround > 2)
            then
                --npcBot:ActionImmediate_Chat("Использую WintersCurse на вражеских героев!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if enemy:CanBeSeen()
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
