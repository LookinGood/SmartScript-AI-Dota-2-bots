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
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local EchoStomp = AbilitiesReal[1]
local AstralSpirit = AbilitiesReal[2]
local ReturnAstralSpirit = npcBot:GetAbilityByName("elder_titan_return_spirit");
local MoveAstralSpirit = npcBot:GetAbilityByName("elder_titan_move_spirit");
local EarthSplitter = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castEchoStompDesire = ConsiderEchoStomp();
    local castAstralSpiritDesire, castAstralSpiritLocation, castAstralSpiritType = ConsiderAstralSpirit();
    local castReturnAstralSpiritDesire = ConsiderReturnAstralSpirit();
    local castMoveAstralSpiritDesire, castMoveAstralSpiritLocation = ConsiderMoveAstralSpirit();
    local castEarthSplitterDesire, castEarthSplitterLocation = ConsiderEarthSplitter();

    if (castEchoStompDesire ~= nil)
    then
        npcBot:Action_ClearActions(true);
        npcBot:Action_UseAbility(EchoStomp);
        return;
    end

    if (castAstralSpiritDesire ~= nil)
    then
        if (castAstralSpiritType) == "combo"
        then
            --npcBot:ActionImmediate_Chat("Использую AstralSpirit в комбо с EchoStomp!", true);
            npcBot:Action_ClearActions(true);
            npcBot:ActionQueue_UseAbilityOnLocation(AstralSpirit, castAstralSpiritLocation);
            npcBot:ActionQueue_UseAbility(EchoStomp);
            return;
        else
            npcBot:Action_UseAbilityOnLocation(AstralSpirit, castAstralSpiritLocation);
            return;
        end
    end

    if (castReturnAstralSpiritDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReturnAstralSpirit);
        return;
    end

    if (castMoveAstralSpiritDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MoveAstralSpirit, castMoveAstralSpiritLocation);
        return;
    end

    if (castEarthSplitterDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(EarthSplitter, castEarthSplitterLocation);
        return;
    end
end

function ConsiderEchoStomp()
    local ability = EchoStomp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("stomp_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую EchoStomp что бы убить цель или сбить каст!", true);
                    return BOT_ACTION_DESIRE_HIGH;
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
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую EchoStomp против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderAstralSpirit()
    local ability = AstralSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("pass_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), nil;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if EchoStomp:IsCooldownReady() and (npcBot:GetMana() >= ability:GetManaCost() + EchoStomp:GetManaCost())
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0),
                        "combo";
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
                    if EchoStomp:IsCooldownReady() and (npcBot:GetMana() >= ability:GetManaCost() + EchoStomp:GetManaCost())
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                            "combo";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, nil;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0), nil;
        end
    end
end

function ConsiderReturnAstralSpirit()
    local ability = ReturnAstralSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Retreat use
    if utility.RetreatMode(npcBot) and not utility.IsAbilityAvailable(EchoStomp)
    then
        if (npcBot.idletime == nil)
        then
            npcBot.idletime = GameTime()
        else
            if (GameTime() - npcBot.idletime >= 5)
            then
                npcBot.idletime = nil
                --npcBot:ActionImmediate_Chat("Использую ReturnAstralSpirit для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderMoveAstralSpirit()
    local ability = MoveAstralSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Cast if attack enemy
    if utility.IsValidTarget(botTarget)
    then
        if (npcBot.idletime == nil)
        then
            npcBot.idletime = GameTime()
        else
            if (GameTime() - npcBot.idletime >= 5)
            then
                npcBot.idletime = nil
                --npcBot:ActionImmediate_Chat("Использую MoveAstralSpirit!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget:GetLocation();
            end
        end
    else
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        if (#enemyAbility > 0) and utility.IsValidTarget(enemyAbility[1])
        then
            if (npcBot.idletime == nil)
            then
                npcBot.idletime = GameTime()
            else
                if (GameTime() - npcBot.idletime >= 5)
                then
                    npcBot.idletime = nil
                    --npcBot:ActionImmediate_Chat("Использую MoveAstralSpirit на героя рядом!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemyAbility[1]:GetLocation();
                end
            end
        elseif (#enemyCreeps > 0) and utility.IsValidTarget(enemyCreeps[1])
        then
            if (npcBot.idletime == nil)
            then
                npcBot.idletime = GameTime()
            else
                if (GameTime() - npcBot.idletime >= 5)
                then
                    npcBot.idletime = nil
                    --npcBot:ActionImmediate_Chat("Использую MoveAstralSpirit на крипа рядом!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemyCreeps[1]:GetLocation();
                end
            end
        end
    end
end

function ConsiderEarthSplitter()
    local ability = EarthSplitter;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("rack_width");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую EarthSplitter по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end
