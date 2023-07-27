---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_faerie_fire",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_gloves",
	"item_robe",

	"item_robe",
	"item_chainmail",
	"item_blitz_knuckles",
	"item_recipe_witch_blade",

	"item_ogre_axe",
	"item_mithril_hammer",
	"item_recipe_black_king_bar",

	"item_aghanims_shard",

	"item_blitz_knuckles",
	"item_staff_of_wizardry",
	"item_cornucopia",
	"item_recipe_orchid",

	"item_robe",
	"item_staff_of_wizardry",
	"item_recipe_kaya",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_quarterstaff",
	"item_sobi_mask",
	"item_robe",
	"item_cloak",
	"item_recipe_mage_slayer",

	"item_recipe_bloodthorn",

	"item_mystic_staff",
	"item_recipe_revenants_brooch",

	"item_hyperstone",
	"item_hyperstone",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
