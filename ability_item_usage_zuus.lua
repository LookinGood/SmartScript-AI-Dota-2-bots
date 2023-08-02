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
    Abilities[2],
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ArcLightning = AbilitiesReal[1]
local LightningBolt = AbilitiesReal[2]
local HeavenlyJump = AbilitiesReal[3]
local Nimbus = AbilitiesReal[4]
local LightningHands = AbilitiesReal[5]
local ThundergodWrath = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castArcLightningDesire, castArcLightningTarget = ConsiderArcLightning();
    local castLightningBoltDesire, castLightningBoltLocation = ConsiderLightningBolt();
    local castHeavenlyJumpDesire = ConsiderHeavenlyJump();
    local castNimbusDesire, castNimbusLocation = ConsiderNimbus();
    ConsiderLightningHands();
    local castThundergodWrathDesire = ConsiderThundergodWrath();

    if (castArcLightningDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ArcLightning, castArcLightningTarget);
        return;
    end

    if (castLightningBoltDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(LightningBolt, castLightningBoltLocation);
        return;
    end

    if (castHeavenlyJumpDesire ~= nil)
    then
        npcBot:Action_UseAbility(HeavenlyJump);
        return;
    end

    if (castNimbusDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Nimbus, castNimbusLocation);
        return;
    end

    if (castThundergodWrathDesire ~= nil)
    then
        npcBot:Action_UseAbility(ThundergodWrath);
        return;
    end
end

function ConsiderArcLightning()
    local ability = ArcLightning;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("arc_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcLightning что бы сбить заклинание или убить цель!",true);
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
        -- Last hit
    elseif not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT and (ManaPercentage >= 0.4)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcLightning что бы добить крипа!",true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую ArcLightning по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderLightningBolt()
    local ability = LightningBolt;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                or enemy:IsChanneling() or enemy:IsInvisible()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.7) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningBolt по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningBolt по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderHeavenlyJump()
    local ability = HeavenlyJump;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump для отступления", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderNimbus()
    local ability = Nimbus;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("cloud_radius") * 10;
    local radiusAbility = ability:GetSpecialValueInt("cloud_radius");
    local damageAbility = LightningBolt:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody
    for i = 1, #enemyAbility do
        if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, ability:GetDamageType())
            and utility.CanCastSpellOnTarget(ability, enemyAbility[i])
        then
            --npcBot:ActionImmediate_Chat("Использую Nimbus что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE, utility.GetTargetPosition(enemyAbility[i], delayAbility);
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(botTarget, delayAbility);
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
        -- Pushing/defending
    elseif utility.PvEMode(npcBot)
    then
        local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
        local frendlyTower = npcBot:GetNearbyTowers(castRangeAbility, false);
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                local enemyHeroAroundTower = enemy:GetNearbyHeroes(radiusAbility, false, BOT_MODE_NONE);
                if (#enemyHeroAroundTower > 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Nimbus под вражескую башню!", true);
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                end
            end
        end
        if (#frendlyTower > 0)
        then
            for _, ally in pairs(frendlyTower) do
                local enemyHeroAroundTower = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyHeroAroundTower > 0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Nimbus под союзную башню!", true);
                    return BOT_MODE_DESIRE_LOW, ally:GetLocation();
                end
            end
        end
    end
end

function ConsiderLightningHands()
    local ability = LightningHands;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end
end

function ConsiderThundergodWrath()
    local ability = ThundergodWrath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Generic use if can kill enemy hero
    for i = 1, #enemyAbility do
        if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, ability:GetDamageType())
            and utility.CanCastSpellOnTarget(ability, enemyAbility[i])
        then
            --npcBot:ActionImmediate_Chat("Использую ThundergodWrath что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
    end
end
