---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_farm_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/hero_role_generic")

function GetDesire()
    local npcBot = GetBot();
    local botLevel = npcBot:GetLevel();
    local botMode = npcBot:GetActiveMode();
    local HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    local neutralCreeps = npcBot:GetNearbyNeutralCreeps(1600);

    if not npcBot:IsAlive() or not utility.CanMove(npcBot) or botLevel >= 30 or HealthPercentage < 0.5 or
        (#neutralCreeps == 0) or (#enemyHeroes > 0) or
        botMode == BOT_MODE_DEFEND_TOWER_TOP or
        botMode == BOT_MODE_DEFEND_TOWER_MID or
        botMode == BOT_MODE_DEFEND_TOWER_BOT
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if hero_role_generic.HaveCarryInTeam(npcBot)
    then
        if hero_role_generic.IsHeroCarry(npcBot)
        then
            if (#neutralCreeps > 0)
            then
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:IsAlive() and creep:CanBeSeen()
                    then
                        if botLevel >= 6 and botLevel < 15
                        then
                            if not creep:IsAncientCreep() and creep:GetLevel() < botLevel
                            then
                                return BOT_ACTION_DESIRE_HIGH;
                            end
                        elseif botLevel >= 15
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            end
        else
            if (#neutralCreeps > 0)
            then
                local allyHeroes = npcBot:GetNearbyHeroes(700, false, BOT_MODE_NONE);
                if (#allyHeroes > 1)
                then
                    for _, ally in pairs(allyHeroes)
                    do
                        if hero_role_generic.IsHeroCarry(ally)
                        then
                            return BOT_ACTION_DESIRE_NONE;
                        end
                    end
                end
                for _, creep in pairs(neutralCreeps)
                do
                    if creep:IsAlive() and creep:CanBeSeen()
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
                if creep:IsAlive() and creep:CanBeSeen()
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

    return BOT_ACTION_DESIRE_NONE;
end

function Think()
    local npcBot = GetBot();
    --local botLevel = npcBot:GetLevel();
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
        else
            --npcBot:ActionImmediate_Chat("Фармлю лесных крипов!", true);
            npcBot:Action_AttackUnit(mainCreep, false);
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_farm_generic) do _G._savedEnv[k] = v end
