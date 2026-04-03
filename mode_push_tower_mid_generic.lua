---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")
require(GetScriptDirectory() .. "/push_generic")

local npcBot = GetBot();

function GetDesire()
    local botLevel = npcBot:GetLevel();
    local botMode = npcBot:GetActiveMode();
    if utility.NotCurrectHeroBot(npcBot) or not npcBot:IsAlive() or npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") or botLevel <= 6
        or botMode == BOT_MODE_LANING or utility.IsBaseUnderAttack()

    then
        return BOT_ACTION_DESIRE_NONE;
    end

    --[[     local botModeDesire = npc:GetActiveModeDesire();

    if botModeDesire <= BOT_MODE_DESIRE_NONE or npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_NONE
    then
        npcBot:ActionImmediate_Chat("Решаю пушить мид от безделья.", true);
        return BOT_ACTION_DESIRE_VERYLOW;
    end ]]

    return BOT_ACTION_DESIRE_VERYLOW;
end

function OnStart()
    if RollPercentage(5)
    then
        npcBot:ActionImmediate_Chat("Атакую центральную линию.", false);
    end
    --npcBot:ActionImmediate_Chat("Решаю пушить мид от безделья.", true);
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

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

    if lineForPush == LANE_MID
    then
        return BOT_ACTION_DESIRE_LOW;
    end

    return BOT_ACTION_DESIRE_NONE;
end
 ]]
