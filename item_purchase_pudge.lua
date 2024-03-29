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
    "item_blades_of_attack",
    "item_chainmail",

    "item_cloak",
    "item_ogre_axe",
    "item_vitality_booster",
    "item_recipe_eternal_shroud",

    "item_blink",

    "item_point_booster",
    "item_ogre_axe",
    "item_staff_of_wizardry",
    "item_blade_of_alacrity",

    "item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

    "item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

    "item_recipe_ultimate_scepter_2",

    "item_reaver",
    "item_recipe_overwhelming_blink",

    "item_recipe_travel_boots",
    "item_boots",

    "item_recipe_travel_boots",

    "item_aghanims_shard",
}

function ItemPurchaseThink()
    purchase.ItemPurchase(ItemsToBuy)
end
