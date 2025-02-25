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

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castTorrentDesire, castTorrentLocation = ConsiderTorrent();
    local castTidebringerDesire, castTidebringerTarget = ConsiderTidebringer();
    local castXMarksTheSpotDesire, castXMarksTheSpotTarget = ConsiderXMarksTheSpot();
    local castReturnDesire = ConsiderReturn();
    local castTorrentStormDesire, castTorrentStormLocation = ConsiderTorrentStorm();
    local castTidalWaveDesire, castTidalWaveLocation = ConsiderTidalWave();
    local castGhostshipDesire, castGhostshipLocation = ConsiderGhostship();

    if (castTorrentDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Torrent, castTorrentLocation);
        return;
    end

    if (castTidebringerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Tidebringer, castTidebringerTarget);
        return;
    end

    if (castXMarksTheSpotDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(XMarksTheSpot, castXMarksTheSpotTarget);
        return;
    end

    if (castReturnDesire ~= nil)
    then
        npcBot:Action_UseAbility(Return);
        return;
    end

    if (castTorrentStormDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TorrentStorm, castTorrentStormLocation);
        return;
    end

    if (castTidalWaveDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TidalWave, castTidalWaveLocation);
        return;
    end

    if (castGhostshipDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Ghostship, castGhostshipLocation);
        return;
    end
end

function ConsiderTorrent()
    local ability = Torrent;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderTidebringer()
    local ability = Tidebringer;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderXMarksTheSpot()
    local ability = XMarksTheSpot;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderReturn()
    local ability = Return;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderTorrentStorm()
    local ability = TorrentStorm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not Torrent:IsTrained()
    then
        return;
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
end

function ConsiderTidalWave()
    local ability = TidalWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end

function ConsiderGhostship()
    local ability = Ghostship;
    if not utility.IsAbilityAvailable(ability) then
        return;
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
end
