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
    Abilities[2],
    Abilities[3],
    Abilities[1],
    Abilities[1],
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[2],
    Abilities[2],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[5],
    Talents[8],
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local StiflingDagger = AbilitiesReal[1]
local PhantomStrike = AbilitiesReal[2]
local Blur = AbilitiesReal[3]
local FanOfKnives = AbilitiesReal[4]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStiflingDaggerDesire, castStiflingDaggerTarget = ConsiderStiflingDagger();
    local castPhantomStrikeDesire, castPhantomStrikeTarget = ConsiderPhantomStrike();
    local castBlurDesire = ConsiderBlur();
    local castFanOfKnivesDesire = ConsiderFanOfKnives();

    if (castStiflingDaggerDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(StiflingDagger, castStiflingDaggerTarget);
        return;
    end

    if (castPhantomStrikeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(PhantomStrike, castPhantomStrikeTarget);
        return;
    end

    if (castBlurDesire ~= nil)
    then
        npcBot:Action_UseAbility(Blur);
        return;
    end

    if (castFanOfKnivesDesire ~= nil)
    then
        npcBot:Action_UseAbility(FanOfKnives);
        return;
    end
end

function ConsiderStiflingDagger()
    local ability = StiflingDagger;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("base_damage") +
        math.floor(npcBot:GetAttackDamage()) / 100 * ability:GetSpecialValueInt("attack_factor_tooltip");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую StiflingDagger что бы убить цель!", true);
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
                    --npcBot:ActionImmediate_Chat("Использую StiflingDagger что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
        -- Last hit
    elseif not utility.PvPMode(npcBot) and not utility.RetreatMode(npcBot) and (ManaPercentage >= 0.4)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую StiflingDagger что бы добить крипа!", true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
    end
end

function ConsiderPhantomStrike()
    local ability = PhantomStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and GetUnitToUnitDistance(npcBot, botTarget) >= attackRange and not npcBot:HasModifier("modifier_phantom_assassin_phantom_strike")
            then
                --npcBot:ActionImmediate_Chat("Использую PhantomStrike по врагу в радиусе действия!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
            local allyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, false);
            local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
            local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
            local fountainLocation = utility.SafeLocation(npcBot);
            if (#allyAbility > 1)
            then
                for _, ally in pairs(allyAbility) do
                    if ally ~= npcBot and GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PhantomStrike для побега на союзника!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreeps > 0)
            then
                for _, ally in pairs(allyCreeps) do
                    if GetUnitToLocationDistance(ally, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(ally, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PhantomStrike для побега на союзного крипа!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PhantomStrike для побега на врага!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
            if (#enemyCreeps > 0)
            then
                for _, enemy in pairs(enemyCreeps) do
                    if GetUnitToLocationDistance(enemy, fountainLocation) < GetUnitToLocationDistance(npcBot, fountainLocation) and
                        (GetUnitToUnitDistance(enemy, npcBot) > castRangeAbility / 2)
                    then
                        --npcBot:ActionImmediate_Chat("Использую PhantomStrike для побега на вражеского крипа!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy;
                    end
                end
            end
        end
    end
end

function ConsiderBlur()
    local ability = Blur;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot) or utility.PvEMode(npcBot)
        or botMode == BOT_MODE_WARD or botMode == BOT_MODE_RUNE
    then
        if not npcBot:IsInvisible()
        then
            local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            local enemyTowers = npcBot:GetNearbyTowers(radiusAbility, true)
            if (#enemyAbility == 0 and #enemyTowers == 0)
            then
                --npcBot:ActionImmediate_Chat("Использую Blur!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderFanOfKnives()
    local ability = FanOfKnives;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            local damageAbility = math.floor(enemy:GetMaxHealth()) / 100 *
                ability:GetSpecialValueInt("pct_health_damage_initial");
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FanOfKnives что бы добить цель!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FanOfKnives для нападения/отступления!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Roshan use
        if utility.IsRoshan(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
        then
            --npcBot:ActionImmediate_Chat("Использую FanOfKnives против Рошана!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую FanOfKnives против крипов",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
