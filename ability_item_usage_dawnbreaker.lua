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
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    Starbreaker = AbilitiesReal[1]
    CelestialHammer = AbilitiesReal[2]
    Converge = npcBot:GetAbilityByName("dawnbreaker_converge");
    SolarGuardian = AbilitiesReal[6]

    castStarbreakerDesire, castStarbreakerLocation = ConsiderStarbreaker();
    castCelestialHammerDesire, castCelestialHammerLocation = ConsiderCelestialHammer();
    castConvergeDesire = ConsiderConverge();
    castSolarGuardianDesire, castSolarGuardianLocation = ConsiderSolarGuardian();

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

    local castRangeAbility = (ability:GetSpecialValueInt("swipe_radius"));
    local radiusAbility = (ability:GetSpecialValueInt("smash_radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if botMode ~= BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen() and enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую Starbreaker что бы сбить заклинание!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Starbreaker по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Starbreaker по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and (ManaPercentage >= 0.4)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Starbreaker на Рошана!", true);
                return BOT_MODE_DESIRE_MODERATE, botTarget:GetLocation();
            end
        end
    end
end

function ConsiderCelestialHammer()
    local ability = CelestialHammer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = (ability:GetSpecialValueInt("range"));
    local radiusAbility = (ability:GetSpecialValueInt("flare_radius"));
    local damageAbility = (ability:GetSpecialValueInt("hammer_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
            then
                --npcBot:ActionImmediate_Chat("Использую CelestialHammer что бы убить цель!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
        then
            --npcBot:ActionImmediate_Chat("Использую CelestialHammer по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
           --npcBot:ActionImmediate_Chat("Использую CelestialHammer по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую CelestialHammer для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end

function ConsiderConverge()
    local ability = Converge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and GetUnitToUnitDistance(npcBot, botTarget) > (castRangeAbility * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Converger что бы догнать врага!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
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

    local castRangeAbility = (ability:GetSpecialValueInt("max_offset_distance")); -- 350
    local radiusAbility = (ability:GetSpecialValueInt("radius"));                 -- 500
    local allyAbility = (GetUnitList(UNIT_LIST_ALLIED_HEROES));

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget)
        then
            for i = 1, #allyAbility do
                if allyAbility[i] ~= nil and GetUnitToUnitDistance(allyAbility[i], botTarget) <= castRangeAbility
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
                if allyAbility[i] ~= nil and allyAbility[i] ~= npcBot and GetUnitToLocationDistance(allyAbility[i], fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation)
                    and (GetUnitToUnitDistance(allyAbility[i], npcBot) > radiusAbility)
                then
                    --npcBot:ActionImmediate_Chat("Использую SolarGuardian на союзника ближе к фонтану!",true);
                    return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i]:GetLocation();
                end
            end
        end
    end
end
