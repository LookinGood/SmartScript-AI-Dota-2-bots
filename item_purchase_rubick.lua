require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_wind_lace",
	"item_branches",
	"item_branches",
	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_sobi_mask",
	"item_recipe_ring_of_basilius",
	"item_recipe_arcane_boots",

	"item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_fluffy_hat",
	"item_staff_of_wizardry",
	"item_recipe_force_staff",

	"item_void_stone",
	"item_staff_of_wizardry",
	"item_recipe_cyclone",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_tiara_of_selemene",
	"item_mystic_staff",
	"item_recipe_sheepstick",

	"item_recipe_ultimate_scepter_2",

	"item_mystic_staff",
	"item_recipe_wind_waker",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_tiara_of_selemene",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",

	"item_aghanims_shard",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
