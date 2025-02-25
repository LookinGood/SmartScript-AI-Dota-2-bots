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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[1],
    Talents[4],
    Abilities[1],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[5],
    Abilities[2],
    Abilities[2],
    Abilities[2],
    Abilities[2],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Base Abilities
local Quas = AbilitiesReal[1]
local Wex = AbilitiesReal[2]
local Exort = AbilitiesReal[3]
local Invoke = AbilitiesReal[6]

-- Created Abilities
local ColdSnap = npcBot:GetAbilityByName("invoker_cold_snap");
local GhostWalk = npcBot:GetAbilityByName("invoker_ghost_walk");
local Tornado = npcBot:GetAbilityByName("invoker_tornado");
local EMP = npcBot:GetAbilityByName("invoker_emp");
local Alacrity = npcBot:GetAbilityByName("invoker_alacrity");
local ChaosMeteor = npcBot:GetAbilityByName("invoker_chaos_meteor");
local SunStrike = npcBot:GetAbilityByName("invoker_sun_strike");
local ForgeSpirit = npcBot:GetAbilityByName("invoker_forge_spirit");
local IceWall = npcBot:GetAbilityByName("invoker_ice_wall");
local DeafeningBlast = npcBot:GetAbilityByName("invoker_deafening_blast");

-- Timers
local combineTimer = 0.0;

local timerColdSnap = 0.0;
local timerGhostWalk = 0.0;
local timerTornado = 0.0;
local timerEMP = 0.0;
local timerAlacrity = 0.0;
local timerChaosMeteor = 0.0;
local timerSunStrike = 0.0;
local timerForgeSpirit = 0.0;
local timerIceWall = 0.0;
local timerDeafeningBlast = 0.0;

local function QuasReady()
    return utility.IsAbilityAvailable(Quas) and
        utility.IsAbilityAvailable(Invoke);
end

local function WexReady()
    return utility.IsAbilityAvailable(Wex) and
        utility.IsAbilityAvailable(Invoke);
end

local function ExortReady()
    return utility.IsAbilityAvailable(Exort) and
        utility.IsAbilityAvailable(Invoke);
end

local function QuasWexReady()
    return utility.IsAbilityAvailable(Quas) and
        utility.IsAbilityAvailable(Wex) and
        utility.IsAbilityAvailable(Invoke);
end

local function QuasExortReady()
    return utility.IsAbilityAvailable(Quas) and
        utility.IsAbilityAvailable(Exort) and
        utility.IsAbilityAvailable(Invoke);
end

local function WexExortReady()
    return utility.IsAbilityAvailable(Wex) and
        utility.IsAbilityAvailable(Exort) and
        utility.IsAbilityAvailable(Invoke);
end

