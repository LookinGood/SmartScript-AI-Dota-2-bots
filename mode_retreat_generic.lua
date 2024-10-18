---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
    if not npcBot:IsAlive() or utility.IsClone(npcBot) or
        --npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter") or
        npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_MODE_DESIRE_NONE;
    end

    local botMode = npcBot:GetActiveMode();
    --local allyHeroes = utility.CountAllyHeroAroundUnit(npcBot, 2000);
    --local enemyHeroes = utility.CountEnemyHeroAroundUnit(npcBot, 2000);
    -- string.find(npcBot:GetUnitName(), "medusa")

    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local manaPercent = npcBot:GetMana() / npcBot:GetMaxMana();
    local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not utility.CanMove(npcBot) or
        npcBot:HasModifier("modifier_fountain_invulnerability") or
        npcBot:HasModifier("modifier_fountain_fury_swipes_damage_increase")
    then
        return BOT_MODE_DESIRE_ABSOLUTE;
    end

    if (healthPercent <= 0.4) or (healthPercent <= 0.6 and npcBot:DistanceFromFountain() <= 2000)
    then
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    if npcBot:HasModifier("modifier_medusa_mana_shield")
    then
        if (manaPercent <= 0.3) and (#enemyHeroAround > 0) and npcBot:WasRecentlyDamagedByAnyHero(5.0)
        then
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    end

    if npcBot:HasModifier("modifier_fountain_aura_buff")
    then
        if (healthPercent <= 0.8 or manaPercent <= 0.8)
        then
            return BOT_MODE_DESIRE_VERYHIGH;
        end
        if (#enemyHeroAround > #allyHeroAround + 1) and utility.IsEnemiesAroundStronger()
        then
            return BOT_MODE_DESIRE_HIGH;
        end
    end

    if botMode == BOT_MODE_LANING
    then
        if (#enemyHeroAround > #allyHeroAround) and utility.IsEnemiesAroundStronger()
        then
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    else
        if utility.IsEnemiesAroundStronger()
        then
            --npcBot:ActionImmediate_Chat("Враги сильнее, нужно отступить!", true);
            return BOT_MODE_DESIRE_VERYHIGH;
        end
    end

    if (#allyHeroAround <= 1 and #enemyHeroAround > 1) and utility.IsEnemiesAroundStronger()
    then
        return BOT_MODE_DESIRE_VERYHIGH;
    end

    if (#enemyHeroAround > 0) and utility.IsEnemiesAroundStronger()
    then
        for _, enemy in pairs(enemyHeroAround) do
            if utility.IsValidTarget(enemy) and utility.IsHero(enemy:GetAttackTarget())
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
            then
                return BOT_MODE_DESIRE_MODERATE;
            end
        end
    end

    return BOT_MODE_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Отступаю!", false);
    end
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local fountainLocation = utility.GetFountainLocation();

    if utility.CanMove(npcBot)
    then
        if GetUnitToLocationDistance(npcBot, fountainLocation) >= 200
        then
            --npcBot:ActionImmediate_Chat("ОТСТУПАЮ!", true);
            npcBot:Action_MoveToLocation(fountainLocation);
            return;
        else
            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(200));
            return;
        end
    else
        local enemyHeroAround = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);
        local enemyCreepsAround = npcBot:GetNearbyCreeps(npcBot:GetAttackRange(), true);
        if (#enemyHeroAround > 0)
        then
            for _, enemy in pairs(enemyHeroAround) do
                if utility.CanCastOnInvulnerableTarget(enemy) and not utility.IsNotAttackTarget(enemy)
                then
                    npcBot:Action_AttackUnit(enemy, true);
                    return;
                end
            end
        elseif (#enemyCreepsAround > 0)
        then
            for _, enemy in pairs(enemyCreepsAround) do
                if utility.CanCastOnInvulnerableTarget(enemy) and not utility.IsNotAttackTarget(enemy)
                then
                    npcBot:Action_AttackUnit(enemy, true);
                    return;
                end
            end
        else
            npcBot:Action_AttackMove(npcBot:GetLocation());
            return;
        end
    end
end

--botMode ~= BOT_MODE_DEFEND_TOWER_TOP and
--botMode ~= BOT_MODE_DEFEND_TOWER_MID and
--botMode ~= BOT_MODE_DEFEND_TOWER_BOT

-- and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9 and npcBot:WasRecentlyDamagedByAnyHero(2.0)

--[[     if (#enemyHeroAround > 0) and (allyHeroes + 1 < enemyHeroes)
    then
        for _, enemy in pairs(enemyHeroAround) do
            local allyHero = enemy:GetAttackTarget();
            if utility.IsHero(allyHero) and not utility.IsHero(allyHero:GetAttackTarget())
                and allyHero:GetHealth() / allyHero:GetMaxHealth() <= 0.9
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end ]]

--[[     if (#enemyHeroAround > 0) and (allyHeroes + 2 < enemyHeroes) and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6
    then
        for _, enemy in pairs(enemyHeroAround) do
            local enemyDamageToMe = enemy:GetEstimatedDamageToTarget(false, npcBot, 5.0, DAMAGE_TYPE_ALL);
            if enemyDamageToMe >= npcBot:GetMaxHealth() / 2 and allyHeroes <= 1
            then
                --npcBot:ActionImmediate_Chat("Меня могут убить! Я убегаю!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end ]]
