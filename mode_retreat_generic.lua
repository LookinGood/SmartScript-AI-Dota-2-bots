---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_retreat_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

function GetDesire()
    local npcBot = GetBot();
    local allyHeroes = utility.CountAllyHeroAroundUnit(npcBot, 2000);
    local enemyHeroes = utility.CountEnemyHeroAroundUnit(npcBot, 2000);
    --local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not npcBot:IsAlive() or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter")
        or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if not utility.CanMove(npcBot) or npcBot:HasModifier("modifier_fountain_invulnerability")
    then
        return BOT_ACTION_DESIRE_ABSOLUTE;
    end

    if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4) or (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6 and npcBot:DistanceFromFountain() <= 3000)
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    if string.find(npcBot:GetUnitName(), "medusa")
    then
        if (npcBot:GetMana() / npcBot:GetMaxMana() <= 0.2) and (#enemyHeroAround > 0) and npcBot:WasRecentlyDamagedByAnyHero(2.0)
        then
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end

    if npcBot:HasModifier("modifier_fountain_aura_buff") and (enemyHeroes <= 0) and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8
            or npcBot:GetMana() / npcBot:GetMaxMana() <= 0.8)
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    if enemyHeroes > allyHeroes
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    -- and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9 and npcBot:WasRecentlyDamagedByAnyHero(2.0)

    if (allyHeroes <= 1 and enemyHeroes > 1)
    then
        return BOT_ACTION_DESIRE_ABSOLUTE;
    end

    if (#enemyHeroAround > 0)
    then
        for _, enemy in pairs(enemyHeroAround) do
            local allyHero = enemy:GetAttackTarget();
            if utility.IsHero(allyHero) and not utility.IsHero(allyHero:GetAttackTarget())
                and allyHero:GetHealth() / allyHero:GetMaxHealth() <= 0.9
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
                and not utility.IsHero(npcBot)
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    if (#enemyHeroAround > 0)
    then
        for _, enemy in pairs(enemyHeroAround) do
            local enemyDamageToMe = enemy:GetEstimatedDamageToTarget(false, npcBot, 3.0, DAMAGE_TYPE_ALL);
            if enemyDamageToMe >= npcBot:GetHealth() / 2 and allyHeroes <= 1
            then
                --npcBot:ActionImmediate_Chat("Меня могут убить! Я убегаю!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function Think()
    local npcBot = GetBot();
    local fountainLocation = utility.SafeLocation(npcBot);

    if utility.CanMove(npcBot)
    then
        if GetUnitToLocationDistance(npcBot, fountainLocation) >= 200
        then
            --npcBot:ActionImmediate_Chat("ОТСТУПАЮ!", true);
            npcBot:Action_MoveToLocation(fountainLocation + RandomVector(100));
        else
            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
            --npcBot:Action_ClearActions(true);
        end
    else
        npcBot:Action_AttackMove(npcBot:GetLocation());
        --npcBot:Action_ClearActions(true);
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_retreat_generic) do _G._savedEnv[k] = v end
