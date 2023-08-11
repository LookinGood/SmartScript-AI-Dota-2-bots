require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_enchanted_mango",

	"item_recipe_magic_wand",

	"item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

	"item_voodoo_mask",
	"item_diadem",
	"item_recipe_dagon",

	"item_staff_of_wizardry",
	"item_robe",
	"item_recipe_kaya",

	"item_aghanims_shard",

	"item_recipe_dagon",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_talisman_of_evasion",
	"item_relic",

	"item_vitality_booster",
    "item_reaver",
    "item_recipe_heart",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end