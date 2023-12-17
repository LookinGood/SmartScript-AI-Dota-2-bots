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
    Talents[2],
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

-- Abilities
local IllusoryOrb = AbilitiesReal[1]
local EtherealJaunt = npcBot:GetAbilityByName("puck_ethereal_jaunt");
local WaningRift = AbilitiesReal[2]
local PhaseShift = AbilitiesReal[3]
local DreamCoil = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castIllusoryOrbDesire, castIllusoryOrbLocation = ConsiderIllusoryOrb();
    local castEtherealJauntDesire = ConsiderEtherealJaunt();
    local castWaningRiftDesire, castWaningRiftLocation = ConsiderWaningRift();
    local castPhaseShiftDesire = ConsiderPhaseShift();
    local castDreamCoilDesire, castDreamCoilLocation = ConsiderDreamCoil();

    if (castIllusoryOrbDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IllusoryOrb, castIllusoryOrbLocation);
        return;
    end

    if (castEtherealJauntDesire ~= nil)
    then
        npcBot:Action_UseAbility(EtherealJaunt);
        return;
    end

    if (castWaningRiftDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WaningRift, castWaningRiftLocation);
        return;
    end

    if (castPhaseShiftDesire ~= nil)
    then
        npcBot:Action_UseAbility(PhaseShift);
        return;
    end

    if (castDreamCoilDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(DreamCoil, castDreamCoilLocation);
        return;
    end
end

function ConsiderIllusoryOrb()
    local ability = IllusoryOrb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("orb_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую IllusoryOrb что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and GetUnitToUnitDistance(npcBot, botTarget) > attackRange
            then
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0) and npcBot:DistanceFromFountain() > castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую IllusoryOrb для отхода!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderEtherealJaunt()
    local ability = EtherealJaunt;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = IllusoryOrb:GetCastRange();
    local radiusAbility = IllusoryOrb:GetSpecialValueInt("radius");
    local projectiles = GetLinearProjectiles();

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (#projectiles > 0)
            then
                for _, project in pairs(projectiles)
                do
                    if project ~= nil and project.ability:GetName() == "puck_illusory_orb"
                    then
                        if GetUnitToUnitDistance(npcBot, botTarget) > attackRange and
                            GetUnitToLocationDistance(botTarget, project.location) <= radiusAbility * 2 or
                            GetUnitToLocationDistance(botTarget, project.location) <= attackRange
                        then
                            --npcBot:ActionImmediate_Chat("Использую EtherealJaunt рядом с врагом!", true);
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        end
    elseif utility.RetreatMode(npcBot)
    then
        local ancient = GetAncient(GetTeam());
        local enemyAncient = GetAncient(GetOpposingTeam());
        if (#projectiles > 0) and npcBot:DistanceFromFountain() >= castRangeAbility
        then
            for _, project in pairs(projectiles)
            do
                if project ~= nil and project.ability:GetName() == "puck_illusory_orb"
                then
                    if GetUnitToLocationDistance(npcBot, project.location) >= attackRange and
                        GetUnitToLocationDistance(ancient, project.location) < GetUnitToLocationDistance(enemyAncient, project.location)
                    then
                        --npcBot:ActionImmediate_Chat("Использую EtherealJaunt для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end
end

function ConsiderWaningRift()
    local ability = WaningRift;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("max_distance");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if get incoming spell
    if not utility.IsAbilityAvailable(PhaseShift)
    then
        local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
        if (#incomingSpells > 0)
        then
            for _, spell in pairs(incomingSpells)
            do
                if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 300 and spell.is_attack == false
                    and spell.is_dodgeable == true
                then
                    --npcBot:ActionImmediate_Chat("Использую WaningRift для уклонения от снарядов!",true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
                end
            end
        end
    end

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую WaningRift сбивая каст в радиусе каста!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + (radiusAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую WaningRift сбивая каст в радиусе каста+радиус!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
            then
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            else
                --npcBot:ActionImmediate_Chat("Использую WaningRift для скачков вокруг врага!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation() + RandomVector(radiusAbility);
            end
        end
        -- Cast if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую WaningRift для отступления!", true);
            return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end
end

function ConsiderPhaseShift()
    local ability = PhaseShift;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_puck_phase_shift")
    then
        return;
    end

    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();

    -- Cast if get incoming spell
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 200 and spell.is_attack == false
            then
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    if npcBot:WasRecentlyDamagedByAnyHero(1.0) or npcBot:WasRecentlyDamagedByTower(1.0)
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end
end

function ConsiderDreamCoil()
    local ability = DreamCoil;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("coil_radius");
    local damageAbility = ability:GetSpecialValueInt("coil_initial_damage") +
        ability:GetSpecialValueInt("coil_break_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + (radiusAbility / 2), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую DreamCoil сбивая каст в радиусе каста!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + (radiusAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую DreamCoil сбивая каст в радиусе каста+радиус!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and (botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1)
        then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
            then
                --npcBot:ActionImmediate_Chat("Использую DreamCoil на врага в радиусе каста!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + (radiusAbility / 2)
            then
                --npcBot:ActionImmediate_Chat("Использую DreamCoil на врага в дальности+радиусе каста!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую DreamCoil по 2+ врагам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую DreamCoil отступая на врага в дальности каста!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + (radiusAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat( "Использую ArenaOfBlood DreamCoil на врага в дальности+радиусе каста!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end
end
