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
    Abilities[1],
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Rage = AbilitiesReal[1]
local OpenWounds = AbilitiesReal[4]
local Consume = npcBot:GetAbilityByName("life_stealer_consume");
local Infest = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castRageDesire = ConsiderRage();
    local castOpenWoundsDesire, castOpenWoundsTarget = ConsiderOpenWounds();
    local castConsumeDesire = ConsiderConsume();
    local castInfestDesire, castInfestTarget = ConsiderInfest();

    if (castRageDesire ~= nil)
    then
        npcBot:Action_UseAbility(Rage);
        return;
    end

    if (castOpenWoundsDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(OpenWounds, castOpenWoundsTarget);
        return;
    end

    if (castConsumeDesire ~= nil)
    then
        npcBot:Action_UseAbility(Consume);
        return;
    end

    if (castInfestDesire ~= nil)
    then
       --infestTarget = castInfestTarget;
        npcBot:Action_UseAbilityOnEntity(Infest, castInfestTarget);
        return;
    end

    if npcBot:HasModifier("modifier_life_stealer_infest") and utility.RetreatMode(npcBot)
        --and infestTarget:IsCreep()
    then
        npcBot:ActionImmediate_Chat("Отступаю в крипе!", true);
        npcBot:ActionPush_MoveToLocation(utility.SafeLocation(npcBot));
    end
end

function ConsiderRage()
    local ability = Rage;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if not utility.CanCastOnMagicImmuneTarget(npcBot)
    then
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

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if (utility.IsHero(botTarget) or utility.IsRoshan(botTarget)) and (GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 4)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- General use
    if (HealthPercentage <= 0.8) and ((npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0)))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderOpenWounds()
    local ability = OpenWounds;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
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
    end
end

