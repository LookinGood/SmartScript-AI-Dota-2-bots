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
    Talents[1],
    Abilities[2],
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

-- Abilities
local Starbreaker = AbilitiesReal[1]
local CelestialHammer = AbilitiesReal[2]
local Converge = npcBot:GetAbilityByName("dawnbreaker_converge");
local SolarGuardian = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStarbreakerDesire, castStarbreakerLocation = ConsiderStarbreaker();
    local castCelestialHammerDesire, castCelestialHammerLocation = ConsiderCelestialHammer();
    local castConvergeDesire = ConsiderConverge();
    local castSolarGuardianDesire, castSolarGuardianLocation = ConsiderSolarGuardian();

    if (castStarbreakerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Starbreaker, castStarbreakerLocation);
        return;
    end

    if (castCelestialHammerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(CelestialHammer, castCelestialHammerLocation);
        return;
    end

    if (castConvergeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Converge);
        return;
    end

    if (castSolarGuardianDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SolarGuardian, castSolarGuardianLocation);
        return;
    end
end

function ConsiderStarbreaker()
    local ability = Starbreaker;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("swipe_radius");
    local radiusAbility = ability:GetSpecialValueInt("smash_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if botMode ~= BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую Starbreaker что бы сбить заклинание!",true);
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
            --npcBot:ActionImmediate_Chat("Использую Starbreaker по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderCelestialHammer()
    local ability = CelestialHammer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("range");
    local radiusAbility = ability:GetSpecialValueInt("flare_radius");
    local damageAbility = ability:GetSpecialValueInt("hammer_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
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
            --npcBot:ActionImmediate_Chat("Использую CelestialHammer по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую CelestialHammer для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую CelestialHammer по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderConverge()
    local ability = Converge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = CelestialHammer:GetSpecialValueInt("flare_radius");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            local projectiles = GetLinearProjectiles();
            if (#projectiles > 0)
            then
                for _, project in pairs(projectiles)
                do
                    if project ~= nil and project.ability:GetName() == "dawnbreaker_celestial_hammer"
                    then
                        if GetUnitToLocationDistance(botTarget, project.location) <= radiusAbility * 2 and GetUnitToUnitDistance(npcBot, botTarget) >= castRangeAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую Converge рядом с врагом!", true);
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        end
    elseif botMode == BOT_MODE_RETREAT
    then
        --npcBot:ActionImmediate_Chat("Использую Converger для отхода!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderSolarGuardian()
    local ability = SolarGuardian;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("max_offset_distance"); -- 350
    local radiusAbility = ability:GetSpecialValueInt("radius");                 -- 500
    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            for i = 1, #allyAbility do
                if utility.IsValidTarget(allyAbility[i]) and GetUnitToUnitDistance(allyAbility[i], botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую SolarGuardian на союзника рядом с врагом!",true);
                    return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i]:GetLocation();
                end
            end
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local fountainLocation = utility.SafeLocation(npcBot);
            for i = 1, #allyAbility do
                if utility.IsValidTarget(allyAbility[i]) and allyAbility[i] ~= npcBot and GetUnitToLocationDistance(allyAbility[i], fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation)
                    and (GetUnitToUnitDistance(allyAbility[i], npcBot) > radiusAbility)
                then
                    --npcBot:ActionImmediate_Chat("Использую SolarGuardian на союзника ближе к фонтану!",true);
                    return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i]:GetLocation() + RandomVector(castRangeAbility);
                end
            end
        end
    end
end
