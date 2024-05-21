require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",
	"item_enchanted_mango",
	"item_clarity",
	"item_flask",

	"item_recipe_magic_wand",

    "item_circlet",
    "item_gauntlets",
    "item_recipe_bracer",

	"item_ring_of_protection",
	"item_gauntlets",
	"item_gauntlets",
	"item_recipe_soul_ring",

	"item_boots",
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
    "item_recipe_arcane_boots",

	"item_gloves",
	"item_recipe_hand_of_midas",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_aghanims_shard",

	"item_voodoo_mask",
	"item_diadem",
	"item_recipe_dagon",

	"item_robe",
	"item_staff_of_wizardry",
	"item_recipe_kaya",

	"item_belt_of_strength",
    "item_ogre_axe",
    "item_recipe_sange",

	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",
	"item_recipe_dagon",

	"item_point_booster",
    "item_energy_booster",
    "item_vitality_booster",
    "item_void_stone",
    "item_voodoo_mask",

	"item_recipe_ultimate_scepter_2",

	"item_tiara_of_selemene",
	"item_ultimate_orb",
	"item_mystic_staff",

	"item_ring_of_tarrasque",
    "item_reaver",
    "item_recipe_heart",

	"item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end