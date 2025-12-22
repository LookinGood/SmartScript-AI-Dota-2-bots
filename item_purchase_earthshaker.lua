---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",

    "item_flask",

    "item_enchanted_mango",

    "item_magic_wand",

    "item_bracer",

    "item_soul_ring",

    "item_ring_of_basilius",
    "item_arcane_boots",

    "item_veil_of_discord",

    "item_blink",

    "item_shivas_guard",

    "item_aghanims_shard",

    "item_headdress",
    "item_mekansm",

    "item_guardian_greaves",

    "item_black_king_bar",

    "item_refresher",

    "item_ultimate_scepter",
    "item_ultimate_scepter_2",

    "item_overwhelming_blink",

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
    "item_branches",
    "item_branches",
    "item_enchanted_mango",
    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_ring_of_protection",
    "item_gauntlets",
    "item_gauntlets",
    "item_recipe_soul_ring",

    "item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",

    "item_blink",

    "item_aghanims_shard",

    "item_platemail",
    "item_recipe_shivas_guard",

    "item_ring_of_regen",
    "item_recipe_headdress",
    "item_chainmail",
    "item_recipe_mekansm",

    "item_ring_of_protection",
    "item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_ogre_axe",
    "item_mithril_hammer",
    "item_recipe_black_king_bar",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_cornucopia",
    "item_ring_of_tarrasque",
    "item_tiara_of_selemene",
    "item_recipe_refresher",

    "item_recipe_ultimate_scepter_2",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",
} ]]
