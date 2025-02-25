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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Swashbuckle = AbilitiesReal[1]
local ShieldCrash = AbilitiesReal[2]
local RollUp = AbilitiesReal[4]
local RollingThunder = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSwashbuckleDesire, castSwashbuckleLocation = ConsiderSwashbuckle();
    local castShieldCrashDesire = ConsiderShieldCrash();
    local castRollUpDesire = ConsiderRollUp();
    local castRollingThunderDesire = ConsiderRollingThunder();

    if (castSwashbuckleDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Swashbuckle, castSwashbuckleLocation);
        return;
    end

    if (castShieldCrashDesire ~= nil)
    then
        npcBot:Action_UseAbility(ShieldCrash);
        return;
    end

    if (castRollUpDesire ~= nil)
    then
        npcBot:Action_UseAbility(RollUp);
        return;
    end

    if (castRollingThunderDesire ~= nil)
    then
        npcBot:Action_UseAbility(RollingThunder);
        return;
    end
end

function ConsiderSwashbuckle()
    local ability = Swashbuckle;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_pangolier_gyroshell")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("end_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("dash_speed");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Swashbuckle по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderShieldCrash()
    local ability = ShieldCrash;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("jump_horizontal_distance") +
        ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShieldCrash что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget) and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую ShieldCrash по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
            and npcBot:DistanceFromFountain() >= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую ShieldCrash для отхода!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderRollUp()
    local ability = RollUp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not utility.CanCastOnMagicImmuneTarget(npcBot) or npcBot:HasModifier("modifier_pangolier_gyroshell")
    then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую RollUp для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderRollingThunder()
    local ability = RollingThunder;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_pangolier_gyroshell")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2) and GetUnitToUnitDistance(npcBot, botTarget) < 2000
            and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую RollingThunder для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    --Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую RollingThunder для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
