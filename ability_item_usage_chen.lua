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
    Abilities[3],
    Abilities[2],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[4],
    Abilities[1],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Penitence = AbilitiesReal[1]
local HolyPersuasion = AbilitiesReal[2]
local DivineFavor = AbilitiesReal[3]
local SummonConvert = AbilitiesReal[4]
local HandOfGod = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castPenitenceDesire, castPenitenceTarget = ConsiderPenitence();
    local castHolyPersuasionDesire, castHolyPersuasionTarget = ConsiderHolyPersuasion();
    local castDivineFavorDesire, castDivineFavorTarget = ConsiderDivineFavor();
    local castSummonConvertDesire = ConsiderSummonConvert();
    local castHandOfGodDesire = ConsiderHandOfGod();

    if (castPenitenceDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Penitence, castPenitenceTarget);
        return;
    end

    if (castHolyPersuasionDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(HolyPersuasion, castHolyPersuasionTarget);
        return;
    end

    if (castDivineFavorDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(DivineFavor, castDivineFavorTarget);
        return;
    end

    if (castSummonConvertDesire > 0)
    then
        npcBot:Action_UseAbility(SummonConvert);
        return;
    end

    if (castHandOfGodDesire > 0)
    then
        npcBot:Action_UseAbility(HandOfGod);
        return;
    end
end

function ConsiderPenitence()
    local ability = Penitence;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Penitence что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true)
        if (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

local function CreepUnderControlCount()
    local count = 0;
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);

    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if ally:GetTeam() == npcBot:GetTeam() and ally:HasModifier("modifier_chen_holy_persuasion")
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function IsCatapult(npcTarget)
    return IsValidTarget(npcTarget) and
        string.find(npcTarget:GetUnitName(), "siege");
end

function ConsiderHolyPersuasion()
    local ability = HolyPersuasion;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local creepMax = ability:GetSpecialValueInt("max_units");
    local creepMaxLevel = ability:GetSpecialValueInt("level_req");

    if CreepUnderControlCount() >= creepMax
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot) or botMode ~= BOT_MODE_LANING
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        local enemy = utility.GetStrongest(enemyCreeps);
        if utility.CanCastSpellOnTarget(ability, enemy) and enemy:GetLevel() <= creepMaxLevel and not enemy:IsAncientCreep() and not IsCatapult(enemy)
        then
            return BOT_ACTION_DESIRE_HIGH, enemy;
        end
    else
        local enemyCreeps = npcBot:GetNearbyNeutralCreeps(1600);
        local enemy = utility.GetStrongest(enemyCreeps);
        if utility.CanCastSpellOnTarget(ability, enemy) and enemy:GetLevel() <= creepMaxLevel and not enemy:IsAncientCreep() and not IsCatapult(enemy)
        then
            return BOT_ACTION_DESIRE_HIGH, enemy;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDivineFavor()
    local ability = DivineFavor;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyHeroes = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);

    -- Cast to heal ally hero
    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую DivineFavor на союзного героя со здоровьем ниже 80%", true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    -- Cast if controlled creep too far away
    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if ally:HasModifier("modifier_chen_holy_persuasion") and GetUnitToUnitDistance(npcBot, ally) >= 3000
                and (ally:TimeSinceDamagedByAnyHero() >= 5.0 and ally:TimeSinceDamagedByCreep() >= 5.0)
            then
                --npcBot:ActionImmediate_Chat("Использую DivineFavor что бы присумонить союзного крипа!", true);
                return BOT_ACTION_DESIRE_HIGH, npcBot;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSummonConvert()
    local ability = SummonConvert;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local creepMax = HolyPersuasion:GetSpecialValueInt("max_units");

    if CreepUnderControlCount() >= creepMax
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- General use
    if not utility.RetreatMode(npcBot) and botMode ~= BOT_MODE_LANING and botMode ~= BOT_MODE_WARD
    then
        --npcBot:ActionImmediate_Chat("Использую SummonConvert!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderHandOfGod()
    local ability = HandOfGod;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Cast to heal ally hero
    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.5)
                and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0) or ally:WasRecentlyDamagedByCreep(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую HandOfGod для лечения " .. ally:GetUnitName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
