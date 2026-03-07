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
    Talents[3],
    Abilities[2],
    Abilities[6],
    Talents[5],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[6],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Scatterblast = npcBot:GetAbilityByName("snapfire_scatterblast");
local FiresnapCookie = npcBot:GetAbilityByName("snapfire_firesnap_cookie");
local LilShredder = npcBot:GetAbilityByName("snapfire_lil_shredder");
local GobbleUp = npcBot:GetAbilityByName("snapfire_gobble_up");
local SpitOut = npcBot:GetAbilityByName("snapfire_spit_creep");
local MortimerKisses = npcBot:GetAbilityByName("snapfire_mortimer_kisses");

local gobbleUpEnemyTarget = nil;
local gobbleUpAllySafeHero = nil;

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
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

    if (castScatterblastDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(Scatterblast, castScatterblastLocation);
        return;
    end

    if (castFiresnapCookieDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(FiresnapCookie, castFiresnapCookieTarget);
        return;
    end

    if (castLilShredderDesire > 0)
    then
        npcBot:Action_UseAbility(LilShredder);
        return;
    end

    if (castGobbleUpDesire > 0)
    then
        npcBot:Action_UseAbilityOnEntity(GobbleUp, castGobbleUpTarget);
        return;
    end

    if (castSpitOutDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(SpitOut, castSpitOutLocation);
        return;
    end

    if (castMortimerKissesDesire > 0)
    then
        npcBot:Action_UseAbilityOnLocation(MortimerKisses, castMortimerKissesLocation);
        return;
    end
end

function ConsiderScatterblast()
    local ability = Scatterblast;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
                if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                    then
                        --npcBot:ActionImmediate_Chat("Использую Scatterblast что бы убить цель!",true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    end
                elseif GetUnitToUnitDistance(npcBot, enemy) <= meleeCastRangeAbility
                then
                    if utility.CanAbilityKillTarget(enemy, meleeDamageAbility, ability:GetDamageType())
                    then
                        --npcBot:ActionImmediate_Chat("Использую Scatterblast что бы убить цель ВБЛИЗИ!",true);
                        return BOT_ACTION_DESIRE_ABSOLUTE,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                    end
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
                --npcBot:ActionImmediate_Chat("Использую Scatterblast по врагу в радиусе действия!",true);
                return BOT_ACTION_DESIRE_HIGH,
                    utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
            end
        end
    end

    -- Retreat mode
    if utility.RetreatMode(npcBot)
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
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility,
            0, 0);
        if locationAoE ~= nil and (ManaPercentage >= 0.5) and (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую Scatterblast по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            --npcBot:ActionImmediate_Chat("Использую Scatterblast по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderFiresnapCookie()
    local ability = FiresnapCookie;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
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
                and ally:IsFacingLocation(utility.GetFountainLocation(), 40) and not ally:IsChanneling() and ally:DistanceFromFountain() > jumpRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую FiresnapCookie для отступления!",true);
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderLilShredder()
    local ability = LilShredder;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_snapfire_lil_shredder_buff")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local attackRange = npcBot:GetAttackRange() + (ability:GetSpecialValueInt("attack_range_bonus"));

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= attackRange
            then
                --npcBot:ActionImmediate_Chat("Использую LilShredder против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function ConsiderGobbleUp()
    local ability = GobbleUp;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_snapfire_gobble_up_belly_has_unit")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange() * 2;
    local damageAbility = ability:GetSpecialValueInt("burn_damage") * ability:GetSpecialValueInt("burn_ground_duration");
    local spitDistance = SpitOut:GetCastRange();
    local allyHeroAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, false, BOT_MODE_NONE);
    local allyCreepsAbility = npcBot:GetNearbyCreeps(castRangeAbility, false);
    local enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurrentCastDistance(spitDistance), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, MortimerKisses:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(MortimerKisses, enemy)
                then
                    if (#allyCreepsAbility > 0)
                    then
                        for _, ally in pairs(allyCreepsAbility)
                        do
                            --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного крипа убивая цель " .. enemy:GetUnitName(), true);
                            gobbleUpEnemyTarget = enemy;
                            return BOT_ACTION_DESIRE_HIGH, ally;
                        end
                    end
                    if (#allyHeroAbility > 1)
                    then
                        for _, ally in pairs(allyHeroAbility)
                        do
                            if ally ~= npcBot and not ally:IsChanneling() and (ally:GetHealth() / ally:GetMaxHealth() >= 0.7)
                            then
                                --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного героя убивая цель " .. enemy:GetUnitName(), true);
                                gobbleUpEnemyTarget = enemy;
                                return BOT_ACTION_DESIRE_HIGH, ally;
                            end
                        end
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(MortimerKisses, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= spitDistance
        then
            if (#allyCreepsAbility > 0)
            then
                for _, ally in pairs(allyCreepsAbility)
                do
                    if not utility.IsTargetInvulnerable(ally)
                    then
                        --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного крипа атакуя цель " .. botTarget:GetUnitName(), true);
                        gobbleUpEnemyTarget = botTarget;
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
            if (#allyHeroAbility > 1)
            then
                for _, ally in pairs(allyHeroAbility)
                do
                    if ally ~= npcBot and not utility.IsTargetInvulnerable(ally) and not ally:IsChanneling() and (ally:GetHealth() / ally:GetMaxHealth() >= 0.7)
                    then
                        --npcBot:ActionImmediate_Chat("Использую GobbleUp на союзного героя атакуя цель " .. botTarget:GetUnitName(), true);
                        gobbleUpEnemyTarget = botTarget;
                        return BOT_ACTION_DESIRE_HIGH, ally;
                    end
                end
            end
        end
    end

    -- Try to safe ally
    if (#allyHeroAbility > 1)
    then
        for _, ally in pairs(allyHeroAbility)
        do
            if ally ~= npcBot and utility.IsHero(ally) and ally:WasRecentlyDamagedByAnyHero(2.0) and not ally:IsChanneling() and
                (ally:GetHealth() / ally:GetMaxHealth() <= 0.4)
            then
                npcBot:ActionImmediate_Chat("Использую GobbleUp на союзника " .. ally:GetUnitName(), true);
                gobbleUpAllySafeHero = ally;
                return BOT_ACTION_DESIRE_HIGH, ally;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

function ConsiderSpitOut()
    local ability = SpitOut;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if not npcBot:HasModifier("modifier_snapfire_gobble_up_belly_has_unit")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("impact_radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");

    -- Generic use
    if gobbleUpEnemyTarget ~= nil
    then
        --npcBot:ActionImmediate_Chat("Использую SpitOut на " .. gobbleUpEnemyTarget:GetUnitName(), true);
        return BOT_ACTION_DESIRE_ABSOLUTE,
            utility.GetTargetCastPosition(npcBot, gobbleUpEnemyTarget, delayAbility, speedAbility);
    end

    if gobbleUpAllySafeHero ~= nil
    then
        --npcBot:ActionImmediate_Chat("Использую SpitOut на союзника " .. gobbleUpAllySafeHero:GetUnitName(), true);
        return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetEscapeLocation(npcBot, castRangeAbility);
    end

    return BOT_ACTION_DESIRE_VERYLOW, npcBot:GetLocation() + RandomVector(radiusAbility);
end

function ConsiderMortimerKisses()
    local ability = MortimerKisses;
    if not utility.IsAbilityAvailable(ability) then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    if npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return BOT_ACTION_DESIRE_NONE, 0;
    end

    local castRangeAbility = ability:GetCastRange();
    local minRangeAbility = ability:GetSpecialValueInt("min_range");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("projectile_speed");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and (GetUnitToUnitDistance(npcBot, botTarget) >= minRangeAbility and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility)
        then
            mortimerKissesTarget = botTarget;
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
    end

    return BOT_ACTION_DESIRE_NONE, 0;
end

--[[ function SelectTargetForMortimerKisses(mortimerKissesTarget)
    if not npcBot:HasModifier("modifier_snapfire_mortimer_kisses")
    then
        return;
    end

    local castRangeAbility = MortimerKisses:GetCastRange();
    local minRangeAbility = MortimerKisses:GetSpecialValueInt("min_range");
    local delayAbility = MortimerKisses:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = MortimerKisses:GetSpecialValueInt("projectile_speed");

    if mortimerKissesTarget ~= nil
    then
        npcBot:Action_ClearActions(false);
        npcBot:ActionPush_MoveToLocation(utility.GetTargetCastPosition(npcBot, mortimerKissesTarget, delayAbility,
            speedAbility));
        npcBot:ActionImmediate_Ping(mortimerKissesTarget:GetLocation().x, mortimerKissesTarget:GetLocation().y, false);
        return;
    else
        local enemyHeroes = GetUnitList(UNIT_LIST_ENEMY_HEROES);
        if (#enemyHeroes > 0)
        then
            for _, enemy in pairs(enemyHeroes) do
                if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility and
                    GetUnitToUnitDistance(npcBot, enemy) >= minRangeAbility
                then
                    mortimerKissesTarget = enemy;
                    npcBot:ActionImmediate_Chat(
                        "Использую MortimerKisses на героя: " .. mortimerKissesTarget:GetUnitName(), true);
                    return;
                end
            end
        end
        local enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility and
                    GetUnitToUnitDistance(npcBot, enemy) >= minRangeAbility
                then
                    mortimerKissesTarget = enemy;
                    npcBot:ActionImmediate_Chat(
                        "Использую MortimerKisses на крипа: " .. mortimerKissesTarget:GetUnitName(), true);
                    return;
                end
            end
        end
    end
end ]]
