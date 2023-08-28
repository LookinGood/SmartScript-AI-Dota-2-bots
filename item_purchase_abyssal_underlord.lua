---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
    "item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_faerie_fire",
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
	"item_energy_booster",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

    "item_staff_of_wizardry",
	"item_vitality_booster",
	"item_recipe_rod_of_atos",

    "item_aghanims_shard",

    "item_helm_of_iron_will",
    "item_recipe_crimson_guard",

    "item_ring_of_protection",
	"item_recipe_buckler",
    "item_recipe_guardian_greaves",

    "item_platemail",
    "item_mystic_staff",
    "item_recipe_shivas_guard",

    "item_mithril_hammer",
	"item_javelin",

	"item_recipe_gungir",

    "item_vitality_booster",
    "item_reaver",
    "item_recipe_heart",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end