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
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local NaturesGrasp = npcBot:GetAbilityByName("treant_natures_grasp");
local LeechSeed = npcBot:GetAbilityByName("treant_leech_seed");
local LivingArmor = npcBot:GetAbilityByName("treant_living_armor");
local NaturesGuise = npcBot:GetAbilityByName("treant_natures_guise");
local EyesInTheForest = npcBot:GetAbilityByName("treant_eyes_in_the_forest");
local Overgrowth = npcBot:GetAbilityByName("treant_overgrowth");

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
    local castNaturesGuiseDesire = ConsiderNaturesGuise();
    local castEyesInTheForestDesire, castEyesInTheForestTarget = ConsiderEyesInTheForest();
    local castOvergrowthDesire = ConsiderOvergrowth();

    if (castNaturesGraspDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(NaturesGrasp, castNaturesGraspLocation);
        return;
    end

    if (castLeechSeedDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(LeechSeed, castLeechSeedTarget);
        return;
    end

    if (castLivingArmorDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(LivingArmor, castLivingArmorTarget);
        return;
    end

    if (castNaturesGuiseDesire > 0)
    then
        npcBot:Action_UseAbility(NaturesGuise);
        return;
    end

    if (castEyesInTheForestDesire > 0)
    then
        npcBot:Action_UseAbilityOnTree(EyesInTheForest, castEyesInTheForestTarget);
        return;
    end

    if (castOvergrowthDesire > 0)
    then
        npcBot:Action_UseAbility(Overgrowth);
        return;
    end
end

function ConsiderNaturesGrasp()
    local ability = NaturesGrasp;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("latch_range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:HasModifier("modifier_treant_natures_grasp_damage")
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_treant_natures_grasp_damage")
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7) and not enemy:HasModifier("modifier_treant_natures_grasp_damage")
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLeechSeed()
    local ability = LeechSeed;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:IsDisarmed()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = npcBot:GetAttackRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(ability, botTarget)
        and not utility.IsDisabled(botTarget)
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую LeechSeed что бы сбить заклинание: " .. enemy:GetUnitName(),
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLivingArmor()
    local ability = LivingArmor;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
            if (not ally:HasModifier("modifier_treant_living_armor") and ally:GetHealth() < ally:GetMaxHealth()) and
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNaturesGuise()
    local ability = NaturesGuise;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:IsInvisible()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and (GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 3000)
        then
            --npcBot:ActionImmediate_Chat("Использую NaturesGuise для нападения!", true);
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую NaturesGuise для отхода!", true);
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderEyesInTheForest()
    local ability = EyesInTheForest;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("vision_aoe");
    local allyTowers = npcBot:GetNearbyTowers(radiusAbility, false);
    local enemyTowers = npcBot:GetNearbyTowers(radiusAbility, true);
    local treantWards = utility.CountUnitAroundTarget(npcBot, "npc_dota_treant_eyes", false, radiusAbility);
    local trees = npcBot:GetNearbyTrees(castRangeAbility);

    if (#trees > 0 and treantWards <= 0 and #allyTowers <= 0 and #enemyTowers <= 0) and not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot)
        and (ManaPercentage >= 0.7) and npcBot:DistanceFromFountain() >= 2000
    then
        for _, tree in pairs(trees)
        do
            if (IsLocationVisible(GetTreeLocation(tree)) or IsLocationPassable(GetTreeLocation(tree)))
            then
                --npcBot:ActionImmediate_Chat("Использую EyesInTheForest, количество моих вардов рядом: " .. treantWards, true);
                return BOT_ACTION_DESIRE_VERYHIGH, tree;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderOvergrowth()
    local ability = Overgrowth;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
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

    return BOT_ACTION_DESIRE_NONE;
end
