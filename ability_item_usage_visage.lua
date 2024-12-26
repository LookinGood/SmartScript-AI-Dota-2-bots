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
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[4],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[3],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local GraveChill = AbilitiesReal[1]
local SoulAssumption = AbilitiesReal[2]
local GravekeepersCloak = AbilitiesReal[3]
local StoneForm = AbilitiesReal[4]
local SilentAsTheGrave = AbilitiesReal[5]
local SummonFamiliars = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castGraveChillDesire, castGraveChillTarget = ConsiderGraveChill();
    local castSoulAssumptionDesire, castSoulAssumptionTarget = ConsiderSoulAssumption();
    local castGravekeepersCloakDesire = ConsiderGravekeepersCloak();
    local castStoneFormDesire = ConsiderStoneForm();
    local castSilentAsTheGraveDesire = ConsiderSilentAsTheGrave();
    local castSummonFamiliarsDesire = ConsiderSummonFamiliars();

    if (castGraveChillDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(GraveChill, castGraveChillTarget);
        return;
    end

    if (castSoulAssumptionDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SoulAssumption, castSoulAssumptionTarget);
        return;
    end

    if (castGravekeepersCloakDesire ~= nil)
    then
        npcBot:Action_UseAbility(GravekeepersCloak);
        return;
    end

    if (castStoneFormDesire ~= nil)
    then
        npcBot:Action_UseAbility(StoneForm);
        return;
    end

    if (castSilentAsTheGraveDesire ~= nil)
    then
        npcBot:Action_UseAbility(SilentAsTheGrave);
        return;
    end

    if (castSummonFamiliarsDesire ~= nil)
    then
        npcBot:Action_UseAbility(SummonFamiliars);
        return;
    end
end

local function IsFamiliar(npcTarget)
    return IsValidTarget(npcTarget) and string.find(npcTarget:GetUnitName(), "familiar");
end

local function CountFamiliars()
    local count = 0;
    local allyCreeps = GetUnitList(UNIT_LIST_ALLIED_CREEPS);
    if (#allyCreeps > 0)
    then
        for _, ally in pairs(allyCreeps) do
            if IsFamiliar(ally)
            then
                count = count + 1;
            end
        end
    end

    return count;
end

function ConsiderGraveChill()
    local ability = GraveChill;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

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

function ConsiderSoulAssumption()
    local ability = SoulAssumption;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local abilityMaxCharges = ability:GetSpecialValueInt("stack_limit");
    local abilityCount = utility.GetModifierCount(npcBot, "modifier_visage_soul_assumption");
    local damageAbility = ability:GetSpecialValueInt("soul_base_damage") +
        (abilityCount * ability:GetSpecialValueInt("soul_charge_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SoulAssumption что бы добить " .. enemy:GetUnitName(), true);
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
                and abilityCount >= abilityMaxCharges
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end
end

function ConsiderGravekeepersCloak()
    local ability = GravekeepersCloak;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_visage_summon_familiars_stone_form_buff")
    then
        return;
    end

    local radiusAbility = StoneForm:GetSpecialValueInt("stun_radius");
    local damageAbility = StoneForm:GetSpecialValueInt("stun_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую GravekeepersCloak что бы добить " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE;
                end
            end
        end
    end

    -- General use
    if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4) and (npcBot:WasRecentlyDamagedByAnyHero(2.0) or npcBot:WasRecentlyDamagedByTower(2.0))
    then
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderStoneForm()
    local ability = StoneForm;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("stun_radius");
    local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    if (#enemyHeroes > 0)
    then
        for _, enemy in pairs(enemyHeroes) do
            if utility.CanCastSpellOnTarget(SoulAssumption, enemy) and not utility.IsDisabled(enemy)
            then
                local allyCreeps = enemy:GetNearbyCreeps(radiusAbility, true);
                if (#allyCreeps > 0)
                then
                    if IsFamiliar(allyCreeps[1]) and not allyCreeps[1]:HasModifier("modifier_visage_summon_familiars_stone_form_buff")
                        and not allyCreeps[1]:HasModifier("modifier_rooted")
                    then
                        --npcBot:ActionImmediate_Chat("Использую StoneForm против " .. enemy:GetUnitName(), true);
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                end
            end
        end
    end
end

function ConsiderSilentAsTheGrave()
    local ability = SilentAsTheGrave;
    if not utility.IsAbilityAvailable(ability)
    then
        return;
    end

    if npcBot:IsInvisible()
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2) and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderSummonFamiliars()
    local ability = SummonFamiliars;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Alternative use-mod broken this spell for bot
    if npcBot:IsAlive()
    then
        return;
    end

    local maxFamiliars = ability:GetSpecialValueInt("familiar_count");

    if CountFamiliars() >= maxFamiliars
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange * 2)
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage < 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Cast if push/defend/farm/roshan
    elseif utility.PvEMode(npcBot)
    then
        if (npcBot:DistanceFromFountain() >= 1000) and (ManaPercentage >= 0.3)
        then
            return BOT_ACTION_DESIRE_LOW;
        end
    end
end
