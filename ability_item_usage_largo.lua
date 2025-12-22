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
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local CatchyLick = npcBot:GetAbilityByName("largo_catchy_lick");
local Frogstomp = npcBot:GetAbilityByName("largo_frogstomp");
local CroakOfGenius = npcBot:GetAbilityByName("largo_croak_of_genius");
local AmphibianRhapsody = npcBot:GetAbilityByName("largo_amphibian_rhapsody");
local BullbellyBlitz = npcBot:GetAbilityByName("largo_song_fight_song");
local HotfeetHustle = npcBot:GetAbilityByName("largo_song_double_time");
local IslandElixir = npcBot:GetAbilityByName("largo_song_good_vibrations");

local battleSong = false;
local speedSong = false;
local healSong = false;
local doubleSong = 0;

local castBattleSongTimer = 0.0;
local castSpeedSongTimer = 0.0;
local castHealSongTimer = 0.0;
local rhythmInterval = 1.0;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castCatchyLickDesire, castCatchyLickTarget = ConsiderCatchyLick();
    local castFrogstompDesire, castFrogstompLocation = ConsiderFrogstomp();
    local castCroakOfGeniusDesire, castCroakOfGeniusTarget = ConsiderCroakOfGenius();
    local castBullbellyBlitzDesire = ConsiderBullbellyBlitz();
    local castHotfeetHustleDesire = ConsiderHotfeetHustle();
    local castIslandElixirDesire = ConsiderIslandElixir();
    local castAmphibianRhapsodyDesire = ConsiderAmphibianRhapsody();

    if (castCatchyLickDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(CatchyLick, castCatchyLickTarget);
        return;
    end

    if (castFrogstompDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Frogstomp, castFrogstompLocation);
        return;
    end

    if (castCroakOfGeniusDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(CroakOfGenius, castCroakOfGeniusTarget);
        return;
    end

    if (castBullbellyBlitzDesire > 0) and (GameTime() >= castBattleSongTimer + rhythmInterval)
    then
        if doubleSong > 0
        then
            --npcBot:ActionImmediate_Chat("Жму BullbellyBlitz с аганимом!", true);
            npcBot:ActionQueue_UseAbility(BullbellyBlitz);
            npcBot:ActionQueue_UseAbility(HotfeetHustle);
            castBattleSongTimer = GameTime();
            return;
        else
            --npcBot:ActionImmediate_Chat("Жму BullbellyBlitz без аганима!", true);
            npcBot:Action_UseAbility(BullbellyBlitz);
            castBattleSongTimer = GameTime();
            return;
        end
    end

    if (castHotfeetHustleDesire > 0) and (GameTime() >= castSpeedSongTimer + rhythmInterval)
    then
        if doubleSong > 0
        then
            --npcBot:ActionImmediate_Chat("Жму HotfeetHustle с аганимом!", true);
            npcBot:ActionQueue_UseAbility(HotfeetHustle);
            npcBot:ActionQueue_UseAbility(IslandElixir);
            castSpeedSongTimer = GameTime();
            return;
        else
            --npcBot:ActionImmediate_Chat("Жму HotfeetHustle без аганима!", true);
            npcBot:Action_UseAbility(HotfeetHustle);
            castSpeedSongTimer = GameTime();
            return;
        end
    end

    if (castIslandElixirDesire > 0) and (GameTime() >= castHealSongTimer + rhythmInterval)
    then
        if doubleSong > 0
        then
            --npcBot:ActionImmediate_Chat("Жму IslandElixir с аганимом!", true);
            npcBot:ActionQueue_UseAbility(IslandElixir);
            npcBot:ActionQueue_UseAbility(HotfeetHustle);
            castHealSongTimer = GameTime();
            return;
        else
            --npcBot:ActionImmediate_Chat("Жму IslandElixir без аганима!", true);
            npcBot:Action_UseAbility(IslandElixir);
            castHealSongTimer = GameTime();
            return;
        end
    end

    if (castAmphibianRhapsodyDesire > 0)
    then
        npcBot:Action_UseAbility(AmphibianRhapsody);
        return;
    end
end

function ConsiderCatchyLick()
    local ability = CatchyLick;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local pullDistanceAlly = ability:GetSpecialValueInt("pull_distance_ally");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую CatchyLick что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.IsDisabled(ally)
            then
                --npcBot:ActionImmediate_Chat("Использую CatchyLick для диспела на " .. ally:GetUnitName(), true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end

    -- Try to safe ally
    if not utility.RetreatMode(npcBot) and (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and ally ~= npcBot
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.5 and (GetUnitToUnitDistance(ally, npcBot) > pullDistanceAlly) and
                    ally:DistanceFromFountain() > npcBot:DistanceFromFountain() and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую CatchyLick для спасения " .. ally:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFrogstomp()
    local ability = Frogstomp;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage_per_stomp") * ability:GetSpecialValueInt("total_ticks");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Frogstomp что бы сбить заклинание или убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderCroakOfGenius()
    local ability = CroakOfGenius;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_largo_croak_of_genius_buff")
            then
                if utility.PvPMode(npcBot)
                then
                    if utility.IsHero(botTarget)
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= (ally:GetAttackRange() * 2)
                        then
                            --npcBot:ActionImmediate_Chat("Использую CroakOfGenius на союзника " .. ally:GetUnitName(),true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end

                if ally:GetAttackTarget() ~= nil and utility.IsBoss(ally:GetAttackTarget())
                then
                    --npcBot:ActionImmediate_Chat("Использую CroakOfGenius на атакующего босса " .. ally:GetUnitName(),true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderBullbellyBlitz()
    local ability = BullbellyBlitz;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if battleSong == true
    then
        return BOT_MODE_DESIRE_HIGH;
    end

    return BOT_MODE_DESIRE_NONE;
end

function ConsiderHotfeetHustle()
    local ability = HotfeetHustle;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if speedSong == true
    then
        return BOT_MODE_DESIRE_HIGH;
    end

    return BOT_MODE_DESIRE_NONE;
end

function ConsiderIslandElixir()
    local ability = IslandElixir;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if healSong == true
    then
        return BOT_MODE_DESIRE_HIGH;
    end

    return BOT_MODE_DESIRE_NONE;
end

-- modifier_largo_amphibian_rhapsody_self

function ConsiderAmphibianRhapsody()
    local ability = AmphibianRhapsody;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange();
    local radiusAbility = ability:GetAOERadius();
    local abilityCount = ability:GetSpecialValueInt("max_stacks");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
    doubleSong = ability:GetSpecialValueInt("double_song");
    rhythmInterval = ability:GetSpecialValueInt("rhythm_interval");

    print("Функция Скила: " .. doubleSong)

    if (battleSong == false and speedSong == false and healSong == false) or
        ((npcBot:GetMana() < BullbellyBlitz:GetManaCost() and
            npcBot:GetMana() < HotfeetHustle:GetManaCost() and
            npcBot:GetMana() < IslandElixir:GetManaCost()))
    then
        if ability:GetToggleState() == true
        then
            --npcBot:ActionImmediate_Chat("Выключаю AmphibianRhapsody!", true);
            return BOT_ACTION_DESIRE_ABSOLUTE;
        end
    end

    if battleSong == true or
        speedSong == true or
        healSong == true
    then
        if ability:GetToggleState() == false
        then
            return BOT_ACTION_DESIRE_ABSOLUTE;
        end
    end

    -- Batlle song
    if speedSong == false and healSong == false
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            and (utility.GetModifierCount(npcBot, "modifier_largo_groovin") < abilityCount)
        then
            --npcBot:ActionImmediate_Chat("Включаю AmphibianRhapsody для BattleSong!", true);
            battleSong = true;
            speedSong = false;
            healSong = false;
        else
            battleSong = false;
        end
    end

    -- SpeedSong
    -- Use to buff damaged ally
    if battleSong == false and healSong == false
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if (utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.9 and ally:GetHealth() / ally:GetMaxHealth() > 0.8)) and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Включаю AmphibianRhapsody для SpeedSong!", true);
                    speedSong = true;
                    battleSong = false;
                    healSong = false;
                else
                    speedSong = false;
                end
            end
        end
    end

    -- HealSong
    if battleSong == false and speedSong == false
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Включаю AmphibianRhapsody для HealSong!", true);
                    healSong = true;
                    battleSong = false;
                    speedSong = false;
                else
                    healSong = false;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end
