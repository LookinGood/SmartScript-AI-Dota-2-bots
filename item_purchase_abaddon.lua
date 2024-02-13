---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_enchanted_mango",
    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_chainmail",
    "item_recipe_mekansm",

    "item_helm_of_iron_will",
    "item_recipe_crimson_guard",

    "item_ring_of_protection",
    "item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_ring_of_health",
    "item_void_stone",
    "item_energy_booster",
    "item_platemail",
    "item_recipe_lotus_orb",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

    "item_aghanims_shard",

    "item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
