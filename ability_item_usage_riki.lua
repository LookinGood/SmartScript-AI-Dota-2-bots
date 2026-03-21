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
    Talents[4],
    Abilities[1],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SmokeScreen = npcBot:GetAbilityByName("riki_smoke_screen");
local BlinkStrike = npcBot:GetAbilityByName("riki_blink_strike");
local Backstab = npcBot:GetAbilityByName("riki_innate_backstab");
local TricksOfTheTrade = npcBot:GetAbilityByName("riki_tricks_of_the_trade");

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

    if (castSmokeScreenDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(SmokeScreen, castSmokeScreenLocation);
        return;
    end

    if (castBlinkStrikeDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(BlinkStrike, castBlinkStrikeTarget);
        return;
    end

    if (castTricksOfTheTradeDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(TricksOfTheTrade, castTricksOfTheTradeLocation);
        return;
    end

    if not npcBot:WasRecentlyDamagedByAnyHero(5.0) and not npcBot:WasRecentlyDamagedByTower(5.0)
    then
        if not utility.IsBusy(npcBot) and utility.IsValidTarget(botTarget) and not utility.IsAlly(npcBot, botTarget) and not botTarget:IsBuilding()
            and botTarget:GetAttackTarget() ~= npcBot
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAcquisitionRange()
            then
                local backstabAngle = Backstab:GetSpecialValueInt("backstab_angle");
                local halfAngle = backstabAngle / 2;
                if botTarget:IsFacingLocation(npcBot:GetLocation(), halfAngle)
                then
                    local backstabPosition = GetBackstabPosition(botTarget, backstabAngle);
                    if backstabPosition ~= nil and GetUnitToLocationDistance(npcBot, backstabPosition) > npcBot:GetBoundingRadius()
                    then
                        npcBot:Action_ClearActions(false);
                        npcBot:ActionQueue_MoveToLocation(backstabPosition);
                        --npcBot:ActionImmediate_Ping(backstabPosition.x, backstabPosition.y, false);
                        --npcBot:ActionImmediate_Chat("Обхожу со спины " .. botTarget:GetUnitName(), true);
                        return;
                    end
                end
            end
        end
    end
end

function GetBackstabPosition(enemy, backstabAngle)
    local attackRange = npcBot:GetAttackRange();
    local enemyLoc = enemy:GetExtrapolatedLocation(0.4);
    local enemyFacing = enemy:GetFacing();

    local backAngle = enemyFacing + 180;
    if backAngle >= 360
    then
        backAngle = backAngle - 360;
    end

    local halfAngle = backstabAngle / 2;
    local bestPos = nil;
    local bestDist = 100000;
    local samples = 7;

    for i = 0, samples do
        local offset = -halfAngle + (backstabAngle / samples) * i
        local finalAngle = backAngle + offset

        if finalAngle < 0 then finalAngle = finalAngle + 360 end
        if finalAngle > 360 then finalAngle = finalAngle - 360 end

        local rad = math.rad(finalAngle);
        local dir = Vector(math.cos(rad), math.sin(rad), 0);
        local pos = enemyLoc + dir * (attackRange - 40);

        if not enemy:IsFacingLocation(pos, 45)
        then
            local dist = GetUnitToLocationDistance(npcBot, pos);
            if dist < bestDist
            then
                bestDist = dist;
                bestPos = pos;
            end
        end
    end

    return bestPos;
end

function ConsiderSmokeScreen()
    local ability = SmokeScreen;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not npcBot:HasModifier("modifier_riki_tricks_of_the_trade_phase")
            then
                --npcBot:ActionImmediate_Chat("Использую SmokeScreen для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBlinkStrike()
    local ability = BlinkStrike;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local backstabDamage = npcBot:GetAttributeValue(ATTRIBUTE_AGILITY) * Backstab:GetSpecialValueInt("damage_multiplier");
    local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("bonus_damage") + backstabDamage;
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike что бы добить " .. enemy:GetUnitName() .. " уроном " .. damageAbility, true);
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local fountainLocation = utility.GetFountainLocation();
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

    -- Last hit
    if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and (ManaPercentage >= 0.4) and (#enemyAbility <= 0)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                    and npcBot:GetAttackTarget() ~= enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую BlinkStrike добивая крипа " .. enemy:GetUnitName() .. " уроном " .. damageAbility, true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTricksOfTheTrade()
    local ability = TricksOfTheTrade;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and utility.BotWasRecentlyDamagedByEnemyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility <= 0)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
                0, 0);
            if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
            then
                --npcBot:ActionImmediate_Chat("Использую TricksOfTheTrade по вражеским крипам!", true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
