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
    Abilities[5],
    Abilities[4],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[5],
    Abilities[5],
    Talents[2],
    Abilities[5],
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
local BerserkersRage = AbilitiesReal[1]
local WhirlingAxesMissle = AbilitiesReal[2]
local WhirlingAxesMelee = AbilitiesReal[3]
local BattleTrance = AbilitiesReal[6]

local castBerserkersRageTimer = 0.0;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBerserkersRageDesire = ConsiderBerserkersRage();
    local castWhirlingAxesMissleDesire, castWhirlingAxesMissleLocation = ConsiderWhirlingAxesMissle();
    local castWhirlingAxesMeleeDesire = ConsiderWhirlingAxesMelee();
    local castBattleTranceDesire = ConsiderBattleTrance();

    if (castBerserkersRageDesire ~= nil) and (DotaTime() >= castBerserkersRageTimer + 2.0)
    then
        npcBot:Action_UseAbility(BerserkersRage);
        castBerserkersRageTimer = DotaTime();
        return;
    end

    if (castWhirlingAxesMissleDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WhirlingAxesMissle, castWhirlingAxesMissleLocation);
        return;
    end

    if (castWhirlingAxesMeleeDesire ~= nil)
    then
        npcBot:Action_UseAbility(WhirlingAxesMelee);
        return;
    end

    if (castBattleTranceDesire ~= nil)
    then
        npcBot:Action_UseAbility(BattleTrance);
        return;
    end
end

function ConsiderBerserkersRage()
    local ability = BerserkersRage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --[[     if ability:GetToggleState() == false
    then
        attackRange = npcBot:GetAttackRange();
    else
        attackRange = npcBot:GetAttackRange() + ability:GetSpecialValueInt("bonus_range");
    end ]]

    --local attackTarget = npcBot:GetAttackTarget();
    local attackRangeMelee = 150;
    local attackRangeMissle = attackRangeMelee + ability:GetSpecialValueInt("bonus_range");

    -- Generic use
    if utility.CanCastOnInvulnerableTarget(botTarget)
    then
        if GetUnitToUnitDistance(npcBot, botTarget) <= attackRangeMissle and GetUnitToUnitDistance(npcBot, botTarget) > attackRangeMelee
        then
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю BerserkersRage для атаки в дальнем бою!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        elseif GetUnitToUnitDistance(npcBot, botTarget) <= attackRangeMelee
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю BerserkersRage для атаки в мили!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю BerserkersRage цель не в диапазоне!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == false
        then
            --npcBot:ActionImmediate_Chat("Включаю BerserkersRage по умолчанию!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderWhirlingAxesMissle()
    local ability = WhirlingAxesMissle;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("axe_width");
    local damageAbility = ability:GetSpecialValueInt("axe_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("axe_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WhirlingAxesMissle что бы убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderWhirlingAxesMelee()
    local ability = WhirlingAxesMelee;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("max_range");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WhirlingAxesMelee что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderBattleTrance()
    local ability = BattleTrance;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_troll_warlord_battle_trance") or npcBot:IsDisarmed()
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("range");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BattleTrance против 2+ врагов!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnInvulnerableTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BattleTrance при побеге!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end
end
