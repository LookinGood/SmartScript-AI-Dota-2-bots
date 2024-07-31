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
    Abilities[7],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[7],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[7],
    Talents[5],
    Talents[7],
    Talents[1],
    Talents[3],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Fireblast = AbilitiesReal[1]
local Ignite = AbilitiesReal[2]
local Bloodlust = AbilitiesReal[3]
local UnrefinedFireblast = AbilitiesReal[4]
local FireShield = AbilitiesReal[5]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    --[[     print(npcBot:GetAbilityInSlot(0):GetName())
    print(npcBot:GetAbilityInSlot(1):GetName())
    print(npcBot:GetAbilityInSlot(2):GetName())
    print(npcBot:GetAbilityInSlot(3):GetName())
    print(npcBot:GetAbilityInSlot(4):GetName())
    print(npcBot:GetAbilityInSlot(5):GetName())
    print(npcBot:GetAbilityInSlot(6):GetName())
    print(npcBot:GetAbilityInSlot(7):GetName()) ]]

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castFireblastDesire, castFireblastTarget = ConsiderFireblast();
    local castIgniteDesire, castIgniteTarget = ConsiderIgnite();
    local castBloodlustDesire, castBloodlustTarget = ConsiderBloodlust();
    local castUnrefinedFireblastDesire, castUnrefinedFireblastTarget = ConsiderUnrefinedFireblast();
    local castFireShieldDesire, castFireShieldTarget = ConsiderFireShield();

    if (castFireblastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Fireblast, castFireblastTarget);
        return;
    end

    if (castIgniteDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Ignite, castIgniteTarget);
        return;
    end

    if (castBloodlustDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Bloodlust, castBloodlustTarget);
        return;
    end

    if (castUnrefinedFireblastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(UnrefinedFireblast, castUnrefinedFireblastTarget);
        return;
    end

    if (castFireShieldDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FireShield, castFireShieldTarget);
        return;
    end
end

function ConsiderFireblast()
    local ability = Fireblast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("fireblast_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Fireblast что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
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
                    --npcBot:ActionImmediate_Chat("Использую Fireblast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderIgnite()
    local ability = Ignite;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("burn_damage") * ability:GetSpecialValueInt("duration");
    --local radiusAbility = ability:GetSpecialValueInt("ignite_multicast_aoe");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ignite что бы убить цель!", true);
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
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ignite что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 3) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Ignite на крипов!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Ignite на лайне!", true);
            return BOT_ACTION_DESIRE_HIGH, enemy;
        end
    end
end

function ConsiderBloodlust()
    local ability = Bloodlust;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if npcBot:HasModifier('modifier_fountain_aura_buff')
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast();
        end
    else
        if ability:GetAutoCastState()
        then
            ability:ToggleAutoCast();
        end
    end

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_ogre_magi_bloodlust")
            then
                if utility.PvPMode(npcBot)
                then
                    if utility.IsHero(botTarget)
                    then
                        if GetUnitToUnitDistance(ally, botTarget) <= ally:GetAttackRange() * 2
                            or GetUnitToUnitDistance(ally, botTarget) > (ally:GetAttackRange() * 2)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Bloodlust на союзника!", true);
                            return BOT_MODE_DESIRE_HIGH, ally;
                        end
                    end
                end

                if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
                        ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую Bloodlust на союзника как баф!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end

                if botMode ~= BOT_MODE_LANING
                then
                    if ally:GetAttackTarget() ~= nil
                    then
                        --npcBot:ActionImmediate_Chat("Использую Bloodlust на атакующего!", true);
                        return BOT_MODE_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end

    -- Cast to buff ally towers
    if not utility.RetreatMode(npcBot)
    then
        local allyTowers = npcBot:GetNearbyTowers(castRangeAbility, false);
        if (#allyTowers > 0)
        then
            for _, ally in pairs(allyTowers)
            do
                if not ally:HasModifier("modifier_ogre_magi_bloodlust") and ally:GetAttackTarget() ~= nil
                then
                    --npcBot:ActionImmediate_Chat("Использую Bloodlust на союзную башню!", true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderUnrefinedFireblast()
    local ability = UnrefinedFireblast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("base_damage") +
        (npcBot:GetAttributeValue(ATTRIBUTE_STRENGTH) / 100 *
            ability:GetSpecialValueInt("str_multiplier"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую UnrefinedFireblast что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy;
                end
            end
        end
    end

    if Fireblast:IsCooldownReady()
    then
        return;
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
                    --npcBot:ActionImmediate_Chat("Использую UnrefinedFireblast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderFireShield()
    local ability = FireShield;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_ogre_magi_smash_buff")
            then
                if ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and
                    ally:WasRecentlyDamagedByAnyHero(2.0) or ally:WasRecentlyDamagedByTower(2.0) or ally:WasRecentlyDamagedByCreep(5.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую FireShield на союзника как баф!", true);
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
            if not ally:HasModifier("modifier_ogre_magi_smash_buff") and utility.IsTargetedByEnemy(ally, true)
            then
                --npcBot:ActionImmediate_Chat("Использую FireShield на союзную башню!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end
    if (#allyBarracks > 0)
    then
        for _, ally in pairs(allyBarracks)
        do
            if not ally:HasModifier("modifier_ogre_magi_smash_buff") and utility.IsTargetedByEnemy(ally, true)
            then
                --npcBot:ActionImmediate_Chat("Использую FireShield на союзные казармы!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end
    if GetUnitToUnitDistance(npcBot, allyAncient) <= castRangeAbility
    then
        if not allyAncient:HasModifier("modifier_ogre_magi_smash_buff") and utility.IsTargetedByEnemy(allyAncient, true)
        then
            --npcBot:ActionImmediate_Chat("Использую FireShield на ДРЕВНЕГО!", true);
            return BOT_MODE_DESIRE_HIGH, allyAncient;
        end
    end
end
