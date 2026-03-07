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
    Abilities[3],
    Abilities[1],
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
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Impetus = npcBot:GetAbilityByName("enchantress_impetus");
local Enchant = npcBot:GetAbilityByName("enchantress_enchant");
local NaturesAttendants = npcBot:GetAbilityByName("enchantress_natures_attendants");
local Sproink = npcBot:GetAbilityByName("enchantress_bunny_hop");
local LittleFriends = npcBot:GetAbilityByName("enchantress_little_friends");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    healingAllyHero = nil;

    ConsiderImpetus();
    local castEnchantDesire, castEnchantTarget = ConsiderEnchant();
    local castNaturesAttendantsDesire = ConsiderNaturesAttendants();
    local castSproinkDesire = ConsiderSproink();
    local castLittleFriendsDesire, castLittleFriendsTarget = ConsiderLittleFriends();

    if (castEnchantDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Enchant, castEnchantTarget);
        return;
    end

    if (castNaturesAttendantsDesire > 0)
    then
        npcBot:Action_UseAbility(NaturesAttendants);
        return;
    end

    if (castSproinkDesire > 0)
    then
        npcBot:Action_UseAbility(Sproink);
        return;
    end

    if (castLittleFriendsDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(LittleFriends, castLittleFriendsTarget);
        return;
    end

    HealingAlliesWithNaturesAttendants()
end

function HealingAlliesWithNaturesAttendants()
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot) or not utility.CanMove(npcBot) or not npcBot:HasModifier("modifier_enchantress_natures_attendants") or healingAllyHero == nil or
        healingAllyHero == npcBot
    then
        return;
    end

    local healingRadius = NaturesAttendants:GetSpecialValueInt("radius");

    if GetUnitToUnitDistance(npcBot, healingAllyHero) > healingRadius
    then
        npcBot:Action_MoveToUnit(healingAllyHero);
        return;
    else
        npcBot:Action_MoveToLocation(healingAllyHero:GetLocation() + RandomVector(healingRadius));
        return;
    end
end

function ConsiderImpetus()
    local ability = Impetus;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.IsNeedTurnOnAttackModifier()
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end
end

function ConsiderEnchant()
    local ability = Enchant;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local creepMaxLevel = ability:GetSpecialValueInt("level_req");
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange and
                GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200 and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Enchant для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsAncientCreep()
                    and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для подчинения крипа в атаке!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsAncientCreep()
                    and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для подчинения крипа отступая!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    -- Cast if push/defend/farm/roshan
    if utility.PvEMode(npcBot)
    then
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsAncientCreep()
                    and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для подчинения крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNaturesAttendants()
    local ability = NaturesAttendants;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);

    -- Use to heal damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.8)
                and not ally:HasModifier("modifier_enchantress_natures_attendants")
            then
                --npcBot:ActionImmediate_Chat("Использую NaturesAttendants!", true);
                healingAllyHero = ally;
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderSproink()
    local ability = Sproink;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();
    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if utility.IsHero(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if GetUnitToUnitDistance(npcBot, attackTarget) <= attackRange / 2
        then
            --npcBot:ActionImmediate_Chat("Использую Sproink для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.9) and not npcBot:IsFacingLocation(utility.GetFountainLocation(), 80)
        then
            --npcBot:ActionImmediate_Chat("Использую Sproink для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderLittleFriends()
    local ability = LittleFriends;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            local allyCreeps = botTarget:GetNearbyCreeps(radiusAbility, true);
            local enemyCreeps = botTarget:GetNearbyCreeps(radiusAbility, false);
            local unitAround = #allyCreeps + #enemyCreeps;
            if (unitAround > 3)
            then
                --npcBot:ActionImmediate_Chat("Использую LittleFriends для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local allyCreeps = enemy:GetNearbyCreeps(radiusAbility, true);
                    local enemyCreeps = enemy:GetNearbyCreeps(radiusAbility, false);
                    local unitAround = #allyCreeps + #enemyCreeps;
                    if (unitAround >= 3)
                    then
                        --npcBot:ActionImmediate_Chat("Использую LittleFriends для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
