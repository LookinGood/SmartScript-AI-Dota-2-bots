---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")
require(GetScriptDirectory() .. "/spell_usage_generic")

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
    Talents[1],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Telekinesis = AbilitiesReal[1]
local TelekinesisLand = npcBot:GetAbilityByName("rubick_telekinesis_land");
local TelekinesisLandSelf = npcBot:GetAbilityByName("rubick_telekinesis_land_self");
local FadeBolt = AbilitiesReal[2]
local SpellSteal = AbilitiesReal[6]

local castLandTimer = 0.0;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    --print(ability4:GetName())
    --print(ability5:GetName())

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castTelekinesisDesire, castTelekinesisTarget = ConsiderTelekinesis();
    local castTelekinesisLandDesire, castTelekinesisLandLocation = ConsiderTelekinesisLand();
    local castTelekinesisLandSelfDesire, castTelekinesisLandSelfLocation = ConsiderTelekinesisLandSelf();
    local castFadeBoltDesire, castFadeBoltTarget = ConsiderFadeBolt();
    local castSpellStealDesire, castSpellStealTarget = ConsiderSpellSteal();

    if (castTelekinesisDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Telekinesis, castTelekinesisTarget);
        return;
    end

    if (castTelekinesisLandDesire ~= nil) and (DotaTime() >= castLandTimer + 2.0)
    then
        npcBot:Action_UseAbilityOnLocation(TelekinesisLand, castTelekinesisLandLocation);
        castLandTimer = DotaTime();
        return;
    end

    if (castTelekinesisLandSelfDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(TelekinesisLandSelf, castTelekinesisLandSelfLocation);
        return;
    end

    if (castFadeBoltDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FadeBolt, castFadeBoltTarget);
        return;
    end

    local ability4 = npcBot:GetAbilityInSlot(3);
    local ability5 = npcBot:GetAbilityInSlot(4);

    spell_usage_generic.CastCustomSpell(ability4)
    spell_usage_generic.CastCustomSpell(ability5)

    if (castSpellStealDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(SpellSteal, castSpellStealTarget);
        return;
    end
end

function ConsiderTelekinesis()
    local ability = Telekinesis;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
                and not utility.IsDisabled(botTarget)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

function ConsiderTelekinesisLand()
    local ability = TelekinesisLand;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --local liftDuration = Telekinesis:GetSpecialValueInt("lift_duration");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую TelekinesisLand при атаке на " .. botTarget:GetUnitName(), true);
        return BOT_MODE_DESIRE_MODERATE, utility.SafeLocation(npcBot);
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                --npcBot:ActionImmediate_Chat("Использую TelekinesisLand при отходе на " .. enemy:GetUnitName(), true);
                return BOT_MODE_DESIRE_MODERATE, utility.SafeLocation(enemy);
            end
        end
    end
end

function ConsiderTelekinesisLandSelf()
    local ability = TelekinesisLandSelf;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if utility.RetreatMode(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Использую TelekinesisLandSelf при отходе", true);
        return BOT_MODE_DESIRE_MODERATE, utility.SafeLocation(npcBot);
    end
end

function ConsiderFadeBolt()
    local ability = FadeBolt;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
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
                    --npcBot:ActionImmediate_Chat("Использую FadeBolt что бы убить " .. enemy:GetUnitName(), true);
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

    -- Retreat use
    if utility.RetreatMode(npcBot)
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

    --  Pushing/defending/Farm
    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps >= 3) and (ManaPercentage >= 0.7)
        then
            local enemy = utility.GetWeakest(enemyCreeps);
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            return BOT_ACTION_DESIRE_VERYHIGH, enemy;
        end
    end
end

function ConsiderSpellSteal()
    local ability = SpellSteal;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    --[[     if (ability4 ~= nil and utility.IsAbilityAvailable(ability4)) and
        (ability5 ~= nil and utility.IsAbilityAvailable(ability5))
    then
        return;
    end ]]

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if (#enemyAbility > 0) and (ManaPercentage > 0.1)
    then
        for _, enemy in pairs(enemyAbility) do
            if (enemy:IsUsingAbility() or
                    enemy:IsCastingAbility() or
                    enemy:IsChanneling())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SpellSteal на " .. enemy:GetUnitName(), true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end
