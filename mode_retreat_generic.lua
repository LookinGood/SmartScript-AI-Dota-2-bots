---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function GetDesire()
    if not npcBot:IsAlive() or utility.IsClone(npcBot) or
        --npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter") or
        string.find(npcBot:GetUnitName(), "npc_dota_lone_druid_bear") or
        npcBot:HasModifier('modifier_item_satanic_unholy')
    then
        return BOT_MODE_DESIRE_NONE;
    end

    --local allyHeroes = utility.CountAllyHeroAroundUnit(npcBot, 2000);
    --local enemyHeroes = utility.CountEnemyHeroAroundUnit(npcBot, 2000);
    -- string.find(npcBot:GetUnitName(), "medusa")

    local botMode = npcBot:GetActiveMode();
    local botHPGegen = npcBot:GetHealthRegen();
    local healthPercent = npcBot:GetHealth() / npcBot:GetMaxHealth();
    local manaPercent = npcBot:GetMana() / npcBot:GetMaxMana();
    local allyHeroAround = npcBot:GetNearbyHeroes(1600, false, BOT_MODE_NONE);
    local enemyHeroAround = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);

    if not utility.CanMove(npcBot) or
        npcBot:HasModifier("modifier_fountain_invulnerability") or
        npcBot:HasModifier("modifier_fountain_fury_swipes_damage_increase") or
        npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        return BOT_MODE_DESIRE_ABSOLUTE;
    end

    if not npcBot:HasModifier("modifier_fountain_aura_buff") and healthPercent <= 0.6 and not utility.BotWasRecentlyDamagedByEnemyHero(3.0)
        and (#enemyHeroAround <= 0) and (botHPGegen >= 20 or utility.IsBotHaveItem("item_aegis"))
    then
        return BOT_MODE_DESIRE_NONE;
    end

    if npcBot:HasModifier("modifier_fountain_aura_buff")
    then
        if (healthPercent <= 0.8 or manaPercent <= 0.8) or ((#enemyHeroAround > #allyHeroAround + 1) and utility.IsEnemiesAroundStronger())
        then
            return BOT_MODE_DESIRE_MODERATE;
        end
    end

    if npcBot:HasModifier("modifier_medusa_mana_shield")
    then
        if (manaPercent <= 0.3) and (#enemyHeroAround > 0) and utility.BotWasRecentlyDamagedByEnemyHero(5.0)
        then
            return BOT_MODE_DESIRE_HIGH;
        end
    end

    if botMode == BOT_MODE_LANING
    then
        if (#enemyHeroAround > #allyHeroAround + 1) and utility.IsEnemiesAroundStronger()
        then
            return BOT_MODE_DESIRE_MODERATE;
        end
    else
        if utility.IsEnemiesAroundStronger()
        then
            --npcBot:ActionImmediate_Chat("Враги сильнее, нужно отступить!", true);
            return BOT_MODE_DESIRE_MODERATE;
        end
    end

    if (#enemyHeroAround > 0) and utility.IsEnemiesAroundStronger() and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
    then
        for _, enemy in pairs(enemyHeroAround) do
            if utility.IsValidTarget(enemy) and utility.IsHero(enemy:GetAttackTarget())
            then
                return BOT_MODE_DESIRE_MODERATE;
            end
        end
    end

    local botDesire = RemapValClamped(healthPercent, 0.3, 0.5, BOT_MODE_DESIRE_VERYHIGH, BOT_MODE_DESIRE_NONE);
    --[[     if botDesire > BOT_MODE_DESIRE_NONE
    then
        npcBot:ActionImmediate_Chat("Желание отступить: " .. botDesire, true);
    end ]]
    return botDesire;
end

function OnStart()
    if not npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        if RollPercentage(5)
        then
            npcBot:ActionImmediate_Chat("Отступаю!", false);
        end
    end
end

function OnEnd()
    npcBot:SetTarget(nil);
end

function Think()
    if npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active") and utility.IsTargetTeleporting(npcBot)
    then
        --npcBot:ActionImmediate_Chat("Прерываю телепортацию.", true);
        npcBot:Action_ClearActions(true);
        return;
    end

    if utility.IsBusy(npcBot)
    then
        return;
    end

    local fountainLocation = utility.GetFountainLocation();

    if npcBot:HasModifier("modifier_skeleton_king_reincarnation_scepter_active")
    then
        local enemyHeroes = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
        local enemyCreeps = npcBot:GetNearbyCreeps(1600, true);
        local enemyOther = GetUnitList(UNIT_LIST_ENEMY_OTHER);
        local enemyTowers = npcBot:GetNearbyTowers(1600, true);
        local enemyBarracks = npcBot:GetNearbyBarracks(1600, true);
        local enemyAncient = GetAncient(GetOpposingTeam());
        local enemyFillers = npcBot:GetNearbyFillers(1600, true);
        local enemyWards = GetUnitList(UNIT_LIST_ENEMY_WARDS);
        if (#enemyHeroes > 0)
        then
            local enemy = utility.GetWeakest(enemyHeroes);
            if not enemy:IsInvulnerable()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую героя: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if (#enemyCreeps > 0)
        then
            local enemy = utility.GetWeakest(enemyCreeps);
            if not enemy:IsInvulnerable()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую крипа: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if (#enemyOther > 0)
        then
            local enemy = utility.GetWeakest(enemyOther);
            if not enemy:IsInvulnerable() and GetUnitToUnitDistance(npcBot, enemy) <= npcBot:GetCurrentVisionRange()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую юнита: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if (#enemyTowers > 0)
        then
            local enemy = utility.GetWeakest(enemyTowers);
            if not enemy:IsInvulnerable()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую башню: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if (#enemyBarracks > 0)
        then
            local enemy = utility.GetWeakest(enemyBarracks);
            if not enemy:IsInvulnerable()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую баррак: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if not enemyAncient:IsInvulnerable() and GetUnitToUnitDistance(npcBot, enemyAncient) <= 3000
        then
            npcBot:SetTarget(enemyAncient);
            npcBot:Action_AttackUnit(enemyAncient, false);
            --npcBot:ActionImmediate_Chat("Атакую древнего: " .. enemyAncient:GetUnitName(), true);
            return;
        end
        if (#enemyWards > 0)
        then
            local enemy = utility.GetWeakest(enemyWards);
            if not enemy:IsInvulnerable() and GetUnitToUnitDistance(npcBot, enemy) <= npcBot:GetCurrentVisionRange()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую вард: " .. enemy:GetUnitName(), true);
                return;
            end
        end
        if (#enemyFillers > 0)
        then
            local enemy = utility.GetWeakest(enemyFillers);
            if not enemy:IsInvulnerable()
            then
                npcBot:SetTarget(enemy);
                npcBot:Action_AttackUnit(enemy, false);
                --npcBot:ActionImmediate_Chat("Атакую постройку: " .. enemy:GetUnitName(), true);
                return;
            end
        end

        npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(1600));
        return;
    end

    if utility.CanMove(npcBot)
    then
        if GetUnitToLocationDistance(npcBot, fountainLocation) >= npcBot:GetAcquisitionRange()
        then
            --npcBot:ActionImmediate_Chat("ОТСТУПАЮ!", true);
            npcBot:Action_MoveToLocation(fountainLocation);
            return;
        else
            npcBot:Action_MoveToLocation(npcBot:GetLocation() + RandomVector(npcBot:GetBoundingRadius() * 4));
            return;
        end
    else
        local enemyHeroAround = npcBot:GetNearbyHeroes(npcBot:GetAttackRange(), true, BOT_MODE_NONE);
        local enemyCreepsAround = npcBot:GetNearbyCreeps(npcBot:GetAttackRange(), true);
        if (#enemyHeroAround > 0)
        then
            for _, enemy in pairs(enemyHeroAround) do
                if utility.CanCastOnInvulnerableTarget(enemy) and not utility.IsNotAttackTarget(enemy)
                then
                    npcBot:SetTarget(enemy);
                    npcBot:Action_AttackUnit(enemy, true);
                    return;
                end
            end
        end
        if (#enemyCreepsAround > 0)
        then
            for _, enemy in pairs(enemyCreepsAround) do
                if utility.CanCastOnInvulnerableTarget(enemy) and not utility.IsNotAttackTarget(enemy)
                then
                    npcBot:SetTarget(enemy);
                    npcBot:Action_AttackUnit(enemy, true);
                    return;
                end
            end
        end
        npcBot:Action_AttackMove(npcBot:GetLocation());
        return;
    end
end

--[[ local AbilityHighFive = npcBot:GetAbilityByName('high_five');
npcBot:ActionImmediate_Chat("Дай пять: " .. AbilityHighFive:GetName(), true);
--local abilityRange = AbilityHighFive:GetSpecialValueInt("acknowledge_range");
--local allyHeroes = npcBot:GetNearbyHeroes(abilityRange, false, BOT_MODE_NONE);
--local enemyHeroes = npcBot:GetNearbyHeroes(abilityRange, true, BOT_MODE_NONE);
if AbilityHighFive ~= nil and AbilityHighFive:IsFullyCastable()
then
    npcBot:ActionImmediate_Chat("Дай пять: " .. AbilityHighFive:GetName(), true);

  if (#allyHeroes > 0) or (#enemyHeroes > 0)
    then
        npcBot:ActionImmediate_Chat("Дай пять!", true);
        npcBot:Action_UseAbility(AbilityHighFive);
    end
end ]]

--botMode ~= BOT_MODE_DEFEND_TOWER_TOP and
--botMode ~= BOT_MODE_DEFEND_TOWER_MID and
--botMode ~= BOT_MODE_DEFEND_TOWER_BOT

-- and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.9 and npcBot:WasRecentlyDamagedByAnyHero(2.0)

--[[     if (#enemyHeroAround > 0) and (allyHeroes + 1 < enemyHeroes)
    then
        for _, enemy in pairs(enemyHeroAround) do
            local allyHero = enemy:GetAttackTarget();
            if utility.IsHero(allyHero) and not utility.IsHero(allyHero:GetAttackTarget())
                and allyHero:GetHealth() / allyHero:GetMaxHealth() <= 0.9
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and allyHero:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACK
                and npcBot:GetCurrentActionType() ~= BOT_ACTION_TYPE_ATTACKMOVE
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end ]]

--[[     if (#enemyHeroAround > 0) and (allyHeroes + 2 < enemyHeroes) and npcBot:GetHealth() / npcBot:GetMaxHealth() <= 0.6
    then
        for _, enemy in pairs(enemyHeroAround) do
            local enemyDamageToMe = enemy:GetEstimatedDamageToTarget(false, npcBot, 5.0, DAMAGE_TYPE_ALL);
            if enemyDamageToMe >= npcBot:GetMaxHealth() / 2 and allyHeroes <= 1
            then
                --npcBot:ActionImmediate_Chat("Меня могут убить! Я убегаю!", true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end ]]
