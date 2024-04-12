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
    Abilities[1],
    Abilities[3],
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

-- Abilities
local WhirlingDeath = AbilitiesReal[1]
local TimberChain = AbilitiesReal[2]
local ReactiveArmor = AbilitiesReal[3]
local SecondChakram = AbilitiesReal[4]
local ReturnSecondChakram = npcBot:GetAbilityByName("shredder_return_chakram_2");
local Flamethrower = AbilitiesReal[5]
local Chakram = AbilitiesReal[6]
local ReturnChakram = npcBot:GetAbilityByName("shredder_return_chakram");

local chakramPosition = nil;
local chakram2Position = nil;
local castChakramTimer = 0;
local castSecondChakramTimer = 0;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castWhirlingDeathDesire = ConsiderWhirlingDeath();
    local castTimberChainDesire, castTimberChainLocation = ConsiderTimberChain();
    local castReactiveArmorDesire = ConsiderReactiveArmor();
    local castFlamethrowerDesire = ConsiderFlamethrower();
    local castSecondChakramDesire, castSecondChakramLocation = ConsiderSecondChakram();
    local castReturnSecondChakramDesire = ConsiderReturnSecondChakram();
    local castChakramDesire, castChakramLocation = ConsiderChakram();
    local castReturnChakramDesire = ConsiderReturnChakram();

    if (castWhirlingDeathDesire ~= nil)
    then
        npcBot:Action_UseAbility(WhirlingDeath);
        return;
    end

    if (castTimberChainDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TimberChain, castTimberChainLocation);
        return;
    end

    if (castReactiveArmorDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReactiveArmor);
        return;
    end

    if (castFlamethrowerDesire ~= nil)
    then
        npcBot:Action_UseAbility(Flamethrower);
        return;
    end

    if (castSecondChakramDesire ~= nil)
    then
        chakram2Position = castSecondChakramLocation;
        castSecondChakramTimer = DotaTime();
        npcBot:Action_UseAbilityOnLocation(SecondChakram, castSecondChakramLocation);
        return;
    end

    if (castReturnSecondChakramDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReturnSecondChakram);
        return;
    end

    if (castChakramDesire ~= nil)
    then
        chakramPosition = castChakramLocation;
        castChakramTimer = DotaTime();
        npcBot:Action_UseAbilityOnLocation(Chakram, castChakramLocation);
        return;
    end

    if (castReturnChakramDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReturnChakram);
        return;
    end
end

