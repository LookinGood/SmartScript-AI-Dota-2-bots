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
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_blades_of_attack",
	"item_chainmail",

	"item_shadow_amulet",
	"item_blitz_knuckles",
	"item_broadsword",

	"item_gloves",
	"item_javelin",
	"item_mithril_hammer",

	"item_aghanims_shard",

	"item_demon_edge",
	"item_recipe_silver_edge",

	"item_sobi_mask",
	"item_robe",
	"item_blitz_knuckles",
	"item_cornucopia",
	"item_recipe_orchid",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_recipe_ultimate_scepter_2",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_javelin",
	"item_hyperstone",
	"item_recipe_bloodthorn",

	"item_hyperstone",
	"item_hyperstone",

	"item_blades_of_attack",
	"item_claymore",
	"item_recipe_lesser_crit",

	"item_demon_edge",
	"item_recipe_greater_crit",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
