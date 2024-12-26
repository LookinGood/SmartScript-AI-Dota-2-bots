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
local npcBot = GetBot();
local Abilities, Talents, AbilitiesReal = ability_levelup_generic.GetHeroAbilities(npcBot)

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
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SmokeScreen = AbilitiesReal[1]
local BlinkStrike = AbilitiesReal[2]
local TricksOfTheTrade = AbilitiesReal[3]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSmokeScreenDesire, castSmokeScreenLocation = ConsiderSmokeScreen();
    local castBlinkStrikeDesire, castBlinkStrikeTarget = ConsiderBlinkStrike();
    local castTricksOfTheTradeDesire, castTricksOfTheTradeLocation = ConsiderTricksOfTheTrade();

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
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                if enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую SmokeScreen что бы сбить заклинание цели!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not npcBot:HasModifier("modifier_riki_tricks_of_the_trade_phase")
            then
                --npcBot:ActionImmediate_Chat("Использую SmokeScreen для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SmokeScreen для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
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
    local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("bonus_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike что бы добить врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_riki_tricks_of_the_trade_phase")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую  BlinkStrike по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local fountainLocation = utility.SafeLocation(npcBot);
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility) do
                    if ally ~= npcBot and GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на союзника!",true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на союзного крипа!",true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlinkStrike для побега на врага!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if (#enemyCreeps > 0)
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
end

function ConsiderTricksOfTheTrade()
    local ability = TricksOfTheTrade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
                and not utility.HaveReflectSpell(npcBot)
            then
                --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade что бы уклониться от снаряда!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, npcBot:GetLocation();
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() >= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end
