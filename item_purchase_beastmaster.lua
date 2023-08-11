---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_faerie_fire",
    "item_wind_lace",

    "item_flask",

    "item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

    "item_boots",
    "item_ring_of_regen",

    "item_sobi_mask",
    "item_recipe_ring_of_basilius",

    "item_ring_of_protection",
    "item_recipe_buckler",

    "item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

    "item_lifesteal",
    "item_blades_of_attack",
    "item_recipe_vladmir",

    "item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

    "item_talisman_of_evasion",
    "item_recipe_heavens_halberd",

    "item_recipe_boots_of_bearing",

    "item_helm_of_iron_will",
    "item_diadem",
    "item_recipe_helm_of_the_dominator",

    "item_aghanims_shard",

    "item_ogre_axe",
    "item_mithril_hammer",
    "item_recipe_black_king_bar",

    "item_recipe_helm_of_the_overlord",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_ring_of_protection",
    "item_recipe_buckler",

    "item_platemail",
    "item_hyperstone",
    "item_recipe_assault",

    "item_hyperstone",
    "item_hyperstone",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
