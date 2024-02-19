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

    "item_boots",
    "item_blades_of_attack",
    "item_chainmail",

    "item_ring_of_health",
    "item_vitality_booster",

    "item_aghanims_shard",

    "item_helm_of_iron_will",
    "item_recipe_crimson_guard",

    "item_chainmail",
    "item_broadsword",
    "item_recipe_blade_mail",

    "item_blink",

    "item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_recipe_ultimate_scepter_2",

    "item_ring_of_protection",
	"item_recipe_buckler",
	"item_platemail",
	"item_hyperstone",
	"item_recipe_assault",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
