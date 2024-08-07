---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_farm_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/hero_role_generic")

local npcBot = GetBot();

function GetDesire()
    if not utility.IsHero(npcBot) or not npcBot:IsAlive() or not utility.CanMove(npcBot) or utility.IsBusy(npcBot) or utility.IsBaseUnderAttack()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local botLevel = npcBot:GetLevel();
    --local botMode = npcBot:GetActiveMode();
    local HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local neutralCreeps = npcBot:GetNearbyNeutralCreeps(1600);

    if botLevel >= 30 or (HealthPercentage < 0.5) or (#neutralCreeps == 0) or (#enemyHeroes > 0)
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes)
        do
            if ally ~= npcBot and ally:GetAttackTarget():IsCreep()
            then
                return BOT_ACTION_DESIRE_NONE;
            end
        end
    end

    if hero_role_generic.HaveCarryInTeam(npcBot)
    then
        if hero_role_generic.IsHeroCarry(npcBot)
        then
            if (#neutralCreeps > 0)
            then
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:CanBeSeen() and creep:IsAlive()
                    then
                        if botLevel >= 6 and botLevel < 15
                        then
                            if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                            then
                                return BOT_ACTION_DESIRE_MODERATE;
                            end
                        elseif botLevel >= 15
                        then
                            return BOT_ACTION_DESIRE_MODERATE;
                        end
                    end
                end
            end
        else
            if (#neutralCreeps > 0)
            then
                if (#allyHeroes > 1)
                then
                    for _, ally in pairs(allyHeroes)
                    do
                        if ally ~= npcBot and hero_role_generic.IsHeroCarry(ally) and ally:GetAttackTarget():IsCreep()
                        then
                            return BOT_ACTION_DESIRE_MODERATE;
                        end
                    end
                end
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:CanBeSeen() and creep:IsAlive()
                    then
                        if botLevel >= 6 and botLevel < 15
                        then
                            if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                            then
                                return BOT_ACTION_DESIRE_MODERATE;
                            end
                        elseif botLevel >= 15
                        then
                            return BOT_ACTION_DESIRE_MODERATE;
                        end
                    end
                end
            end
        end
    else
        if (#neutralCreeps > 0)
        then
            for _, creep in pairs(neutralCreeps)
            do
                if creep:CanBeSeen() and creep:IsAlive()
                then
                    if botLevel >= 10 and botLevel < 15
                    then
                        if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                        then
                            return BOT_ACTION_DESIRE_MODERATE;
                        end
                    elseif botLevel >= 15
                    then
                        return BOT_ACTION_DESIRE_MODERATE;
                    end
                end
            end
        end
    end

    return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Иду фармить в лес", false);
    end
end

function OnEnd()
    --
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    local attackRange = npcBot:GetAttackRange();
    local neutralCreeps = npcBot:GetNearbyNeutralCreeps(1600);

    if (#neutralCreeps > 0)
    then
        mainCreep = utility.GetWeakest(neutralCreeps);
    end

    if mainCreep ~= nil
    then
        if GetUnitToUnitDistance(npcBot, mainCreep) > attackRange
        then
            --npcBot:ActionImmediate_Chat("Иду фармить лесных крипов!", true);
            npcBot:Action_MoveToLocation(mainCreep:GetLocation());
            return;
        else
            --npcBot:ActionImmediate_Chat("Фармлю лесных крипов!", true);
            npcBot:Action_AttackUnit(mainCreep, false);
            return;
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_farm_generic) do _G._savedEnv[k] = v end
