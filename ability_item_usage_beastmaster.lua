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
    Abilities[4],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[4],
    Abilities[4],
    Talents[3],
    Abilities[4],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local WildAxes = AbilitiesReal[1]
local SummonBoar = AbilitiesReal[2]
local SummonHawk = AbilitiesReal[3]
local InnerBeast = npcBot:GetAbilityByName("beastmaster_inner_beast");
local DrumsOfSlom = AbilitiesReal[5]
local PrimalRoar = AbilitiesReal[6]
--SummonBoar = npcBot:GetAbilityByName("beastmaster_call_of_the_wild_boar");
--SummonHawk = npcBot:GetAbilityByName("beastmaster_call_of_the_wild_hawk");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castWildAxesDesire, castWildAxesLocation = ConsiderWildAxes();
    local castSummonBoarDesire = ConsiderSummonBoar();
    local castSummonHawkDesire = ConsiderSummonHawk();
    local castInnerBeastDesire = ConsiderInnerBeast();
    local castDrumsOfSlomDesire = ConsiderDrumsOfSlom();
    local castPrimalRoarDesire, castPrimalRoarTarget = ConsiderPrimalRoar();

    if (castWildAxesDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(WildAxes, castWildAxesLocation);
        return;
    end

    if (castSummonBoarDesire > 0)
    then
        npcBot:Action_UseAbility(SummonBoar);
        return;
    end

    if (castSummonHawkDesire > 0)
    then
        npcBot:Action_UseAbility(SummonHawk);
        return;
    end

    if (castInnerBeastDesire > 0)
    then
        npcBot:Action_UseAbility(InnerBeast);
        return;
    end

    if (castDrumsOfSlomDesire > 0)
    then
        npcBot:Action_UseAbility(DrumsOfSlom);
        return;
    end

    if (castPrimalRoarDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(PrimalRoar, castPrimalRoarTarget);
        return;
    end
end

function ConsiderWildAxes()
    local ability = WildAxes;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("axe_damage") * 2;
    local delayAbility = ability:GetSpecialValueInt("min_throw_duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую WildAxes по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую WildAxes по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSummonBoar()
    local ability = SummonBoar;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Cast if push/defend/farm/roshan
    if utility.PvEMode(npcBot)
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

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSummonHawk()
    local ability = SummonHawk;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SummonHawk против врага в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderInnerBeast()
    local ability = InnerBeast;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_beastmaster_inner_beast_berserk")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)
        then
            if utility.CanCastSpellOnTarget(ability, attackTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую InnerBeast на врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    if utility.PvEMode(npcBot)
    then
        if (ManaPercentage >= 0.5) and attackTarget:IsAncientCreep() and utility.CanCastSpellOnTarget(ability, attackTarget)
            and (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую InnerBeast на крипа!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDrumsOfSlom()
    local ability = DrumsOfSlom;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack or retreat use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Drums Of Slom по врагу в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderPrimalRoar()
    local ability = PrimalRoar;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WraithfireBlast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

--[[ OLD VERSION
function ConsiderSummonHawk()
    local ability = SummonHawk;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Use for exploration
    if not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT
    then
        local neutralCreeps = npcBot:GetNearbyNeutralCreeps(castRangeAbility);
        if (#neutralCreeps > 0) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(neutralCreeps) do
                if utility.IsValidTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Summon Hawk для разведки!", true);
                    return BOT_ACTION_DESIRE_VERYLOW, enemy:GetLocation();
                end
            end
        end
    end

    if ability:GetBehavior() == ABILITY_BEHAVIOR_AUTOCAST
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast();
        end
    end

    if ability:GetAutoCastState()
    then
        if utility.PvPMode(npcBot)
        then
            if utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)
            then
                npcBot:ActionImmediate_Chat("Использую Summon Hawk по врагу в радиусе действия!",
                    true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            end
            -- Use if need retreat
        elseif botMode == BOT_MODE_RETREAT
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy))
                    then
                        npcBot:ActionImmediate_Chat("Использую Summon Hawk что бы оторваться от врага!",
                            true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end ]]
