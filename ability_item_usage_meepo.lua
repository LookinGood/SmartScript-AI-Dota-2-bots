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
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Abilities[2],
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[3],
    Abilities[1],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Earthbind = AbilitiesReal[1]
local Poof = AbilitiesReal[2]
local Dig = AbilitiesReal[4]
local Megameepo = AbilitiesReal[5]
local MegaMeepoFling = npcBot:GetAbilityByName("meepo_megameepo_fling");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castEarthbindDesire, castEarthbindLocation = ConsiderEarthbind();
    local castPoofDesire, castPoofLocation = ConsiderPoof();
    local castDigDesire = ConsiderDig();
    local castMegameepoDesire = ConsiderMegameepo();
    local castMegaMeepoFlingDesire, castMegaMeepoFlingTarget = ConsiderMegaMeepoFling();

    if (castEarthbindDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Earthbind, castEarthbindLocation);
        return;
    end

    if (castPoofDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Poof, castPoofLocation);
        return;
    end

    if (castDigDesire > 0)
    then
        npcBot:Action_UseAbility(Dig);
        return;
    end

    if (castMegameepoDesire > 0)
    then
        npcBot:Action_UseAbility(Megameepo);
        return;
    end

    if (castMegaMeepoFlingDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(MegaMeepoFling, castMegaMeepoFlingTarget);
        return;
    end
end

local function IsMeepo(npcTarget)
    return string.find(npcTarget:GetUnitName(), "meepo") and npcBot:GetPlayerID() == npcTarget:GetPlayerID();
end

local function HasMeepoAroundTarget(npcTarget, radius)
    local allyHeroesAround = npcTarget:GetNearbyHeroes(radius, true, BOT_MODE_NONE);

    if (#allyHeroesAround > 0)
    then
        for _, ally in pairs(allyHeroesAround) do
            if IsMeepo(ally) and npcBot:GetPlayerID() == ally:GetPlayerID()
            then
                return true;
            end
        end
    end

    return false;
end

local function GetCountMeepoAroundBot(radius)
    local count = 0;
    local allyHeroesAround = npcBot:GetNearbyHeroes(radius, false, BOT_MODE_NONE);

    if (#allyHeroesAround > 1)
    then
        for _, ally in pairs(allyHeroesAround) do
            if ally ~= npcBot and not ally:IsIllusion() and IsMeepo(ally) and npcBot:GetPlayerID() == ally:GetPlayerID()
                and not ally:HasModifier("modifier_meepo_petrify")
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function ConsiderEarthbind()
    local ability = Earthbind;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPoof()
    local ability = Poof;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("poof_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and HasMeepoAroundTarget(enemy, radiusAbility)
                then
                    --npcBot:ActionImmediate_Chat("Использую Poof что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and HasMeepoAroundTarget(botTarget, radiusAbility)
            then
                --npcBot:ActionImmediate_Chat("Использую Poof по цели рядом с мипо", true);
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Use if need retreat
    if utility.RetreatMode(npcBot)
    then
        local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);
        if (#allyHeroes > 1)
        then
            for _, ally in pairs(allyHeroes)
            do
                if ally ~= npcBot and IsMeepo(ally) and GetUnitToUnitDistance(npcBot, ally) >= 1000
                    and ally:DistanceFromFountain() < npcBot:DistanceFromFountain()
                then
                    --npcBot:ActionImmediate_Chat("Использую Poof по мипо который ближе к фонтану.", true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, ally, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDig()
    local ability = Dig;
    if not utility.IsAbilityAvailable(ability)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_meepo_petrify")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
                and not utility.HaveReflectSpell(npcBot)
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- General use
    if (HealthPercentage <= 0.5)
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderMegameepo()
    local ability = Megameepo;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local countMeepoAround = GetCountMeepoAroundBot(radiusAbility);

    if (countMeepoAround <= 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Megameepo при атаке!", true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local allyHeroes = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
        if (#allyHeroes > 0)
        then
            for _, ally in pairs(allyHeroes)
            do
                if IsMeepo(ally) and not ally:HasModifier("modifier_meepo_petrify") and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6)
                    and ally:WasRecentlyDamagedByAnyHero(3.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Megameepo при отходе!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderMegaMeepoFling()
    local ability = MegaMeepoFling;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusMegaMeepo = Megameepo:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("fling_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0) and not utility.RetreatMode(npcBot)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую MegaMeepoFling что бы убить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
                and GetUnitToUnitDistance(npcBot, botTarget) > radiusMegaMeepo
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
