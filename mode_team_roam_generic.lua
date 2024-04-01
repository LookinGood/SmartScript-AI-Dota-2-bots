---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("mode_retreat_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();
local castAbility = nil;

function GetDesire()
    local botMode = npcBot:GetActiveMode();

    if botMode == BOT_MODE_SHRINE or botMode == BOT_MODE_OUTPOST or npcBot:GetCurrentActionType() == BOT_ACTION_TYPE_SHRINE
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    if castAbility == nil then castAbility = npcBot:GetAbilityByName("tinker_rearm") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("elder_titan_echo_stomp") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("tiny_tree_channel") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("clinkz_burning_barrage") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("drow_ranger_multishot") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("templar_assassin_trap_teleport") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("keeper_of_the_light_illuminate") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("oracle_fortunes_end") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("puck_phase_shift") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("pugna_life_drain") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("shadow_shaman_shackles") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("witch_doctor_death_ward") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("enigma_black_hole") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("windrunner_shackleshot") end;
    if castAbility == nil then castAbility = npcBot:GetAbilityByName("spirit_breaker_charge_of_darkness") end;

    if npcBot:IsChanneling() or (castAbility ~= nil and castAbility:IsInAbilityPhase()) or
        npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
    then
        --npcBot:ActionImmediate_Chat("Решаю стоять на месте кастуя!", true);
        return BOT_ACTION_DESIRE_ABSOLUTE;
    end

    return BOT_ACTION_DESIRE_NONE;
end

function Think()
    if (castAbility ~= nil and castAbility:IsInAbilityPhase()) or npcBot:IsChanneling() or
        npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
    then
        --npcBot:ActionImmediate_Chat("Стою на месте кастуя!", true);
        return;
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(mode_retreat_generic) do _G._savedEnv[k] = v end



--[[     if castAbility == nil or not npcBot:IsChanneling()
    then
        return BOT_ACTION_DESIRE_NONE;
    end ]]


--[[     if npcBot:GetUnitName() == "npc_dota_hero_tinker"
    then
        if castAbility == nil then castAbility = npcBot:GetAbilityByName("tinker_rearm") end;
        if castAbility:IsInAbilityPhase() or npcBot:IsChanneling()
        then
            npcBot:ActionImmediate_Chat("Решаю стоять на месте кастуя!", true);
            return BOT_MODE_DESIRE_ABSOLUTE;
        end
    end ]]

--[[     if npcBot:IsChanneling()
    then
        castAbility = npcBot:GetAbilityByName("tinker_rearm");
        if castAbility ~= nil and castAbility:IsInAbilityPhase() == true
        then
            --channeling = true;
            npcBot:ActionImmediate_Chat("Решаю стоять на месте кастуя!", true);
            return BOT_ACTION_DESIRE_ABSOLUTE;
        end
    end ]]
