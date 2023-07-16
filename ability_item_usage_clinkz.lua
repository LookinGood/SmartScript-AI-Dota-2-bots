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
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
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
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    Strafe = AbilitiesReal[1]
    TarBomb = AbilitiesReal[2]
    DeathPact = AbilitiesReal[3]
    BurningArmy = AbilitiesReal[4]
    BurningBarrage = AbilitiesReal[5]
    SkeletonWalk = AbilitiesReal[6]

    castStrafeDesire = ConsiderStrafe();
    castTarBombDesire, castTarBombTarget = ConsiderTarBomb();
    castDeathPactDesire, castDeathPactTarget = ConsiderDeathPact();
    castBurningArmyDesire, castBurningArmyLocation = ConsiderBurningArmy();
    castBurningBarrageDesire, castBurningBarrageLocation = ConsiderBurningBarrage();
    castSkeletonWalkDesire = ConsiderSkeletonWalk();

    if (castStrafeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Strafe);
        return;
    end

    if (castTarBombDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(TarBomb, castTarBombTarget);
        return;
    end

    if (castDeathPactDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DeathPact, castDeathPactTarget);
        return;
    end

    if (castBurningArmyDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BurningArmy, castBurningArmyLocation);
        return;
    end

    if (castBurningBarrageDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BurningBarrage, castBurningBarrageLocation);
        return;
    end

    if (castSkeletonWalkDesire ~= nil)
    then
        npcBot:Action_UseAbility(SkeletonWalk);
        return;
    end
end

function ConsiderStrafe()
    local ability = Strafe;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local attackRange = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую Strafe против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Use when attack building
    if attackTarget:IsTower() or attackTarget:IsFort() or attackTarget:IsBarracks()
    then
        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3) and ManaPercentage >= 0.4
        then
            --npcBot:ActionImmediate_Chat("Использую Strafe против зданий!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderTarBomb()
    local ability = TarBomb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    if not npcBot:IsInvisible()
    then
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
            then
                if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
                then
                    return BOT_MODE_DESIRE_HIGH, botTarget;
                end
            end
            -- Retreat or help ally use
        elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if enemy:CanBeSeen() and utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую TarBomb что бы оторваться от врага",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
            -- Cast if push/defend/farm
        elseif utility.PvEMode(npcBot)
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true)
            if (#enemyCreeps > 0) and (ManaPercentage >= 0.5)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if enemy:CanBeSeen() and utility.SafeCast(enemy, false)
                    then
                        return BOT_MODE_DESIRE_VERYLOW, enemy;
                    end
                end
            end
            -- Cast when laning
        elseif botMode == BOT_MODE_LANING
        then
            if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
            then
                for _, enemy in pairs(enemyAbility) do
                    if enemy:CanBeSeen() and utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую TarBomb для лайнинга!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end
end

function ConsiderDeathPact()
    local ability = DeathPact;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local creepMaxLevel = ability:GetSpecialValueInt("creep_level");
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    -- General use
    if (HealthPercentage <= 0.9)
    then
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:GetLevel() <= creepMaxLevel
                then
                    --npcBot:ActionImmediate_Chat("Использую DeathPact!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderBurningArmy()
    local ability = BurningArmy;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    if not npcBot:IsInvisible()
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if botTarget ~= nil and utility.IsHero(botTarget)
            then
                if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    if npcBot:IsFacingLocation(botTarget:GetLocation(), 20)
                    then
                        --npcBot:ActionImmediate_Chat("Использую BurningArmy под себя!", true);
                        return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
                    else
                        --npcBot:ActionImmediate_Chat("Использую BurningArmy под врага!", true);
                        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
                    end
                end
            end
            -- Retreat use
        elseif botMode == BOT_MODE_RETREAT
        then
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
            if (enemyAbility > 0) and (HealthPercentage < 0.7)
            then
                --npcBot:ActionImmediate_Chat("Использую BurningArmy для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
            end
        end
    end
end

function ConsiderBurningBarrage()
    local ability = BurningBarrage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");

    if not npcBot:IsInvisible()
    then
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
            then
                if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую BurningBarrage!", true);
                    return BOT_MODE_DESIRE_HIGH, botTarget:GetLocation();
                end
            end
        end
    end
end

function ConsiderSkeletonWalk()
    local ability = SkeletonWalk;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    if not npcBot:IsInvisible()
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if botTarget ~= nil and utility.IsHero(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
                then
                    --npcBot:ActionImmediate_Chat("Использую SkeletonWalk для нападения!", true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
            -- Retreat use
        elseif botMode == BOT_MODE_RETREAT
        then
            --local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
            then
                --npcBot:ActionImmediate_Chat("Использую SkeletonWalk для отхода!", true);
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    end
end
