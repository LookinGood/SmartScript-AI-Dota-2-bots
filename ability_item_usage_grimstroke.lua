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
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local StrokeOfFate = AbilitiesReal[1]
local PhantomsEmbrace = AbilitiesReal[2]
local InkSwell = AbilitiesReal[3]
local InkExplosion = npcBot:GetAbilityByName("grimstroke_return");
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
    local castInkExplosionDesire = ConsiderInkExplosion();
    local castDarkPortraitDesire, castDarkPortraitTarget = ConsiderDarkPortrait();
    local castSoulbindDesire, castSoulbindTarget = ConsiderSoulbind();

    if (castStrokeOfFateDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(StrokeOfFate, castStrokeOfFateLocation);
        return;
    end

    if (castPhantomsEmbraceDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(PhantomsEmbrace, castPhantomsEmbraceTarget);
        return;
    end

    if (castInkSwellDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(InkSwell, castInkSwellTarget);
        return;
    end

    if (castInkExplosionDesire > 0)
    then
        npcBot:Action_UseAbility(InkExplosion);
        return;
    end

    if (castDarkPortraitDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(DarkPortrait, castDarkPortraitTarget);
        return;
    end

    if (castSoulbindDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(Soulbind, castSoulbindTarget);
        return;
    end
end

function ConsiderStrokeOfFate()
    local ability = StrokeOfFate;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("start_radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
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
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую StrokeOfFate по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую StrokeOfFate по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderPhantomsEmbrace()
    local ability = PhantomsEmbrace;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("damage_per_second") * ability:GetSpecialValueInt("latch_duration")) +
        ability:GetSpecialValueInt("pop_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/Interrupt cast
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
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility + 200
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsSilenced()
                then
                    --npcBot:ActionImmediate_Chat("Использую PhantomsEmbrace что бы оторваться от врага", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderInkSwell()
    local ability = InkSwell;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);

    -- Cast if allys has negative effect or low HP
    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility)
        do
            if utility.IsHero(ally) and (utility.IsDisabled(ally) or (ally:GetHealth() / ally:GetMaxHealth() <= 0.8 and ally:WasRecentlyDamagedByAnyHero(2.0)))
            then
                --npcBot:ActionImmediate_Chat("Использую InkSwell на союзника раненного!", true);
                return BOT_ACTION_DESIRE_ABSOLUTE, ally;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally) and (GetUnitToUnitDistance(ally, botTarget) <= radiusAbility or
                            (GetUnitToUnitDistance(ally, botTarget) > ally:GetAttackRange() * 2 and GetUnitToUnitDistance(ally, botTarget) < 1000))
                    then
                        --npcBot:ActionImmediate_Chat("Использую InkSwell на союзника рядом с врагом!", true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, ally;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderInkExplosion()
    local ability = InkExplosion;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    local radiusAbility = InkSwell:GetSpecialValueInt("radius");
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Use if around ally has enemy hero
    if (#allyHeroes > 0)
    then
        for _, ally in pairs(allyHeroes) do
            if ally:HasModifier("modifier_grimstroke_spirit_walk_buff")
            then
                local enemyHeroes = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyHeroes > 0)
                then
                    for _, enemy in pairs(enemyHeroes) do
                        if utility.CanCastSpellOnTarget(InkSwell, enemy) and not utility.IsDisabled(enemy)
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderDarkPortrait()
    local ability = DarkPortrait;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.6) and
                    (enemy:GetRawOffensivePower() >= npcBot:GetOffensivePower())
                then
                    --npcBot:ActionImmediate_Chat("Использую DarkPortrait на врага в радиусе действия!",true);
                    return BOT_MODE_DESIRE_HIGH, enemy;
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSoulbind()
    local ability = Soulbind;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("chain_latch_radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if (#enemyAbility > 1)
            then
                for _, enemy in pairs(enemyAbility) do
                    if enemy ~= botTarget and utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(enemy, botTarget) <= radiusAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую Soulbind по врагу в радиусе действия!", true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, botTarget;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end
