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
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
}


function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local MagicMissile = AbilitiesReal[1]
local WaveOfTerror = AbilitiesReal[2]
local NetherSwap = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castMagicMissileDesire, castMagicMissileTarget = ConsiderMagicMissile();
    local castWaveOfTerrorDesire, castWaveOfTerrorLocation = ConsiderWaveOfTerror();
    local castNetherSwapDesire, castNetherSwapTarget = ConsiderNetherSwap();

    if (castMagicMissileDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(MagicMissile, castMagicMissileTarget);
        return;
    end

    if (castNetherSwapDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(NetherSwap, castNetherSwapTarget);
        return;
    end

    if (castWaveOfTerrorDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WaveOfTerror, castWaveOfTerrorLocation);
        return;
    end
end

function ConsiderMagicMissile()
    local ability = MagicMissile;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("magic_missile_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую MagicMissile что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
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
                and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую MagicMissile что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderWaveOfTerror()
    local ability = WaveOfTerror;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("wave_width");
    local damageAbility = ability:GetSpecialValueInt("AbilityDamage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую WaveOfTerror по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую WaveOfTerror по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderNetherSwap()
    local ability = NetherSwap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local attackRange = npcBot:GetAttackRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
    local fountainLocation = utility.SafeLocation(npcBot);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, false)
            and (GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange)
        then
            --npcBot:ActionImmediate_Chat("Использую NetherSwap по врагу в радиусе действия!",true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
        end
        -- Interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling() and utility.SafeCast(enemy, false)
                then
                    --npcBot:ActionImmediate_Chat("Использую NetherSwap что бы сбить заклинание цели!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (HealthPercentage <= 0.5) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
                then
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую NetherSwap что бы оторваться от врага!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    -- Try to safe ally
    if botMode ~= BOT_MODE_RETREAT and (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally ~= npcBot
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.5 and (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2) and
                    ally:DistanceFromFountain() > npcBot:DistanceFromFountain() and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую NetherSwap на союзного героя со здоровьем ниже 20%!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally;
                end
            end
        end
    end
end
