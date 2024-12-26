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
    Talents[5],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local OverwhelmingOdds = AbilitiesReal[1]
local PressTheAttack = AbilitiesReal[2]
local Duel = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castOverwhelmingOddsDesire = ConsiderOverwhelmingOdds();
    local castPressTheAttackDesire, castPressTheAttackTarget, castPressTheAttackTargetType = ConsiderPressTheAttack();
    local castDuelDesire, castDuelTarget = ConsiderDuel();

    if (castOverwhelmingOddsDesire ~= nil)
    then
        npcBot:Action_UseAbility(OverwhelmingOdds);
        return;
    end

    if (castPressTheAttackDesire ~= nil)
    then
        if (castPressTheAttackTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(PressTheAttack, castPressTheAttackTarget);
            return;
        elseif (castPressTheAttackTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(PressTheAttack, castPressTheAttackTarget);
            return;
        end
    end

    if (castDuelDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Duel, castDuelTarget);
        return;
    end
end

function ConsiderOverwhelmingOdds()
    local ability = OverwhelmingOdds;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyCreepsAbility = npcBot:GetNearbyCreeps(radiusAbility, true);
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
    local damageForCreep = ability:GetSpecialValueInt("damage_per_unit");
    local damageForHero = ability:GetSpecialValueInt("damage_per_hero");
    local damageAbility = (#enemyCreepsAbility * damageForCreep) + (#enemyAbility * damageForHero);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую OverwhelmingOdds что бы добить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую OverwhelmingOdds для нападения!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Boss use
        if utility.IsBoss(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую OverwhelmingOdds против Рошана!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую OverwhelmingOdds против крипов",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderPressTheAttack()
    local ability = PressTheAttack;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            -- Heal ally
            if utility.IsHero(ally) and not ally:HasModifier("modifier_legion_commander_press_the_attack")
            then
                if ((ally:WasRecentlyDamagedByAnyHero(2.0) or
                            ally:WasRecentlyDamagedByCreep(2.0) or
                            ally:WasRecentlyDamagedByTower(2.0))
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)) or (utility.IsDisabled(ally))
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PressTheAttack для лечения по цели!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PressTheAttack для лечения по области!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0),
                            "location";
                    end
                end
                -- Buff Ally attack
                if utility.PvPMode(npcBot)
                then
                    if utility.IsHero(botTarget)
                    then
                        if (#allyAbility > 0)
                        then
                            for _, ally in pairs(allyAbility)
                            do
                                if not utility.IsHaveMaxSpeed(ally) and not utility.IsDisabled(ally)
                                then
                                    if utility.IsHero(ally) and GetUnitToUnitDistance(ally, botTarget) > ally:GetAttackRange()
                                        and GetUnitToUnitDistance(ally, botTarget) <= 1600
                                    then
                                        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                                        then
                                            --npcBot:ActionImmediate_Chat("Использую PressTheAttack для атаки по цели!",  true);
                                            return BOT_ACTION_DESIRE_HIGH, ally, "target";
                                        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                                        then
                                            --npcBot:ActionImmediate_Chat("Использую PressTheAttack для атаки по области!", true);
                                            return BOT_ACTION_DESIRE_HIGH,
                                                utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0),
                                                "location";
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end

function ConsiderDuel()
    local ability = Duel;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Duel что бы сбить заклинание!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:IsDisarmed()
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:IsDominated() and not botTarget:IsAttackImmune() and botTarget:GetHealth() < npcBot:GetHealth()
            then
                --npcBot:ActionImmediate_Chat("Использую Duel по цели!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Cast if enemy >=2
        if (#enemyAbility > 1)
        then
            local weakestEnemyHero = utility.GetWeakest(enemyAbility);
            if utility.CanCastSpellOnTarget(ability, weakestEnemyHero) and not weakestEnemyHero:IsDominated() and not weakestEnemyHero:IsAttackImmune()
                and weakestEnemyHero:GetHealth() <= npcBot:GetHealth()
            then
                --npcBot:ActionImmediate_Chat("Использую Duel по слабейшей цели!", true);
                return BOT_ACTION_DESIRE_HIGH, weakestEnemyHero;
            end
        end
    end
end
