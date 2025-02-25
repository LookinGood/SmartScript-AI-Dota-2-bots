---@diagnostic disable: undefined-global, redefined-local
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
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Earthshock = AbilitiesReal[1]
local Overpower = AbilitiesReal[2]
local Enrage = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castEarthshockDesire = ConsiderEarthshock();
    local castOverpowerDesire = ConsiderOverpower();
    local castEnrageDesire = ConsiderEnrage();

    if (castEarthshockDesire ~= nil)
    then
        npcBot:Action_UseAbility(Earthshock);
        return;
    end

    if (castOverpowerDesire ~= nil)
    then
        npcBot:Action_UseAbility(Overpower);
        return;
    end

    if (castEnrageDesire ~= nil)
    then
        npcBot:Action_UseAbility(Enrage);
        return;
    end
end

function ConsiderEarthshock()
    local ability = Earthshock;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("shock_radius") + ability:GetSpecialValueInt("hop_distance");
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:IsFacingLocation(enemy:GetLocation(), 10)
                then
                    --npcBot:ActionImmediate_Chat("Использую Earthshock что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                and npcBot:IsFacingLocation(botTarget:GetLocation(), 10) and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Earthshock по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
            and npcBot:DistanceFromFountain() > radiusAbility
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую Earthshock против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderOverpower()
    local ability = Overpower;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_ursa_overpower")
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)
        then
            if utility.CanCastSpellOnTarget(ability, attackTarget)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    if utility.PvEMode(npcBot)
    then
        if (ManaPercentage >= 0.5) and attackTarget:IsAncientCreep() and utility.CanCastSpellOnTarget(ability, attackTarget)
            and attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.4
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderEnrage()
    local ability = Enrage;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_ursa_enrage")
    then
        return;
    end

    if ((HealthPercentage <= 0.8) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0))) or utility.IsDisabled(npcBot)
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
end
