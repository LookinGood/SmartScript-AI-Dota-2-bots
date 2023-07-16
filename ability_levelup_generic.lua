---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("ability_levelup_generic", package.seeall)


function AbilityLevelUpThink(AbilityToLevelUp)
    local npcBot = GetBot();
    
    if npcBot:GetAbilityPoints() < 1 or #AbilityToLevelUp == 0
    then
        return;
    end

    local ability = npcBot:GetAbilityByName(AbilityToLevelUp[1]);

    if ability ~= nil and ability:CanAbilityBeUpgraded() and not ability:IsHidden()
    then
        npcBot:ActionImmediate_LevelAbility(AbilityToLevelUp[1]);
        table.remove(AbilityToLevelUp, 1);
    end
end



---------------------------------------------------------------------------------------------------
for k, v in pairs(ability_levelup_generic) do _G._savedEnv[k] = v end
