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

    local castSproutDesire, castSproutTarget, castSproutType = ConsiderSprout();
    local castTeleportationDesire, castTeleportationLocation = ConsiderTeleportation();
    local castNaturesCallDesire, castNaturesCallLocation = ConsiderNaturesCall();
    local castCurseOfTheOldgrowthDesire = ConsiderCurseOfTheOldgrowth();
    local castWrathOfNatureDesire, castWrathOfNatureTarget, castWrathOfNatureTargetType = ConsiderWrathOfNature();

    if (castSproutDesire ~= nil)
    then
        if (castSproutType == "combo")
        then
            npcBot:Action_ClearActions(true);
            npcBot:ActionQueue_UseAbilityOnEntity(Sprout, npcBot);
            npcBot:ActionQueue_UseAbilityOnLocation(Teleportation, utility.SafeLocation(npcBot));
            return;
        elseif (castSproutType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Sprout, castSproutTarget);
            return;
        elseif (castSproutType == "nil")
        then
            npcBot:Action_UseAbilityOnLocation(Sprout, castSproutTarget);
            return;
        end
    end

    if (castTeleportationDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Teleportation, castTeleportationLocation);
        return;
    end

    if (castNaturesCallDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(NaturesCall, castNaturesCallLocation);
        return;
    end

    if (castCurseOfTheOldgrowthDesire ~= nil)
    then
        npcBot:Action_UseAbility(CurseOfTheOldgrowth);
        return;
    end

    if (castWrathOfNatureDesire ~= nil)
    then
        if (castWrathOfNatureTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(WrathOfNature, castWrathOfNatureTarget);
            return;
        elseif (castWrathOfNatureTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(WrathOfNature, castWrathOfNatureTarget);
            return;
        end
    end
end

function ConsiderSprout()
    local ability = Sprout;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and not utility.IsDisabled(botTarget)
                and not botTarget:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Sprout для атаки!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget, "target";
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            if utility.IsAbilityAvailable(Teleportation) and npcBot:GetMana() >= ability:GetManaCost() + Teleportation:GetManaCost()
            then
                --npcBot:ActionImmediate_Chat("Использую Sprout для отступления в комбе с телепортом!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, nil, "combo";
            else
                for _, enemy in pairs(enemyAbility) do
                    if not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Sprout для отступления!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), "nil";
                    end
                end
            end
        end
    end
end

function ConsiderTeleportation()
    local ability = Teleportation;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local tps = npcBot:GetItemInSlot(15);
    if tps == nil or not tps:IsFullyCastable()
    then
        local tpLocation = nil;
        local shouldTP = false;

        shouldTP, tpLocation = teleportation_usage_generic.ShouldTP()

        if shouldTP
        then
            --npcBot:ActionImmediate_Chat("Использую Teleportation!", true);
            return BOT_ACTION_DESIRE_HIGH, tpLocation;
        end
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
end

function ConsiderNaturesCall()
    local ability = NaturesCall;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local radiusAbility = ability:GetSpecialValueInt("radius");
    local maxUnits = ability:GetSpecialValueInt("max_treants") / 2;
    local trees = npcBot:GetNearbyTrees(castRangeAbility + 200);

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget)
            then
                if #trees >= (maxUnits - maxUnits % 1)
                then
                    --npcBot:ActionImmediate_Chat("Использую NaturesCall для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[1]);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTower = npcBot:GetNearbyTowers(1600, true);
        if (#enemyCreeps > 1 or #enemyTower > 0)
        then
            if #trees >= (maxUnits - maxUnits % 1)
            then
                --npcBot:ActionImmediate_Chat("Использую NaturesCall для пуша дефа!", true);
                return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[1]);
            end
        end
    end
end

function ConsiderCurseOfTheOldgrowth()
    local ability = CurseOfTheOldgrowth;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderWrathOfNature()
    local ability = WrathOfNature;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for i = 1, #enemyAbility do
            if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, ability:GetDamageType())
                and utility.CanCastSpellOnTarget(ability, enemyAbility[i])
            then
                --npcBot:ActionImmediate_Chat("Использую WrathOfNature что бы убить цель!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemyAbility[i], "target";
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            for i = 1, #enemyAbility do
                if enemyAbility[i] ~= botTarget and utility.IsValidTarget(enemyAbility[i]) and GetUnitToUnitDistance(enemyAbility[i], botTarget) >= 5000
                then
                    --npcBot:ActionImmediate_Chat("Использую WrathOfNature по дальнему герою!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemyAbility[i]:GetLocation(), "location";
                end
            end
            local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
            for i = 1, #enemyCreeps do
                if utility.IsValidTarget(enemyCreeps[i]) and GetUnitToUnitDistance(enemyCreeps[i], botTarget) >= 5000
                then
                    --npcBot:ActionImmediate_Chat("Использую WrathOfNature по дальнему крипу!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemyCreeps[i]:GetLocation(), "location";
                end
            end
        end
    end
end
