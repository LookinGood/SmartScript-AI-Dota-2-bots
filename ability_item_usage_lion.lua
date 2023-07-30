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
    Talents[5],
    Talents[8],
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

    local castEarthSpikeDesire, castEarthSpikeTarget, castEarthSpikeTargetType = ConsiderEarthSpike();
    local castHexDesire, castHexTarget = ConsiderHex();
    local castManaDrainDesire, castManaDrainTarget = ConsiderManaDrain();
    local castFingerOfDeathDesire, castFingerOfDeathTarget = ConsiderFingerOfDeath();

    if (castEarthSpikeDesire ~= nil)
    then
        if (castEarthSpikeTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(EarthSpike, castEarthSpikeTarget);
            return;
        elseif (castEarthSpikeTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(EarthSpike, castEarthSpikeTarget);
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
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike что бы сбить заклинание по цели!", true);
                        return BOT_MODE_DESIRE_HIGH, enemy, "target";
                    else
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike что бы сбить заклинание по области!",true);
                        return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                if not utility.IsDisabled(botTarget)
                then
                    if utility.SafeCast(botTarget, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike по основной цели!", true);
                        return BOT_MODE_DESIRE_HIGH, botTarget, "target";
                    else
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike по основной цели по земле!",true);
                        return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility), "location";
                    end
                else
                    if (#enemyAbility > 1)
                    then
                        for _, enemy in pairs(enemyAbility) do
                            if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                            then
                                if utility.SafeCast(enemy, true)
                                then
                                    --npcBot:ActionImmediate_Chat("Использую EarthSpike по второй цели!", true);
                                    return BOT_MODE_DESIRE_HIGH, enemy, "target";
                                else
                                    --npcBot:ActionImmediate_Chat("Использую EarthSpike по второй цели по земле!",true);
                                    return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility),
                                        "location";
                                end
                            end
                        end
                    end
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike что бы оторваться по цели", true);
                        return BOT_MODE_DESIRE_HIGH, enemy, "target";
                    else
                        --npcBot:ActionImmediate_Chat("Использую EarthSpike что бы оторваться по области", true);
                        return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility), "location";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.6) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую EarthSpike по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            if utility.SafeCast(enemy, true)
            then
                --npcBot:ActionImmediate_Chat("Использую EarthSpike на лайне по цели!", true);
                return BOT_MODE_DESIRE_HIGH, enemy, "target";
            else
                --npcBot:ActionImmediate_Chat("Использую EarthSpike на лайне по области!", true);
                return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
            end
        end
    end
end

function ConsiderHex()
    local ability = Hex;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Hex что бы сбить заклинание!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and utility.SafeCast(botTarget, false)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
        then
            if not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Hex по основной цели!", true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            else
                if (#enemyAbility > 1)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Hex по второй цели!", true);
                            return BOT_MODE_DESIRE_HIGH, enemy;
                        end
                    end
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy) and utility.SafeCast(enemy, false)
                then
                    --npcBot:ActionImmediate_Chat("Использую Hex для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
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
    if botMode ~= BOT_MODE_RETREAT and (HealthPercentage >= 0.6)
    then
        if (ManaPercentage <= 0.7) or npcBot:GetMana() < EarthSpike:GetManaCost()
            or npcBot:GetMana() < Hex:GetManaCost() or npcBot:GetMana() < FingerOfDeath:GetManaCost()
        then
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local enemyTower = npcBot:GetNearbyTowers(1000, true);
            if #enemyAbility > 0 and #enemyTower <= 0
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false)
                        and enemy:GetMana() > 0 and enemy:GetMana() / enemy:GetMaxMana() >= 0.2
                    then
                        --npcBot:ActionImmediate_Chat("Использую ManaDrain для высасывания маны из героя!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if #enemyCreeps > 0 and #enemyTower <= 0 and npcBot:TimeSinceDamagedByCreep() >= 5.0
            then
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, false)
                        and enemy:GetMana() > 0 and enemy:GetMana() / enemy:GetMaxMana() >= 0.4
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
            if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
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
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
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
                and utility.SafeCast(botTarget, true) and botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.5
            then
                --npcBot:ActionImmediate_Chat("Использую LagunaBlade для атаки!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end
