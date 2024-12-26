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
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local NetherBlast = AbilitiesReal[1]
local Decrepify = AbilitiesReal[2]
local NetherWard = AbilitiesReal[3]
local LifeDrain = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCastWhenChanneling(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDecrepifyDesire, castDecrepifyTarget = ConsiderDecrepify();

    if (castDecrepifyDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Decrepify, castDecrepifyTarget);
        return;
    end

    if not utility.CanCast(npcBot) then
        return;
    end

    local castNetherBlastDesire, castNetherBlastLocation, castNetherBlastTarget = ConsiderNetherBlast();
    local castNetherWardDesire, castNetherWardLocation = ConsiderNetherWard();
    local castLifeDrainDesire, castLifeDrainTarget = ConsiderLifeDrain();

    if (castNetherBlastDesire ~= nil)
    then
        if utility.IsAbilityAvailable(Decrepify) and (npcBot:GetMana() >= NetherBlast:GetManaCost() + Decrepify:GetManaCost())
            and castNetherBlastTarget ~= nil and not castNetherBlastTarget:IsAttackImmune()
        then
            --npcBot:ActionImmediate_Chat("Использую NetherBlast в связке с Decrepify!", true);
            npcBot:Action_ClearActions(false);
            npcBot:Action_UseAbilityOnEntity(Decrepify, castNetherBlastTarget);
            npcBot:ActionQueue_UseAbilityOnLocation(NetherBlast, castNetherBlastLocation);
            return;
        else
            --npcBot:ActionImmediate_Chat("Использую NetherBlast!", true);
            npcBot:Action_UseAbilityOnLocation(NetherBlast, castNetherBlastLocation);
            return;
        end
    end

    if (castNetherWardDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(NetherWard, castNetherWardLocation);
        return;
    end

    if (castLifeDrainDesire ~= nil)
    then
        if utility.IsAbilityAvailable(Decrepify) and (npcBot:GetMana() >= LifeDrain:GetManaCost() + Decrepify:GetManaCost())
            and castLifeDrainTarget ~= nil and not castLifeDrainTarget:IsAttackImmune()
        then
            --npcBot:ActionImmediate_Chat("Использую LifeDrain в связке с Decrepify!", true);
            npcBot:Action_ClearActions(true);
            npcBot:Action_UseAbilityOnEntity(Decrepify, castLifeDrainTarget);
            npcBot:ActionQueue_UseAbilityOnEntity(LifeDrain, castLifeDrainTarget);
            return;
        else
            --npcBot:ActionImmediate_Chat("Использую LifeDrain!", true);
            npcBot:Action_ClearActions(true);
            npcBot:Action_UseAbilityOnEntity(LifeDrain, castLifeDrainTarget);
            return;
        end
    end
end

function ConsiderNetherBlast()
    local ability = NetherBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("blast_damage");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую NetherBlast что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                        enemy;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0),
                    botTarget;
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if (ManaPercentage >= 0.5)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
                0, 0);
            if locationAoE ~= nil and (locationAoE.count >= 3)
            then
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, nil;
            end
            -- Cast if enemy building near
            local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
            local enemyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, true);
            local enemyAncient = GetAncient(GetOpposingTeam());
            if (#enemyTower > 0)
            then
                for _, enemy in pairs(enemyTower) do
                    if utility.CanCastOnInvulnerableTarget(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую NetherBlast против башни!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), nil;
                    end
                end
            end
            if (#enemyBarracks > 0)
            then
                for _, enemy in pairs(enemyBarracks) do
                    if utility.CanCastOnInvulnerableTarget(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую NetherBlast против барраков!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), nil;
                    end
                end
            end
            if GetUnitToUnitDistance(npcBot, enemyAncient) <= castRangeAbility and utility.CanCastOnInvulnerableTarget(enemyAncient)
            then
                --npcBot:ActionImmediate_Chat("Использую NetherBlast против древнего!", true);
                return BOT_ACTION_DESIRE_HIGH, enemyAncient:GetLocation(), nil;
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), enemy;
        end
    end
end

function ConsiderDecrepify()
    local ability = Decrepify;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        --[[         if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget) and not botTarget:IsAttackImmune()
            then
                npcBot:ActionImmediate_Chat("Использую Decrepify на врага!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end ]]
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility == 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and not enemy:IsAttackImmune()
                then
                    --npcBot:ActionImmediate_Chat("Использую Decrepify при побеге на одного врага!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
            if not npcBot:IsAttackImmune()
            then
                --npcBot:ActionImmediate_Chat("Использую Decrepify при побеге на себя т.к враг иммунен!",true);
                return BOT_ACTION_DESIRE_HIGH, npcBot;
            end
        elseif (#enemyAbility > 0) and not npcBot:IsAttackImmune()
        then
            --npcBot:ActionImmediate_Chat("Использую Decrepify при побеге на себя т.к врагов больше 1!",true);
            return BOT_ACTION_DESIRE_HIGH, npcBot;
        end
    end

    -- Cast if ally attacked and low HP
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.6 and not ally:IsAttackImmune()) and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0)) or
                (ally:IsChanneling())
            then
                --npcBot:ActionImmediate_Chat("Использую Decrepify на союзного героя со здоровьем ниже 60%!",true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end

function ConsiderNetherWard()
    local ability = NetherWard;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую NetherWard против врага в радиусе действия!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                end
            end
        end
    end
end

function ConsiderLifeDrain()
    local ability = LifeDrain;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange() + 200;
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую LifeDrain для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6)
        then
            if (#enemyAbility == 1) or (#allyAbility > 1)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую LifeDrain при побеге на одного врага!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    -- Cast if ally attacked and low HP
    if (#allyAbility > 1) and (HealthPercentage >= 0.8)
    then
        for _, ally in pairs(allyAbility)
        do
            if (ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.3) and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую LifeDrain на союзного героя со здоровьем ниже 30%!", true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end

    -- (Only Shard) Use if enemy around ward > 1
    if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_OTHER)
    then
        if utility.PvPMode(npcBot)
        then
            local allys = GetUnitList(UNIT_LIST_ALLIED_OTHER);
            if (#allys > 0)
            then
                for _, ally in pairs(allys)
                do
                    if string.find(ally:GetUnitName(), "npc_dota_pugna_nether_ward") and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        local enemyHeroes = ally:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
                        if (#enemyHeroes > 1)
                        then
                            npcBot:ActionImmediate_Chat("Использую LifeDrain на свой вард!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH, ally;
                        end
                    end
                end
            end
        end
    end
end
