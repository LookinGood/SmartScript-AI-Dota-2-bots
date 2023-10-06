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
    Abilities[3],
    Abilities[3],
    Talents[1],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[4],
    Abilities[2],
    Abilities[6],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Scatterblast = AbilitiesReal[1]
local FiresnapCookie = AbilitiesReal[2]
local LilShredder = AbilitiesReal[3]
local GobbleUp = AbilitiesReal[4]
local SpitOut = AbilitiesReal[5]
local MortimerKisses = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castScatterblastDesire, castScatterblastLocation = ConsiderScatterblast();
    local castFiresnapCookieDesire, castFiresnapCookieTarget = ConsiderFiresnapCookie();
    local castLilShredderDesire = ConsiderLilShredder();
    local castGobbleUpDesire, castGobbleUpTarget = ConsiderGobbleUp();
    local castSpitOutDesire, castSpitOutLocation = ConsiderSpitOut();
    local castMortimerKissesDesire, castMortimerKissesLocation = ConsiderMortimerKisses();

    if (castScatterblastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Scatterblast, castScatterblastLocation);
        return;
    end

    if (castFiresnapCookieDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(FiresnapCookie, castFiresnapCookieTarget);
        return;
    end

    if (castLilShredderDesire ~= nil)
    then
        npcBot:Action_UseAbility(LilShredder);
        return;
    end

    if (castGobbleUpDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(GobbleUp, castGobbleUpTarget);
        return;
    end

    if (castSpitOutDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SpitOut, castSpitOutLocation);
        return;
    end

    if (castMortimerKissesDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MortimerKisses, castMortimerKissesLocation);
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        local delayAbility = MortimerKisses:GetSpecialValueInt("AbilityCastPoint");
        local speedAbility = MortimerKisses:GetSpecialValueInt("projectile_speed");
        if utility.IsValidTarget(botTarget)
        then
            npcBot:ActionPush_MoveToLocation(utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility));
        else
            local enemyAbility = npcBot:GetNearbyHeroes(MortimerKisses:GetCastRange(), true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.IsValidTarget(enemy)
                    then
                        npcBot:ActionPush_MoveToLocation(utility.GetTargetCastPosition(npcBot, enemy, delayAbility,
                            speedAbility));
                    end
                end
            end
        end
    end
end

function ConsiderScatterblast()
    local ability = Scatterblast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local meleeCastRangeAbility = ability:GetSpecialValueInt("point_blank_range");
    local radiusAbility = ability:GetSpecialValueInt("blast_width_initial");
    local damageAbility = ability:GetSpecialValueInt("damage");                            -- 280
    local meleeDamageAbility = damageAbility +
        (damageAbility / 100 * (ability:GetSpecialValueInt("point_blank_dmg_bonus_pct"))); -- 480
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("blast_speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                if GetUnitToUnitDistance(npcBot, enemy) <= (castRangeAbility + 200)
                then
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                    then
                        --npcBot:ActionImmediate_Chat("Использую Scatterblast что бы убить цель!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    end
                elseif GetUnitToUnitDistance(npcBot, enemy) <= meleeCastRangeAbility
                then
                    if utility.CanAbilityKillTarget(enemy, meleeDamageAbility, ability:GetDamageType())
                    then
                        --npcBot:ActionImmediate_Chat("Использую Scatterblast что бы убить цель ВБЛИЗИ!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    end
                end
            end
        end
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую Scatterblast по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_VERYHIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
        -- Retreat mode
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Scatterblast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
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
            --npcBot:ActionImmediate_Chat("Использую Scatterblast по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Scatterblast по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderFiresnapCookie()
    local ability = FiresnapCookie;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyHeroAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local allyCreepsAbility = npcBot:GetNearbyCreeps(castRangeAbility, false);
    local jumpRangeAbility = ability:GetSpecialValueInt("jump_horizontal_distance");
    local jumpRadiusAbility = ability:GetSpecialValueInt("impact_radius");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
        then
            if (#allyHeroAbility > 0)
            then
                for _, ally in pairs(allyHeroAbility)
                do
                    if ally:IsFacingLocation(botTarget:GetLocation(), 10) and GetUnitToUnitDistance(ally, botTarget) <= (jumpRangeAbility + (jumpRadiusAbility / 2))
                        and not ally:IsChanneling()
                    then
                        --npcBot:ActionImmediate_Chat("Использую FiresnapCookie для АТАКИ на союзного героя!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyCreepsAbility > 0)
            then
                for _, ally in pairs(allyCreepsAbility)
                do
                    if ally:IsFacingLocation(botTarget:GetLocation(), 10) and GetUnitToUnitDistance(ally, botTarget) <= jumpRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Использую FiresnapCookie для АТАКИна союзного крипа!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
    -- Retreat use
    if (#allyHeroAbility > 0)
    then
        for _, ally in pairs(allyHeroAbility)
        do
            if (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0)
                and ally:IsFacingLocation(utility.SafeLocation(npcBot), 40) and not ally:IsChanneling()
            then
                --npcBot:ActionImmediate_Chat("Использую FiresnapCookie для отступления!",true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end
end

function ConsiderLilShredder()
    local ability = LilShredder;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));

    -- Attack use
    if utility.PvPMode(npcBot) or npcBot:GetActiveMode() == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую LilShredder против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end
end

function ConsiderGobbleUp()
    local ability = GobbleUp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange() * 2;
    local spitDistance = SpitOut:GetCastRange();
    local allyHeroAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local allyCreepsAbility = npcBot:GetNearbyCreeps(castRangeAbility, false);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= spitDistance
        then
            if (#allyCreepsAbility > 0)
            then
                for _, ally in pairs(allyHeroAbility)
                do
                    --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, ally;
                end
            elseif (#allyHeroAbility > 1)
            then
                for _, ally in pairs(allyHeroAbility)
                do
                    if ally ~= npcBot and not ally:IsChanneling() and (ally:GetHealth() / ally:GetMaxHealth() >= 0.7)
                    then
                        --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного героя!", true);
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end
end

function ConsiderSpitOut()
    local ability = SpitOut;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    -- Generic use
    if npcBot:HasModifier("modifier_snapfire_gobble_up_belly_has_unit")
    then
        if utility.IsValidTarget(botTarget)
        then
            --npcBot:ActionImmediate_Chat("Использую SpitOut во врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE, botTarget:GetLocation();
        else
            return BOT_MODE_DESIRE_HIGH, npcBot:GetLocation() + RandomVector(500);
        end
    end
end

function ConsiderMortimerKisses()
    local ability = MortimerKisses;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local minRangeAbility = ability:GetSpecialValueInt("min_range");
    local castRangeAbility = ability:GetCastRange();
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and (GetUnitToUnitDistance(npcBot, botTarget) >= minRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility)
        then
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
    end
end
