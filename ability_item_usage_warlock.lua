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
    Abilities[2],
    Abilities[1],
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
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local FatalBonds = AbilitiesReal[1]
local ShadowWord = AbilitiesReal[2]
local Upheaval = AbilitiesReal[3]
local ChaoticOffering = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFatalBondsDesire, castFatalBondsTarget = ConsiderFatalBonds();
    local castShadowWordDesire, castShadowWordTarget = ConsiderShadowWord();
    local castUpheavalDesire, castUpheavalLocation = ConsiderUpheaval();
    local castChaoticOfferingDesire, castChaoticOfferingLocation = ConsiderChaoticOffering();

    if (castFatalBondsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FatalBonds, castFatalBondsTarget);
        return;
    end

    if (castShadowWordDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ShadowWord, castShadowWordTarget);
        return;
    end

    if (castUpheavalDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Upheaval, castUpheavalLocation);
        return;
    end

    if (castChaoticOfferingDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ChaoticOffering, castChaoticOfferingLocation);
        return;
    end
end

--print(tostring(botTarget:GetName()))

function ConsiderFatalBonds()
    local ability = FatalBonds;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("search_aoe");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            local enemyHeroesAoe = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
            local enemyCreepsAoe = botTarget:GetNearbyCreeps(radiusAbility, false);
            if #enemyHeroesAoe > 1 or #enemyCreepsAoe >= ability:GetSpecialValueInt("count") / 2
            then
                --npcBot:ActionImmediate_Chat("Использую FatalBonds по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyCreeps) do
                local enemyCreepsAoe = enemy:GetNearbyCreeps(radiusAbility, false);
                if #enemyCreepsAoe >= ability:GetSpecialValueInt("count") / 2
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую FatalBonds на крипов!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (ManaPercentage >= 0.5)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
            local enemy = utility.GetWeakest(enemyAbility);
            if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_warlock_fatal_bonds")
            then
                local enemyHeroesAoe = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local enemyCreepsAoe = enemy:GetNearbyCreeps(radiusAbility, false);
                if #enemyHeroesAoe > 1 or #enemyCreepsAoe >= ability:GetSpecialValueInt("count") / 2
                then
                    --npcBot:ActionImmediate_Chat("Использую FatalBonds на лайне!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderShadowWord()
    local ability = ShadowWord;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("duration");
    local allyHeroes = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowWord что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast to heal ally hero
    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowWord на союзного героя со здоровьем ниже 80%", true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowWord по врагу в радиусе действия!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowWord по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderUpheaval()
    local ability = Upheaval;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("aoe");

    if utility.PvPMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        -- Cast if enemy hero immobilized
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.IsHero(enemy) and
                    utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Upheaval против обездвиженного врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end

        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Upheaval по врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderChaoticOffering()
    local ability = ChaoticOffering;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("aoe");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and not utility.IsDisabled(botTarget) and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.3)
            then
                --npcBot:ActionImmediate_Chat("Использую ChaoticOffering по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую ChaoticOffering по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChaoticOffering отступая!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end
end
