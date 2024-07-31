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
    Abilities[3],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ParalyzingCask = AbilitiesReal[1]
local VoodooRestoration = AbilitiesReal[2]
local Maledict = AbilitiesReal[3]
local VoodooSwitcheroo = AbilitiesReal[4]
local DeathWard = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castParalyzingCaskDesire, castParalyzingCaskTarget = ConsiderParalyzingCask();
    local castVoodooRestorationDesire = ConsiderVoodooRestoration();
    local castMaledictDesire, castMaledictLocation = ConsiderMaledict();
    local castVoodooSwitcherooDesire = ConsiderVoodooSwitcheroo();
    local castDeathWardDesire, castDeathWardLocation = ConsiderDeathWard();

    if (castParalyzingCaskDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ParalyzingCask, castParalyzingCaskTarget);
        return;
    end

    if (castVoodooRestorationDesire ~= nil)
    then
        npcBot:Action_UseAbility(VoodooRestoration);
        return;
    end

    if (castMaledictDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Maledict, castMaledictLocation);
        return;
    end

    if (castVoodooSwitcherooDesire ~= nil)
    then
        npcBot:Action_UseAbility(VoodooSwitcheroo);
        return;
    end

    if (castDeathWardDesire ~= nil)
    then
        npcBot:Action_ClearActions(true);
        npcBot:Action_UseAbilityOnLocation(DeathWard, castDeathWardLocation);
        return;
    end

    -- Trying to stay close to wounded hero
    if npcBot:HasModifier("modifier_voodoo_restoration_heal") and VoodooRestoration:GetToggleState() == true
    then
        if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot)
        then
            local allyAbility = npcBot:GetNearbyHeroes(VoodooRestoration:GetSpecialValueInt("radius") * 2, false,
                BOT_MODE_NONE);
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility)
                do
                    if ally ~= npcBot and utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.8)
                    then
                        if GetUnitToUnitDistance(npcBot, ally) > (VoodooRestoration:GetSpecialValueInt("radius"))
                        then
                            npcBot:Action_ClearActions(false);
                            npcBot:Action_MoveToLocation(ally:GetLocation() +
                            RandomVector(VoodooRestoration:GetSpecialValueInt("radius")));
                        end
                    end
                end
            end
        end
    end
end

function ConsiderParalyzingCask()
    local ability = ParalyzingCask;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("base_damage");
    local radiusAbility = ability:GetSpecialValueInt("bounce_range");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ParalyzingCask что бы сбить заклинание или убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
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
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderVoodooRestoration()
    local ability = VoodooRestoration;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
    local countHeroesToHeal = 0;

    -- Use to heal damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() < 0.8)
            then
                countHeroesToHeal = countHeroesToHeal + 1;
            end
        end

        if countHeroesToHeal > 0
        then
            if ability:GetToggleState() == false
            then
                --npcBot:ActionImmediate_Chat("Использую VoodooRestoration для хила!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        elseif countHeroesToHeal <= 0 and not utility.PvPMode(npcBot)
        then
            if ability:GetToggleState() == true
            then
                --npcBot:ActionImmediate_Chat("Выключаю VoodooRestoration, хил не нужен!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if ability:GetToggleState() == false
                    then
                        --npcBot:ActionImmediate_Chat("Использую VoodooRestoration для атаки!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end
end

function ConsiderMaledict()
    local ability = Maledict;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage() * ability:GetSpecialValueInt("AbilityDuration");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                and not botTarget:HasModifier("modifier_maledict")
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7) and not enemy:HasModifier("modifier_maledict")
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end
end

function ConsiderVoodooSwitcheroo()
    local ability = VoodooSwitcheroo;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = DeathWard:GetSpecialValueInt("attack_range_tooltip");
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            print(tostring(spell.caster:GetName()))
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false and
                not npcBot:HasModifier("modifier_antimage_counterspell") and
                not npcBot:HasModifier("modifier_item_sphere_target") and
                not npcBot:HasModifier("modifier_item_lotus_orb_active")
            then
                npcBot:ActionImmediate_Chat("Использую VoodooSwitcheroo что бы сбить снаряд!",
                    true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1)
        then
            --npcBot:ActionImmediate_Chat("Использую VoodooSwitcheroo на врага!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderDeathWard()
    local ability = DeathWard;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local bonusRange = ability:GetSpecialValueInt("attack_range_tooltip");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую DeathWard на врага в радиусе каста!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + bonusRange
            then
                --npcBot:ActionImmediate_Chat("Использую DeathWard на врага в радиусе атаки варда!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
            end
        end
    end
end
