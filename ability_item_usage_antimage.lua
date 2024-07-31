---@diagnostic disable: undefined-global, redefined-local
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
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Blink = AbilitiesReal[2]
local Counterspell = AbilitiesReal[3]
local BlinkFragment = AbilitiesReal[4]
local CounterspellAlly = AbilitiesReal[5]
local ManaVoid = AbilitiesReal[6]

-- Ability Use
function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castBlinkDesire, castBlinkLocation = ConsiderBlink();
    local castCounterspellDesire = ConsiderCounterspell();
    local castBlinkFragmentDesire, castBlinkFragmentLocation = ConsiderBlinkFragment();
    local castCounterspellAllyDesire, castCounterspellAllyTarget = ConsiderCounterspellAlly();
    local castManaVoidDesire, castManaVoidTarget = ConsiderManaVoid();

    if (castBlinkDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Blink, castBlinkLocation);
        return;
    end

    if (castCounterspellDesire ~= nil)
    then
        npcBot:Action_UseAbility(Counterspell);
        return;
    end

    if (castBlinkFragmentDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BlinkFragment, castBlinkFragmentLocation);
        return;
    end

    if (castCounterspellAllyDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(CounterspellAlly, castCounterspellAllyTarget);
        return;
    end

    if (castManaVoidDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ManaVoid, castManaVoidTarget);
        return;
    end
end

function ConsiderBlink()
    local ability = Blink;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local minBlinkRange = ability:GetSpecialValueInt("min_blink_range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and (GetUnitToUnitDistance(npcBot, botTarget) > minBlinkRange
                    and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2))
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
    -- Cast if get incoming spell
    if not utility.IsAbilityAvailable(Counterspell)
    then
        local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
        if (#incomingSpells > 0)
        then
            for _, spell in pairs(incomingSpells)
            do
                if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 700
                    and spell.is_attack == false and spell.is_dodgeable == true
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
                end
            end
        end
    end

    --[[     -- If going somewhere
    if not utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
    then
        return BOT_ACTION_DESIRE_VERYLOW, botTarget:GetLocation();
    end ]]
end

function ConsiderCounterspell()
    local ability = Counterspell;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false and
                not npcBot:HasModifier("modifier_antimage_counterspell") and
                not npcBot:HasModifier("modifier_item_sphere_target") and
                not npcBot:HasModifier("modifier_item_lotus_orb_active")
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end
end

function ConsiderBlinkFragment()
    local ability = BlinkFragment;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.IsValidTarget(enemy)
                then
                    return BOT_MODE_DESIRE_MODERATE, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderCounterspellAlly()
    local ability = CounterspellAlly;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and
                not ally:HasModifier("modifier_antimage_counterspell") and
                not ally:HasModifier("modifier_item_sphere_target") and
                not ally:HasModifier("modifier_item_lotus_orb_active")
            then
                local incomingSpells = ally:GetIncomingTrackingProjectiles();
                if (#incomingSpells > 0)
                then
                    for _, spell in pairs(incomingSpells)
                    do
                        if not utility.IsAlly(ally, spell.caster) and GetUnitToLocationDistance(ally, spell.location) <= 300 and spell.is_attack == false
                        then
                            return BOT_ACTION_DESIRE_VERYHIGH, ally;
                        end
                    end
                end
            end
        end
    end
end

function ConsiderManaVoid()
    local ability = ManaVoid;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damagePercentMana = ability:GetSpecialValueFloat("mana_void_damage_per_mana");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Generic use
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = damagePercentMana * (enemy:GetMaxMana() - enemy:GetMana())
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:GetMana() / enemy:GetMaxMana() <= 0.2 or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end
