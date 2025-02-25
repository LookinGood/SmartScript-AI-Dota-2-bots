---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")
--require(GetScriptDirectory() .. "/minion_generic")

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
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SummonSpiritBear = AbilitiesReal[1]
local SpiritLink = AbilitiesReal[2]
local SavageRoar = AbilitiesReal[3]
local TrueForm = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSummonSpiritBearDesire = ConsiderSummonSpiritBear();
    local castSpiritLinkDesire, castSpiritLinkTarget = ConsiderSpiritLink();
    local castSavageRoarDesire = ConsiderSavageRoar();
    local castTrueFormDesire = ConsiderTrueForm();

    if (castSummonSpiritBearDesire ~= nil)
    then
        npcBot:Action_UseAbility(SummonSpiritBear);
        return;
    end

    if (castSpiritLinkDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SpiritLink, castSpiritLinkTarget);
        return;
    end

    if (castSavageRoarDesire ~= nil)
    then
        npcBot:Action_UseAbility(SavageRoar);
        return;
    end

    if (castTrueFormDesire ~= nil)
    then
        npcBot:Action_UseAbility(TrueForm);
        return;
    end
end

-- Bear is Hero

local function IsBear(npcTarget)
    return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "npc_dota_lone_druid_bear");
end

local function CountBears()
    local count = 0;
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if IsBear(ally) and ally:GetPlayerID() == npcBot:GetPlayerID()
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function ConsiderSummonSpiritBear()
    local ability = SummonSpiritBear;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local maxUnits = 1;

    if CountBears() >= maxUnits
    then
        return;
    end

    return BOT_ACTION_DESIRE_HIGH;

    --[[     -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTowers = npcBot:GetNearbyTowers(1600, true);
        local enemyBarracks = npcBot:GetNearbyBarracks(1600, true);
        local enemyAncient = GetAncient(GetOpposingTeam());
        if (ManaPercentage >= 0.4) and
            ((#enemyCreeps > 0) or
                (#enemyTowers > 0) or
                (#enemyBarracks > 0) or
                npcBot:GetAttackTarget() == enemyAncient)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end ]]
end

function ConsiderSpiritLink()
    local ability = SpiritLink;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and not ally:HasModifier("modifier_lone_druid_spirit_link")
            then
                if utility.PvPMode(npcBot)
                then
                    if utility.IsHero(botTarget)
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() * 2
                        then
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end
    end
end

function ConsiderSavageRoar()
    local ability = SavageRoar;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local bears = utility.CountUnitAroundTarget(enemy, "npc_dota_lone_druid_bear", false, radiusAbility);
                    if (bears > 0)
                    then
                        npcBot:ActionImmediate_Chat("Использую SavageRoar(Медведь) сбивая каст " .. enemy:GetUnitName(),
                            true);
                        return BOT_ACTION_DESIRE_ABSOLUTE;
                    end
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    local bears = utility.CountUnitAroundTarget(enemy, "npc_dota_lone_druid_bear", false, radiusAbility);
                    if (bears > 0)
                    then
                        npcBot:ActionImmediate_Chat("Использую SavageRoar(Медведь) против " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderTrueForm()
    local ability = TrueForm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_lone_druid_true_form")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= 1000
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

        -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage < 0.5)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
