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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Torrent = AbilitiesReal[1]
local Tidebringer = AbilitiesReal[2]
local XMarksTheSpot = AbilitiesReal[3]
local Return = npcBot:GetAbilityByName("kunkka_return");
local TorrentStorm = AbilitiesReal[4]
local TidalWave = AbilitiesReal[5]
local Ghostship = AbilitiesReal[6]

--[[ local combo1Time = 0.0;
local combo2Time = 0.0;
local combo3Time = 0.0;
local combo1Running = false;
local combo2Running = false;
local combo3Running = false;
 ]]

local combo1Ready = false;
local combo2Ready = false;
local combo3Ready = false;

function AbilityUsageThink()
    --[[     if not npcBot:IsAlive()
    then
        combo1Time = 0.0;
        combo2Time = 0.0;
        combo3Time = 0.0;
    end ]]

    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();
    botMana = npcBot:GetMana();

    --[[     if (combo1Time > 0 and DotaTime() >= combo1Time + (combo1Delay - 0.6)) or
        (combo2Time > 0 and DotaTime() >= combo2Time + (combo2Delay - 2.1)) or
        (combo3Time > 0 and DotaTime() >= combo3Time + (combo3Delay - 0.6))
    then
        combo1Time = 0.0;
        combo2Time = 0.0;
        combo3Time = 0.0;
        if utility.IsAbilityAvailable(Return)
        then
            npcBot:ActionImmediate_Chat("Юзаю Return!", true);
            npcBot:Action_UseAbility(Return);
            return;
        end
    end ]]

    --[[   if (combo1Time > 0 and (GameTime() >= combo1Time + (0.6)))
    then
        npcBot:ActionImmediate_Chat(
            "Юзаю Return Combo1: " .. combo1Time .. " + " .. 0.6 .. " = " .. combo1Time + 0.6, true);
        combo1Time = 0.0;
        combo1Running = false;
        npcBot:Action_UseAbility(Return);
        return;
    end

    if (combo2Time > 0 and (GameTime() >= combo2Time + (2.1)))
    then
        npcBot:ActionImmediate_Chat(
            "Юзаю Return Combo2: " .. combo2Time .. " + " .. 2.1 .. " = " .. combo2Time + 2.1, true);
        combo2Time = 0.0;
        combo2Running = false;
        npcBot:Action_UseAbility(Return);
        return;
    end

    if (combo3Time > 0 and (GameTime() >= combo3Time + (0.6)))
    then
        npcBot:ActionImmediate_Chat(
            "Юзаю Return Combo3: " .. combo3Time .. " + " .. 0.6 .. " = " .. combo3Time + 0.6, true);
        combo3Time = 0.0;
        combo3Running = false;
        npcBot:Action_UseAbility(Return);
        return;
    end ]]

    local combo1Desire, Combo1Target, Combo1Location = ConsiderCombo1();
    local combo2Desire, Combo2Target, Combo2Location = ConsiderCombo2();
    local combo3Desire, Combo3Target, Combo3Location = ConsiderCombo3();

    if (combo1Desire > 0)
    then
        npcBot:Action_ClearActions(false);
        npcBot:ActionQueue_UseAbilityOnEntity(XMarksTheSpot, Combo1Target);
        npcBot:ActionQueue_UseAbilityOnLocation(Ghostship, Combo1Location);
        npcBot:ActionQueue_UseAbilityOnLocation(Torrent, Combo1Location);
        npcBot:ActionQueue_UseAbility(Return);
        return;
    end

    if (combo2Desire > 0)
    then
        npcBot:Action_ClearActions(false);
        npcBot:ActionQueue_UseAbilityOnEntity(XMarksTheSpot, Combo2Target);
        npcBot:ActionQueue_UseAbilityOnLocation(Ghostship, Combo2Location);
        npcBot:ActionQueue_UseAbility(Return);
        return;
    end

    if (combo3Desire > 0)
    then
        npcBot:Action_ClearActions(false);
        npcBot:ActionQueue_UseAbilityOnEntity(XMarksTheSpot, Combo3Target);
        npcBot:ActionQueue_UseAbilityOnLocation(Torrent, Combo3Location);
        npcBot:ActionQueue_UseAbility(Return);
        return;
    end

    local castTorrentDesire, castTorrentLocation = ConsiderTorrent();
    local castTidebringerDesire, castTidebringerTarget = ConsiderTidebringer();
    local castXMarksTheSpotDesire, castXMarksTheSpotTarget = ConsiderXMarksTheSpot();
    local castReturnDesire = ConsiderReturn();
    local castTorrentStormDesire, castTorrentStormLocation = ConsiderTorrentStorm();
    local castTidalWaveDesire, castTidalWaveLocation = ConsiderTidalWave();
    local castGhostshipDesire, castGhostshipLocation = ConsiderGhostship();

    if (castTorrentDesire > 0) and (combo1Ready == false and combo3Ready == false)
    then
        npcBot:Action_UseAbilityOnLocation(Torrent, castTorrentLocation);
        return;
    end

    if (castTidebringerDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Tidebringer, castTidebringerTarget);
        return;
    end

    if (castXMarksTheSpotDesire > 0) and (combo1Ready == false and combo2Ready == false and combo3Ready == false)
    then
        npcBot:Action_UseAbilityOnEntity(XMarksTheSpot, castXMarksTheSpotTarget);
        return;
    end

    if (castReturnDesire > 0)
    then
        npcBot:Action_UseAbility(Return);
        return;
    end

    if (castTorrentStormDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(TorrentStorm, castTorrentStormLocation);
        return;
    end

    if (castTidalWaveDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(TidalWave, castTidalWaveLocation);
        return;
    end

    if (castGhostshipDesire > 0) and (combo1Ready == false and combo2Ready == false)
    then
        npcBot:Action_UseAbilityOnLocation(Ghostship, castGhostshipLocation);
        return;
    end
end

function ConsiderCombo1()
    if not utility.IsAbilityAvailable(Torrent) or
        not utility.IsAbilityAvailable(XMarksTheSpot) or
        not utility.IsAbilityAvailable(Ghostship)
    then
        combo1Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboMana = Torrent:GetManaCost() + XMarksTheSpot:GetManaCost() + Ghostship:GetManaCost();

    if botMana < comboMana
    then
        combo1Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboCastRange = XMarksTheSpot:GetCastRange();
    --local comboDelay = Torrent:GetSpecialValueInt("delay");

    if utility.PvPMode(npcBot) and utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(Torrent, botTarget)
    then
        combo1Ready = true;
        if GetUnitToUnitDistance(npcBot, botTarget) <= comboCastRange
        then
            --npcBot:ActionImmediate_Chat("Использую combo1!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, botTarget, botTarget:GetLocation();
        end
    else
        combo1Ready = false;
    end

    return BOT_MODE_DESIRE_NONE, 0, 0;
end

function ConsiderCombo2()
    if not utility.IsAbilityAvailable(XMarksTheSpot) or
        not utility.IsAbilityAvailable(Ghostship)
    then
        combo2Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboMana = XMarksTheSpot:GetManaCost() + Ghostship:GetManaCost();

    if botMana < comboMana
    then
        combo2Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboCastRange = XMarksTheSpot:GetCastRange();
    --local comboDelay = Ghostship:GetSpecialValueInt("tooltip_delay");

    if utility.PvPMode(npcBot) and utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(Ghostship, botTarget)
    then
        combo2Ready = true;
        if GetUnitToUnitDistance(npcBot, botTarget) <= comboCastRange
        then
            --npcBot:ActionImmediate_Chat("Использую combo2!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, botTarget, botTarget:GetLocation();
        end
    else
        combo2Ready = false;
    end

    return BOT_MODE_DESIRE_NONE, 0, 0;
end

function ConsiderCombo3()
    if not utility.IsAbilityAvailable(Torrent) or
        not utility.IsAbilityAvailable(XMarksTheSpot)
    then
        combo3Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboMana = Torrent:GetManaCost() + XMarksTheSpot:GetManaCost();

    if botMana < comboMana
    then
        combo3Ready = false;
        return BOT_MODE_DESIRE_NONE, 0, 0;
    end

    local comboCastRange = XMarksTheSpot:GetCastRange();
    --local comboDelay = Torrent:GetSpecialValueInt("delay");

    if utility.PvPMode(npcBot) and utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(Torrent, botTarget)
    then
        combo3Ready = true;
        if GetUnitToUnitDistance(npcBot, botTarget) <= comboCastRange
        then
            --npcBot:ActionImmediate_Chat("Использую combo3!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, botTarget, botTarget:GetLocation();
        end
    else
        combo3Ready = false;
    end

    return BOT_MODE_DESIRE_NONE, 0, 0;
end

function ConsiderTorrent()
    local ability = Torrent;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("torrent_damage");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

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

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTidebringer()
    local ability = Tidebringer;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = npcBot:GetAttackDamage() + ability:GetSpecialValueInt("damage_bonus");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 100, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Tidebringer что бы добить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderXMarksTheSpot()
    local ability = XMarksTheSpot;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_kunkka_x_marks_the_spot")
                then
                    --npcBot:ActionImmediate_Chat("Использую XMarksTheSpot что бы сбить каст!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Stalking enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange() and not botTarget:HasModifier("modifier_kunkka_x_marks_the_spot")
        then
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_kunkka_x_marks_the_spot")
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderReturn()
    local ability = Return;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsValidTarget(enemy) and enemy:IsChanneling() and enemy:HasModifier("modifier_kunkka_x_marks_the_spot")
            then
                --npcBot:ActionImmediate_Chat("Использую Return!", true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderTorrentStorm()
    local ability = TorrentStorm;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if not Torrent:IsTrained()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("torrent_max_distance");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.2)
                and GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility - radiusAbility
                and GetUnitToUnitDistance(npcBot, botTarget) < castRangeAbility + radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую TorrentStorm для атаки!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
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
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TorrentStorm для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, npcBot:GetLocation();
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderTidalWave()
    local ability = TidalWave;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TidalWave что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TidalWave для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderGhostship()
    local ability = Ghostship;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("ghostship_width");
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("ghostship_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1)
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end

        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Ghostship по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ghostship для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
