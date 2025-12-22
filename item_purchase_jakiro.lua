---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_clarity",

    "item_magic_wand",

    "item_null_talisman",

    "item_ring_of_basilius",
    "item_arcane_boots",

    "item_force_staff",

    "item_headdress",
    "item_mekansm",

    "item_guardian_greaves",

    "item_cyclone",

    "item_ultimate_scepter",

    "item_soul_booster",
    "item_bloodstone",

    "item_aghanims_shard",

    "item_sheepstick",

    "item_ultimate_scepter_2",

    "item_wind_waker",

    "item_soul_booster",
    "item_octarine_core",
}

local realItemsToBuy = {}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy, realItemsToBuy)
end

-- Old version
--[[ local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_wind_lace",
    "item_branches",
    "item_branches",
    "item_flask",
    "item_clarity",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_mantle",
    "item_recipe_null_talisman",

    "item_boots",
    "item_ring_of_regen",

    "item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

    "item_recipe_boots_of_bearing",

    "item_fluffy_hat",
    "item_staff_of_wizardry",
    "item_recipe_force_staff",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_cloak",
    "item_ring_of_tarrasque",
    "item_recipe_pipe",

    "item_aghanims_shard",

    "item_blink",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_tiara_of_selemene",
    "item_mystic_staff",
    "item_recipe_sheepstick",

    "item_recipe_ultimate_scepter_2",

    "item_mystic_staff",
    "item_recipe_arcane_blink",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",
} ]]