local function AllSpheresReady()
    return utility.IsAbilityAvailable(Quas) and
        utility.IsAbilityAvailable(Wex) and
        utility.IsAbilityAvailable(Exort) and
        utility.IsAbilityAvailable(Invoke);
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castColdSnapDesire, castColdSnapTarget = ConsiderColdSnap();
    local castGhostWalkDesire = ConsiderGhostWalk();
    local castTornadoDesire, castTornadoLocation = ConsiderTornado();
    local castEMPDesire, castEMPLocation = ConsiderEMP();
    local castAlacrityDesire, castAlacrityTarget = ConsiderAlacrity();
    local castChaosMeteorDesire, castChaosMeteorLocation = ConsiderChaosMeteor();
    local castSunStrikeDesire, castSunStrikeLocation = ConsiderSunStrike();
    local castForgeSpiritDesire = ConsiderForgeSpirit();
    local castIceWallDesire = ConsiderIceWall();
    local castDeafeningBlastDesire, castDeafeningBlastLocation = ConsiderDeafeningBlast();

    if (castColdSnapDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ColdSnap, castColdSnapTarget);
        timerColdSnap = GameTime();
        return;
    end

    if (castGhostWalkDesire ~= nil)
    then
        npcBot:Action_UseAbility(GhostWalk);
        timerGhostWalk = GameTime();
        return;
    end

    if (castTornadoDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Tornado, castTornadoLocation);
        timerTornado = GameTime();
        return;
    end

    if (castEMPDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(EMP, castEMPLocation);
        timerEMP = GameTime();
        return;
    end

    if (castAlacrityDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Alacrity, castAlacrityTarget);
        timerAlacrity = GameTime();
        return;
    end

    if (castChaosMeteorDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ChaosMeteor, castChaosMeteorLocation);
        timerChaosMeteor = GameTime();
        return;
    end

    if (castSunStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SunStrike, castSunStrikeLocation);
        timerSunStrike = GameTime();
        return;
    end

    if (castForgeSpiritDesire ~= nil)
    then
        npcBot:Action_UseAbility(ForgeSpirit);
        timerForgeSpirit = GameTime();
        return;
    end

    if (castIceWallDesire ~= nil)
    then
        npcBot:Action_UseAbility(IceWall);
        timerIceWall = GameTime();
        return;
    end

    if (castDeafeningBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DeafeningBlast, castDeafeningBlastLocation);
        timerDeafeningBlast = GameTime();
        return;
    end

    ability4 = npcBot:GetAbilityInSlot(3);
    ability5 = npcBot:GetAbilityInSlot(4);
    ConsiderSpheres()

    --print(ability4:GetName())
    --print(ability5:GetName())
end

local function CombineSpheres(sphere1, sphere2, sphere3)
    npcBot:Action_ClearActions(false);
    npcBot:ActionQueue_UseAbility(sphere1);
    npcBot:ActionQueue_UseAbility(sphere2);
    npcBot:ActionQueue_UseAbility(sphere3);
    npcBot:ActionQueue_UseAbility(Invoke);
    combineTimer = GameTime();
end

local function IsAbilityCanBeChanged(ability)
    return ability:IsHidden() or
        ability:IsPassive()
        or not ability:IsCooldownReady()
end

local function IsNotAbilityOnBoard(ability)
    return (ability4:GetName() ~= ability:GetName() and ability5:GetName() ~= ability:GetName())
end

local function CanCombineAbility(ability, timer)
    return IsNotAbilityOnBoard(ability) and npcBot:GetMana() >= ability:GetManaCost() and
        GameTime() >= timer + ability:GetCooldown();
end

function ConsiderSpheres()
    if IsAbilityCanBeChanged(ability4) or IsAbilityCanBeChanged(ability5)
    then
        if (GameTime() >= combineTimer + 2.0)
        then
            if utility.PvPMode(npcBot)
            then
                if ExortReady()
                then
                    if CanCombineAbility(SunStrike, timerSunStrike)
                    then
                        CombineSpheres(Exort, Exort, Exort)
                        return;
                    end
                end

                if QuasWexReady()
                then
                    if CanCombineAbility(Tornado, timerTornado)
                    then
                        CombineSpheres(Wex, Wex, Quas)
                        return;
                    end
                end

                if AllSpheresReady()
                then
                    if CanCombineAbility(DeafeningBlast, timerDeafeningBlast)
                    then
                        CombineSpheres(Quas, Wex, Exort)
                        return;
                    end
                end

                if WexExortReady()
                then
                    if CanCombineAbility(ChaosMeteor, timerChaosMeteor)
                    then
                        CombineSpheres(Exort, Exort, Wex)
                        return;
                    end
                    if CanCombineAbility(Alacrity, timerAlacrity)
                    then
                        CombineSpheres(Wex, Wex, Exort)
                        return;
                    end
                end

                if QuasReady()
                then
                    if CanCombineAbility(ColdSnap, timerColdSnap)
                    then
                        CombineSpheres(Quas, Quas, Quas)
                        return;
                    end
                end

                if WexReady()
                then
                    if CanCombineAbility(EMP, timerEMP)
                    then
                        CombineSpheres(Wex, Wex, Wex)
                        return;
                    end
                end

                if QuasExortReady()
                then
                    if CanCombineAbility(ForgeSpirit, timerForgeSpirit)
                    then
                        CombineSpheres(Exort, Exort, Quas)
                        return;
                    end
                    if CanCombineAbility(IceWall, timerIceWall)
                    then
                        CombineSpheres(Quas, Quas, Exort)
                        return;
                    end
                end
            elseif utility.RetreatMode(npcBot)
            then
                if QuasWexReady()
                then
                    if CanCombineAbility(Tornado, timerTornado)
                    then
                        CombineSpheres(Wex, Wex, Quas)
                        return;
                    end
                    if CanCombineAbility(GhostWalk, timerGhostWalk)
                    then
                        CombineSpheres(Quas, Quas, Wex)
                        return;
                    end
                end

                if QuasReady()
                then
                    if CanCombineAbility(ColdSnap, timerColdSnap)
                    then
                        CombineSpheres(Quas, Quas, Quas)
                        return;
                    end
                end

                if AllSpheresReady()
                then
                    if CanCombineAbility(DeafeningBlast, timerDeafeningBlast)
                    then
                        CombineSpheres(Quas, Wex, Exort)
                        return;
                    end
                end

                if QuasExortReady()
                then
                    if CanCombineAbility(IceWall, timerIceWall)
                    then
                        CombineSpheres(Quas, Quas, Exort)
                        return;
                    end
                end
            elseif utility.PvEMode(npcBot)
            then
                if AllSpheresReady()
                then
                    if CanCombineAbility(DeafeningBlast, timerDeafeningBlast)
                    then
                        CombineSpheres(Quas, Wex, Exort)
                        return;
                    end
                end

                if WexExortReady()
                then
                    if CanCombineAbility(Alacrity, timerAlacrity)
                    then
                        CombineSpheres(Wex, Wex, Exort)
                        return;
                    end
                end

                if QuasExortReady()
                then
                    if CanCombineAbility(ForgeSpirit, timerForgeSpirit)
                    then
                        CombineSpheres(Exort, Exort, Quas)
                        return;
                    end
                    if CanCombineAbility(IceWall, timerIceWall)
                    then
                        CombineSpheres(Quas, Quas, Exort)
                        return;
                    end
                end
            elseif botMode == BOT_MODE_ROSHAN
            then
                if QuasReady()
                then
                    if CanCombineAbility(ColdSnap, timerColdSnap)
                    then
                        CombineSpheres(Quas, Quas, Quas)
                        return;
                    end
                end

                if ExortReady()
                then
                    if CanCombineAbility(SunStrike, timerSunStrike)
                    then
                        CombineSpheres(Exort, Exort, Exort)
                        return;
                    end
                end

                if WexExortReady()
                then
                    if CanCombineAbility(Alacrity, timerAlacrity)
                    then
                        CombineSpheres(Wex, Wex, Exort)
                        return;
                    end
                end

                if QuasExortReady()
                then
                    if CanCombineAbility(ForgeSpirit, timerForgeSpirit)
                    then
                        CombineSpheres(Exort, Exort, Quas)
                        return;
                    end
                    if CanCombineAbility(IceWall, timerIceWall)
                    then
                        CombineSpheres(Quas, Quas, Exort)
                        return;
                    end
                end
            else
                if ExortReady()
                then
                    if CanCombineAbility(SunStrike, timerSunStrike)
                    then
                        CombineSpheres(Exort, Exort, Exort)
                        return;
                    end
                end

                if QuasWexReady()
                then
                    if CanCombineAbility(GhostWalk, timerGhostWalk)
                    then
                        CombineSpheres(Quas, Quas, Wex)
                        return;
                    end
                end

                if QuasReady()
                then
                    if CanCombineAbility(ColdSnap, timerColdSnap)
                    then
                        CombineSpheres(Quas, Quas, Quas)
                        return;
                    end
                end

                if AllSpheresReady()
                then
                    if CanCombineAbility(DeafeningBlast, timerDeafeningBlast)
                    then
                        CombineSpheres(Quas, Wex, Exort)
                        return;
                    end
                end

                if QuasWexReady()
                then
                    if CanCombineAbility(Tornado, timerTornado)
                    then
                        CombineSpheres(Wex, Wex, Quas)
                        return;
                    end
                end
            end
        end
    end
end

function ConsiderColdSnap()
    local ability = ColdSnap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("freeze_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ColdSnap что бы добить " .. enemy:GetUnitName(), true);
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
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
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
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderGhostWalk()
    local ability = GhostWalk;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
        then
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    end
end

function ConsiderTornado()
    local ability = Tornado;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local radiusAbility = ability:GetSpecialValueInt("area_of_effect");
    local damageAbility = ability:GetSpecialValueInt("base_damage") + ability:GetSpecialValueInt("quas_damage") +
        ability:GetSpecialValueInt("wex_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("travel_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Tornado что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end

function ConsiderEMP()
    local ability = EMP;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("area_of_effect");
    local damageAbility = ability:GetSpecialValueInt("mana_burned");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую EMP что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end

function ConsiderAlacrity()
    local ability = Alacrity;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            local attackTarget = ally:GetAttackTarget();
            if utility.IsHero(ally) and not ally:HasModifier("modifier_invoker_alacrity")
            then
                if utility.PvPMode(npcBot)
                then
                    if utility.IsHero(botTarget)
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= (ally:GetAttackRange() * 2)
                        then
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                elseif utility.PvEMode(npcBot)
                then
                    if utility.IsBuilding(attackTarget) and utility.CanCastOnInvulnerableTarget(attackTarget)
                    then
                        if (attackTarget:GetHealth() / attackTarget:GetMaxHealth() >= 0.3) and (ManaPercentage >= 0.4)
                        then
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
                if utility.IsHero(attackTarget) or utility.IsBoss(attackTarget)
                then
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    if utility.PvEMode(npcBot)
    then
        if (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую DarkPact против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderChaosMeteor()
    local ability = ChaosMeteor;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local radiusAbility = ability:GetSpecialValueInt("area_of_effect");
    local damageAbility = ability:GetSpecialValueInt("main_damage") + (ability:GetSpecialValueInt("burn_dps") +
        ability:GetSpecialValueInt("burn_duration"));
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChaosMeteor что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end
end

function ConsiderSunStrike()
    local ability = SunStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("delay");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую SunStrike что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
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
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end
end

function ConsiderForgeSpirit()
    local ability = ForgeSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("spirit_attack_range") + npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyTowers = npcBot:GetNearbyTowers(1600, true);
        local enemyBarracks = npcBot:GetNearbyBarracks(1600, true);
        local enemyAncient = GetAncient(GetOpposingTeam());
        if (ManaPercentage >= 0.4) and
            ((#enemyCreeps > 0) or
                (#enemyTowers > 0) or
                (#enemyBarracks > 0) or
                npcBot:GetAttackTarget() == enemyAncient)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

function ConsiderIceWall()
    local ability = IceWall;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("wall_place_distance");
    local radiusAbility = ability:GetSpecialValueInt("wall_element_radius");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and npcBot:IsFacingLocation(botTarget:GetLocation(), 20)
            then
                return BOT_ACTION_DESIRE_HIGH;
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
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
end

function ConsiderDeafeningBlast()
    local ability = DeafeningBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius_end");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("travel_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую DeafeningBlast что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
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
end
