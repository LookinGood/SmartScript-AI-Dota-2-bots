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
    Talents[2],
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

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    ShadowStrike = AbilitiesReal[1]
    Blink = AbilitiesReal[2]
    ScreamOfPain = AbilitiesReal[3]
    SonicWave = AbilitiesReal[6]

    castShadowStrikeDesire, castShadowStrikeTarget, castShadowStrikeTargetType = ConsiderShadowStrike();
    castBlinkDesire, castBlinkLocation = ConsiderBlink();
    castScreamOfPainDesire = ConsiderScreamOfPain();
    castSonicWaveDesire, castSonicWaveLocation = ConsiderSonicWave();

    if (castShadowStrikeDesire ~= nil)
    then
        if (castShadowStrikeTargetType == "target")
        then
            npcBot:Action_UseAbilityOnEntity(ShadowStrike, castShadowStrikeTarget);
            return;
        elseif (castShadowStrikeTargetType == "location")
        then
            npcBot:Action_UseAbilityOnLocation(ShadowStrike, castShadowStrikeTarget);
            return;
        end
    end

    if (castBlinkDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Blink, castBlinkLocation);
        return;
    end

    if (castScreamOfPainDesire ~= nil)
    then
        npcBot:Action_UseAbility(ScreamOfPain);
        return;
    end

    if (castSonicWaveDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(SonicWave, castSonicWaveLocation);
        return;
    end
end

function ConsiderShadowStrike()
    local ability = ShadowStrike;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = (ability:GetSpecialValueInt("aoe_radius"));
    local damageAbility = (ability:GetSpecialValueInt("duration_damage") * ability:GetSpecialValueInt("duration")) +
        ability:GetSpecialValueInt("strike_damage");
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                then
                    if not npcBot:HasScepter() and utility.SafeCast(enemy, true)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для убийства без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для убийства с аганимом!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), "location";
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            then
                if not npcBot:HasScepter() and utility.SafeCast(botTarget, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowStrike для нападения без аганима!", true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif npcBot:HasScepter()
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowStrike для нападения с аганимом!",true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation(), "location";
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для отступления без аганима!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        npcBot:ActionImmediate_Chat("Использую ShadowStrike для отступления с аганимом!",
                            true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), "location";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if npcBot:HasScepter() and (ManaPercentage >= 0.6)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
                radiusAbility,
                0, 0);
            if (locationAoE.count >= 2)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowStrike по вражеским крипам!",true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.7)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для лайнинга без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для лайнинга с аганимом!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation(), "location";
                    end
                end
            end
        end
    end
end

function ConsiderBlink()
    local ability = Blink;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local castRangeAbility = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetSpecialValueInt("shard_aoe");

    -- Cast if get incoming spell
    local incomingSpells = npcBot:GetIncomingTrackingProjectiles();
    if (#incomingSpells > 0)
    then
        for _, spell in pairs(incomingSpells)
        do
            if GetUnitToLocationDistance(npcBot, spell.location) <= 700 and spell.is_attack == false and spell.is_dodgeable == true
            then
                --npcBot:ActionImmediate_Chat("Использую Blink для уклонения от снарядов!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
            end
        end
    end

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and botTarget:CanBeSeen()
        then
            if GetUnitToUnitDistance(npcBot, botTarget) > (attackRange * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую Blink для нападения!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
            else
                --npcBot:ActionImmediate_Chat("Использую Blink для скачков вокруг врага!", true);
                return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation() + RandomVector(radiusAbility);
            end
        end
        -- Cast if need retreat
    elseif botMode == BOT_MODE_RETREAT and npcBot:DistanceFromFountain() >= castRangeAbility
    then
        --npcBot:ActionImmediate_Chat("Использую Blink для отступления!", true);
        return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetEscapeLocation(npcBot, castRangeAbility);
    end
end

function ConsiderScreamOfPain()
    local ability = ScreamOfPain;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("area_of_effect");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) and not utility.TargetCantDie(enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ScreamOfPain для нападения/отступления!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot) and (ManaPercentage >= 0.6)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ScreamOfPain против крипов",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderSonicWave()
    local ability = SonicWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    --local radiusAbility = (ability:GetSpecialValueInt("final_aoe"));
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE)

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnInvulnerableTarget(enemy) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_PURE)
                and not utility.TargetCantDie(enemy)
            then
                --npcBot:ActionImmediate_Chat("Использую SonicWave что бы добить врага!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Sonic Wave по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if (utility.CanCastOnInvulnerableTarget(enemy))
                then
                    --npcBot:ActionImmediate_Chat("Использую SonicWave что бы оторваться!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
    end
end
