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
    Talents[6],
    Talents[8],
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[7],
}


function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local StickyBomb = AbilitiesReal[1]
local ReactiveTazer = AbilitiesReal[2]
local DetonateTazer = npcBot:GetAbilityByName("techies_reactive_tazer_stop");
local BlastOff = AbilitiesReal[3]
local MinefieldSign = AbilitiesReal[5]
local ProximityMines = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castStickyBombDesire, castStickyBombLocation = ConsiderStickyBomb();
    local castReactiveTazerDesire, castReactiveTazerTarget, castReactiveTazerTargetType = ConsiderReactiveTazer();
    local castDetonateTazerDesire = ConsiderDetonateTazer();
    local castBlastOffDesire, castBlastOffLocation = ConsiderBlastOff();
    local castMinefieldSignDesire, castMinefieldSignLocation = ConsiderMinefieldSign();
    local castProximityMinesDesire, castProximityMinesLocation = ConsiderProximityMines();

    if (castStickyBombDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(StickyBomb, castStickyBombLocation);
        return;
    end

    if (castReactiveTazerDesire ~= nil)
    then
        if (castReactiveTazerTargetType == nil)
        then
            npcBot:Action_UseAbility(ReactiveTazer);
            return;
        elseif (castReactiveTazerTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(ReactiveTazer, castReactiveTazerTarget);
            return;
        end
    end

    if (castDetonateTazerDesire ~= nil)
    then
        npcBot:Action_UseAbility(DetonateTazer);
        return;
    end

    if (castBlastOffDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(BlastOff, castBlastOffLocation);
        return;
    end

    if (castProximityMinesDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ProximityMines, castProximityMinesLocation);
        return;
    end

    if (castMinefieldSignDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(MinefieldSign, castMinefieldSignLocation);
        return;
    end
end

function ConsiderStickyBomb()
    local ability = StickyBomb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local speedAbility = ability:GetSpecialValueInt("speed");
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

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                --npcBot:ActionImmediate_Chat("Использую StickyBomb для нападения!", true);
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
                    --npcBot:ActionImmediate_Chat("Использую StickyBomb для отступления!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end

    -- Cast if push/defend/farm
    if utility.PvEMode(npcBot)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2) and (ManaPercentage >= 0.6)
        then
            --npcBot:ActionImmediate_Chat("Использую StickyBomb по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
    end

    -- Cast when laning
    if botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.8)
        then
            --npcBot:ActionImmediate_Chat("Использую StickyBomb по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
        end
    end
end

function ConsiderReactiveTazer()
    local ability = ReactiveTazer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("stun_radius");

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        if not npcBot:HasModifier("modifier_techies_reactive_tazer")
        then
            -- Attack use
            if utility.PvPMode(npcBot)
            then
                local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastOnMagicImmuneTarget(enemy)
                        then
                            --npcBot:ActionImmediate_Chat("Использую Reactive Tazer для нападения!", true);
                            return BOT_ACTION_DESIRE_HIGH, nil, nil;
                        end
                    end
                end
                -- Retreat use
            elseif utility.RetreatMode(npcBot)
            then
                if (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
                then
                    --npcBot:ActionImmediate_Chat("Использую Reactive Tazer для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, nil, nil;
                end
            end
        end
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
    then
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and not ally:HasModifier("modifier_techies_reactive_tazer") and ally:GetHealth() / ally:GetMaxHealth() <= 0.8
                then
                    local enemyAbility = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                    if ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(5.0) or
                        ally:WasRecentlyDamagedByTower(2.0) or
                        (#enemyAbility > 0)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Reactive Tazer на союзника!", true);
                        return BOT_MODE_DESIRE_HIGH, ally, "target";
                    end
                end
            end
        end
    end
end

function ConsiderDetonateTazer()
    local ability = DetonateTazer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ReactiveTazer:GetSpecialValueInt("stun_radius");
    local allyHeroes = GetUnitList(UNIT_LIST_ALLIED_HEROES);

    -- Use if around ally has enemy hero
    for _, ally in pairs(allyHeroes) do
        if ally:HasModifier("modifier_techies_reactive_tazer")
        then
            local enemyHeroes = ally:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            if (#enemyHeroes > 0)
            then
                for _, enemy in pairs(enemyHeroes) do
                    if utility.CanCastSpellOnTarget(ReactiveTazer, enemy) and not utility.IsDisabled(enemy)
                    then
                        return BOT_ACTION_DESIRE_HIGH;
                    end
                end
            end
        end
    end
end

function ConsiderBlastOff()
    local ability = BlastOff;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Cast if can kill somebody/interrupt cast
    if not utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, 0);
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility and (HealthPercentage >= 0.1)
        then
            --npcBot:ActionImmediate_Chat("Использую Blast Off для нападения!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, 0);
        end
    end

    -- Cast if need retreat
    if utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility and (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            --npcBot:ActionImmediate_Chat("Использую BlastOff для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end

function ConsiderMinefieldSign()
    local ability = MinefieldSign;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("aura_radius");

    if GetGameState() == GAME_STATE_PRE_GAME and not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT and npcBot:DistanceFromFountain() > 6000
    then
        --npcBot:ActionImmediate_Chat("Использую Mine field Sign до начала игры!",true);
        return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
    end

    if not npcBot:HasScepter()
    then
        if not utility.PvPMode(npcBot) and MineInRadius(radiusAbility, npcBot:GetLocation()) and
            utility.CountEnemyHeroAroundUnit(npcBot, radiusAbility) == 0 and
            utility.CountEnemyTowerAroundUnit(npcBot, 1000) == 0
        then
            --npcBot:ActionImmediate_Chat("Использую Mine field Sign рядом со своей миной!", true);
            return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
        end
    elseif npcBot:HasScepter()
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 700)
            then
                --npcBot:ActionImmediate_Chat("Использую Minefield Sign для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            end
        end

        -- Retreat use
        if utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Использую Minefield Sign для отступления!",true);
                        return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
                    end
                end
            end
        end
    end
end

local function MineInRadius(radius, location)
    local unit = GetUnitList(UNIT_LIST_ALLIED_OTHER);
    for _, creep in pairs(unit)
    do
        if creep:GetUnitName() == "npc_dota_techies_land_mine"
        then
            if GetUnitToLocationDistance(creep, location) <= radius
            then
                return true;
            end
        end
    end
    return false;
end

function ConsiderProximityMines()
    local ability = ProximityMines;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetCastRange();
    local placementRadius = ability:GetSpecialValueInt("placement_radius");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (attackRange + castRangeAbility)
                and not MineInRadius(placementRadius, botTarget:GetLocation())
            then
                --npcBot:ActionImmediate_Chat("Использую Proximity Mines для атаки по врагу!", true);
                return BOT_MODE_DESIRE_HIGH, botTarget:GetLocation();
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not MineInRadius(placementRadius, enemy:GetLocation())
                then
                    --npcBot:ActionImmediate_Chat("Использую Proximity Mines для отступления!",true);
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                end
            end
        end
    end

    -- General use
    if npcBot:DistanceFromFountain() > 1000 and not MineInRadius(placementRadius, npcBot:GetLocation())
    then
        --npcBot:ActionImmediate_Chat("Использую Proximity Mines для минирования!", true);
        return BOT_MODE_DESIRE_LOW, npcBot:GetLocation() + RandomVector(castRangeAbility);
    end
end
