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

	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_aghanims_shard",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_ring_of_protection",
	"item_recipe_buckler",

	"item_recipe_guardian_greaves",

	"item_void_stone",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_energy_booster",
	"item_vitality_booster",
	"item_point_booster",
	"item_void_stone",
	"item_void_stone",
	"item_recipe_octarine_core",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
