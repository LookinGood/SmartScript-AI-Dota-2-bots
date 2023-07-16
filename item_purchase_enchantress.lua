---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_enchanted_mango",
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

	"item_blade_of_alacrity",
	"item_belt_of_strength",
	"item_recipe_dragon_lance",

	"item_cornucopia",
	"item_ultimate_orb",
	"item_recipe_sphere",

	"item_aghanims_shard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_blade_of_alacrity",
	"item_boots_of_elves",
	"item_recipe_yasha",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_recipe_hurricane_pike",

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