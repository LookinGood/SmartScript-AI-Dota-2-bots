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
    Abilities[1],
    Abilities[2],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
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

    Blink = AbilitiesReal[2]
    SpellShield = AbilitiesReal[3]
    BlinkFragment = AbilitiesReal[4]
    ManaVoid = AbilitiesReal[6]

    castBlinkDesire, castBlinkLocation = ConsiderBlink();
    castSpellshieldDesire = ConsiderSpellShield();
    castBlinkFragmentDesire, castBlinkFragmentLocation = ConsiderBlinkFragment();
    castManaVoidDesire, castManaVoidTarget = ConsiderManaVoid();

    if (castManaVoidDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ManaVoid, castManaVoidTarget);
        return;
    end

    if (castBlinkDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Blink, castBlinkLocation);
        return;
    end

    if (castSpellshieldDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpellShield);
        return;
    end

    if (castBlinkFragmentDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BlinkFragment, castBlinkFragmentLocation);
        return;
    end
end

function ConsiderBlink()
    local ability = Blink;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
        -- Cast if need retreat
    elseif botMode == BOT_MODE_RETREAT and npcBot:DistanceFromFountain() >= castRangeAbility
    then
        return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
    end
    -- Cast if get incoming spell
    if not utility.IsAbilityAvailable(SpellShield)
    then
        local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
        if (#incomingSpells > 0)
        then
            for _, spell in pairs(incomingSpells)
            do
                if GetUnitToLocationDistance(npcBot, spell.location) <= 700 and spell.is_attack == false and spell.is_dodgeable == true
                then
                    return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
                end
            end
        end
    end

    -- If going somewhere
    if not utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
    then
        return BOT_ACTION_DESIRE_VERYLOW, botTarget:GetLocation();
    end
end

function ConsiderSpellShield()
    local ability = SpellShield;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
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
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
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
            if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
            then
                local damageAbility = damagePercentMana * (enemy:GetMaxMana() - enemy:GetMana())
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:GetMana() / enemy:GetMaxMana() <= 0.2 or enemy:IsChanneling()
                then
                    return BOT_MODE_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end
