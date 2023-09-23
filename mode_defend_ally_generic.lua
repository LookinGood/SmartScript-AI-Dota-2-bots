---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_rune_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

function GetDesire()
    local npcBot = GetBot();
    local botMode = npcBot:GetActiveMode();
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not npcBot:IsAlive() or npcBot:IsUsingAbility() or npcBot:IsChanneling() or not utility.CanMove(npcBot) or (#allyHeroes <= 1)
        or botMode == BOT_MODE_ATTACK or botMode == BOT_MODE_RETREAT or (#allyHeroes < #enemyHeroes) or
        (npcBot:GetHealth() / npcBot:GetMaxHealth() < 0.7 and npcBot:WasRecentlyDamagedByAnyHero(2.0))
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    escortAlly = nil;
    mostDangerousEnemy = nil;

    if (#allyHeroes > 1)
    then
        for _, ally in pairs(allyHeroes)
        do
            if escortAlly == nil and ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.8
                and ally:WasRecentlyDamagedByAnyHero(2.0)
            then
                local enemyHeroes = ally:GetNearbyHeroes(1000, true, BOT_MODE_NONE);
                if (#enemyHeroes > 0)
                then
                    for _, enemy in pairs(enemyHeroes)
                    do
                        local totalDamageToAlly = 0;
                        local totalDamageToMe = 0;
                        local maxDamage = 0;
                        local enemyDamageToAlly = enemy:GetEstimatedDamageToTarget(false, ally, 3.0,
                            DAMAGE_TYPE_ALL);
                        local enemyDamageToToMe = enemy:GetEstimatedDamageToTarget(false, npcBot, 3.0,
                            DAMAGE_TYPE_ALL);
                        totalDamageToAlly = totalDamageToAlly + enemyDamageToAlly;
                        totalDamageToMe = totalDamageToMe + enemyDamageToToMe;

                        if (totalDamageToAlly > maxDamage) and (totalDamageToAlly <= totalDamageToMe)
                        then
                            --npcBot:ActionImmediate_Chat("Я решил защищать союзника!", true);
                            totalDamageToAlly = enemyDamageToAlly;
                            escortAlly = ally;
                            mostDangerousEnemy = enemy;
                            return BOT_ACTION_DESIRE_VERYHIGH;
                        end
                    end
                end
            end
        end
    end

    if mostDangerousEnemy == nil or escortAlly == nil
    then
        return BOT_ACTION_DESIRE_NONE;
    end
end

function OnEnd()
    escortAlly = nil;
    mostDangerousEnemy = nil;
    npcBot:SetTarget(nil);
end

function Think()
    local npcBot = GetBot();

    if mostDangerousEnemy ~= nil
    then
        if GetUnitToUnitDistance(npcBot, mostDangerousEnemy) <= (npcBot:GetAttackRange() * 4)
        then
            --npcBot:ActionImmediate_Chat("Я атакую врага защищая союзника!", true);
            npcBot:SetTarget(mostDangerousEnemy);
            npcBot:Action_AttackUnit(mostDangerousEnemy, false);
        else
            if escortAlly ~= nil and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                --npcBot:ActionImmediate_Chat("Я патрулирую рядом с союзником!", true);
                local escortAlyPosition = escortAlly:GetLocation();
                if GetUnitToUnitDistance(npcBot, escortAlly) > 300
                then
                    npcBot:Action_MoveToLocation(escortAlyPosition);
                else
                    npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(npcBot:GetAttackRange() * 2));
                end
            end
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_rune_generic) do _G._savedEnv[k] = v end
