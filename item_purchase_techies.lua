---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_wind_lace",
	"item_branches",
	"item_branches",
	"item_enchanted_mango",
	"item_flask",

	"item_recipe_magic_wand",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",
	"item_energy_booster",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_void_stone",
	"item_staff_of_wizardry",
	"item_recipe_cyclone",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_aghanims_shard",

	"item_voodoo_mask",
	"item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_bloodstone",

	"item_mystic_staff",
	"item_recipe_wind_waker",

	"item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
	"item_void_stone",
	"item_void_stone",
	"item_recipe_octarine_core",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end


-- "item_aghanims_shard",