local function CountEnemyNearChakram(radius, projectName, bhero, bcreep)
    local countEnemyHeroesNearChakram = 0;
    local countEnemyCreepsNearChakram = 0;
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
    local projectiles = GetLinearProjectiles();

    --local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
    --local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);

    if (#projectiles > 0)
    then
        for _, project in pairs(projectiles)
        do
            if project ~= nil and project.ability:GetName() == projectName
            then
                if (#enemyHeroes > 0)
                then
                    for _, enemy in pairs(enemyHeroes) do
                        if GetUnitToLocationDistance(enemy, project.location) <= radius
                        then
                            if projectName == "shredder_chakram" and chakramPosition ~= nil
                            then
                                if GetUnitToLocationDistance(enemy, chakramPosition) <= radius
                                then
                                    countEnemyHeroesNearChakram = countEnemyHeroesNearChakram + 1;
                                    if bhero == "true"
                                    then
                                        return countEnemyHeroesNearChakram;
                                    end
                                end
                            end
                            if projectName == "shredder_chakram_2" and chakram2Position ~= nil
                            then
                                if GetUnitToLocationDistance(enemy, chakram2Position) <= radius
                                then
                                    countEnemyHeroesNearChakram = countEnemyHeroesNearChakram + 1;
                                    if bhero == "true"
                                    then
                                        return countEnemyHeroesNearChakram;
                                    end
                                end
                            end
                        end
                    end
                end
                if (#enemyCreeps > 0)
                then
                    for _, enemy in pairs(enemyCreeps) do
                        if projectName == "shredder_chakram" and chakramPosition ~= nil
                        then
                            if GetUnitToLocationDistance(enemy, chakramPosition) <= radius
                            then
                                countEnemyCreepsNearChakram = countEnemyCreepsNearChakram + 1;
                                if bcreep == "true"
                                then
                                    return countEnemyCreepsNearChakram;
                                end
                            end
                        end
                        if projectName == "shredder_chakram_2" and chakram2Position ~= nil
                        then
                            if GetUnitToLocationDistance(enemy, chakram2Position) <= radius
                            then
                                countEnemyCreepsNearChakram = countEnemyCreepsNearChakram + 1;
                                if bcreep == "true"
                                then
                                    return countEnemyCreepsNearChakram;
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    --[[     if bhero == "true" and bcreep == "true"
    then
        return countEnemyHeroesNearChakram + countEnemyCreepsNearChakram;
    elseif bhero == "true"
    then
        return countEnemyHeroesNearChakram;
    elseif bcreep == "true"
    then
        return countEnemyCreepsNearChakram;
    end ]]

    return 0;
end

function ConsiderWhirlingDeath()
    local ability = WhirlingDeath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local treesAround = npcBot:GetNearbyTrees(radiusAbility);
    local damageAbility = ability:GetSpecialValueInt("whirling_damage") +
        (#treesAround * ability:GetSpecialValueInt("tree_damage_scale"));
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую WhirlingDeath что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Roshan use
        if utility.IsRoshan(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 1) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderTimberChain()
    local ability = TimberChain;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain")
    then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local chainRadius = ability:GetSpecialValueInt("chain_radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local trees = enemy:GetNearbyTrees(radiusAbility);
                    if (#trees > 0)
                    then
                        npcBot:ActionImmediate_Chat("Использую TimberChain что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[1]);
                    end
                end
            end
        end
    end

    -- and not utility.IsTreeBetweenMeAndTarget(npcBot, enemy, enemy:GetLocation(), chainRadius)

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    local trees = botTarget:GetNearbyTrees(radiusAbility);
                    if (#trees > 0) and IsLocationPassable(GetTreeLocation(trees[1]))
                    then
                        --npcBot:ActionImmediate_Chat("Использую TimberChain по цели!", true);
                        return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[1]);
                    end
                end
                if GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility + chainRadius
                then
                    local trees = npcBot:GetNearbyTrees(castRangeAbility);
                    if (#trees > 0) and IsLocationPassable(GetTreeLocation(trees[1]))
                        and GetUnitToLocationDistance(botTarget, GetTreeLocation(trees[1])) <= GetUnitToLocationDistance(npcBot, GetTreeLocation(trees[1]))
                    then
                        --npcBot:ActionImmediate_Chat("Использую TimberChain по цели которая рядом!", true);
                        return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(trees[1]);
                    end
                end
            end
        end
        -- Cast if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        local trees = npcBot:GetNearbyTrees(castRangeAbility);
        local closestTrees = npcBot:GetNearbyTrees(chainRadius);
        --local allyBuildings = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
        --local ancient = GetAncient(GetTeam());
        local fountain = utility.GetFountain(npcBot);
        --local enemyAncient = GetAncient(GetOpposingTeam());
        if (#trees > 0) and (#closestTrees == 0)
        then
            for _, tree in pairs(trees)
            do
                if GetUnitToLocationDistance(npcBot, GetTreeLocation(tree) >= math.floor(castRangeAbility / 2))
                then
                    if GetUnitToLocationDistance(fountain, GetTreeLocation(tree)) < GetUnitToUnitDistance(fountain, npcBot)
                    then
                        npcBot:ActionImmediate_Chat("Использую TimberChain отступая!", true);
                        return BOT_ACTION_DESIRE_HIGH, GetTreeLocation(tree);
                    end
                end
            end
        end
    end
end

function ConsiderReactiveArmor()
    local ability = ReactiveArmor;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_reactive_armor_bomb")
    then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    --local maxStacks = ability:GetSpecialValueInt("stack_limit");

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую ReactiveArmor против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую ReactiveArmor для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderFlamethrower()
    local ability = Flamethrower;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain")
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local castRangeAbility = ability:GetSpecialValueInt("length");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and npcBot:IsFacingLocation(botTarget:GetLocation(), 20)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Use when attack building
    if utility.IsBuilding(attackTarget) and utility.CanCastSpellOnTarget(ability, attackTarget)
    then
        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and ManaPercentage >= 0.4
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderChakram()
    local ability = Chakram;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("pass_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram в радиусе что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram в касте+радиусе что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Chakram в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Chakram в касте+радиусе!!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram в радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram в касте+радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую Chakram по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end
end

function ConsiderReturnChakram()
    local ability = ReturnChakram;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain") or chakramPosition == nil
    then
        return;
    end

    if DotaTime() > (castChakramTimer + 2.0)
    then
        return BOT_MODE_DESIRE_MODERATE;
    end

    --[[
    if (npcBot.idletime == nil)
    then
        npcBot.idletime = GameTime()
    else
        if (GameTime() - npcBot.idletime >= 5)
        then
            npcBot.idletime = nil
            return BOT_MODE_DESIRE_MODERATE;
        end
    end ]]

    --[[     local radiusAbility = Chakram:GetSpecialValueInt("radius");

    -- Attack/Retreat use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if CountEnemyNearChakram(radiusAbility, "shredder_chakram", "true", "false") == 0
        then
            npcBot:ActionImmediate_Chat("Возвращаю Chakram т.к враги не в радиусе!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if CountEnemyNearChakram(radiusAbility, "shredder_chakram", "false", "true") == 0
        then
            npcBot:ActionImmediate_Chat("Возвращаю Chakram т.к крипы не в радиусе!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end ]]
end

function ConsiderSecondChakram()
    local ability = SecondChakram;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("pass_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram2 в радиусе что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram2 в касте+радиусе что бы убить цель!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Chakram2 в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Chakram2 в касте+радиусе!!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram2 в радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Chakram2 в касте+радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую Chakram2 по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end
end

function ConsiderReturnSecondChakram()
    local ability = ReturnSecondChakram;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_shredder_timber_chain") or chakram2Position == nil
    then
        return;
    end

    if DotaTime() > (castSecondChakramTimer + 2.0)
    then
        return BOT_MODE_DESIRE_MODERATE;
    end

    --[[
    if (npcBot.idletime == nil)
    then
        npcBot.idletime = GameTime()
    else
        if (GameTime() - npcBot.idletime >= 5)
        then
            npcBot.idletime = nil
            return BOT_MODE_DESIRE_MODERATE;
        end
    end ]]

    --[[     local radiusAbility = SecondChakram:GetSpecialValueInt("radius");

    -- Attack/Retreat use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if CountEnemyNearChakram(radiusAbility, "shredder_chakram_2", "true", "false") == 0
        then
            npcBot:ActionImmediate_Chat("Возвращаю Chakram2 т.к враги не в радиусе!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if CountEnemyNearChakram(radiusAbility, "shredder_chakram_2", "false", "true") == 0
        then
            npcBot:ActionImmediate_Chat("Возвращаю Chakram2 т.к крипы не в радиусе!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end ]]
end
