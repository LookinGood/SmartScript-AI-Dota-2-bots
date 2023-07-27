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
    Abilities[1],
    Abilities[2],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[3],
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
    Talents[7],
}


function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    VenomousGale = AbilitiesReal[1]
    PlagueWard = AbilitiesReal[3]
    LatentToxicity = AbilitiesReal[4]
    NoxiousPlague = AbilitiesReal[6]

    castVenomousGaleDesire, castVenomousGaleLocation = ConsiderVenomousGale();
    castPlagueWardDesire, castPlagueWardLocation = ConsiderPlagueWard();
    castLatentToxicityDesire, castLatentToxicitytarget = ConsiderLatentToxicity();
    castNoxiousPlagueDesire, castNoxiousPlagueTarget = ConsiderNoxiousPlague();

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
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
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
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую VenomousGale для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую VenomousGale по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую VenomousGale по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderPlagueWard()
    local ability = PlagueWard;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- General use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget)
        then
            return BOT_MODE_DESIRE_MODERATE, botTarget:GetLocation();
        end
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
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
        --  Pushing/defending/Farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
        local frendlyTower = npcBot:GetNearbyTowers(castRangeAbility, false);
        local enemyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, true);
        local frendlyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, false);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_VERYLOW, enemy:GetLocation() + RandomVector(100);
                end
            end
        end
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(100);
                end
            end
            if (#frendlyTower > 0)
            then
                for _, ally in pairs(frendlyTower) do
                    if utility.CanCastSpellOnTarget(ability, ally)
                    then
                        return BOT_MODE_DESIRE_LOW, ally:GetLocation() + RandomVector(100);
                    end
                end
            end
            if (#enemyBarracks > 0)
            then
                for _, enemy in pairs(enemyBarracks) do
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_MODE_DESIRE_LOW, enemy:GetLocation() + RandomVector(100);
                    end
                end
            end
            if (#frendlyBarracks > 0)
            then
                for _, ally in pairs(frendlyBarracks) do
                    if utility.CanCastSpellOnTarget(ability, ally)
                    then
                        return BOT_MODE_DESIRE_LOW, ally:GetLocation() + RandomVector(100);
                    end
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

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)  and utility.SafeCast(enemy, true)
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

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and utility.SafeCast(enemy, true)
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
