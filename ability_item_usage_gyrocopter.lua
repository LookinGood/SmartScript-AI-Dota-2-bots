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
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Ability Use
function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    RocketBarrage = AbilitiesReal[1]
    HomingMissile = AbilitiesReal[2]
    FlakCannon = AbilitiesReal[3]
    CallDown = AbilitiesReal[6]

    castRocketBarrageDesire = ConsiderRocketBarrage();
    castHomingMissileDesire, castHomingMissileTarget = ConsiderHomingMissile();
    castFlakCannonDesire = ConsiderFlakCannon();
    castCallDownDesire, castCallDownLocation = ConsiderCallDown();

    if (castRocketBarrageDesire ~= nil)
    then
        npcBot:Action_UseAbility(RocketBarrage);
        return;
    end

    if (castHomingMissileDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(HomingMissile, castHomingMissileTarget);
        return;
    end

    if (castFlakCannonDesire ~= nil)
    then
        npcBot:Action_UseAbility(FlakCannon);
        return;
    end

    if (castCallDownDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(CallDown, castCallDownLocation);
        return;
    end
end

function ConsiderRocketBarrage()
    local ability = RocketBarrage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRadiusAbility = (ability:GetSpecialValueInt("radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую Rocket Barrage против врага в радиусе действия!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderHomingMissile()
    local ability = HomingMissile;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую HomingMissile что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if (utility.CanCastOnMagicImmuneTarget(botTarget)) and not utility.IsDisabled(botTarget) and
                GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
            then
                --npcBot:ActionImmediate_Chat("Использую Homing Missile по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy)) and utility.SafeCast(enemy, false)
                then
                    --npcBot:ActionImmediate_Chat("Использую Homing Missile что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderFlakCannon()
    local ability = FlakCannon;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local castRadiusAbility = (ability:GetSpecialValueInt("radius"));
    local enemyAbility = attackTarget:GetNearbyHeroes(castRadiusAbility, false, BOT_MODE_NONE);

    -- Cast if enemy hero at the range of attack
    if utility.PvPMode(npcBot)
    then
        if (attackTarget ~= nil and (#enemyAbility > 1))
        then
            if utility.IsHero(attackTarget) and (utility.CanCastOnInvulnerableTarget(attackTarget))
            then
                --npcBot:ActionImmediate_Chat("Использую Flak Cannon против нескольких врагов на дистанции атаки!",true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderCallDown()
    local ability = CallDown;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if enemy hero immobilized
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and utility.IsHero(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3) and
                utility.IsDisabled(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую Call Down против обездвиженного врага!",true);
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
            end
        end
    end

    -- Cast if enemy >=2
    if utility.PvPMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую CallDown по врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
