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
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local FrostBlast = AbilitiesReal[1]
local FrostShield = AbilitiesReal[2]
local SinisterGaze = AbilitiesReal[3]
local IceSpire = AbilitiesReal[4]
local ChainFrost = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFrostBlastDesire, castFrostBlastTarget = ConsiderFrostBlast();
    local castFrostShieldDesire, castFrostShieldTarget = ConsiderFrostShield();
    local castSinisterGazeDesire, castSinisterGazeTarget, castSinisterGazeTargetType = ConsiderSinisterGaze();
    local castIceSpireDesire, castIceSpireLocation = ConsiderIceSpire();
    local castChainFrostDesire, castChainFrostTarget = ConsiderChainFrost();

    if (castFrostBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FrostBlast, castFrostBlastTarget);
        return;
    end

    if (castFrostShieldDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FrostShield, castFrostShieldTarget);
        return;
    end

    if (castSinisterGazeDesire ~= nil)
    then
        if (castSinisterGazeTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(SinisterGaze, castSinisterGazeTarget);
            return;
        elseif (castSinisterGazeTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(SinisterGaze, castSinisterGazeTarget);
            return;
        end
    end

    if (castIceSpireDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IceSpire, castIceSpireLocation);
        return;
    end

    if (castChainFrostDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ChainFrost, castChainFrostTarget);
        return;
    end
end

function ConsiderFrostBlast()
    local ability = FrostBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetAbilityDamage() + ability:GetSpecialValueInt("aoe_damage")
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FrostBlast что бы убить цель!",true);
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
                    --npcBot:ActionImmediate_Chat("Использую FrostBlast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyCreeps) do
                local enemyCreepsAoe = enemy:GetNearbyCreeps(radiusAbility, false);
                if (#enemyCreepsAoe > 2)
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую FrostBlast на крипов!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                    end
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую FrostBlast по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderFrostShield()
    local ability = FrostShield;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally) and not ally:HasModifier("modifier_lich_frost_shield")
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= radiusAbility
                        then
                            --npcBot:ActionImmediate_Chat("Использую FrostShield на союзника рядом с врагом!",true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end

        -- Safe ally hero
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_lich_frost_shield")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
                    ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0) or ally:WasRecentlyDamagedByCreep(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую FrostShield на союзника для защиты!",true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end

    -- Cast to buff ally buildings
    local allyTowers = npcBot:GetNearbyTowers(castRangeAbility, false);
    local allyBarracks = npcBot:GetNearbyBarracks(castRangeAbility, false);
    local allyAncient = GetAncient(GetTeam());
    if (#allyTowers > 0)
    then
        for _, ally in pairs(allyTowers)
        do
            if not ally:HasModifier("modifier_lich_frost_shield") and utility.IsTargetedByEnemy(ally, true)
            then
                --npcBot:ActionImmediate_Chat("Использую FrostShield на союзную башню!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end
    if (#allyBarracks > 0)
    then
        for _, ally in pairs(allyBarracks)
        do
            if not ally:HasModifier("modifier_lich_frost_shield") and utility.IsTargetedByEnemy(ally, true)
            then
                --npcBot:ActionImmediate_Chat("Использую FrostShield на союзные казармы!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end
    if GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility
    then
        if not allyAncient:HasModifier("modifier_lich_frost_shield") and utility.IsTargetedByEnemy(allyAncient, true)
        then
            --npcBot:ActionImmediate_Chat("Использую FrostShield на ДРЕВНЕГО!", true);
            return BOT_MODE_DESIRE_HIGH, allyAncient;
        end
    end
end

function ConsiderSinisterGaze()
    local ability = SinisterGaze;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("aoe_scepter");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую SinisterGaze сбивая каст без аганима!", true);
                        return BOT_MODE_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую SinisterGaze сбивая каст с аганимом!",true);
                        return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
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
                and not utility.IsDisabled(botTarget)
            then
                if not npcBot:HasScepter()
                then
                    --npcBot:ActionImmediate_Chat("Использую SinisterGaze по врагу без аганима!", true);
                    return BOT_MODE_DESIRE_HIGH, botTarget, "target";
                elseif npcBot:HasScepter()
                then
                    --npcBot:ActionImmediate_Chat("Использую SinisterGaze по врагу с аганимом!", true);
                    return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility), "location";
                end
            end
        end
        if npcBot:HasScepter()
        then
            -- Cast if enemy >=2
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
                    radiusAbility,
                    0,
                    0);
                if (locationAoE.count >= 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую SinisterGaze по врагам!", true);
                    return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility == 1)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую SinisterGaze для отхода без аганима!", true);
                        return BOT_MODE_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую SinisterGaze для отхода с аганимом!",true);
                        return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
                    end
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy) and (ManaPercentage >= 0.7)
        then
            if not npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую SinisterGaze на лайне без аганима!",true);
                return BOT_MODE_DESIRE_HIGH, enemy, "target";
            elseif npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую SinisterGaze на лайне с аганимом!", true);
                return BOT_MODE_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
            end
        end
    end
end

function ConsiderIceSpire()
    local ability = IceSpire;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую IceSpire что бы оторваться от врага!",true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
    end
end

function ConsiderChainFrost()
    local ability = ChainFrost;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("jump_range");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChainFrost что бы убить цель!", true);
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
            then
                local enemyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                local iceSpires = utility.CountUnitAroundTarget(botTarget, "npc_dota_lich_ice_spire", false,
                    radiusAbility);
                if #enemyHeroAround > 1 or iceSpires > 0 or (botTarget:GetHealth() / botTarget:GetMaxHealth() <= 0.4
                        and botTarget:GetHealth() / botTarget:GetMaxHealth() > 0.1)
                then
                    --npcBot:ActionImmediate_Chat("Использую ChainFrost для атаки!", true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget;
                end
            end
        end
        -- Use if need retreat
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    local enemyHeroAround = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                    local iceSpires = utility.CountUnitAroundTarget(enemy, "npc_dota_lich_ice_spire", false,
                        radiusAbility);
                    if #enemyHeroAround > 1 or iceSpires > 0
                    then
                        --npcBot:ActionImmediate_Chat("Использую ChainFrost для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end
end
