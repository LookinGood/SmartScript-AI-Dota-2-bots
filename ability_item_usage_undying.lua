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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Decay = AbilitiesReal[1]
local SoulRip = AbilitiesReal[2]
local Tombstone = AbilitiesReal[3]
local FleshGolem = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDecayDesire, castDecayLocation = ConsiderDecay();
    local castSoulRipDesire, castSoulRipTarget = ConsiderSoulRip();
    local castTombstoneDesire, castTombstoneTarget, castTombstoneTargetType = ConsiderTombstone();
    local castFleshGolemDesire = ConsiderFleshGolem();

    if (castDecayDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Decay, castDecayLocation);
        return;
    end

    if (castSoulRipDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SoulRip, castSoulRipTarget);
        return;
    end

    if (castTombstoneDesire ~= nil)
    then
        if (castTombstoneTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Tombstone, castTombstoneTarget + RandomVector(200));
            return;
        elseif (castTombstoneTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Tombstone, castTombstoneTarget);
            return;
        end
    end

    if (castFleshGolemDesire ~= nil)
    then
        npcBot:Action_UseAbility(FleshGolem);
        return;
    end
end

function ConsiderDecay()
    local ability = Decay;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("decay_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Decay по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Decay что бы оторваться от врага!",true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 2) and (damageAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую Decay по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.5)
        then
            --npcBot:ActionImmediate_Chat("Использую DragonSlave по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderSoulRip()
    local ability = SoulRip;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("radius"));
    local allyHeroAbilityHeal = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local allyCreepsAbility = npcBot:GetNearbyCreeps(radiusAbility, false);
    local allyHeroAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
    local enemyCreepsAbility = npcBot:GetNearbyCreeps(radiusAbility, true);
    local enemyHeroAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
    local unitAroundMe = #allyCreepsAbility + #allyHeroAbility + #enemyCreepsAbility + #enemyHeroAbility;

    if (unitAroundMe > 1)
    then
        -- Cast to heal ally hero
        if #allyHeroAbilityHeal > 0
        then
            for _, ally in pairs(allyHeroAbilityHeal)
            do
                if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Использую Soul Rip на союзного героя со здоровьем ниже 80%",true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Soul Rip по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end

function ConsiderTombstone()
    local ability = Tombstone;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
    then
        -- Cast if attack enemy
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                -- npcBot:ActionImmediate_Chat("Использую Tombstone для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
            end
            -- Use if need retreat
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Tombstone что бы оторваться от врага!", true);
                        return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation(), "location";
                    end
                end
            end
        end
    end

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
    then
        -- General use on allied heroes
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and not ally:IsChanneling()
                then
                    if utility.IsDisabled(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.5) and ally:WasRecentlyDamagedByAnyHero(2.0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Tombstone на союзника в стане!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally, "target";
                    end
                end
            end
        end
    end
end

function ConsiderFleshGolem()
    local ability = FleshGolem;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_undying_flesh_golem")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 4)
        then
            --npcBot:ActionImmediate_Chat("Использую Flesh Golem для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Flesh Golem для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
