---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_retreat_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

local function IsEnemiesStronger()
    local allyPower = 0;
    local enemyPower = 0;
    local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if (#enemyHeroAround > 0)
    then
        for _, enemy in pairs(enemyHeroAround) do
            if utility.IsValidTarget(enemy)
            then
                local enemyOffensivePower = enemy:GetRawOffensivePower();
                enemyPower = enemyPower + enemyOffensivePower;
            end
        end
    end

    if (#allyHeroAround > 0)
    then
        for _, ally in pairs(allyHeroAround) do
            local allyOffensivePower = ally:GetOffensivePower();
            allyPower = allyPower + allyOffensivePower;
        end
    end

    if enemyPower > allyPower
    then
        return true;
    else
        return false;
    end
end

function GetDesire()
    if not npcBot:IsAlive() or utility.IsBusy(npcBot) or utility.IsClone(npcBot) or
        npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter") or
        npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    --local botMode = npcBot:GetActiveMode();
    --local allyHeroes = utility.CountAllyHeroAroundUnit(npcBot, 2000);
    --local enemyHeroes = utility.CountEnemyHeroAroundUnit(npcBot, 2000);
    local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not utility.CanMove(npcBot) or npcBot:HasModifier("modifier_fountain_invulnerability")
    then
        return BOT_ACTION_DESIRE_ABSOLUTE;
    end

    if (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.4) or (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6 and npcBot:DistanceFromFountain() <= 3000)
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    if string.find(npcBot:GetUnitName(), "medusa") or npcBot:HasModifier("modifier_medusa_mana_shield")
    then
        if (npcBot:GetMana() / npcBot:GetMaxMana() <= 0.3) and (#enemyHeroAround > 0) and npcBot:WasRecentlyDamagedByAnyHero(5.0)
        then
            return BOT_ACTION_DESIRE_VERYHIGH;
        end
    end

    if npcBot:HasModifier("modifier_fountain_aura_buff") and (#enemyHeroAround <= 0) and (npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.8
            or npcBot:GetMana() / npcBot:GetMaxMana() <= 0.8)
    then
        return BOT_ACTION_DESIRE_HIGH;
    end

    if (#enemyHeroAround > #allyHeroAround + 1) and IsEnemiesStronger()
    then
        --npcBot:ActionImmediate_Chat("Враги сильнее, нужно отступить!", true);
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    if (#allyHeroAround <= 1 and #enemyHeroAround > 1) and IsEnemiesStronger()
    then
        return BOT_ACTION_DESIRE_VERYHIGH;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Отступаю!", false);
    end
end

function OnEnd()
    --
end

function Think()
    local fountainLocation = utility.SafeLocation(npcBot);

    if utility.CanMove(npcBot)
    then
        if GetUnitToLocationDistance(npcBot, fountainLocation) >= 200
        then
            --npcBot:ActionImmediate_Chat("ОТСТУПАЮ!", true);
            npcBot:Action_MoveToLocation(fountainLocation + RandomVector(100));
            return;
        else
            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(100));
            return;
        end
    else
        npcBot:Action_AttackMove(npcBot:GetLocation());
        return;
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_retreat_generic) do _G._savedEnv[k] = v end


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
