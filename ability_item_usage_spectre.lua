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
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local SpectralDagger = AbilitiesReal[1]
local Dispersion = AbilitiesReal[3]
local Reality = AbilitiesReal[4]
local Haunt = AbilitiesReal[5]
local ShadowStep = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castSpectralDaggerDesire, castSpectralDaggerTarget, castSpectralDaggerTargetType = ConsiderSpectralDagger();
    local castDispersionDesire = ConsiderDispersion();
    local castRealityDesire, castRealityLocation = ConsiderReality();
    local castShadowStepDesire, castShadowStepTarget = ConsiderShadowStep();
    local castHauntDesire = ConsiderHaunt();

    if (castSpectralDaggerDesire ~= nil)
    then
        if (castSpectralDaggerTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(SpectralDagger, castSpectralDaggerTarget);
            return;
        elseif (castSpectralDaggerTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(SpectralDagger, castSpectralDaggerTarget);
            return;
        end
    end

    if (castDispersionDesire ~= nil)
    then
        npcBot:Action_UseAbility(Dispersion);
        return;
    end

    if (castRealityDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Reality, castRealityLocation);
        return;
    end

    if (castShadowStepDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ShadowStep, castShadowStepTarget);
        return;
    end

    if (castHauntDesire ~= nil)
    then
        npcBot:Action_UseAbility(Haunt);
        return;
    end
end

function ConsiderSpectralDagger()
    local ability = SpectralDagger;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую SpectralDagger что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
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
                --npcBot:ActionImmediate_Chat("Использую SpectralDagger по врагу в радиусе действия!",true);
                return BOT_MODE_DESIRE_HIGH, botTarget, "target";
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую SpectralDagger для отхода, по врагу!", true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                    else
                        --npcBot:ActionImmediate_Chat("Использую SpectralDagger для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility), "location";
                    end
                end
            elseif (#enemyAbility <= 0) and npcBot:DistanceFromFountain() > castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую SpectralDagger для отхода!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility), "location";
            end
        end
    end
end

function ConsiderDispersion()
    local ability = Dispersion;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("max_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- General use
    if (#enemyAbility > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        for _, enemy in pairs(enemyAbility)
        do
            if utility.CanCastOnInvulnerableTarget(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую Dispersion против врага в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderReality()
    local ability = Reality;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
        then
            for i = 1, #allyAbility do
                if allyAbility[i]:IsIllusion() and GetUnitToUnitDistance(allyAbility[i], botTarget) <= 1600
                then
                    return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i]:GetLocation();

                    --[[             if (npcBot.idletime == nil)
                    then
                        npcBot.idletime = GameTime()
                    else
                        if (GameTime() - npcBot.idletime >= 2)
                        then
                            npcBot.idletime = nil
                            --npcBot:ActionImmediate_Chat("Использую Reality на свою иллюзию!", true);
                            return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i]:GetLocation();
                        end
                    end ]]
                end
            end
        end
    end
    --allyAbility[i]:HasModifier("modifier_spectre_haunt")
end

function ConsiderShadowStep()
    local ability = ShadowStep;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --local damageAbility = SpectralDagger:GetSpecialValueInt("damage");
    --local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
--[[     for i = 1, #enemyAbility do
        if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, SpectralDagger:GetDamageType())
            and utility.CanCastSpellOnTarget(SpectralDagger, enemyAbility[i])
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowStep что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE, enemyAbility[i];
        end
    end ]]

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую ShadowStep по врагу в радиусе действия!",true);
            return BOT_MODE_DESIRE_HIGH, botTarget;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local closeEnemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#closeEnemyAbility > 0)
        then
            for _, enemy in pairs(closeEnemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowStep что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderHaunt()
    local ability = Haunt;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую Haunt для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
