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

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
    "item_recipe_soul_ring",

	"item_circlet",
	"item_gauntlets",
	"item_recipe_bracer",

	"item_boots",
	"item_blades_of_attack",
	"item_chainmail",

	"item_blink",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_blight_stone",
    "item_mithril_hammer",
	"item_mithril_hammer",

	"item_lifesteal",
    "item_claymore",
    "item_reaver",

	"item_reaver",
	"item_recipe_overwhelming_blink",

	"item_demon_edge",
	"item_relic",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
