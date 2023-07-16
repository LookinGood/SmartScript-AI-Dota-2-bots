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
local Talents = {}
local Abilities = {}
local npcBot = GetBot()

for i = 0, 23, 1 do
    local ability = npcBot:GetAbilityInSlot(i)
    if (ability ~= nil)
    then
        if (ability:IsTalent() == true)
        then
            table.insert(Talents, ability:GetName())
        else
            table.insert(Abilities, ability:GetName())
        end
    end
end

local AbilitiesReal =
{
    npcBot:GetAbilityByName(Abilities[1]),
    npcBot:GetAbilityByName(Abilities[2]),
    npcBot:GetAbilityByName(Abilities[3]),
    npcBot:GetAbilityByName(Abilities[4]),
    npcBot:GetAbilityByName(Abilities[5]),
    npcBot:GetAbilityByName(Abilities[6]),
}

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
    Talents[5],
    Talents[8],
}


function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    StickyBomb = AbilitiesReal[1]
    ReactiveTazer = AbilitiesReal[2]
    BlastOff = AbilitiesReal[3]
    MinefieldSign = AbilitiesReal[5]
    ProximityMines = AbilitiesReal[6]

    castStickyBombDesire, castStickyBombLocation = ConsiderStickyBomb();
    castReactiveTazerDesire = ConsiderReactiveTazer();
    castBlastOffDesire, castBlastOffLocation = ConsiderBlastOff();
    castMinefieldSignDesire, castMinefieldSignLocation = ConsiderMinefieldSign();
    castProximityMinesDesire, castProximityMinesLocation = ConsiderProximityMines();

    if (castStickyBombDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(StickyBomb, castStickyBombLocation);
        return;
    end

    if (castReactiveTazerDesire ~= nil)
    then
        npcBot:Action_UseAbility(ReactiveTazer);
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
    local radiusAbility = (ability:GetSpecialValueInt("radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnMagicImmuneTarget(botTarget)) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую StickyBomb для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую StickyBomb для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую StickyBomb по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.8)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую StickyBomb для лайнинга!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN and (ManaPercentage >= 0.4)
    then
        if botTarget ~= nil and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Sticky Bomb на Рошана!", true);
            return BOT_MODE_DESIRE_MODERATE, botTarget:GetLocation();
        end
    end
end

function ConsiderReactiveTazer()
    local ability = ReactiveTazer;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = (ability:GetSpecialValueInt("stun_radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую Reactive Tazer для нападения!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT and (HealthPercentage <= 0.8) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        --npcBot:ActionImmediate_Chat("Использую Reactive Tazer для отступления!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderBlastOff()
    local ability = BlastOff;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end
    local castRangeAbility = ability:GetCastRange();

    -- Attack use
    if utility.PvPMode(npcBot) and (HealthPercentage >= 0.1)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Blast Off для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Cast if need retreat
    elseif botMode == BOT_MODE_RETREAT and npcBot:DistanceFromFountain() >= castRangeAbility and (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
    then
        --npcBot:ActionImmediate_Chat("Использую BlastOff для отступления!", true);
        return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
        -- Interrupt cast
    elseif botMode ~= BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую Blast Off что бы сбить каст!", true);
                    return BOT_MODE_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderMinefieldSign()
    local ability = MinefieldSign;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("aura_radius"));

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
            if botTarget ~= nil and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 700)
            then
                --npcBot:ActionImmediate_Chat("Использую Minefield Sign для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            end
        end
        -- Retreat or help ally use
        if botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
        then
            local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy))
                    then
                        --npcBot:ActionImmediate_Chat("Использую Minefield Sign для отступления!",true);
                        return BOT_ACTION_DESIRE_HIGH, npcBot:GetLocation();
                    end
                end
            end
        end
    end
end

function MineInRadius(radius, location)
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

    local castRangeAbility = ability:GetCastRange();
    local placementRadius = (ability:GetSpecialValueInt("placement_radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.CanCastOnMagicImmuneAndInvulnerableTarget(botTarget)) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not MineInRadius(placementRadius, botTarget:GetLocation())
        then
            --npcBot:ActionImmediate_Chat("Использую Proximity Mines для атаки по врагу!", true);
            return BOT_MODE_DESIRE_LOW, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnMagicImmuneAndInvulnerableTarget(enemy)) and not MineInRadius(placementRadius, enemy:GetLocation())
                then
                    --npcBot:ActionImmediate_Chat("Использую Proximity Mines для отступления!",true);
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                end
            end
        end
    else
        -- General use
        if npcBot:DistanceFromFountain() > 1000 and not MineInRadius(placementRadius, npcBot:GetLocation())
        then
            --npcBot:ActionImmediate_Chat("Использую Proximity Mines для минирования!", true);
            return BOT_MODE_DESIRE_LOW, npcBot:GetLocation();
        end
    end
end