function ConsiderConsume()
    local ability = Consume;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility = Infest:GetSpecialValueInt("damage");
    local radiusAbility = Infest:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, Infest:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Consume что бы добить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_life_stealer_infest")
    then
        if not utility.RetreatMode(npcBot)
        then
            --npcBot:ActionImmediate_Chat("Использую Consume не отступая!", true);
            return BOT_ACTION_DESIRE_HIGH;
        else
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility <= 0)
            then
                --npcBot:ActionImmediate_Chat("Использую Consume когда врагов рядом нет!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderInfest()
    local ability = Infest;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local allyCreepsAbility = npcBot:GetNearbyCreeps(castRangeAbility, false);
    local enemyCreepsAbility = npcBot:GetNearbyCreeps(castRangeAbility, true);
    local allyHeroesAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyHeroesAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if (#enemyCreepsAbility > 0)
                    then
                        for _, enemyCreep in pairs(enemyCreepsAbility) do
                            if utility.CanCastSpellOnTarget(ability, enemyCreep) and GetUnitToUnitDistance(enemyCreep, enemy) <= radiusAbility
                            then
                                --npcBot:ActionImmediate_Chat("Использую Infest на вражеском крипе что бы убить цель!", true);
                                return BOT_ACTION_DESIRE_VERYHIGH, enemyCreep;
                            end
                        end
                    end
                    if (#allyCreepsAbility > 0)
                    then
                        for _, allyCreep in pairs(allyCreepsAbility) do
                            if utility.CanCastSpellOnTarget(ability, allyCreep) and GetUnitToUnitDistance(allyCreep, enemy) <= radiusAbility
                            then
                                --npcBot:ActionImmediate_Chat("Использую Infest на союзном крипе что бы убить цель!",true);
                                return BOT_ACTION_DESIRE_VERYHIGH, allyCreep;
                            end
                        end
                    end
                    if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO)
                    then
                        if (#enemyHeroesAbility > 0)
                        then
                            for _, enemyHero in pairs(enemyHeroesAbility) do
                                if utility.CanCastSpellOnTarget(ability, enemyHero) and GetUnitToUnitDistance(enemyHero, enemy) <= radiusAbility
                                then
                                    --npcBot:ActionImmediate_Chat("Использую Infest на вражеском герое что бы убить цель!",true);
                                    return BOT_ACTION_DESIRE_VERYHIGH, enemyHero;
                                end
                            end
                        end
                        if (#allyHeroesAbility > 0)
                        then
                            for _, allyHero in pairs(allyHeroesAbility) do
                                if utility.CanCastSpellOnTarget(ability, allyHero) and GetUnitToUnitDistance(allyHero, enemy) <= radiusAbility
                                then
                                    --npcBot:ActionImmediate_Chat("Использую Infest на союзном герое что бы убить цель!",true);
                                    return BOT_ACTION_DESIRE_VERYHIGH, allyHero;
                                end
                            end
                        end
                    end
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
            then
                if (#enemyCreepsAbility > 0)
                then
                    for _, enemyCreep in pairs(enemyCreepsAbility) do
                        if utility.CanCastSpellOnTarget(ability, enemyCreep) and GetUnitToUnitDistance(enemyCreep, botTarget) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую Infest на вражеском крипе для атаки!", true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemyCreep;
                        end
                    end
                end
                if (#allyCreepsAbility > 0)
                then
                    for _, allyCreep in pairs(allyCreepsAbility) do
                        if GetUnitToUnitDistance(allyCreep, botTarget) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую Infest на союзном крипе для атаки!",true);
                            return BOT_ACTION_DESIRE_VERYHIGH, allyCreep;
                        end
                    end
                end
                if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO)
                then
                    if (#enemyHeroesAbility > 0)
                    then
                        for _, enemyHero in pairs(enemyHeroesAbility) do
                            if utility.CanCastSpellOnTarget(ability, enemyHero) and GetUnitToUnitDistance(enemyHero, botTarget) <= radiusAbility
                            then
                                npcBot:ActionImmediate_Chat("Использую Infest на вражеском герое для атаки!",
                                    true);
                                return BOT_ACTION_DESIRE_VERYHIGH, enemyHero;
                            end
                        end
                    end
                    if (#allyHeroesAbility > 0)
                    then
                        for _, allyHero in pairs(allyHeroesAbility) do
                            if GetUnitToUnitDistance(allyHero, botTarget) <= radiusAbility
                            then
                                npcBot:ActionImmediate_Chat("Использую Infest на союзном герое для атаки!",
                                    true);
                                return BOT_ACTION_DESIRE_VERYHIGH, allyHero;
                            end
                        end
                    end
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyCreepsAbility > 0)
        then
            for _, enemyCreep in pairs(enemyCreepsAbility) do
                if utility.CanCastSpellOnTarget(ability, enemyCreep)
                then
                    --npcBot:ActionImmediate_Chat("Использую Infest на вражеском крипе для отступления!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemyCreep;
                end
            end
        end
        if (#allyCreepsAbility > 0)
        then
            for _, allyCreep in pairs(allyCreepsAbility) do
                if utility.CanCastSpellOnTarget(ability, allyCreep) and GetUnitToUnitDistance(allyCreep, enemy) <= radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Infest на союзном крипе для отступления!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, allyCreep;
                end
            end
        end
        if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO)
        then
            local allyHeroesAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local enemyHeroesAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            if (#enemyHeroesAbility > 0) and (#allyHeroesAbility <= 0)
            then
                for _, enemyHero in pairs(enemyHeroesAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemyHero)
                    then
                        npcBot:ActionImmediate_Chat("Использую Infest на вражеском герое что бы сбежать!",
                            true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemyHero;
                    end
                end
            end
            if (#allyHeroesAbility > 0)
            then
                for _, allyHero in pairs(allyHeroesAbility) do
                    if utility.CanCastSpellOnTarget(ability, allyHero) and GetUnitToUnitDistance(allyHero, enemy) <= radiusAbility
                    then
                        npcBot:ActionImmediate_Chat("Использую Infest на союзном герое что бы сбежать!",
                            true);
                        return BOT_ACTION_DESIRE_VERYHIGH, allyHero;
                    end
                end
            end
        end
    end
end
