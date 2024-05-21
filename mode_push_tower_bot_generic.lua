---@diagnostic disable: undefined-global
--require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/push_generic")

--local npcBot = GetBot();

function Think()
    push_generic.Think()
end

--[[ function GetDesire()
    local botHealth = npcBot:GetHealth() / npcBot:GetMaxHealth();
    --local botLevel = npcBot:GetLevel();

    if not npcBot:IsAlive() or not utility.CanMove(npcBot) or
        utility.IsBusy(npcBot) or npcBot:WasRecentlyDamagedByAnyHero(2.0) or
        (botHealth <= 0.4) or utility.IsBaseUnderAttack()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    --return BOT_ACTION_DESIRE_VERYHIGH;

    lineForPush = utility.GetLineForPush();

    if lineForPush == LANE_BOT
    then
        return BOT_ACTION_DESIRE_LOW;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function OnStart()
    npcBot:ActionImmediate_Chat("Пушу бот!", true);
    if RollPercentage(15)
    then
        npcBot:ActionImmediate_Chat("Пушу бот!", false);
    end
end

function OnEnd()
    npcBot:SetTarget(nil);
end ]]
