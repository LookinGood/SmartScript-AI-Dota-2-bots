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
    Abilities[3],
    Abilities[3],
    Talents[2],
    Abilities[3],
    Abilities[6],
    Abilities[1],
    Abilities[1],
    Talents[4],
    Abilities[1],
    Abilities[6],
    Talents[6],
    Talents[8],
    Talents[1],
    Talents[3],
    Talents[5],
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ShadowStrike = AbilitiesReal[1]
local Blink = AbilitiesReal[2]
local ScreamOfPain = AbilitiesReal[3]
local SonicWave = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castShadowStrikeDesire, castShadowStrikeTarget, castShadowStrikeTargetType = ConsiderShadowStrike();
    local castBlinkDesire, castBlinkLocation = ConsiderBlink();
    local castScreamOfPainDesire = ConsiderScreamOfPain();
    local castSonicWaveDesire, castSonicWaveLocation = ConsiderSonicWave();

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
    local radiusAbility = ability:GetSpecialValueInt("aoe_radius");
    local damageAbility = (ability:GetSpecialValueInt("duration_damage") * ability:GetSpecialValueInt("duration")) +
        ability:GetSpecialValueInt("strike_damage");
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
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для убийства без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для убийства с аганимом!",true);
                        return BOT_ACTION_DESIRE_VERYHIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
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
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowStrike для нападения без аганима!", true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    --npcBot:ActionImmediate_Chat("Использую ShadowStrike для нападения с аганимом!",true);
                    return BOT_ACTION_DESIRE_HIGH,
                        utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility), "location";
                end
            end
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                    then
                        --npcBot:ActionImmediate_Chat("Использую ShadowStrike для отступления без аганима!",true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                    then
                        npcBot:ActionImmediate_Chat("Использую ShadowStrike для отступления с аганимом!",
                            true);
                        return BOT_ACTION_DESIRE_HIGH,
                            utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility), "location";
                    end
                end
            end
        end
        -- Cast if push/defend/farm
    elseif utility.PvEMode(npcBot)
    then
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
        then
            local locationAoE = npcBot:FindAoELocation(true, false, npcBot:GetLocation(), castRangeAbility,
                radiusAbility,
                0, 0);
            if locationAoE ~= nil and (ManaPercentage >= 0.6) and (locationAoE.count >= 2)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowStrike по вражеским крипам!",true);
                return BOT_ACTION_DESIRE_LOW, locationAoE.targetloc, "location";
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7)
        then
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowStrike для лайнинга без аганима!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy, "target";
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                --npcBot:ActionImmediate_Chat("Использую ShadowStrike для лайнинга с аганимом!", true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility),
                    "location";
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
            if not utility.IsAlly(npcBot, spell.caster) and GetUnitToLocationDistance(npcBot, spell.location) <= 700 and spell.is_attack == false
                and spell.is_dodgeable == true
            then
                --npcBot:ActionImmediate_Chat("Использую Blink для уклонения от снарядов!",true);
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
            end
        end
    end

    -- Cast if enemy hero too far away
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
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
    elseif utility.RetreatMode(npcBot)
    then
        if npcBot:DistanceFromFountain() >= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Blink для отступления!", true);
            return BOT_ACTION_DESIRE_ABSOLUTE, utility.GetEscapeLocation(npcBot, castRangeAbility);
        end
    end
end

function ConsiderScreamOfPain()
    local ability = ScreamOfPain;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetAOERadius();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ScreamOfPain для нападения/отступления!",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    elseif utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую ScreamOfPain против крипов",true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end

    -- Boss use
    if utility.IsBoss(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
    then
        --npcBot:ActionImmediate_Chat("Использую ScreamOfPain против Рошана!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderSonicWave()
    local ability = SonicWave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("final_aoe");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("tick_rate");
    local speedAbility = ability:GetSpecialValueInt("speed");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE)

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
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and
            GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Sonic Wave по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_VERYHIGH,
                utility.GetTargetCastPosition(npcBot, botTarget, delayAbility, speedAbility);
        end
        -- Cast if enemy >=2
        local locationAoE = npcBot:FindAoELocation(true, true, npcBot:GetLocation(), castRangeAbility, radiusAbility, 0,
            0);
        if locationAoE ~= nil and (locationAoE.count >= 2)
        then
            --npcBot:ActionImmediate_Chat("Использую SonicWave по врагам!", true);
            return BOT_ACTION_DESIRE_HIGH, locationAoE.targetloc;
        end
        -- Retreat use
    elseif utility.RetreatMode(npcBot)
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.6) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую SonicWave что бы оторваться!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH,
                        utility.GetTargetCastPosition(npcBot, enemy, delayAbility, speedAbility);
                end
            end
        end
    end
end
