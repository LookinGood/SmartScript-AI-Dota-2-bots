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
    Talents[6],
    Talents[7],
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

    ColdFeet = AbilitiesReal[1]
    IceVortex = AbilitiesReal[2]
    ChillingTouch = AbilitiesReal[3]
    Release = npcBot:GetAbilityByName("ancient_apparition_ice_blast_release");
    IceBlast = AbilitiesReal[6]

    castColdFeetDesire, castColdFeetTarget = ConsiderColdFeet();
    castIceVortexDesire, castIceVortexLocation = ConsiderIceVortex();
    ConsiderChillingTouch();
    castReleaseDesire = ConsiderRelease();
    castIceBlastDesire, castIceBlastLocation = ConsiderIceBlast();

    if (castColdFeetDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ColdFeet, castColdFeetTarget);
        return;
    end

    if (castIceVortexDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceVortex, castIceVortexLocation);
        return;
    end

    if (castReleaseDesire ~= nil)
    then
        npcBot:Action_UseAbility(Release);
        return;
    end

    if (castIceBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceBlast, castIceBlastLocation);
        --releaseLocation = castIceBlastLocation;
        return;
    end
end

function ConsiderColdFeet()
    local ability = ColdFeet;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("damage") * ability:GetDuration());
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling() or utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
        then
            --npcBot:ActionImmediate_Chat("Использую ColdFeet по врагу в радиусе действия!",true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdFeet что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Roshan
    elseif npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую ColdFeet на Рошана!", true);
                return BOT_MODE_DESIRE_MODERATE, botTarget;
            end
        end
    end
end

function ConsiderIceVortex()
    local ability = IceVortex;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not botTarget:HasModifier("modifier_ice_vortex")
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen() and not enemy:HasModifier("modifier_ice_vortex")
                then
                    --npcBot:ActionImmediate_Chat("Использую IceVortex для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if (locationAoE.count > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex по героям врага на линии!",true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN and (ManaPercentage >= 0.4)
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not botTarget:HasModifier("modifier_ice_vortex")
        then
            --npcBot:ActionImmediate_Chat("Использую IceVortex на рошана!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
    end
end

function ConsiderChillingTouch()
    local ability = ChillingTouch;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));
    local attackTarget = npcBot:GetAttackTarget();

    if botTarget ~= nil and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
        and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
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

    if attackTarget ~= nil
    then
        if (utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget))
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
    end
end

function ConsiderRelease()
    local ability = Release;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local projectiles = GetLinearProjectiles();
    local radiusAbility = (IceBlast:GetSpecialValueInt("radius_min"));
    local enemyAbility = (GetUnitList(UNIT_LIST_ENEMY_HEROES));

    for _, iceBlast in pairs(projectiles)
    do
        if iceBlast ~= nil and iceBlast.ability:GetName() == "ancient_apparition_ice_blast"
        then
            for i = 1, #enemyAbility do
                if GetUnitToLocationDistance(enemyAbility[i], iceBlast.location) <= radiusAbility
                then
                    if botTarget == enemyAbility[i] or enemyAbility[i]:GetHealth() <= (enemyAbility[i]:GetMaxHealth() / 100 * IceBlast:GetSpecialValueInt("kill_pct"))
                    then
                        --npcBot:ActionImmediate_Chat("Использую Release рядом с врагом!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    else
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                end
            end
        end
    end
end

function ConsiderIceBlast()
    local ability = IceBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local healthLimit = (ability:GetSpecialValueInt("kill_pct"));
    local enemyAbility = (GetUnitList(UNIT_LIST_ENEMY_HEROES));

    -- Generic use if can kill enemy hero
    for i = 1, #enemyAbility do
        if enemyAbility[i]:GetHealth() <= (enemyAbility[i]:GetMaxHealth() / 100 * healthLimit)
        then
            --npcBot:ActionImmediate_Chat("Использую IceBlast что бы добить врага!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemyAbility[i]:GetLocation();
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and botTarget:CanBeSeen()
        then
            --npcBot:ActionImmediate_Chat("Использую IceBlast по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
    end
end
