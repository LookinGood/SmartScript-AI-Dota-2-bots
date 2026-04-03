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
    Abilities[3],
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local EtherShock = npcBot:GetAbilityByName("shadow_shaman_ether_shock");
local Hex = npcBot:GetAbilityByName("shadow_shaman_voodoo");
local Shackles = npcBot:GetAbilityByName("shadow_shaman_shackles");
local Urnaconda = npcBot:GetAbilityByName("shadow_shaman_urnaconda");
local MassSerpentWard = npcBot:GetAbilityByName("shadow_shaman_mass_serpent_ward");

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castEtherShockDesire, castEtherShockTarget = ConsiderEtherShock();
    local castHexDesire, castHexTarget = ConsiderHex();
    local castShacklesDesire, castShacklesTarget = ConsiderShackles();
    local castUrnacondaDesire, castUrnacondaLocation = ConsiderUrnaconda();
    local castMassSerpentWardDesire, castMassSerpentWardLocation = ConsiderMassSerpentWard();

    if (castEtherShockDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(EtherShock, castEtherShockTarget);
        return;
    end

    if (castHexDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Hex, castHexTarget);
        return;
    end

    if (castShacklesDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Shackles, castShacklesTarget);
        return;
    end

    if (castUrnacondaDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Urnaconda, castUrnacondaLocation);
        return;
    end

    if (castMassSerpentWardDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(MassSerpentWard, castMassSerpentWardLocation);
        return;
    end
end

function ConsiderEtherShock()
    local ability = EtherShock;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("end_distance");
    local damageAbility = ability:GetSpecialValueInt("damage");
    --local maxTargets = ability:GetSpecialValueInt("targets");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget;
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if #enemyCreeps >= 3 and (ManaPercentage >= 0.5)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую EtherShock по крипам!", true);
                    return BOT_MODE_DESIRE_VERYLOW, enemy;
                end
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую EtherShock по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderHex()
    local ability = Hex;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую Hex что бы сбить заклинание!",true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
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
                        if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Hex по второй цели!", true);
                            return BOT_MODE_DESIRE_HIGH, enemy;
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
                    --npcBot:ActionImmediate_Chat("Использую Hex для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderShackles()
    local ability = Shackles;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("total_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Shackles что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget)
            then
                --npcBot:ActionImmediate_Chat("Использую Shackles по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility == 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Shackles что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderUrnaconda()
    local ability = Urnaconda;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("impact_radius");
    local damageAbility = ability:GetSpecialValueInt("impact_damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Urnaconda в радиусе каста добивая!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Urnaconda в касте+радиусе добивая!!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end

    if not MassSerpentWard:IsTrained()
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + radiusAbility)
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Urnaconda в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Urnaconda в касте+радиусе!!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderMassSerpentWard()
    local ability = MassSerpentWard;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую MassSerpentWard что бы оторваться от врага!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
