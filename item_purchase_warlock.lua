require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
	"item_magic_stick",
	"item_branches",
	"item_branches",

	"item_flask",
	"item_clarity",
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

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_cornucopia",
	"item_cornucopia",
	"item_recipe_refresher",

	"item_aghanims_shard",

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_recipe_guardian_greaves",

	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",

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