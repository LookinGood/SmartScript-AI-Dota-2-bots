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
    Talents[7],
    Talents[1],
    Talents[4],
    Talents[6],
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
    local castLightningHandsDesire = ConsiderLightningHands();
    local castThundergodWrathDesire = ConsiderThundergodWrath();

    if (castArcLightningDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(ArcLightning, castArcLightningTarget);
        return;
    end

    if (castLightningBoltDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(LightningBolt, castLightningBoltLocation);
        return;
    end

    if (castHeavenlyJumpDesire > 0)
    then
        npcBot:Action_UseAbility(HeavenlyJump);
        return;
    end

    if (castNimbusDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Nimbus, castNimbusLocation);
        return;
    end

    if (castLightningHandsDesire > 0)
    then
        npcBot:Action_UseAbility(LightningHands);
        return;
    end

    if (castThundergodWrathDesire > 0)
    then
        npcBot:Action_UseAbility(ThundergodWrath);
        return;
    end
end

function ConsiderArcLightning()
    local ability = ArcLightning;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = ability:GetSpecialValueInt("arc_damage") + (enemy:GetMaxHealth() / 100 *
                ability:GetSpecialValueInt("damage_health_pct"));
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcLightning что бы убить цель!",true);
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
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Last hit
    if not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and (ManaPercentage >= 0.4)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                local damageAbility = ability:GetSpecialValueInt("arc_damage") + (enemy:GetMaxHealth() / 100 *
                    ability:GetSpecialValueInt("damage_health_pct"));
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLightningBolt()
    local ability = LightningBolt;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("spread_aoe");
    local damageAbility = ability:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                or enemy:IsChanneling() or enemy:IsInvisible()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
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
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (ManaPercentage >= 0.7) and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningBolt по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую LightningBolt по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderHeavenlyJump()
    local ability = HeavenlyJump;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_zuus_heavenly_jump_boost_buff")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local castRangeAbility = ability:GetSpecialValueInt("range");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump для отступления", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderNimbus()
    local ability = Nimbus;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetSpecialValueInt("cloud_radius") * 10;
    --local radiusAbility = ability:GetSpecialValueInt("cloud_radius");
    local damageAbility = LightningBolt:GetAbilityDamage();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Nimbus что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end


    --[[     -- Cast if can kill somebody
    for i = 1, #enemyAbility do
        if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, ability:GetDamageType())
            and utility.CanCastSpellOnTarget(ability, enemyAbility[i])
        then
            --npcBot:ActionImmediate_Chat("Использую Nimbus что бы добить врага!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemyAbility[i], delayAbility, 0);
        end
    end ]]

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
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
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                end
            end
        end
    end

    --[[         -- Pushing/defending
    elseif utility.PvEMode(npcBot)
    then
        local enemyTower = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);
        local frendlyTower = GetUnitList(UNIT_LIST_ALLIED_BUILDINGS);
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                if enemy:IsTower()
                then
                    local enemyHeroAroundTower = utility.CountEnemyHeroAroundUnit(enemy, radiusAbility);
                    if (enemyHeroAroundTower > 0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Nimbus под вражескую башню " .. enemy:GetUnitName(), true);
                        return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                    end
                end
            end
        end
        if (#frendlyTower > 0)
        then
            for _, ally in pairs(frendlyTower) do
                if ally:IsTower()
                then
                    local enemyHeroAroundTower = utility.CountEnemyHeroAroundUnit(ally, radiusAbility);
                    local enemyCreepsAroundTower = utility.CountEnemyCreepAroundUnit(enemy, radiusAbility);
                    if (enemyHeroAroundTower > 0) or (enemyCreepsAroundTower > 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Nimbus под союзную башню " .. enemy:GetUnitName(), true);
                        return BOT_MODE_DESIRE_LOW, ally:GetLocation();
                    end
                end
            end
        end ]]

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLightningHands()
    local ability = LightningHands;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if ability:GetToggleState() == false
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    --[[   if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end ]]

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderThundergodWrath()
    local ability = ThundergodWrath;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Cast if can kill/do a lot of damage somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsHero(enemy)
            then
                local damageAbility = ability:GetSpecialValueInt("damage") + (enemy:GetMaxHealth() / 100 *
                    ability:GetSpecialValueInt("damage_pct"));
                --print(damageAbility)
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or damageAbility >= math.floor(enemy:GetMaxHealth() / 2)
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ThundergodWrath что бы убить " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

--[[     -- Generic use if can kill enemy hero
    for i = 1, #enemyAbility do
        if utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, ability:GetDamageType())
            and utility.CanCastSpellOnTarget(ability, enemyAbility[i])
        then
            --npcBot:ActionImmediate_Chat("Использую ThundergodWrath что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
    end ]]
