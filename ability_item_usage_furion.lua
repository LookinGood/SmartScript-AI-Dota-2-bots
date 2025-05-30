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
    Abilities[3],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Sprout = AbilitiesReal[1]
local Teleportation = AbilitiesReal[2]
local NaturesCall = AbilitiesReal[3]
local CurseOfTheOldgrowth = AbilitiesReal[4]
local WrathOfNature = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSproutDesire, castSproutTarget, castSproutTargetType = ConsiderSprout();
    local castTeleportationDesire, castTeleportationLocation = ConsiderTeleportation();
    local castNaturesCallDesire, castNaturesCallLocation, castNaturesCallTargetType = ConsiderNaturesCall();
    local castCurseOfTheOldgrowthDesire = ConsiderCurseOfTheOldgrowth();
    local castWrathOfNatureDesire, castWrathOfNatureTarget = ConsiderWrathOfNature();

    if (castSproutDesire > 0)
    then
        if (castSproutTargetType == "combo")
        then
            npcBot:Action_ClearActions(true);
            npcBot:ActionQueue_UseAbilityOnLocation(Sprout, castSproutTarget);
            npcBot:ActionQueue_UseAbilityOnLocation(Teleportation, utility.SafeLocation(npcBot));
            return;
        else
            npcBot:Action_UseAbilityOnLocation(Sprout, castSproutTarget);
            return;
        end
    end

    if (castTeleportationDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Teleportation, castTeleportationLocation);
        return;
    end

    if (castNaturesCallDesire > 0)
    then
        if (castNaturesCallTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(NaturesCall, castNaturesCallLocation);
            return;
        else
            npcBot:Action_UseAbilityOnTree(NaturesCall, castNaturesCallLocation);
            return;
        end
    end

    if (castCurseOfTheOldgrowthDesire > 0)
    then
        npcBot:Action_UseAbility(CurseOfTheOldgrowth);
        return;
    end

    if (castWrathOfNatureDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(WrathOfNature, castWrathOfNatureTarget);
        return;
    end
end

function ConsiderSprout()
    local ability = Sprout;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("sprout_damage_per_second") * ability:GetSpecialValueInt("duration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Sprout что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                        nil;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and not utility.IsDisabled(botTarget)
                and not botTarget:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Sprout для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0), nil;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            if utility.IsAbilityAvailable(Teleportation) and npcBot:GetMana() > (ability:GetManaCost() + Teleportation:GetManaCost())
            then
                --npcBot:ActionImmediate_Chat("Использую Sprout для отступления в комбе с телепортом!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, npcBot:GetLocation(), "combo";
            else
                for _, enemy in pairs(enemyAbility) do
                    if not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Sprout для отступления!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), nil;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end

function ConsiderTeleportation()
    local ability = Teleportation;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local shouldTP, tpLocation = teleportation_usage_generic.ShouldTP();
    
    if shouldTP
    then
        --npcBot:ActionImmediate_Chat("Использую Teleportation!", true);
        return BOT_ACTION_DESIRE_HIGH, tpLocation;
    end


    -- Cast if attack enemy
    if utility.IsValidTarget(botTarget)
    then
        if GetUnitToUnitDistance(npcBot, botTarget) >= 2000
        then
            local allyHeroes = botTarget:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
            if (#allyHeroes >= 2)
            then
                --npcBot:ActionImmediate_Chat("Использую Teleportation на врага!", true);
                return BOT_MODE_DESIRE_HIGH, allyHeroes[1]:GetLocation();
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderNaturesCall()
    local ability = NaturesCall;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    --local radiusAbility = ability:GetSpecialValueInt("radius");
    local maxUnits = ability:GetSpecialValueInt("max_treants") / 2;
    local trees = npcBot:GetNearbyTrees(castRangeAbility + 200);

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget)
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    if #trees >= (maxUnits - maxUnits % 1)
                    then
                        --npcBot:ActionImmediate_Chat("Использую NaturesCall для атаки по точке!", true);
                        return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[2]), "location";
                    end
                else
                    if (#trees > 0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую NaturesCall для атаки по дереву!", true);
                        return BOT_ACTION_DESIRE_HIGH, trees[1], nil;
                    end
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTower = npcBot:GetNearbyTowers(1600, true);
        if (#enemyCreeps > 1 or #enemyTower > 0)
        then
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                if #trees >= (maxUnits - maxUnits % 1)
                then
                    --npcBot:ActionImmediate_Chat("Использую NaturesCall в pve по точке!", true);
                    return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[2]), "location";
                end
            else
                if (#trees > 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую NaturesCall в pve по дереву!", true);
                    return BOT_ACTION_DESIRE_HIGH, trees[1], nil;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0, 0;
end

function ConsiderCurseOfTheOldgrowth()
    local ability = CurseOfTheOldgrowth;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local trees = enemy:GetNearbyTrees(radiusAbility);
                    local treants = utility.CountUnitAroundTarget(enemy, "npc_dota_furion_treant", false, radiusAbility);
                    if (#trees > 1 or treants > 1)
                    then
                        --npcBot:ActionImmediate_Chat("Использую CurseOfTheOldgrowth против врага в радиусе действия!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderWrathOfNature()
    local ability = WrathOfNature;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую WrathOfNature что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if (#enemyAbility > 1)
            then
                for _, enemy in pairs(enemyAbility) do
                    if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(enemy, botTarget) >= 5000
                    then
                        --npcBot:ActionImmediate_Chat("Использую WrathOfNature по дальнему герою!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
                end
            end
            local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
            if (#enemyCreeps > 0)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(enemy, botTarget) >= 5000
                    then
                        --npcBot:ActionImmediate_Chat("Использую WrathOfNature по дальнему крипу!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
