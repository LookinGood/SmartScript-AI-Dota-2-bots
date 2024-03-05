---@diagnostic disable: undefined-global, need-check-nil
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
    Abilities[2],
    Abilities[1],
    Abilities[3],
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
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Illuminate = AbilitiesReal[1]
local ReleaseIlluminate = npcBot:GetAbilityByName("keeper_of_the_light_illuminate_end");
local IlluminateSpiritForm = npcBot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate");
--local ReleaseIlluminateSpiritForm = npcBot:GetAbilityByName("keeper_of_the_light_spirit_form_illuminate_end");
local BlindingLight = AbilitiesReal[2]
local ChakraMagic = AbilitiesReal[3]
local SolarBind = AbilitiesReal[4]
local WillOWisp = AbilitiesReal[5]
local Recall = npcBot:GetAbilityByName("keeper_of_the_light_recall");
local SpiritForm = AbilitiesReal[6]

-- Selecting active ability
--[[ if utility.IsAbilityAvailable(Illuminate) and not utility.IsAbilityAvailable(IlluminateSpiritForm)
then
    Illuminate = AbilitiesReal[1];
else
    Illuminate = IlluminateSpiritForm;
end

if utility.IsAbilityAvailable(ReleaseIlluminate) and not utility.IsAbilityAvailable(ReleaseIlluminateSpiritForm)
then
    ReleaseIlluminate = npcBot:GetAbilityByName("keeper_of_the_light_illuminate_end");
else
    ReleaseIlluminate = ReleaseIlluminateSpiritForm;
end ]]
--

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castIlluminateDesire, castIlluminateLocation = ConsiderIlluminate();
    local castReleaseIlluminateDesire = ConsiderReleaseIlluminate();
    local castIlluminateSpiritFormDesire, castIlluminateSpiritFormLocation = ConsiderIlluminateSpiritForm();
    --local castReleaseIlluminateSpiritFormDesire = ConsiderReleaseIlluminateSpiritForm();
    local castBlindingLightDesire, castBlindingLightLocation = ConsiderBlindingLight();
    local castChakraMagicDesire, castChakraMagicTarget = ConsiderChakraMagic();
    local castSolarBindDesire, castSolarBindTarget = ConsiderSolarBind();
    local castWillOWispDesire, castWillOWispLocation = ConsiderWillOWisp();
    local castRecallDesire, castRecallLocation = ConsiderRecall();
    local castSpiritFormDesire = ConsiderSpiritForm();

    if (castIlluminateDesire ~= nil)
    then
        npcBot:Action_ClearActions(true);
        npcBot:ActionQueue_UseAbilityOnLocation(Illuminate, castIlluminateLocation);
        return;
    end

    if (castReleaseIlluminateDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReleaseIlluminate);
        return;
    end

    if (castIlluminateSpiritFormDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(IlluminateSpiritForm, castIlluminateSpiritFormLocation);
        return;
    end

--[[     if (castReleaseIlluminateSpiritFormDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReleaseIlluminateSpiritForm);
        return;
    end ]]

    if (castBlindingLightDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BlindingLight, castBlindingLightLocation);
        return;
    end

    if (castChakraMagicDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ChakraMagic, castChakraMagicTarget);
        return;
    end

    if (castSolarBindDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SolarBind, castSolarBindTarget);
        return;
    end

    if (castWillOWispDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(WillOWisp, castWillOWispLocation);
        return;
    end

    if (castRecallDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Recall, castRecallLocation);
        npcBot:ActionImmediate_Ping(castRecallLocation.x, castRecallLocation.y, true);
        return;
    end

    if (castSpiritFormDesire ~= nil)
    then
        npcBot:Action_UseAbility(SpiritForm);
        return;
    end
end

function ConsiderIlluminate()
    local ability = Illuminate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("total_damage")
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0) and npcBot:TimeSinceDamagedByAnyHero() >= 5.0
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Illuminate что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
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

function ConsiderReleaseIlluminate()
    local ability = ReleaseIlluminate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local allyAbility = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);

    if (#allyAbility <= 1) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        --npcBot:ActionImmediate_Chat("Использую ReleaseIlluminate!", true);
        return BOT_ACTION_DESIRE_MODERATE;
    end
end

function ConsiderIlluminateSpiritForm()
    local ability = IlluminateSpiritForm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("total_damage")
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую IlluminateSpiritForm что бы убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
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
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if locationAoE ~= nil and (locationAoE.count >= 3) and (ManaPercentage >= 0.6)
        then
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
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

function ConsiderBlindingLight()
    local ability = BlindingLight;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + radiusAbility, true, BOT_MODE_NONE);

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
                        --npcBot:ActionImmediate_Chat("Использую BlindingLight в радиусе каста добивая!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlindingLight в касте+радиусе добивая!!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + radiusAbility)
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую BlindingLight в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую BlindingLight в касте+радиусе!!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
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
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlindingLight в радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую BlindingLight в касте+радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
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
    end
end

function ConsiderChakraMagic()
    local ability = ChakraMagic;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local manaRestore = ability:GetSpecialValueInt("mana_restore");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast to buff allies
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and (ally:GetMana() <= ally:GetMaxMana() - manaRestore)
            then
                --npcBot:ActionImmediate_Chat("Использую ChakraMagic!", true);
                return BOT_MODE_DESIRE_HIGH, ally;
            end
        end
    end
end

function ConsiderSolarBind()
    local ability = SolarBind;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

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
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderWillOWisp()
    local ability = WillOWisp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую WillOWisp в радиусе каста добивая!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую WillOWisp в касте+радиусе добивая!!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                and not utility.IsDisabled(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую WillOWisp в радиусе каста!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
                elseif GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую WillOWisp в касте+радиусе!!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, botTarget, castRangeAbility);
                end
            end
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
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
                        --npcBot:ActionImmediate_Chat("Использую WillOWisp в радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    elseif GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility + radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую WillOWisp в касте+радиусе для отхода!", true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetMaxRangeCastLocation(npcBot, enemy, castRangeAbility);
                    end
                end
            end
        end
    end
end

function ConsiderRecall()
    local ability = Recall;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    if (#allyAbility > 1)
    then
        for i = 1, #allyAbility do
            do
                if allyAbility[i] ~= npcBot and utility.IsHero(allyAbility[i]) and (allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.6)
                    and allyAbility[i]:TimeSinceDamagedByAnyHero() >= 4.0 and not allyAbility[i]:IsChanneling()
                then
                    if npcBot:DistanceFromFountain() < allyAbility[i]:DistanceFromFountain() and GetUnitToUnitDistance(npcBot, allyAbility[i]) >= 3000
                    then
                        npcBot:ActionImmediate_Chat("Использую Recall на раненного союзника!", true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, allyAbility[i], delayAbility, 0);
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
            if (#allyAbility > 1) and GetUnitToUnitDistance(npcBot, botTarget) <= 2000
            then
                for i = 1, #allyAbility do
                    do
                        if allyAbility[i] ~= npcBot and utility.IsHero(allyAbility[i]) and (allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() > 0.6)
                            and allyAbility[i]:TimeSinceDamagedByAnyHero() >= 4.0 and not allyAbility[i]:IsChanneling()
                        then
                            if allyAbility[i]:DistanceFromFountain() < 3000 and GetUnitToUnitDistance(npcBot, allyAbility[i]) >= 3000
                            then
                                npcBot:ActionImmediate_Chat("Использую Recall что бы вызвать союзника в бой!", true);
                                return BOT_ACTION_DESIRE_HIGH,
                                    utility.GetTargetCastPosition(npcBot, allyAbility[i], delayAbility, 0);
                            end
                        end
                    end
                end
            end
        end
    end
end

function ConsiderSpiritForm()
    local ability = SpiritForm;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:HasModifier("modifier_keeper_of_the_light_spirit_form")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (npcBot:GetAttackRange() * 2)
        then
            --npcBot:ActionImmediate_Chat("Использую SpiritForm для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
        then
            --npcBot:ActionImmediate_Chat("Использую SpiritForm для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end
