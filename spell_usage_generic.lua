---@diagnostic disable: undefined-global, undefined-field, need-check-nil
_G._savedEnv = getfenv()
module("spell_usage_generic", package.seeall)
require(GetScriptDirectory() .. "/utility")

local ignoredAbility = {
    "bane_nightmare_end",
    "keeper_of_the_light_illuminate_end",
    "keeper_of_the_light_spirit_form_illuminate_end",
    "dawnbreaker_converge",
    "morphling_morph_agi",
    "morphling_morph_str",
    "pangolier_gyroshell_stop",
    "pangolier_rollup_stop",
    "phoenix_icarus_dive_stop",
    "phoenix_sun_ray_stop",
    "phoenix_sun_ray_toggle_move",
    "shadow_demon_shadow_poison_release",
    "wisp_spirits_in",
    "wisp_spirits_out",
    "wisp_tether_break",
    "grimstroke_ink_over",
    "grimstroke_return",
    "kunkka_return",
    "night_stalker_darkness",
    "nyx_assassin_burrow",
}

local interruptAbility = {
    "alchemist_unstable_concoction_throw",
    "ancient_apparition_cold_feet",
    "beastmaster_primal_roar",
    "chaos_knight_chaos_bolt",
    "crystal_maiden_frostbite",
    "dark_willow_cursed_crown",
    "dragon_knight_dragon_tail",
    "earth_spirit_boulder_smash",
    "enigma_malefice",
    "grimstroke_ink_creature",
    "gyrocopter_homing_missile",
    "juggernaut_omni_slash",
    "juggernaut_swift_slash",
    "lich_sinister_gaze",
    "lion_impale",
    "luna_lucent_beam",
    "marci_grapple",
    "naga_siren_ensnare",
    "necrolyte_reapers_scythe",
    "obsidian_destroyer_astral_imprisonment",
    "ogre_magi_fireblast",
    "ogre_magi_unrefined_fireblast",
    "pudge_dismember",
    "rubick_telekinesis",
    "sandking_burrowstrike",
    "shadow_demon_disruption",
    "shadow_shaman_voodoo",
    "shadow_shaman_shackles",
    "skeleton_king_hellfire_blast",
    "skywrath_mage_ancient_seal",
    "sniper_assassinate",
    "spirit_breaker_charge_of_darkness",
    "spirit_breaker_nether_strike",
    "storm_spirit_electric_vortex",
    "sven_storm_bolt",
    "tiny_toss",
    "tusk_walrus_kick",
    "vengefulspirit_magic_missile",
    "windrunner_shackleshot",
    "winter_wyvern_winters_curse",
    "witch_doctor_paralyzing_cask",
    "zuus_lightning_bolt",
    "disruptor_glimpse",
    "oracle_fortunes_end",
    "silencer_last_word",
    "bane_nightmare",
    "abyssal_underlord_pit_of_malice",
    "batrider_flamebreak",
    "bloodseeker_blood_bath",
    "dark_seer_vacuum",
    "death_prophet_silence",
    "drow_ranger_silence",
    "earthshaker_fissure",
    "elder_titan_earth_splitter",
    "faceless_void_chronosphere",
    "hoodwink_bushwhack",
    "jakiro_ice_path",
    "keeper_of_the_light_radiant_bind",
    "keeper_of_the_light_will_o_wisp",
    "kunkka_tidal_wave",
    "kunkka_torrent",
    "leshrac_split_earth",
    "lina_light_strike_array",
    "lion_impale",
    "magnataur_shockwave",
    "mars_spear",
    "meepo_earthbind",
    "monkey_king_boundless_strike",
    "muerta_the_calling",
    "nyx_assassin_impale",
    "puck_waning_rift",
    "pudge_meat_hook",
    "rattletrap_hookshot",
    "riki_smoke_screen",
    "sandking_burrowstrike",
    "tiny_avalanche",
    "zuus_lightning_bolt",
    "enigma_black_hole",
    "axe_berserkers_call",
    "centaur_hoof_stomp",
    "crystal_maiden_freezing_field",
    "earthshaker_enchant_totem",
    "elder_titan_echo_stomp",
    "huskar_inner_fire",
    "magnataur_horn_toss",
    "medusa_stone_gaze",
    "silencer_global_silence",
    "slardar_slithereen_crush",
    "terrorblade_terror_wave",
    "tidehunter_ravage",
    "treant_overgrowth",
}

