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
	"item_gloves",
	"item_robe",

	"item_shadow_amulet",
	"item_blitz_knuckles",
	"item_broadsword",

	"item_javelin",
	"item_mithril_hammer",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_blades_of_attack",
	"item_broadsword",
	"item_recipe_lesser_crit",

	"item_blitz_knuckles",
	"item_staff_of_wizardry",
	"item_cornucopia",
	"item_recipe_orchid",

	"item_hyperstone",
	"item_recipe_mjollnir",

	"item_recipe_silver_edge",

	"item_quarterstaff",
	"item_sobi_mask",
	"item_robe",
	"item_cloak",
	"item_recipe_mage_slayer",

	"item_recipe_bloodthorn",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
