---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_enchanted_mango",
	"item_ring_of_protection",
	"item_gauntlets",
	"item_branches",
	"item_branches",
	"item_flask",
	"item_magic_stick",

	"item_recipe_magic_wand",

	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_wind_lace",

	"item_boots",
	"item_energy_booster",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

	"item_void_stone",
	"item_staff_of_wizardry",
	"item_recipe_cyclone",

	"item_void_stone",
	"item_void_stone",

	"item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
	"item_recipe_octarine_core",

	"item_mystic_staff",
	"item_recipe_wind_waker",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots_2",

}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end


-- "item_aghanims_shard",