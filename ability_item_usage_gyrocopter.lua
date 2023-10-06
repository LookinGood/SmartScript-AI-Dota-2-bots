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
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local RocketBarrage = AbilitiesReal[1]
local HomingMissile = AbilitiesReal[2]
local FlakCannon = AbilitiesReal[3]
local CallDown = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castRocketBarrageDesire = ConsiderRocketBarrage();
    local castHomingMissileDesire, castHomingMissileTarget = ConsiderHomingMissile();
    local castFlakCannonDesire = ConsiderFlakCannon();
    local castCallDownDesire, castCallDownLocation = ConsiderCallDown();

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
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую HomingMissile по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую HomingMissile что бы оторваться от врага", true);
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
    local castRadiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = attackTarget:GetNearbyHeroes(castRadiusAbility, false, BOT_MODE_NONE);

    -- Cast if enemy hero at the range of attack
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 1)
        then
            if utility.IsHero(attackTarget) and utility.CanCastSpellOnTarget(ability, attackTarget)
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
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if enemy hero immobilized
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and utility.IsHero(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3) and
                utility.IsDisabled(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую Call Down против обездвиженного врага!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
            end
        end
    end

    -- Cast if enemy >=2
    if utility.PvPMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую CallDown по врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