local damageAbility = {
    "alchemist_unstable_concoction_throw",
    "ancient_apparition_cold_feet",
    "beastmaster_primal_roar",
    "chaos_knight_chaos_bolt",
    "crystal_maiden_frostbite",
    "dark_willow_cursed_crown",
    "dragon_knight_dragon_tail",
    "earth_spirit_boulder_smash",
    "enigma_malefice",
    "grimstroke_ink_creature",
    "gyrocopter_homing_missile",
    "juggernaut_omni_slash",
    "juggernaut_swift_slash",
    "lion_impale",
    "luna_lucent_beam",
    "marci_grapple",
    "obsidian_destroyer_astral_imprisonment",
    "ogre_magi_fireblast",
    "ogre_magi_unrefined_fireblast",
    "pudge_dismember",
    "sandking_burrowstrike",
    "shadow_shaman_shackles",
    "skeleton_king_hellfire_blast",
    "sniper_assassinate",
    "spirit_breaker_nether_strike",
    "sven_storm_bolt",
    "tiny_toss",
    "tusk_walrus_kick",
    "vengefulspirit_magic_missile",
    "witch_doctor_paralyzing_cask",
    "zuus_lightning_bolt",
    "oracle_fortunes_end",
    "silencer_last_word",
    "batrider_flamebreak",
    "bloodseeker_blood_bath",
    "dark_seer_vacuum",
    "earthshaker_fissure",
    "elder_titan_earth_splitter",
    "hoodwink_bushwhack",
    "jakiro_ice_path",
    "keeper_of_the_light_radiant_bind",
    "kunkka_tidal_wave",
    "kunkka_torrent",
    "leshrac_split_earth",
    "lina_light_strike_array",
    "lion_impale",
    "magnataur_shockwave",
    "mars_spear",
    "monkey_king_boundless_strike",
    "muerta_the_calling",
    "nyx_assassin_impale",
    "puck_waning_rift",
    "pudge_meat_hook",
    "rattletrap_hookshot",
    "sandking_burrowstrike",
    "tiny_avalanche",
    "zuus_lightning_bolt",
    "enigma_black_hole",
    "centaur_hoof_stomp",
    "crystal_maiden_freezing_field",
    "earthshaker_enchant_totem",
    "elder_titan_echo_stomp",
    "huskar_inner_fire",
    "magnataur_horn_toss",
    "slardar_slithereen_crush",
    "tidehunter_ravage",
    "treant_overgrowth",
}

local selfBuffAbility = {
    "alchemist_chemical_rage",
    "dragon_knight_elder_dragon_form",
    "keeper_of_the_light_spirit_form",
    "lone_druid_true_form",
    "lycan_shapeshift",
    "muerta_pierce_the_veil",
    "pangolier_gyroshell",
    "terrorblade_metamorphosis",
    "undying_flesh_golem",
    "batrider_firefly",
    "brewmaster_primal_split",
    "broodmother_insatiable_hunger",
    "centaur_stampede",
    "chaos_knight_phantasm",
    "dark_willow_shadow_realm",
    "death_prophet_exorcism",
    "clinkz_strafe",
    "drow_ranger_glacier",
    "earthshaker_enchant_totem",
    "life_stealer_rage",
    "lina_flame_cloak",
    "marci_unleash",
    "razor_eye_of_the_storm",
    "shredder_reactive_armor",
    "slardar_sprint",
    "slark_shadow_dance",
    "sniper_take_aim",
    "spirit_breaker_bulldoze",
    "storm_spirit_overload",
    "sven_warcry",
    "sven_gods_strength",
    "techies_reactive_tazer",
    "templar_assassin_refraction",
    "tusk_tag_team",
    "ursa_overpower",
    "ursa_enrage",
    "windrunner_windrun",
    "winter_wyvern_arctic_burn",
    "witch_doctor_voodoo_switcheroo",
    "zuus_heavenly_jump",
}

local healingAbility = {
    "abaddon_death_coil",
    "dazzle_shadow_wave",
    "legion_commander_press_the_attack",
    "omniknight_purification",
    "oracle_purifying_flames",
    "shadow_demon_demonic_cleanse",
    "warlock_shadow_word",
    "winter_wyvern_cold_embrace",
    "treant_living_armor",
    "undying_soul_rip",
    "enchantress_natures_attendants",
}

local protectTargetAbility = {
    "abaddon_aphotic_shield",
    "alchemist_berserk_potion",
    "antimage_counterspell_ally",
    "chen_divine_favor",
    "bounty_hunter_wind_walk_ally",
    "grimstroke_spirit_walk",
    "lich_frost_shield",
    "lone_druid_spirit_link",
    "marci_guardian",
    "omniknight_repel",
    "oracle_fates_edict",
    "shadow_demon_disseminate",
    "snapfire_firesnap_cookie",
    "tinker_defense_matrix",
    "wisp_tether",
    "slark_depth_shroud",
    "bloodseeker_bloodrage",
}

local safeLifeTargetAbility = {
    "dazzle_shallow_grave",
    "oracle_false_promise",
    "omniknight_guardian_angel",
}

local blinkLikeAbility = {
    "antimage_blink",
    "queenofpain_blink",
    "faceless_void_time_walk",
    "sandking_burrowstrike",
    "pangolier_swashbuckle",
}

local invisAbility = {
    "clinkz_wind_walk",
    "bounty_hunter_wind_walk",
    "bounty_hunter_wind_walk_ally",
    "nyx_assassin_vendetta",
    "phantom_lancer_juxtapose",
    "weaver_shukuchi",
    "phantom_assassin_blur",
}

local toggleAbility = {
    "pudge_rot",
    "witch_doctor_voodoo_restoration",
    "bloodseeker_blood_mist",
    "phantom_lancer_phantom_edge",
    "winter_wyvern_arctic_burn",
    "zuus_lightning_hands",
    "leshrac_pulse_nova",
}

local treeTargetAbility = {
    "tiny_tree_grab",
    "monkey_king_tree_dance",
    "shredder_timber_chain"
}

