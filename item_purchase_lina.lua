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

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_ring_of_regen",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

	"item_void_stone",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_recipe_boots_of_bearing",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_aghanims_shard",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_point_booster",
	"item_energy_booster",
	"item_vitality_booster",
	"item_void_stone",
	"item_void_stone",
	"item_recipe_octarine_core",

	"item_recipe_ultimate_scepter",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end
