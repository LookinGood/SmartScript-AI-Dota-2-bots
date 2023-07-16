---@diagnostic disable: undefined-global
require( GetScriptDirectory().."/item_purchase_generic" ) 

local ItemsToBuy =
{ 
	"item_tango",
    "item_magic_stick",
    "item_branches",
    "item_branches",
    "item_enchanted_mango",
    "item_enchanted_mango",

    "item_flask",
    "item_recipe_magic_wand",

    "item_circlet",
	"item_mantle",
	"item_recipe_null_talisman",

	"item_boots",
	"item_energy_booster",

    "item_blight_stone",
    "item_sobi_mask",
    "item_chainmail",

    "item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

    "item_aghanims_shard",

    "item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

    "item_wind_lace",
    "item_crown",
    "item_recipe_solar_crest",

    "item_cornucopia",
    "item_ultimate_orb",
    "item_recipe_sphere",

    "item_point_booster",
    "item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

    "item_hyperstone",
	"item_hyperstone",

    "item_recipe_travel_boots",
	"item_boots",

	"item_recipe_travel_boots_2",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end