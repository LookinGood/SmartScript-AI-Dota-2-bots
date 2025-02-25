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
    Abilities[4],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[4],
    Abilities[4],
    Talents[2],
    Abilities[4],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local BoundlessStrike = AbilitiesReal[1]
local TreeDance = AbilitiesReal[2]
local PrimalSpring = AbilitiesReal[3]
local SpringEarly = npcBot:GetAbilityByName("monkey_king_primal_spring_early");
local Mischief = AbilitiesReal[5]
local WukongsCommand = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBoundlessStrikeDesire, castBoundlessStrikeLocation = ConsiderBoundlessStrike();
    local castTreeDanceDesire, castTreeDanceTarget = ConsiderTreeDance();
    local castPrimalSpringDesire, castPrimalSpringLocation = ConsiderPrimalSpring();
    local castSpringEarlyDesire = ConsiderSpringEarly();
    local castMischiefDesire = ConsiderMischief();
    local castWukongsCommandDesire, castWukongsCommandLocation = ConsiderWukongsCommand();

    if (castBoundlessStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BoundlessStrike, castBoundlessStrikeLocation);
        return;
    end

    if (castTreeDanceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnTree(TreeDance, castTreeDanceTarget);
        return;
    end

    if (castPrimalSpringDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(PrimalSpring, castPrimalSpringLocation);
        return;
    end

    if (castSpringEarlyDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpringEarly);
        return;
    end

    if (castMischiefDesire ~= nil)
    then
        npcBot:Action_UseAbility(Mischief);
        return;
    end

    if (castWukongsCommandDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WukongsCommand, castWukongsCommandLocation);
        return;
    end
end

function ConsiderBoundlessStrike()
    local ability = BoundlessStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("strike_radius");
    local damageAbility = npcBot:GetAttackDamage() / 100 * ability:GetSpecialValueInt("strike_crit_mult");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    --npcBot:ActionImmediate_Chat("Использую BoundlessStrike для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую BoundlessStrike по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую BoundlessStrike по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderTreeDance()
    local ability = TreeDance;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local castRangePrimalSpring = PrimalSpring:GetCastRange();
    local trees = npcBot:GetNearbyTrees(castRangeAbility);
    --local ancient = GetAncient(GetTeam());
    --local mainTree = nil;

    if (#trees == 0)
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if PrimalSpring:IsFullyCastable()
            then
                for _, tree in pairs(trees)
                do
                    if GetUnitToLocationDistance(botTarget, GetTreeLocation(tree)) < castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую TreeDance для атаки!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, tree;
                    end
                end
            end
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        local fountain = utility.GetFountain(npcBot);
        if npcBot:DistanceFromFountain() > castRangeAbility
        then
            for _, tree in pairs(trees)
            do
                if GetUnitToLocationDistance(npcBot, GetTreeLocation(tree)) > npcBot:GetAttackRange() and
                    GetUnitToLocationDistance(npcBot, GetTreeLocation(tree)) < castRangeAbility and
                    GetUnitToLocationDistance(fountain, GetTreeLocation(tree)) < GetUnitToUnitDistance(fountain, npcBot)
                then
                    npcBot:ActionImmediate_Chat("Использую TreeDance для отхода!", true);
                    return BOT_ACTION_DESIRE_HIGH, tree;
                end
            end
        end
    end

    -- Retreat use
    --[[     if utility.RetreatMode(npcBot)
    then
        for _, tree in pairs(trees)
        do
            if GetUnitToLocationDistance(ancient, GetTreeLocation(tree)) < GetUnitToUnitDistance(ancient, npcBot)
            then
                mainTree = tree;
            end
        end
        if mainTree ~= nil
        then
            npcBot:ActionImmediate_Chat("Использую TreeDance для отхода!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, mainTree;
        end
    end ]]
end

function ConsiderPrimalSpring()
    local ability = PrimalSpring;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --[[     if not ability:IsActivated()
    then
        return;
    end ]]

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityChannelTime");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
    then
        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
    else
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end

function ConsiderSpringEarly()
    local ability = SpringEarly;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую SpringEarly для отхода!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderMischief()
    local ability = Mischief;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_monkey_king_transform")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    if GetGameState() == GAME_STATE_PRE_GAME or npcBot:HasModifier('modifier_fountain_aura_buff') or
        botMode == BOT_MODE_RUNE or
        botMode == BOT_MODE_WARD or
        botMode == BOT_MODE_SECRET_SHOP or
        botMode == BOT_MODE_SIDE_SHOP
    then
        return BOT_ACTION_DESIRE_VERYLOW;
    end

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 100 and spell.is_attack == false and
                not npcBot:HasModifier("modifier_antimage_counterspell") and
                not npcBot:HasModifier("modifier_item_sphere_target") and
                not npcBot:HasModifier("modifier_item_lotus_orb_active")
            then
                --npcBot:ActionImmediate_Chat("Использую Mischief что бы сбить снаряд!", true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую Mischief против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую Mischief для отступления!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderWukongsCommand()
    local ability = WukongsCommand;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("cast_range");
    local radiusAbility = ability:GetSpecialValueInt("second_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.3)
            then
                --npcBot:ActionImmediate_Chat("Использую WukongsCommand по цели!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую WukongsCommand по врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end
