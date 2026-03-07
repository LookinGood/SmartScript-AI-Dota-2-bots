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
local Blink = npcBot:GetAbilityByName("antimage_blink");
local Counterspell = npcBot:GetAbilityByName("antimage_counterspell");
local BlinkFragment = npcBot:GetAbilityByName("antimage_mana_overload");
local CounterspellAlly = npcBot:GetAbilityByName("antimage_counterspell_ally");
local ManaVoid = npcBot:GetAbilityByName("antimage_mana_void");

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

    if (castBlinkDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Blink, castBlinkLocation);
        return;
    end

    if (castCounterspellDesire > 0)
    then
        npcBot:Action_UseAbility(Counterspell);
        return;
    end

    if (castBlinkFragmentDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(BlinkFragment, castBlinkFragmentLocation);
        return;
    end

    if (castCounterspellAllyDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(CounterspellAlly, castCounterspellAllyTarget);
        return;
    end

    if (castManaVoidDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(ManaVoid, castManaVoidTarget);
        return;
    end
end

function ConsiderBlink()
    local ability = Blink;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local minBlinkRange = ability:GetSpecialValueInt("min_blink_range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if target too far away
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastOnInvulnerableTarget(botTarget) and (GetUnitToUnitDistance(npcBot, botTarget) > minBlinkRange
                    and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2))
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end

    -- Cast if get incoming spell
    if not utility.IsAbilityAvailable(Counterspell) and not utility.HaveReflectSpell(npcBot)
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

    -- If going somewhere
    if utility.WanderMode(npcBot) and (ManaPercentage >= 0.5)
    then
        local botMoveSpeed = npcBot:GetCurrentMovementSpeed();
        local forwardTime = castRangeAbility / botMoveSpeed;
        local extrapolatedLocation = npcBot:GetExtrapolatedLocation(forwardTime);
        if npcBot:IsFacingLocation(extrapolatedLocation, 20) and IsLocationPassable(extrapolatedLocation) and
            npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_MOVE_TO and
            (GetUnitToLocationDistance(npcBot, extrapolatedLocation) <= castRangeAbility and
                GetUnitToLocationDistance(npcBot, extrapolatedLocation) >= castRangeAbility / 2) and
            (utility.CountEnemyHeroAroundPosition(extrapolatedLocation, castRangeAbility) <= 0 and
                utility.CountEnemyTowerAroundPosition(extrapolatedLocation, castRangeAbility) <= 0)
        then
            --npcBot:ActionImmediate_Chat("Телепортируюсь вперед.", true);
            --npcBot:ActionImmediate_Ping(extrapolatedLocation.x, extrapolatedLocation.y, false);
            return BOT_ACTION_DESIRE_VERYLOW, extrapolatedLocation;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderCounterspell()
    local ability = Counterspell;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if utility.HaveReflectSpell(npcBot)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            --[[             if spell.is_attack == false
            then
                if not utility.IsAlly(npcBot, spell.caster)
                then
                    npcBot:ActionImmediate_Chat("Кастер враг: " .. spell.caster:GetUnitName(), true);
                else
                    npcBot:ActionImmediate_Chat("Кастер союзник: " .. spell.caster:GetUnitName(), true);
                end
            end ]]
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderBlinkFragment()
    local ability = BlinkFragment;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
                    return BOT_ACTION_DESIRE_MODERATE, enemy:GetLocation();
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderCounterspellAlly()
    local ability = CounterspellAlly;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- General use
    if (#allyAbility > 1)
    then
        for _, ally in pairs(allyAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and not utility.HaveReflectSpell(ally)
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

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderManaVoid()
    local ability = ManaVoid;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damagePercentMana = ability:GetSpecialValueFloat("mana_void_damage_per_mana");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Generic use
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = damagePercentMana * (enemy:GetMaxMana() - enemy:GetMana())
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or (enemy:GetMana() / enemy:GetMaxMana() <= 0.2) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
