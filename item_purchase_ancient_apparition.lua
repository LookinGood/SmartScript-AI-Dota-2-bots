---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_wind_lace",

	"item_flask",
	"item_clarity",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_void_stone",
	"item_staff_of_wizardry",
	"item_recipe_cyclone",

	"item_aghanims_shard",

	"item_ring_of_health",
	"item_void_stone",
	"item_energy_booster",
	"item_platemail",
	"item_recipe_lotus_orb",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_mystic_staff",
	"item_recipe_wind_waker",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
