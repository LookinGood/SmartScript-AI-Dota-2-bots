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
local EarthSpike = AbilitiesReal[1]
local Hex = AbilitiesReal[2]
local ManaDrain = AbilitiesReal[3]
local FingerOfDeath = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castEarthSpikeDesire, castEarthSpikeTarget = ConsiderEarthSpike();
    local castHexDesire, castHexTarget, castHexTargetType = ConsiderHex();
    local castManaDrainDesire, castManaDrainTarget = ConsiderManaDrain();
    local castFingerOfDeathDesire, castFingerOfDeathTarget = ConsiderFingerOfDeath();

    if (castEarthSpikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(EarthSpike, castEarthSpikeTarget);
        return;
    end

    if (castHexDesire ~= nil)
    then
        if (castHexTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(Hex, castHexTarget);
            return;
        elseif (castHexTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(Hex, castHexTarget);
            return;
        end
    end

    if (castHexDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Hex, castHexTarget);
        return;
    end

    if (castManaDrainDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ManaDrain, castManaDrainTarget);
        return;
    end

    if (castFingerOfDeathDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FingerOfDeath, castFingerOfDeathTarget);
        return;
    end
end

function ConsiderEarthSpike()
    local ability = EarthSpike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("width");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
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
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                if not utility.IsDisabled(botTarget)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                else
                    if (#enemyAbility > 1)
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
        if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую EarthSpike по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderHex()
    local ability = Hex;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and enemy:IsChanneling()
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                elseif
                    utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                        "location";
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
        then
            if not utility.IsDisabled(botTarget)
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, botTarget, "target";
                elseif
                    utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0),
                        "location";
                end
            else
                if (#enemyAbility > 1)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                        then
                            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                            then
                                return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                            elseif
                                utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                            then
                                return BOT_ACTION_DESIRE_VERYHIGH,
                                    utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                                    "location";
                            end
                        end
                    end
                end
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
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    elseif
                        utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0),
                            "location";
                    end
                end
            end
        end
    end
end

function ConsiderManaDrain()
    local ability = ManaDrain;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Use if need restore mana
    if not utility.RetreatMode(npcBot) and (HealthPercentage >= 0.6)
    then
        if (ManaPercentage <= 0.7) or npcBot:GetMana() < EarthSpike:GetManaCost()
            or npcBot:GetMana() < Hex:GetManaCost() or npcBot:GetMana() < FingerOfDeath:GetManaCost()
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local enemyTower = npcBot:GetNearbyTowers(1000, true);
            if #enemyAbility > 0 and #enemyTower <= 0
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and enemy:GetMana() > 0 and enemy:GetMana() / enemy:GetMaxMana() >= 0.2
                    then
                        --npcBot:ActionImmediate_Chat("Использую ManaDrain для высасывания маны из героя!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if #enemyCreeps > 0 and #enemyTower <= 0 and npcBot:TimeSinceDamagedByCreep() >= 5.0
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and enemy:GetMana() > 0 and enemy:GetMana() / enemy:GetMaxMana() >= 0.4
                        and enemy:GetHealth() / enemy:GetMaxHealth() >= 0.4
                    then
                        --npcBot:ActionImmediate_Chat("Использую ManaDrain для высасывания маны из крипа!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if (ManaPercentage <= 0.7) or npcBot:GetMana() < EarthSpike:GetManaCost()
            or npcBot:GetMana() < Hex:GetManaCost() or npcBot:GetMana() < FingerOfDeath:GetManaCost()
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую ManaDrain для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end

function ConsiderFingerOfDeath()
    local ability = FingerOfDeath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LagunaBlade что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
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
                and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5
            then
                --npcBot:ActionImmediate_Chat("Использую LagunaBlade для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end