function IsIgnoredAbility(sAbilityName)
    for _, spell in pairs(ignoredAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsInterruptAbility(sAbilityName)
    for _, spell in pairs(interruptAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsDamageAbility(sAbilityName)
    for _, spell in pairs(damageAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsHealAbility(sAbilityName)
    for _, spell in pairs(healingAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsProtectTargetAbility(sAbilityName)
    for _, spell in pairs(protectTargetAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsSelfBuffAbility(sAbilityName)
    for _, spell in pairs(selfBuffAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsSafeLifeAbility(sAbilityName)
    for _, spell in pairs(safeLifeTargetAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsBlinkLikeAbility(sAbilityName)
    for _, spell in pairs(blinkLikeAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsInvisAbility(sAbilityName)
    for _, spell in pairs(invisAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsToggleAbility(sAbilityName)
    for _, spell in pairs(toggleAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

function IsTreeTargetAbility(sAbilityName)
    for _, spell in pairs(treeTargetAbility)
    do
        if (sAbilityName == spell)
        then
            return true;
        end
    end
    return false;
end

local function GetAbilityRange(ability)
    local range = 0;
    local npcBot = GetBot();
    local castAbilityRange = ability:GetAbilityRange();
    local castAbilityRange2 = ability:GetSpecialValueInt("AbilityCastRange");
    local radiusAbility = ability:GetAOERadius();
    local radiusAbility2 = ability:GetSpecialValueInt("radius");
    local attackRange = npcBot:GetAttackRange();

    if (castAbilityRange ~= nil and castAbilityRange > 0)
    then
        range = castAbilityRange;
    elseif (castAbilityRange2 ~= nil and castAbilityRange2 > 0)
    then
        range = castAbilityRange2;
    elseif (radiusAbility ~= nil and radiusAbility > 0)
    then
        range = radiusAbility;
    elseif (radiusAbility2 ~= nil and radiusAbility2 > 0)
    then
        range = radiusAbility2;
    elseif (attackRange ~= nil and attackRange > 0)
    then
        range = attackRange + 200;
    else
        range = 700;
    end

    return range;
end

local function GetAbilityDamage(ability)
    local damage = 0;
    local damageAbility = ability:GetAbilityDamage();
    local damageAbility2 = ability:GetSpecialValueInt("AbilityDamage");
    local damageAbility3 = ability:GetSpecialValueInt("damage");

    if (damageAbility ~= nil and damageAbility > 0)
    then
        damage = damageAbility;
    elseif (damageAbility2 ~= nil and damageAbility2 > 0)
    then
        damage = damageAbility2;
    elseif (damageAbility3 ~= nil and damageAbility3 > 0)
    then
        damage = damageAbility3;
    end

    return damage;
end

--print(ability:GetName())

function CastCustomSpell(ability)
    local ability = ability;
    if (ability == nil or
            ability:IsHidden() or
            ability:IsPassive() or
            not ability:IsFullyCastable() or
            not ability:IsActivated() or
            IsIgnoredAbility(ability:GetName()))
    then
        return;
    end

    local npcBot = GetBot();
    botTarget = npcBot:GetTarget();
    HealthPercentage = npcBot:GetHealth() / npcBot:GetMaxHealth();
    ManaPercentage = npcBot:GetMana() / npcBot:GetMaxMana();

    print(ability:GetName())
    --print(GetAbilityRange(ability))
    --print(GetAbilityDamage(ability))

    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_AUTOCAST)
    then
        if not ability:GetAutoCastState()
        then
            ability:ToggleAutoCast();
            return;
        else
            return;
        end
    end

    local castDesire, castTarget, castTargetLocation, castTargetType = ConsiderCast(ability);
    if (castDesire ~= nil)
    then
        if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
        then
            if (castTargetType == "target")
            then
                --npcBot:ActionImmediate_Chat("Использую по таргету " .. ability:GetName(), true);
                npcBot:Action_UseAbilityOnEntity(ability, castTarget);
                return;
            elseif (castTargetType == "tree")
            then
                --npcBot:ActionImmediate_Chat("Использую по дереву " .. ability:GetName(), true);
                npcBot:Action_UseAbilityOnTree(ability, castTarget);
                return;
            end
        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
        then
            --npcBot:ActionImmediate_Chat("Использую по точке " .. ability:GetName(), true);
            npcBot:Action_UseAbilityOnLocation(ability, castTargetLocation);
            return;
        elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
        then
            --npcBot:ActionImmediate_Chat("Использую без цели " .. ability:GetName(), true);
            npcBot:Action_UseAbility(ability);
            return;
        end
    end
end

function ConsiderCast(ability)
    local npcBot = GetBot();
    --#region
    -- Get Cast Range
    local castRangeAbility = 0;
    local enemyAbility = {};
    local allyAbility = {};
    local enemyCreeps = {};
    if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET) or
        utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
    then
        castRangeAbility = ability:GetCastRange();
        if castRangeAbility == nil or (castRangeAbility <= 0)
        then
            castRangeAbility = npcBot:GetAttackRange() + 200;
        end
        allyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), false, BOT_MODE_NONE);
        enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);
        enemyCreeps = npcBot:GetNearbyCreeps(utility.GetCurretCastDistance(castRangeAbility), true);
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
    then
        castRangeAbility = ability:GetAOERadius();
        if castRangeAbility == nil or (castRangeAbility <= 0)
        then
            castRangeAbility = npcBot:GetAttackRange() - 200;
        end
        allyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), false, BOT_MODE_NONE);
        enemyAbility = npcBot:GetNearbyHeroes(utility.GetCurretCastDistance(castRangeAbility), true, BOT_MODE_NONE);
        enemyCreeps = npcBot:GetNearbyCreeps(utility.GetCurretCastDistance(castRangeAbility), true);
    elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_OVERSHOOT)
    then
        castRangeAbility = 10000;
        allyAbility = GetUnitList(UNIT_LIST_ALLIED_HEROES);
        enemyAbility = GetUnitList(UNIT_LIST_ENEMY_HEROES);
        enemyCreeps = GetUnitList(UNIT_LIST_ENEMY_CREEPS);
    else
        castRangeAbility = npcBot:GetAttackRange() + 200;
    end
    --#endregion

    print(castRangeAbility)

    if ability:GetName() == "doom_bringer_devour"
    then
        if (#enemyCreeps > 0)
        then
            local creepMaxLevel = ability:GetSpecialValueInt("creep_level");
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.7))
                    and not enemy:IsAncientCreep() and enemy:GetLevel() <= creepMaxLevel
                    and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    return BOT_ACTION_DESIRE_MODERATE, enemy, enemy:GetLocation(), "target";
                end
            end
        end
    elseif ability:GetName() == "clinkz_death_pact"
    then
        if (HealthPercentage <= 0.9)
        then
            if (#enemyCreeps > 0)
            then
                local creepMaxLevel = ability:GetSpecialValueInt("creep_level");
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:GetLevel() <= creepMaxLevel
                        and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        return BOT_ACTION_DESIRE_MODERATE, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end
    elseif ability:GetName() == "terrorblade_sunder"
    then
        -- Cast if enemy has more HP
        if (#enemyAbility > 0) and (HealthPercentage <= 0.2)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() > 0.3)
                    and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    return BOT_MODE_DESIRE_VERYHIGH, enemy, enemy:GetLocation(), "target";
                end
            end
        end
        -- Try to safe ally
        if (#allyAbility > 0) and (HealthPercentage >= 0.3) and
            (not npcBot:WasRecentlyDamagedByAnyHero(2.0) and
                not npcBot:WasRecentlyDamagedByCreep(2.0) and
                not npcBot:WasRecentlyDamagedByTower(2.0))
        then
            for _, ally in pairs(allyAbility)
            do
                if (ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2)
                    and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                    and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally, ally:GetLocation(), "target";
                end
            end
        end
    end

    if IsInterruptAbility(ability:GetName())
    then
        -- Cast if can interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                    then
                        --npcBot:ActionImmediate_Chat("Target/Interrupt сбиваю каст " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end

        -- Retreat use
        if utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                        and not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Target/Interrupt отступаю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end
    end

    --[[     if IsDamageAbility(ability:GetName())
    then ]]
    local damageAbility = ability:GetAbilityDamage();
    -- Cast if can kill somebody
    if (#enemyAbility > 0) and damageAbility ~= nil and (damageAbility > 0)
    then
        for _, enemy in pairs(enemyAbility) do
            if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
            then
                if utility.CanCastSpellOnTarget(ability, enemy) and GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
                then
                    npcBot:ActionImmediate_Chat("Target/Damage убиваю " .. ability:GetName(), true);
                    return BOT_ACTION_DESIRE_ABSOLUTE, enemy, enemy:GetLocation(), "target";
                end
            end
        end
    end
    --end

    if IsHealAbility(ability:GetName())
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                then
                    if ((ally:WasRecentlyDamagedByAnyHero(2.0) or
                                ally:WasRecentlyDamagedByCreep(2.0) or
                                ally:WasRecentlyDamagedByTower(2.0))
                            and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8))
                    then
                        if ability:GetName() == "oracle_purifying_flames"
                        then
                            local magicResist = ally:GetMagicResist();
                            if utility.TargetCantDie(ally) or magicResist >= 0.5
                            then
                                return BOT_ACTION_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                            end
                        else
                            npcBot:ActionImmediate_Chat("Target/Heal лечу " .. ability:GetName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                        end
                    end
                end
            end
        end
    end

    if IsProtectTargetAbility(ability:GetName())
    then
        -- Cast to buff allies
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                then
                    if (ally:WasRecentlyDamagedByAnyHero(2.0) or
                            ally:WasRecentlyDamagedByCreep(2.0) or
                            ally:WasRecentlyDamagedByTower(2.0))
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                    then
                        return BOT_MODE_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                    end
                    if utility.IsHero(ally:GetAttackTarget()) or utility.IsDisabled(ally)
                    then
                        npcBot:ActionImmediate_Chat("Target/Buff бафаю " .. ability:GetName(), true);
                        return BOT_MODE_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                    end
                end
            end
        end
    end

    if IsSafeLifeAbility(ability:GetName())
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if (utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2 and not utility.TargetCantDie(ally))
                    and (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_MODE_DESIRE_ABSOLUTE, ally, ally:GetLocation(), "target";
                end
            end
        end
    end

    if IsSelfBuffAbility(ability:GetName())
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange()
            then
                --npcBot:ActionImmediate_Chat("NoTarget/BuffSelf атакую " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
            then
                --npcBot:ActionImmediate_Chat("NoTarget/BuffSelf отступаю " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    if IsBlinkLikeAbility(ability:GetName())
    then
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget)
            then
                if GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange()
                then
                    return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                end
            end
        elseif utility.RetreatMode(npcBot)
        then
            if npcBot:DistanceFromFountain() >= castRangeAbility
            then
                return BOT_ACTION_DESIRE_HIGH, utility.GetEscapeLocation(npcBot, castRangeAbility);
            end
        end
    end

    if IsInvisAbility(ability:GetName())
    then
        if not npcBot:IsInvisible()
        then
            if utility.PvPMode(npcBot)
            then
                if utility.IsHero(botTarget)
                then
                    if GetUnitToUnitDistance(npcBot, botTarget) > npcBot:GetAttackRange() and GetUnitToUnitDistance(npcBot, botTarget) <= 1600
                    then
                        return BOT_MODE_DESIRE_HIGH, npcBot, npcBot:GetLocation(), "target";
                    end
                end
            elseif utility.RetreatMode(npcBot)
            then
                return BOT_MODE_DESIRE_HIGH, npcBot, npcBot:GetLocation(), "target";
            end
        end
    end

    if IsToggleAbility(ability:GetName())
    then
        if ability:GetName() == "pudge_rot" or ability:GetName() == "leshrac_pulse_nova"
        then
            if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    if ability:GetToggleState() == false
                    then
                        return BOT_MODE_DESIRE_HIGH;
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

        if ability:GetName() == "witch_doctor_voodoo_restoration"
        then
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally) and GetUnitToUnitDistance(npcBot, ally) <= castRangeAbility
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.7) and (ManaPercentage >= 0.3)
                    then
                        if ability:GetToggleState() == false
                        then
                            return BOT_MODE_DESIRE_HIGH;
                        end
                    else
                        if ability:GetToggleState() == true
                        then
                            return BOT_ACTION_DESIRE_HIGH;
                        end
                    end
                end
            else
                if ability:GetToggleState() == true
                then
                    return BOT_ACTION_DESIRE_HIGH;
                end
            end
        end

        if ability:GetName() == "winter_wyvern_arctic_burn"
        then
            if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    and (ManaPercentage >= 0.3)
                then
                    if ability:GetToggleState() == false
                    then
                        return BOT_MODE_DESIRE_HIGH;
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

        if ability:GetName() == "phantom_lancer_phantom_edge" or
            ability:GetName() == "zuus_lightning_hands"
        then
            if ability:GetToggleState() == false
            then
                return BOT_MODE_DESIRE_HIGH;
            end
        end
    end

    if IsTreeTargetAbility(ability:GetName())
    then
        if ability:GetName() == "tiny_tree_grab"
        then
            local trees = npcBot:GetNearbyTrees(npcBot:GetAttackRange() - 200);
            if (#trees > 0) and not utility.RetreatMode(npcBot)
            then
                return BOT_MODE_DESIRE_HIGH, trees[1], GetTreeLocation(trees[1]), "tree";
            end
        end

        if ability:GetName() == "monkey_king_tree_dance"
        then
            if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
            then
                local trees = botTarget:GetNearbyTrees(npcBot:GetAttackRange());
                if (#trees > 0)
                then
                    return BOT_MODE_DESIRE_HIGH, trees[1], GetTreeLocation(trees[1]), "tree";
                end
            end
        end

        if ability:GetName() == "shredder_timber_chain"
        then
            if utility.PvPMode(npcBot) and utility.IsHero(botTarget)
            then
                local trees = botTarget:GetNearbyTrees(225);
                if (#trees > 0)
                then
                    return BOT_MODE_DESIRE_HIGH, trees[1], GetTreeLocation(trees[1]), "tree";
                end
            end
        end
    end



    --utility.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)

    -- Default Use
    if ability:GetName() ~= "oracle_purifying_flames"
    then
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    if IsInterruptAbility(ability:GetName())
                    then
                        if not utility.IsDisabled(botTarget)
                        then
                            return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                        end
                    else
                        --npcBot:ActionImmediate_Chat("Target/Interrupt атакую  " .. ability:GetName(), true);
                        return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                    end
                end
            end
        end
    end



    --[[ if IsInterruptAbility(ability:GetName())
    then
        -- Cast if can interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Target/Interrupt сбиваю каст " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    and not utility.IsDisabled(botTarget)
                then
                    --npcBot:ActionImmediate_Chat("Target/Interrupt атакую  " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                end
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    then
                        --npcBot:ActionImmediate_Chat("Target/Interrupt отступаю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end
    elseif IsDamageAbility(ability:GetName())
    then
        local damageAbility = ability:GetAbilityDamage();
        -- Cast if can kill somebody
        if (#enemyAbility > 0) and damageAbility ~= nil and (damageAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        -- npcBot:ActionImmediate_Chat("Target/Damage убиваю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy, enemy:GetLocation(), "target";
                    end
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    --npcBot:ActionImmediate_Chat("Target/Damage нападаю " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                end
            end
        end
    elseif IsHealTargetAbility(ability:GetName())
    then
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally)
                then
                    if ((ally:WasRecentlyDamagedByAnyHero(2.0) or
                                ally:WasRecentlyDamagedByCreep(2.0) or
                                ally:WasRecentlyDamagedByTower(2.0))
                            and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8))
                    then
                        if ability:GetName() == "oracle_purifying_flames"
                        then
                            local magicResist = ally:GetMagicResist();
                            if utility.TargetCantDie(ally) or magicResist >= 0.5
                            then
                                return BOT_ACTION_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                            end
                        else
                            npcBot:ActionImmediate_Chat("Target/Heal лечу " .. ability:GetName(), true);
                            return BOT_ACTION_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                        end
                    end
                end
            end
        end
    elseif IsProtectTargetAbility(ability:GetName())
    then
        -- Cast to buff allies
        if (#allyAbility > 0)
        then
            for _, ally in pairs(allyAbility)
            do
                if utility.IsHero(ally)
                then
                    if (ally:WasRecentlyDamagedByAnyHero(2.0) or
                            ally:WasRecentlyDamagedByCreep(2.0) or
                            ally:WasRecentlyDamagedByTower(2.0))
                        and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                    then
                        return BOT_MODE_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                    end
                    if utility.IsHero(ally:GetAttackTarget()) or utility.IsDisabled(ally)
                    then
                        npcBot:ActionImmediate_Chat("Target/Buff бафаю " .. ability:GetName(), true);
                        return BOT_MODE_DESIRE_HIGH, ally, ally:GetLocation(), "target";
                    end
                end
            end
        end
    elseif IsSelfBuffAbility(ability:GetName())
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange()
            then
                npcBot:ActionImmediate_Chat("NoTarget/BuffSelf атакую " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
            then
                npcBot:ActionImmediate_Chat("NoTarget/BuffSelf отступаю " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    --if utility.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)
    --then
    -- Attack use
    if ability:GetName() ~= "oracle_purifying_flames"
    then
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    npcBot:ActionImmediate_Chat("Target/All нападаю " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget, botTarget:GetLocation(), "target";
                end
            end
        end
    end ]]
end

----------------------------------------------------
local function ConsiderUnitTarget(ability)
    local ability = ability;
    local npcBot = GetBot();
    local castRangeAbility = npcBot:GetAttackRange() + 200;
    local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);
    local enemyCreeps = npcBot:GetNearbyCreeps(castRangeAbility, true);

    --print(castRangeAbility)

    if ability:GetName() == "doom_bringer_devour"
    then
        if (#enemyCreeps > 0)
        then
            local creepMaxLevel = ability:GetSpecialValueInt("creep_level");
            for _, enemy in pairs(enemyCreeps) do
                if (utility.CanCastOnMagicImmuneTarget(enemy) and (enemy:GetHealth() / enemy:GetMaxHealth() >= 0.7))
                    and not enemy:IsAncientCreep() and enemy:GetLevel() <= creepMaxLevel
                then
                    return BOT_ACTION_DESIRE_MODERATE, enemy, "target";
                end
            end
        end
    elseif ability:GetName() == "clinkz_death_pact"
    then
        if (HealthPercentage <= 0.9)
        then
            if (#enemyCreeps > 0)
            then
                local creepMaxLevel = ability:GetSpecialValueInt("creep_level");
                for _, enemy in pairs(enemyCreeps) do
                    if utility.CanCastOnMagicImmuneTarget(enemy) and enemy:GetLevel() <= creepMaxLevel
                    then
                        return BOT_ACTION_DESIRE_MODERATE, enemy, "target";
                    end
                end
            end
        end
    elseif ability:GetName() == "terrorblade_sunder"
    then
        local allyAbility = npcBot:GetNearbyHeroes(castRangeAbility, false, BOT_MODE_NONE);
        -- Cast if enemy has more HP
        if (#enemyAbility > 0) and (HealthPercentage <= 0.2)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanCastSpellOnTarget(ability, enemy) and (enemy:GetHealth() / enemy:GetMaxHealth()) > 0.3
                then
                    return BOT_MODE_DESIRE_VERYHIGH, enemy, "target";
                end
            end
        end
        -- Try to safe ally
        if (#allyAbility > 0) and (HealthPercentage >= 0.3) and
            (not npcBot:WasRecentlyDamagedByAnyHero(2.0) and
                not npcBot:WasRecentlyDamagedByCreep(2.0) and
                not npcBot:WasRecentlyDamagedByTower(2.0))
        then
            for _, ally in pairs(allyAbility)
            do
                if (ally ~= npcBot and utility.IsHero(ally) and ally:GetHealth() / ally:GetMaxHealth() <= 0.2)
                    and
                    (ally:WasRecentlyDamagedByAnyHero(2.0) or
                        ally:WasRecentlyDamagedByCreep(2.0) or
                        ally:WasRecentlyDamagedByTower(2.0))
                then
                    return BOT_ACTION_DESIRE_ABSOLUTE, ally, "target";
                end
            end
        end
    else
        if IsInterruptTargetAbility(ability:GetName())
        then
            -- Cast if can interrupt cast
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                    then
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            npcBot:ActionImmediate_Chat("Target/Interrupt сбиваю каст " .. ability:GetName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE, enemy, "target";
                        end
                    end
                end
            end
            -- Attack use
            if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
            then
                if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
                then
                    if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                        and not utility.IsDisabled(botTarget)
                    then
                        npcBot:ActionImmediate_Chat("Target/Interrupt атакую  " .. ability:GetName(), true);
                        return BOT_MODE_DESIRE_HIGH, botTarget, "target";
                    end
                end
                -- Retreat use
            elseif utility.RetreatMode(npcBot)
            then
                if (#enemyAbility > 0)
                then
                    for _, enemy in pairs(enemyAbility) do
                        if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                        then
                            npcBot:ActionImmediate_Chat("Target/Interrupt отступаю " .. ability:GetName(), true);
                            return BOT_ACTION_DESIRE_VERYHIGH, enemy, "target";
                        end
                    end
                end
            end
        elseif IsDamageTargetAbility(ability:GetName())
        then
            local damageAbility = ability:GetAbilityDamage();
            -- Cast if can kill somebody
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                    then
                        if utility.CanCastSpellOnTarget(ability, enemy)
                        then
                            npcBot:ActionImmediate_Chat("Target/Damage убиваю " .. ability:GetName(), true);
                            return BOT_ACTION_DESIRE_ABSOLUTE, enemy, "target";
                        end
                    end
                end
            end
            -- Attack use
            if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
            then
                if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
                then
                    if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    then
                        npcBot:ActionImmediate_Chat("Target/Damage нападаю " .. ability:GetName(), true);
                        return BOT_MODE_DESIRE_HIGH, botTarget, "target";
                    end
                end
            end
        elseif IsHealTargetAbility(ability:GetName())
        then
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally)
                    then
                        if ((ally:WasRecentlyDamagedByAnyHero(2.0) or
                                    ally:WasRecentlyDamagedByCreep(2.0) or
                                    ally:WasRecentlyDamagedByTower(2.0))
                                and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8))
                        then
                            if ability:GetName() == "oracle_purifying_flames"
                            then
                                local magicResist = ally:GetMagicResist();
                                if utility.TargetCantDie(ally) or magicResist >= 0.5
                                then
                                    return BOT_ACTION_DESIRE_HIGH, ally, "target";
                                end
                            else
                                npcBot:ActionImmediate_Chat("Target/Heal лечу " .. ability:GetName(), true);
                                return BOT_ACTION_DESIRE_HIGH, ally, "target";
                            end
                        end
                    end
                end
            end
        elseif IsProtectTargetAbility(ability:GetName())
        then
            -- Cast to buff allies
            if (#allyAbility > 0)
            then
                for _, ally in pairs(allyAbility)
                do
                    if utility.IsHero(ally)
                    then
                        if (ally:WasRecentlyDamagedByAnyHero(2.0) or
                                ally:WasRecentlyDamagedByCreep(2.0) or
                                ally:WasRecentlyDamagedByTower(2.0))
                            and (ally:GetHealth() / ally:GetMaxHealth() <= 0.8)
                        then
                            return BOT_MODE_DESIRE_HIGH, ally, "target";
                        end
                        if utility.IsHero(ally:GetAttackTarget()) or utility.IsDisabled(ally)
                        then
                            npcBot:ActionImmediate_Chat("Target/Buff бафаю " .. ability:GetName(), true);
                            return BOT_MODE_DESIRE_HIGH, ally, "target";
                        end
                    end
                end
            end
        end

        if utility.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)
        then
            -- Attack use
            if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
            then
                if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
                then
                    if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    then
                        if ability:GetName() ~= "oracle_purifying_flames"
                        then
                            npcBot:ActionImmediate_Chat("Target/All нападаю " .. ability:GetName(), true);
                            return BOT_MODE_DESIRE_HIGH, botTarget, "target";
                        end
                    end
                end
            end
        end
    end
end

local function ConsiderPointTarget(ability)
    local ability = ability;
    local npcBot = GetBot();
    local castRangeAbility = npcBot:GetAttackRange() + 200;
    local enemyAbility = npcBot:GetNearbyHeroes(castRangeAbility, true, BOT_MODE_NONE);

    --print(castRangeAbility)

    if IsInterruptPointAbility(ability:GetName())
    then
        -- Cast if can interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        npcBot:ActionImmediate_Chat("Point/Interrupt сбиваю каст " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE, enemy:GetLocation();
                    end
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                    and not utility.IsDisabled(botTarget)
                then
                    npcBot:ActionImmediate_Chat("Point/Interrupt атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget:GetLocation();
                end
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    then
                        npcBot:ActionImmediate_Chat("Point/Interrupt отступаю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH, enemy:GetLocation();
                    end
                end
            end
        end
    elseif IsDamagePointAbility(ability:GetName())
    then
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    npcBot:ActionImmediate_Chat("Point/Damage атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget:GetLocation();
                end
            end
        end
    end

    -- Attack use
    if utility.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)
    then
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
                then
                    npcBot:ActionImmediate_Chat("Point/All атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH, botTarget:GetLocation();
                end
            end
        end
    end
end

local function ConsiderNoTarget(ability)
    local ability = ability;
    local npcBot = GetBot();
    local radiusAbility = ability:GetAOERadius();
    local enemyAbility = npcBot:GetNearbyHeroes(radiusAbility, true, BOT_MODE_NONE);

    print(radiusAbility)

    if IsInterruptNoTargetAbility(ability:GetName())
    then
        -- Cast if can interrupt cast
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if enemy:IsChanneling()
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        npcBot:ActionImmediate_Chat("NoTarget/Interrupt сбиваю каст " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE;
                    end
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                    and not utility.IsDisabled(botTarget)
                then
                    npcBot:ActionImmediate_Chat("NoTarget/Interrupt атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            if (#enemyAbility > 0)
            then
                for _, enemy in pairs(enemyAbility) do
                    if utility.CanCastSpellOnTarget(ability, enemy) and not utility.IsDisabled(enemy)
                    then
                        npcBot:ActionImmediate_Chat("NoTarget/Interrupt отступаю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_VERYHIGH;
                    end
                end
            end
        end
    elseif IsDamageNoTargetAbility(ability:GetName())
    then
        local damageAbility = ability:GetAbilityDamage();
        -- Cast if can kill somebody
        if (#enemyAbility > 0)
        then
            for _, enemy in pairs(enemyAbility) do
                if utility.CanAbilityKillTarget(enemy, damageAbility, ability:GetDamageType())
                then
                    if utility.CanCastSpellOnTarget(ability, enemy)
                    then
                        npcBot:ActionImmediate_Chat("NoTarget/Damage убиваю " .. ability:GetName(), true);
                        return BOT_ACTION_DESIRE_ABSOLUTE;
                    end
                end
            end
        end
        -- Attack use
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                then
                    npcBot:ActionImmediate_Chat("NoTarget/Damage атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
        end
    elseif IsSelfBuffAbility(ability:GetName())
    then
        -- Attack use
        if utility.PvPMode(npcBot)
        then
            if utility.IsHero(botTarget) and utility.CanCastOnInvulnerableTarget(botTarget)
                and GetUnitToUnitDistance(npcBot, botTarget) <= npcBot:GetAttackRange()
            then
                npcBot:ActionImmediate_Chat("NoTarget/BuffSelf атакую " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
            -- Retreat use
        elseif utility.RetreatMode(npcBot)
        then
            local enemyAbility = npcBot:GetNearbyHeroes(1600, true, BOT_MODE_NONE);
            if (#enemyAbility > 0) and (HealthPercentage <= 0.8)
            then
                npcBot:ActionImmediate_Chat("NoTarget/BuffSelf отступаю " .. ability:GetName(), true);
                return BOT_ACTION_DESIRE_HIGH;
            end
        end
    end

    -- Attack use
    if utility.CheckFlag(ability:GetTargetTeam(), ABILITY_TARGET_TEAM_ENEMY)
    then
        if utility.PvPMode(npcBot) or botMode == BOT_MODE_ROSHAN
        then
            if utility.IsHero(botTarget) or utility.IsRoshan(botTarget)
            then
                if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= radiusAbility
                then
                    npcBot:ActionImmediate_Chat("NoTarget/All атакую " .. ability:GetName(), true);
                    return BOT_MODE_DESIRE_HIGH;
                end
            end
        end
    end
end

-- Enemy use
--if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TEAM_ENEMY)
--then
--if utility.CheckFlag(ability:GetTargetType(), ABILITY_TARGET_TYPE_HERO)
--then
--[[     if utility.PvPMode(npcBot)
    then
        if utility.IsHero(botTarget)
        then
            --if utility.CanCastSpellOnTarget(ability, botTarget) and GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            --then
            if GetUnitToUnitDistance(npcBot, botTarget) <= castRangeAbility
            then
                if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
                then
                    npcBot:Action_UseAbilityOnEntity(ability, botTarget)
                    return;
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
                then
                    npcBot:Action_UseAbilityOnLocation(ability, botTarget:GetLocation())
                    return;
                elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
                then
                    npcBot:Action_UseAbility(ability);
                    return;
                end
                --end
                npcBot:ActionImmediate_Chat("Использую " .. ability:GetName(), true);
            end
        end
    end ]]
--end
--end

--[[ if (#enemyAbility > 0)
then
    for _, enemy in pairs(enemyAbility) do
        if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую " .. ability:GetName(), true);
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                npcBot:Action_UseAbilityOnEntity(ability, enemy)
                return;
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                npcBot:Action_UseAbilityOnLocation(ability, enemy:GetLocation())
                return;
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
            then
                npcBot:Action_UseAbility(ability);
                return;
            end
        end
    end
end
if (#enemyCreeps > 0)
then
    for _, enemy in pairs(enemyCreeps) do
        if GetUnitToUnitDistance(npcBot, enemy) <= castRangeAbility
        then
            --npcBot:ActionImmediate_Chat("Использую " .. ability:GetName(), true);
            if utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_UNIT_TARGET)
            then
                npcBot:Action_UseAbilityOnEntity(ability, enemy)
                return;
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_POINT)
            then
                npcBot:Action_UseAbilityOnLocation(ability, enemy:GetLocation())
                return;
            elseif utility.CheckFlag(ability:GetBehavior(), ABILITY_BEHAVIOR_NO_TARGET)
            then
                npcBot:Action_UseAbility(ability);
                return;
            end
        end
    end
end ]]

--[[ local desire1 = BOT_ACTION_DESIRE_LOW  -- 0,0
local desire2 = BOT_ACTION_DESIRE_HIGH -- 0,5
local desire3 = BOT_ACTION_DESIRE_ABSOLUTE -- 1,0

local max = math.max(desire1, desire2, desire3)  ]]

---------------------------------------------------------------------------------------------------
for k, v in pairs(spell_usage_generic) do _G._savedEnv[k] = v end
