---@diagnostic disable: undefined-global, redefined-local
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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[3],
    Abilities[1],
    Abilities[6],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    SmokeScreen = AbilitiesReal[1]
    BlinkStrike = AbilitiesReal[2]
    TricksOfTheTrade = AbilitiesReal[3]

    castSmokeScreenDesire, castSmokeScreenLocation = ConsiderSmokeScreen();
    castBlinkStrikeDesire, castBlinkStrikeTarget = ConsiderBlinkStrike();
    castTricksOfTheTradeDesire, castTricksOfTheTradeLocation = ConsiderTricksOfTheTrade();

    if (castSmokeScreenDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SmokeScreen, castSmokeScreenLocation);
        return;
    end

    if (castBlinkStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(BlinkStrike, castBlinkStrikeTarget);
        return;
    end

    if (castTricksOfTheTradeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TricksOfTheTrade, castTricksOfTheTradeLocation);
        return;
    end
end

function ConsiderSmokeScreen()
    local ability = SmokeScreen;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую SmokeScreen что бы сбить заклинание цели!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnMagicImmuneTarget(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and utility.IsHero(botTarget) and not npcBot:HasModifier("modifier_riki_tricks_of_the_trade_phase")
        then
            --npcBot:ActionImmediate_Chat("Использую SmokeScreen для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую SmokeScreen для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and (ManaPercentage >= 0.4)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую SmokeScreen на Рошана!", true);
                return BOT_MODE_DESIRE_MODERATE, botTarget:GetLocation();
            end
        end
    end
end

function ConsiderBlinkStrike()
    local ability = BlinkStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local attackDamage = npcBot:GetAttackDamage();
    local bonusDamageAbility = (ability:GetSpecialValueInt("bonus_damage"));
    local damageAbility = attackDamage + bonusDamageAbility;
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnInvulnerableTarget(enemy) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                and utility.SafeCast(botTarget, true)
            then
                --npcBot:ActionImmediate_Chat("Использую BlinkStrike что бы добить врага!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and GetUnitToUnitDistance(npcBot, botTarget) > attackRange and utility.IsHero(botTarget) and utility.SafeCast(botTarget, true)
            and not npcBot:HasModifier("modifier_riki_tricks_of_the_trade_phase")
        then
            --npcBot:ActionImmediate_Chat("Использую  BlinkStrike по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT and (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
        local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        local fountainLocation = utility.SafeLocation(npcBot);
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility) do
                if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2) and ally ~= npcBot
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на союзника!",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        elseif (#allyCreeps > 0)
        then
            for _, ally in pairs(allyCreeps) do
                if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на союзного крипа!",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        elseif (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на врага!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        elseif (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                    (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на вражеского крипа!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderTricksOfTheTrade()
    local ability = TricksOfTheTrade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade что бы уклониться от снаряда!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, npcBot:GetLocation();
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnInvulnerableTarget(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and utility.IsHero(botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() >= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end