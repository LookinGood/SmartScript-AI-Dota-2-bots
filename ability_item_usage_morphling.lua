---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")
require(GetScriptDirectory() .. "/spell_usage_generic")

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
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[4],
    Abilities[4],
    Talents[4],
    Abilities[4],
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
local Waveform = npcBot:GetAbilityByName("morphling_waveform");
local AdaptiveStrikeAgility = npcBot:GetAbilityByName("morphling_adaptive_strike_agi");
--local AdaptiveStrikeStrength = npcBot:GetAbilityByName("morphling_adaptive_strike_str");
local AttributeShiftAgility = npcBot:GetAbilityByName("morphling_morph_agi");
local AttributeShiftStrength = npcBot:GetAbilityByName("morphling_morph_str");
local Morph = npcBot:GetAbilityByName("morphling_replicate");
--local MorphReplicate = npcBot:GetAbilityByName("morphling_morph_replicate");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();
    botStrenght = npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH);
    botAgility = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY);
    attributeDifference = math.floor((botAgility / botStrenght) * 100 - 100);
    --print(attributeDifference)

    local castWaveformDesire, castWaveformLocation = ConsiderWaveform();
    local castAdaptiveStrikeAgilityDesire, castAdaptiveStrikeAgilityTarget = ConsiderAdaptiveStrikeAgility();
    --local castAdaptiveStrikeStrengthDesire, castAdaptiveStrikeStrengthTarget = ConsiderAdaptiveStrikeStrength();
    local castAttributeShiftAgilityDesire = ConsiderAttributeShiftAgility();
    local castAttributeShiftStrengthDesire = ConsiderAttributeShiftStrength();
    --local castMorphDesire, castMorphTarget = ConsiderMorph();

    if (castWaveformDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Waveform, castWaveformLocation);
        return;
    end

    if (castAdaptiveStrikeAgilityDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(AdaptiveStrikeAgility, castAdaptiveStrikeAgilityTarget);
        return;
    end

    --[[     if (castAdaptiveStrikeStrengthDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(AdaptiveStrikeStrength, castAdaptiveStrikeStrengthTarget);
        return;
    end ]]

    if (castAttributeShiftAgilityDesire > 0)
    then
        npcBot:Action_UseAbility(AttributeShiftAgility);
        return;
    end

    if (castAttributeShiftStrengthDesire > 0)
    then
        npcBot:Action_UseAbility(AttributeShiftStrength);
        return;
    end

    if (castMorphDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Morph, castMorphTarget);
        return;
    end

    -- Dont work currect
    --[[     if npcBot:HasModifier("modifier_morphling_replicate_manager")
    then
        local ability1 = npcBot:GetAbilityInSlot(0);
        local ability2 = npcBot:GetAbilityInSlot(1);
        local ability3 = npcBot:GetAbilityInSlot(2);
        local ability4 = npcBot:GetAbilityInSlot(3);
        local ability5 = npcBot:GetAbilityInSlot(4);
        local ability6 = npcBot:GetAbilityInSlot(5);

        spell_usage_generic.CastCustomSpell(ability1)
        spell_usage_generic.CastCustomSpell(ability2)
        spell_usage_generic.CastCustomSpell(ability3)
        spell_usage_generic.CastCustomSpell(ability4)
        spell_usage_generic.CastCustomSpell(ability5)
        spell_usage_generic.CastCustomSpell(ability6)

        --if ability1:GetName() ~= "morphling_waveform" then spell_usage_generic.CastCustomSpell(ability1) end;
        --if ability2:GetName() ~= "morphling_adaptive_strike_agi" then spell_usage_generic.CastCustomSpell(ability2) end;
        --if ability3:GetName() ~= "morphling_adaptive_strike_str" then spell_usage_generic.CastCustomSpell(ability3) end;
        --if ability4:GetName() ~= "morphling_morph_agi" then spell_usage_generic.CastCustomSpell(ability4) end;
        --if ability5:GetName() ~= "morphling_morph_str" then spell_usage_generic.CastCustomSpell(ability5) end;
        --if ability6:GetName() ~= "morphling_morph_str" then spell_usage_generic.CastCustomSpell(ability6) end;
    end ]]

    --npcBot:HasModifier("modifier_morphling_replicate_manager")
    --print("СМорфом" .. ability1:GetName())
    --local ability1 = npcBot:GetAbilityInSlot(0);
    --print("БезМорфа" .. ability1:GetName())
end

function ConsiderWaveform()
    local ability = Waveform;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("width");
    local damageAbility = ability:GetAbilityDamage() +
        math.floor(npcBot:GetAttackDamage()) / 100 * ability:GetSpecialValueInt("pct_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Waveform что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot) and (#enemyAbility <= 0)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderAdaptiveStrikeAgility()
    local ability = AdaptiveStrikeAgility;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage_base") +
        (botAgility / 100 * ability:GetSpecialValueInt("damage_min"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AdaptiveStrikeAgility что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            then
                --npcBot:ActionImmediate_Chat("Использую AdaptiveStrikeAgility на " .. enemy:GetUnitName(), true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

--[[ function ConsiderAdaptiveStrikeStrength()
    local ability = AdaptiveStrikeStrength;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую AdaptiveStrikeStrength что бы сбить каст " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
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
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end ]]

function ConsiderAttributeShiftAgility()
    local ability = AttributeShiftAgility;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_morphling_morph_str")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local abilityRate = ability:GetSpecialValueInt("morph_rate_tooltip");

    if (ManaPercentage <= 0.2) or utility.RetreatMode(npcBot) or botStrenght <= abilityRate * 2
    then
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю AttributeShiftAgility (Мало маны)!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        return;
    end

    if attributeDifference < abilityRate * 2
    then
        if ability:GetToggleState() == false
        then
            --npcBot:ActionImmediate_Chat("Включаю AttributeShiftAgility (Недостаток ловкости)!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю AttributeShiftAgility (Ловкости достаточно)!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderAttributeShiftStrength()
    local ability = AttributeShiftStrength;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_morphling_morph_agi")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local abilityRate = ability:GetSpecialValueInt("morph_rate_tooltip");

    if (ManaPercentage < 0.1) or botAgility <= abilityRate / 2
    then
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю AttributeShiftStrength (Мало маны))!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        return;
    end

    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and HealthPercentage <= 0.5 and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Включаю AttributeShiftStrength (Отступаю)!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю AttributeShiftStrength (Отступаю без угрозы)!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю AttributeShiftStrength (Не отступаю)!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderMorph()
    local ability = Morph;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_morphling_replicate_manager")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    --print("Бот " .. botOffensivePower)

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                local botOffensivePower = npcBot:GetOffensivePower();
                local enemyOffensivePower = enemy:GetRawOffensivePower();
                --print("Враг " .. enemyOffensivePower)
                if enemyOffensivePower > botOffensivePower
                then
                    npcBot:ActionImmediate_Chat("Использую Morph на " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_MODERATE, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
