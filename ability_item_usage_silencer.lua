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
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[3],
    Abilities[1],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[2],
    Abilities[2],
    Talents[3],
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

    ArcaneCurse = AbilitiesReal[1]
    GlaivesOfWisdom = AbilitiesReal[2]
    LastWord = AbilitiesReal[3]
    GlobalSilence = AbilitiesReal[6]


    castArcaneCurseDesire, castArcaneCurseLocation = ConsiderArcaneCurse();
    ConsiderGlaivesOfWisdom();
    castLastWordDesire, castLastWordTarget, castLastWordTargetType = ConsiderLastWord();
    castGlobalSilenceDesire = ConsiderGlobalSilence();

    if (castArcaneCurseDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(ArcaneCurse, castArcaneCurseLocation);
        return;
    end

    if (castLastWordDesire ~= nil)
    then
        if (castLastWordTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(LastWord, castLastWordTarget);
            return;
        elseif (castLastWordTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(LastWord, castLastWordTarget);
            return;
        end
    end

    if (castGlobalSilenceDesire ~= nil)
    then
        npcBot:Action_UseAbility(GlobalSilence);
        return;
    end
end

function ConsiderArcaneCurse()
    local ability = ArcaneCurse;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen() and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen()
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcaneCurse для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
            radiusAbility,
            0, 0);
        if (locationAoE.count >= 3)
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse по вражеским крипам!", true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING and (ManaPercentage >= 0.7)
    then
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility,
            radiusAbility, 0, 0);
        if (locationAoE.count > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse по героям врага на линии!",true);
            return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc;
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN and (ManaPercentage >= 0.4)
    then
        local botTarget = npcBot:GetAttackTarget();
        if botTarget ~= nil and botTarget:CanBeSeen() and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse на рошана!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
    end
end

function ConsiderGlaivesOfWisdom()
    local ability = GlaivesOfWisdom;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if attackTarget ~= nil and utility.CanCastOnInvulnerableTarget(attackTarget)
    then
        if utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)
        then
            if not ability:GetAutoCastState() then
                ability:ToggleAutoCast()
            end
        else
            if ability:GetAutoCastState() then
                ability:ToggleAutoCast()
            end
        end
    end
end

function ConsiderLastWord()
    local ability = LastWord;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("scepter_radius"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget)
            and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200) and utility.SafeCast(botTarget, true)
        then
            if not npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую LastWord для нападения без аганима!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
            elseif npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую LastWord для нападения с аганимом!",true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if not npcBot:HasScepter() and utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для отступления без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для отступления с аганимом!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), "location";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if npcBot:HasScepter() and (ManaPercentage >= 0.8)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
                radiusAbility,
                0, 0);
            if (locationAoE.count >= 2)
            then
                --npcBot:ActionImmediate_Chat("Использую LastWord по вражеским крипам!", true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
            end
        end
        -- Roshan
    elseif botMode == BOT_MODE_ROSHAN and (ManaPercentage >= 0.4)
    then
        if botTarget ~= nil and botTarget:CanBeSeen() and utility.IsRoshan(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            if not npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую LastWord на рошана без аганима!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
            elseif npcBot:HasScepter()
            then
                --npcBot:ActionImmediate_Chat("Использую LastWord на рошана с аганимом!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
            end
        end
    end
end

function ConsiderGlobalSilence()
    local ability = GlobalSilence;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Use in teamfight
    if utility.PvPMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        if (#enemyAbility >= 2)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:CanBeSeen() and not enemy:IsSilenced()
                then
                    --npcBot:ActionImmediate_Chat("Использую GlobalSilence!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
