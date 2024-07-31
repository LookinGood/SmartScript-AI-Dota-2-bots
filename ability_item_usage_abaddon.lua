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
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local MistCoil = AbilitiesReal[1]
local AphoticShield = AbilitiesReal[2]
local BorrowedTime = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castMistCoilDesire, castMistCoilTarget = ConsiderMistCoil();
    local castAphoticShieldDesire, castAphoticShieldTarget = ConsiderAphoticShield();
    local castBorrowedTimeDesire = ConsiderBorrowedTime();

    if (castMistCoilDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(MistCoil, castMistCoilTarget);
        return;
    end

    if (castAphoticShieldDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(AphoticShield, castAphoticShieldTarget);
        return;
    end

    if (castBorrowedTimeDesire ~= nil)
    then
        npcBot:Action_UseAbility(BorrowedTime);
        return;
    end
end

function ConsiderMistCoil()
    local ability = MistCoil;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("target_damage");
    local radiusAbility = ability:GetSpecialValueInt("effect_radius");
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
                    --npcBot:ActionImmediate_Chat("Использую MistCoil что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
    -- Use to heal damaged ally
    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую MistCoil для лечения!", true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6) and (radiusAbility > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую MistCoil против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderAphoticShield()
    local ability = AphoticShield;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally) and not ally:HasModifier("modifier_abaddon_aphotic_shield")
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую AphoticShield на союзника рядом с врагом!",  true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end

        -- Safe ally hero
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_abaddon_aphotic_shield")
            then
                if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
                        (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0) or ally:WasRecentlyDamagedByCreep(2.0)))
                    or utility.IsDisabled(ally)
                then
                    --npcBot:ActionImmediate_Chat("Использую AphoticShield на союзника для защиты!",true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderBorrowedTime()
    local ability = BorrowedTime;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_abaddon_borrowed_time") or utility.TargetCantDie(npcBot)
    then
        return;
    end

    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if (HealthPercentage <= 0.3) and (#enemyAbility > 1) and npcBot:WasRecentlyDamagedByAnyHero(1.0)
    then
        --npcBot:ActionImmediate_Chat("Использую BorrowedTime!", true);
        return BOT_ACTION_DESIRE_VERYLOW;
    end
end
