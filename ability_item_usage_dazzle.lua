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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

local AbilityToLevelUp =
{
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Ability Use
function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    PoisonTouch = AbilitiesReal[1]
    ShallowGrave = AbilitiesReal[2]
    ShadowWave = AbilitiesReal[3]
    BadJuju = AbilitiesReal[6]

    castPoisonTouchDesire, castPoisonTouchTarget = ConsiderPoisonTouch();
    castShallowGraveDesire, castShallowGraveTarget = ConsiderShallowGrave();
    castShadowWaveDesire, castShadowWaveTarget = ConsiderShadowWave();
    castBadJujuDesire = ConsiderBadJuju();

    if (castPoisonTouchDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(PoisonTouch, castPoisonTouchTarget);
        return;
    end

    if (castShallowGraveDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ShallowGrave, castShallowGraveTarget);
        return;
    end

    if (castShadowWaveDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ShadowWave, castShadowWaveTarget);
        return;
    end

    if (castBadJujuDesire ~= nil)
    then
        npcBot:Action_UseAbility(BadJuju);
        return;
    end
end

function ConsiderPoisonTouch()
    local ability = PoisonTouch;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --  npcBot:ActionImmediate_Chat("Использую Poison Touch по врагу в радиусе действия!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false) and enemy:IsChanneling()
                then
                    --  npcBot:ActionImmediate_Chat("Использую Poison Touch что бы сбить заклинание цели!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    -- Interrupt cast
                elseif utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false)
                then
                    -- npcBot:ActionImmediate_Chat("Использую Poison Touch по врагу в радиусе!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreepsLane = npcBot:GetNearbyLaneCreeps(castRangeAbility, true)
        if (#enemyCreepsLane > 2) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreepsLane) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy)) and utility.SafeCast(enemy, true)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= CastRangeAbility and (ManaPercentage >= 0.4)
        then
            --npcBot:ActionImmediate_Chat("Использую Poison Touch на Рошана!", true);
            return BOT_MODE_DESIRE_MODERATE, botTarget;
        end
    end
end

function ConsiderShallowGrave()
    local ability = ShallowGrave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2 and not utility.TargetCantDie(ally))
                and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую Shallow Grave на союзного героя со здоровьем ниже 20%!", true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end

function ConsiderShadowWave()
    local ability = ShadowWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("damage_radius"));
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- General use on allied heroes
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                if (#allyAbility > 1)
                then
                    if ally ~= npcBot
                    then
                        --npcBot:ActionImmediate_Chat("Использую Shadow Wave на союзного героя!",true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    elseif ally == npcBot
                    then
                        --npcBot:ActionImmediate_Chat("Использую Shadow Wave на союзника но ранен я!", true);
                        return BOT_ACTION_DESIRE_HIGH, allyAbility[2];
                    end
                elseif (#allyAbility == 1)
                then
                    --npcBot:ActionImmediate_Chat("Использую Shadow Wave на себя когда я один!", true);
                    return BOT_ACTION_DESIRE_HIGH, npcBot;
                end
            end
        end
    end

    -- Attack or Laning use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_LANING
    then
        local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
        if (#allyCreeps > 0)
        then
            for _, ally in pairs(allyCreeps)
            do
                local enemyAbility = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility)
                    do
                        if utility.CanCastOnInvulnerableTarget(enemy)
                        then
                            --npcBot:ActionImmediate_Chat( "Использую Shadow Wave на союзного крипа что бы продамажить врага!",true);
                            return BOT_ACTION_DESIRE_MODERATE, ally;
                        end
                    end
                end
            end
        end
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                local enemyAbility = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility)
                    do
                        if utility.CanCastOnInvulnerableTarget(enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Shadow Wave на союзного героя что бы продамажить врага!",true);
                            return BOT_ACTION_DESIRE_MODERATE, ally;
                        end
                    end
                end
            end
        end
    end

    -- Attack use
    if npcBot:HasScepter()
    then
        if utility.PvPMode(npcBot)
        then
            if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and
                GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Shadow Wave на врага!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end

--[[ local function GetBadJujuCount(npcTarget)
    local modifier = npcTarget:GetModifierByName("modifier_dazzle_bad_juju_armor_counter")
    if (modifier ~= nil)
    then
        return npcTarget:GetModifierStackCount(modifier);
    else
        return 0
    end
end ]]

function ConsiderBadJuju()
    local ability = BadJuju;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- General use
    if botMode ~= BOT_MODE_RETREAT and utility.TargetCantDie(npcBot)
    then
        if (not PoisonTouch:IsCooldownReady() or
                not ShallowGrave:IsCooldownReady() or
                not ShadowWave:IsCooldownReady())
        then
            --npcBot:ActionImmediate_Chat("Использую BadJuju пока другая способность на кулдауне!",true);
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end

---- DELETED ABILITY
--#region GoodJuju
--[[ GoodJuju = npcBot:GetAbilityByName("dazzle_good_juju");

 castGoodJujuDesire, castGoodJujuTarget = ConsiderGoodJuju();

if (castGoodJujuDesire ~= nil)
then
    npcBot:Action_UseAbilityOnEntity(GoodJuju, castGoodJujuTarget);
    return;
end

function ConsiderGoodJuju()
    if not GoodJuju:IsFullyCastable() then
        return
    end

    -- General use on allied heroes
    if not GoodJuju:IsPassive() then
        local npcBot = GetBot();
        local CastRangeGoodJuju = GoodJuju:GetCastRange()
        local allysGoodJuju = npcBot:GetNearbyHeroes(CastRangeGoodJuju + 200, false, BOT_MODE_NONE);
        for _, eGoodJuju in pairs(allysGoodJuju)
        do
            if eGoodJuju:GetHealth() / eGoodJuju:GetMaxHealth() <= 0.5 and utility.IsHero(eGoodJuju) then
                --npcBot:ActionImmediate_Chat("Использую GoodJuju на союзного героя!",true);
                return BOT_ACTION_DESIRE_HIGH, eGoodJuju;
            end
        end
    end
end ]]
--#endregion


-- Heals allys creeps if there is an enemy Hero nearby
--[[     if botMode ~= BOT_MODE_RETREAT and (ManaPercentage >= 0.7) then
        for _, aCreeps in pairs(allysCreeps)
        do
            eHero = aCreeps:GetNearbyHeroes(damageRadiusShadowWave, true, BOT_MODE_NONE);
        end
        if #eHero > 0 and utility.CanCastOnInvulnerableTarget(eHero) then
            npcBot:ActionImmediate_Chat("Использую Shadow Wave на крипа рядом с которым вражеский герой!",
                true);
            return BOT_ACTION_DESIRE_HIGH, allysCreeps[1];
        end
    end ]]
--[[
    if npcBot:GetActiveMode() ~= BOT_MODE_RETREAT and (ManaPercentage >= 0.7) then
        for _, eShadowWave in pairs(enemyShadowWave)
        do
            if utility.CanCastOnInvulnerableTarget(eShadowWave) and targetShadowWave == nil then
                targetShadowWave = eShadowWave
                allysCreeps = targetShadowWave:GetNearbyCreeps(damageRadiusShadowWave, false);
            end
        end
        if targetShadowWave ~= nil and #allysCreeps > 0 then
            npcBot:ActionImmediate_Chat("Использую Shadow Wave на крипа рядом с которым вражеский герой!",
                true);
            return BOT_ACTION_DESIRE_HIGH, allysCreeps[1];
        end
    end ]]
--[[         -- Heal ally creeps if push or def line
        if (utility.PvEMode(npcBot) == true)
        then
            for _, aCreepsLane in pairs(allysCreeps) do
                if #allysCreeps > 2 and aCreepsLane:GetHealth() / aCreepsLane:GetMaxHealth() < 0.5 and (ManaPercentage >= 0.7) then
                    --npcBot:ActionImmediate_Chat("Использую ShadowWave на союзных крипов!", true);
                    return BOT_MODE_DESIRE_VERYLOW, allysCreeps[1];
                end
            end
        end ]]
--[[     -- Heals allys Hero if there is an enemy Hero nearby
    if npcBot:GetActiveMode() ~= BOT_MODE_RETREAT then
        for _, allysHero in pairs(allysShadowWave)
        do
            if allysHero:GetHealth() / allysHero:GetMaxHealth() <= 0.9 then
                HeroShadowWave = allysHero;
                local enemyHeroNearAlly = HeroShadowWave:GetNearbyHeroes(damageRadiusShadowWave, true, BOT_MODE_NONE);
                if #enemyHeroNearAlly > 0 and enemyHeroNearAlly ~= nil then
                    npcBot:ActionImmediate_Chat("Использую ShadowWave на союзного Героя рядом с вражеским Героем!",
                        true);
                    return BOT_ACTION_DESIRE_HIGH, enemyHeroNearAlly;
                end
            end
        end
    end ]]