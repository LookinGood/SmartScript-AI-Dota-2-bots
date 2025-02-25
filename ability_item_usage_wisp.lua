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
local Abilities, Talents, AbilitiesReal = ability_levelup_generic.GetHeroAbilities(npcBot);

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
    Talents[5],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Tether = AbilitiesReal[1]
local BreakTether = npcBot:GetAbilityByName("wisp_tether_break");
local Spirits = AbilitiesReal[2]
local Overcharge = AbilitiesReal[3]
local SpiritsIn = AbilitiesReal[4]
local SpiritsOut = AbilitiesReal[5]
local Relocate = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    boundAlly = GetBoundAlly();
    --[[    if boundAlly ~= nil
    then
        print(boundAlly:GetUnitName())
    end ]]

    local castTetherDesire, castTetherTarget = ConsiderTether();
    local castBreakTetherDesire = ConsiderBreakTether();
    local castSpiritsDesire = ConsiderSpirits();
    local castOverchargeDesire = ConsiderOvercharge();
    local castSpiritsInDesire = ConsiderSpiritsIn();
    local castSpiritsOutDesire = ConsiderSpiritsOut();
    local castRelocateDesire, castRelocateLocation = ConsiderRelocate();

    if (castTetherDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Tether, castTetherTarget);
        return;
    end

    if (castBreakTetherDesire ~= nil)
    then
        npcBot:Action_UseAbility(BreakTether);
        return;
    end

    if (castSpiritsDesire ~= nil)
    then
        npcBot:Action_UseAbility(Spirits);
        return;
    end

    if (castOverchargeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Overcharge);
        return;
    end

    if (castSpiritsInDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpiritsIn);
        return;
    end

    if (castSpiritsOutDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpiritsOut);
        return;
    end

    if (castRelocateDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Relocate, castRelocateLocation);
        return;
    end
end

function GetBoundAlly()
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes) do
            if ally:HasModifier("modifier_wisp_tether_haste")
            then
                return ally;
            end
        end
    end

    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if ally:HasModifier("modifier_wisp_tether_haste")
            then
                return ally;
            end
        end
    end

    return nil;
end

