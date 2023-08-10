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
    Talents[7],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local ArcaneCurse = AbilitiesReal[1]
local GlaivesOfWisdom = AbilitiesReal[2]
local LastWord = AbilitiesReal[3]
local GlobalSilence = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castArcaneCurseDesire, castArcaneCurseLocation = ConsiderArcaneCurse();
    ConsiderGlaivesOfWisdom();
    local castLastWordDesire, castLastWordTarget, castLastWordTargetType = ConsiderLastWord();
    local castGlobalSilenceDesire = ConsiderGlobalSilence();

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
    local radiusAbility = ability:GetSpecialValueInt("radius");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
            and not botTarget:HasModifier("modifier_silencer_curse_of_the_silent")
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility);
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_silencer_curse_of_the_silent")
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcaneCurse для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility);
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
        local enemy = utility.GetWeakest(enemyAbility);
        if utility.CanCastSpellOnTarget(ability, enemy) and (ManaPercentage >= 0.7) and not enemy:HasModifier("modifier_silencer_curse_of_the_silent")
        then
            --npcBot:ActionImmediate_Chat("Использую ArcaneCurse по цели на ЛАЙНЕ!", true);
            return BOT_ACTION_DESIRE_VERYHIGH, utility.GetTargetPosition(enemy, delayAbility);
        end
    end
end

function ConsiderGlaivesOfWisdom()
    local ability = GlaivesOfWisdom;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local attackTarget = npcBot:GetAttackTarget();

    if (utility.IsHero(attackTarget) or utility.IsRoshan(attackTarget)) and utility.CanCastSpellOnTarget(ability, attackTarget)
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

function ConsiderLastWord()
    local ability = LastWord;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local radiusAbility = ability:GetSpecialValueInt("scepter_radius");
    local damageAbility = ability:GetSpecialValueInt("damage");
    local delayAbility = ability:GetSpecialValueInt("AbilityCastPoint");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_silencer_last_word")
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для убийства без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для убийства с аганимом!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
                    end
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (castRangeAbility + 200)
                and not botTarget:HasModifier("modifier_silencer_last_word")
            then
                if not npcBot:HasScepter()
                then
                    --npcBot:ActionImmediate_Chat("Использую LastWord для нападения без аганима!",true);
                    return BOT_ACTION_DESIRE_HIGH, botTarget, "target";
                elseif npcBot:HasScepter()
                then
                    --npcBot:ActionImmediate_Chat("Использую LastWord для нападения с аганимом!",true);
                    return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(botTarget, delayAbility), "location";
                end
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:HasModifier("modifier_silencer_last_word")
                then
                    if not npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для отступления без аганима!", true);
                        return BOT_ACTION_DESIRE_HIGH, enemy, "target";
                    elseif npcBot:HasScepter()
                    then
                        --npcBot:ActionImmediate_Chat("Использую LastWord для отступления с аганимом!",true);
                        return BOT_ACTION_DESIRE_HIGH, utility.GetTargetPosition(enemy, delayAbility), "location";
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
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsSilenced()
                then
                    --npcBot:ActionImmediate_Chat("Использую GlobalSilence!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end
