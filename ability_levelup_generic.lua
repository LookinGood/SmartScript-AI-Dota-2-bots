---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("ability_levelup_generic", package.seeall)

function GetHeroAbilities(npcBot)
    local Talents = {}
    local Abilities = {}

    for i = 0, 23, 1 do
        local ability = npcBot:GetAbilityInSlot(i)
        if (ability ~= nil)
        then
            if (ability:IsTalent() == true)
            then
                table.insert(Talents, ability:GetName())
            else
                table.insert(Abilities, ability:GetName())
            end
        end
    end

    local AbilitiesReal =
    {
        npcBot:GetAbilityByName(Abilities[1]),
        npcBot:GetAbilityByName(Abilities[2]),
        npcBot:GetAbilityByName(Abilities[3]),
        npcBot:GetAbilityByName(Abilities[4]),
        npcBot:GetAbilityByName(Abilities[5]),
        npcBot:GetAbilityByName(Abilities[6]),
    }

    return Abilities, Talents, AbilitiesReal;
end

function AbilityLevelUpThink(AbilityToLevelUp)
    local npcBot = GetBot();

    if npcBot:GetAbilityPoints() > 0 and #AbilityToLevelUp == 0
    then
        for i = 0, 23, 1 do
            local ability = npcBot:GetAbilityInSlot(i)
            if ability ~= nil and ability:CanAbilityBeUpgraded() and not ability:IsHidden()
            then
                npcBot:ActionImmediate_Chat("Улучшаю дополнительную способность: " .. ability:GetName(), true);
                npcBot:ActionImmediate_LevelAbility(ability:GetName());
            end
        end
    elseif npcBot:GetAbilityPoints() < 1 or #AbilityToLevelUp == 0
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
