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
local npcBot = GetBot();

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
    Abilities[2],
    Abilities[1],
    Abilities[3],
    Abilities[2],
    Abilities[2],
    Abilities[6],
    Abilities[2],
    Abilities[1],
    Abilities[1],
    Talents[2],
    Abilities[1],
    Abilities[6],
    Abilities[3],
    Abilities[3],
    Talents[3],
    Abilities[3],
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

    ArcLightning = AbilitiesReal[1]
    LightningBolt = AbilitiesReal[2]
    HeavenlyJump = AbilitiesReal[3]
    Nimbus = AbilitiesReal[4]
    LightningHands = AbilitiesReal[5]
    ThundergodWrath = AbilitiesReal[6]

    castArcLightningDesire, castArcLightningTarget = ConsiderArcLightning();
    castLightningBoltDesire, castLightningBoltLocation = ConsiderLightningBolt();
    castHeavenlyJumpDesire = ConsiderHeavenlyJump();
    castNimbusDesire, castNimbusLocation = ConsiderNimbus();
    ConsiderLightningHands();
    castThundergodWrathDesire = ConsiderThundergodWrath();

    if (castArcLightningDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnEntity(ArcLightning, castArcLightningTarget);
        return;
    end

    if (castLightningBoltDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(LightningBolt, castLightningBoltLocation);
        return;
    end

    if (castHeavenlyJumpDesire ~= nil)
    then
        npcBot:Action_UseAbility(HeavenlyJump);
        return;
    end

    if (castNimbusDesire ~= nil)
    then
        npcBot:Action_UseAbilityOnLocation(Nimbus, castNimbusLocation);
        return;
    end

    if (castThundergodWrathDesire ~= nil)
    then
        npcBot:Action_UseAbility(ThundergodWrath);
        return;
    end
end

function ConsiderArcLightning()
    local ability = ArcLightning;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = (ability:GetSpecialValueInt("arc_damage"));
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                and utility.SafeCast(enemy, true)
            then
                --npcBot:ActionImmediate_Chat("Использую ArcLightning что бы добить врага!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy;
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and utility.SafeCast(botTarget, true)
        then
            --npcBot:ActionImmediate_Chat("Использую ArcLightning по врагу в радиусе действия!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Last hit
    elseif not utility.PvPMode(npcBot) and botMode ~= BOT_MODE_RETREAT and (ManaPercentage >= 0.4)
    then
        local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);
        if (#enemyCreeps > 0)
        then
            for _, enemy in pairs(enemyCreeps) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetActualIncomingDamage(damageAbility, DAMAGE_TYPE_MAGICAL) >= enemy:GetHealth())
                then
                    --npcBot:ActionImmediate_Chat("Использую ArcLightning что бы добить крипа!",true);
                    return BOT_ACTION_DESIRE_LOW, enemy;
                end
            end
        end
        -- Cast when laning
    elseif botMode == BOT_MODE_LANING
    then
        if (#enemyAbility > 0) and (ManaPercentage >= 0.6)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and utility.SafeCast(enemy, true)
                then
                    npcBot:ActionImmediate_Chat("Использую ArcLightning для лайнинга!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderLightningBolt()
    local ability = LightningBolt;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes((castRangeAbility + 200), true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy) and utility.CanAbilityKillTarget(enemy, damageAbility, DAMAGE_TYPE_MAGICAL)
                and utility.SafeCast(enemy, true)
            then
                --npcBot:ActionImmediate_Chat("Использую LightningBolt что бы добить врага!", true);
                return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую LightningBolt по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
    end
    -- Interrupt cast/Detect invisible
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if enemy:IsChanneling() or enemy:IsInvisible()
                then
                    --npcBot:ActionImmediate_Chat("Использую LightningBolt что бы сбить заклинание цели/Или по невидимому врагу!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderHeavenlyJump()
    local ability = HeavenlyJump;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = (ability:GetSpecialValueInt("range"));

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and npcBot:IsFacingLocation(botTarget:GetLocation(), 10)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH;
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and npcBot:IsFacingLocation(utility.SafeLocation(npcBot), 40)
        then
            --npcBot:ActionImmediate_Chat("Использую HeavenlyJump для отступления", true);
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderNimbus()
    local ability = Nimbus;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = (ability:GetSpecialValueInt("cloud_radius") * 10);
    local radiusAbility = (ability:GetSpecialValueInt("cloud_radius"));
    local damageAbility = LightningBolt:GetAbilityDamage();
    local enemyAbility = (GetUnitList(UNIT_LIST_ENEMY_HEROES));

    -- Cast if can kill somebody
    for i = 1, #enemyAbility do
        if enemyAbility[i] ~= nil and utility.CanCastOnMagicImmuneTarget(enemyAbility[i]) and
            utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, DAMAGE_TYPE_MAGICAL)
        then
            --npcBot:ActionImmediate_Chat("Использую Nimbus что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE, enemyAbility[i]:GetLocation();
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if botTarget ~= nil and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую Nimbus по врагу в радиусе действия!",true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
        -- Retreat use
    elseif botMode == BOT_MODE_RETREAT
    then
        local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
        if (#enemyAbility > 0) and (HealthPercentage <= 0.7) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy)
                then
                    --npcBot:ActionImmediate_Chat("Использую Nimbus что бы оторваться от врага!",true);
                    return BOT_ACTION_DESIRE_HIGH, enemy:GetLocation();
                end
            end
        end
        -- Pushing/defending
    elseif utility.PvEMode(npcBot)
    then
        local enemyTower = npcBot:GetNearbyTowers(castRangeAbility, true);
        local frendlyTower = npcBot:GetNearbyTowers(castRangeAbility, false);
        if (#enemyTower > 0)
        then
            for _, enemy in pairs(enemyTower) do
                local enemyHeroAroundTower = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyHeroAroundTower > 0)
                then
                    npcBot:ActionImmediate_Chat("Использую Nimbus под вражескую башню!", true);
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                end
            end
        elseif (#frendlyTower > 0)
        then
            for _, enemy in pairs(frendlyTower) do
                local enemyHeroAroundTower = enemy:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);
                if (#enemyHeroAroundTower > 0)
                then
                    npcBot:ActionImmediate_Chat("Использую Nimbus под союзную башню!", true);
                    return BOT_MODE_DESIRE_LOW, enemy:GetLocation();
                end
            end
        end
    end
end

function ConsiderLightningHands()
    local ability = LightningHands;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end
end

function ConsiderThundergodWrath()
    local ability = ThundergodWrath;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);

    -- Generic use if can kill enemy hero
    for i = 1, #enemyAbility do
        if enemyAbility[i] ~= nil and utility.CanCastOnMagicImmuneTarget(enemyAbility[i]) and not utility.TargetCantDie(enemyAbility[i]) and
            utility.CanAbilityKillTarget(enemyAbility[i], damageAbility, DAMAGE_TYPE_MAGICAL)
        then
            --npcBot:ActionImmediate_Chat("Использую ThundergodWrath что бы добить врага!", true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
    end
end
