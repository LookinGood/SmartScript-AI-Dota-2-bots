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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

local AbilityToLevelUp =
{
    Abilities[3],
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[3],
    Abilities[6],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
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

-- Ability Use
function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    Reflection = AbilitiesReal[1]
    ConjureImage = AbilitiesReal[2]
    Metamorphosis = AbilitiesReal[3]
    DemonZeal = AbilitiesReal[4]
    TerrorWave = AbilitiesReal[5]
    Sunder = AbilitiesReal[6]

    castReflectionDesire, castReflectionLocation = ConsiderReflection();
    castConjureImageDesire = ConsiderConjureImage();
    castMetamorphosisDesire = ConsiderMetamorphosis();
    castDemonZealDesire = ConsiderDemonZeal();
    castTerrorWaveDesire = ConsiderTerrorWave();
    castSunderDesire, castSunderTarget = ConsiderSunder();

    if (castSunderDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Sunder, castSunderTarget);
        return;
    end

    if (castMetamorphosisDesire ~= nil)
    then
        npcBot:Action_UseAbility(Metamorphosis);
        return;
    end

    if (castReflectionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Reflection, castReflectionLocation);
        return;
    end

    if (castDemonZealDesire ~= nil)
    then
        npcBot:Action_UseAbility(DemonZeal);
        return;
    end

    if (castTerrorWaveDesire ~= nil)
    then
        npcBot:Action_UseAbility(TerrorWave);
        return;
    end

    if (castConjureImageDesire ~= nil)
    then
        npcBot:Action_UseAbility(ConjureImage);
        return;
    end
end

function ConsiderReflection()
    local ability = Reflection;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Reflection для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Reflection для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderConjureImage()
    local ability = ConjureImage;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and not botTarget:IsInvulnerable()
        then
            --npcBot:ActionImmediate_Chat("Использую ConjureImage для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую ConjureImage для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot) and (npcBot:DistanceFromFountain() > 1000) and (ManaPercentage >= 0.4)
    then
        --npcBot:ActionImmediate_Chat("Использую ConjureImage против вражеских сил!", true);
        return BOT_ACTION_DESIRE_LOW;
    end
end

function ConsiderMetamorphosis()
    local ability = Metamorphosis;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local baseAttackRange = npcBot:GetAttackRange();
    local bonusAttackRange = (ability:GetSpecialValueInt("bonus_range"));
    local attackRange = baseAttackRange + bonusAttackRange;

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            and not npcBot:HasModifier("modifier_terrorblade_metamorphosis")
        then
            --npcBot:ActionImmediate_Chat("Использую Metamorphosis для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderDemonZeal()
    local ability = DemonZeal;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnInvulnerableTarget(botTarget) and (HealthPercentage > 0.2)
            and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange + 200)
        then
            --npcBot:ActionImmediate_Chat("Использую DemonZeal для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage > 0.2) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую DemonZeal для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderTerrorWave()
    local ability = TerrorWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = (ability:GetSpecialValueInt("scepter_radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую TerrorWave что бы сбить заклинание цели!",true);
                return BOT_ACTION_DESIRE_VERYHIGH;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую TerrorWave для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую TerrorWave для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSunder()
    local ability = Sunder;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local minimumHp = (ability:GetSpecialValueInt("hit_point_minimum_pct"));
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if enemy has more HP
    if (#enemyAbility > 0) and (HealthPercentage <= 0.2)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and ((enemy:GetHealth() / enemy:GetMaxHealth()) > 0.3)
            then
                --npcBot:ActionImmediate_Chat("Использую Sunder на врага со здоровьем ниже 30%!",true);
                return BOT_MODE_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Try to safe ally
    if (#allyAbility > 0) and (HealthPercentage >= 0.3) and
        (not npcBot:WasRecentlyDamagedByAnyHero(2.0) and
            not npcBot:WasRecentlyDamagedByCreep(2.0) and
            not npcBot:WasRecentlyDamagedByTower(2.0))
    then
        for _, ally in pairs(allyAbility)
        do
            if (ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2)
                and
                (ally:WasRecentlyDamagedByAnyHero(2.0) or
                    ally:WasRecentlyDamagedByCreep(2.0) or
                    ally:WasRecentlyDamagedByTower(2.0))
            then
                --npcBot:ActionImmediate_Chat("Использую Sunder на союзного героя со здоровьем ниже 20%!",true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end
end
