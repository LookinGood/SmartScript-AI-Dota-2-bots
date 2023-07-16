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

    Impetus = AbilitiesReal[1]
    Enchant = AbilitiesReal[2]
    NaturesAttendants = AbilitiesReal[3]
    Sproink = AbilitiesReal[4]
    LittleFriends = AbilitiesReal[5]

    ConsiderImpetus();
    castEnchantDesire, castEnchantTarget = ConsiderEnchant();
    castNaturesAttendantsDesire = ConsiderNaturesAttendants();
    castSproinkDesire = ConsiderSproink();
    castLittleFriendsDesire, castLittleFriendsTarget = ConsiderLittleFriends();

    if (castEnchantDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Enchant, castEnchantTarget);
        return;
    end

    if (castNaturesAttendantsDesire ~= nil)
    then
        npcBot:Action_UseAbility(NaturesAttendants);
        return;
    end

    if (castSproinkDesire ~= nil)
    then
        npcBot:Action_UseAbility(Sproink);
        return;
    end

    if (castLittleFriendsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LittleFriends, castLittleFriendsTarget);
        return;
    end
end

function ConsiderImpetus()
    local ability = Impetus;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if attackTarget ~= nil and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)
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

function ConsiderEnchant()
    local ability = Enchant;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local creepMaxLevel = ability:GetSpecialValueInt("level_req");
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and not utility.IsDisabled(botTarget)
            and utility.SafeCast(botTarget, false)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                --npcBot:ActionImmediate_Chat("Использую Enchant для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                if (#enemyCreeps > 0)
                then
                    for _, enemy in pairs(enemyCreeps) do
                        if utility.CanCastOnMagicImmuneTarget(enemy) and not enemy:IsAncientCreep() and utility.SafeCast(enemy, true)
                            and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                        then
                            --npcBot:ActionImmediate_Chat("Использую Enchant для подчинения крипа в атаке!",true);
                            return BOT_ACTION_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot)
    then
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not enemy:IsAncientCreep() and utility.SafeCast(enemy, true)
                and (enemy:GetLevel() <= creepMaxLevel and (enemy:GetLevel() > 1))
                then
                    --npcBot:ActionImmediate_Chat("Использую Enchant для подчинения крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderNaturesAttendants()
    local ability = NaturesAttendants;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);

    -- Use to buff damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую NaturesAttendants!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderSproink()
    local ability = Sproink;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local attackTarget = npcBot:GetAttackTarget();

    -- Attack use
    if attackTarget ~= nil and utility.IsHero(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if GetUnitToUnitDistance(npcBot, attackTarget) <= attackRange / 2
        then
            --npcBot:ActionImmediate_Chat("Использую Sproink для атаки!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (HealthPercentage <= 0.8) and not npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 80)
        then
            --npcBot:ActionImmediate_Chat("Использую Sproink для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderLittleFriends()
    local ability = LittleFriends;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and utility.SafeCast(botTarget, false)
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
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
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
end
