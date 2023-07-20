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
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
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
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    AcidSpray = AbilitiesReal[1]
    UnstableConcoction = AbilitiesReal[2]
    UnstableConcoctionThrow = npcBot:GetAbilityByName("alchemist_unstable_concoction_throw");
    BerserkPotion = AbilitiesReal[4]
    ChemicalRage = AbilitiesReal[6]

    castAcidSprayDesire, castAcidSprayLocation = ConsiderAcidSpray();
    castUnstableConcoctionDesire = ConsiderUnstableConcoction();
    castUnstableConcoctionThrowDesire, castUnstableConcoctionThrowTarget = ConsiderUnstableConcoctionThrow();
    castBerserkPotionDesire, castBerserkPotionTarget = ConsiderBerserkPotion();
    castChemicalRageDesire = ConsiderChemicalRage();

    if (castAcidSprayDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(AcidSpray, castAcidSprayLocation);
        return;
    end

    if (castUnstableConcoctionDesire ~= nil)
    then
        npcBot:Action_UseAbility(UnstableConcoction);
        return;
    end

    if (castUnstableConcoctionThrowDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(UnstableConcoctionThrow, castUnstableConcoctionThrowTarget);
        return;
    end

    if (castBerserkPotionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(BerserkPotion, castBerserkPotionTarget);
        return;
    end

    if (castChemicalRageDesire ~= nil)
    then
        npcBot:Action_UseAbility(ChemicalRage);
        return;
    end
end

function ConsiderAcidSpray()
    local ability = AcidSpray;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую AcidSpray по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую AcidSpray по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderUnstableConcoction()
    local ability = UnstableConcoction;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("max_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
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
                and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
            then
                --npcBot:ActionImmediate_Chat("Использую LightStrikeArray по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end
end

function ConsiderUnstableConcoctionThrow()
    local ability = UnstableConcoctionThrow;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("max_damage");
    local brewTime = ability:GetSpecialValueInt("brew_time");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/Interrup cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.PvPMode(npcBot)
                then
                    if (npcBot.idletime == nil)
                    then
                        npcBot.idletime = GameTime()
                    else
                        if (GameTime() - npcBot.idletime >= brewTime)
                        then
                            npcBot.idletime = nil
                            --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow что бы убить врага!", true);
                            return BOT_MODE_DESIRE_HIGH, enemy;
                        end
                    end
                end
                if enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow что бы сбить заклинание цели!", true);
                    return BOT_MODE_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.IsHero(botTarget)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and utility.SafeCast(botTarget, true) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if botTarget:GetHealth() / botTarget:GetMaxHealth() >= 0.2
            then
                if (npcBot.idletime == nil)
                then
                    npcBot.idletime = GameTime()
                else
                    if (GameTime() - npcBot.idletime >= brewTime)
                    then
                        npcBot.idletime = nil
                        --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow по врагу в радиусе действия!",true);
                        return BOT_MODE_DESIRE_HIGH, botTarget;
                    end
                end
            else
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_alchemist_unstable_concoction")
    then
        if not utility.IsValidTarget(botTarget) or GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow что бы не взорватся",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
    end
end

function ConsiderBerserkPotion()
    local ability = BerserkPotion;
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
            if utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.8
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(5.0) or
                    ally:WasRecentlyDamagedByTower(2.0) or
                    utility.IsHero(ally:GetAttackTarget())
                then
                    --npcBot:ActionImmediate_Chat("Использую BerserkPotion на союзника!", true);
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
                    if utility.IsHero(ally) and GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() * 2
                        or GetUnitToUnitDistance(ally, botTarget) > (ally:GetAttackRange() * 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BerserkPotion на союзника!", true);
                        return BOT_MODE_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
end

function ConsiderChemicalRage()
    local ability = ChemicalRage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 4
        then
            --npcBot:ActionImmediate_Chat("Использую ChemicalRage для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую ChemicalRage для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
