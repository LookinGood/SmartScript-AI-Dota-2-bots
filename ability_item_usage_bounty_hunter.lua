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
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ShurikenToss = AbilitiesReal[1]
local Jinada = AbilitiesReal[2]
local ShadowWalk = AbilitiesReal[3]
local FriendlyShadow = AbilitiesReal[4]
local Track = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castShurikenTossDesire, castShurikenTossTarget = ConsiderShurikenToss();
    --local castJinadaDesire, castJinadaTarget = ConsiderJinada();
    ConsiderJinada();
    local castShadowWalkDesire = ConsiderShadowWalk();
    local castFriendlyShadowDesire, castFriendlyShadowTarget = ConsiderFriendlyShadow();
    local castTrackDesire, castTrackTarget = ConsiderTrack();

    if (castShurikenTossDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ShurikenToss, castShurikenTossTarget);
        return;
    end

--[[     if (castJinadaDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Jinada, castJinadaTarget);
        return;
    end ]]

    if (castShadowWalkDesire ~= nil)
    then
        npcBot:Action_UseAbility(ShadowWalk);
        return;
    end

    if (castFriendlyShadowDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FriendlyShadow, castFriendlyShadowTarget);
        return;
    end

    if (castTrackDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Track, castTrackTarget);
        return;
    end
end

function ConsiderShurikenToss()
    local ability = ShurikenToss;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("bounce_aoe");
    local damageAbility = ability:GetSpecialValueInt("bonus_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShurikenToss что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if botTarget:HasModifier("modifier_bounty_hunter_track")
                then
                    local enemyHeroes = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
                    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
                    if (#enemyHeroes > 1)
                    then
                        for _, enemy in pairs(enemyHeroes) do
                            if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(enemy, botTarget) <= radiusAbility
                            then
                                --npcBot:ActionImmediate_Chat("Использую ShurikenToss по помеченному врагу (на героя)!", true);
                                return BOT_ACTION_DESIRE_HIGH, enemy;
                            end
                        end
                    end
                    if (#enemyCreeps > 0)
                    then
                        for _, enemy in pairs(enemyCreeps) do
                            if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(enemy, botTarget) <= radiusAbility
                            then
                                --npcBot:ActionImmediate_Chat("Использую ShurikenToss по помеченному врагу (на крипа)!",true);
                                return BOT_ACTION_DESIRE_HIGH, enemy;
                            end
                        end
                    end
                    --npcBot:ActionImmediate_Chat("Использую ShurikenToss по омеченному врагу, других целей нет!", true);
                    return BOT_MODE_DESIRE_HIGH, botTarget;
                else
                    --npcBot:ActionImmediate_Chat("Использую ShurikenToss по не помеченному врагу!", true);
                    return BOT_MODE_DESIRE_HIGH, botTarget;
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShurikenToss что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую ShurikenToss по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderJinada()
    local ability = Jinada;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --local castRangeAbility = ability:GetCastRange();
    --local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("bonus_damage");
    --local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end

--[[     -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Jinada что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy)
        then
            npcBot:ActionImmediate_Chat("Использую Jinada по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end ]]
end

function ConsiderShadowWalk()
    local ability = ShadowWalk;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();
    local attackRange = npcBot:GetAttackRange();

    -- Try to interrupt enemy cast
    if attackTarget:IsChanneling()
    then
        --npcBot:ActionImmediate_Chat("Использую ShadowWalk против кастующей цели!", true);
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > attackRange and GetUnitToUnitDistance(npcBot, botTarget) <= 3000
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowWalk для нападения!", true);
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую ShadowWalk для отхода!", true);
        return BOT_MODE_DESIRE_VERYHIGH;
        -- General use
    elseif npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
    then
        if npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_PICK_UP_RUNE or
            botMode == BOT_MODE_WARD or botMode == BOT_MODE_RUNE or
            botMode == BOT_MODE_SECRET_SHOP or botMode == BOT_MODE_SIDE_SHOP or
            botMode == BOT_MODE_DEFEND_TOWER_TOP or botMode == BOT_MODE_DEFEND_TOWER_MID or
            botMode == BOT_MODE_DEFEND_TOWER_BOT
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowWalk для разведки!", true);
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderFriendlyShadow()
    local ability = FriendlyShadow;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    if (#allyAbility > 1)
    then
        -- Safe ally hero
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and not ally:IsInvisible()
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                    or ally:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую FriendlyShadow на союзника!", true);
                    return BOT_MODE_DESIRE_VERYHIGH, ally;
                end
            end
        end
    end
end

function ConsiderTrack()
    local ability = Track;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                if not botTarget:HasModifier("modifier_bounty_hunter_track")
                then
                    --npcBot:ActionImmediate_Chat("Использую Track по основной цели!", true);
                    return BOT_MODE_DESIRE_VERYHIGH, botTarget;
                else
                    if (#enemyAbility > 1)
                    then
                        for _, enemy in pairs(enemyAbility) do
                            if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_bounty_hunter_track")
                            then
                                --npcBot:ActionImmediate_Chat("Использую Track по 2 цели!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                            end
                        end
                    end
                end
            end
        end
    else
        -- General use
        if (#enemyAbility > 0) and (ManaPercentage >= 0.3)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_bounty_hunter_track")
                then
                    --npcBot:ActionImmediate_Chat("Использую Track для отметки врага!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end
