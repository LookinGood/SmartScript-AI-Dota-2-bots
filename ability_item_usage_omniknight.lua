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
local Purification = AbilitiesReal[1]
local Repel = AbilitiesReal[2]
local HammerOfPurity = AbilitiesReal[3]
local GuardianAngel = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castPurificationDesire, castPurificationTarget = ConsiderPurification();
    local castRepelDesire, castRepelTarget = ConsiderRepel();
    local castHammerOfPurityDesire, castHammerOfPurityTarget = ConsiderHammerOfPurity();
    local castGuardianAngelDesire, castGuardianAngelTarget = ConsiderGuardianAngel();

    if (castPurificationDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Purification, castPurificationTarget);
        return;
    end

    if (castRepelDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Repel, castRepelTarget);
        return;
    end

    if (castHammerOfPurityDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(HammerOfPurity, castHammerOfPurityTarget);
        return;
    end

    if (castGuardianAngelDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(GuardianAngel, castGuardianAngelTarget);
        return;
    end
end

function ConsiderPurification()
    local ability = Purification;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("heal");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
            then
                local allyHeroAround = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                local allyCreepsAround = enemy:GetNearbyCreeps(radiusAbility, true);
                if (#allyHeroAround > 1)
                then
                    for _, ally in pairs(allyHeroAround) do
                        if utility.IsValidTarget(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        then
                            npcBot:ActionImmediate_Chat("Использую Purification на героя что бы добить врага!",
                                true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
                if (#allyCreepsAround > 0)
                then
                    for _, ally in pairs(allyCreepsAround) do
                        if utility.IsValidTarget(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        then
                            npcBot:ActionImmediate_Chat("Использую Purification на крипа что бы добить врага!",
                                true);
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                end
            end
        end
    end

    -- Use to heal damaged ally
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and utility.CanBeHeal(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("Использую Purification для лечения!", true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            local allyHeroAround = botTarget:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            local allyCreepsAround = botTarget:GetNearbyCreeps(radiusAbility, true);
            if (#allyHeroAround > 1)
            then
                for _, ally in pairs(allyHeroAround) do
                    if utility.IsValidTarget(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Purification на союзного героя рядом с целью!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreepsAround > 0)
            then
                for _, ally in pairs(allyCreepsAround) do
                    if utility.IsValidTarget(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Purification на союзного крипа рядом с целью!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую Purification против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH, npcBot;
                end
            end
        end
    end
end

function ConsiderRepel()
    local ability = Repel;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and not ally:HasModifier("modifier_omniknight_martyr")
            then
                if (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                    and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                then
                    --npcBot:ActionImmediate_Chat("Использую Repel на союзника которого атакуют!",true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
                if utility.IsHero(ally:GetAttackTarget()) or utility.IsDisabled(ally)
                then
                    --npcBot:ActionImmediate_Chat("Использую Repel на союзника диспеля или для атаки!",true);
                    return BOT_MODE_DESIRE_HIGH, ally;
                end
            end
        end
    end
end

function ConsiderHammerOfPurity()
    local ability = HammerOfPurity;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (npcBot:GetBaseDamage() / 100 * ability:GetSpecialValueInt("base_damage")) +
        ability:GetSpecialValueInt("bonus_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую HammerOfPurity что бы убить цель!",
                        true);
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
                return BOT_ACTION_DESIRE_VERYHIGH, botTarget;
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
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderGuardianAngel()
    local ability = GuardianAngel;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not npcBot:HasScepter()
    then
        local castRangeAbility = ability:GetCastRange();
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and (ally:GetHealth() / ally:GetMaxHealth() <= 0.6) and ally:WasRecentlyDamagedByAnyHero(2.0)
                    and not ally:HasModifier("modifier_omninight_guardian_angel")
                then
                    --npcBot:ActionImmediate_Chat("Использую GuardianAngel без аганима!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            end
        end
    elseif npcBot:HasScepter()
    then
        local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);
        if (#allyAbility > 0)
        then
            for i = 1, #allyAbility do
                do
                    if utility.IsHero(allyAbility[i]) and (allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.6) and allyAbility[i]:WasRecentlyDamagedByAnyHero(2.0)
                        and not allyAbility[i]:HasModifier("modifier_omninight_guardian_angel")
                    then
                        if (#allyAbility > 1)
                        then
                            if allyAbility[i] ~= npcBot
                            then
                                --npcBot:ActionImmediate_Chat("Использую GuardianAngel с аганимом на союзного героя!", true);
                                return BOT_ACTION_DESIRE_HIGH, allyAbility[i];
                            elseif allyAbility[i] == npcBot
                            then
                                npcBot:ActionImmediate_Chat("Использую GuardianAngel с аганимом на союзника но ранен я!",
                                    true);
                                return BOT_ACTION_DESIRE_HIGH, allyAbility[2];
                            end
                        elseif (#allyAbility == 1)
                        then
                            npcBot:ActionImmediate_Chat("Использую GuardianAngel с аганимом на себя когда я один!", true);
                            return BOT_ACTION_DESIRE_HIGH, npcBot;
                        end
                    end
                end
            end
        end
    end
end

-- СТАРЫЕ ВЕРСИИ СПОСОБНОСТЕЙ
--[[
    local castGuardianAngelDesire = ConsiderGuardianAngel();
        if (castGuardianAngelDesire ~= nil)
    then
        npcBot:Action_UseAbility(GuardianAngel);
        return;
    end
function ConsiderGuardianAngel()
    local ability = GuardianAngel;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not npcBot:HasScepter()
    then
        local radiusAbility = ability:GetSpecialValueInt("radius");
        local allyAbility = npcBot:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#allyAbility >= 2) and (#enemyAbility >= 2)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and not ally:HasModifier("modifier_omninight_guardian_angel")
                then
                    if (ally:GetHealth() / ally:GetMaxHealth() <= 0.8) and ally:WasRecentlyDamagedByAnyHero(2.0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую GuardianAngel без аганима!", true);
                        return BOT_MODE_DESIRE_HIGH;
                    end
                end
            end
        end
    elseif npcBot:HasScepter()
    then
        local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);
        if (#allyAbility > 0)
        then
            for i = 1, #allyAbility do
                local allyAbility = allyAbility[i]:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
                local enemyAbility = allyAbility[i]:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
                if utility.IsHero(allyAbility[i]) and not allyAbility[i]:HasModifier("modifier_omninight_guardian_angel")
                    and allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.6 and allyAbility[i]:WasRecentlyDamagedByAnyHero(2.0)
                    and (#allyAbility >= 2) and (#enemyAbility >= 2)
                then
                    --npcBot:ActionImmediate_Chat("Использую GuardianAngel с аганимом!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Use to protect ancient
        local allyAncient = GetAncient(GetTeam());
        if allyAncient:GetHealth() / allyAncient:GetMaxHealth() <= 0.6 and utility.IsTargetedByEnemy(allyAncient, true)
            and not allyAncient:HasModifier("modifier_omninight_guardian_angel")
        then
            npcBot:ActionImmediate_Chat("Использую GuardianAngel на ДРЕВНЕГО!", true);
            return BOT_MODE_DESIRE_HIGH;
        end
    end
end ]]
