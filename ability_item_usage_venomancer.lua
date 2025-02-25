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
    Talents[1],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[2],
    Talents[3],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local VenomousGale = AbilitiesReal[1]
local PlagueWard = AbilitiesReal[3]
local LatentToxicity = AbilitiesReal[4]
local NoxiousPlague = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castVenomousGaleDesire, castVenomousGaleLocation = ConsiderVenomousGale();
    local castPlagueWardDesire, castPlagueWardLocation = ConsiderPlagueWard();
    local castLatentToxicityDesire, castLatentToxicitytarget = ConsiderLatentToxicity();
    local castNoxiousPlagueDesire, castNoxiousPlagueTarget = ConsiderNoxiousPlague();

    if (castVenomousGaleDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(VenomousGale, castVenomousGaleLocation);
        return;
    end

    if (castPlagueWardDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(PlagueWard, castPlagueWardLocation);
        return;
    end

    if (castLatentToxicityDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(LatentToxicity, castLatentToxicitytarget);
        return;
    end

    if (castNoxiousPlagueDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(NoxiousPlague, castNoxiousPlagueTarget);
        return;
    end
end

function ConsiderVenomousGale()
    local ability = VenomousGale;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("start_radius");
    local damageAbility = ability:GetSpecialValueInt("strike_damage") +
        (ability:GetSpecialValueInt("tick_damage") * ability:GetSpecialValueInt("duration"));
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE,
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH,
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
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую VenomousGale для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую VenomousGale по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую VenomousGale по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderPlagueWard()
    local ability = PlagueWard;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local minionAttackRange = 600;
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_MODERATE, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) > castRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + minionAttackRange
                then
                    return BOT_ACTION_DESIRE_MODERATE,
                        utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_MODERATE, enemy:GetLocation();
                end
            end
        end
    end

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot) and (ManaPercentage >= 0.5)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
        local frendlyTower = npcBot:GetNearbyTowers(castRangeAbility, false);
        local enemyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, true);
        local frendlyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, false);
        local ancient = GetAncient(GetTeam());
        local enemyAncient = GetAncient(GetOpposingTeam());
        local attackTarget = npcBot:GetAttackTarget();

        if (utility.CountEnemyCreepAroundUnit(ancient, minionAttackRange) > 0 or utility.CountEnemyHeroAroundUnit(ancient, minionAttackRange) > 0)
            and GetUnitToUnitDistance(npcBot, ancient) <= castRangeAbility
        then
            return BOT_MODE_DESIRE_MODERATE, ancient:GetLocation();
        end
        if (attackTarget ~= nil and attackTarget == enemyAncient)
        then
            return BOT_MODE_DESIRE_MODERATE, attackTarget:GetLocation() + RandomVector(minionAttackRange);
        end
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                end
            end
        end
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                end
            end
        end
        if (#frendlyTower > 0)
        then
            for _, ally in pairs(frendlyTower) do
                if utility.CanCastSpellOnTarget(ability, ally) and not ally:IsInvulnerable()
                then
                    return BOT_MODE_DESIRE_LOW, ally:GetLocation();
                end
            end
        end
        if (#enemyBarracks > 0)
        then
            for _, enemy in pairs(enemyBarracks) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(minionAttackRange);
                end
            end
        end
        if (#frendlyBarracks > 0)
        then
            for _, ally in pairs(frendlyBarracks) do
                if utility.CanCastSpellOnTarget(ability, ally) and not ally:IsInvulnerable()
                then
                    return BOT_MODE_DESIRE_LOW, ally:GetLocation();
                end
            end
        end
    end
end

function ConsiderLatentToxicity()
    local ability = LatentToxicity;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("duration_damage") * ability:GetSpecialValueInt("duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую LatentToxicity что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
                and not botTarget:HasModifier("modifier_venomancer_latent_poison")
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
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
                    and not enemy:HasModifier("modifier_venomancer_latent_poison")
                then
                    --npcBot:ActionImmediate_Chat("Использую LatentToxicity что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderNoxiousPlague()
    local ability = NoxiousPlague;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = (ability:GetSpecialValueInt("impact_damage") + (enemy:GetMaxHealth() / 100 *
                ability:GetSpecialValueInt("health_damage")) * ability:GetSpecialValueInt("debuff_duration"));
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую NoxiousPlague что бы добить " .. enemy:GetUnitName(), true);
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
                and not botTarget:HasModifier("modifier_venomancer_noxious_plague_primary")
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_venomancer_noxious_plague_primary")
                then
                    --npcBot:ActionImmediate_Chat("Использую LatentToxicity что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

---- DELETED ABILITY
--#region Poision Nova
--[[ PoisonNova = AbilitiesReal[6]

castPoisonNovaDesire = ConsiderPoisonNova();

    if (castPoisonNovaDesire ~= nil)
    then
        npcBot:Action_UseAbility(PoisonNova);
        return
    end

function CanCastPoisonNovaOnTarget(npcTarget)
    return npcTarget:CanBeSeen() and not npcTarget:IsMagicImmune() and not npcTarget:IsInvulnerable();
end

function ConsiderPoisonNova()
    local npcBot = GetBot();

    if not PoisonNova:IsFullyCastable() then
        return
    end

    local castRadiusPoisonNova = (PoisonNova:GetSpecialValueInt("radius") - 100);
    local enemyPoisonNova = npcBot:GetNearbyHeroes(castRadiusPoisonNova, true, BOT_MODE_NONE);

    -- General use
    for _, ePoisonNova in pairs(enemyPoisonNova) do
        if (CanCastPoisonNovaOnTarget(ePoisonNova)) and not ePoisonNova:IsIllusion() and #enemyPoisonNova > 1 then
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end
end ]]
--#endregion