function ConsiderTether()
    local ability = Tether;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_wisp_tether")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local boundRange = ability:GetSpecialValueInt("latch_distance");
    local allyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), false, BOT_MODE_NONE);
    local allyCreeps = npcBot:GetNearbyCreeps(utility.GetCurrentCastDistance(castRangeAbility), false);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility)
                do
                    if ally ~= npcBot and not utility.IsIllusion(ally) and
                        (GetUnitToUnitDistance(ally, botTarget) <= GetUnitToUnitDistance(npcBot, botTarget) or ally:GetAttackTarget() == botTarget)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Tether на союзного героя " .. ally:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            else
                if (#allyCreeps > 0)
                then
                    for _, ally in pairs(allyCreeps)
                    do
                        if (GetUnitToUnitDistance(ally, botTarget) <= GetUnitToUnitDistance(npcBot, botTarget) or ally:GetAttackTarget() == botTarget)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Tether на союзного крипа " .. ally:GetUnitName(), true);
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
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local fountainLocation = utility.SafeLocation(npcBot);
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility) do
                    if ally ~= npcBot and GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > boundRange)
                    then
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > boundRange)
                    then
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        if (#allyAbility > 1)
        then
            for _, ally in pairs(allyAbility)
            do
                if ally ~= npcBot and not utility.IsIllusion(ally)
                then
                    --npcBot:ActionImmediate_Chat("Использую Tether в pve моде на " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local laningLocation = GetLaneFrontLocation(npcBot:GetTeam(), npcBot:GetAssignedLane(), 0);
        if GetUnitToLocationDistance(npcBot, laningLocation) <= castRangeAbility
        then
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility)
                do
                    if ally ~= npcBot and not utility.IsIllusion(ally)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Tether на лайне на " .. ally:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
end

function ConsiderBreakTether()
    local ability = BreakTether;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if boundAlly ~= nil and boundAlly:IsHero()
    then
        return;
    end

    local allyAbility = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);

    if utility.PvPMode(npcBot) or utility.BossMode(npcBot) or botMode == BOT_MODE_LANING
    then
        if (#allyAbility > 1)
        then
            --npcBot:ActionImmediate_Chat("Использую BreakTether!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderSpirits()
    local ability = Spirits;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_wisp_spirits")
    then
        return;
    end

    --local minRangeAbility = ability:GetSpecialValueInt("min_range");
    local maxRangeAbility = ability:GetSpecialValueInt("max_range");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= maxRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(maxRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(maxRangeAbility, true);
        if (#enemyCreeps > 3) and (ManaPercentage >= 0.5)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderOvercharge()
    local ability = Overcharge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_wisp_overcharge")
    then
        return;
    end

    -- Heal use
    if (HealthPercentage <= 0.5) or (boundAlly ~= nil and boundAlly:GetHealth() / boundAlly:GetMaxHealth() <= 0.5)
    then
        --npcBot:ActionImmediate_Chat("Использую Overcharge для лечения!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if not utility.IsTargetInvulnerable(botTarget) and (npcBot:GetAttackTarget() == botTarget or (boundAlly ~= nil and boundAlly:GetAttackTarget() == botTarget))
            then
                --npcBot:ActionImmediate_Chat("Использую Overcharge для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

local function IsEnemyHeroUnderSpirits()
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if enemy:HasModifier("modifier_wisp_spirits_slow")
            then
                return true;
            end
        end
    end

    return false;
end

function ConsiderSpiritsIn()
    local ability = SpiritsIn;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if SpiritsOut:GetToggleState() == true
    then
        return;
    end

    if IsEnemyHeroUnderSpirits()
    then
        if ability:GetToggleState() == true
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    local minRangeAbility = Spirits:GetSpecialValueInt("min_range");
    local maxRangeAbility = Spirits:GetSpecialValueInt("max_range");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(Spirits, botTarget) and (utility.IsHero(botTarget) or utility.IsBoss(botTarget))
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= minRangeAbility
            then
                if ability:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            else
                if ability:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        else
            if ability:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(maxRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= minRangeAbility
                    then
                        if ability:GetToggleState() == false
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    else
                        if ability:GetToggleState() == true
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        else
            if ability:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderSpiritsOut()
    local ability = SpiritsOut;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if SpiritsIn:GetToggleState() == true
    then
        return;
    end

    if IsEnemyHeroUnderSpirits()
    then
        if ability:GetToggleState() == true
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    --local minRangeAbility = Spirits:GetSpecialValueInt("min_range");
    local maxRangeAbility = Spirits:GetSpecialValueInt("max_range");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(Spirits, botTarget) and (utility.IsHero(botTarget) or utility.IsBoss(botTarget))
        then
            if GetUnitToUnitDistance(npcBot, botTarget) == maxRangeAbility
            then
                if ability:GetToggleState() == false
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            else
                if ability:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        else
            if ability:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(maxRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) == maxRangeAbility
                    then
                        if ability:GetToggleState() == false
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    else
                        if ability:GetToggleState() == true
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        else
            if ability:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderRelocate()
    local ability = Relocate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Safe use
    if npcBot:DistanceFromFountain() > 3000
    then
        if (HealthPercentage <= 0.4 and npcBot:WasRecentlyDamagedByAnyHero(2.0)) or
            (boundAlly ~= nil and (boundAlly:GetHealth() / boundAlly:GetMaxHealth() <= 0.3 and boundAlly:WasRecentlyDamagedByAnyHero(2.0)))
        then
            --npcBot:ActionImmediate_Chat("Использую Relocate для побега!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetFountainLocation() + RandomVector(100);
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) >= 3000 and boundAlly ~= nil
            then
                local allyHeroes = botTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
                if (#allyHeroes > 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Relocate на врага!", true);
                    return BOT_MODE_DESIRE_HIGH, allyHeroes[1]:GetLocation();
                end
            end
        end
    end
end
