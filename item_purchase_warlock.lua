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
    "item_sobi_mask",
    "item_recipe_ring_of_basilius",
	"item_recipe_arcane_boots",

    "item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

	"item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

    "item_cornucopia",
	"item_ring_of_tarrasque",
    "item_tiara_of_selemene",
	"item_recipe_refresher",

	"item_aghanims_shard",

	"item_recipe_ultimate_scepter_2",

	"item_ring_of_protection",
	"item_recipe_buckler",
	"item_ring_of_regen",
	"item_recipe_headdress",
	"item_chainmail",
	"item_recipe_mekansm",

	"item_recipe_guardian_greaves",

    "item_energy_booster",
    "item_vitality_booster",
    "item_point_booster",
    "item_tiara_of_selemene",

	"item_ring_of_health",
	"item_void_stone",
	"item_energy_booster",
	"item_platemail",
	"item_recipe_lotus_orb",

	"item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end