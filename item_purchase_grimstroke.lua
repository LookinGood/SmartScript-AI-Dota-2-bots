---@diagnostic disable: undefined-global
require(GetScriptDirectory() .. "/item_purchase_generic")

local ItemsToBuy =
{
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_clarity",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_aghanims_shard",

	"item_point_booster",
	"item_staff_of_wizardry",
	"item_ogre_axe",
	"item_blade_of_alacrity",

	"item_void_stone",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_ring_of_health",
	"item_void_stone",
	"item_energy_booster",
	"item_platemail",
	"item_recipe_lotus_orb",

	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_ring_of_protection",
	"item_recipe_buckler",

	"item_recipe_guardian_greaves",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
