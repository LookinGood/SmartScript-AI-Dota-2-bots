---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_clarity",

    "item_magic_wand",

    "item_null_talisman",

    "item_tranquil_boots",

    "item_glimmer_cape",

    "item_ancient_janggo",
    "item_boots_of_bearing",

    "item_pavise",
    "item_solar_crest",

    "item_aghanims_shard",

    "item_ultimate_scepter",

    "item_arcane_blink",

    "item_aeon_disk",

    "item_ultimate_scepter_2",

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

    "item_shadow_amulet",
    "item_cloak",
    "item_recipe_glimmer_cape",

    "item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

    "item_recipe_boots_of_bearing",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_blink",

    "item_energy_booster",
    "item_vitality_booster",
    "item_recipe_aeon_disk",

    "item_recipe_ultimate_scepter_2",

    "item_ring_of_protection",
    "item_fluffy_hat",
    "item_energy_booster",
    "item_recipe_pavise",

    "item_wind_lace",
    "item_crown",
    "item_recipe_solar_crest",

    "item_mystic_staff",
    "item_recipe_arcane_blink",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

    "item_aghanims_shard",
} ]]
