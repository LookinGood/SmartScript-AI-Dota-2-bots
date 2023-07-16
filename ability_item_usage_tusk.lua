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

    IceShards = AbilitiesReal[1]
    Snowball = AbilitiesReal[2]
    LaunchSnowball = npcBot:GetAbilityByName("tusk_launch_snowball");
    TagTeam = AbilitiesReal[3]
    WalrusKick = AbilitiesReal[4]
    WalrusPunch = AbilitiesReal[6]

    castIceShardsDesire, castIceShardsLocation = ConsiderIceShards();
    castSnowballDesire, castSnowballTarget = ConsiderSnowball();
    castLaunchSnowballDesire = ConsiderLaunchSnowball();
    castTagTeamDesire = ConsiderTagTeam();
    castWalrusKickDesire, castWalrusKickTarget = ConsiderWalrusKick();
    castWalrusPunchDesire, castWalrusPunchTarget = ConsiderWalrusPunch();

    if (castIceShardsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceShards, castIceShardsLocation);
        return;
    end

    if (castSnowballDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Snowball, castSnowballTarget);
        return;
    end

    if (castLaunchSnowballDesire ~= nil)
    then
        npcBot:Action_UseAbility(LaunchSnowball);
        return;
    end

    if (castTagTeamDesire ~= nil)
    then
        npcBot:Action_UseAbility(TagTeam);
        return;
    end

    if (castWalrusKickDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WalrusKick, castWalrusKickTarget);
        return;
    end

    if (castWalrusPunchDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WalrusPunch, castWalrusPunchTarget);
        return;
    end
end

function ConsiderIceShards()
    local ability = IceShards;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("shard_width");
    local damageAbility = ability:GetSpecialValueInt("shard_damage");
    --local speedAbility = ability:GetSpecialValueInt("shard_speed");
    --local abilityCastPoint = ability:GetCastPoint();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE)

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) and not utility.TargetCantDie(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую IceShards что бы убить бегущую цель!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(0.5);
                    else
                        --npcBot:ActionImmediate_Chat("Использую IceShards что бы убить бегущую цель!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if utility.IsMoving(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую IceShards по бегущей цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetExtrapolatedLocation(0.5);
            else
                --npcBot:ActionImmediate_Chat("Использую IceShards по стоящей цели!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую IceShards по бегущей цели отступая!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(0.5);
                    else
                        --npcBot:ActionImmediate_Chat("Использую IceShards по стоящей цели отступая!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую IceShards по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if utility.IsMoving(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую IceShards по бегущей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetExtrapolatedLocation(0.5);
                    else
                        --npcBot:ActionImmediate_Chat("Использую IceShards по стоящей цели на ЛАЙНЕ!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    end
end

function ConsiderSnowball()
    local ability = Snowball;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("snowball_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
    local fountainLocation = utility.SafeLocation(npcBot);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) and not utility.TargetCantDie(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Snowball что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Snowball по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Use if need retreat
    elseif botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
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
end

function ConsiderLaunchSnowball()
    local ability = LaunchSnowball;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --npcBot:ActionImmediate_Chat("Использую LaunchSnowball!", true);
    return BOT_ACTION_DESIRE_HIGH;
end

function ConsiderTagTeam()
    local ability = TagTeam;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую TagTeam против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.8) and (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую TagTeam для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderWalrusKick()
    local ability = WalrusKick;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("damage"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility * 2), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:CanBeSeen() and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую WalrusKick что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen() and not utility.IsDisabled(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true) and
            botTarget:IsFacingLocation(npcBot:GetLocation(), 20)
        then
            --npcBot:ActionImmediate_Chat("Использую WalrusKick по врагу в радиусе действия!", true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen() and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую WalrusKick что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderWalrusPunch()
    local ability = WalrusPunch;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = math.floor(npcBot:GetAttackDamage()) / 100 * ability:GetSpecialValueInt("crit_multiplier");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility * 2), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:CanBeSeen()
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую WalrusPunch что бы сбить заклинание или убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if botTarget ~= nil
    then
        if (utility.IsHero(botTarget) or utility.IsRoshan(botTarget)) and utility.CanCastOnInvulnerableTarget(botTarget)
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
    else
        if ability:GetAutoCastState()
        then
            ability:ToggleAutoCast()
        end
    end
end
