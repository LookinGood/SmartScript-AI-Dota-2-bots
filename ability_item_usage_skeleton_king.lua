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
    Abilities[3],
    Abilities[2],
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

    WraithfireBlast = AbilitiesReal[1]
    VampiricSpirit = AbilitiesReal[2]
    Reincarnation = AbilitiesReal[6]

    castWraithfireBlastDesire, castWraithfireBlastTarget = ConsiderWraithfireBlast();
    castVampiricSpiritDesire = ConsiderVampiricSpirit();
    castReincarnationDesire, castReincarnationTarget = ConsiderReincarnation();

    if (castWraithfireBlastDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(WraithfireBlast, castWraithfireBlastTarget);
        return;
    end

    if (castVampiricSpiritDesire ~= nil)
    then
        npcBot:Action_UseAbility(VampiricSpirit);
        return;
    end

    if (castReincarnationDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(Reincarnation, castReincarnationTarget);
        return;
    end
end

function ConsiderWraithfireBlast()
    local ability = WraithfireBlast;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage() +
        (ability:GetSpecialValueInt("blast_dot_damage") * ability:GetSpecialValueInt("blast_dot_duration"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody/interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
            then
                if utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL) or enemy:IsChanneling()
                then
                    --npcBot:ActionImmediate_Chat("Использую WraithfireBlast что бы сбить заклинание или убить цель!",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
    then
        if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
        then
            if utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                and not utility.IsDisabled(botTarget) and utility.SafeCast(botTarget, true)
            then
                return BOT_MODE_DESIRE_HIGH, botTarget;
            end
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy) and utility.SafeCast(enemy, true)
                then
                    --npcBot:ActionImmediate_Chat("Использую WraithfireBlast что бы оторваться от врага",true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderVampiricSpirit()
    local ability = VampiricSpirit;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local abilityCount = ability:GetSpecialValueInt("max_skeleton_charges");
    local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if utility.GetModifierCount(npcBot, "modifier_skeleton_king_vampiric_aura") >= abilityCount / 2
    then
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if botTarget ~= nil and (utility.IsHero(botTarget) or utility.IsRoshan(botTarget))
            then
                if utility.CanCastOnInvulnerableTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange() * 2
                then
                    --npcBot:ActionImmediate_Chat("Использую VampiricSpirit для атаки врага!", true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
            -- Retreat or help ally use
        elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastOnInvulnerableTarget(enemy)
                    then
                       -- npcBot:ActionImmediate_Chat("Использую VampiricSpirit что бы оторваться от врага", true);
                        return BOT_ACTION_DESIRE_VERYHIGH;
                    end
                end
            end
            -- Cast if push/defend/farm
        elseif utility.PvEMode(npcBot)
        then
            if (ManaPercentage >= 0.6)
            then
                local enemyCreeps = npcBot:GetNearbyLaneCreeps(1600, true);
                local enemyBuilding = GetUnitList(UNIT_LIST_ENEMY_BUILDINGS);
                if #enemyCreeps >= 5
                then
                    --npcBot:ActionImmediate_Chat("Использую VampiricSpirit против КРИПОВ!", true);
                    return BOT_ACTION_DESIRE_MODERATE;
                end
                if #enemyBuilding > 0
                then
                    for _, enemy in pairs(enemyBuilding) do
                        if not enemy:IsInvulnerable() and GetUnitToUnitDistance(npcBot, enemy) <= 2000
                        then
                            if enemy:IsTower() or enemy:IsBarracks() or enemy:IsAncient()
                            then
                                --npcBot:ActionImmediate_Chat("Использую VampiricSpirit против зданий!", true);
                                return BOT_ACTION_DESIRE_MODERATE;
                            end
                        end
                    end
                end
            end
        end
    end
end

function ConsiderReincarnation()
    local ability = Reincarnation;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local radiusAbility = (ability:GetSpecialValueInt("slow_radius"));
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    if not utility.TargetCantDie(npcBot)
    then
        if npcBot:GetHealth() <= 50 and #enemyAbility > 0 and npcBot:WasRecentlyDamagedByAnyHero(5.0)
        then
            --npcBot:ActionImmediate_Chat("Использую Reincarnation для суицида!", true);
            return BOT_ACTION_DESIRE_VERYLOW, npcBot;
        end
    end
end
