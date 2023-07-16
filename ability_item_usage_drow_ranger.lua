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
        npcBot:Action_UseAbilityOnLocation(Multishot, castMultishotLocation);
        --return;
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

    if attackTarget ~= nil and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)
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
end

function ConsiderGust()
    local ability = Gust;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
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
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget)
            and not botTarget:IsSilenced() and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
        then
            --npcBot:ActionImmediate_Chat("Использую Gust для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
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
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
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

    local castRangeAbility = (npcBot:GetAttackRange() * 1.75);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
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
                if utility.CanCastOnInvulnerableTarget(enemy)
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
        if attackTarget ~= nil and utility.IsHero(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую Glacier для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
