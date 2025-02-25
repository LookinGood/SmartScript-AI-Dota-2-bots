---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/ability_item_usage_generic")
require(GetScriptDirectory() .. "/ability_levelup_generic")
require(GetScriptDirectory() .. "/spell_usage_generic")

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
    Abilities[2],
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[1],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
    Abilities[6],
    Talents[6],
    Talents[7],
    Talents[2],
    Talents[4],
    Talents[5],
    Talents[8],
}

function AbilityLevelUpThink()
    ability_levelup_generic.AbilityLevelUpThink(AbilityToLevelUp)
end

-- Abilities
local Devour = AbilitiesReal[1]
local ScorchedEarth = AbilitiesReal[2]
local InfernalBlade = AbilitiesReal[3]
local Doom = AbilitiesReal[6]

function AbilityUsageThink()
    if not utility.CanCast(npcBot) then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    local castDevourDesire, castDevourTarget = ConsiderDevour();
    local castScorchedEarthDesire = ConsiderScorchedEarth();
    local castInfernalBladeDesire, castInfernalBladeTarget = ConsiderInfernalBlade();
    local castDoomDesire, castDoomTarget = ConsiderDoom();

    if (castDevourDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Devour, castDevourTarget);
        return;
    end

    if (castScorchedEarthDesire ~= nil)
    then
        npcBot:Action_UseAbility(ScorchedEarth);
        return;
    end

    if (castInfernalBladeDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(InfernalBlade, castInfernalBladeTarget);
        return;
    end

    if (castDoomDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Doom, castDoomTarget);
        return;
    end

    local ability4 = npcBot:GetAbilityInSlot(3);
    local ability5 = npcBot:GetAbilityInSlot(4);

    spell_usage_generic.CastCustomSpell(ability4)
    spell_usage_generic.CastCustomSpell(ability5)
end

function ConsiderDevour()
    local ability = Devour;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:HasModifier("modifier_doom_bringer_devour")
    then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local creepMaxLevel = ability:GetSpecialValueInt("creep_level");

    --[[     if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end ]]

    if utility.PvPMode(npcBot) or utility.RetreatMode(npcBot) or botMode == BOT_MODE_LANING
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.7))
                    and not enemy:IsAncientCreep() and enemy:GetLevel() <= creepMaxLevel
                then
                    --npcBot:ActionImmediate_Chat("Использую devour на обычного/древнего крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    else
        local enemyCreeps = npcBot:GetNearbyNeutralCreeps(1600);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.7))
                    and not enemy:IsAncientCreep() and enemy:GetLevel() <= creepMaxLevel
                then
                    --npcBot:ActionImmediate_Chat("Использую devour на обычного/древнего нейтрального крипа!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderScorchedEarth()
    local ability = ScorchedEarth;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = ability:GetSpecialValueInt("radius");

    -- Attack use
    if utility.PvPMode(npcBot) or utility.BossMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBoss(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= (radiusAbility * 2)
            then
                --npcBot:ActionImmediate_Chat("Использую ScorchedEarth против врага!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility * 2, true, BOT_MODE_NONE);
        if (HealthPercentage <= 0.9) and (#enemyAbility > 0)
        then
            --npcBot:ActionImmediate_Chat("Использую ScorchedEarth для отступления!", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end

    if utility.PvEMode(npcBot)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(radiusAbility, true);
        if (#enemyCreeps > 2) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastSpellOnTarget(ability, enemy) and npcBot:GetAttackTarget() == enemy
                then
                    --npcBot:ActionImmediate_Chat("Использую ScorchedEarth против крипов", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderInfernalBlade()
    local ability = InfernalBlade;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if npcBot:IsDisarmed()
    then
        return;
    end

    local castRangeAbility = npcBot:GetAttackRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    if (utility.IsHero(botTarget) or utility.IsBoss(botTarget)) and utility.CanCastSpellOnTarget(ability, botTarget)
        and not utility.IsDisabled(botTarget)
    then
        if not ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    else
        if ability:GetAutoCastState() then
            ability:ToggleAutoCast()
        end
    end

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую InfernalBlade что бы сбить заклинание!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Retreat use
    if utility.RetreatMode(npcBot)
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0)
        then
            if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
            then
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end
end

function ConsiderDoom()
    local ability = Doom;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage") * ability:GetSpecialValueInt("duration");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility + 200, true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) or enemy:IsChanneling()
            then
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Doom что бы сбить заклинание или убить цель!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not botTarget:IsSilenced()
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
    end

    -- Retreat or help ally use
    if utility.RetreatMode(npcBot) or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0) and (HealthPercentage <= 0.5)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and not enemy:IsSilenced()
                then
                    --npcBot:ActionImmediate_Chat("Использую Doom что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end
