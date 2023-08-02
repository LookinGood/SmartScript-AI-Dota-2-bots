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
    Abilities[6],
    Abilities[1],
    Abilities[2],
    Abilities[2],
    Talents[1],
    Abilities[2],
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
local StrokeOfFate = AbilitiesReal[1]
local PhantomsEmbrace = AbilitiesReal[2]
local InkSwell = AbilitiesReal[3]
local DarkPortrait = AbilitiesReal[4]
local Soulbind = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStrokeOfFateDesire, castStrokeOfFateLocation = ConsiderStrokeOfFate();
    local castPhantomsEmbraceDesire, castPhantomsEmbraceTarget = ConsiderPhantomsEmbrace();
    local castInkSwellDesire, castInkSwellTarget = ConsiderInkSwell();
    local castDarkPortraitDesire, castDarkPortraitTarget = ConsiderDarkPortrait();
    local castSoulbindDesire, castSoulbindTarget = ConsiderSoulbind();

    if (castStrokeOfFateDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(StrokeOfFate, castStrokeOfFateLocation);
        return;
    end

    if (castPhantomsEmbraceDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(PhantomsEmbrace, castPhantomsEmbraceTarget);
        return;
    end

    if (castInkSwellDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(InkSwell, castInkSwellTarget);
        return;
    end

    if (castDarkPortraitDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(DarkPortrait, castDarkPortraitTarget);
        return;
    end

    if (castSoulbindDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Soulbind, castSoulbindTarget);
        return;
    end
end

function ConsiderStrokeOfFate()
    local ability = StrokeOfFate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("start_radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
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
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую StrokeOfFate по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую StrokeOfFate по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderPhantomsEmbrace()
    local ability = PhantomsEmbrace;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("latch_duration")) +
        ability:GetSpecialValueInt("pop_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/Interrup cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую PhantomsEmbrace что бы убить цель!", true);
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsSilenced()
                then
                    --npcBot:ActionImmediate_Chat("Использую PhantomsEmbrace что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderInkSwell()
    local ability = InkSwell;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Cast if allys has negative effect or low HP
    if (#allyAbility > 0)
    then
        for i = 1, #allyAbility do
            if GetUnitToUnitDistance(allyAbility[i], npcBot) <= castRangeAbility
            then
                if utility.IsDisabled(allyAbility[i])
                    or (allyAbility[i]:GetHealth() / allyAbility[i]:GetMaxHealth() <= 0.8 and allyAbility[i]:WasRecentlyDamagedByAnyHero(2.0))
                then
                    --npcBot:ActionImmediate_Chat("Использую InkSwell на союзника!", true);
                    return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i];
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget)
        then
            for i = 1, #allyAbility do
                if utility.IsValidTarget(allyAbility[i]) and GetUnitToUnitDistance(allyAbility[i], npcBot) <= (castRangeAbility + 200)
                then
                    if GetUnitToUnitDistance(allyAbility[i], botTarget) <= radiusAbility
                        or (GetUnitToUnitDistance(allyAbility[i], botTarget) > (allyAbility[i]:GetAttackRange() * 2) and GetUnitToUnitDistance(allyAbility[i], botTarget) < 2000)
                    then
                        --npcBot:ActionImmediate_Chat("Использую InkSwell на союзника рядом с врагом!", true);
                        return BOT_MODE_DESIRE_ABSOLUTE, allyAbility[i];
                    end
                end
            end
        end
    end
end

function ConsiderDarkPortrait()
    local ability = DarkPortrait;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.6) and (enemy:GetLevel() >= npcBot:GetLevel())
                    and utility.SafeCast(enemy, false)
                then
                    --npcBot:ActionImmediate_Chat("Использую DarkPortrait на врага в радиусе действия!",true);
                    return BOT_MODE_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderSoulbind()
    local ability = Soulbind;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("chain_latch_radius");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and utility.SafeCast(botTarget, true)
        then
            for i = 1, #enemyAbility do
                if enemyAbility[i] ~= botTarget and utility.CanCastOnMagicImmuneTarget(enemyAbility[i])
                    and GetUnitToUnitDistance(enemyAbility[i], botTarget) <= radiusAbility
                then
                    --npcBot:ActionImmediate_Chat("Использую Soulbind по врагу в радиусе действия!",true);
                    return BOT_MODE_DESIRE_ABSOLUTE, botTarget;
                end
            end
        end
    end
end
