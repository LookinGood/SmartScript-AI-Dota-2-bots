---@diagnostic disable: undefined-global
require( GetScriptDirectory().."/item_purchase_generic" ) 

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

    "item_ring_of_protection",
    "item_fluffy_hat",
    "item_energy_booster",
    "item_recipe_pavise",

    "item_wind_lace",
    "item_crown",
    "item_recipe_solar_crest",

    "item_energy_booster",
	"item_void_stone",
	"item_recipe_aether_lens",

    "item_cloak",
	"item_shadow_amulet",
	"item_recipe_glimmer_cape",

    "item_wind_lace",
    "item_belt_of_strength",
    "item_robe",
    "item_recipe_ancient_janggo",

    "item_aghanims_shard",

    "item_recipe_boots_of_bearing",

    "item_helm_of_iron_will",
    "item_crown",
    "item_recipe_veil_of_discord",
    "item_platemail",
    "item_recipe_shivas_guard",

    "item_ghost",
	"item_recipe_ethereal_blade",

    "item_point_booster",
	"item_ogre_axe",
	"item_staff_of_wizardry",
	"item_blade_of_alacrity",

	"item_recipe_ultimate_scepter_2",

    "item_energy_booster",
	"item_vitality_booster",
	"item_recipe_aeon_disk",
}

function ItemPurchaseThink()
	purchase.ItemPurchase(ItemsToBuy)
end