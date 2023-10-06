---@diagnostic disable: undefined-global
require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_clarity",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

	"item_robe",
	"item_staff_of_wizardry",
    "item_recipe_kaya",

	"item_voodoo_mask",
    "item_diadem",
    "item_recipe_dagon",

	"item_aghanims_shard",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_recipe_dagon",

	"item_recipe_dagon",

	"item_recipe_dagon",

	"item_recipe_dagon",

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
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end