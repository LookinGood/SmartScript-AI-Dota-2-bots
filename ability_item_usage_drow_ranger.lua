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
    Abilities[3],
    Abilities[2],
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
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local FrostArrows = AbilitiesReal[1]
local Gust = AbilitiesReal[2]
local Multishot = AbilitiesReal[3]
local Glacier = AbilitiesReal[4]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    ConsiderFrostArrows();
    local castGustDesire, castGustLocation = ConsiderGust();
    local castMultishotDesire, castMultishotLocation = ConsiderMultishot();
    local castGlacierDesire = ConsiderGlacier();

    if (castGustDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Gust, castGustLocation);
        return;
    end

    if (castMultishotDesire ~= nil)
    then
        npcBot:Action_ClearActions(true);
        --npcBot:ActionQueue_Delay(1.0);
        npcBot:ActionQueue_UseAbilityOnLocation(Multishot, castMultishotLocation);
        return;
    end

    if (castGlacierDesire ~= nil)
    then
        npcBot:Action_UseAbility(Glacier);
        return;
    end
end

function ConsiderFrostArrows()
    local ability = FrostArrows;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if (utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)) and utility.CanCastSpellOnTarget(ability, attackTarget)
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end
end

function ConsiderGust()
    local ability = Gust;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("wave_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Interrupt cast/Detect invisible
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if enemy:IsChanneling() or enemy:IsInvisible()
                then
                    --npcBot:ActionImmediate_Chat("Использую Gust что бы сбить заклинание цели/Или по невидимому врагу!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not botTarget:IsSilenced() and not utility.IsDisabled(botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую Gust для нападения!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Gust для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end

function ConsiderMultishot()
    local ability = Multishot;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = npcBot:GetAttackRange() * ability:GetSpecialValueInt("arrow_range_multiplier");
    local radiusAbility = ability:GetSpecialValueInt("arrow_width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("arrow_speed");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Multishot для нападения!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Multishot по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif npcBot:GetActiveMode() == BOT_MODE_LANING
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Multishot для лайнинга!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end

function ConsiderGlacier()
    local ability = Glacier;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую Glacier для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
