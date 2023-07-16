---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",

	"item_enchanted_mango",
	"item_flask",

	"item_recipe_soul_ring",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_aghanims_shard",

	"item_blink",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_ghost",
	"item_recipe_ethereal_blade",

	"item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",

	"item_void_stone",
	"item_void_stone",

	"item_recipe_octarine_core",

	"item_mystic_staff",
	"item_recipe_arcane_blink",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
