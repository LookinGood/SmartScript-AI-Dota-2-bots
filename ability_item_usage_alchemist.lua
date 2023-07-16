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
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую AcidSpray против врага!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if (ManaPercentage >= 0.8) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую AcidSpray по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AcidSpray по героям врага на линии!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderUnstableConcoction()
    local ability = UnstableConcoction;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("max_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/Interrup cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnInvulnerableTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_PHYSICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую UnstableConcoction что бы сбить заклинание цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
            then
                --npcBot:ActionImmediate_Chat("Использую UnstableConcoction против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую UnstableConcoction что бы оторваться от врага",true);
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
    local damageAbility = (ability:GetSpecialValueInt("max_damage"));
    local brewTime = (ability:GetSpecialValueInt("brew_time"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/Interrup cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnInvulnerableTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_PHYSICAL) and utility.PvPMode(npcBot)
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
    if botTarget ~= nil and utility.IsHero(botTarget)
    then
        if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
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
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую UnstableConcoctionThrow что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_alchemist_unstable_concoction")
    then
        if botTarget == nil or GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastOnInvulnerableTarget(enemy) and utility.SafeCast(enemy, true)
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
    local allyAbility = (GetUnitList(UNIT_LIST_ALLIED_HEROES));

    -- Cast if allys has negative effect or low HP
    if (#allyAbility > 0)
    then
        for i = 1, #allyAbility do
            if GetUnitToUnitDistance(allyAbility[i], npcBot) <= castRangeAbility
            then
                if utility.IsHero(allyAbility[i]) and allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.8
                then
                    if allyAbility[i]:WasRecentlyDamagedByAnyHero(2.0) or
                        allyAbility[i]:WasRecentlyDamagedByCreep(5.0) or
                        allyAbility[i]:WasRecentlyDamagedByTower(2.0) or
                        utility.IsHero(allyAbility[i]:GetAttackTarget())
                    then
                        --npcBot:ActionImmediate_Chat("Использую BerserkPotion на союзника!", true);
                        return BOT_MODE_DESIRE_HIGH, allyAbility[i];
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget)
        then
            for i = 1, #allyAbility do
                if allyAbility[i] ~= nil and GetUnitToUnitDistance(allyAbility[i], npcBot) <= (castRangeAbility + 200)
                then
                    if GetUnitToUnitDistance(allyAbility[i], botTarget) <= allyAbility[i]:GetAttackRange() * 2
                        or GetUnitToUnitDistance(allyAbility[i], botTarget) > (allyAbility[i]:GetAttackRange() * 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BerserkPotion на союзника рядом с врагом!",true);
                        return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i];
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
        if botTarget ~= nil and utility.CanCastOnInvulnerableTarget(botTarget) and utility.IsHero(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 4
        then
            --npcBot:ActionImmediate_Chat("Использую ChemicalRage для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую ChemicalRage для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
