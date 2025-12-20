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
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Strafe = npcBot:GetAbilityByName("clinkz_strafe");
local SearingArrows = npcBot:GetAbilityByName("clinkz_searing_arrows");
local TarBomb = npcBot:GetAbilityByName("clinkz_tar_bomb");
local DeathPact = npcBot:GetAbilityByName("clinkz_death_pact");
local BurningBarrage = npcBot:GetAbilityByName("clinkz_burning_barrage");
local BurningArmy = npcBot:GetAbilityByName("clinkz_burning_army");
local SkeletonWalk = npcBot:GetAbilityByName("clinkz_wind_walk");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStrafeDesire = ConsiderStrafe();
    ConsiderSearingArrows();
    local castTarBombDesire, castTarBombTarget = ConsiderTarBomb();
    local castDeathPactDesire, castDeathPactTarget = ConsiderDeathPact();
    local castBurningArmyDesire, castBurningArmyLocation = ConsiderBurningArmy();
    local castBurningBarrageDesire, castBurningBarrageLocation = ConsiderBurningBarrage();
    local castSkeletonWalkDesire = ConsiderSkeletonWalk();

    if (castStrafeDesire > 0)
    then
        npcBot:Action_UseAbility(Strafe);
        return;
    end

    if (castTarBombDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(TarBomb, castTarBombTarget);
        return;
    end

    if (castDeathPactDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(DeathPact, castDeathPactTarget);
        return;
    end

    if (castBurningArmyDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(BurningArmy, castBurningArmyLocation);
        return;
    end

    if (castBurningBarrageDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(BurningBarrage, castBurningBarrageLocation);
        return;
    end

    if (castSkeletonWalkDesire > 0)
    then
        npcBot:Action_UseAbility(SkeletonWalk);
        return;
    end
end

function ConsiderStrafe()
    local ability = Strafe;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local attackRange = npcBot:GetAttackRange() + ability:GetSpecialValueInt("attack_range_bonus");


    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую Strafe против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Use when attack building
    if utility.IsBuilding(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3) and (ManaPercentage >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую Strafe против зданий!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSearingArrows()
    local ability = SearingArrows;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if utility.CanCastSpellOnTarget(ability, attackTarget) and
        (utility.IsHero(attackTarget) or utility.IsBoss(attackTarget))
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

function ConsiderTarBomb()
    local ability = TarBomb;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:IsInvisible()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local attackTarget = npcBot:GetAttackTarget();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    if utility.CanCastSpellOnTarget(ability, attackTarget) and
        (utility.IsHero(attackTarget) or utility.IsBoss(attackTarget))
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
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
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TarBomb что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true)
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy;
                end
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую TarBomb по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDeathPact()
    local ability = DeathPact;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBurningArmy()
    local ability = BurningArmy;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:IsInvisible()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
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
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую BurningArmy для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBurningBarrage()
    local ability = BurningBarrage;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:IsInvisible()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую BurningBarrage!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSkeletonWalk()
    local ability = SkeletonWalk;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:IsInvisible()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                --npcBot:ActionImmediate_Chat("Использую SkeletonWalk для нападения!", true);
                return BOT_MODE_DESIRE_VERYHIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую SkeletonWalk для отхода!", true);
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    -- General use
    if utility.WanderMode(npcBot)
    then
        local enemyTowers = npcBot:GetNearbyTowers(1000, true);
        if (#enemyTowers == 0) and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
        then
            return BOT_MODE_DESIRE_MODERATE;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
