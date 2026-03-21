---@diagnostic disable: undefined-global, redefined-local
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
    if utility.NotCurrectHeroBot(npcBot) or not npcBot:IsAlive()
    then
        return BOT_ACTION_DESIRE_NONE;
    end

    local castAbility = nil;

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

    if utility.IsBusy(npcBot) or
        (castAbility ~= nil and castAbility:IsInAbilityPhase()) or
        npcBot:HasModifier("modifier_spirit_breaker_charge_of_darkness")
    then
        --npcBot:ActionImmediate_Chat("Решаю стоять на месте кастуя!", true);
        return BOT_MODE_DESIRE_ABSOLUTE;
    end

    denyAllyHero = nil;
    local allyHeroes = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
    if (#allyHeroes > 1) and (#enemyHeroes <= 0)
    then
        for _, ally in pairs(allyHeroes)
        do
            if ally ~= npcBot and utility.IsHero(ally) and ally:IsSpeciallyDeniable() and ally:WasRecentlyDamagedByAnyHero(2.0)
            then
                --npcBot:ActionImmediate_Chat("Хочу задинаить героя " .. ally:GetUnitName(), true);
                denyAllyHero = ally;
                return BOT_ACTION_DESIRE_ABSOLUTE;
            end
        end
    end

    return BOT_MODE_DESIRE_VERYLOW;
end

function OnStart()
    --
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if utility.IsBusy(npcBot)
    then
        return;
    end

    if denyAllyHero ~= nil
    then
        npcBot:Action_ClearActions(false);
        npcBot:Action_AttackUnit(denyAllyHero, false);
        return;
    end

    if npcBot:GetActiveModeDesire() == BOT_MODE_DESIRE_VERYLOW and utility.CanMove(npcBot)
    then
        local fountainLocation = utility.GetFountainLocation();
        if GetUnitToLocationDistance(npcBot, fountainLocation) > npcBot:GetBoundingRadius() * 4
        then
            npcBot:Action_MoveToLocation(utility.GetFountainLocation());
            return;
        else
            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(npcBot:GetBoundingRadius() * 4));
            return;
        end
    end
end
