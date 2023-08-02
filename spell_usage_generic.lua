---@diagnostic disable: undefined-global
_G._savedEnv = getfenv()
module("spell_usage_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local npcBot = GetBot();

function CastCustomSpell(ability)
    if ability == nil or
        ability:IsHidden() or
        ability:IsPassive()
    then
        return;
    end

    botMode = npcBot:GetActiveMode();
    botTarget = npcBot:GetTarget();

    --print(ability:GetName())

    if ability:GetName() == "centaur_khan_war_stomp"
    then
        --WarStomp = npcBot:GetAbilityByName("centaur_khan_war_stomp");
        WarStomp = ability;
        local castWarStompDesire = ConsiderWarStomp();
        if (castWarStompDesire ~= nil)
        then
            npcBot:Action_UseAbility(WarStomp);
            return;
        end
    end

    if ability:GetName() == "ogre_bruiser_ogre_smash"
    then
        --OgreSmash = npcBot:GetAbilityByName("ogre_bruiser_ogre_smash");
        OgreSmash = ability;
        local castOgreSmashDesire, castOgreSmashLocation = ConsiderOgreSmash();
        if (castOgreSmashDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnLocation(OgreSmash, castOgreSmashLocation);
            return;
        end
    end

    if ability:GetName() == "giant_wolf_intimidate"
    then
        --Intimidate = npcBot:GetAbilityByName("giant_wolf_intimidate");
        Intimidate = ability;
        local castIntimidateDesire = ConsiderIntimidate();
        if (castIntimidateDesire ~= nil)
        then
            npcBot:Action_UseAbility(Intimidate);
            return;
        end
    end

    if ability:GetName() == "fel_beast_haunt"
    then
        --Haunt = npcBot:GetAbilityByName("fel_beast_haunt");
        Haunt = ability;
        local castHauntDesire, castHauntTarget = ConsiderHaunt();
        if (castHauntDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(Haunt, castHauntTarget)
            return;
        end
    end

    if ability:GetName() == "polar_furbolg_ursa_warrior_thunder_clap"
    then
        --ThunderClap = npcBot:GetAbilityByName("polar_furbolg_ursa_warrior_thunder_clap");
        ThunderClap = ability;
        local castThunderClapDesire = ConsiderThunderClap();
        if (castThunderClapDesire ~= nil)
        then
            npcBot:Action_UseAbility(ThunderClap);
            return;
        end
    end

    if ability:GetName() == "ogre_magi_frost_armor"
    then
        --FrostArmor = npcBot:GetAbilityByName("ogre_magi_frost_armor");
        FrostArmor = ability;
        local castFrostArmorDesire, castFrostArmorTarget = ConsiderFrostArmor();
        if (castFrostArmorDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(FrostArmor, castFrostArmorTarget)
            return;
        end
    end

    if ability:GetName() == "dark_troll_warlord_ensnare"
    then
        --Ensnare = npcBot:GetAbilityByName("dark_troll_warlord_ensnare");
        Ensnare = ability;
        local castEnsnareDesire, castEnsnareTarget = ConsiderEnsnare();
        if (castEnsnareDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(Ensnare, castEnsnareTarget)
            return;
        end
    end

    if ability:GetName() == "dark_troll_warlord_raise_dead"
    then
        --RaiseDead = npcBot:GetAbilityByName("dark_troll_warlord_raise_dead");
        RaiseDead = ability;
        local castRaiseDeadDesire = ConsiderRaiseDead();
        if (castRaiseDeadDesire ~= nil)
        then
            npcBot:Action_UseAbility(RaiseDead);
            return;
        end
    end

    if ability:GetName() == "warpine_raider_seed_shot"
    then
        --SeedShot = npcBot:GetAbilityByName("warpine_raider_seed_shot");
        SeedShot = ability;
        local castSeedShotDesire, castSeedShotTarget = ConsiderSeedShot();
        if (castSeedShotDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(SeedShot, castSeedShotTarget)
            return;
        end
    end

    if ability:GetName() == "mud_golem_hurl_boulder"
    then
        --HurlBoulder = npcBot:GetAbilityByName("mud_golem_hurl_boulder");
        HurlBoulder = ability;
        local castHurlBoulderDesire, castHurlBoulderTarget = ConsiderHurlBoulder();
        if (castHurlBoulderDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(HurlBoulder, castHurlBoulderTarget)
            return;
        end
    end

    if ability:GetName() == "ice_shaman_incendiary_bomb"
    then
        --IncendiaryBomb = npcBot:GetAbilityByName("ice_shaman_incendiary_bomb");
        IncendiaryBomb = ability;
        local castIncendiaryBombDesire, castIncendiaryBombTarget = ConsiderIncendiaryBomb();
        if (castIncendiaryBombDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(IncendiaryBomb, castIncendiaryBombTarget)
            return;
        end
    end

    if ability:GetName() == "enraged_wildkin_tornado"
    then
        --Tornado = npcBot:GetAbilityByName("enraged_wildkin_tornado");
        Tornado = ability;
        local castTornadoDesire, castTornadoLocation = ConsiderTornado();
        if (castTornadoDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnLocation(Tornado, castTornadoLocation)
            return;
        end
    end

    if ability:GetName() == "enraged_wildkin_hurricane"
    then
        --Hurricane = npcBot:GetAbilityByName("enraged_wildkin_hurricane");
        Hurricane = ability;
        local castHurricaneDesire, castHurricaneTarget = ConsiderHurricane();
        if (castHurricaneDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(Hurricane, castHurricaneTarget)
            return;
        end
    end

    if ability:GetName() == "satyr_trickster_purge"
    then
        --Purge = npcBot:GetAbilityByName("satyr_trickster_purge");
        Purge = ability;
        local castPurgeDesire, castPurgeTarget = ConsiderPurge();
        if (castPurgeDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(Purge, castPurgeTarget)
            return;
        end
    end

    if ability:GetName() == "satyr_soulstealer_mana_burn"
    then
        --ManaBurn = npcBot:GetAbilityByName("satyr_soulstealer_mana_burn");
        ManaBurn = ability;
        local castManaBurnDesire, castManaBurnTarget = ConsiderManaBurn();
        if (castManaBurnDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(ManaBurn, castManaBurnTarget)
            return;
        end
    end

    if ability:GetName() == "satyr_hellcaller_shockwave"
    then
        --Shockwave = npcBot:GetAbilityByName("satyr_hellcaller_shockwave");
        Shockwave = ability;
        local castShockwaveDesire, castShockwaveLocation = ConsiderShockwave();
        if (castShockwaveDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnLocation(Shockwave, castShockwaveLocation)
            return;
        end
    end

    if ability:GetName() == "forest_troll_high_priest_heal"
    then
        Heal = ability;
        local castHealDesire, castHealTarget = ConsiderHeal();
        if (castHealDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(Heal, castHealTarget)
            return;
        end
    end

    if ability:GetName() == "harpy_scout_take_off"
    then
        TakeOff = ability;
        local castTakeOffDesire = ConsiderTakeOff();
        if (castTakeOffDesire ~= nil)
        then
            npcBot:Action_UseAbility(TakeOff);
            return;
        end
    end

    if ability:GetName() == "harpy_storm_chain_lightning"
    then
        ChainLightning = ability;
        local castChainLightningDesire, castChainLightningTarget = ConsiderChainLightning();
        if (castChainLightningDesire ~= nil)
        then
            npcBot:Action_UseAbilityOnEntity(ChainLightning, castChainLightningTarget)
            return;
        end
    end
end

-- ABILITIES
function ConsiderWarStomp()
    local ability = WarStomp;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRadiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy)) or enemy:IsChanneling()
                then
                    npcBot:ActionImmediate_Chat("Использую WarStomp что бы убить цель или сбить каст!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую WarStomp по цели!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderOgreSmash()
    local ability = OgreSmash;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if enemy:CanBeSeen() and enemy:IsChanneling()
            then
                npcBot:ActionImmediate_Chat("Использую OgreSmash что бы сбить заклинание!",
                    true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
            end
        end
    end

    -- Cast if attack enemy
    if utility.CanCastSpellOnTarget(ability, botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
    then
        npcBot:ActionImmediate_Chat("Использую OgreSmash по врагу в радиусе действия!",
            true);
        return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
    end
end

function ConsiderIntimidate()
    local ability = Intimidate;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRadiusAbility = ability:GetSpecialValueInt("radius");
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility, true, BOT_MODE_NONE);

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Intimidate по цели!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderHaunt()
    local ability = Haunt;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if enemy:IsChanneling()
                then
                    npcBot:ActionImmediate_Chat("Использую Haunt что бы сбить заклинание цели!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Attack use
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not botTarget:IsSilenced() and not utility.IsDisabled(botTarget)
        then
            npcBot:ActionImmediate_Chat("Использую Haunt для нападения!", true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
        -- Retreat or help ally use
    elseif botMode == BOT_MODE_RETREAT or botMode == BOT_MODE_DEFEND_ALLY
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Haunt для отступления!", true);
                    return BOT_ACTION_DESIRE_HIGH, enemy;
                end
            end
        end
    end
end

function ConsiderThunderClap()
    local ability = ThunderClap;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRadiusAbility = ability:GetSpecialValueInt("radius");
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy))
                then
                    npcBot:ActionImmediate_Chat("Использую ThunderClap что бы убить цель!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH;
                end
            end
        end
    end

    -- General use
    if utility.PvPMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую ThunderClap по цели!", true);
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end
    end
end

function ConsiderFrostArmor()
    local ability = FrostArmor;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility) do
            if not ally:HasModifier("modifier_ogre_magi_frost_armor")
            then
                npcBot:ActionImmediate_Chat("Использую FrostArmor!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, ally;
            end
        end
    end
end

function ConsiderEnsnare()
    local ability = Ensnare;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsValidTarget(enemy) and enemy:IsChanneling()
            then
                npcBot:ActionImmediate_Chat("Использую Ensnare что бы сбить заклинание!",
                    true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget)
        then
            npcBot:ActionImmediate_Chat("Использую Ensnare по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.IsValidTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Ensnare для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderRaiseDead()
    local ability = RaiseDead;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- General use
    if utility.PvPMode(npcBot) or utility.PvEMode(npcBot) or botMode == BOT_MODE_RETREAT
    then
        npcBot:ActionImmediate_Chat("Использую RaiseDead!", true);
        return BOT_ACTION_DESIRE_HIGH;
    end
end

function ConsiderSeedShot()
    local ability = SeedShot;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy))
                then
                    npcBot:ActionImmediate_Chat("Использую SeedShot что бы убить цель!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget)
        then
            npcBot:ActionImmediate_Chat("Использую SeedShot по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую SeedShot для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderHurlBoulder()
    local ability = HurlBoulder;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can interrupt cast
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.IsValidTarget(enemy) and enemy:IsChanneling()
            then
                npcBot:ActionImmediate_Chat("Использую HurlBoulder что бы сбить заклинание!",
                    true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsValidTarget(botTarget) and utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget)
        then
            npcBot:ActionImmediate_Chat("Использую HurlBoulder по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.IsValidTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую HurlBoulder для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderIncendiaryBomb()
    local ability = IncendiaryBomb;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) or utility.IsBuilding(botTarget)
        then
            if utility.IsValidTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                npcBot:ActionImmediate_Chat("Использую IncendiaryBomb по врагу в радиусе действия!",
                    true);
                return BOT_ACTION_DESIRE_HIGH, botTarget;
            end
        end
    end
end

function ConsiderTornado()
    local ability = Tornado;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyCreeps(castRangeAbility, true);

    if utility.PvEMode(npcBot)
    then
        if (#enemyAbility > 2)
        then
            return BOT_ACTION_DESIRE_HIGH, enemyAbility[1]:GetLocation();
        end
    end
end

function ConsiderHurricane()
    local ability = Hurricane;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.IsValidTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Hurricane для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderPurge()
    local ability = Purge;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRadiusAbility, true, BOT_MODE_NONE);

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastOnMagicImmuneTarget(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            and not utility.IsDisabled(botTarget)
        then
            npcBot:ActionImmediate_Chat("Использую Purge по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end

    -- Retreat use
    if botMode == BOT_MODE_RETREAT
    then
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility)
            do
                if utility.CanCastOnMagicImmuneTarget(enemy) and not utility.IsDisabled(enemy)
                then
                    npcBot:ActionImmediate_Chat("Использую Purge для отхода!", true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end
end

function ConsiderManaBurn()
    local ability = ManaBurn;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility)
        do
            if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:GetMana() >= ability:GetSpecialValueInt("burn_amount")
            then
                npcBot:ActionImmediate_Chat("Использую ManaBurn!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, enemy;
            end
        end
    end
end

function ConsiderShockwave()
    local ability = Shockwave;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetAbilityDamage();
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastOnMagicImmuneTarget(enemy)
            then
                if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy))
                then
                    npcBot:ActionImmediate_Chat("Использую Shockwave что бы убить цель!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            npcBot:ActionImmediate_Chat("Использую Shockwave по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget:GetLocation();
        end
    end
end

function ConsiderHeal()
    local ability = Heal;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    if not ability:GetAutoCastState()
    then
        ability:ToggleAutoCast();
    end

    if (#allyAbility > 0)
    then
        for _, ally in pairs(allyAbility) do
            if ally:GetHealth() / ally:GetMaxHealth() <= 0.8
            then
                npcBot:ActionImmediate_Chat("Использую Heal!", true);
                return BOT_ACTION_DESIRE_VERYHIGH, ally;
            end
        end
    end
end

function ConsiderTakeOff()
    local ability = TakeOff;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange()
        then
            if ability:GetToggleState() == false
            then
                npcBot:ActionImmediate_Chat("Использую TakeOff!",
                    true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        else
            if ability:GetToggleState() == true
            then
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    else
        if ability:GetToggleState() == true
        then
            return BOT_ACTION_DESIRE_HIGH;
        end
    end
end

function ConsiderChainLightning()
    local ability = ChainLightning;
    if not utility.IsAbilityAvailable(ability) then
        return;
    end

    local castRangeAbility = ability:GetCastRange();
    local damageAbility = ability:GetSpecialValueInt("initial_damage");
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    -- Cast if can kill somebody
    if (#enemyAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanCastSpellOnTarget(ability, enemy)
            then
                if (utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType()) and not utility.TargetCantDie(enemy))
                then
                    npcBot:ActionImmediate_Chat("Использую ChainLightning что бы убить цель!",
                        true);
                    return BOT_ACTION_DESIRE_VERYHIGH, enemy;
                end
            end
        end
    end

    -- Cast if attack enemy
    if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget) and utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
        then
            npcBot:ActionImmediate_Chat("Использую ChainLightning по врагу в радиусе действия!",
                true);
            return BOT_ACTION_DESIRE_HIGH, botTarget;
        end
    end
end

---------------------------------------------------------------------------------------------------
for k, v in pairs(spell_usage_generic) do _G._savedEnv[k] = v end
