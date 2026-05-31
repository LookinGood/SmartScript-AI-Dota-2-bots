---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

function GetDesire()
	return BOT_ACTION_DESIRE_NONE;
end

function OnStart()

end

function OnEnd()
	npcBot:SetTarget(nil);
end

function Think()
	if utility.IsBusy(npcBot)
	then
		return;
	end
end
