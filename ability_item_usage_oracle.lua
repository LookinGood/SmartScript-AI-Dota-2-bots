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
    Abilities[3],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local FortunesEnd = AbilitiesReal[1]
local FatesEdict = AbilitiesReal[2]
local PurifyingFlames = AbilitiesReal[3]
local RainOfDestiny = AbilitiesReal[4]
local FalsePromise = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFortunesEndDesire, castFortunesEndTarget = ConsiderFortunesEnd();
    local castFatesEdictDesire, castFatesEdictTarget = ConsiderFatesEdict();
    local castPurifyingFlamesDesire, castPurifyingFlamesTarget = ConsiderPurifyingFlames();
    local castRainOfDestinyDesire, castRainOfDestinyLocation = ConsiderRainOfDestiny();
    local castFalsePromiseDesire, castFalsePromiseTarget = ConsiderFalsePromise();

    if castFortunesEndDesire == nil then castFortunesEndDesire = BOT_ACTION_DESIRE_NONE end;
    if castFatesEdictDesire == nil then castFatesEdictDesire = BOT_ACTION_DESIRE_NONE end;
    if castPurifyingFlamesDesire == nil then castPurifyingFlamesDesire = BOT_ACTION_DESIRE_NONE end;
    if castRainOfDestinyDesire == nil then castRainOfDestinyDesire = BOT_ACTION_DESIRE_NONE end;
    if castFalsePromiseDesire == nil then castFalsePromiseDesire = BOT_ACTION_DESIRE_NONE end;

    if (castFortunesEndDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castFortunesEndDesire > castFatesEdictDesire and castPurifyingFlamesDesire and castRainOfDestinyDesire and castFalsePromiseDesire)
        then
            npcBot:Action_UseAbilityOnEntity(FortunesEnd, castFortunesEndTarget);
            return;
        end
    end

    if (castFatesEdictDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castFatesEdictDesire > castFortunesEndDesire and castPurifyingFlamesDesire and castRainOfDestinyDesire and castFalsePromiseDesire)
        then
            npcBot:Action_UseAbilityOnEntity(FatesEdict, castFatesEdictTarget);
            return;
        end
    end

    if (castPurifyingFlamesDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castPurifyingFlamesDesire > castFortunesEndDesire and castFatesEdictDesire and castRainOfDestinyDesire and castFalsePromiseDesire)
        then
            npcBot:Action_UseAbilityOnEntity(PurifyingFlames, castPurifyingFlamesTarget);
            return;
        end
    end

    if (castRainOfDestinyDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castRainOfDestinyDesire > castFortunesEndDesire and castFatesEdictDesire and castPurifyingFlamesDesire and castFalsePromiseDesire)
        then
            npcBot:Action_UseAbilityOnLocation(RainOfDestiny, castRainOfDestinyLocation);
            return;
        end
    end

    if (castFalsePromiseDesire > BOT_ACTION_DESIRE_NONE)
    then
        if (castFalsePromiseDesire > castFortunesEndDesire and castFatesEdictDesire and castRainOfDestinyDesire and castPurifyingFlamesDesire)
        then
            npcBot:Action_UseAbilityOnEntity(FalsePromise, castFalsePromiseTarget);
            return;
        end
    end
end

function ConsiderFortunesEnd()
    local ability = FortunesEnd;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FortunesEnd что бы убить цель/сбить каст!", true);
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
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 1) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FortunesEnd на крипов!", true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_MODERATE, enemy;
        end
    end
end

function ConsiderFatesEdict()
    local ability = FatesEdict;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_oracle_fates_edict")
            then
                if ally:WasRecentlyDamagedByAnyHero(2.0) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Использую FatesEdict для защиты союзника!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    for _, spell in pairs(incomingSpells)
                    do
                        if not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false
                        then
                            --npcBot:ActionImmediate_Chat("Использую FatesEdict для защиты от заклинания!", true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end
    end

    -- Cast to debuff enemies
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility)
        do
            local attackTarget = enemy:GetAttackTarget();
            if utility.IsHero(attackTarget) and not enemy:IsDisarmed()
            then
                return BOT_MODE_DESIRE_HIGH, enemy;
            end
        end
    end
end

function ConsiderPurifyingFlames()
    local ability = PurifyingFlames;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local healAbility = ability:GetSpecialValueInt("total_heal_tooltip");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую PurifyingFlames что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() <= ally:GetMaxHealth() - healAbility)
            then
                local magicResist = ally:GetMagicResist();
                if utility.TargetCantDie(ally) or magicResist >= 0.5
                then
                    --npcBot:ActionImmediate_Chat("Использую PurifyingFlames по бессмертному/с высоким резистом союзнику!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                else
                    if not utility.CanAbilityKillTarget(ally, damageAbility, ability:GetDamageType()) and ally:TimeSinceDamagedByAnyHero() >= 5.0
                    then
                        --npcBot:ActionImmediate_Chat("Использую PurifyingFlames по союзнику безопасно!", true);
                        return BOT_MODE_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end

    -- Last hit
    if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and (ManaPercentage >= 0.5)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую PurifyingFlames что бы добить крипа!", true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
    end
end

function ConsiderRainOfDestiny()
    local ability = RainOfDestiny;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Use to heal damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.7)
            then
                return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderFalsePromise()
    local ability = FalsePromise;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if (utility.IsHero(ally) and not utility.TargetCantDie(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2)
                and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end
