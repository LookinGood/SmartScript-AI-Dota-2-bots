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
    Abilities[1],
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
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local IceShards = npcBot:GetAbilityByName("tusk_ice_shards");
local Snowball = npcBot:GetAbilityByName("tusk_snowball");
local LaunchSnowball = npcBot:GetAbilityByName("tusk_launch_snowball");
local TagTeam = npcBot:GetAbilityByName("tusk_tag_team");
local DrinkingBuddies = npcBot:GetAbilityByName("tusk_drinking_buddies");
local WalrusKick = npcBot:GetAbilityByName("tusk_walrus_kick");
local WalrusPunch = npcBot:GetAbilityByName("tusk_walrus_punch");

function AbilityUsageThink()
    local castLaunchSnowballDesire = ConsiderLaunchSnowball();

    if (castLaunchSnowballDesire > 0)
    then
        npcBot:Action_UseAbility(LaunchSnowball);
        return;
    end

    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castIceShardsDesire, castIceShardsLocation = ConsiderIceShards();
    local castSnowballDesire, castSnowballTarget = ConsiderSnowball();
    local castTagTeamDesire = ConsiderTagTeam();
    local castDrinkingBuddiesDesire, castDrinkingBuddiesTarget = ConsiderDrinkingBuddies();
    local castWalrusKickDesire, castWalrusKickTarget = ConsiderWalrusKick();
    local castWalrusPunchDesire, castWalrusPunchTarget = ConsiderWalrusPunch();

    if (castIceShardsDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(IceShards, castIceShardsLocation);
        return;
    end

    if (castSnowballDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Snowball, castSnowballTarget);
        return;
    end

    if (castTagTeamDesire > 0)
    then
        npcBot:Action_UseAbility(TagTeam);
        return;
    end

    if (castDrinkingBuddiesDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(DrinkingBuddies, castDrinkingBuddiesTarget);
        return;
    end

    if (castWalrusKickDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(WalrusKick, castWalrusKickTarget);
        return;
    end

    if (castWalrusPunchDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(WalrusPunch, castWalrusPunchTarget);
        return;
    end
end

function ConsiderIceShards()
    local ability = IceShards;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("shard_width");
    local damageAbility = ability:GetSpecialValueInt("shard_damage");
    local delayAbility = ability:GetCastPoint();
    local speedAbility = ability:GetSpecialValueInt("shard_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую IceShards по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую IceShards по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSnowball()
    local ability = Snowball;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("snowball_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
    local fountainLocation = utility.GetFountainLocation();

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Snowball что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Use if need retreat
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Snowball что бы оторваться ПО ГЕРОЮ!",true);
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
                        --npcBot:ActionImmediate_Chat("Использую Snowball что бы оторваться ПО КРИПУ!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLaunchSnowball()
    local ability = LaunchSnowball;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    --npcBot:ActionImmediate_Chat("Использую LaunchSnowball!", true);
    return BOT_ACTION_DESIRE_HIGH;
end

function ConsiderTagTeam()
    local ability = TagTeam;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую TagTeam против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    --[[     if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую TagTeam для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end ]]

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderDrinkingBuddies()
    local ability = DrinkingBuddies;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local minDistance = ability:GetSpecialValueInt("min_distance");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
                if (#allyAbility > 1)
                then
                    for _, ally in pairs(allyAbility)
                    do
                        if utility.IsHero(ally) and ally ~= npcBot and GetUnitToUnitDistance(ally, botTarget) <= (minDistance * 2)
                            and not npcBot:HasModifier("modifier_tusk_drinking_buddies_buff")
                        then
                            --npcBot:ActionImmediate_Chat("Использую DrinkingBuddies на союзного героя при атаке!",true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and not npcBot:HasModifier("modifier_tusk_drinking_buddies_buff")
        then
            local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
            local fountainLocation = utility.SafeLocation(npcBot);
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility) do
                    if ally ~= npcBot and GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) >= minDistance)
                    then
                        --npcBot:ActionImmediate_Chat("Использую DrinkingBuddies для побега на союзного героя!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) >= minDistance)
                    then
                        --npcBot:ActionImmediate_Chat("Использую DrinkingBuddies для побега на союзного крипа!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWalrusKick()
    local ability = WalrusKick;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility * 2, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WalrusKick что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget) and botTarget:IsFacingLocation(npcBot:GetLocation(), 20)
        then
            --npcBot:ActionImmediate_Chat("Использую WalrusKick по врагу в радиусе действия!", true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
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
                    --npcBot:ActionImmediate_Chat("Использую WalrusKick что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderWalrusPunch()
    local ability = WalrusPunch;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = math.floor(npcBot:GetAttackDamage()) / 100 * ability:GetSpecialValueInt("crit_multiplier");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility * 2), true, BOT_MODE_NONE);

    if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(ability, botTarget)
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState()
        then
            ability:ToggleAutoCast()
        end
    end

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WalrusPunch что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
