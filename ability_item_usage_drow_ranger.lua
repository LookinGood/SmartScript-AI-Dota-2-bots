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
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
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

    FrostArrows = AbilitiesReal[1]
    Gust = AbilitiesReal[2]
    Multishot = AbilitiesReal[3]
    Glacier = AbilitiesReal[4]

    ConsiderFrostArrows();
    castGustDesire, castGustLocation = ConsiderGust();
    castMultishotDesire, castMultishotLocation = ConsiderMultishot();
    castGlacierDesire = ConsiderGlacier();

    if (castGustDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Gust, castGustLocation);
        return;
    end

    if (castMultishotDesire ~= nil)
    then
        npcBot:Action_ClearActions(false);
        npcBot:ActionQueue_Delay(0.5);
        npcBot:ActionQueue_UseAbilityOnLocation(Multishot, castMultishotLocation);
        --npcBot:Action_UseAbilityOnLocation(Multishot, castMultishotLocation);
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

    if (utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)) and utility.CanCastSpellOnTarget(ability, attackTarget)
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
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Interrupt cast/Detect invisible
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if enemy:IsChanneling() or enemy:IsInvisible()
                then
                    --npcBot:ActionImmediate_Chat("Использую Gust что бы сбить заклинание цели/Или по невидимому врагу!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not botTarget:IsSilenced() and not utility.IsDisabled(botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую Gust для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Gust для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility);
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

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Multishot для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
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
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
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
