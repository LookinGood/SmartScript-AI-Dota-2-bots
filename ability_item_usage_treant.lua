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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[3],
    Abilities[1],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local NaturesGrasp = AbilitiesReal[1]
local LeechSeed = AbilitiesReal[2]
local LivingArmor = AbilitiesReal[3]
local EyesInTheForest = AbilitiesReal[4]
local Overgrowth = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castNaturesGraspDesire, castNaturesGraspLocation = ConsiderNaturesGrasp();
    local castLeechSeedDesire, castLeechSeedTarget = ConsiderLeechSeed();
    local castLivingArmorDesire, castLivingArmorTarget = ConsiderLivingArmor();
    local castEyesInTheForestDesire, castEyesInTheForestTarget = ConsiderEyesInTheForest();
    local castOvergrowthDesire = ConsiderOvergrowth();

    if (castNaturesGraspDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(NaturesGrasp, castNaturesGraspLocation);
        return;
    end

    if (castLeechSeedDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LeechSeed, castLeechSeedTarget);
        return;
    end

    if (castLivingArmorDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LivingArmor, castLivingArmorTarget);
        return;
    end

    if (castEyesInTheForestDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnTree(EyesInTheForest, castEyesInTheForestTarget);
        return;
    end

    if (castOvergrowthDesire ~= nil)
    then
        npcBot:Action_UseAbility(Overgrowth);
        return;
    end
end

function ConsiderNaturesGrasp()
    local ability = NaturesGrasp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("latch_range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not botTarget:HasModifier("modifier_treant_natures_grasp_damage")
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_treant_natures_grasp_damage")
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7) and not enemy:HasModifier("modifier_treant_natures_grasp_damage")
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderLeechSeed()
    local ability = LeechSeed;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("leech_damage") * ability:GetSpecialValueInt("duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LeechSeed что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:HasModifier("modifier_treant_leech_seed")
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_treant_leech_seed")
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 3) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_treant_leech_seed")
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (ManaPercentage >= 0.7)
        then
            local enemy = utility.GetWeakest(enemyAbility);
            if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_treant_leech_seed")
            then
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end
end

function ConsiderLivingArmor()
    local ability = LivingArmor;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);
    local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_treant_living_armor")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8
                then
                    --npcBot:ActionImmediate_Chat("Использую LivingArmor на союзного героя!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Cast to buff ally buildings
    if (#allyBuildings > 0) and not utility.RetreatMode(npcBot)
    then
        for _, ally in pairs(allyBuildings)
        do
            if not ally:HasModifier("modifier_treant_living_armor") and ally:GetHealth() < ally:GetMaxHealth() and
                (ally:IsTower() or ally:IsBarracks() or ally:IsFort())
            then
                --npcBot:ActionImmediate_Chat("Использую living armor на союзное здание!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end

    --local allyAncient = GetAncient(GetTeam());
    --[[     if GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility
    then
        if not allyAncient:HasModifier("modifier_ogre_magi_smash_buff") and utility.IsTargetedByEnemy(allyAncient, true)
        then
            --npcBot:ActionImmediate_Chat("Использую FireShield на ДРЕВНЕГО!", true);
            return BOT_MODE_DESIRE_HIGH, allyAncient;
        end
    end ]]
end

function ConsiderEyesInTheForest()
    local ability = EyesInTheForest;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local trees = npcBot:GetNearbyTrees(castRangeAbility * 2);

    if (#trees > 0) and not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot)
        and (ManaPercentage >= 0.7)
    then
        for _, tree in pairs(trees)
        do
            if (IsLocationVisible(GetTreeLocation(tree)) or IsLocationPassable(GetTreeLocation(tree))) and
                GetUnitToLocationDistance(botTarget, GetTreeLocation(tree)) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую EyesInTheForest!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, tree;
            end
        end
    end
end

function ConsiderOvergrowth()
    local ability = Overgrowth;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Use in teamfight/retreat
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility >= 2)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Overgrowth!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
